#!/bin/sh
# waitfor.sh -- wait for a long job WITHOUT the two ways it went wrong (playbook 50).
#
#   waitfor.sh <logfile> <sentinel-regex> [deadline-seconds]
#
# 1. CHECKS FIRST. If the sentinel is already in the log, it returns at once.
#    Both six-hour losses on 2026-08-16 were waits on work that had finished
#    or was already known dead.
# 2. NEVER matches itself. It watches the LOG, not a process-name pattern.
#    `pgrep -f "make verify"` inside a shell whose command line contains
#    "make verify" always matches, and the loop cannot end.
# 3. REFUSES to wait forever. Default deadline 1800s, then it reports the log's
#    last-modified age so a stalled job is distinguishable from a slow one.
set -eu
log=${1:?usage: waitfor.sh <logfile> <sentinel-regex> [deadline-seconds]}
pat=${2:?missing sentinel regex}
deadline=${3:-1800}
i=0
while :; do
    if [ -f "$log" ] && grep -qE "$pat" "$log" 2>/dev/null; then
        echo "waitfor: sentinel found after ${i}s"; exit 0
    fi
    if [ "$i" -ge "$deadline" ]; then
        age="n/a"
        [ -f "$log" ] && age=$(( $(date +%s) - $(stat -c %Y "$log") ))
        echo "waitfor: DEADLINE ${deadline}s reached; log last changed ${age}s ago"
        echo "waitfor: if that age keeps growing the job is STALLED, not slow."
        exit 2
    fi
    sleep 10; i=$((i+10))
done
