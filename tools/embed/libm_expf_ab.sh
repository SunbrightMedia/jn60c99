#!/usr/bin/env bash
# libm_expf_ab.sh — lift newlib's expf out of the toolchain and diff it against
# glibc's, bit for bit. See tools/embed/libm_expf_ab.c for why.
#
# The engine calls expf() in the per-sample audio path (src/voice_render.c:776
# and :1239). arm_golden.sh proves bit-exactness on ARM against *glibc*; a
# Teensy links *newlib*. If the two implementations disagree anywhere in the
# engine's input domain, the on-device golden corpus fails and the cause is not
# the port.
#
# Deps: gcc-arm-linux-gnueabihf, qemu-user-static, gcc-arm-none-eabi
set -u
cd "$(dirname "$0")/../.." || exit 2
OUT="${TMPDIR:-/tmp}/expf_ab"; rm -rf "$OUT"; mkdir -p "$OUT"

# The Cortex-M7 hard-float multilib: exactly what a Teensy 4.1 build links.
LIBM=/usr/lib/arm-none-eabi/newlib/thumb/v7e-m+dp/hard/libm.a
[ -f "$LIBM" ] || { echo "SKIP: newlib $LIBM not found"; exit 0; }
command -v qemu-arm-static >/dev/null || { echo "SKIP: qemu-arm-static missing"; exit 0; }

# expf plus its three helper objects (__exp2f_data, __math_*flowf).
( cd "$OUT" && arm-none-eabi-ar x "$LIBM" \
      libm_a-sf_exp.o libm_a-sf_exp2_data.o libm_a-math_errf.o ) || exit 2

# Rename so glibc's expf and newlib's can coexist in one link.
arm-none-eabi-objcopy --redefine-sym expf=newlib_expf \
    "$OUT/libm_a-sf_exp.o" "$OUT/newlib_expf.o" || exit 2

# The newlib objects are built for M-profile (armv7e-m) and the host binary is
# A-profile; the *code* is plain Thumb-2 + VFP and runs identically, so the
# attribute mismatch is waved through deliberately. Only expf's arithmetic is
# under test, and it is the same instructions either way.
arm-linux-gnueabihf-gcc -std=c99 -O2 -ffp-contract=off -static \
    -march=armv7-a -mfpu=vfpv4-d16 -mfloat-abi=hard \
    -o "$OUT/expf_ab" tools/embed/libm_expf_ab.c \
    "$OUT/newlib_expf.o" "$OUT/libm_a-sf_exp2_data.o" "$OUT/libm_a-math_errf.o" \
    -lm -Wl,--no-warn-mismatch 2>&1 | grep -vi "attribute\|mismatch" | head -5

[ -x "$OUT/expf_ab" ] || { echo "BUILD FAILED"; exit 2; }
qemu-arm-static "$OUT/expf_ab"
