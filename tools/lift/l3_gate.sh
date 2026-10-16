#!/bin/sh
# l3_gate.sh -- L3 of the JUNO lift (docs/JUNO_LIFT.md): the lifter proven instruction by instruction.
#  1. l3_cases.py: every SHIPPED statement of lift/jn_lift.c whose rva the L1 census executed (--all: every non-trap
#     statement), with its form and state constraints -> build/l3/l3_cases.c (the product's own build flags)
#  2. l3_harness: each statement against the REAL CPU running the plugin's own bytes for one step, from the same
#     state (edge + random registers, flags, XMM, MXCSR, memory); its stream -> l3_unicorn.py: the same states through
#     Unicorn (two processes). PASS = lift != CPU in 0 states (MXCSR's sticky exception flags excepted: not held by the
#     lift or the oracle; they reach only dead stack slots, docs/JUNO_LIFT.md) AND Unicorn != CPU only inside its known
#     classes (unflushed denormals, the NaN of two NaN operands, bsf of zero)
#  3. l3_flags.py: no lifted code reads a flag x86 leaves undefined (or AF): 0 violations; its tooth bites
#  4. l3_teeth.sh: four planted wrong semantics, the Unicorn tooth and the CPU-against-itself control
# usage: sh tools/lift/l3_gate.sh [nstates] [nrep] [--all]      (run from the repo root; ~10 min at 16 / 256)
set -e
R=$(pwd); B=$R/build/l3; mkdir -p "$B"
NS=${1:-16}; NR=${2:-256}; ALL=${3:-}
BASE="-std=c99 -ffp-contract=off -fno-strict-aliasing -fwrapv -fPIC -DJP8_RELOC -DJP8_FLAT -DJP8_GS_BASE=0x580000000ULL -I$R/jp8/src -I$R/lift -I$R/tools/lift"
HB="-std=gnu99 -O2 -ffp-contract=off -fno-strict-aliasing -fwrapv -DJP8_RELOC -DJP8_FLAT -DJP8_GS_BASE=0x580000000ULL -I$R/jp8/src -I$R/tools/lift"
echo "[L3 1/4] the work list"
python3 "$R/tools/lift/l3_cases.py" $ALL --out "$B"
cc $BASE -w -c "$B/l3_cases.c" -o "$B/l3_cases.o"
cc $HB -Wall -c "$R/tools/lift/l3_harness.c" -o "$B/l3_harness.o"
cc -o "$B/l3_harness" "$B/l3_harness.o" "$B/l3_cases.o" -lz -lm
echo "[L3 2/4] every statement vs the CPU, every state vs Unicorn"
set +e
"$B/l3_harness" "$B/image.bin" "$B/pool.bin" "$NS" "$NR" 2>"$B/harness_err.txt" | \
    python3 "$R/tools/lift/l3_unicorn.py" --cases "$B/l3_cases.json" --out "$B/l3_report.json"
U=$?
set -e
tail -1 "$B/harness_err.txt"
lift=$(sed -n 's/.*lift != CPU in \([0-9]*\) states.*/\1/p' "$B/harness_err.txt" | tail -1)
[ "${lift:-x}" = 0 ] || { echo "L3 RED: the lift differs from the CPU (build/l3/harness_err.txt)"; exit 1; }
[ "$U" = 0 ] || { echo "L3 RED: Unicorn differs from the CPU outside its known classes (build/l3/l3_report.json)"; exit 1; }
echo "[L3 3/4] no read of an undefined flag"
python3 "$R/tools/lift/l3_flags.py"
python3 "$R/tools/lift/l3_flags.py" --tooth | tail -1
echo "[L3 4/4] teeth"
sh "$R/tools/lift/l3_teeth.sh"
echo "L3 GREEN: every statement equal to the CPU in every state; Unicorn's differences all known; no undefined flag read; teeth bite"
