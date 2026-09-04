#!/bin/bash
# build_chain4.sh -- build the four CHAIN4 position images and STAGE them in
# esp32s3/flash/chain4/pos{1..4} as the three-bin set the bench flashes.
#
# COMMITTED ON PURPOSE. This lived in scratchpad/ for the first chain arc and
# died with the container, which cost a rebuild of the recipe from a summary.
# The engine flags here are the b44 CLASSIC-EXACT set and MUST stay identical
# to tools/engineb/chain_gate.sh (the host gate that makes the answer key).
#
# Usage:  sh tools/engineb/build_chain4.sh [pos ...]      (default: 1 2 3 4)
set -e
REPO="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$REPO/esp32s3"

# export.sh insists on being sourced FROM the IDF directory (it detects
# IDF_PATH from $PWD, not from the path it was called by).
: "${IDF_PATH:=/home/user/esp-idf}"
# the constraints download 403s behind the agent proxy; the pinned tools are
# already installed, so the check is the only thing that fails.
export IDF_PYTHON_CHECK_CONSTRAINTS=no
cd "$IDF_PATH" && . ./export.sh > /dev/null && cd "$REPO/esp32s3"

# trunk + EXACTLY-0 levers + the 1982 byte law. No approximation, no MSPROF.
LEVERS="-DEB_VCF_DEADCOEF=1;-DEB_ATREST_BLOCK=1;-DEB_ATREST_O1=1;\
-DEB_ZEROCOEF=1;-DEB_EXP_MEMO=1;-DEB_FUSE_VCA=1;-DEB_NOLIBM=1;-DEB_CLASSIC=1"
# prologue and the FULL master ride core 1 -- b45's measured law: one exact
# voice per core is the maximum, so no REV_PIPE and no second voice anywhere.
COMMON="-DS3L_SWEEP=0;-DS3_CORES=2;-DS3L_FX_PIPE=1;-DS3L_PROLOGUE_C1=1;\
-DS3L_REPORT_SECS=10;-DCHUNK=256;-DS3L_DMA_N=6;-DS3L_LINK=0;-DS3L_CHAIN=1;\
-DS3L_PLAY=1"

for POS in "${@:-1 2 3 4}"; do
    case "$POS" in
    1) PER="-DS3L_VOICE_LO=7;-DS3L_SPLIT=8;-DS3L_MIDI=1;-DS3L_STRESS=1" ;;
    2) PER="-DS3L_VOICE_LO=6;-DS3L_SPLIT=7;-DS3L_VOICE_HI=7;-DS3L_NOMASTER=1" ;;
    3) PER="-DS3L_VOICE_LO=4;-DS3L_SPLIT=5;-DS3L_VOICE_HI=6;-DS3L_NOMASTER=1" ;;
    4) PER="-DS3L_VOICE_LO=2;-DS3L_SPLIT=3;-DS3L_VOICE_HI=4;-DS3L_NOMASTER=1" ;;
    *) echo "position must be 1..4"; exit 1 ;;
    esac
    echo "=== CHAIN4 position $POS ==="
    rm -rf build sdkconfig
    idf.py -DS3_LISTEN=1 -DS3_RECALL=1 -DS3_VOICES=6 -DS3_EXACT_ONLY=1 \
           -DS3_EXTRA_DEFS="$COMMON;$LEVERS;$PER;-DS3_CHAIN_POS=$POS" \
           build
    OUT="$REPO/esp32s3/flash/chain4/pos$POS"
    mkdir -p "$OUT"
    cp build/bootloader/bootloader.bin      "$OUT/bootloader.bin"
    cp build/partition_table/partition-table.bin "$OUT/partitiontable.bin"
    cp build/juno_s3.bin                    "$OUT/juno_s3.bin"
    ( cd "$OUT" && sha256sum *.bin > SHA256SUMS )
    echo "staged -> $OUT"
done
