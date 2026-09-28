#!/bin/sh
# Boot the image in QEMU (esp32s3) and print its log. Two builds:
#   real : the shipped image. QEMU has no I2S, so the self-test MUST read FAIL
#          and HEALTH must name the fault -- the detectors seen to fire.
#   fake : -DMSQ_QEMU (timer plays the DMA). The self-test MUST read PASS.
# Needs: . $IDF_PATH/export.sh ; qemu-xtensa installed (idf_tools.py install qemu-xtensa).
cd "$(dirname "$0")/.." || exit 1
O=${TMPDIR:-/tmp}
run() {  # $1 build dir
  (cd "$1" && python -m esptool --chip esp32s3 merge-bin --fill-flash-size 8MB \
      -o "$O/msq_q.bin" @flash_args >/dev/null) || exit 1
  timeout 20 qemu-system-xtensa -nographic -machine esp32s3 -m 32M \
      -drive file="$O/msq_q.bin",if=mtd,format=raw -serial file:"$O/msq_q.log" -monitor none >/dev/null 2>&1
  grep -E "SELFTEST|STAT" "$O/msq_q.log" | head -6
}
idf.py -B build build >/dev/null || exit 1
echo "== real image (expect FAIL: no I2S in QEMU)"; run build
idf.py -B build_qemu -DSDKCONFIG=build_qemu/sdkconfig -DMSQ_QEMU=1 build >/dev/null || exit 1
echo "== fake-DMA image (expect PASS)"; run build_qemu
