#!/bin/sh
# ramp_ab_gate.sh -- the JUNO RAMP gate (docs/GATE_PARITY.tsv row ramp_smoothing).
#
# src/juno_ramp.c was transcribed months ago and had NO differential gate. That
# was not a suspicion: `ramp_const` was a MUTATION SURVIVOR -- change a ramp
# constant, rebuild, and every gate in `make verify` stayed green. A survivor is
# a gate that must be written. This is that gate.
#
# It found FOUR real defects on its first run, none of which any existing gate
# could see (docs/RAMP_AB_FINDINGS.md):
#   1. juno_ramp_reset never cleared step_cnt
#   2/3/4. three unordered-compare mistranscriptions (playbook 81)
#
# SEEN TO FAIL: removing fix 1 alone drops the gate to 215/300.
#
# usage: sh ramp_ab_gate.sh [n_cases=300] [seeds="1 2 3"] [steps=24]
set -e
HERE=$(cd "$(dirname "$0")" && pwd)
REPO=$(cd "$HERE/../.." && pwd)
WORK=${JUNO_RAMP_WORK:-$(mktemp -d)}
mkdir -p "$WORK"
N=${1:-300}
SEEDS=${2:-"1 2 3"}
STEPS=${3:-24}

cc -O2 -fno-strict-aliasing -ffp-contract=off -shared -fPIC \
   -o "$WORK/libjr.so" \
   "$HERE/ramp_ab_shim.c" "$REPO/src/juno_ramp.c" "$REPO/src/juno_ftz.c" -lm

fails=0
for s in $SEEDS; do
  # two processes, never one (the two-process rule)
  python3 "$HERE/ramp_ab_emu.py" "$WORK/r$s.pkl" "$N" "$s" "$STEPS"
  if ! python3 "$HERE/ramp_ab_c.py" "$WORK/r$s.pkl" "$WORK/libjr.so"; then
    fails=$((fails+1))
  fi
  rm -f "$WORK/r$s.pkl"
done

if [ "$fails" -ne 0 ]; then
  echo "[juno ramp gate] FAIL -- $fails seed(s) diverged"; exit 1
fi
echo "[juno ramp gate] GREEN -- $N cases x $(echo $SEEDS | wc -w) seeds x $STEPS steps, EXACTLY 0"
