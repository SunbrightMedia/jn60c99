#!/usr/bin/env bash
# build.sh -- compile the STANDALONE JX-3P engine to WebAssembly.
# Requires emsdk (source /home/user/emsdk/emsdk_env.sh or have emcc on PATH).
# Run from the repo root:  bash jx3p/gui/web/build.sh
set -euo pipefail
cd "$(dirname "$0")/../../.."   # repo root

# the engine assets ride INSIDE the wasm filesystem: the clean-boot template,
# the factory bank, and the per-patch recall aux -- all derived from the
# binary by committed tools (jx_template_export / jx_master_recall_export).
# assets are FETCHED by the page as .gz and inflated with the browser's own
# DecompressionStream, then written into the wasm FS -- no zlib anywhere.
cp jx3p/gen/jx_template.bin.gz jx3p/gui/web/jx_template.bin.gz
cp jx3p/gen/jx_master_recall.bin.gz jx3p/gui/web/jx_master_recall.bin.gz
emcc -std=c99 -O2 -ffp-contract=off -fno-strict-aliasing \
  -sGROWABLE_ARRAYBUFFERS=0 \
  jx3p/gui/jx_bridge.c jx3p/src/jx_recall.c \
  jx3p/src/jx_voice_render.c jx3p/src/jx_voice_helpers.c \
  jx3p/src/jx_master_render.c jx3p/src/jx_ftz.c \
  -s EXPORTED_FUNCTIONS='["_jx3p_init","_jx3p_recall","_jx3p_note_on","_jx3p_note_off","_jx3p_render","_jx3p_render_dry","_malloc","_free"]' \
  -s EXPORTED_RUNTIME_METHODS='["ccall","cwrap","HEAPF32","FS"]' \
  -s ALLOW_MEMORY_GROWTH=1 -s MODULARIZE=1 -s EXPORT_ES6=1 \
  -s EXPORT_NAME=Jx3pModule -s ENVIRONMENT=web \
  -o jx3p/gui/web/jx3p.js

if grep -q "toResizableBuffer" jx3p/gui/web/jx3p.js; then
  echo "ERROR: resizable-heap path re-enabled (see gui/web/build.sh)" >&2
  exit 1
fi
# WHY the assets are in the hash: the page cache-busts every fetch with
# ?v=$BUILD_VER, including the .gz engine data. Hashing only code let a
# data-only regeneration (new template/aux, same source) keep the old
# stamp -- browsers would then serve STALE engine data against new code,
# the exact base-split class the aux exporter's tooth guards on the host.
VER=$(cat jx3p/gui/web/jx3p.wasm jx3p/gui/web/jx3p.js \
        jx3p/gui/web/jx_template.bin.gz jx3p/gui/web/jx_master_recall.bin.gz \
        jx3p/gui/web/bank.bin.gz | sha256sum | cut -c1-12)
sed -i "s/const BUILD_VER = \"[^\"]*\"/const BUILD_VER = \"$VER\"/" \
    jx3p/gui/web/index.html
# mirror for GitHub Pages (same convention as the JUNO app in docs/)
mkdir -p docs/jx3p
cp jx3p/gui/web/index.html jx3p/gui/web/jx3p.js jx3p/gui/web/jx3p.wasm \
   jx3p/gui/web/jx_template.bin.gz jx3p/gui/web/jx_master_recall.bin.gz \
   jx3p/gui/web/bank.bin.gz docs/jx3p/
touch docs/.nojekyll
# single-file build for the claude.ai Artifact (classic script, wasm inlined)
emcc -std=c99 -O2 -ffp-contract=off -fno-strict-aliasing \
  -sGROWABLE_ARRAYBUFFERS=0 \
  jx3p/gui/jx_bridge.c jx3p/src/jx_recall.c \
  jx3p/src/jx_voice_render.c jx3p/src/jx_voice_helpers.c \
  jx3p/src/jx_master_render.c jx3p/src/jx_ftz.c \
  -s EXPORTED_FUNCTIONS='["_jx3p_init","_jx3p_recall","_jx3p_note_on","_jx3p_note_off","_jx3p_render_dry","_malloc","_free"]' \
  -s EXPORTED_RUNTIME_METHODS='["ccall","cwrap","HEAPF32","FS"]' \
  -s ALLOW_MEMORY_GROWTH=1 -s MODULARIZE=1 -s EXPORT_NAME=Jx3pModule \
  -s ENVIRONMENT=web \
  -o jx3p/gui/web/jx3p_artifact.js
echo "built jx3p/gui/web/{jx3p.js,jx3p.wasm,jx3p_artifact.js} + docs/jx3p mirror  BUILD_VER=$VER"
