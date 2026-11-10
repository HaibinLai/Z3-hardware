#!/usr/bin/env python3
"""Reproduce binary cross-entropy gradient collapse on a pinned PyTorch CPU build."""
import json
from decimal import Decimal, localcontext
from pathlib import Path
import torch
import torch.nn.functional as F

torch.set_num_threads(1)
rows = []
for dtype in (torch.float32, torch.float64):
    for margin in (16, 17, 18, 20, 40):
        with localcontext() as ctx:
            ctx.prec = 90
            s = (-Decimal(margin)).exp()
            exact_target = -s / (1 + s)
            exact_loss = (1 + s).ln()
        x = torch.tensor([[0.0, -float(margin)]], dtype=dtype, requires_grad=True)
        standard = F.cross_entropy(x, torch.tensor([0]))
        standard.backward()
        std_grad = x.grad.detach().flatten().tolist()
        std_loss = standard.item()
        x = torch.tensor([[0.0, -float(margin)]], dtype=dtype, requires_grad=True)
        fixed = torch.log1p(torch.exp(x[0, 1] - x[0, 0]))
        fixed.backward()
        fix_grad = x.grad.detach().flatten().tolist()
        rows.append({
            'dtype': str(dtype), 'margin': margin,
            'reference_target_gradient_90digit': str(exact_target),
            'reference_loss_90digit': str(exact_loss),
            'standard_loss': std_loss, 'standard_gradient': std_grad,
            'fixed_loss': fixed.item(), 'fixed_gradient': fix_grad,
            'standard_target_signed_error': float(Decimal(str(std_grad[0])) - exact_target),
            'fixed_target_signed_error': float(Decimal(str(fix_grad[0])) - exact_target),
        })
a = torch.tensor(2**24, dtype=torch.float32)
b = torch.tensor(1.0, dtype=torch.float32)
report = {
    'torch_version': torch.__version__, 'backend': 'CPU',
    'rounding_example': {'a': a.item(), 'b': b.item(), 'exact_sum': 2**24 + 1, 'torch_sum': (a+b).item()},
    'rows': rows,
    'reference_note': 'Decimal exp/ln at precision 90 is a high precision approximation, not a certified transcendental bound.',
}
Path('results').mkdir(exist_ok=True)
Path('results/pytorch_precision.json').write_text(json.dumps(report, indent=2))
for row in rows:
    print(row['dtype'], 'm=', row['margin'], 'std=', row['standard_gradient'], 'fixed=', row['fixed_gradient'])
print('wrote results/pytorch_precision.json')
