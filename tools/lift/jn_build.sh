#!/bin/sh
# jn_build.sh -- build the lifted JUNO host from the L1 census (docs/JUNO_LIFT.md): the oracle's special-import list
# (gen_oracle_imports.py -> lift/jn_oracle_imports.h), the host-flavor lift (gen_juno_lift.sh -> lift/jn_lift.c), the
# JNH1 template (jn_host_ref.py, Unicorn), and build/jn_host/libjunohost.so. Every L5 gate runs on this build
# (tools/lift/jn_l5_all.sh). A census must exist (tools/verify/juno_lift_reach.py).
# usage: sh tools/lift/jn_build.sh            (run from the repo root)
set -e
R=${REPO:-.}
OUT="$R/build/jn_host"; mkdir -p "$OUT"
[ -f "$R/scratchpad/lift/juno_reach.json" ] || { echo "no L1 census -- run tools/verify/juno_lift_reach.py"; exit 2; }
echo "[build 1/4] the oracle's special-import list (from its own source)"
python3 "$R/tools/lift/gen_oracle_imports.py"
echo "[build 2/4] the host-flavor lift (lift/jn_lift.c)"
sh "$R/tools/lift/gen_juno_lift.sh"
echo "[build 3/4] the JNH1 template (regions + facts + the oracle's Python-side state + stubs)"
python3 "$R/tools/lift/jn_host_ref.py" "$OUT/jn_host_template.bin" >/dev/null
echo "[build 4/4] libjunohost.so"
BASE="-std=c99 -ffp-contract=off -fno-strict-aliasing -fwrapv -fPIC -DJP8_RELOC -DJP8_FLAT -DJP8_GS_BASE=0x580000000ULL -I$R/jp8/src -I$R/lift"
cc $BASE -w -c "$R/lift/jn_lift.c" -o "$OUT/jn_lift.o"
cc $BASE -pedantic-errors -c "$R/jp8/src/jp8_rt.c" -o "$OUT/jn_rt.o"
cc $BASE -pedantic-errors -c "$R/lift/jn_host.c" -o "$OUT/jn_host.o"
cc -shared -o "$OUT/libjunohost.so" "$OUT/jn_lift.o" "$OUT/jn_rt.o" "$OUT/jn_host.o" -lm
echo "jn_build: OK -> $OUT/libjunohost.so"
