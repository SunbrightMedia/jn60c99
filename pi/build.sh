#!/bin/sh
# build.sh — build the JUNO bare-metal HARDWARE image (kernel8.img) for a real
# Pi 3 family board (BCM2837: Zero 2 W / 3A+ / 3B). One image serves all three.
#
# Toolchain (Ubuntu/Debian): aarch64 cross gcc + g++.
#   apt-get install -y gcc-aarch64-linux-gnu g++-aarch64-linux-gnu
# Circle upstream uses aarch64-none-elf-; we use aarch64-linux-gnu- plus the
# __getauxval stub in kernel/bare_stubs.c (see that file). Same result.
#
# Run ./run_qemu.sh for the emulator boot-proof (it builds a --qemu variant).
set -e
HERE="$(cd "$(dirname "$0")" && pwd)"
CIRCLE="$HERE/circle"
PREFIX=aarch64-linux-gnu-

command -v ${PREFIX}g++ >/dev/null 2>&1 || {
  echo "missing ${PREFIX}g++ — apt-get install -y gcc-aarch64-linux-gnu g++-aarch64-linux-gnu"; exit 1; }

# Circle is a pinned submodule; make sure it is checked out.
[ -f "$CIRCLE/Rules.mk" ] || { echo "circle submodule empty — git submodule update --init pi/circle"; exit 1; }

echo ">> build the engine archive (proven bit-exact flags) + embed bank"
sh "$HERE/build_engine.sh"

echo ">> configure Circle: Pi 3, AArch64 (hardware)"
( cd "$CIRCLE" && ./configure -r 3 -p "$PREFIX" -f )

echo ">> build libcircle.a"
make -C "$CIRCLE/lib" -j"$(nproc)"

echo ">> build kernel8.img"
make -C "$HERE/kernel" clean >/dev/null 2>&1 || true
make -C "$HERE/kernel"

echo ">> DONE: $HERE/kernel/kernel8.img"
ls -la "$HERE/kernel/kernel8.img"
