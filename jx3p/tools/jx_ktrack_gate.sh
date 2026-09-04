#!/bin/sh
# jx_ktrack_gate.sh -- the key-tracker differential gate (charter 7b step 2b).
set -e
HERE="$(cd "$(dirname "$0")" && pwd)"
REPO="$(cd "$HERE/../.." && pwd)"
OUT="$REPO/build/jx_ktrack_ab"
mkdir -p "$OUT"
echo "=== 1. oracle replay (Unicorn) ==="
python3 "$HERE/jx_ktrack_emu.py" "$OUT"
echo "=== 2. C twin ==="
cc -std=c99 -O2 -ffp-contract=off -fno-strict-aliasing -shared -fPIC \
   -o "$OUT/libjxktrack.so" "$REPO/jx3p/src/jx_ktrack.c"
python3 "$HERE/jx_ktrack_c.py" "$OUT" "$OUT/libjxktrack.so"
echo "=== 3. the tooth ==="
cc -std=c99 -O2 -ffp-contract=off -fno-strict-aliasing -shared -fPIC \
   -DJX_KTRACK_TOOTH=1 \
   -o "$OUT/libjxktrack_tooth.so" "$REPO/jx3p/src/jx_ktrack.c"
if python3 "$HERE/jx_ktrack_c.py" "$OUT" "$OUT/libjxktrack_tooth.so" \
     > /dev/null 2>&1; then
    echo "*** THE TOOTH DID NOT BITE ***"; exit 1
fi
echo "tooth bites."
echo "JX KTRACK GATE GREEN"
