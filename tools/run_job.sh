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
# A job NAME is used once. Never delete a job's directory while its wrapper may
# live: the old wrapper then writes its EXIT into a new job of the same name, and
# that job looks finished while it runs (paid 2026-10-10: a throwaway job and a
# real one shared a name; the real export showed EXIT 2 at its patch 3).
# The command is re-parsed by sh as `( $* )`: quotes are LOST. Put a compound
# command in a script file and run that, never `sh -c '...'` (playbook 118).
set -u
cd "$(dirname "$0")/.." || exit 1
JOBS=bench/jobs
mkdir -p "$JOBS"

# _age <file> -- how long the job ran, from its last heartbeat vs its start.
_age() {
  b=$1; s=$(dirname "$b")/started
  [ -f "$b" ] || { echo "no heartbeat"; return; }
  t0=$(date -d "$(cat "$s")" +%s 2>/dev/null) || { echo "?"; return; }
  t1=$(date -r "$b" +%s 2>/dev/null) || { echo "?"; return; }
  echo "$(( (t1 - t0) / 60 ))m"
}

# _alive <dir> -- the job's process group is alive AND its heartbeat is fresh.
# A pid alone lies after a container restart: the kernel hands the old number
# to a new process, and a job that died in the restart looked RUNNING (paid
# 2026-10-06: verify_5efc6d5_r2 "alive" on a pid that was another job's make).
# The wrapper touches beat every 20 s, so a beat older than 90 s is a dead job.
_alive() {
  p=$(cat "$1/pid" 2>/dev/null)
  [ -n "$p" ] && kill -0 "$p" 2>/dev/null || return 1
  if [ -f "$1/beat" ]; then t=$(date -r "$1/beat" +%s 2>/dev/null) || return 1
  else t=$(date -d "$(cat "$1/started" 2>/dev/null)" +%s 2>/dev/null) || return 1; fi
  [ $(( $(date +%s) - t )) -le 90 ]
}

if [ "${1:-}" = "--list" ]; then
  for d in "$JOBS"/*/; do
    [ -d "$d" ] || continue
    n=$(basename "$d")
    pid=$(cat "$d/pid" 2>/dev/null)
    if [ -f "$d/EXIT" ]; then
      code=$(cat "$d/EXIT")
      [ "$code" = 0 ] && st="FINISHED ok" || st="FINISHED EXIT=$code"
    elif _alive "$d"; then
      st="RUNNING (pgid $pid, alive $(_age "$d/beat"))"
    else
      # A killed job (OOM, SIGKILL) writes no EXIT. The heartbeat says WHEN it
      # stopped, which separates "died at once" from "died hours in".
      st="*** DIED WITHOUT VERDICT after $(_age "$d/beat") -- RESTART: sh tools/run_job.sh $n \$(cat $d/cmd) ***"
    fi
    printf "  %-24s started %s  %s\n" "$n" "$(cat "$d/started" 2>/dev/null)" "$st"
  done
  exit 0
fi

NAME=$1; shift
D="$JOBS/$NAME"
if [ -d "$D" ] && [ ! -f "$D/EXIT" ]; then
  pid=$(cat "$D/pid" 2>/dev/null)
  if _alive "$D"; then
    echo "job '$NAME' is already RUNNING (pgid $pid); refuse to double-start"
    exit 1
  fi
fi
rm -rf "$D"; mkdir -p "$D"
printf '%s\n' "$*" > "$D/cmd"
date -Is > "$D/started"
# the wrapper writes EXIT itself, so the verdict survives even if the launcher dies
setsid sh -c "( $* ) > '$D/log' 2>&1 < /dev/null & w=\$!;
  while kill -0 \$w 2>/dev/null; do touch '$D/beat'; sleep 20; done;
  wait \$w; echo \$? > '$D/EXIT'" &
pid=$!
echo "$pid" > "$D/pid"
echo "started job '$NAME' (pgid $pid); log: $D/log"
