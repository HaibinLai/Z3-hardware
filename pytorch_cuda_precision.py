#!/usr/bin/env python3
"""PyTorch CUDA checks on one visible V100, with explicit device synchronization."""
import itertools
import json
from decimal import Decimal, localcontext
from pathlib import Path
import torch
import torch.nn.functional as F

assert torch.cuda.is_available(), 'CUDA PyTorch is unavailable'
torch.cuda.set_device(0)
torch.set_num_threads(1)
rows=[]
for dtype in (torch.float32, torch.float64):
    for margin in (16,17,18,20,40):
        with localcontext() as ctx:
            ctx.prec=90
            s=(-Decimal(margin)).exp()
            ref=-s/(1+s)
        x=torch.tensor([[0.,-float(margin)]],dtype=dtype,device='cuda',requires_grad=True)
        loss=F.cross_entropy(x,torch.tensor([0],device='cuda'))
        loss.backward()
        torch.cuda.synchronize()
        std_g=x.grad.detach().cpu().flatten().tolist()
        std_loss=loss.item()
        x=torch.tensor([[0.,-float(margin)]],dtype=dtype,device='cuda',requires_grad=True)
        fixed=torch.log1p(torch.exp(x[0,1]-x[0,0]))
        fixed.backward()
        torch.cuda.synchronize()
        fix_g=x.grad.detach().cpu().flatten().tolist()
        rows.append({'dtype':str(dtype),'margin':margin,'reference_target_gradient_90digit':str(ref),
                     'standard_loss':std_loss,'standard_gradient':std_g,
                     'fixed_loss':fixed.item(),'fixed_gradient':fix_g})

values=[-(2**24),-1,0,1,2**24]
b=torch.ones(4,dtype=torch.float32,device='cuda')
bounds={k:{'min_error':None,'max_error':None,'min_witness':None,'max_witness':None}
        for k in ['torch_dot_cuda','torch_matmul_cuda']}
disagree=0
for tup in itertools.product(values,repeat=4):
    a=torch.tensor(tup,dtype=torch.float32,device='cuda')
    dot=torch.dot(a,b).item()
    mm=torch.matmul(a.reshape(1,4),b.reshape(4,1))[0,0].item()
    exact=sum(tup)
    disagree += dot!=mm
    for key,out in [('torch_dot_cuda',dot),('torch_matmul_cuda',mm)]:
        err=out-exact
        rec=bounds[key]
        if rec['min_error'] is None or err<rec['min_error']:
            rec['min_error'],rec['min_witness']=err,list(tup)
        if rec['max_error'] is None or err>rec['max_error']:
            rec['max_error'],rec['max_witness']=err,list(tup)

example=torch.tensor([2**24,1,1,-(2**24)],dtype=torch.float32,device='cuda')
report={'torch_version':torch.__version__,'cuda_version':torch.version.cuda,
        'gpu':torch.cuda.get_device_name(0),'capability':torch.cuda.get_device_capability(0),
        'arch_list':torch.cuda.get_arch_list(),'rows':rows,
        'example':{'a':[2**24,1,1,-(2**24)],'b':[1,1,1,1],
                   'exact':2,'torch_dot_cuda':torch.dot(example,b).item(),
                   'torch_matmul_cuda':torch.matmul(example.reshape(1,4),b.reshape(4,1))[0,0].item()},
        'finite_domain':{'a_i':values,'b_i':[1,1,1,1],'inputs':625,
                         'error_bounds':bounds,'dot_matmul_disagreements':disagree},
        'scope':'Measurements on one NVIDIA V100 with a pinned PyTorch CUDA build; no claim about Vortex or Ventus RTL.'}
Path('results/pytorch_cuda_precision.json').write_text(json.dumps(report,indent=2))
print('torch',report['torch_version'],'GPU',report['gpu'],'arch',report['capability'])
for row in rows:
    print(row['dtype'],'m',row['margin'],'std',row['standard_gradient'],'fixed',row['fixed_gradient'])
print('example',report['example'])
print('finite_domain',report['finite_domain'])
