import argparse,concurrent.futures as cf,json,subprocess,sys,time,hashlib
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]


def main():
    p=argparse.ArgumentParser();p.add_argument('--workers',type=int,default=96);a=p.parse_args();start=time.monotonic()
    jobs=[(e,i) for e in [127,253,254] for i in range(1024)]
    expected_hash=hashlib.sha256((ROOT/'variants/fixed/results/models/VortexRecipTop-function.smt2').read_bytes()).hexdigest()
    def run(job):
        e,i=job;path=ROOT/'results/certificates'/f'e{e}'/f'{i:04d}.json'
        if path.exists():
            old=json.loads(path.read_text())
            if old.get('certified') and old.get('function_sha256')==expected_hash:return job,0
        with (ROOT/'results'/f'cert-e{e}-{i:04d}.log').open('w') as f:
            proc=subprocess.run([sys.executable,str(ROOT/'scripts/bounds.py'),'--exponent',str(e),'--index',str(i)],stdout=f,stderr=subprocess.STDOUT)
        return job,proc.returncode
    failures=[];n=0
    with cf.ThreadPoolExecutor(max_workers=a.workers) as p:
        for task in cf.as_completed([p.submit(run,j) for j in jobs]):
            job,status=task.result();n+=1
            if status:failures.append(job)
            if n%96==0 or status:print(n,'/3072',job,status,'seconds',round(time.monotonic()-start,1),flush=True)
    assert not failures,failures
    allrows=[json.loads((ROOT/'results/certificates'/f'e{e}'/f'{i:04d}.json').read_text()) for e,i in jobs]
    assert all(r['certified'] for r in allrows)
    (ROOT/'results/partitions.json').write_text(json.dumps(allrows,indent=2));print('COMPLETE',len(allrows),sum(r['enumerated'] for r in allrows),round(time.monotonic()-start,1),'seconds',flush=True)


if __name__=='__main__':main()
