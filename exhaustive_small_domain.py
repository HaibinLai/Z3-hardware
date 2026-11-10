#!/usr/bin/env python3
"""Exhaustively evaluate a finite cancellation-heavy input set for three paths."""
import itertools
import json
from pathlib import Path
import torch

torch.set_num_threads(1)
values = [-(2**24), -1, 0, 1, 2**24]
b = torch.ones(4,dtype=torch.float32)
summary = {k: {'min_error': None, 'max_error': None, 'min_witness': None, 'max_witness': None} for k in ['ventus_tree_model','torch_dot_cpu','torch_matmul_cpu']}
disagree = {'tree_vs_dot':0,'tree_vs_matmul':0,'dot_vs_matmul':0}
for tup in itertools.product(values, repeat=4):
    a=torch.tensor(tup,dtype=torch.float32)
    p=a*b
    tree=((p[0]+p[2])+(p[1]+p[3]))+torch.tensor(0.,dtype=torch.float32)
    outputs={'ventus_tree_model':tree.item(),'torch_dot_cpu':torch.dot(a,b).item(),'torch_matmul_cpu':torch.matmul(a.reshape(1,4),b.reshape(4,1))[0,0].item()}
    exact=sum(tup)
    for key,out in outputs.items():
        err=out-exact
        rec=summary[key]
        if rec['min_error'] is None or err<rec['min_error']:
            rec['min_error'],rec['min_witness']=err,list(tup)
        if rec['max_error'] is None or err>rec['max_error']:
            rec['max_error'],rec['max_witness']=err,list(tup)
    disagree['tree_vs_dot'] += outputs['ventus_tree_model'] != outputs['torch_dot_cpu']
    disagree['tree_vs_matmul'] += outputs['ventus_tree_model'] != outputs['torch_matmul_cpu']
    disagree['dot_vs_matmul'] += outputs['torch_dot_cpu'] != outputs['torch_matmul_cpu']
report={'domain': {'a_i': values, 'b_i': [1,1,1,1], 'c':0, 'number_of_inputs':len(values)**4},
        'scope':'Complete enumeration of this finite domain on PyTorch CPU; Ventus is a source-structure model with assumed IEEE RNE stages, not RTL output.',
        'error_bounds':summary,'disagreement_counts':disagree}
Path('results/exhaustive_small_domain.json').write_text(json.dumps(report,indent=2))
print(json.dumps(report,indent=2))
