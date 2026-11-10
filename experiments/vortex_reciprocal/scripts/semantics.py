"""Global bit-level contracts and real RTL packing-cutpoint RNE proof."""
import json,time
from pathlib import Path
import z3 as z
from bounds import output
ROOT=Path(__file__).resolve().parents[1]


def prove(name,conditions,bad):
    start=time.monotonic();s=z.SolverFor('QF_BV');s.set(timeout=60000);s.add(*conditions,bad);status=s.check()
    folder=ROOT/'results/semantic';folder.mkdir(exist_ok=True)
    (folder/f'{name}.smt2').write_text(s.to_smt2())
    row=dict(name=name,status=str(status),seconds=time.monotonic()-start)
    if status==z.unknown:row['reason']=s.reason_unknown()
    if status==z.sat:row['model']=str(s.model())
    (folder/f'{name}.json').write_text(json.dumps(row,indent=2));print(row,flush=True)
    return row


def packing():
    top='VortexRecipTop';source=(ROOT/'variants/fixed/build'/f'{top}.smt2').read_text()
    fields={'raw':('s5_y2',z.BitVec('raw',32)),'e':('s5_exp',z.BitVec('e',8)),
            'sg':('s5_sign',z.Bool('sg')),'inf':('s5_inf',z.Bool('inf')),
            'zero':('s5_zero',z.Bool('zero')),'nan':('s5_nan',z.Bool('nan'))}
    h=z.BitVec('packed_h',32);decls={n:v for n,(_,v) in fields.items()};decls['packed_h']=h
    lines=[source,f'(declare-const pack_state |{top}_s|)']
    for n,(wire,_) in fields.items():lines.append(f'(assert (= {n} (|{top}_n dut.g_dsp_seed.{wire}| pack_state)))')
    lines.append(f'(assert (= packed_h (|{top}_n result| pack_state)))')
    clauses=list(z.parse_smt2_string('\n'.join(lines),decls=decls))
    # Retain full cutpoint bindings even if Yosys split a vector state read.
    todo=list(clauses);seen=set();pairs=[]
    while todo:
        x=todo.pop()
        if x.get_id() in seen:continue
        seen.add(x.get_id())
        if z.is_app(x) and x.num_args()==1 and x.decl().kind()==z.Z3_OP_UNINTERPRETED:
            pairs.append((x,z.Const(f'pack_read_{len(pairs)}',x.sort())))
        else:todo.extend(x.children())
    bindings=[z.substitute(x,*pairs) for x in clauses]
    raw=fields['raw'][1];e=fields['e'][1];sg=fields['sg'][1]
    finite_flags=[z.Not(fields[k][1]) for k in ['inf','zero','nan']]
    rows=[]
    for ee,shift in [(253,8),(254,9)]:
        mant=z.ZeroExt(33,z.Extract(30,0,h));r=z.ZeroExt(32,raw)
        scaled=mant<<shift;distance=z.If(z.UGE(scaled,r),scaled-r,r-scaled)
        bad=z.Or(z.UGT(distance,1<<(shift-1)),z.And(distance==(1<<(shift-1)),(mant&1)!=0),
                 (z.Extract(31,31,h)==1)!=sg,z.Extract(30,23,h)==255)
        rows.append(prove(f'subnormal-rne-e{ee}',bindings+finite_flags+[e==ee],bad))
    return rows


def main():
    x=z.BitVec('x',32);exp=z.Extract(30,23,x);frac=z.Extract(22,0,x);sign=z.Extract(31,31,x)
    old=output('original',x);new=output('fixed',x)
    rows=[]
    rows.append(prove('normal-path-bit-preservation',[z.UGE(exp,1),z.ULE(exp,252)],old!=new))
    rows.append(prove('special-input-policy-preserved',[z.Or(exp==0,exp==255)],old!=new))
    hn=output('fixed',z.Concat(z.BitVecVal(127,9),frac));ne=z.Extract(30,23,hn);nf=z.Extract(22,0,hn)
    carry=ne==127;oe=z.BitVecVal(253,8)-exp+z.If(carry,z.BitVecVal(1,8),z.BitVecVal(0,8))
    rows.append(prove('normal-exponent-propagation',[z.UGE(exp,1),z.ULE(exp,252)],new!=z.Concat(sign,oe,nf)))
    pos=output('fixed',x&0x7fffffff)
    rows.append(prove('all-normal-input-sign-symmetry',[z.UGE(exp,1),z.ULE(exp,254)],new!=(pos|(x&0x80000000))))
    expected=z.If(exp==0,z.BitVecVal(0x7f7fffff,32),z.If(frac==0,z.Concat(sign,z.BitVecVal(0,31)),z.BitVecVal(0x7fc00000,32)))
    rows.append(prove('special-value-policy',[z.Or(exp==0,exp==255)],new!=expected))
    rows+=packing()
    # Complete field decomposition is the coverage argument for all three
    # certified positive-input regions and their sign mirrors.
    rows.append(prove('all-normal-exponent-coverage',[exp!=0,exp!=255],
                      z.Not(z.Or(z.And(z.UGE(exp,1),z.ULE(exp,252)),exp==253,exp==254))))
    (ROOT/'results/semantic-summary.json').write_text(json.dumps(rows,indent=2))


if __name__=='__main__':main()
