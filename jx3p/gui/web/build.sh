#!/usr/bin/env bash
# build.sh -- compile the STANDALONE JX-3P engine to WebAssembly.
# Requires emsdk (source /home/user/emsdk/emsdk_env.sh or have emcc on PATH).
# Run from the repo root:  bash jx3p/gui/web/build.sh
set -euo pipefail
cd "$(dirname "$0")/../../.."   # repo root

# the engine assets ride INSIDE the wasm filesystem: the clean-boot template,
# the factory bank, and the per-patch recall aux -- all derived from the
# binary by committed tools (jx_template_export / jx_master_recall_export).
emcc -std=c99 -O2 -ffp-contract=off -fno-strict-aliasing \
  -sGROWABLE_ARRAYBUFFERS=0 -sUSE_ZLIB=1 \
  jx3p/gui/jx_bridge.c jx3p/src/jx_recall.c \
  jx3p/src/jx_voice_render.c jx3p/src/jx_voice_helpers.c \
  jx3p/src/jx_master_render.c jx3p/src/jx_ftz.c \
  --embed-file jx3p/gen/jx_template.bin@/jx_template.bin \
  --embed-file jx3p/gen/jx_master_recall.bin@/jx_master_recall.bin \
  --embed-file jx3p/truth/preset_bank_1.bin@/bank.bin \
  -s EXPORTED_FUNCTIONS='["_jx3p_init","_jx3p_recall","_jx3p_note_on","_jx3p_note_off","_jx3p_render","_malloc","_free"]' \
  -s EXPORTED_RUNTIME_METHODS='["ccall","cwrap","HEAPF32"]' \
  -s ALLOW_MEMORY_GROWTH=1 -s MODULARIZE=1 -s EXPORT_ES6=1 \
  -s EXPORT_NAME=Jx3pModule -s ENVIRONMENT=web \
  -o jx3p/gui/web/jx3p.js

if grep -q "toResizableBuffer" jx3p/gui/web/jx3p.js; then
  echo "ERROR: resizable-heap path re-enabled (see gui/web/build.sh)" >&2
  exit 1
fi
VER=$(cat jx3p/gui/web/jx3p.wasm jx3p/gui/web/jx3p.js | sha256sum | cut -c1-12)
sed -i "s/const BUILD_VER = \"[^\"]*\"/const BUILD_VER = \"$VER\"/" \
    jx3p/gui/web/index.html
echo "built jx3p/gui/web/{jx3p.js,jx3p.wasm}  BUILD_VER=$VER"
