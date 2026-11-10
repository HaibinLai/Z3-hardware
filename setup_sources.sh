#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

checkout_sparse() {
  local directory="$1" url="$2" sha="$3"
  shift 3
  if [[ ! -d "$directory/.git" ]]; then
    git clone --quiet --depth=1 --filter=blob:none --sparse "$url" "$directory"
  fi
  if [[ "$(git -C "$directory" rev-parse HEAD)" != "$sha" ]]; then
    git -C "$directory" fetch --quiet --depth=1 origin "$sha"
    git -C "$directory" checkout --quiet --detach "$sha"
  fi
  git -C "$directory" sparse-checkout set "$@"
  printf '%s %s\n' "$directory" "$(git -C "$directory" rev-parse HEAD)"
}

checkout_sparse vortex https://github.com/vortexgpgpu/vortex.git \
  127178d6375c3cb525e2c8af0c77b5f2d52ed93e \
  hw/rtl/libs hw/rtl/tcu hw/rtl/fpu docs/designs
checkout_sparse ventus https://github.com/THU-DSP-LAB/ventus-gpgpu.git \
  681172541a8a34ffb43c483a19c075acbc11a4eb \
  ventus/src/pipeline ventus/src/top
checkout_sparse fpuv2 https://github.com/THU-DSP-LAB/fpuv2.git \
  7ea30df00f9353f2e8645b32665b13f9b3f69e6d \
  src/main/scala
