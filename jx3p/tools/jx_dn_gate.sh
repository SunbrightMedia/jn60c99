#!/bin/sh
# jx_dn_gate.sh -- the note/gate dispatch-handler differential gate
# (charter 7b step 3). Two processes; the seam values [o110+0x58/0x5C] and
# the temper table are read from the oracle and handed to the C.
set -e
HERE="$(cd "$(dirname "$0")" && pwd)"
REPO="$(cd "$HERE/../.." && pwd)"
OUT="$REPO/build/jx_dn_ab"
mkdir -p "$OUT"
echo "=== 1. oracle replay (Unicorn) ==="
python3 "$HERE/jx_dn_emu.py" "$OUT"
echo "=== 2. C twin ==="
cc -std=c99 -O2 -ffp-contract=off -fno-strict-aliasing -shared -fPIC \
   -o "$OUT/libjxdn.so" "$REPO/jx3p/src/jx_dispatch_note.c"
python3 "$HERE/jx_dn_c.py" "$OUT" "$OUT/libjxdn.so"
echo "=== 3. the tooth ==="
cc -std=c99 -O2 -ffp-contract=off -fno-strict-aliasing -shared -fPIC \
   -DJX_DN_TOOTH=1 \
   -o "$OUT/libjxdn_tooth.so" "$REPO/jx3p/src/jx_dispatch_note.c"
if python3 "$HERE/jx_dn_c.py" "$OUT" "$OUT/libjxdn_tooth.so" \
     > /dev/null 2>&1; then
    echo "*** THE TOOTH DID NOT BITE ***"; exit 1
fi
echo "tooth bites."
echo "JX DN GATE GREEN"
