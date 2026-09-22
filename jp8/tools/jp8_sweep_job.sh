#!/bin/sh
# jp8_sweep_job.sh -- the 64-patch listen sweep at 44100 as ONE run_job: 3 patches at a time (4-core box), one log per
# patch in jp8/logs/sweep44100/, then the collector writes jp8/docs/SWEEP_44100.md. Exit 0 only when all 64 ROW lines exist.
#   sh tools/run_job.sh jp8_sweep44100 sh jp8/tools/jp8_sweep_job.sh
set -u
cd "$(dirname "$0")/../.." || exit 1
export JP8_EMU_QUIET=1
seq 0 63 | xargs -P 3 -I{} sh -c 'python3 jp8/tools/jp8_sweep.py {} > /dev/null 2>&1; echo "patch {} exit $?"'
python3 jp8/tools/jp8_sweep_collect.py
n=$(grep -l "] ROW " jp8/logs/sweep44100/p*.log 2>/dev/null | wc -l)
echo "ROW lines: $n / 64"
[ "$n" = 64 ]
