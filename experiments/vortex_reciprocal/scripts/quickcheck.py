"""Reject stale source/model snapshots, then run the lightweight core proofs."""
import hashlib,json,subprocess,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]


def main():
    manifest=json.loads((ROOT/'results/published-models.json').read_text())
    for rel,expected in manifest.items():
        path=ROOT/rel
        assert path.exists() and hashlib.sha256(path.read_bytes()).hexdigest()==expected, f'Stale or missing {rel}; rebuild models and results before trusting checks'
    for name in ['semantics.py','quantization.py']:
        subprocess.run([sys.executable,str(ROOT/'scripts'/name)],check=True)
    rows=json.loads((ROOT/'results/semantic-summary.json').read_text());assert all(r['status']=='unsat' for r in rows),rows
    print('Source/model snapshots match; lightweight proof checks passed')


if __name__=='__main__':main()
