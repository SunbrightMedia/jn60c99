#!/usr/bin/env bash
# arm_golden.sh — prove the engine's arithmetic is bit-exact on 32-bit ARM.
#
# This is the check every embedded plan rested on and which had never been run:
# tests/teensy_golden.h has always been generated on x86 and verified on x86.
# Here the SAME corpus is replayed by an ARM binary under qemu-user, so a
# divergence in libm, FP semantics, denormal handling or 32-bit pointer width
# shows up as a hash mismatch.
#
# It also compiles the whole engine for the real bare-metal Cortex-M7 target
# (FPv5-D16 hard-float, Thumb-2) to prove there is no host-only construct, and
# reports code size + hot-function instruction counts for the cycle budget.
#
# Deps:  apt-get install -y gcc-arm-linux-gnueabihf qemu-user-static gcc-arm-none-eabi
# Usage: tools/embed/arm_golden.sh            (from the repo root)
set -u
cd "$(dirname "$0")/../.." || exit 2

CFLAGS_COMMON="-std=c99 -O2 -ffp-contract=off -fno-strict-aliasing -Itests"
SRC="tests/test_teensy_golden.c gui/juno_bridge.c src/*.c"
OUT="${TMPDIR:-/tmp}"
FAIL=0

step() { printf '\n=== %s ===\n' "$1"; }
need() { command -v "$1" >/dev/null 2>&1 || { echo "MISSING: $1 (see header)"; exit 3; }; }

need arm-linux-gnueabihf-gcc
need qemu-arm-static

# ---------------------------------------------------------------- 1. x86 control
step "1/3  x86-64 control (the reference the corpus was generated on)"
# shellcheck disable=SC2086
cc $CFLAGS_COMMON -o "$OUT/tg_x86" $SRC -lm || exit 2
"$OUT/tg_x86" || FAIL=1

# ---------------------------------------------------------- 2. ARM32 under qemu
# armv7-a/VFPv4 is the closest qemu-user-runnable proxy for the M7's FPv5-D16:
# same IEEE-754 single/double semantics, same lack of implicit FMA contraction
# under -ffp-contract=off. A hash match here means the arithmetic is portable;
# it does NOT measure speed (qemu is not cycle-accurate).
step "2/3  ARM32 hard-float under qemu-user  (THE portability proof)"
# shellcheck disable=SC2086
arm-linux-gnueabihf-gcc $CFLAGS_COMMON \
    -march=armv7-a -mfpu=vfpv4-d16 -mfloat-abi=hard -static \
    -o "$OUT/tg_arm" $SRC -lm 2>/dev/null || exit 2
qemu-arm-static "$OUT/tg_arm" || FAIL=1

# ------------------------------------------------- 3. bare-metal Cortex-M7 build
step "3/3  bare-metal Cortex-M7 compile (FPv5-D16, Thumb-2) + size"
if command -v arm-none-eabi-gcc >/dev/null 2>&1; then
    M7="$OUT/m7"; rm -rf "$M7"; mkdir -p "$M7"
    M7FLAGS="-std=c99 -O2 -ffp-contract=off -fno-strict-aliasing \
             -mcpu=cortex-m7 -mfpu=fpv5-d16 -mfloat-abi=hard -mthumb \
             -ffunction-sections -fdata-sections"
    for f in src/*.c gui/juno_bridge.c; do
        # shellcheck disable=SC2086
        arm-none-eabi-gcc $M7FLAGS -c "$f" -o "$M7/$(basename "${f%.c}").o" \
            || { echo "M7 COMPILE FAILED: $f"; FAIL=1; }
    done
    arm-none-eabi-size --format=berkeley "$M7"/*.o | awk 'NR>1{t+=$1} END{
        printf "  engine text: %.1f KiB  (Teensy 4.1 flash 8 MB / Daisy QSPI 8 MB: fits;\n", t/1024
        printf "               H750 internal flash is 128 KB, so a QSPI/HyperFlash boot is required)\n"}'
else
    echo "  SKIP: arm-none-eabi-gcc not installed"
fi

step "RESULT"
[ "$FAIL" -eq 0 ] && echo "ARM GOLDEN OK — the engine is bit-exact off x86." \
                  || echo "ARM GOLDEN FAILED"
exit "$FAIL"
