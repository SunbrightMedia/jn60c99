#!/bin/sh
# jn_rebuild.sh -- after a new L1 census or a lifter change: the build (jn_build.sh), the L2 check (no lifted trap on
# an executed instruction, with its self-test) -- the input of every later gate. Run it with tools/run_job.sh.
# usage: sh tools/lift/jn_rebuild.sh            (run from the repo root)
set -e
R=${REPO:-.}
sh "$R/tools/lift/jn_build.sh"
python3 "$R/tools/lift/check_reached.py"
if python3 "$R/tools/lift/check_reached.py" --self-test >/dev/null; then    # a planted trap MUST fail the check
  echo "L2 self-test DID NOT FAIL on a planted trap"; exit 1
fi
echo "L2 self-test: the planted reached trap is seen (the check fails on it)"
echo "jn_rebuild: GREEN"
