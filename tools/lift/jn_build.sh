#!/bin/sh
# jn_build.sh -- build the lifted JUNO host from the L1 census (docs/JUNO_LIFT.md): the oracle's special-import list
# (gen_oracle_imports.py -> lift/jn_oracle_imports.h), the host-flavor lift (gen_juno_lift.sh -> lift/jn_lift.c), the
# JNH1 template (jn_host_ref.py, Unicorn), and build/jn_host/libjunohost.so. Every L5 gate runs on this build
# (tools/lift/jn_l5_all.sh). A census must exist (tools/verify/juno_lift_reach.py).
# JN_KEEP_LIFT=1: the glue / template changed, the lift did not -- keep lift/jn_lift.c and its part objects (their
# stamp, the sha256 of the lift they were compiled from, must equal lift/jn_lift.c's: a stale object never links).
# usage: sh tools/lift/jn_build.sh            (run from the repo root)
set -e
R=${REPO:-.}
OUT="$R/build/jn_host"; mkdir -p "$OUT"
[ -f "$R/scratchpad/lift/juno_reach.json" ] || { echo "no L1 census -- run tools/verify/juno_lift_reach.py"; exit 2; }
echo "[build 1/4] the oracle's special-import list (from its own source)"
python3 "$R/tools/lift/gen_oracle_imports.py"
if [ "${JN_KEEP_LIFT:-0}" = 1 ]; then
  echo "[build 2/4] JN_KEEP_LIFT=1: lift/jn_lift.c and its objects kept"
  S=$(sha256sum < "$R/lift/jn_lift.c" | cut -c1-64)
  [ "$S" = "$(cat "$OUT/jn_lift.stamp" 2>/dev/null)" ] || { echo "jn_build: the lift objects are not of lift/jn_lift.c ($S)"; exit 2; }
else
  echo "[build 2/4] the host-flavor lift (lift/jn_lift.c)"
  sh "$R/tools/lift/gen_juno_lift.sh"
fi
echo "[build 3/4] the JNH1 template (regions + facts + the oracle's Python-side state + stubs)"
python3 "$R/tools/lift/jn_host_ref.py" "$OUT/jn_host_template.bin" >/dev/null
echo "[build 4/4] libjunohost.so (the GATE flavor) and libjunohost_hw.so (the PRODUCT flavor)"
# Two float flavors of ONE lift (docs/JUNO_LIFT.md L3): the PRODUCT runs the plugin's float operations on the
# hardware at the guest's MXCSR (FTZ / DAZ real) -- L3 proves each statement equal to the CPU; the GATE flavor
# models the oracle's float semantics (Unicorn 2.1.4: DAZ on inputs, no FTZ, its NaN choice; JP8_SOFTFP=1
# JP8_ORACLE_NAN) -- L3 proves each statement equal to Unicorn, and every whole-program gate (L5, L6) compares
# it with the oracle EXACTLY. The program around the float operations is the same text in both.
BASE="-std=c99 -ffp-contract=off -fno-strict-aliasing -fwrapv -fPIC -DJP8_RELOC -DJP8_FLAT -DJP8_GS_BASE=0x580000000ULL -I$R/jp8/src -I$R/lift"
GATE="-DJP8_SOFTFP=1 -DJP8_ORACLE_NAN"
# The lift compiles in NP parts (tools/lift/split_lift.py: the same definitions, external), PJ compilers at a time: one
# cc1 over the whole 2.3 M-statement file reached 14 GB and was killed (playbook 292); a part needs ~2.3 GB, ~1 min
NP=${JN_PARTS:-8}; PJ=${JN_JOBS:-3}
OBJ=""; OBJ_HW=""; k=0
while [ $k -lt "$NP" ]; do OBJ="$OBJ $OUT/lift_$k.o"; OBJ_HW="$OBJ_HW $OUT/lift_${k}_hw.o"; k=$((k + 1)); done
parts() {        # parts <suffix> <flags...>: every part of $OUT/split, PJ at a time; any failure fails the build
  sfx=$1; shift; pids=""; fail=0; k=0
  while [ $k -lt "$NP" ]; do
    cc $BASE "$@" -w -c "$OUT/split/lift_$k.c" -o "$OUT/lift_$k$sfx.o" & pids="$pids $!"
    k=$((k + 1))
    if [ $(echo $pids | wc -w) -ge "$PJ" ] || [ $k = "$NP" ]; then
      for p in $pids; do wait $p || fail=1; done; pids=""
    fi
  done
  [ $fail = 0 ] || { echo "jn_build: a part of the lift did not compile"; exit 1; }
}
if [ "${JN_KEEP_LIFT:-0}" != 1 ]; then
  rm -f "$OUT/jn_lift.stamp" $OBJ $OBJ_HW
  python3 "$R/tools/lift/split_lift.py" "$R/lift/jn_lift.c" "$OUT/split" "$NP"
  parts "" $GATE
  parts "_hw"
  sha256sum < "$R/lift/jn_lift.c" | cut -c1-64 > "$OUT/jn_lift.stamp"
else
  for o in $OBJ $OBJ_HW; do [ -f "$o" ] || { echo "jn_build: JN_KEEP_LIFT=1 but $o is missing"; exit 2; }; done
fi
cc $BASE $GATE -pedantic-errors -c "$R/jp8/src/jp8_rt.c" -o "$OUT/jn_rt.o"
cc $BASE $GATE -pedantic-errors -c "$R/lift/jn_host.c" -o "$OUT/jn_host.o"
cc $BASE -pedantic-errors -c "$R/jp8/src/jp8_rt.c" -o "$OUT/jn_rt_hw.o"
cc $BASE -pedantic-errors -c "$R/lift/jn_host.c" -o "$OUT/jn_host_hw.o"
cc -shared -o "$OUT/libjunohost.so" $OBJ "$OUT/jn_rt.o" "$OUT/jn_host.o" -lm
cc -shared -o "$OUT/libjunohost_hw.so" $OBJ_HW "$OUT/jn_rt_hw.o" "$OUT/jn_host_hw.o" -lm
echo "jn_build: OK -> $OUT/libjunohost.so (gate flavor), $OUT/libjunohost_hw.so (product flavor)"
