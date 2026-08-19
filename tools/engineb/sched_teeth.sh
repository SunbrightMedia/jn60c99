#!/bin/sh
# sched_teeth.sh -- plant each way the burst budget could be wrong and require
# sched_gate.py to CATCH it.
#
# The budget decides whether incremental work runs in an audio block. Every way
# it can be wrong is either a missed deadline or a change that never arrives --
# THE INVARIANT rules 2 and 3. A gate for it that has never gone red is worth
# nothing, which is how the budget shipped in the first place.
set -e
HERE=$(cd "$(dirname "$0")" && pwd)
REPO=$(dirname "$(dirname "$HERE")")
WORK="$REPO/build/schedteeth"
SRC="$REPO/engine_b/dev/eb_sched.h"

rm -rf "$WORK"; mkdir -p "$WORK"
cp "$SRC" "$WORK/eb_sched.h.orig"
restore() { cp "$WORK/eb_sched.h.orig" "$SRC"; }
trap 'restore; rm -rf "$WORK"' EXIT INT TERM

tooth() {
    n=$1; script=$2; what=$3
    restore
    sed -i "$script" "$SRC"
    if cmp -s "$SRC" "$WORK/eb_sched.h.orig"; then
        echo "TOOTH $n: *** THE PLANT DID NOT APPLY. A tooth that changes"
        echo "           nothing proves nothing (playbook 55)."
        exit 1
    fi
    if python3 "$HERE/sched_gate.py" > "$WORK/out" 2>&1; then
        echo "TOOTH $n NOT CAUGHT ($what)"
        sed 's/^/    /' "$WORK/out"
        exit 1
    fi
    echo "TOOTH $n caught: $what"
}

# 1. THE ONE THAT MATTERS MOST: no starvation bound. On an instrument whose
#    steady-state cost exceeds the period, slack never appears and EVERY step
#    is deferred for ever. The key is pressed and never sounds. "The change
#    arrives later" silently becomes "never" -- the invariant broken rather
#    than degraded, and nothing in the audio would reveal it.
tooth 1 \
  's/    if (++s->starve >= s->starve_max) {/    if (0) {/' \
  'no starvation bound -- an over-budget instrument NEVER runs a step'

# 2. The boundary: a step costing exactly the slack refused. Halves the burst
#    rate on any instrument sitting right at its budget, which is where this
#    one sits, and looks like nothing at all.
tooth 2 \
  's/    if (worst <= s->slack) { s->starve = 0ul; return 1; }/    if (worst < s->slack) { s->starve = 0ul; return 1; }/' \
  'a step costing EXACTLY the slack is refused (off-by-one)'

# 3. The refusal is not counted -- rule 4's whole subject. A system that copes
#    quietly cannot be proven to cope, and this is the counter that says how
#    hard it is coping.
tooth 3 \
  's/    ++s->n_defer;/    \/* ++s->n_defer; *\//' \
  'a deferral is not counted (rule 4: no silent failure)'

# 4. Forced steps counted as ordinary deferrals. These mean OPPOSITE things:
#    defer is the budget working, forced is the budget admitting it never
#    found room. Merging them hides a steady-state overrun inside a healthy-
#    looking number.
tooth 4 \
  's/        ++s->n_forced;/        ++s->n_defer;/' \
  'forced steps counted as deferrals -- an overrun hidden in a healthy number'

# 5. THE SELF-STARVATION DEFECT. The starve counter is never reset on a step
#    that fits, so a single earlier refusal is remembered for ever and the
#    scheduler forces on a healthy instrument.
tooth 5 \
  's/    if (worst <= s->slack) { s->starve = 0ul; return 1; }/    if (worst <= s->slack) { return 1; }/' \
  'the starve counter is never reset -- a healthy instrument forces anyway'

# 6. The bootstrap hole inverted: refuse when nothing has been measured. The
#    firmware then waits for a measurement only running work can produce, and
#    no note is ever built. Silent, total, and it would pass any test that
#    pre-seeded the numbers.
tooth 6 \
  's/    if (s->slack == 0ul || worst == 0ul) return 1;/    if (s->slack == 0ul || worst == 0ul) return 0;/' \
  'work refused before anything is measured -- nothing ever runs'

# 7. starve_max of zero accepted, which forces EVERY step: the budget removed
#    entirely while still appearing to be present.
tooth 7 \
  's/    s->starve_max = starve_max < 2ul ? 2ul : starve_max;/    s->starve_max = starve_max;/' \
  'starve_max 0 accepted -- every step forced, the budget gone'

restore
echo
python3 "$HERE/sched_gate.py"
echo "SCHED TEETH: seven caught, clean tree green."
