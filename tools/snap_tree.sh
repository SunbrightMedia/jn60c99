#!/bin/sh
# snap_tree.sh -- freeze a COPY, not the tree. A long job runs from a snapshot
# worktree of the CURRENT working state (HEAD + every modified and untracked
# file), so edits in the main tree cannot reach it (CLAUDE.md freeze rule)
# and work goes on while the job runs. The snapshot shares scratchpad/ and
# bench/jobs/ with the main tree: its oracle pickles and its job registry are
# the main ones, and tools/status.sh sees the job.
# usage: sh tools/snap_tree.sh <dir>
#        sh <dir>/tools/run_job.sh <name> <command...>
set -eu
R=$(cd "$(dirname "$0")/.." && pwd)
W=${1:?usage: snap_tree.sh <dir>}
case "$W" in /*) ;; *) W=$(pwd)/$W ;; esac
[ "$W" != "$R" ] || { echo "refusing: <dir> is the main tree"; exit 2; }
git -C "$R" worktree remove --force "$W" 2>/dev/null || rm -rf "$W"
git -C "$R" worktree add --detach "$W" HEAD >/dev/null
cd "$R"
n=0
for f in $( { git diff --name-only HEAD; git ls-files --others --exclude-standard; } | sort -u); do
  case "$f" in scratchpad/*|bench/jobs/*) continue ;; esac
  if [ -e "$f" ]; then mkdir -p "$W/$(dirname "$f")"; cp -p "$f" "$W/$f"; else rm -f "$W/$f"; fi
  n=$((n + 1))
done
rm -rf "$W/scratchpad"; ln -s "$R/scratchpad" "$W/scratchpad"
mkdir -p "$W/bench"; rm -rf "$W/bench/jobs"; ln -s "$R/bench/jobs" "$W/bench/jobs"
echo "snapshot $W = $(git rev-parse --short HEAD) + $n working files"
