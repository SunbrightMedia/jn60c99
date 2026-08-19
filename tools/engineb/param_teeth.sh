#!/bin/sh
# param_teeth.sh -- plant each way O3's parameter sequence could be wrong and
# require param_gate.py to CATCH it.
#
# The note machine and the patch machine both SHIPPED with the hand-over
# defect and both were found by reading (playbook 62). Teeth 1 and 2 plant
# that exact defect into the third machine, so it can never ship there.
#
# Plants go into a COPY under build/paramteeth; engine_b is restored on exit.
set -e
HERE=$(cd "$(dirname "$0")" && pwd)
REPO=$(dirname "$(dirname "$HERE")")
WORK="$REPO/build/paramteeth"
SRC="$REPO/engine_b/dev/eb_paramstep.h"

rm -rf "$WORK"; mkdir -p "$WORK"
cp "$SRC" "$WORK/orig"
restore() { cp "$WORK/orig" "$SRC"; }
trap 'restore; rm -rf "$WORK"' EXIT INT TERM

tooth() {                        # tooth <n> <sed> <what>
    n=$1; script=$2; what=$3
    restore
    sed -i "$script" "$SRC"
    if cmp -s "$SRC" "$WORK/orig"; then
        echo "TOOTH $n: *** THE PLANT DID NOT APPLY. A tooth that changes"
        echo "           nothing proves nothing (playbook 55)."
        exit 1
    fi
    if python3 "$HERE/param_gate.py" > "$WORK/out" 2>&1; then
        echo "TOOTH $n NOT CAUGHT ($what)"
        sed 's/^/    /' "$WORK/out"
        exit 1
    fi
    echo "TOOTH $n caught: $what"
}

echo "=================================================================="
echo "PARAM TEETH"
echo "=================================================================="

# 1. ⚠ THE ONE THIS MACHINE EXISTS TO NEVER HAVE. PM_CHECK goes IDLE and asks
#    for the publish in one step. If that publish is refused the whole build is
#    stranded in the shadow: the knob move silently did nothing, and the next
#    note build copies the live bank over it. This is verbatim the defect the
#    note machine and the patch machine each shipped with.
tooth 1 \
  '/case PM_CHECK:/,/return 0;/ s/^        m->st = PM_PUB;$/        m->st = PM_IDLE;/' \
  'PM_CHECK goes IDLE before the publish is taken (the stranded build)'

# 2. published() advances unconditionally, so a REFUSED publish still moves the
#    machine on. Same loss, reached from the caller side instead.
tooth 2 \
  's/{ if (m->st == PM_PUB) m->st = PM_IDLE; }/{ m->st = PM_IDLE; }/' \
  'published() advances even when the publish was refused'

# 3. THE BUDGET LIES ABOUT PM_APPLY. It looks like two byte writes; it is the
#    ~0.24 M-cycle warm recall, the biggest single step this machine takes.
#    Calling it cheap lets the largest step escape the budget entirely -- the
#    mistake eb_notestep.h's NB_EVENTS made and its comment records.
tooth 3 \
  's/{ return m->st == PM_APPLY || m->st == PM_COEFS; }/{ return m->st == PM_COEFS; }/' \
  'the budget calls PM_APPLY cheap -- the warm recall escapes it'

# 4. AN EMPTY CLASS IS DROPPED. A parameter whose class opens no builder goes
#    idle without publishing, so the edit vanishes with no error. The one
#    outcome never allowed (playbook 32: a boundary that accepts a parameter
#    and does nothing is a knob that is not a knob).
tooth 4 \
  's/        m->st = o->busy(u) ? PM_COEFS : PM_CHECK;/        if (!o->busy(u)) { m->st = PM_IDLE; return 1; }\n        m->st = PM_COEFS;/' \
  'an empty class goes idle without publishing -- the edit is dropped'

restore
echo "------------------------------------------------------------------"
python3 "$HERE/param_gate.py"
echo "PARAM TEETH: four caught, clean tree green."
