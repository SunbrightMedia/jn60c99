#!/bin/sh
# l3_all.sh -- L3 over EVERY shipped statement of lift/jn_lift.c (playbook 288: a proof over "what ran" misses what
# runs next), in N chunks: each chunk's statements against the CPU (product flavor) and against Unicorn (gate
# flavor), as tools/lift/l3_gate.sh does for the executed ones. Statements the harness cannot place (an absolute
# address, a divide whose divisor is rax / rdx) are NAMED in each chunk's l3_cases.json ("skipped") and counted.
# usage: sh tools/lift/l3_all.sh [chunks] [nstates] [nrep]   (run from the repo root, with tools/run_job.sh; ~2 h)
set -e
R=$(pwd); N=${1:-8}; NS=${2:-4}; NR=${3:-64}
BASE="-std=c99 -ffp-contract=off -fno-strict-aliasing -fwrapv -fPIC -DJP8_RELOC -DJP8_FLAT -DJP8_GS_BASE=0x580000000ULL -I$R/jp8/src -I$R/lift -I$R/tools/lift"
HB="-std=gnu99 -O2 -ffp-contract=off -fno-strict-aliasing -fwrapv -DJP8_RELOC -DJP8_FLAT -DJP8_GS_BASE=0x580000000ULL -I$R/jp8/src -I$R/tools/lift"
GATE="-DJP8_SOFTFP=1 -DJP8_ORACLE_NAN"
cc $HB -Wall -c "$R/tools/lift/l3_harness.c" -o "$R/build/l3_harness_hw.o"
cc $HB $GATE -Wall -c "$R/tools/lift/l3_harness.c" -o "$R/build/l3_harness_gate.o"
fail=0; i=0
while [ $i -lt "$N" ]; do
  B=$R/build/l3all/c$i; mkdir -p "$B"
  python3 "$R/tools/lift/l3_cases.py" --all --chunk "$i/$N" --out "$B"
  cc $BASE -w -c "$B/l3_cases.c" -o "$B/hw.o" &
  cc $BASE $GATE -w -c "$B/l3_cases.c" -o "$B/gate.o" &
  wait
  cc -o "$B/h_hw" "$R/build/l3_harness_hw.o" "$B/hw.o" -lz -lm
  cc -o "$B/h_gate" "$R/build/l3_harness_gate.o" "$B/gate.o" -lz -lm
  rm -f "$B/l3_cases.c" "$B/hw.o" "$B/gate.o"
  set +e
  "$B/h_hw" "$B/image.bin" "$B/pool.bin" "$NS" "$NR" 2>"$B/hw_err.txt" | \
      python3 "$R/tools/lift/l3_unicorn.py" --cases "$B/l3_cases.json" --out "$B/report_hw.json" > "$B/hw_uni.txt"
  U1=$?
  "$B/h_gate" "$B/image.bin" "$B/pool.bin" "$NS" "$NR" --emit-lift 2>"$B/gate_err.txt" | \
      python3 "$R/tools/lift/l3_unicorn.py" --cases "$B/l3_cases.json" --vs lift --out "$B/report_gate.json" > "$B/gate_uni.txt"
  U2=$?
  set -e
  lift=$(sed -n 's/.*lift != CPU in \([0-9]*\) states.*/\1/p' "$B/hw_err.txt" | tail -1)
  echo "chunk $i/$N: $(tail -1 "$B/hw_err.txt" | cut -c1-160)"
  echo "chunk $i/$N: $(tail -1 "$B/hw_uni.txt" | cut -c1-200)"
  echo "chunk $i/$N: $(tail -1 "$B/gate_uni.txt" | cut -c1-200)"
  [ "${lift:-x}" = 0 ] && [ "$U1" = 0 ] && [ "$U2" = 0 ] || { echo "chunk $i/$N RED"; fail=1; }
  rm -f "$B/h_hw" "$B/h_gate" "$B/image.bin" "$B/pool.bin"
  i=$((i + 1))
done
[ $fail = 0 ] && echo "L3 ALL GREEN: every shipped statement equal to the CPU (product) and to Unicorn (gate)" || { echo "L3 ALL RED"; exit 1; }
