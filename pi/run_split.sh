#!/bin/sh
# run_split.sh — build the MULTI-CORE split kernel and run it on 4 emulated
# cores, proving the fork-join is bit-exact vs single core (the real concurrency:
# barrier, ARM memory ordering, per-core private engine copies).
#
# Needs the aarch64 cross toolchain + qemu-system-arm (see build.sh). NOTE: do
# NOT pass -smp to QEMU — raspi3b already models 4 cores and -smp makes it fail
# to boot.
set -e
HERE="$(cd "$(dirname "$0")" && pwd)"
CIRCLE="$HERE/circle"
PREFIX=aarch64-linux-gnu-
OUT="${TMPDIR:-/tmp}/juno_split.txt"

sh "$HERE/build_engine.sh"
echo ">> configure Circle: Pi 3, AArch64, --qemu --multicore"
( cd "$CIRCLE" && ./configure -r 3 -p "$PREFIX" --qemu --multicore -f )
make -C "$CIRCLE/lib" clean >/dev/null 2>&1 || true      # multicore flag changes the lib
make -C "$CIRCLE/lib" -j"$(nproc)" >/dev/null
make -C "$CIRCLE/lib/sound" -j"$(nproc)" >/dev/null
make -C "$HERE/kernel" clean >/dev/null 2>&1 || true
make -C "$HERE/kernel" JUNO_SPLIT=1 >/dev/null

echo ">> boot on 4 emulated cores (-M raspi3b, no -smp; up to 60 s)"
timeout 60 qemu-system-aarch64 -M raspi3b -kernel "$HERE/kernel/kernel8.img" \
    -serial "file:$OUT" -serial null -display none < /dev/null > /dev/null 2>&1 || true

echo "---------------- UART ----------------"
cat "$OUT"
echo "--------------------------------------"
grep -q "SPLIT BIT-EXACT ON 4 EMULATED CORES" "$OUT" \
    && echo "RESULT: MULTI-CORE SPLIT BIT-EXACT" \
    || { echo "RESULT: FAIL / did not complete"; exit 1; }
