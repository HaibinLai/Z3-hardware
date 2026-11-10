"""Exact symbolic execution of Yosys transition equations, with SMT lemmas."""
import json
import sys
import time
import faulthandler
import resource
_stack_soft,_stack_hard=resource.getrlimit(resource.RLIMIT_STACK)
_stack_target=256*1024*1024 if _stack_hard==resource.RLIM_INFINITY else min(256*1024*1024,_stack_hard)
if _stack_soft!=resource.RLIM_INFINITY and _stack_soft<_stack_target:
    try:resource.setrlimit(resource.RLIMIT_STACK,(_stack_target,_stack_hard))
    except (ValueError,OSError):pass
from pathlib import Path
import z3 as z

sys.setrecursionlimit(100000)
ROOT=Path(__file__).resolve().parents[1]


def state_read(x):
    return (z.is_app(x) and x.num_args()==1 and
            x.decl().kind()==z.Z3_OP_UNINTERPRETED and
            str(x.arg(0).sort()).endswith('_s'))


def step(x):
    return int(str(x.arg(0)).rsplit('_',1)[1])


def flatten(x):
    if z.is_and(x):
        for c in x.children():yield from flatten(c)
    else:yield x


def build(top,n,cycles):
    start=time.monotonic()
    pass # No asynchronous stack-dump thread during native Z3 calls.
    print(top,"START",flush=True)
    av=[z.BitVec(f'a{i}',32) for i in range(n)]
    bv=[z.BitVec(f'b{i}',32) for i in range(n)]
    c=z.BitVec('c',32);h=z.BitVec(f'h_{top}',32)
    f=z.BitVec(f'f_{top}',5);v=z.Bool(f'v_{top}')
    script=(ROOT/'build'/f'{top}.smt2').read_text()
    lines=[script];decls={'c':c,'h':h,'f':f,'valid':v}
    decls.update({f'a{i}':x for i,x in enumerate(av)})
    decls.update({f'b{i}':x for i,x in enumerate(bv)})
    ports=[]
    if top.startswith('Ventus'):
        if n==1:ports=[('io_a','a0'),('io_b','b0')]
        else:ports=[(f'io_{p}_{i}',f'{p}{i}') for p in ['a','b'] for i in range(n)]
        ports.append(('io_c','c'))
        result,flags,valid='io_result','io_fflags','io_valid'
    else:
        def pack(p):
            out=f'{p}0'
            for i in range(1,n):out=f'(concat {p}{i} {out})'
            return out
        ports=[('a',pack('a')),('b',pack('b')),('c','c')]
        result,flags,valid='result',('fflags' if n==1 else None),None
    for i in range(cycles+1):
        s=f'{top}_state_{i}'
        lines.append(f'(declare-fun {s} () |{top}_s|)')
        lines.append(f'(assert (|{top}_h| {s}))')
        for port,val in ports:
            lines.append(f'(assert (= (|{top}_n {port}| {s}) {val}))')
        lines.append(f'(assert (= (|{top}_n reset| {s}) {"true" if i==0 else "false"}))')
        if i:lines.append(f'(assert (|{top}_t| {top}_state_{i-1} {s}))')
    lines.append(f'(assert (|{top}_i| {top}_state_0))')
    end=f'{top}_state_{cycles}'
    lines.append(f'(assert (= h (|{top}_n {result}| {end})))')
    lines.append(f'(assert (= f '+(f'(|{top}_n {flags}| {end})' if flags else '#b00000')+'))')
    lines.append(f'(assert (= valid '+(f'(|{top}_n {valid}| {end})' if valid else 'true')+'))')
    constraints=list(z.parse_smt2_string('\n'.join(lines),decls=decls))
    print(top,"PARSED",time.monotonic()-start,flush=True)
    definitions={};outputs={};other=[]
    for raw in constraints:
        for eq in flatten(raw):
            if z.is_true(eq):continue
            if not z.is_eq(eq):other.append(eq);continue
            lhs,rhs=eq.children()
            if lhs.eq(h) or lhs.eq(f) or lhs.eq(v):
                outputs[lhs.get_id()]=rhs;continue
            if rhs.eq(h) or rhs.eq(f) or rhs.eq(v):
                outputs[rhs.get_id()]=lhs;continue
            lread,rread=state_read(lhs),state_read(rhs)
            if lread and rread:
                if step(lhs)>step(rhs):definitions[lhs.get_id()]=rhs
                else:definitions[rhs.get_id()]=lhs
            elif lread:definitions[lhs.get_id()]=rhs
            elif rread:definitions[rhs.get_id()]=lhs
            elif lhs.eq(h) or lhs.eq(f) or lhs.eq(v):outputs[lhs.get_id()]=rhs
            else:other.append(eq)
    print(top,"DEFINITIONS",len(definitions),time.monotonic()-start,flush=True)
    cache={};active=set();chosen={}
    def resolve(root):
        stack=[(root,False)]
        while stack:
            x,post=stack.pop();key=x.get_id()
            if key in cache:continue
            if post==1:
                if key in definitions:out=cache[definitions[key].get_id()]
                elif key in chosen:out=cache[chosen[key].get_id()]
                else:
                    pairs=[(ch,cache[ch.get_id()]) for ch in x.children() if not ch.eq(cache[ch.get_id()])]
                    out=z.simplify(z.substitute(x,*pairs)) if pairs else z.simplify(x)
                cache[key]=out;active.remove(key)
            elif post==2:
                condition=cache[x.arg(0).get_id()]
                if z.is_true(condition) or z.is_false(condition):
                    branch=x.arg(1 if z.is_true(condition) else 2);chosen[key]=branch
                    stack.append((x,1));stack.append((branch,False))
                else:
                    stack.append((x,1))
                    stack.extend((child,False) for child in reversed(x.children()[1:]) if child.get_id() not in cache)
            else:
                if key in active:raise RuntimeError('Cyclic definition')
                active.add(key)
                if key not in definitions and z.is_app_of(x,z.Z3_OP_ITE):
                    stack.append((x,2));stack.append((x.arg(0),False));continue
                stack.append((x,1))
                children=[definitions[key]] if key in definitions else x.children()
                stack.extend((child,False) for child in reversed(children) if child.get_id() not in cache)
        return cache[root.get_id()]
    hf,ff,vf=[resolve(outputs[x.get_id()]) for x in [h,f,v]]
    print(top,"RESOLVED",len(cache),time.monotonic()-start,flush=True)
    remaining=[];seen=set();todo=[hf,ff,vf]
    while todo:
        x=todo.pop()
        if x.get_id() in seen:continue
        seen.add(x.get_id())
        if state_read(x):remaining.append(str(x))
        todo.extend(x.children())
    assert not remaining,remaining[:5]
    assert not other,[str(x)[:100] for x in other[:5]]
    directory=ROOT/'results/models';directory.mkdir(parents=True,exist_ok=True)
    # These are equivalence checks against the original unrolled transition
    # relation. The optimizer later consumes only the proved pure expression.
    # Each read of a register/input at a named time becomes a fresh symbol.
    # This drops UF congruence constraints, so UNSAT of this overapproximation
    # is sufficient for UNSAT of the original transition relation.
    replacements={};todo=list(constraints);visited=set()
    while todo:
        node=todo.pop()
        if node.get_id() in visited:continue
        visited.add(node.get_id())
        if state_read(node):
            replacements[node.get_id()]=(node,z.Const(f'r_{top}_{len(replacements)}',node.sort()))
        else:todo.extend(node.children())
    pairs=list(replacements.values())
    reified=[z.substitute(x,*pairs) for x in constraints]
    feasible_solver=z.SolverFor('QF_BV');feasible_solver.set(timeout=30000);feasible_solver.add(*reified)
    print(top,"REIFIED",len(pairs),time.monotonic()-start,flush=True)
    feasible=feasible_solver.check();assert feasible==z.sat,str(feasible)
    print(top,"FEASIBLE",time.monotonic()-start,flush=True)
    raw_solver=z.Solver();raw_solver.add(*reified)
    (directory/f'{top}-raw.smt2').write_text(raw_solver.to_smt2())
    solver=z.SolverFor('QF_BV');solver.set(timeout=2000)
    solver.add(*reified,z.Or(h!=hf,f!=ff,v!=vf))
    (directory/f'{top}-extraction.smt2').write_text(solver.to_smt2())
    lemma=solver.check()
    valid_solver=z.SolverFor('QF_BV');valid_solver.set(timeout=30000)
    valid_solver.add(*reified,z.Not(v));valid_check=valid_solver.check()
    assert valid_check==z.unsat,(top,str(valid_check))
    reduced=z.Solver();reduced.add(h==hf,f==ff,v==vf)
    (directory/f'{top}-function.smt2').write_text(reduced.to_smt2())
    meta={'top':top,'lanes':n,'clock_edges':cycles,'feasibility':str(feasible),
          'generic_extraction_mismatch':str(lemma),'required_scope':'per-case extraction proof before optimization','invalid_output':str(valid_check),
          'expression_nodes':len(seen),'reified_reads':len(pairs),'seconds':time.monotonic()-start}
    (directory/f'{top}.json').write_text(json.dumps(meta,indent=2))
    faulthandler.cancel_dump_traceback_later()
    print(json.dumps(meta),flush=True)


def load(top):
    solver=z.Solver();solver.from_file(str(ROOT/'results/models'/f'{top}-function.smt2'))
    outputs={}
    for eq in solver.assertions():
        lhs,rhs=eq.children()
        names={f'h_{top}',f'f_{top}',f'v_{top}'}
        if str(lhs) in names:outputs[str(lhs)]=rhs
        elif str(rhs) in names:outputs[str(rhs)]=lhs
        else:raise RuntimeError(str(eq)[:100])
    return outputs[f'h_{top}'],outputs[f'f_{top}'],outputs[f'v_{top}']


if __name__=='__main__':
    import argparse
    p=argparse.ArgumentParser();p.add_argument('top');p.add_argument('--lanes',type=int,default=1)
    p.add_argument('--cycles',type=int,default=16);p.add_argument('--root',type=Path);a=p.parse_args()
    if a.root:ROOT=a.root.resolve()
    build(a.top,a.lanes,a.cycles)
