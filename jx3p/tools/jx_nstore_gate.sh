#!/bin/sh
# jx_nstore_gate.sh -- the note-store differential gate (charter 7b step 2a).
set -e
HERE="$(cd "$(dirname "$0")" && pwd)"
REPO="$(cd "$HERE/../.." && pwd)"
OUT="$REPO/build/jx_nstore_ab"
mkdir -p "$OUT"
echo "=== 1. oracle replay (Unicorn) ==="
python3 "$HERE/jx_nstore_emu.py" "$OUT"
echo "=== 2. C twin ==="
cc -std=c99 -O2 -ffp-contract=off -fno-strict-aliasing -shared -fPIC \
   -o "$OUT/libjxnstore.so" "$REPO/jx3p/src/jx_nstore.c"
python3 "$HERE/jx_nstore_c.py" "$OUT" "$OUT/libjxnstore.so"
echo "=== 3. the tooth ==="
cc -std=c99 -O2 -ffp-contract=off -fno-strict-aliasing -shared -fPIC \
   -DJX_NSTORE_TOOTH=1 \
   -o "$OUT/libjxnstore_tooth.so" "$REPO/jx3p/src/jx_nstore.c"
if python3 "$HERE/jx_nstore_c.py" "$OUT" "$OUT/libjxnstore_tooth.so" \
     > /dev/null 2>&1; then
    echo "*** THE TOOTH DID NOT BITE ***"; exit 1
fi
echo "tooth bites."
echo "JX NSTORE GATE GREEN"
