#!/bin/sh
# build_render.sh -- jp8_render from the committed lift (jp8/src/jp8_host_lift.c): the fast pass (jp8_fast.py), the
# lane pass (jp8_xlane.py), then ISO C99 at -O2 with the product build's flags (jp8_host_gate.sh PRD: one host offset,
# no bounds check, guest memory not volatile). The template it needs is jp8/gen/jp8h_template.bin.gz, gunzipped.
#   sh jp8/apps/build_render.sh [outdir=build/jp8_render]
#   gunzip -c jp8/gen/jp8h_template.bin.gz > build/jp8_render/jp8h_template.bin
#   build/jp8_render/jp8_render build/jp8_render/jp8h_template.bin jp8/truth/1_Preset.bin 2 in.mid out.wav
set -e
HERE="$(cd "$(dirname "$0")" && pwd)"; REPO="$(cd "$HERE/../.." && pwd)"; OUT="${1:-$REPO/build/jp8_render}"; mkdir -p "$OUT"
python3 "$REPO/jp8/tools/jp8_fast.py" "$REPO/jp8/src/jp8_host_lift.c" "$OUT/lift_fast.c"
python3 "$REPO/jp8/tools/jp8_xlane.py" "$OUT/lift_fast.c" "$OUT/lift_xl.c"
F="-std=c99 -pedantic-errors -ffp-contract=off -fno-strict-aliasing -fwrapv -DJP8_RELOC -DJP8_FLAT -DJP8_GS_BASE=0x580000000ULL"
F="$F -I$REPO/jp8/src -O2 -DJP8_RELOC_CHECK=0 -DJP8_MQ="
cc $F -w -c -o "$OUT/lift.o" "$OUT/lift_xl.c"
cc $F -c -o "$OUT/rt.o" "$REPO/jp8/src/jp8_rt.c"
cc $F -c -o "$OUT/host.o" "$REPO/jp8/src/jp8_host.c"
cc $F -Wall -Wextra -c -o "$OUT/render.o" "$REPO/jp8/apps/jp8_render.c"
cc -o "$OUT/jp8_render" "$OUT/render.o" "$OUT/lift.o" "$OUT/rt.o" "$OUT/host.o" -lm
echo "built $OUT/jp8_render"
