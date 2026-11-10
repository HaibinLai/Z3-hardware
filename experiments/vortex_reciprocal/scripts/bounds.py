"""Complete Z3 finite-domain certificates for three repaired output regions."""
import argparse,csv,gzip,hashlib,json,struct,time
from functools import lru_cache
from pathlib import Path
from fractions import Fraction as F
import z3 as z
import rtl_model
ROOT=Path(__file__).resolve().parents[1]
NW=52
DEN=1<<47


@lru_cache(None)
def function(variant):
    rtl_model.ROOT=ROOT/'variants'/variant
    return rtl_model.load('VortexRecipTop')[0]


def output(variant,x):
    return z.simplify(z.substitute(function(variant),(z.BitVec('a0',32),x)))


def domain(e,index):
    lo=z.BitVec('low_fraction',13);frac=z.Concat(z.BitVecVal(index,10),lo)
    x=z.Concat(z.BitVecVal(e,9),frac);h=output('fixed',x);he=z.Extract(30,23,h);hf=z.Extract(22,0,h)
    a=z.Concat(z.BitVecVal(1,1),frac)
    if e==127:b=z.If(he==127,z.BitVecVal(1<<24,25),z.ZeroExt(2,hf)+(1<<23));shift=0
    else:b=z.If(he==0,z.ZeroExt(2,hf),z.ZeroExt(2,hf)+(1<<23));shift=e-252
    num=(z.ZeroExt(NW-24,a)*z.ZeroExt(NW-25,b)<<shift)-(1<<47)
    return lo,h,z.simplify(num)


@lru_cache(None)
def native(e):
    with (ROOT/'variants/fixed/results'/f'native-e{e}-partitions.tsv').open() as f:return list(csv.DictReader(f,delimiter='\t'))


def run(e,index):
    start=time.monotonic();lo,h,num=domain(e,index);folder=ROOT/'results/certificates'/f'e{e}';folder.mkdir(parents=True,exist_ok=True)
    nums=[];ys=bytearray();ns=bytearray();low=high=None;wl=wh=0
    for v in range(8192):
        pair=(lo,z.BitVecVal(v,13));hv=z.simplify(z.substitute(h,pair));nv=z.simplify(z.substitute(num,pair))
        assert z.is_bv_value(hv) and z.is_bv_value(nv)
        y=hv.as_long();n=nv.as_signed_long();he=(y>>23)&255;hf=y&0x7fffff
        assert y>>31==0 and (y&0x7fffffff)!=0
        if e==127:assert he in [126,127] and (he!=127 or hf==0)
        if e==253:assert he in [0,1] and (he!=1 or hf==0)
        if e==254:assert he==0
        ys+=struct.pack('<I',y);ns+=struct.pack('<q',n);nums.append(n)
        if low is None or n<low:low=n;wl=v
        if high is None or n>high:high=n;wh=v
    row=native(e)[index]
    assert int(row['finite'])==8192 and int(row['nan'])==int(row['inf'])==int(row['zero'])==0
    assert low==int(row['min_numerator']) and high==int(row['max_numerator'])
    maximum=max(abs(low),abs(high))
    outside=z.SolverFor('QF_BV')
    outside.add(z.Or(*[z.And(lo==v,z.UGT(z.BitVecVal(abs(n),NW),maximum)) for v,n in enumerate(nums)]))
    assert outside.check()==z.unsat
    with gzip.open(folder/f'{index:04d}-outside-expanded.smt2.gz','wt') as f:f.write(outside.to_smt2())
    for label,v,target in [('min',wl,low),('max',wh,high)]:
        s=z.SolverFor('QF_BV');s.add(lo==v,num==target);assert s.check()==z.sat
        with gzip.open(folder/f'{index:04d}-{label}-attainable.smt2.gz','wt') as f:f.write(s.to_smt2())
    if index==0:
        s=z.SolverFor('QF_BV');s.add(z.Not(z.Or(*[lo==v for v in range(8192)])));assert s.check()==z.unsat
        with gzip.open(folder/'bv13-coverage.smt2.gz','wt') as f:f.write(s.to_smt2())
    (folder/f'{index:04d}-outputs.bin').write_bytes(ys);(folder/f'{index:04d}-errors.bin').write_bytes(ns)
    report=dict(exponent=e,index=index,enumerated=8192,method='Complete finite-domain instantiation of the original RTL-derived BV expression',
                min_numerator=low,max_numerator=high,max_abs_numerator=maximum,denominator=DEN,
                max_abs_relative_error=str(F(maximum,DEN)),
                min_input=f'{(e<<23)|(index<<13)|wl:08x}',max_input=f'{(e<<23)|(index<<13)|wh:08x}',
                outside='unsat',endpoints='sat',coverage='BV13 exhaustive; high 10 bits partitioned over 1024 bins',certified=True,
                output_sha256=hashlib.sha256(ys).hexdigest(),error_sha256=hashlib.sha256(ns).hexdigest(),
                function_sha256=hashlib.sha256((ROOT/'variants/fixed/results/models/VortexRecipTop-function.smt2').read_bytes()).hexdigest(),seconds=time.monotonic()-start)
    (folder/f'{index:04d}.json').write_text(json.dumps(report,indent=2));print(json.dumps(report),flush=True)


if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--exponent',type=int,choices=[127,253,254],required=True);p.add_argument('--index',type=int,required=True);a=p.parse_args();run(a.exponent,a.index)
