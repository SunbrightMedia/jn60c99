#!/bin/sh
# qemu.sh -- boots JUNO LITE in QEMU (no I2S / MIDI there: a stub paces the
# blocks, main.c JL_QEMU) and checks its log: banner, 5 BENCH lines, the demo
# reaches 6 voices, the silence probe reads SILENT and never STUCK.
# Needs ESP-IDF sourced + qemu-xtensa (idf_tools.py install qemu-xtensa).
set -e
cd "$(dirname "$0")/.."
B=${TMPDIR:-/tmp}/junolite_qemu
idf.py -B "$B" -DSDKCONFIG="$B.sdkconfig" -DCMAKE_C_FLAGS=-DJL_QEMU build > "$B.build.log" 2>&1
(cd "$B" && esptool.py --chip esp32s3 merge_bin --fill-flash-size 8MB -o flash.bin @flash_args) > /dev/null 2>&1 \
 || (cd "$B" && python -m esptool --chip esp32s3 merge-bin --pad-to-size 8MB -o flash.bin @flash_args) > /dev/null
timeout 40 qemu-system-xtensa -nographic -machine esp32s3 -drive file="$B/flash.bin",if=mtd,format=raw \
  -serial mon:stdio > "$B.log" 2>&1 || true
L="$B.log"; f=0
grep -q "JUNO LITE v1" "$L" || { echo "FAIL no banner"; f=1; }
[ "$(grep -c '^BENCH' "$L")" = 5 ] || { echo "FAIL want 5 BENCH lines"; f=1; }
grep -q "SIL:STUCK" "$L" && { echo "FAIL silence probe STUCK"; f=1; }
grep -q "SIL:SILENT" "$L" || { echo "FAIL never silent between presets"; f=1; }
grep -q "voices<=6" "$L" || { echo "FAIL never 6 voices"; f=1; }
grep -E "BENCH|JL " "$L" | head -20
[ $f = 0 ] && echo "QEMU CHECK PASS (QEMU timing is not the chip's: trust BENCH only on the board)" || { echo "QEMU CHECK FAIL (log: $L)"; exit 1; }
