#!/usr/bin/env python3
"""Z3 checks for a reduced softmax arithmetic graph and Vortex TFR sticky logic."""
import json
from pathlib import Path
import z3

Path('results').mkdir(exist_ok=True)
records = []
def check(name, assumptions, violation):
    solver = z3.Solver()
    solver.set(timeout=30000)
    solver.add(*assumptions, violation)
    status = solver.check()
    item = {'name': name, 'status': str(status), 'solver_seconds': solver.statistics().get_key_value('time') if 'time' in solver.statistics().keys() else None}
    if status == z3.sat:
        item['model'] = str(solver.model())
    if status == z3.unknown:
        item['reason'] = solver.reason_unknown()
    records.append(item)
    Path('results', name + '.smt2').write_text(solver.to_smt2())
    print(name, item['status'])
    return status

f32 = z3.FPSort(8, 24)
rne = z3.RNE()
one = z3.FPVal(1.0, f32)
zero = z3.FPVal(0.0, f32)
s = z3.FP('s', f32)
lo, hi = z3.FPVal(2**-30, f32), z3.FPVal(2**-24, f32)
domain = [z3.fpGEQ(s, lo), z3.fpLEQ(s, hi)]
denom = z3.fpAdd(rne, one, s)
std = z3.fpSub(rne, z3.fpDiv(rne, one, denom), one)
fixed = z3.fpDiv(rne, z3.fpNeg(s), denom)
check('fp32_denominator_rounds_to_one', domain, z3.Not(z3.fpEQ(denom, one)))
check('fp32_standard_gradient_is_zero', domain, z3.Not(z3.fpEQ(std, zero)))
check('fp32_fixed_gradient_negative', domain, z3.Not(z3.fpLT(fixed, zero)))

# VX_tcu_tfr_align.sv at Vortex 127178d... with WI=25, SHIFT_MAG_W=26,
# SHIFT_W=5 and TCU_EXP_BITS=10. VX_lzc.sv REVERSE=1 returns trailing zeros.
mag = z3.BitVec('mag_shifted', 26)
q = z3.BitVec('shift_amts', 10)
en = z3.Bool('lane_en')
tz = z3.BitVecVal(0, 5)
for i in range(25, -1, -1):
    tz = z3.If(z3.Extract(i, i, mag) == z3.BitVecVal(1, 1), z3.BitVecVal(i, 5), tz)
shift_hi = z3.Extract(9, 5, q) != z3.BitVecVal(0, 5)
shift_lo = z3.Extract(4, 0, q)
rtl_sticky = z3.And(en, mag != z3.BitVecVal(0, 26), z3.Or(shift_hi, z3.UGT(shift_lo, tz)))
reference_sticky = z3.And(en, z3.Or(*[
    z3.And(z3.UGT(q, z3.BitVecVal(i, 10)), z3.Extract(i, i, mag) == z3.BitVecVal(1, 1))
    for i in range(26)
]))
check('vortex_tfr_sticky_matches_discarded_bits', [], rtl_sticky != reference_sticky)

# All positive normal binary32 values from 2^-30 through 2^-24 are K/2^53.
# Their exact real collapse error is K/(2^53+K). The two error bounds
# reduce by positive cross multiplication to 2^23 <= K <= 2^29.
s_bits = z3.BitVec('s_bits', 32)
s_sign = z3.Extract(31,31,s_bits)
s_exp = z3.Extract(30,23,s_bits)
s_frac = z3.Extract(22,0,s_bits)
sig = z3.Concat(z3.BitVecVal(1,1),s_frac)
K = z3.ZeroExt(40,sig) << (z3.ZeroExt(56,s_exp)-z3.BitVecVal(97,64))
bv_domain = [s_sign == 0, z3.UGE(s_exp, z3.BitVecVal(97,8)),
             z3.ULE(s_exp, z3.BitVecVal(103,8)),
             z3.Implies(s_exp == z3.BitVecVal(103,8), s_frac == 0)]
check('fp32_scaled_exact_error_range', bv_domain,
      z3.Or(z3.ULT(K,z3.BitVecVal(2**23,64)), z3.UGT(K,z3.BitVecVal(2**29,64))))
check('fp32_scaled_lower_endpoint_attained', bv_domain, K == z3.BitVecVal(2**23,64))
check('fp32_scaled_upper_endpoint_attained', bv_domain, K == z3.BitVecVal(2**29,64))

report = {
    'z3_version': z3.get_version_string(), 'queries': records,
    'softmax_scope': 's is a positive FP32 value in [2^-30,2^-24]; arithmetic graph only, exp/log not modeled.',
    'softmax_exact_real_signed_error_bound': '2^-30/(1+2^-30) <= standard_target_gradient - (-s/(1+s)) <= 2^-24/(1+2^-24)',
    'vortex_scope': 'Manual translation of one combinational sticky-bit expression; not RTL equivalence or full FPU proof.',
}
Path('results/proofs.json').write_text(json.dumps(report, indent=2))
expected = {'fp32_scaled_lower_endpoint_attained': 'sat', 'fp32_scaled_upper_endpoint_attained': 'sat'}
assert all(x['status'] == expected.get(x['name'], 'unsat') for x in records), report
