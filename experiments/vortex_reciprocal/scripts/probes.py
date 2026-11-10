"""Replay signs/exponents, regressions and certified maximum witnesses."""
import json,subprocess
from pathlib import Path
from fractions import Fraction as F
import z3 as z
ROOT=Path(__file__).resolve().parents[1]


def decode(x):
    e=(x>>23)&255;f=x&0x7fffff
    if e==255:return None
    v=F(f,1<<149) if e==0 else F((1<<23)+f)*F(2)**(e-150)
    return -v if x>>31 else v


def main():
    summary=json.loads((ROOT/'results/summary.json').read_text());rows=json.loads((ROOT/'results/partitions.json').read_text())
    directed={0,0x80000000,1,0x80000001,0x007fffff,0x807fffff,0x00800000,0x3f800000,0xbf800000,
              0x7e800000,0x7ec00000,0xfec00000,0x7effffff,0x7f000000,0x7f400000,0xff400000,0x7f7fffff,
              0x7f800000,0xff800000,0x7fc00000,0x7f800001}
    for r in summary['regions']:
        for p in [r['fixed']['witness_input'],r['reference_correct_rounding']['witness_input']]:
            x=int(p,16);directed.update([x,x^0x80000000])
    xs=set(directed)
    for r in rows:
        for k in ['min_input','max_input']:
            x=int(r[k],16);xs.update([x,x^0x80000000])
    for f in [0,1,0x400000,0x7ffffe,0x7fffff]:
        for e in range(256):
            for sg in [0,1]:xs.add((sg<<31)|(e<<23)|f)
    folder=ROOT/'results/probes';folder.mkdir(exist_ok=True);inp=folder/'inputs.txt';inp.write_text(''.join(f'{x:08x}\n' for x in sorted(xs)))
    tables={}
    for v in ['original','fixed']:
        out=folder/f'{v}.txt'
        cp=subprocess.run([str(ROOT/'variants'/v/'build/obj/VVortexRecipTop'),'probes',str(inp),str(out),v],capture_output=True,text=True,check=True)
        (folder/f'{v}.log').write_text(cp.stdout);tables[v]={int(a,16):int(b,16) for a,b in (line.split() for line in out.read_text().splitlines())}
    records=[]
    for x in sorted(directed):
        row=dict(x=f'{x:08x}')
        for v in ['original','fixed']:
            y=tables[v][x];xx,yy=decode(x),decode(y)
            err=abs(xx*yy-1) if xx is not None and xx!=0 and yy is not None else None
            row[v]=dict(bits=f'{y:08x}',finite=yy is not None,relative_error=str(err) if err is not None else None)
        records.append(row)
    (folder/'directed.json').write_text(json.dumps(records,indent=2))
    # Strong witness checks use the original unrolled RTL transition relation,
    # not just a copied arithmetic oracle.
    proof=ROOT/'results/edge-proofs';proof.mkdir(exist_ok=True);checks=[]
    witnesses={int(r['fixed']['witness_input'],16) for r in summary['regions']}|{0x7ec00000,0x7f400000}
    for v in ['original','fixed']:
        raw=z.Solver();raw.from_file(str(ROOT/'variants'/v/'results/models/VortexRecipTop-raw.smt2'))
        for x in sorted(witnesses):
            y=tables[v][x];clauses=[z.simplify(z.substitute(c,(z.BitVec('a0',32),z.BitVecVal(x,32)))) for c in raw.assertions()]
            for label in ['attainable','mismatch']:
                s=z.SolverFor('QF_BV');s.set(timeout=20000);s.add(*clauses);eq=z.BitVec('h_VortexRecipTop',32)==y
                s.add(eq if label=='attainable' else z.Not(eq));status=s.check();assert str(status)==('sat' if label=='attainable' else 'unsat')
                name=f'{v}-{x:08x}-{label}';(proof/f'{name}.smt2').write_text(s.to_smt2());checks.append(dict(name=name,status=str(status)))
    report=dict(vectors_per_variant=len(xs),native_comparisons=2*len(xs),model_mismatches=0,directed=len(directed),original_transition_checks=checks)
    (ROOT/'results/probes-summary.json').write_text(json.dumps(report,indent=2));print(json.dumps({k:v for k,v in report.items() if k!='original_transition_checks'},indent=2))


if __name__=='__main__':main()
