#!/bin/sh
# chain_gate.sh -- build + run the CHAIN4 sum-law gate (docs/engineb/CHAIN4.md)
# at the CLASSIC-EXACT engine flags, chord 6, and prove its tooth bites.
# Also (re)generates the chord-6 boot triple + answer key the chain firmware
# builds against (esp32s3/main/gen/).
set -e
REPO="$(cd "$(dirname "$0")/../.." && pwd)"
BUILD="$REPO/build/devboot"
HERE="$REPO/tools/engineb/devboot"

# the CLASSIC-EXACT engine flag set: trunk + EXACTLY-0 levers + the classic
# byte law. MUST match the firmware build (DEVCRC_RC_SZ tooth also enforces).
DEFS="-DEB_FORK_S3 -DEB_LFO_SHARED=1 -DEB_VCF_DEADCOEF=1 -DEB_ATREST_BLOCK=1 \
-DEB_ATREST_O1=1 -DEB_ZEROCOEF=1 -DEB_EXP_MEMO=1 -DEB_FUSE_VCA=1 \
-DEB_NOLIBM=1 -DEB_CLASSIC=1"

echo "=== 1. the chord-6 boot triple + answer key (make_boot) ==="
EBOOT_DEFS="$DEFS" python3 "$HERE/make_boot.py" --chord 6

SRCS="$(ls "$REPO"/src/*.c "$REPO"/engine_b/*.c \
        | grep -v engineb_stub | grep -v '/test_')"
CFLAGS="-std=c99 -O2 -ffp-contract=off -fno-strict-aliasing -w \
-I$HERE -I$REPO/src -I$REPO/engine_b -I$REPO/engine_b/dev"
DEVSRC="$REPO/engine_b/dev/ebdev.c $REPO/engine_b/dev/eb_devseq.c"

echo "=== 2. the sum-law gate ==="
cc $CFLAGS $DEFS -DEB_DEVCELLS -DEBDEV_NV=8 -DDEVCHORD_N=6 \
   -o "$BUILD/chain_gate" "$HERE/chain_gate.c" $SRCS $DEVSRC -lm
"$BUILD/chain_gate" "$BUILD/ebdev_boot.bin" "$BUILD/eb_bank64.bin" \
                    "$BUILD/eb_template.bin"

echo "=== 3. the tooth (a misrouted slot MUST fail) ==="
cc $CFLAGS $DEFS -DEB_DEVCELLS -DEBDEV_NV=8 -DDEVCHORD_N=6 -DCHAIN_TOOTH=1 \
   -o "$BUILD/chain_gate_tooth" "$HERE/chain_gate.c" $SRCS $DEVSRC -lm
if "$BUILD/chain_gate_tooth" "$BUILD/ebdev_boot.bin" "$BUILD/eb_bank64.bin" \
                             "$BUILD/eb_template.bin" > /dev/null 2>&1; then
    echo "*** THE TOOTH DID NOT BITE -- the gate proves nothing ***"
    exit 1
fi
echo "tooth bites: the misrouted slot FAILED the gate, as it must."

echo "=== 4. the marker tooth (the OLD shared-tag/unbounded law MUST fail) ==="
cc $CFLAGS $DEFS -DEB_DEVCELLS -DEBDEV_NV=8 -DDEVCHORD_N=6 \
   -DCHAIN_TOOTH_MARK=1 \
   -o "$BUILD/chain_gate_mark" "$HERE/chain_gate.c" $SRCS $DEVSRC -lm
if "$BUILD/chain_gate_mark" "$BUILD/ebdev_boot.bin" "$BUILD/eb_bank64.bin" \
                            "$BUILD/eb_template.bin" > /dev/null 2>&1; then
    echo "*** THE MARKER TOOTH DID NOT BITE -- the law checks prove nothing ***"
    exit 1
fi
echo "marker tooth bites: the old shared-tag law FAILED the gate, as it must."
echo "CHAIN GATE GREEN"
