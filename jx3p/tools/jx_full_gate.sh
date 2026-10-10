#!/bin/sh
# jx_full_gate.sh -- THE 7b FINISH LINE: the standalone C engine (clean boot,
# its own control plane) vs the plugin driving ITSELF, L/R bit-exact.
set -e
HERE="$(cd "$(dirname "$0")" && pwd)"
REPO="$(cd "$HERE/../.." && pwd)"
OUT="$REPO/build/jx_full_ab"
PATCHES="${JX_FULL_PATCHES:-0,5,20,49}"
N="${JX_FULL_N:-12000}"   # reach past the master EFX NaN birth at 3681 (lesson 9)
mkdir -p "$OUT"
if [ "${JX_FULL_SKIP_DERIVE:-0}" != "1" ]; then
echo "=== 0. regenerate the derived input (the guest image: the plugin's heap after its boot) ==="
python3 "$HERE/jx_guest_export.py" --rate 44100
else
echo "=== 0. derivation SKIPPED (JX_FULL_SKIP_DERIVE=1) ==="
fi
echo "=== 1. the standalone C engine ==="
cc -std=c99 -O2 -ffp-contract=off -fno-strict-aliasing -shared -fPIC \
   -o "$OUT/libjx3p.so" \
   "$REPO/jx3p/gui/jx_bridge.c" "$REPO/jx3p/src/jx_recall.c" \
   "$REPO/jx3p/src/jx_voice_render.c" "$REPO/jx3p/src/jx_voice_helpers.c" \
   "$REPO/jx3p/src/jx_master_render.c" "$REPO/jx3p/src/jx_ftz.c" -lm -lz
cc -std=c99 -O2 -ffp-contract=off -fno-strict-aliasing -shared -fPIC \
   -DJX_FULL_TOOTH=1 -o "$OUT/libjx3p_tooth.so" \
   "$REPO/jx3p/gui/jx_bridge.c" "$REPO/jx3p/src/jx_recall.c" \
   "$REPO/jx3p/src/jx_voice_render.c" "$REPO/jx3p/src/jx_voice_helpers.c" \
   "$REPO/jx3p/src/jx_master_render.c" "$REPO/jx3p/src/jx_ftz.c" -lm -lz
# two modes (2026-10-10): ENGINE = the plugin's own engine render (six voices, the assigner clocks,
# the output gain stage; played past the 0.5 s start mute), DSP = the per-unit renders (every unit,
# no gain stage) -- the voices and the master on every sample from the first
for MODE in 1 0; do
  export JX_FULL_ENGINE=$MODE
  if [ $MODE = 1 ]; then NAME=ENGINE; else NAME=DSP; fi
  echo "=== 2. mode $NAME: the oracle full chain (Unicorn, no pokes) ==="
  python3 "$HERE/jx_full_emu.py" "$OUT/m$MODE" "$PATCHES" "$N"
  echo "=== 3. mode $NAME: the C engine against it ==="
  python3 "$HERE/jx_full_c.py" "$OUT/m$MODE" "$OUT/libjx3p.so" "$PATCHES" "$N"
  echo "=== 4. mode $NAME: the tooth (a one-semitone note skew MUST fail end to end) ==="
  if python3 "$HERE/jx_full_c.py" "$OUT/m$MODE" "$OUT/libjx3p_tooth.so" "$PATCHES" "$N" \
       > /dev/null 2>&1; then
      echo "*** THE TOOTH DID NOT BITE (mode $NAME) ***"; exit 1
  fi
  echo "tooth bites."
done
echo "JX FULL GATE GREEN -- THE PORT PLAYS STANDALONE (both modes)"
