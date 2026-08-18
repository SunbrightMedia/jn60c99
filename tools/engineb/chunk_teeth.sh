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
tooth 4 "$SRC" \
  's/if (st > EB_RECALL_CHUNK_STEPS) { r->chunk_step = 0; return 0; }/if (st >= EB_RECALL_CHUNK_STEPS) { r->chunk_step = 0; return 0; }/' \
  'the cursor terminates one step early'

# 5. The extraction itself regresses: the monolith stops calling the tail it
#    used to inline. Catches a bad merge of the eb_coefs.c split.
tooth 5 "$COEF" \
  's/^    eb_render_coefs_build_shared(base, c);$/    (void)0;/' \
  'the MONOLITH loses the shared tail (a bad merge of the split)'

restore
echo
python3 "$HERE/chunk_gate.py"
echo "CHUNK TEETH: five caught, clean tree green."
