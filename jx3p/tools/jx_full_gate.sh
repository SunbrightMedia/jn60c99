#!/bin/sh
# jx_full_gate.sh -- THE 7b FINISH LINE: the standalone C engine (clean boot,
# its own control plane) vs the plugin driving ITSELF, L/R bit-exact.
set -e
HERE="$(cd "$(dirname "$0")" && pwd)"
REPO="$(cd "$HERE/../.." && pwd)"
OUT="$REPO/build/jx_full_ab"
PATCHES="${JX_FULL_PATCHES:-0,5,20,49}"
N="${JX_FULL_N:-1200}"
mkdir -p "$OUT"
if [ "${JX_FULL_SKIP_DERIVE:-0}" != "1" ]; then
echo "=== 0. regenerate the derived inputs (template + recall aux) ==="
python3 "$HERE/jx_template_export.py"
python3 "$HERE/jx_master_recall_export.py"
else
echo "=== 0. derivation SKIPPED (JX_FULL_SKIP_DERIVE=1) ==="
fi
echo "=== 1. oracle full chain (Unicorn, no pokes) ==="
python3 "$HERE/jx_full_emu.py" "$OUT" "$PATCHES" "$N"
echo "=== 2. the standalone C engine ==="
cc -std=c99 -O2 -ffp-contract=off -fno-strict-aliasing -shared -fPIC \
   -o "$OUT/libjx3p.so" \
   "$REPO/jx3p/gui/jx_bridge.c" "$REPO/jx3p/src/jx_recall.c" \
   "$REPO/jx3p/src/jx_voice_render.c" "$REPO/jx3p/src/jx_voice_helpers.c" \
   "$REPO/jx3p/src/jx_master_render.c" "$REPO/jx3p/src/jx_ftz.c" -lm -lz
python3 "$HERE/jx_full_c.py" "$OUT" "$OUT/libjx3p.so" "$PATCHES" "$N"
echo "=== 3. the tooth (a one-semitone note skew MUST fail end to end) ==="
cc -std=c99 -O2 -ffp-contract=off -fno-strict-aliasing -shared -fPIC \
   -DJX_FULL_TOOTH=1 -o "$OUT/libjx3p_tooth.so" \
   "$REPO/jx3p/gui/jx_bridge.c" "$REPO/jx3p/src/jx_recall.c" \
   "$REPO/jx3p/src/jx_voice_render.c" "$REPO/jx3p/src/jx_voice_helpers.c" \
   "$REPO/jx3p/src/jx_master_render.c" "$REPO/jx3p/src/jx_ftz.c" -lm -lz
if python3 "$HERE/jx_full_c.py" "$OUT" "$OUT/libjx3p_tooth.so" "$PATCHES" "$N" \
     > /dev/null 2>&1; then
    echo "*** THE TOOTH DID NOT BITE ***"; exit 1
fi
echo "tooth bites."
echo "JX FULL GATE GREEN -- THE PORT PLAYS STANDALONE"
