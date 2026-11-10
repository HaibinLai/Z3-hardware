"""Exact before/after accuracy, certified maxima and quantization baseline."""
import json,csv,hashlib
from fractions import Fraction as F
from pathlib import Path
import numpy as np
ROOT=Path(__file__).resolve().parents[1]
DEN=1<<47


def reference(e,a):
    power=47 if e==127 else 299-e
    q,r=np.divmod(np.int64(1<<power),a)
    m=q+((2*r>a)|((2*r==a)&((q&1)!=0)))
    bits=(0x3f000000+(m-(1<<23))) if e==127 else m
    return m,bits.astype(np.uint32)


def numerator(e,a,y):
    he=(y>>23)&255;f=(y&0x7fffff).astype(np.int64)
    if e==127:b=np.where(he==127,1<<24,(1<<23)+f);return a*b-DEN
    b=f+np.where(he==0,0,1<<23)
    return ((a*b)<<(e-252))-DEN


def run():
    certs=json.loads((ROOT/'results/partitions.json').read_text());assert len(certs)==3072
    reports=[];reference_rows=[];a=(1<<23)+np.arange(1<<23,dtype=np.int64)
    for e in [127,253,254]:
        rows=sorted([r for r in certs if r['exponent']==e],key=lambda r:r['index']);assert len(rows)==1024
        ys={v:np.fromfile(ROOT/'variants'/v/'results'/f'native-e{e}-outputs.bin',dtype='<u4') for v in ['original','fixed']}
        assert all(y.size==1<<23 for y in ys.values())
        if e==127:assert np.array_equal(ys['original'],ys['fixed'])
        for r in rows:
            i=r['index'];p=ROOT/'results/certificates'/f'e{e}'
            data=(p/f'{i:04d}-outputs.bin').read_bytes();errors=(p/f'{i:04d}-errors.bin').read_bytes()
            assert hashlib.sha256(data).hexdigest()==r['output_sha256'] and hashlib.sha256(errors).hexdigest()==r['error_sha256']
            y=np.frombuffer(data,dtype='<u4');n=np.frombuffer(errors,dtype='<i8')
            assert np.array_equal(y,ys['fixed'][i*8192:(i+1)*8192])
            assert np.array_equal(n,numerator(e,a[i*8192:(i+1)*8192],y))
        rmax=max(rows,key=lambda r:r['max_abs_numerator'])
        low=min(r['min_numerator'] for r in rows);high=max(r['max_numerator'] for r in rows)
        witness=rmax['max_input'] if rmax['max_numerator']>=abs(rmax['min_numerator']) else rmax['min_input']
        ref_m,ref_y=reference(e,a);ref_n=numerator(e,a,ref_y);j=int(np.abs(ref_n).argmax())
        ref_max=np.abs(ref_n).reshape(1024,8192).max(axis=1)
        for i,v in enumerate(ref_max):reference_rows.append(dict(exponent=e,index=i,max_abs_numerator=int(v)))
        variants={}
        for variant,y in ys.items():
            he=(y>>23)&255;finite=he!=255;nan=(he==255)&((y&0x7fffff)!=0);inf=(he==255)&((y&0x7fffff)==0)
            d=dict(finite=int(np.count_nonzero(finite)),nan=int(np.count_nonzero(nan)),infinity=int(np.count_nonzero(inf)),zero=int(np.count_nonzero((y&0x7fffffff)==0)))
            if finite.all():
                n=numerator(e,a,y);k=int(np.abs(n).argmax());nn=int(abs(n[k]));distance=y.astype(np.int64)-ref_y.astype(np.int64)
                ds,cs=np.unique(distance,return_counts=True)
                histogram={str(int(v)):int(c) for v,c in zip(ds,cs)} if len(ds)<=16 else None
                d.update(max_abs_relative_error=str(F(nn,DEN)),max_abs_relative_error_float=float(F(nn,DEN)),
                         witness_input=f'{(e<<23)|k:08x}',witness_output=f'{int(y[k]):08x}',
                         correctly_rounded_mismatches=int(np.count_nonzero(distance)),max_fp32_ordered_distance=int(np.abs(distance).max()),
                         signed_ulp_distance_counts=histogram,distinct_ulp_distances=int(len(ds)),
                         signed_ulp_distance_range=[int(ds[0]),int(ds[-1])])
            else:d.update(max_abs_relative_error=None,max_abs_relative_error_float=None,note='Nonfinite outputs: no real-valued relative-error bound over the whole region')
            variants[variant]=d
        assert variants['fixed']['nan']==variants['fixed']['infinity']==variants['fixed']['zero']==0
        assert variants['fixed']['max_abs_relative_error']==str(F(rmax['max_abs_numerator'],DEN))
        reports.append(dict(exponent=e,original=variants['original'],fixed=variants['fixed'],
            certified_signed_bounds=[str(F(low,DEN)),str(F(high,DEN))],certified_max_abs=str(F(rmax['max_abs_numerator'],DEN)),
            certified_witness=witness,reference_correct_rounding=dict(max_abs_relative_error=str(F(int(abs(ref_n[j])),DEN)),
                max_abs_relative_error_float=float(F(int(abs(ref_n[j])),DEN)),witness_input=f'{(e<<23)|j:08x}',
                witness_output=f'{int(ref_y[j]):08x}',method='Exact integer quotient/remainder, nearest-even; full 2^23-input table')))
    worst=max(reports,key=lambda r:r['fixed']['max_abs_relative_error_float'])
    result=dict(normal_inputs_domain='1 <= biased exponent <= 254, both signs; documented zero/subnormal-input policy retained',
        cases_per_region=1<<23,certified_partitions=3072,certified_positive_inputs=3*(1<<23),
        native_vectors=6*(1<<23),native_z3_fixed_comparisons=3*(1<<23),native_z3_mismatches=0,
        regions=reports,global_normal_input_max_abs_relative_error=worst['certified_max_abs'],
        global_normal_input_max_abs_relative_error_float=worst['fixed']['max_abs_relative_error_float'],
        global_witness=worst['certified_witness'],normal_path_bit_identical=True,
        finite_normal_inputs_have_finite_nonzero_outputs=True,input_subnormal_policy_unchanged=True)
    (ROOT/'results/reference-partitions.json').write_text(json.dumps(reference_rows,indent=2))
    (ROOT/'results/summary.json').write_text(json.dumps(result,indent=2));print(json.dumps(result,indent=2))


if __name__=='__main__':run()
