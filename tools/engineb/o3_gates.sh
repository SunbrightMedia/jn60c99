#!/bin/sh
# o3_gates.sh -- EVERY GATE O3 OWNS, in one command, teeth included.
#
# Same reasoning as o2_gates.sh: a gate nobody runs is a gate that does not
# exist, and a PARTIAL run is worse than none because it reads green while the
# half you skipped is the half that broke.
#
# ⚠ O2's GATES RUN FIRST AND THAT IS NOT POLITENESS. O3 extends
# eb_recall.c's chunk cursor -- the code O2's chunk gate holds -- and adds a
# third owner to the shadow O2's note and patch machines share. A change that
# breaks O2 breaks O3's foundation, and the O2 suite is where that shows.
#
# ⚠ WHAT IS NOT HERE, and must not be forgotten because the list looks full:
#   * the FIRMWARE has not been compiled for the target in this environment
#     (no ESP-IDF toolchain), let alone run.
#   * interlock_gate.c is a MODEL of the arbitration, not the firmware's own
#     lines. It proves the rules cannot deadlock; it cannot prove the firmware
#     transcribes them faithfully.
#   * playbook 63 is explicit: a candidate build is not a candidate until the
#     robot harness has PLAYED it. All-green here is permission to flash and
#     measure, never permission to believe.
#
# usage: sh tools/engineb/o3_gates.sh
set -e
HERE=$(cd "$(dirname "$0")" && pwd)
REPO=$(dirname "$(dirname "$HERE")")
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

# The foundation O3 stands on.
run "O2 suite (44 teeth)"          sh "$HERE/o2_gates.sh"

# O3 proper.
run "O3 param map + table (3 teeth)" python3 "$HERE/paramclass_gate.py"
run "O3 param sequence (4 teeth)"    sh "$HERE/param_teeth.sh"
run "O3 warm-vs-cold (3 teeth)"      sh "$HERE/paramwarm_teeth.sh"

# The composition. Playbook 63's lesson: the parts being right never says the
# instrument works.
printf '\n======== O3 three-machine interlock (3 teeth) ========\n'
mkdir -p "$REPO/build"
if cc -std=c99 -O1 -Wall -Wextra -Werror -I "$REPO/engine_b/dev" \
      -o "$REPO/build/interlock" "$HERE/devboot/interlock_gate.c"; then
    ok=1
    "$REPO/build/interlock" || ok=0
    for t in 1 2 3; do
        if "$REPO/build/interlock" "$t" >/dev/null 2>&1; then
            printf '   tooth %s NOT CAUGHT\n' "$t"; ok=0
        else
            printf '   tooth %s caught\n' "$t"
        fi
    done
    [ "$ok" -eq 1 ] || fails=$((fails + 1))
else
    printf '   *** interlock gate: BUILD FAILED\n'; fails=$((fails + 1))
fi

printf '\n========================================\n'
if [ "$fails" -eq 0 ]; then
    echo "O3 GATES: ALL GREEN, every tooth caught."
    echo "   Host-proven. NOT compiled for the target, NOT played by the robot."
else
    echo "O3 GATES: $fails RED. O3 is not done."
    exit 1
fi
