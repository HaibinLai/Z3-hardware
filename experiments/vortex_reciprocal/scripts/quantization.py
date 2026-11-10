"""Prove that a 9e-8 bound cannot cover all normal FP32 inputs."""
import json
from pathlib import Path
from fractions import Fraction as F
import z3 as z
ROOT=Path(__file__).resolve().parents[1]


def rat(f):
    f=F(f);return z.RealVal(f'{f.numerator}/{f.denominator}')


def run():
    s=json.loads((ROOT/'results/summary.json').read_text())
    r=next(x for x in s['regions'] if x['exponent']==254)['reference_correct_rounding']
    bits=int(r['witness_input'],16);a=(1<<23)+(bits&0x7fffff);x=F(a)*(1<<104);eps=F(9,100000000)
    m=z.Int('subnormal_significand');y=z.Real('output_value')
    n=a*m-(1<<45)
    jobs=[('subnormal-output',[m>=0,m<(1<<23),z.If(n<0,-n,n)*100000000<=9*(1<<45)]),
          ('positive-normal-output',[y>=rat(F(2)**-126),z.If(rat(x)*y-1<0,1-rat(x)*y,rat(x)*y-1)<=rat(eps)]),
          ('nonpositive-output',[y<=0,z.If(rat(x)*y-1<0,1-rat(x)*y,rat(x)*y-1)<=rat(eps)])]
    folder=ROOT/'results/quantization';folder.mkdir(exist_ok=True);rows=[]
    for name,constraints in jobs:
        solver=z.Solver();solver.add(*constraints);status=solver.check();assert status==z.unsat
        (folder/f'{name}.smt2').write_text(solver.to_smt2());rows.append(dict(name=name,status=str(status)))
    report=dict(witness_input=f'{bits:08x}',input_exact=str(x),threshold='9/100000000',
                conclusion='No finite FP32 output can meet 9e-8 relative error for this normal input',
                correctly_rounded_error=r['max_abs_relative_error'],cases=rows)
    (ROOT/'results/quantization-summary.json').write_text(json.dumps(report,indent=2));print(json.dumps(report,indent=2))


if __name__=='__main__':run()
