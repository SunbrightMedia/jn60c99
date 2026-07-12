#!/usr/bin/env bash
# build.sh — compile the JUNO-60 C99 engine to WebAssembly for the in-browser GUI
# and regenerate params.json. Requires the emscripten SDK (emcc) on PATH:
#   git clone https://github.com/emscripten-core/emsdk && cd emsdk
#   ./emsdk install latest && ./emsdk activate latest && source ./emsdk_env.sh
#
# Output (committed so GitHub Pages serves it without a build step):
#   gui/web/juno.js  gui/web/juno.wasm  gui/web/params.json
# Run from the repo root:  bash gui/web/build.sh
set -euo pipefail
cd "$(dirname "$0")/../.."   # repo root

emcc -std=c99 -O2 -fno-strict-aliasing gui/juno_bridge.c src/*.c -lm \
  -s EXPORTED_FUNCTIONS='["_juno_gui_create","_juno_gui_set","_juno_gui_get","_juno_gui_recall_factory","_juno_gui_set_chorus_mode","_juno_gui_gate","_juno_gui_note_on","_juno_gui_note_off","_juno_gui_arp_config","_juno_gui_get_arp","_juno_gui_apply_bank","_juno_gui_render","_juno_gui_render_dry","_juno_gui_param_count","_juno_gui_param_name","_juno_gui_param_offset","_juno_gui_set_param","_juno_gui_warmup","_malloc","_free"]' \
  -s EXPORTED_RUNTIME_METHODS='["ccall","cwrap","HEAPF32","HEAPU8"]' \
  -s ALLOW_MEMORY_GROWTH=1 -s MODULARIZE=1 -s EXPORT_ES6=1 -s EXPORT_NAME=JunoModule \
  -s ENVIRONMENT=web \
  -o gui/web/juno.js

python3 - <<'PY'
import re, json
out, seen = [], set()
for line in open("docs/COEFF_PARAM_MAP.md", encoding="utf-8"):
    m = re.match(r"\|\s*(\d+)\s*\|\s*([^|]+?)\s*\|", line)
    if m and m.group(1).isdigit():
        o = int(m.group(1))
        if o not in seen:
            seen.add(o); out.append([o, m.group(2)])
json.dump(sorted(out), open("gui/web/params.json", "w"))
print("params.json:", len(out), "params")
PY

# Cache-busting: stamp index.html with the WASM content hash so browsers/CDN fetch
# the new engine instead of a stale juno.wasm (same filename would otherwise cache).
VER=$(sha256sum gui/web/juno.wasm | cut -c1-12)
sed -i "s/const BUILD_VER = \"[^\"]*\"/const BUILD_VER = \"$VER\"/" gui/web/index.html
echo "stamped BUILD_VER=$VER"

# Mirror the static app into docs/ — GitHub Pages serves it from there
# (Settings > Pages > Deploy from a branch > /docs). Keeps both copies in sync.
cp gui/web/index.html gui/web/bank.js gui/web/juno.js gui/web/juno.wasm \
   gui/web/params.json gui/web/param_meta.json docs/
touch docs/.nojekyll

echo "built gui/web/{juno.js,juno.wasm,params.json} and mirrored to docs/"
