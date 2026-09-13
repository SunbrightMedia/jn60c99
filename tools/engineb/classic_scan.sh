#!/bin/sh
# classic_scan.sh -- build + run the classic-constant coefficient scan
# (tools/engineb/devboot/classic_scan.c) at the CLASSIC-EXACT engine flags.
# Answers: which eb_render_coefs cells can NO compact-patch byte move under
# the classic byte law?  Those are the EB_CLASSIC deletion candidates for
# the CHAIN4 capacity shave (b45: voice+prologue must lose ~320-350 cyc).
set -e
REPO="$(cd "$(dirname "$0")/../.." && pwd)"
BUILD="$REPO/build/devboot"
HERE="$REPO/tools/engineb/devboot"

# MUST stay identical to tools/engineb/chain_gate.sh (and build_chain4.sh):
# a scan at different flags measures a different engine.
DEFS="-DEB_FORK_S3 -DEB_LFO_SHARED=1 -DEB_VCF_DEADCOEF=1 -DEB_ATREST_BLOCK=1 \
-DEB_ATREST_O1=1 -DEB_ZEROCOEF=1 -DEB_EXP_MEMO=1 -DEB_FUSE_VCA=1 \
-DEB_NOLIBM=1 -DEB_CLASSIC=1"

if [ ! -f "$BUILD/eb_bank64.bin" ] || [ ! -f "$BUILD/eb_template.bin" ]; then
    echo "=== bank64/template missing -- generating via make_boot ==="
    EBOOT_DEFS="$DEFS" python3 "$HERE/make_boot.py" --chord 6
fi

# FLAT-state build (no EB_DEVCELLS): the devrecall gate proves flat and
# dev-cells derive bit-identical coefficients at matched engine flags, and
# the flat path is what patchbank.c's round-trip proof runs on.
SRCS="$(ls "$REPO"/src/*.c "$REPO"/engine_b/*.c \
        | grep -v engineb_stub | grep -v '/test_')"
CFLAGS="-std=c99 -O2 -ffp-contract=off -fno-strict-aliasing -w \
-I$HERE -I$REPO/src -I$REPO/engine_b"

cc $CFLAGS $DEFS \
   -o "$BUILD/classic_scan" "$HERE/classic_scan.c" $SRCS -lm
"$BUILD/classic_scan" "$BUILD/eb_bank64.bin" "$BUILD/eb_template.bin"
