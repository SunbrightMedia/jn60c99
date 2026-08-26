#!/bin/sh
# run_job.sh -- THE ONLY WAY LONG JOBS RUN (written after 2026-08-26, when two
# multi-hour gate runs died silently because they were tied to an interactive
# shell that later ran pkill/worktree cleanup; progress was then reported from
# their stale logs).
#
# Guarantees, each one mechanical, none dependent on anyone being careful:
#  1. DETACHED: setsid + </dev/null, so no shell exit, pkill of a parent, or
#     cleanup in the launching session can kill the job.
#  2. SELF-RECORDING: every job writes bench/jobs/<name>/ containing
#        cmd        the exact command line (restart is copy-paste)
#        pid        the process-group id
#        started    ISO timestamp
#        log        combined stdout+stderr, streamed
#        EXIT       written ONLY when the job ends, with the exit code.
#  3. VERDICT-OR-DEAD: a job with no EXIT file whose pid is gone DIED. The
#     status tool prints that in capital letters. There is no state in which a
#     dead job looks finished, and no state in which "done" lacks an exit code.
#
# usage: sh tools/run_job.sh <name> <command...>
#        sh tools/run_job.sh --list
set -u
cd "$(dirname "$0")/.." || exit 1
JOBS=bench/jobs
mkdir -p "$JOBS"

if [ "${1:-}" = "--list" ]; then
  for d in "$JOBS"/*/; do
    [ -d "$d" ] || continue
    n=$(basename "$d")
    pid=$(cat "$d/pid" 2>/dev/null)
    if [ -f "$d/EXIT" ]; then
      code=$(cat "$d/EXIT")
      [ "$code" = 0 ] && st="FINISHED ok" || st="FINISHED EXIT=$code"
    elif [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null; then
      st="RUNNING (pgid $pid)"
    else
      st="*** DIED WITHOUT VERDICT -- RESTART: sh tools/run_job.sh $n \$(cat $d/cmd) ***"
    fi
    printf "  %-24s started %s  %s\n" "$n" "$(cat "$d/started" 2>/dev/null)" "$st"
  done
  exit 0
fi

NAME=$1; shift
D="$JOBS/$NAME"
if [ -d "$D" ] && [ ! -f "$D/EXIT" ]; then
  pid=$(cat "$D/pid" 2>/dev/null)
  if [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null; then
    echo "job '$NAME' is already RUNNING (pgid $pid); refuse to double-start"
    exit 1
  fi
fi
rm -rf "$D"; mkdir -p "$D"
printf '%s\n' "$*" > "$D/cmd"
date -Is > "$D/started"
# the wrapper writes EXIT itself, so the verdict survives even if the launcher dies
setsid sh -c "( $* ) > '$D/log' 2>&1 < /dev/null; echo \$? > '$D/EXIT'" &
pid=$!
echo "$pid" > "$D/pid"
echo "started job '$NAME' (pgid $pid); log: $D/log"
