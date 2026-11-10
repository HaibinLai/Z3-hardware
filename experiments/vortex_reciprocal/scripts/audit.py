"""Cross-version replay of the complete repair certificate set."""
import argparse,concurrent.futures as cf,gzip,json,subprocess,time
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]


def run():
    ap=argparse.ArgumentParser();ap.add_argument('--z3',type=Path,required=True);ap.add_argument('--workers',type=int,default=24);a=ap.parse_args()
    start=time.monotonic();jobs=[]
    for e in [127,253,254]:
        folder=ROOT/'results/certificates'/f'e{e}'
        assert len(list(folder.glob('[0-9][0-9][0-9][0-9].json')))==1024,'Generate full certificates with run_bounds.py first'
        for p in sorted(folder.glob('*.smt2.gz')):jobs.append((p,'sat' if 'attainable' in p.name else 'unsat'))
    for p in sorted((ROOT/'results/semantic').glob('*.smt2')):jobs.append((p,'unsat'))
    for p in sorted((ROOT/'results/quantization').glob('*.smt2')):jobs.append((p,'unsat'))
    for v in ['original','fixed']:
        meta=json.loads((ROOT/'variants'/v/'results/models/VortexRecipTop.json').read_text())
        assert meta['generic_extraction_mismatch']=='unsat'
        jobs.append((ROOT/'variants'/v/'results/models/VortexRecipTop-extraction.smt2','unsat'))
    jobs.append((ROOT/'variants/fixed/results/pipeline/arbitrary-changing-inputs-reduced.smt2','unsat'))
    for p in sorted((ROOT/'results/edge-proofs').glob('*.smt2')):jobs.append((p,'sat' if 'attainable' in p.name else 'unsat'))
    def check(job):
        p,expect=job;script=gzip.open(p,'rt').read() if p.suffix=='.gz' else p.read_text()
        proc=subprocess.run([str(a.z3),'-in','-T:20'],input=script,text=True,capture_output=True,timeout=25)
        assert proc.returncode==0 and proc.stdout.strip()==expect,(str(p),proc.returncode,proc.stdout,proc.stderr)
        return dict(path=str(p.relative_to(ROOT)),expected=expect,status=proc.stdout.strip())
    with cf.ThreadPoolExecutor(max_workers=a.workers) as p:rows=list(p.map(check,jobs))
    report=dict(version=subprocess.check_output([str(a.z3),'-version'],text=True).strip(),queries=len(rows),passed=len(rows),failures=0,seconds=time.monotonic()-start,records=rows)
    (ROOT/'results/replay-audit.json').write_text(json.dumps(report,indent=2));print(json.dumps({k:v for k,v in report.items() if k!='records'},indent=2))


if __name__=='__main__':run()
