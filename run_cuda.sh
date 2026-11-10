#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
export CUDA_VISIBLE_DEVICES=0
export OMP_NUM_THREADS=1
export OPENBLAS_NUM_THREADS=1
python_bin="${CUDA_PYTHON:-.venv-cuda/bin/python}"
"$python_bin" pytorch_cuda_precision.py
"$python_bin" compare_cpu_cuda_matched.py
