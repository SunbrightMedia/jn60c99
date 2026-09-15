#!/bin/sh
# build_engine.sh — compile the ORIGINAL JUNO port (src/ + gui/juno_bridge.c +
# the shared probe core) into a static archive for the bare-metal kernel, using
# the PROVEN bit-exact flags plus the minimum a freestanding link needs.
#
# The bare-metal-only additions (-ffreestanding -fno-stack-protector -fno-pic
# -fno-pie) touch linkage/canaries/addressing, never float arithmetic, so the
# render stays bit-identical — and verify_engine.sh re-proves that under
# qemu-user before we trust the image.
#
# Also embeds the factory bank: copies truth/presetbankog1.bin -> kernel/bank.bin
# so bank_blob.S .incbin's the exact bytes the host reference used.
set -e
ROOT="$(cd "$(dirname "$0")/.." && pwd)"       # repo root
HERE="$(cd "$(dirname "$0")" && pwd)"          # pi/
PREFIX=aarch64-linux-gnu-
OBJ="$HERE/kernel/build/obj"
OUT="$HERE/kernel/build/libjunoengine.a"
BANK="$ROOT/truth/presetbankog1.bin"

PROVEN="-std=c99 -O2 -ffp-contract=off -fno-strict-aliasing -w"
BARE="-ffreestanding -fno-stack-protector -fno-pic -fno-pie"
INC="-I$ROOT/src -I$ROOT/gui -I$HERE/probe"

[ -f "$BANK" ] || { echo "missing truth bank: $BANK"; exit 1; }
rm -rf "$OBJ"; mkdir -p "$OBJ"

echo ">> compile engine (proven flags + bare-metal safe)"
for f in $(ls "$ROOT"/src/*.c) "$ROOT/gui/juno_bridge.c" "$HERE/probe/juno_probe_core.c"; do
	o="$OBJ/$(basename "$f" .c).o"
	${PREFIX}gcc $PROVEN $BARE $INC -c "$f" -o "$o"
done

# The exact math shim (fabsf/fmodf/lrint/...). -fno-math-errno lets the builtins
# inline to AArch64 instructions (no glibc libm, no errno, no recursion).
echo ">> compile bare_libm (exact math, no glibc)"
${PREFIX}gcc $PROVEN $BARE -fno-math-errno $INC -c "$HERE/kernel/bare_libm.c" -o "$OBJ/bare_libm.o"

echo ">> archive -> $OUT"
rm -f "$OUT"; ${PREFIX}ar rcs "$OUT" "$OBJ"/*.o

echo ">> embed bank -> kernel/bank.bin ($(wc -c < "$BANK") bytes)"
cp "$BANK" "$HERE/kernel/bank.bin"

echo ">> engine archive done: $(${PREFIX}ar t "$OUT" | wc -l) objects"
