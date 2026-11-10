"""Build original and repaired copies of the real reciprocal module."""
import argparse,subprocess,concurrent.futures as cf,hashlib,json,shlex
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]


def build(variant,lab,tools_override=None,preprocessed=False):
    root=ROOT/'variants'/variant;out=root/'build';out.mkdir(parents=True,exist_ok=True)
    (root/'results').mkdir(exist_ok=True);(root/'scripts').mkdir(exist_ok=True)
    src=lab/'src/vortex';tools=tools_override or lab/'tools/oss-cad-suite/bin'
    wrapper=out/'VortexRecipTop.sv'
    wrapper.write_text('''module VortexRecipTop(input wire clk,reset,input wire[31:0] a,b,c,output wire[31:0] result,output wire[4:0] fflags);
 VX_rtu_recip #(.DSP_SEED(1)) dut(.clk(clk),.reset(reset),.enable(1'b1),.mask(1'b1),.x(a),.result(result));
 assign fflags=0;
endmodule
''')
    flags=['-DVX_CFG_XLEN=32','-DVX_CFG_NUM_THREADS=64','-I'+str(lab/'build/vortex/hw'),'-I'+str(src/'hw/rtl'),'-I'+str(src/'hw/rtl/fpu'),'-I'+str(src/'hw/rtl/libs')]
    source=ROOT/'source'/variant/'VX_rtu_recip.sv'
    files=[str(src/'hw/rtl/VX_gpu_pkg.sv'),str(src/'hw/rtl/fpu/VX_fpu_pkg.sv'),str(wrapper),str(source)]
    if preprocessed:
        snapshot=out/'preprocessed.sv';assert snapshot.exists(),snapshot
        flags=[];files=[str(snapshot)]
    ys=root/'scripts/VortexRecipTop.ys'
    ys.write_text('plugin -i slang\nread_slang --top VortexRecipTop '+shlex.join(flags+files)+'\nprep -top VortexRecipTop -flatten\nmemory_map\nopt\nasync2sync\ndffunmap\nopt_clean\nwrite_smt2 -wires '+str(out/'VortexRecipTop.smt2')+'\n')
    with (out/'yosys.log').open('w') as f:p=subprocess.run([str(tools/'yosys'),'-Q','-T','-s',str(ys)],stdout=f,stderr=subprocess.STDOUT)
    assert p.returncode==0,(out/'yosys.log').read_text()[-3000:]
    cmd=[str(tools/'verilator'),'--cc','--exe','--build','-j','8','-O3','-Wno-fatal','--top-module','VortexRecipTop','--Mdir',str(out/'obj'),'-CFLAGS','-O3']+flags+files+[str(ROOT/'scripts/sim.cpp')]
    (out/'verilator.command').write_text(shlex.join(cmd)+'\n')
    with (out/'verilator.log').open('w') as f:p=subprocess.run(cmd,stdout=f,stderr=subprocess.STDOUT)
    assert p.returncode==0,(out/'verilator.log').read_text()[-3000:]
    if not preprocessed:
        with (out/'preprocessed.sv').open('w') as f:subprocess.run([str(tools/'verilator'),'-E','-P']+flags+files,stdout=f,check=True)
    print(variant,'built',flush=True)
    return dict(variant=variant,source_sha256=hashlib.sha256(source.read_bytes()).hexdigest(),
                preprocessed_sha256=hashlib.sha256((out/'preprocessed.sv').read_bytes()).hexdigest(),
                compilation_mode='preprocessed_snapshot' if preprocessed else 'original_sources')


if __name__=='__main__':
    ap=argparse.ArgumentParser();ap.add_argument('--lab',type=Path,default=ROOT.parent);ap.add_argument('--variant',choices=['original','fixed'])
    ap.add_argument('--tools',type=Path);ap.add_argument('--preprocessed',action='store_true');args=ap.parse_args()
    variants=[args.variant] if args.variant else ['original','fixed']
    with cf.ThreadPoolExecutor(max_workers=2) as p:rows=list(p.map(lambda v:build(v,args.lab.resolve(),args.tools.resolve() if args.tools else None,args.preprocessed),variants))
    commit='127178d6375c3cb525e2c8af0c77b5f2d52ed93e'
    if not args.preprocessed:commit=subprocess.check_output(['git','-C',str(args.lab/'src/vortex'),'rev-parse','HEAD'],text=True).strip()
    assert commit=='127178d6375c3cb525e2c8af0c77b5f2d52ed93e'
    prior=ROOT/'results/provenance.json'
    if prior.exists():
        old=json.loads(prior.read_text())['variants'];rows=[r for r in old if r['variant'] not in variants]+rows
    prior.write_text(json.dumps(dict(base_commit=commit,variants=rows,DSP_SEED=1,enabled_edges=5),indent=2))
