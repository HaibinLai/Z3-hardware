#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

vortex_dir="${VORTEX_DIR:-vortex}"
if [[ ! -f "$vortex_dir/hw/rtl/tcu/tfr/VX_tcu_tfr_align.sv" ]]; then
  printf 'Vortex source missing; run ./setup_sources.sh first.\n' >&2
  exit 1
fi

iverilog_bin="${IVERILOG_BIN:-}"
vvp_bin="${VVP_BIN:-}"
verilator_bin="${VERILATOR_BIN:-}"
if [[ -z "$iverilog_bin" ]]; then
  if command -v iverilog >/dev/null 2>&1; then
    iverilog_bin=iverilog
  else
    iverilog_bin=vendor/apt/iverilog_unpack/usr/bin/iverilog
  fi
fi
if [[ -z "$vvp_bin" ]]; then
  if command -v vvp >/dev/null 2>&1; then
    vvp_bin=vvp
  else
    vvp_bin=vendor/apt/iverilog_unpack/usr/bin/vvp
  fi
fi
if [[ -z "$verilator_bin" ]]; then
  if command -v verilator >/dev/null 2>&1; then
    verilator_bin=verilator
  else
    verilator_bin=vendor/apt/unpack/usr/bin/verilator
    export VERILATOR_ROOT="$PWD/vendor/apt/unpack/usr/share/verilator"
  fi
fi

iverilog_base=()
if [[ -n "${IVERILOG_BASE:-}" ]]; then
  iverilog_base=(-B "$IVERILOG_BASE")
elif [[ "$iverilog_bin" == vendor/apt/iverilog_unpack/usr/bin/iverilog ]]; then
  iverilog_base=(-B "$PWD/vendor/apt/iverilog_unpack/usr/lib/x86_64-linux-gnu/ivl")
fi

sources=(
  rtl_test/VX_tcu_pkg_stub.sv
  "$vortex_dir/hw/rtl/libs/VX_find_first.sv"
  "$vortex_dir/hw/rtl/libs/VX_onehot_mux.sv"
  "$vortex_dir/hw/rtl/libs/VX_lzc.sv"
  "$vortex_dir/hw/rtl/tcu/tfr/VX_tcu_tfr_align.sv"
  rtl_test/tb_tfr_align.sv
)
mkdir -p results rtl_test/obj
"$iverilog_bin" -g2012 "${iverilog_base[@]}" -Irtl_include -s tb_tfr_align \
  -o rtl_test/iverilog.out "${sources[@]}"
"$vvp_bin" rtl_test/iverilog.out | tee results/vortex_iverilog.log
"$verilator_bin" --binary --timing -Wno-fatal -j 8 -Irtl_include \
  --top-module tb_tfr_align --Mdir rtl_test/obj "${sources[@]}" \
  > rtl_test/build.log 2>&1
rtl_test/obj/Vtb_tfr_align | tee results/vortex_verilator.log
