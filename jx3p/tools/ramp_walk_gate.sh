#!/bin/sh
# ramp_walk_gate.sh -- the RAMP WALKER gate (SCOPE_AUDIT row 2).
#
# Proves the product's sweep and slot tick (jx3p/gui/jx_bridge.c jxg_ramp_sweep /
# jxg_ramp_tick) agree with the plugin's own sub_1803F40E0 / sub_1803F4A40, byte
# for byte, over RANDOM SEEDED list shapes -- not over the factory bank.
#
# Why seeds and not patches: the walker is a CONTAINER algorithm. Its defects
# are a function of list shape (how many ramps retire, in what order), and its
# arithmetic defects are a function of value class (denormal, NaN, inf). The 64
# factory patches are ONE correlated sample of both. Seeds cover the space.
#
# SEEN TO FAIL, twice, before it was believed:
#   * without FTZ/DAZ on the port side: 110/200 cases (the real defect it found)
#   * with the retire-path cursor advanced: fails immediately
# and a third time (2026-10-15, playbook 259): two NaNs meeting in one add -- the plugin's addss keeps the FIRST
# operand's (READ: movss xmm0, [step]; addss xmm0, [acc]), GCC had swapped the port's operands: seed 5, case 110;
# --tooth-nan (the plain add back) must diverge. The oracle is Unicorn, whose two-NaN rule is x87's (the larger
# significand), not the CPU's (the first operand): it grades such a meeting only where both rules agree -- NaNs with
# random payloads in every case made ~6 % of the cases differ on the ORACLE side (row 24's class, playbook 259).
#
# usage: sh ramp_walk_gate.sh [--tooth | --tooth-nan] [n_cases=400] [seeds="1 2 3 4 5"]
set -e
HERE=$(cd "$(dirname "$0")" && pwd)
REPO=$(cd "$HERE/../.." && pwd)
WORK=${JX_WALK_WORK:-$(mktemp -d)}
mkdir -p "$WORK"
TOOTH=
if [ "${1:-}" = "--tooth" ]; then TOOTH=-DJX_RAMP_TOOTH=1; shift; fi   # the product's sweep with its cursor defect
NANT=
if [ "${1:-}" = "--tooth-nan" ]; then NANT=1; TOOTH=-DJX_RAMP_TOOTH=2; shift; fi   # the adds in the compiler's order
N=${1:-400}
SEEDS=${2:-"1 2 3 4 5"}

# the PRODUCT's sweep (jx3p/gui/jx_bridge.c), built as every product gate builds it (2026-10-11: the walk graded
# jx3p/src/jx_ramp.c, a transcription the product no longer built)
cc -std=c99 -O2 -fno-strict-aliasing -ffp-contract=off -shared -fPIC $TOOTH \
   -o "$WORK/libjxramp.so" \
   "$HERE/ramp_walk_shim.c" "$REPO/jx3p/gui/jx_bridge.c" \
   "$REPO/jx3p/src/jx_voice_render.c" "$REPO/jx3p/src/jx_voice_helpers.c" "$REPO/jx3p/src/jx_master_render.c" \
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

if [ -n "$NANT" ]; then           # the NaN tooth: some seed must diverge (two NaNs meet in some cases, not all)
  if [ "$fails" -gt 0 ]; then echo "[ramp walk gate] --tooth-nan: BITES ($fails seed(s))"; exit 0; fi
  echo "[ramp walk gate] --tooth-nan: DID NOT BITE"; exit 1
fi
if [ -n "$TOOTH" ]; then          # the tooth: every seed must diverge
  n=$(echo $SEEDS | wc -w)
  if [ "$fails" -eq "$n" ]; then echo "[ramp walk gate] --tooth: BITES ($fails of $n seeds)"; exit 0; fi
  echo "[ramp walk gate] --tooth: DID NOT BITE ($fails of $n seeds)"; exit 1
fi
if [ "$fails" -ne 0 ]; then
  echo "[ramp walk gate] FAIL -- $fails seed(s) diverged"; exit 1
fi
echo "[ramp walk gate] GREEN -- $N cases x $(echo $SEEDS | wc -w) seeds, EXACTLY 0"
