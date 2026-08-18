#!/bin/sh
# chunk_teeth.sh -- plant each way the chunked build could differ from the
# monolith and require chunk_gate.py to CATCH it.
#
# A gate that has never gone red is an untested detector -- playbook defect 1,
# the oldest rule in this project. This is what makes "CHUNK GATE: PASS" mean
# something.
#
# The plants go into COPIES under build/chunkteeth; engine_b is never edited.
set -e
HERE=$(cd "$(dirname "$0")" && pwd)
REPO=$(dirname "$(dirname "$HERE")")
WORK="$REPO/build/chunkteeth"
SRC="$REPO/engine_b/dev/eb_recall.c"
COEF="$REPO/engine_b/eb_coefs.c"

rm -rf "$WORK"; mkdir -p "$WORK"
cp "$SRC" "$WORK/eb_recall.c.orig"
cp "$COEF" "$WORK/eb_coefs.c.orig"
restore() { cp "$WORK/eb_recall.c.orig" "$SRC"; cp "$WORK/eb_coefs.c.orig" "$COEF"; }
trap 'restore; rm -rf "$WORK"' EXIT INT TERM

tooth() {                        # tooth <n> <file> <sed> <what>
    n=$1; file=$2; script=$3; what=$4
    restore
    sed -i "$script" "$file"
    if cmp -s "$file" "$WORK/$(basename "$file").orig"; then
        echo "TOOTH $n: *** THE PLANT DID NOT APPLY. A tooth that changes"
        echo "           nothing proves nothing (playbook 55)."
        exit 1
    fi
    if python3 "$HERE/chunk_gate.py" > "$WORK/out" 2>&1; then
        echo "TOOTH $n NOT CAUGHT ($what)"
        sed 's/^/    /' "$WORK/out"
        exit 1
    fi
    echo "TOOTH $n caught: $what"
}

# 1. THE ONE THAT MATTERS MOST: a voice silently skipped. A chunked build that
#    drops voice 7 sounds correct on any patch that does not use it.
tooth 1 "$SRC" \
  's/if (st <= EB_NUM_VOICES) {/if (st <= EB_NUM_VOICES \&\& st != EB_NUM_VOICES) {/' \
  'the chunked build skips one voice'

# 2. The shared tail dropped -- the exact field group whose absence the old
#    eb_coefs.h comment implied did not exist.
tooth 2 "$SRC" \
  's/eb_render_coefs_build_shared((const unsigned char \*)0, r->rc\[shadow\]);/(void)0;/' \
  'the shared FX/noise tail is never built'

# 3. The master build dropped.
tooth 3 "$SRC" \
  's/eb_master_coefs_build((const unsigned char \*)0, r->mc\[shadow\]);/(void)0;/' \
  'the master coefficients are never built'

# 4. The cursor stops one step early: every symptom of 3, plus a step count
#    that no longer matches what the firmware budgets blocks against.
# RETARGETED when chunk_step was rewritten for O2. The old plant edited a line
# that no longer exists, and the guard caught that rather than passing a tooth
# that changed nothing -- which is the whole reason the guard is there.
tooth 4 "$SRC" \
  's/    if (r->chunk_tail \&\& st <= EB_RECALL_CHUNK_STEPS) {/    if (r->chunk_tail \&\& st < EB_RECALL_CHUNK_STEPS) {/' \
  'the cursor terminates one step early (the master set is never built)'

# 5. The extraction itself regresses: the monolith stops calling the tail it
#    used to inline. Catches a bad merge of the eb_coefs.c split.
tooth 5 "$COEF" \
  's/^    eb_render_coefs_build_shared(base, c);$/    (void)0;/' \
  'the MONOLITH loses the shared tail (a bad merge of the split)'

# ---- O2: the NOTE build ------------------------------------------------
# 6. a note build that also runs the master set: 130,000 cycles nobody
#    budgeted, and invisible in a byte compare because the values are right.
tooth 6 "$SRC" \
  's/    r->chunk_tail = 0;             \/\* a note moves no FX and no master cell \*\//    r->chunk_tail = 1;/' \
  'a NOTE build also builds the shared tail and master set'

# 7. the shadow copy skipped: every voice the note did NOT name keeps whatever
#    was in the shadow -- the patch from two changes ago.
# ⚠ SCOPED TO THE CHUNKED FUNCTION. The unscoped version of this plant deleted
# the identical line from eb_recall_build_voices TOO -- so both sides of the
# comparison lost the copy, agreed with each other, and the gate passed. A
# plant that breaks the reference as well as the subject proves nothing, and it
# looks exactly like a blind gate. Range-address the function.
tooth 7 "$SRC" \
  '/eb_recall_chunk_begin_voices/,/^}/ s/    \*r->rc\[shadow\] = \*r->rc\[r->cur\];//' \
  'the note build skips the shadow copy'

# 8. the cursor spends an extra block discovering it is finished -- the exact
#    defect the step count caught on the first draft.
tooth 8 "$SRC" \
  's/    if (st <= EB_NUM_VOICES) { r->chunk_step = st; return 1; }/    if (st <= EB_NUM_VOICES + 1) { r->chunk_step = st; return 1; }/' \
  'the note cursor burns an extra block per build'

restore
echo
python3 "$HERE/chunk_gate.py"
echo "CHUNK TEETH: eight caught, clean tree green."
