#!/bin/sh
# fuzz_gate.sh -- the JX SEEDED FUZZ gate (docs/GATE_PARITY.tsv seeded_random_diff).
#
# The JUNO equivalent (tools/verify/fuzz_diff.py) has existed for months. The JX
# had none, and the FTZ/DAZ mode defect lived in that gap for the whole port.
# The seed is the regression script: a failure at seed N is replayable forever
# with  sh fuzz_gate.sh N $((N+1))
#
# Two processes, never one (the two-process rule): the Unicorn oracle writes
# reference blobs, then a separate ctypes process replays them.
#
# usage: sh fuzz_gate.sh [--tooth] [lo=0] [hi=24]
#   --tooth: the C engine built with JX_HELPER_TOOTH (one slip in a voice helper's polynomial every voice runs):
#   every seed must diverge (2026-10-11; the master's effect-LFO tooth was tried first: the factory patches the
#   seeds draw never reach those sites -- DID NOT BITE on 12 seeds)
set -e
HERE=$(cd "$(dirname "$0")" && pwd)
REPO=$(cd "$HERE/../.." && pwd)
WORK=${JX_FUZZ_WORK:-$(mktemp -d)}
mkdir -p "$WORK"
TOOTH=
if [ "${1:-}" = "--tooth" ]; then TOOTH=-DJX_HELPER_TOOTH=1; shift; fi
LO=${1:-0}
HI=${2:-24}

cc -O2 -fno-strict-aliasing -ffp-contract=off -shared -fPIC $TOOTH \
   -o "$WORK/libjxengine.so" \
   "$REPO/jx3p/src/jx_voice_render.c" "$REPO/jx3p/src/jx_voice_helpers.c" \
   "$REPO/jx3p/src/jx_master_render.c" "$REPO/jx3p/src/jx_ftz.c" -lm

fails=0
s=$LO
while [ "$s" -lt "$HI" ]; do
  rm -rf "$WORK/ab"
  python3 "$HERE/fuzz_emu.py" "$WORK/ab" "$s" "$((s+1))"
  n=$(python3 -c "import ast,sys;print(ast.literal_eval(open(sys.argv[1]).read())['n'])" \
        "$WORK/ab/s$s/p0/script.txt")
  if python3 "$HERE/ab_render_c.py" "$WORK/ab/s$s" "$WORK/libjxengine.so" "$n" \
       2>&1 | grep -q "1/1 patches EXACTLY 0"; then
    :
  else
    echo "  *** SEED $s DIVERGED -- replay: sh fuzz_gate.sh $s $((s+1))"
    cat "$WORK/ab/s$s/p0/script.txt"
    fails=$((fails+1))
  fi
  s=$((s+1))
done
rm -rf "$WORK/ab"

if [ -n "$TOOTH" ]; then
  if [ "$fails" -eq $((HI-LO)) ]; then echo "[jx fuzz gate] --tooth: BITES ($fails of $((HI-LO)) seeds diverged)"; exit 0; fi
  echo "[jx fuzz gate] --tooth: DID NOT BITE ($fails of $((HI-LO)) seeds diverged)"; exit 1
fi
if [ "$fails" -ne 0 ]; then
  echo "[jx fuzz gate] FAIL -- $fails seed(s) diverged"; exit 1
fi
echo "[jx fuzz gate] GREEN -- seeds $LO..$((HI-1)) EXACTLY 0"
