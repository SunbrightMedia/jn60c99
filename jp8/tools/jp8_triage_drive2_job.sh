#!/bin/sh
# jp8_triage_drive2_job.sh -- run jp8_drive2_triage.py for every line of a spec file, 2 at a time (shared 4-core box).
# spec line: <patch> <tag> [ENG=RAW ...]      log: jp8/logs/drive2/triage_p<patch>_<tag>.log
#   sh tools/run_job.sh jp8_triage_drive2 sh jp8/tools/jp8_triage_drive2_job.sh jp8/logs/drive2/triage_spec.txt
set -u
cd "$(dirname "$0")/../.." || exit 1
export JP8_EMU_QUIET=1
unset JP8_EMU_LEGACY_HOST
SPEC=$1
grep -v '^#' "$SPEC" | grep -v '^ *$' | xargs -P 2 -L 1 sh -c 'p=$0; t=$1; shift 1; python3 jp8/tools/jp8_drive2_triage.py $p "$@" tag=$t > jp8/logs/drive2/triage_p${p}_$t.log 2>&1; echo "patch $p $t exit $?"'
echo "TRIAGE verdicts:"
grep -v '^#' "$SPEC" | grep -v '^ *$' | while read p t rest; do grep -h "TRIAGE patch" jp8/logs/drive2/triage_p${p}_$t.log || echo "patch $p $t: NO VERDICT"; done
