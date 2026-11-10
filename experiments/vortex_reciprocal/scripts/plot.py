"""English before/after and quantization-floor figures."""
import csv,json
from pathlib import Path
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
ROOT=Path(__file__).resolve().parents[1]
DEN=1<<47


def partition_rows():
    p=ROOT/'results/partitions.json'
    if p.exists():return json.loads(p.read_text())
    with (ROOT/'results/certified-bounds.csv').open() as f:
        return [{k:(int(v) if k in ['exponent','index','min_numerator','max_numerator','max_abs_numerator'] else v) for k,v in r.items()} for r in csv.DictReader(f)]


def save(fig,name):
    folder=ROOT/'figures';folder.mkdir(exist_ok=True)
    for ext in ['png','pdf','svg']:fig.savefig(folder/f'{name}.{ext}',dpi=180,facecolor='white')


def main():
    rows=partition_rows();refs=json.loads((ROOT/'results/reference-partitions.json').read_text());s=json.loads((ROOT/'results/summary.json').read_text())
    plt.rcParams.update({'font.size':11,'axes.spines.top':False,'axes.spines.right':False,'svg.fonttype':'none','pdf.fonttype':42})
    x=1+(np.arange(1024)+.5)/1024;regions=[127,253,254]
    labels=[r'Normal outputs: $x\in[1,2)$',r'Subnormal boundary: $x\in[2^{126},2^{127})$',r'Small reciprocals: $x\in[2^{127},2^{128})$']
    fig,axs=plt.subplots(1,3,figsize=(15.5,5.9),sharey=True);fig.subplots_adjust(left=.065,right=.98,top=.75,bottom=.25,wspace=.15)
    for ax,e,title in zip(axs,regions,labels):
        rr=sorted([r for r in rows if r['exponent']==e],key=lambda r:r['index']);after=np.array([r['max_abs_numerator'] for r in rr])/DEN
        with (ROOT/'variants/original/results'/f'native-e{e}-partitions.tsv').open() as f:old=list(csv.DictReader(f,delimiter='\t'))
        if e!=254:
            before=np.array([max(abs(int(r['min_numerator'])),abs(int(r['max_numerator']))) for r in old])/DEN
            ax.plot(x,before,color='#bc622e',ls='--',lw=1.5,label='Before: exhaustive native RTL')
        else:
            ax.axhspan(1e-3,1.5,color='#bc622e',alpha=.07)
            ax.text(1.5,.025,'Before: 8,388,607 NaNs\n+ one zero output per sign',ha='center',fontsize=10)
        ax.plot(x,after,color='#2468a0',lw=1.5,label='After: Z3-certified bounds')
        ax.axhline(9e-8,color='#777777',ls=':',lw=1)
        ax.set_title(title,fontsize=11,pad=16);ax.set_xlim(1,2.005);ax.set_yscale('log');ax.set_ylim(1e-8,2)
        ax.set_xticks([1,1.5,2]);ax.set_xlabel('Input significand');ax.grid(axis='y',alpha=.15)
        summary=next(r for r in s['regions'] if r['exponent']==e)
        ax.text(.04,.06,'After max: '+f"{summary['fixed']['max_abs_relative_error_float']:.8g}",transform=ax.transAxes,fontsize=10,
                bbox=dict(facecolor='white',edgecolor='none',alpha=.85,pad=2))
    axs[0].set_ylabel('Maximum absolute relative error per table bin (log scale)')
    axs[0].legend(loc='upper left',frameon=False,fontsize=9)
    fig.suptitle('Vortex reciprocal repair: normal accuracy preserved, underflow fixed',fontsize=18,y=.975)
    fig.text(.5,.875,'Each curve covers 1024 bins × 8192 inputs; both signs follow from proved sign symmetry',ha='center',fontsize=11,color='#444444')
    fig.text(.025,.12,'Before: complete native RTL enumeration. After: complete Z3 finite-domain instantiation, attainable extrema and UNSAT bounds.',fontsize=10)
    fig.text(.025,.065,'Dotted line: the previous normal-core 9e-8 target. Normal outputs are bit-identical; subnormal relative precision is inherently coarser.',fontsize=10)
    save(fig,'reciprocal-before-after-en')

    fig,axs=plt.subplots(1,3,figsize=(15,5.6));fig.subplots_adjust(left=.07,right=.98,top=.74,bottom=.25,wspace=.25)
    for ax,e,title in zip(axs,regions,labels):
        rr=sorted([r for r in rows if r['exponent']==e],key=lambda r:r['index']);rf=sorted([r for r in refs if r['exponent']==e],key=lambda r:r['index'])
        after=np.array([r['max_abs_numerator'] for r in rr])/DEN*1e7;ideal=np.array([r['max_abs_numerator'] for r in rf])/DEN*1e7
        ax.plot(x,after,color='#2468a0',lw=1.3,label='Repaired RTL: certified')
        ax.plot(x,ideal,color='#666666',ls='--',lw=1,label='Correctly rounded FP32 reference')
        ax.set_title(title,fontsize=11,pad=16);ax.set_xlabel('Input significand');ax.set_xlim(1,2.005);ax.set_ylim(bottom=0)
        ax.set_xticks([1,1.5,2]);ax.grid(alpha=.15)
    axs[0].set_ylabel(r'Maximum relative error ($\times10^{-7}$)')
    axs[0].legend(loc='upper left',frameon=False,fontsize=8)
    fig.suptitle('Repaired accuracy approaches the FP32 quantization limit',fontsize=18,y=.975)
    fig.text(.5,.87,'Reference values use exact integer division and nearest-even rounding over every input significand',ha='center',fontsize=11,color='#444444')
    fig.text(.025,.12,'Subnormal rounding uses the high-precision NR result directly, with one nearest-even rounding and no intermediate FP32 rounding.',fontsize=10)
    fig.text(.025,.065,'For x = 0x7f7ffffc, Z3 proves that no finite FP32 output can meet 9e-8 relative error. The normal-core target cannot cover all normal inputs.',fontsize=10)
    save(fig,'reciprocal-quantization-floor-en');print('Saved two English comparison figures (PNG/PDF/SVG)')


if __name__=='__main__':main()
