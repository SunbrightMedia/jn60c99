#!/bin/sh
# jx_verify.sh -- the JX-3P PORT FINISH LINE. One command, self-proving, every
# fact re-derived from the checksummed binary. Green here == the port is done
# for what it covers; the coverage is stated plainly at the end.
#
# Two proven halves, tied together:
#   A. RECALL   -- the plugin's OWN patch load (2026-10-10, playbook 197): the
#                  oracle drive (initialize's and the patch browser's records
#                  through the engine's own host entry) equals the booted plugin
#                  word for word (jx_recall_product_check.py), and the port's
#                  recall equals that drive in every window, all 64 patches
#                  (jx_recall_data_gate.py). The old pool-model LUT gate
#                  (jx_recall_gate.sh) graded a model and is no gate.
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
mkdir -p "$WORK"
RATES=${JX_VERIFY_RATES:-"44100 48000 96000"}
N=${JX_VERIFY_N:-64}          # samples per patch (long block: crosses LFO/env edges)
WARM=${JX_VERIFY_WARM:-6}
PATCHES=${JX_VERIFY_PATCHES:-"$(seq 0 63)"}
echo "[jx verify] work dir $WORK  rates=$RATES  n=$N warm=$WARM"

echo "=== JX GATE 0/5: THE DRIVE GATE (playbook 87/88/89/90) ==="
# Every defect that cost this port days was a DRIVE defect, invisible to an
# A/B gate because both sides shared it. These teeth check the drive itself:
# the ABI ledger against the machine code, the boot fingerprint against its
# recorded value, the bank decode census (with its tooth), and that the
# shipped template and aux come from ONE boot.
python3 "$HERE/jx_drive_gate.py"
echo "=== JX GATE 1/5: RECALL ON THE PLUGIN'S OWN PATCH LOAD (playbook 197) ==="
python3 "$HERE/jx_recall_product_check.py" 0 49          # the drive == the booted plugin, every unit, word for word
python3 "$HERE/jx_recall_product_check.py" --tooth       # one record left out must be seen
python3 "$HERE/jx_recall_data_gate.py"                   # the port's recall == the drive, every window, 64/64
python3 "$HERE/jx_recall_data_gate.py" --patches 0,20 --tooth

echo "=== JX GATE 2/5: INTEGRATION RENDER A/B (voice+master, C == plugin) ==="
cc -O2 -fno-strict-aliasing -ffp-contract=off -shared -fPIC \
   -o "$WORK/libjxengine.so" \
   "$REPO/jx3p/src/jx_voice_render.c" "$REPO/jx3p/src/jx_voice_helpers.c" \
   "$REPO/jx3p/src/jx_master_render.c" "$REPO/jx3p/src/jx_ftz.c" -lm
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
echo "=== JX GATE 3/5: FULL CHAIN (shipping entry path, reach 12000) ==="
JX_FULL_SKIP_DERIVE=1 sh "$HERE/jx_full_gate.sh"
echo "=== JX GATE 3b: THE MASTER, EVERY SAMPLE OF STATE (64 patches + the mode variants + tooth; playbook 198) ==="
# every unit's state, the 36 control objects and L/R per 256-sample chunk over 4,096 idle + a note +
# 12,000, against the plugin; the variants set the two effect-mode cells to the values no factory
# patch holds, through the plugin's own host entry; the tooth puts the decompile's lost argument back
python3 "$HERE/jx_master_bisect.py" --gate 12000
echo "=== JX GATE 4/5: LISTEN PROOFS (oracle + C twin, dry + master) ==="
python3 "$HERE/jx_listen.py" 0 48,60,72 2>/dev/null
python3 "$HERE/jx_listen.py" 5 48,60,72 --master 2>/dev/null
python3 "$HERE/jx_listen_c.py" "$REPO/build/jx_full_ab/libjx3p.so" 0,20,49,35 48,60,72
python3 "$HERE/jx_listen_c.py" "$REPO/build/jx_full_ab/libjx3p.so" 5,20 48,60,72 --master
echo "=== JX GATE 5/5: THE DELIVERED WEB ENGINE (WASM == native on the page's calls, playbook 196) ==="
if command -v node >/dev/null 2>&1; then
  python3 "$HERE/jx_wasm_check.py" --patches "$(seq -s, 0 63)"
else
  echo "[jx verify] FAIL -- no node: the delivered WASM cannot be graded"; exit 1
fi
echo "[jx verify] GREEN -- recall 64/64 + render 64/64 x $(echo $RATES | wc -w) rates, all EXACTLY 0; the web engine == native"
