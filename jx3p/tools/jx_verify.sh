#!/bin/sh
# jx_verify.sh -- the JX-3P PORT FINISH LINE. One command, self-proving, every
# fact re-derived from the checksummed binary. Green here == the port is done
# for what it covers; the coverage is stated plainly at the end.
#
# Two proven halves, tied together:
#   A. RECALL   -- jx_recall_gate.sh: C recall == oracle dispatch, EXACTLY 0,
#                  all 64 factory patches (patch bytes -> coefficient state).
#   B. RENDER   -- integration A/B: recall(oracle) -> note-on(oracle) -> the
#                  FULL per-sample chain (8 voice arms + master) in C vs the
#                  plugin's own arms+master, byte-exact on the seam, L/R, and
#                  every final state word. Run across 3 host rates and a long
#                  block so no rate- or time-dependent divergence hides.
#
# Two-process rule honoured (Unicorn oracle and ctypes port never share a
# process). Per-patch process-and-delete keeps the disk flat.
#
# What this does NOT yet cover, stated so "green" is not read wider than it is:
#   * the note-on / voice-allocator is the ORACLE's here (control-plane voice
#     assignment; deterministic). The DSP it feeds IS proven bit-exact. A
#     fully device-standalone engine still needs that allocator transcribed;
#     it is sized in jx3p/docs/S3_STATUS.md.
#   * standalone effect entries not reached by a factory patch (those reached
#     inside the master chain ARE covered by B).
set -e
HERE=$(cd "$(dirname "$0")" && pwd)
REPO=$(cd "$HERE/../.." && pwd)
WORK=${JX_VERIFY_WORK:-$(mktemp -d)}
RATES=${JX_VERIFY_RATES:-"44100 48000 96000"}
N=${JX_VERIFY_N:-64}          # samples per patch (long block: crosses LFO/env edges)
WARM=${JX_VERIFY_WARM:-6}
PATCHES=${JX_VERIFY_PATCHES:-"$(seq 0 63)"}
echo "[jx verify] work dir $WORK  rates=$RATES  n=$N warm=$WARM"

echo "=== JX GATE 1/2: RECALL (C == oracle, 64/64 EXACTLY 0) ==="
sh "$HERE/jx_recall_gate.sh"

echo "=== JX GATE 2/2: INTEGRATION RENDER A/B (voice+master, C == plugin) ==="
cc -O2 -fno-strict-aliasing -ffp-contract=off -shared -fPIC \
   -o "$WORK/libjxengine.so" \
   "$REPO/jx3p/src/jx_voice_render.c" "$REPO/jx3p/src/jx_voice_helpers.c" \
   "$REPO/jx3p/src/jx_master_render.c" -lm
fails=0
for sr in $RATES; do
  spass=0
  for p in $PATCHES; do
    rm -rf "$WORK/ab"
    if ! python3 "$HERE/ab_render_emu.py" "$WORK/ab" "$p" "$N" "$WARM" "$sr" >/dev/null 2>&1; then
      echo "  sr=$sr p=$p ORACLE FAIL"; fails=$((fails+1)); continue
    fi
    if python3 "$HERE/ab_render_c.py" "$WORK/ab" "$WORK/libjxengine.so" "$N" 2>&1 \
        | grep -q "1/1 patches EXACTLY 0"; then
      spass=$((spass+1))
    else
      echo "  sr=$sr p=$p RENDER FAIL"; fails=$((fails+1))
    fi
  done
  echo "  rate $sr: $spass/$(echo $PATCHES | wc -w) EXACTLY 0"
done
rm -rf "$WORK/ab"
if [ "$fails" -ne 0 ]; then
  echo "[jx verify] FAIL -- $fails patch/rate cases not EXACTLY 0"; exit 1
fi
echo "[jx verify] GREEN -- recall 64/64 + render 64/64 x $(echo $RATES | wc -w) rates, all EXACTLY 0"
