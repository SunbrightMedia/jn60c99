#!/bin/sh
# jx_alloc_gate.sh -- the note-manager differential gate (charter 7b step 1).
# Two processes (two-process rule): the oracle writes files, the C reads them.
# Then the TOOTH: a one-op perturbation of the C MUST fail the same gate.
set -e
HERE="$(cd "$(dirname "$0")" && pwd)"
REPO="$(cd "$HERE/../.." && pwd)"
OUT="$REPO/build/jx_alloc_ab"
mkdir -p "$OUT"

echo "=== 1. oracle replay (Unicorn) ==="
python3 "$HERE/jx_alloc_emu.py" "$OUT"

echo "=== 2. C twin ==="
cc -std=c99 -O2 -ffp-contract=off -fno-strict-aliasing -shared -fPIC \
   -o "$OUT/libjxalloc.so" "$REPO/jx3p/src/jx_alloc.c"
python3 "$HERE/jx_alloc_c.py" "$OUT" "$OUT/libjxalloc.so"

echo "=== 3. the tooth (a one-op change MUST fail) ==="
cc -std=c99 -O2 -ffp-contract=off -fno-strict-aliasing -shared -fPIC \
   -DJX_ALLOC_TOOTH=1 \
   -o "$OUT/libjxalloc_tooth.so" "$REPO/jx3p/src/jx_alloc.c"
if python3 "$HERE/jx_alloc_c.py" "$OUT" "$OUT/libjxalloc_tooth.so" \
     > /dev/null 2>&1; then
    echo "*** THE TOOTH DID NOT BITE -- the gate proves nothing ***"
    exit 1
fi
echo "tooth bites: the perturbed twin FAILED, as it must."
echo "JX ALLOC GATE GREEN"
