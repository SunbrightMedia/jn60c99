#!/bin/sh
# jp8_sweep_drive2_job.sh -- the 64-patch listen sweep at 44100 on DRIVE2 (S3_STATUS D7) as ONE run_job, run from a FROZEN
# COPY of jp8/ (build/snapSweep2/jp8) so edits in the repo cannot touch it (PORT_LESSONS 11). 2 patches at a time (the
# 4-core box is shared). Logs: jp8/logs/sweep44100_drive2/pNN.log in the REPO; then the copy's collector writes
# jp8/docs/SWEEP_44100_DRIVE2.md in the repo. Exit 0 only when all 64 ROW lines exist.
#   rm -rf build/snapSweep2 && mkdir -p build/snapSweep2 && cp -a jp8 build/snapSweep2/jp8
#   sh tools/run_job.sh jp8_sweep_drive2 sh build/snapSweep2/jp8/tools/jp8_sweep_drive2_job.sh
set -u
HERE=$(cd "$(dirname "$0")" && pwd)
REPO=/home/user/jn60c99
OUT=$REPO/jp8/logs/sweep44100_drive2
mkdir -p "$OUT"
export JP8_EMU_QUIET=1
unset JP8_EMU_LEGACY_HOST
echo "sweep code: $HERE (sha256 of jp8_emu.py $(sha256sum "$HERE/jp8_emu.py" | cut -c1-16), jp8_sweep.py $(sha256sum "$HERE/jp8_sweep.py" | cut -c1-16))"
seq 0 63 | xargs -P 2 -I{} sh -c "python3 '$HERE/jp8_sweep.py' {} '$OUT' > /dev/null 2>&1; echo \"patch {} exit \$?\""
python3 "$HERE/jp8_sweep_collect.py" "$OUT" "$REPO/jp8/docs/SWEEP_44100_DRIVE2.md" drive2
n=$(grep -l "] ROW " "$OUT"/p*.log 2>/dev/null | wc -l)
echo "ROW lines: $n / 64"
[ "$n" = 64 ]
