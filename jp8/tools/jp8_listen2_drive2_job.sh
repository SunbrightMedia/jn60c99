#!/bin/sh
# jp8_listen2_drive2_job.sh -- step-4 listen proof on DRIVE2 (S3_STATUS D7) for the reference patches at 44100, 2 at a time.
#   sh tools/run_job.sh jp8_listen2_drive2 sh jp8/tools/jp8_listen2_drive2_job.sh
set -u
cd "$(dirname "$0")/../.." || exit 1
export JP8_EMU_QUIET=1
unset JP8_EMU_LEGACY_HOST
mkdir -p jp8/logs/drive2
echo "2 10 52 63 0" | tr ' ' '\n' | xargs -P 2 -I{} sh -c 'python3 jp8/tools/jp8_listen2.py 44100 {} > jp8/logs/drive2/listen2_sr44100_p{}.log 2>&1; echo "patch {} exit $?"'
# exact names only (defect paid 2026-09-23: the glob p*.log also matched the archived *_run1_24k.log files and the
# job printed "GREEN: 4 / 5" when 3 of the 5 fresh logs were GREEN; the EXIT code was right, the count was not)
g=0; for p in 2 10 52 63 0; do grep -q "JP8 LISTEN sr 44100 patch $p: GREEN" jp8/logs/drive2/listen2_sr44100_p$p.log && g=$((g+1)); done
echo "GREEN: $g / 5"
[ "$g" = 5 ]
