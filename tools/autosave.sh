#!/bin/bash
# autosave.sh — commit and push whatever the running workflows have produced.
#
# WHY THIS EXISTS. Two workflows died returning nothing, and the only reason
# their work survived was that it happened to sit in scratchpad/ where it could
# be rescued by hand. scratchpad/ is gitignored, so a container restart would
# have destroyed 540 KB of measured oracle data including the 200,000-sample
# noise capture that later solved the LFSR exactly.
#
# Runs until killed. Every INTERVAL seconds:
#   1. mirror scratchpad/engineb data into docs/engineb/data (tracked)
#   2. commit anything new, clearly marked as an unattended autosave
#   3. push, tolerating a busy remote
# It never rebases, never force-pushes, and skips a cycle if another git
# process holds the lock, so it cannot fight an agent that is mid-commit.
set -u
cd /home/user/jn60c99 || exit 1
INTERVAL="${1:-300}"
BRANCH=claude/session-recap-j7evnx

while true; do
  sleep "$INTERVAL"

  # Never race an agent's own commit.
  [ -f .git/index.lock ] && continue

  # Rescue measured data out of the gitignored scratchpad.
  if [ -d scratchpad/engineb ]; then
    mkdir -p docs/engineb/data
    find scratchpad/engineb -maxdepth 1 -type f \
         \( -name '*.json' -o -name '*.npy' -o -name '*.npz' -o -name '*.tsv' \) \
         -exec cp -u {} docs/engineb/data/ \; 2>/dev/null
  fi

  git add -A >/dev/null 2>&1 || continue
  if git diff --cached --quiet 2>/dev/null; then
    continue                      # nothing new this cycle
  fi

  n=$(git diff --cached --name-only | wc -l)
  git commit -q -m "autosave: unattended workflow output ($n files)

Committed by tools/autosave.sh while workflows ran unattended. This is a
SNAPSHOT, not a reviewed change: the contents have not been gate-checked and
may be mid-edit. It exists so that a workflow dying returns nothing INSTEAD OF
destroying its work, which has already happened once in this project.

Co-Authored-By: Claude Opus 5 <noreply@anthropic.com>
Claude-Session: https://claude.ai/code/session_019dkoF3tvNYDygVXy9RBXJb" >/dev/null 2>&1 || continue

  for i in 1 2 3; do
    git push -q origin "$BRANCH" >/dev/null 2>&1 && break
    sleep $((i * 5))
  done
  echo "[autosave $(date '+%H:%M:%S')] committed $n files"
done
