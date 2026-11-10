"""Prove the five-edge pipeline for arbitrary changing 32-bit inputs.

Enable and mask are tied high in the checked configuration. This is not a
stall/reset protocol proof. Initial data registers may be unconstrained.
"""
import json,time,argparse
import rtl_model
from pathlib import Path
import z3 as z
from rtl_model import load,state_read
ROOT=Path(__file__).resolve().parents[1]


def main():
    global ROOT
    ap=argparse.ArgumentParser();ap.add_argument('--root',type=Path,required=True);args=ap.parse_args()
    ROOT=args.root.resolve();rtl_model.ROOT=ROOT
    start=time.monotonic();top='VortexRecipTop';script=(ROOT/'build'/f'{top}.smt2').read_text()
    xs=[z.BitVec(f'transaction_x_{i}',32) for i in range(6)];h=z.BitVec('pipeline_h',32)
    lines=[script]
    for i in range(6):
        st=f'pipeline_state_{i}';lines += [f'(declare-fun {st} () |{top}_s|)',f'(assert (|{top}_h| {st}))',
            f'(assert (= (|{top}_n a| {st}) transaction_x_{i}))',
            f'(assert (= (|{top}_n b| {st}) #x00000000))',f'(assert (= (|{top}_n c| {st}) #x00000000))',
            f'(assert (= (|{top}_n reset| {st}) '+('true' if i==0 else 'false')+'))']
        if i:lines.append(f'(assert (|{top}_t| pipeline_state_{i-1} {st}))')
    lines += [f'(assert (|{top}_i| pipeline_state_0))',f'(assert (= pipeline_h (|{top}_n result| pipeline_state_5)))']
    decls={str(x):x for x in xs};decls['pipeline_h']=h
    clauses=list(z.parse_smt2_string('\n'.join(lines),decls=decls))
    # Reify state reads to remove UF congruence constraints. This is a
    # relaxation; UNSAT of a mismatch still proves the original relation.
    todo=list(clauses);seen=set();pairs=[]
    while todo:
        x=todo.pop()
        if x.get_id() in seen:continue
        seen.add(x.get_id())
        if state_read(x):pairs.append((x,z.Const(f'pipeline_read_{len(pairs)}',x.sort())))
        else:todo.extend(x.children())
    constraints=[z.substitute(x,*pairs) for x in clauses]
    expected,_,_=load(top);expected=z.substitute(expected,(z.BitVec('a0',32),xs[0]))
    folder=ROOT/'results/pipeline';folder.mkdir(exist_ok=True)
    s=z.SolverFor('QF_BV');s.set(timeout=60000);s.add(*constraints);feasible=s.check();assert feasible==z.sat
    s.add(h!=expected)
    (folder/'arbitrary-changing-inputs.smt2').write_text(s.to_smt2())
    # Eliminate forward register/net equalities before bit-blasting. The
    # unreduced check may spend its budget on unused initial-cycle cones.
    goal=z.Goal();goal.add(*s.assertions())
    reduced=z.Then('simplify','solve-eqs','simplify','propagate-values','simplify')(goal)
    ss=z.SolverFor('QF_BV');ss.set(timeout=60000);ss.add(reduced.as_expr());mismatch=ss.check()
    (folder/'arbitrary-changing-inputs-reduced.smt2').write_text(ss.to_smt2())
    report=dict(enabled_edges=5,feasible=str(feasible),output_mismatch=str(mismatch),
                input_scope='All 32-bit patterns at all six input times, independently symbolic',
                configuration='enable=1 and mask=1',seconds=time.monotonic()-start)
    report['method']='Z3 word-level equality elimination, then QF_BV mismatch check'
    (ROOT/'results/pipeline-summary.json').write_text(json.dumps(report,indent=2));print(json.dumps(report,indent=2))


if __name__=='__main__':main()
