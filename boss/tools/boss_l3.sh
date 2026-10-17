#!/bin/sh
# boss_l3.sh -- L3 of the BOSS lift (boss/docs/LIFT_PLAN.md): the shared JUNO prover (tools/lift/l3_*) pointed at the
# BOSS image and lift by L3_BIN / L3_LIFT (no census yet: --all, every non-trap statement). Steps 1-2b of l3_gate.sh:
# each statement vs the REAL CPU running the plugin's own bytes, every state vs Unicorn; the gate flavor vs Unicorn.
# usage: sh boss/tools/boss_l3.sh <lift.c> <outdir> [nstates] [nrep] [--forms m1,m2] [--tooth K]   (repo root)
set -e
R=$(pwd); LIFTC=$1; B=$2; NS=${3:-16}; NR=${4:-256}; shift 4 2>/dev/null || shift $#
mkdir -p "$B"
export L3_BIN="$R/boss/truth/BOSS_Effects_Pedals.vst3" L3_LIFT="$LIFTC" L3_EXE="$B/none.json"
BASE="-std=c99 -ffp-contract=off -fno-strict-aliasing -fwrapv -fPIC -DJP8_RELOC -DJP8_FLAT -DJP8_GS_BASE=0x580000000ULL -I$R/jp8/src -I$R/tools/lift"
HB="-std=gnu99 -O2 -ffp-contract=off -fno-strict-aliasing -fwrapv -DJP8_RELOC -DJP8_FLAT -DJP8_GS_BASE=0x580000000ULL -I$R/jp8/src -I$R/tools/lift"
GATE="-DJP8_SOFTFP=1 -DJP8_ORACLE_NAN"
python3 "$R/tools/lift/l3_cases.py" --all --out "$B" "$@"
cc $BASE -w -c "$B/l3_cases.c" -o "$B/l3_cases.o" & cc $BASE $GATE -w -c "$B/l3_cases.c" -o "$B/l3_cases_gate.o" & wait
cc $HB -Wall -c "$R/tools/lift/l3_harness.c" -o "$B/l3_harness.o"
cc $HB $GATE -Wall -c "$R/tools/lift/l3_harness.c" -o "$B/l3_harness_gate.o"
cc -o "$B/l3_harness" "$B/l3_harness.o" "$B/l3_cases.o" -lz -lm
cc -o "$B/l3_harness_gate" "$B/l3_harness_gate.o" "$B/l3_cases_gate.o" -lz -lm
set +e
"$B/l3_harness" "$B/image.bin" "$B/pool.bin" "$NS" "$NR" 2>"$B/harness_err.txt" | \
    python3 "$R/tools/lift/l3_unicorn.py" --cases "$B/l3_cases.json" --out "$B/l3_report.json"; U=$?
tail -1 "$B/harness_err.txt"
lift=$(sed -n 's/.*lift != CPU in \([0-9]*\) states.*/\1/p' "$B/harness_err.txt" | tail -1)
"$B/l3_harness_gate" "$B/image.bin" "$B/pool.bin" "$NS" "$NR" --emit-lift 2>"$B/harness_gate_err.txt" | \
    python3 "$R/tools/lift/l3_unicorn.py" --cases "$B/l3_cases.json" --vs lift --out "$B/l3_report_gate.json"; G=$?
tail -1 "$B/harness_gate_err.txt"
[ "${lift:-x}" = 0 ] || { echo "BOSS L3 RED: lift != CPU in ${lift:-?} states"; exit 1; }
[ "$U" = 0 ] || { echo "BOSS L3 RED: Unicorn != CPU outside its known classes"; exit 1; }
[ "$G" = 0 ] || { echo "BOSS L3 RED: the gate flavor != Unicorn"; exit 1; }
echo "BOSS L3 GREEN"
