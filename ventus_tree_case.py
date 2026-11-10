#!/usr/bin/env python3
"""Model the explicit TCDotProduct(4) tree in Ventus' pinned FPUv2 source."""
import json
from pathlib import Path
import torch
import z3

torch.set_num_threads(1)
a_values = [2**24, 1, 1, -(2**24)]
b_values = [1, 1, 1, 1]
a = torch.tensor(a_values, dtype=torch.float32)
b = torch.tensor(b_values, dtype=torch.float32)
products = a * b
pair_02 = products[0] + products[2]
pair_13 = products[1] + products[3]
model_output = (pair_02 + pair_13) + torch.tensor(0.0, dtype=torch.float32)
exact = sum(x*y for x,y in zip(a_values,b_values))
matmul = torch.matmul(a.reshape(1,4),b.reshape(4,1))[0,0]

f32 = z3.FPSort(8,24)
rne = z3.RNE()
fp = lambda x: z3.FPVal(float(x),f32)
ps = [z3.fpMul(rne,fp(x),fp(y)) for x,y in zip(a_values,b_values)]
answer = z3.fpAdd(rne, z3.fpAdd(rne, z3.fpAdd(rne,ps[0],ps[2]), z3.fpAdd(rne,ps[1],ps[3])), fp(0))
solver = z3.Solver()
solver.add(z3.Not(z3.fpEQ(answer, fp(1))))
status = solver.check()
assert status == z3.unsat
Path('results/ventus_tree_case.smt2').write_text(solver.to_smt2())
report = {
    'source': 'Ventus dependencies/fpuv2 at 7ea30df00f9353f2e8645b32665b13f9b3f69e6d, Tensor.scala TCDotProduct and TCMulPipe/TCAddPipe',
    'assumption': 'Each multiply and add stage implements IEEE FP32 round-to-nearest-even. This is a source-level numerical model, not generated RTL or silicon proof.',
    'a': a_values, 'b': b_values, 'c': 0,
    'products': products.tolist(), 'pair_02': pair_02.item(), 'pair_13': pair_13.item(),
    'model_output': model_output.item(), 'torch_dot_cpu': torch.dot(a,b).item(),
    'torch_matmul_cpu': matmul.item(), 'exact_integer_result': exact,
    'signed_model_error': model_output.item()-exact,
    'z3_status_for_model_output_not_1': str(status),
}
Path('results/ventus_tree_case.json').write_text(json.dumps(report,indent=2))
print(json.dumps(report,indent=2))
