#!/bin/sh
# o2_gates.sh -- EVERY GATE O2 OWNS, in one command, teeth included.
#
# There are five, they were written over three sessions, and remembering all
# five is not a plan. A gate nobody runs is a gate that does not exist, and a
# PARTIAL run is worse than none: it reads green while the half you skipped is
# the half that broke.
#
# Each entry runs the TEETH script, not just the gate, because a gate that has
# not been seen to fail is an untested detector (playbook 1) -- and twice in
# this track a tooth went uncaught and found a hole in the gate rather than in
# the code (playbook 60, and the scheduler's own reset check).
#
# usage: sh tools/engineb/o2_gates.sh
set -e
HERE=$(cd "$(dirname "$0")" && pwd)
fails=0

run() {
    name=$1; shift
    printf '\n======== %s ========\n' "$name"
    if "$@"; then
        printf '   %s: GREEN\n' "$name"
    else
        printf '   *** %s: RED\n' "$name"
        fails=$((fails + 1))
    fi
}

# O1's boundary -- O2 lives behind it, so a break here invalidates O2's inputs.
run "O1 event queue (7 teeth)"   sh   "$HERE/../../event/teeth.sh"
run "O1 boundary   (3 teeth)"    sh   "$HERE/boundary_teeth.sh"
# O2 proper.
run "O2 chunk+split (11 teeth)"  sh   "$HERE/chunk_teeth.sh"
run "O2 burst budget (7 teeth)"  sh   "$HERE/sched_teeth.sh"
# The narrowing that is REFUSED and must stay refused: this gate is green only
# because the narrowing is off. It is here so nobody enables it unnoticed.
run "held (narrowing OFF)"       python3 "$HERE/held_gate.py"

printf '\n========================================\n'
if [ "$fails" -eq 0 ]; then
    echo "O2 GATES: ALL GREEN, every tooth caught."
else
    echo "O2 GATES: $fails RED. O2 is not done."
    exit 1
fi
