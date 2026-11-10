import argparse,concurrent.futures as cf,subprocess,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]


def main():
    ap=argparse.ArgumentParser();ap.add_argument('--preprocessed',action='store_true');ap.add_argument('--tools',type=Path)
    ap.add_argument('--lab',type=Path);ap.add_argument('--workers',type=int,default=32);a=ap.parse_args()
    command=[sys.executable,str(ROOT/'scripts/build.py')]
    if a.preprocessed:command.append('--preprocessed')
    if a.tools:command+=['--tools',str(a.tools.resolve())]
    if a.lab:command+=['--lab',str(a.lab.resolve())]
    subprocess.run(command,check=True)
    jobs=[]
    for v in ['original','fixed']:
        root=ROOT/'variants'/v
        jobs.append((f'{v}-model',[sys.executable,str(ROOT/'scripts/rtl_model.py'),'VortexRecipTop','--cycles','5','--root',str(root)]))
        for e in [127,253,254]:jobs.append((f'{v}-native-e{e}',[str(root/'build/obj/VVortexRecipTop'),'exhaust',str(root/'results'/f'native-e{e}'),str(e),v]))
    def run(job):
        name,cmd=job
        with (ROOT/'results'/f'{name}.log').open('w') as f:p=subprocess.run(cmd,stdout=f,stderr=subprocess.STDOUT)
        return name,p.returncode
    with cf.ThreadPoolExecutor(max_workers=8) as p:results=list(p.map(run,jobs))
    print('models and native tables',results,flush=True);assert all(code==0 for _,code in results)
    subprocess.run([sys.executable,str(ROOT/'scripts/run_bounds.py'),'--workers',str(a.workers)],check=True)


if __name__=='__main__':main()
