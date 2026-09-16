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
# Default raspi3ap = the Pi 3A+ prototype (512 MB, BCM2837). The gate reuses ONE
# engine instance (juno_gui_reinit), so there is no 12 MB create/destroy churn
# and 512 MB is plenty. Pass raspi3b to run on the 1 GB model instead.
MACH="${1:-raspi3ap}"
OUT="${TMPDIR:-/tmp}/juno_boot_${MACH}.txt"

echo ">> build the engine archive (proven bit-exact flags) + embed bank"
sh "$HERE/build_engine.sh"

echo ">> configure Circle: Pi 3, AArch64, --qemu"
( cd "$CIRCLE" && ./configure -r 3 -p "$PREFIX" --qemu -f )
make -C "$CIRCLE/lib" -j"$(nproc)" >/dev/null
make -C "$CIRCLE/lib/sound" -j"$(nproc)" >/dev/null
make -C "$HERE/kernel" clean >/dev/null 2>&1 || true
make -C "$HERE/kernel" >/dev/null          # GATE image (bit-exact probe)
echo ">> boot on -M $MACH (rendering all scenarios under TCG; up to 240 s)"
timeout 240 qemu-system-aarch64 -M "$MACH" -kernel "$HERE/kernel/kernel8.img" \
    -serial "file:$OUT" -serial null -display none < /dev/null > /dev/null 2>&1 || true

echo "---------------- UART ----------------"
cat "$OUT"
echo "--------------------------------------"
if grep -q "FULL SYNTH BIT-EXACT ON BARE METAL" "$OUT"; then
    echo "RESULT: BIT-EXACT ON METAL ($MACH)"
elif grep -q "PROBE COMPLETE" "$OUT"; then
    echo "RESULT: DIVERGENCE — probe ran but not bit-exact ($MACH)"; exit 1
else
    echo "RESULT: NO BOOT / probe did not finish ($MACH)"; exit 1
fi
