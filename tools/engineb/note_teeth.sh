#!/bin/sh
# note_teeth.sh -- plant each way the note sequence could be wrong and require
# note_gate.py to CATCH it.
#
# ⚠ TEETH 1 AND 2 ARE THE TWO DEFECTS THAT WERE REALLY IN THIS CODE, found by
# READING it rather than by any test. They are planted here so that finding
# them was not a one-off piece of luck: from now on the gate finds them.
set -e
HERE=$(cd "$(dirname "$0")" && pwd)
REPO=$(dirname "$(dirname "$HERE")")
WORK="$REPO/build/noteteeth"
SRC="$REPO/engine_b/dev/eb_notestep.h"

rm -rf "$WORK"; mkdir -p "$WORK"
cp "$SRC" "$WORK/eb_notestep.h.orig"
restore() { cp "$WORK/eb_notestep.h.orig" "$SRC"; }
trap 'restore; rm -rf "$WORK"' EXIT INT TERM

tooth() {
    n=$1; script=$2; what=$3
    restore
    sed -i "$script" "$SRC"
    if cmp -s "$SRC" "$WORK/eb_notestep.h.orig"; then
        echo "TOOTH $n: *** THE PLANT DID NOT APPLY (playbook 55)."; exit 1
    fi
    if python3 "$HERE/note_gate.py" > "$WORK/out" 2>&1; then
        echo "TOOTH $n NOT CAUGHT ($what)"; sed 's/^/    /' "$WORK/out"; exit 1
    fi
    echo "TOOTH $n caught: $what"
}

# 1. ⚑ THE REAL DEFECT #1. The machine advances past the publish on its own
#    instead of waiting for the caller to acknowledge one. A REFUSED publish
#    then lets the catch-up build copy over the shadow that still holds the
#    priority voice -- and that voice is not in the catch-up mask, so nothing
#    ever rebuilds it. The key sounds with the previous patch's coefficients
#    until some later note happens to name it. Silent, and audible only as
#    "one note sounds wrong sometimes".
tooth 1 \
  's/        if (!o->chunk_step(u)) { n->st = NB_PUB1; return 0; }/        if (!o->chunk_step(u)) { n->st = NB_REST_BEGIN; return 0; }/' \
  'the machine advances past a publish that never happened (stale voice)'

# 2. ⚑ THE REAL DEFECT #2, from the other side. The machine reports IDLE while
#    a build is still owed, so the caller draws new events -- and starts a
#    patch build -- over a shadow that has one owner.
tooth 2 \
  's/static int eb_nb_idle(const eb_nb \*n) { return n->st == NB_IDLE; }/static int eb_nb_idle(const eb_nb *n) { return n->st == NB_IDLE || n->st == NB_REST; }/' \
  'idle reported while a build is still owed (the shadow gets two owners)'

# 3. The priority stage skipped: the note still completes and every voice is
#    still built, so only the KEY LATENCY check can see this. Without that
#    check the split publish could be silently absent while the note sounded
#    correct -- 58 ms back, and every other number unchanged.
tooth 3 \
  's/        n->pri  = o->voiced(u) \& o->touched(u);/        n->pri  = 0u;/' \
  'the priority stage is skipped -- the key waits for the whole build again'

# 4. The catch-up mask overlaps the priority mask: voices built TWICE. Wasted
#    blocks, and a longer window where the shadow disagrees with the cells.
tooth 4 \
  's/        n->rest = o->touched(u) \& ~n->pri;/        n->rest = o->touched(u);/' \
  'the catch-up rebuilds the priority voices too (double work)'

# 5. The obligation is narrowed to the priority set: the other voices are
#    never built at all. This is the narrowing held_gate.py REFUSED, arriving
#    through the back door of the sequencer instead of the mask.
tooth 5 \
  's/        n->rest = o->touched(u) \& ~n->pri;/        n->rest = 0u;/' \
  'the catch-up is dropped -- seven voices never rebuilt'

# 6. The unmapped-cell check folded away: a note that wrote into a sink is
#    published as if it were fine, which is DEVICE_RECALL.md defect 2 with the
#    detector removed.
tooth 6 \
  's/        if (!o->check_ok(u)) { n->st = NB_IDLE; return -1; }/        if (0) { n->st = NB_IDLE; return -1; }/' \
  'an unmapped cell access is no longer reported'

# 7. A fatal event apply leaves a publish owed: the instrument mutes, and the
#    machine still holds the interlock, so nothing else can ever run.
tooth 7 \
  's/        if (!o->apply_events(u)) { n->st = NB_IDLE; return -1; }/        if (!o->apply_events(u)) { n->st = NB_PUB2; return -1; }/' \
  'a fatal event leaves a publish owed and the interlock held'

# 8. The publish retry is not counted -- rule 4. A publish quietly refused for
#    ever would show as a note that simply never arrived.
tooth 8 \
  's/        ++n->pub_retry;/        \/* ++n->pub_retry; *\//' \
  'refused publishes are not counted (rule 4)'

# 9. THE BUDGET PREDICATE LIES. NB_EVENTS opens a build with a ~20 KB shadow
#    copy; calling it cheap makes the first build of every note skip the
#    budget. This was a REAL defect, caught by check 8 the first time the gate
#    ever ran.
tooth 9 \
  's/    return n->st == NB_IDLE  || n->st == NB_EVENTS ||/    return/' \
  'the budget predicate calls a building state cheap'

restore
echo
python3 "$HERE/note_gate.py"
echo "NOTE TEETH: nine caught, clean tree green."
