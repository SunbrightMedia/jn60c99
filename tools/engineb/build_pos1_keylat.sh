#!/bin/bash
# build_pos1_keylat.sh -- MEASUREMENT BUILD (2026-09-15, do not ship).
# Rebuilds ONLY chain4 position 1 with the key-to-DAC latency probe
# (-DS3L_KEYLAT=1) added to the committed pos1 flag set. Everything else is
# byte-identical to build_chain4.sh's pos1, so reflashing pos1 alone is safe:
# S3L_KEYLAT only prints, and touches no wire/event/format code. It does NOT
# write VERSION.txt -- the bench is not triggered; the user flashes by hand.
set -e
REPO="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$REPO/esp32s3"
: "${IDF_PATH:=/home/user/esp-idf}"
export IDF_PYTHON_CHECK_CONSTRAINTS=no
cd "$IDF_PATH" && . ./export.sh > /dev/null && cd "$REPO/esp32s3"

LEVERS="-DEB_VCF_DEADCOEF=1;-DEB_ATREST_BLOCK=1;-DEB_ATREST_O1=1;\
-DEB_ZEROCOEF=1;-DEB_EXP_MEMO=1;-DEB_FUSE_VCA=1;-DEB_NOLIBM=1;-DEB_VCA_DEFER=1;-DEB_FPDIV=1;\
-DEB_CR_PITCH=1;-DEB_CR_MODCV=1;-DEB_CR_VCFCV=1;-DEB_CR_ENV=1;-DEB_CR_N=4;-DEB_CR_NP=4;-DEB_CR_NC=2;-DEB_CR_NE=2;-DEB_LFO_TAIL_CR=1"
COMMON="-DS3L_SWEEP=0;-DS3_CORES=2;-DS3L_FX_PIPE=1;-DS3L_PROLOGUE_C1=1;\
-DS3L_REPORT_SECS=10;-DCHUNK=256;-DS3L_DMA_N=6;-DS3L_LINK=0;-DS3L_CHAIN=1;\
-DS3L_PLAY=1"
# pos1 committed set + the probe flag.
PER="-DS3L_VOICE_LO=7;-DS3L_SPLIT=8;-DS3L_MIDI=1;-DS3L_STRESS=1;-DS3L_PANEL=1;-DS3L_KEYLAT=1"

echo "=== CHAIN4 position 1  +KEYLAT (measurement) ==="
rm -rf build sdkconfig
idf.py -DS3_LISTEN=1 -DS3_RECALL=1 -DS3_VOICES=6 -DS3_EXACT_ONLY=1 \
       -DS3_EXTRA_DEFS="$COMMON;$LEVERS;$PER;-DS3_CHAIN_POS=1" \
       build
OUT="$REPO/esp32s3/flash/chain4/pos1"
mkdir -p "$OUT"
cp build/bootloader/bootloader.bin            "$OUT/bootloader.bin"
cp build/partition_table/partition-table.bin  "$OUT/partitiontable.bin"
cp build/juno_s3.bin                          "$OUT/juno_s3.bin"
( cd "$OUT" && sha256sum *.bin > SHA256SUMS )
echo "staged -> $OUT (VERSION.txt deliberately NOT written)"
