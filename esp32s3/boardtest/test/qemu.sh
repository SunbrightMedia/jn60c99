#!/bin/sh
# qemu.sh -- boots the board test in QEMU (no I2S there: a timer stub plays the
# blocks, main.c BT_QEMU) and checks its log: banner, I2S started, every stage
# line with the host check's peaks, two loops at ~44100 Hz with no errors.
# Needs ESP-IDF sourced + qemu-xtensa (idf_tools.py install qemu-xtensa).
set -e
cd "$(dirname "$0")/.."
B=${TMPDIR:-/tmp}/boardtest_qemu
idf.py -B "$B" -DSDKCONFIG="$B.sdkconfig" -DCMAKE_C_FLAGS=-DBT_QEMU build > "$B.build.log" 2>&1
(cd "$B" && esptool.py --chip esp32s3 merge_bin --fill-flash-size 8MB -o flash.bin @flash_args) > /dev/null 2>&1 \
 || (cd "$B" && python -m esptool --chip esp32s3 merge-bin --pad-to-size 8MB -o flash.bin @flash_args) > /dev/null
timeout 60 qemu-system-xtensa -nographic -machine esp32s3 -drive file="$B/flash.bin",if=mtd,format=raw \
  -serial mon:stdio > "$B.log" 2>&1 || true
L="$B.log"; f=0
grep -q "BOARD TEST v1" "$L" || { echo "FAIL no banner"; f=1; }
grep -q "BT I2S started" "$L" || { echo "FAIL no I2S start"; f=1; }
for s in "LEFT 440Hz  frames= 66150 peakL= 1036 peakR=    0" "RIGHT 880Hz frames= 66150 peakL=    0 peakR= 1036" \
         "MELODY      frames=158760 peakL=  898 peakR=  898"; do
  grep -q "stage=$s" "$L" || { echo "FAIL no line: $s"; f=1; }; done
grep -q "BT-LOOP 2 .* i2s_errors=0" "$L" || { echo "FAIL no clean loop 2"; f=1; }
grep "BT" "$L" | tail -12
[ $f = 0 ] && echo "QEMU CHECK PASS" || { echo "QEMU CHECK FAIL (log: $L)"; exit 1; }
