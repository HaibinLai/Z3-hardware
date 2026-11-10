#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
export OMP_NUM_THREADS=1
export OPENBLAS_NUM_THREADS=1
python_bin="${CPU_PYTHON:-.venv/bin/python}"
"$python_bin" pytorch_precision.py
"$python_bin" prove_models.py
"$python_bin" ventus_tree_case.py
"$python_bin" exhaustive_small_domain.py
./run_rtl.sh
