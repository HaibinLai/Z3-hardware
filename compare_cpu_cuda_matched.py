#!/usr/bin/env python3
"""Compare CPU and V100 within the same PyTorch CUDA wheel."""
import itertools
import json
from pathlib import Path
import torch
import torch.nn.functional as F

torch.set_num_threads(1)
assert torch.cuda.is_available()

def ce_case(device):
    x=torch.tensor([[0.,-18.]],device=device,dtype=torch.float32,requires_grad=True)
    loss=F.cross_entropy(x,torch.tensor([0],device=device))
    loss.backward()
    if device=='cuda':torch.cuda.synchronize()
    return {'loss':loss.item(),'gradient':x.grad.detach().cpu().flatten().tolist()}

values=[-(2**24),-1,0,1,2**24]
counts={'dot':0,'matmul':0}
witnesses={'dot':None,'matmul':None}
for tup in itertools.product(values,repeat=4):
    outputs={}
    for device in ('cpu','cuda'):
        a=torch.tensor(tup,dtype=torch.float32,device=device)
        b=torch.ones(4,dtype=torch.float32,device=device)
        outputs[device]={'dot':torch.dot(a,b).item(),
                         'matmul':torch.matmul(a.reshape(1,4),b.reshape(4,1))[0,0].item()}
    for op in counts:
        if outputs['cpu'][op]!=outputs['cuda'][op]:
            counts[op]+=1
            if witnesses[op] is None:witnesses[op]={'a':list(tup),'cpu':outputs['cpu'][op],'cuda':outputs['cuda'][op]}
report={'torch_version':torch.__version__,'gpu':torch.cuda.get_device_name(0),
        'ce_margin18':{'cpu':ce_case('cpu'),'cuda':ce_case('cuda')},
        'finite_domain_inputs':625,'cpu_cuda_mismatch_counts':counts,'first_witnesses':witnesses,
        'scope':'Same PyTorch build; only stated cases/domain, not all inputs.'}
Path('results/pytorch_cpu_cuda_matched.json').write_text(json.dumps(report,indent=2))
print(json.dumps(report,indent=2))
