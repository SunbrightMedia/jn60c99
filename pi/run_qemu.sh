#!/bin/sh
# run_qemu.sh — boot-proof: build a --qemu variant of the kernel and RUN it on
# the emulated Pi 3A+ (the exact prototype board), capturing the UART. This is
# the gate for the boot step: not "it built" but "it boots to metal and runs".
#
# Circle's --qemu build option adapts serial/timer/halt for the emulator, so
# this image is for QEMU ONLY. The hardware image comes from ./build.sh.
#
# Needs: aarch64 cross toolchain (see build.sh) + qemu-system-arm.
#   apt-get install -y qemu-system-arm
#
# NOTE on QEMU serial: on -M raspi3* the FIRST -serial is the mini-UART, which
# is where Circle's log lands here; the SECOND is the PL011. We capture the
# first to a file (a killed pipe can drop buffered output — capture, don't pipe).
set -e
HERE="$(cd "$(dirname "$0")" && pwd)"
CIRCLE="$HERE/circle"
PREFIX=aarch64-linux-gnu-
MACH="${1:-raspi3ap}"          # raspi3ap = Pi 3A+ (prototype); raspi3b also works
OUT="${TMPDIR:-/tmp}/juno_boot_${MACH}.txt"

echo ">> configure Circle: Pi 3, AArch64, --qemu"
( cd "$CIRCLE" && ./configure -r 3 -p "$PREFIX" --qemu -f )
make -C "$CIRCLE/lib" -j"$(nproc)" >/dev/null
make -C "$HERE/kernel" clean >/dev/null 2>&1 || true
make -C "$HERE/kernel" >/dev/null
echo ">> boot on -M $MACH (12 s capture)"
timeout 12 qemu-system-aarch64 -M "$MACH" -kernel "$HERE/kernel/kernel8.img" \
    -serial "file:$OUT" -serial null -display none < /dev/null > /dev/null 2>&1 || true

echo "---------------- UART ----------------"
cat "$OUT"
echo "--------------------------------------"
grep -q "BOOT PROOF COMPLETE" "$OUT" && echo "RESULT: BOOT OK ($MACH)" || { echo "RESULT: NO BOOT"; exit 1; }
