#!/bin/sh
# ramp_walk_gate.sh -- the RAMP WALKER gate (SCOPE_AUDIT row 2).
#
# Proves the ported walker (jx_ramp_walk) and stepper (jx_ramp_step) agree with
# the plugin's own sub_1803F40E0 / sub_1803F4A40, byte for byte, over RANDOM
# SEEDED list shapes -- not over the factory bank.
#
# Why seeds and not patches: the walker is a CONTAINER algorithm. Its defects
# are a function of list shape (how many ramps retire, in what order), and its
# arithmetic defects are a function of value class (denormal, NaN, inf). The 64
# factory patches are ONE correlated sample of both. Seeds cover the space.
#
# SEEN TO FAIL, twice, before it was believed:
#   * without FTZ/DAZ on the port side: 110/200 cases (the real defect it found)
#   * with the retire-path cursor advanced: fails immediately
#
# usage: sh ramp_walk_gate.sh [n_cases=400] [seeds="1 2 3 4 5"]
set -e
HERE=$(cd "$(dirname "$0")" && pwd)
REPO=$(cd "$HERE/../.." && pwd)
WORK=${JX_WALK_WORK:-$(mktemp -d)}
mkdir -p "$WORK"
N=${1:-400}
SEEDS=${2:-"1 2 3 4 5"}

cc -O2 -fno-strict-aliasing -ffp-contract=off -shared -fPIC \
   -o "$WORK/libjxramp.so" \
   "$HERE/ramp_walk_shim.c" "$REPO/jx3p/src/jx_ramp.c" \
   "$REPO/jx3p/src/jx_ftz.c" -lm

fails=0
for s in $SEEDS; do
  # two processes, never one: Unicorn build and ctypes load may not share a
  # process (the two-process rule). They meet only through the pickle.
  python3 "$HERE/ramp_walk_emu.py" "$WORK/c$s.pkl" "$N" "$s"
  if ! python3 "$HERE/ramp_walk_c.py" "$WORK/c$s.pkl" "$WORK/libjxramp.so"; then
    fails=$((fails+1))
  fi
  rm -f "$WORK/c$s.pkl"
done

if [ "$fails" -ne 0 ]; then
  echo "[ramp walk gate] FAIL -- $fails seed(s) diverged"; exit 1
fi
echo "[ramp walk gate] GREEN -- $N cases x $(echo $SEEDS | wc -w) seeds, EXACTLY 0"
