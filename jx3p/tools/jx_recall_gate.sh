#!/bin/sh
# jx_recall_gate.sh -- the JX recall finish line, regenerated from the binary
# every run (no stored intermediate is trusted). Two-process rule honoured: each
# Unicorn step and the ctypes check run in separate processes.
#
#   1. recall_ref_emu.py   (Unicorn) -> recall_ref.pkl   (oracle, per patch)
#   2. recall_separ.py     (Unicorn) -> recall_lut.pkl   (per-pool byte LUTs)
#   3. recall_model_check.py (Unicorn) -- oracle-side separability proof, 64/64
#   4. gen_recall_c.py               -> src/jx_recall_lut.h (generated table)
#   5. cc jx_recall.c                -> librecall.so
#   6. jx_recall_gate.py   (ctypes)  -- C recall == oracle, EXACTLY 0, 64/64
set -e
HERE=$(cd "$(dirname "$0")" && pwd)
REPO=$(cd "$HERE/../.." && pwd)
WORK=${JX_RECALL_WORK:-$(mktemp -d)}
echo "[recall gate] work dir $WORK"
python3 "$HERE/recall_ref_emu.py"      "$WORK"
python3 "$HERE/recall_separ.py"        "$WORK"
python3 "$HERE/recall_model_check.py"  "$WORK"
python3 "$HERE/gen_recall_c.py"        "$WORK"
cc -O2 -fno-strict-aliasing -ffp-contract=off -shared -fPIC \
   -o "$WORK/librecall.so" "$REPO/jx3p/src/jx_recall.c" -I"$REPO/jx3p/src"
python3 "$HERE/jx_recall_gate.py"      "$WORK" "$WORK/librecall.so"
echo "[recall gate] GREEN"
