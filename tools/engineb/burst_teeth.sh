#!/bin/sh
# burst_teeth.sh -- plant each way the patch sequence could be wrong and
# require burst_gate.py to CATCH it.
#
# ⚠ TOOTH 1 IS THE DEFECT THAT WAS REALLY IN THE SHIPPING FIRMWARE, found by
# reading this machine AFTER the note machine had been gated. It is planted
# here so the class stays caught rather than the instance.
set -e
HERE=$(cd "$(dirname "$0")" && pwd)
REPO=$(dirname "$(dirname "$HERE")")
WORK="$REPO/build/burstteeth"
SRC="$REPO/engine_b/dev/eb_burststep.h"
rm -rf "$WORK"; mkdir -p "$WORK"
cp "$SRC" "$WORK/orig"
restore() { cp "$WORK/orig" "$SRC"; }
trap 'restore; rm -rf "$WORK"' EXIT INT TERM

tooth() {
    n=$1; script=$2; what=$3
    restore; sed -i "$script" "$SRC"
    if cmp -s "$SRC" "$WORK/orig"; then
        echo "TOOTH $n: *** THE PLANT DID NOT APPLY (playbook 55)."; exit 1; fi
    if python3 "$HERE/burst_gate.py" > "$WORK/out" 2>&1; then
        echo "TOOTH $n NOT CAUGHT ($what)"; sed 's/^/    /' "$WORK/out"; exit 1; fi
    echo "TOOTH $n caught: $what"
}

# 1. ⚑ THE REAL ONE. The machine goes IDLE at the same moment it asks for the
#    publish. A refused publish then strands the whole ~2.1 M-cycle build in
#    the shadow: the program change silently did nothing, and the next key
#    press copies the live bank over it and destroys the built patch.
tooth 1 \
  's/        b->st = BS_PUB;/        b->st = BS_IDLE;/' \
  'IDLE at the same moment it asks to publish (the patch is stranded)'

# 2. A stage skipped: install runs on the PREVIOUS patch's cells, so the record
#    is written over the wrong array. The build completes and the CRC is
#    computed over coefficients nobody asked for.
tooth 2 \
  's/        b->st = BS_INSTALL;  return 1;/        b->st = BS_RECALL;   return 1;/' \
  'the install stage is skipped -- the record lands on the old cells'

# 3. The coefficient build is never opened, so BS_COEFS steps a cursor that is
#    not running and the machine publishes the PREVIOUS shadow.
tooth 3 \
  's/        o->begin(u);//' \
  'the coefficient build is never opened'

# 4. The verify is dropped: a patch whose CRC disagrees with the host, or which
#    touched an unmapped cell, is published as if it were sound.
tooth 4 \
  's/        if (!o->verify(u)) { b->st = BS_IDLE; return -1; }/        if (0) { b->st = BS_IDLE; return -1; }/' \
  'the CRC and unmapped-cell verify is dropped'

# 5. A fatal stage leaves the machine mid-sequence rather than idle: the
#    instrument mutes AND keeps the interlock, so nothing can ever run again.
tooth 5 \
  's/        if (!o->reseed(u))  { b->st = BS_IDLE; return -1; }/        if (!o->reseed(u))  { return -1; }/' \
  'a fatal reseed leaves the interlock held for ever'

# 6. The publish retry is not counted -- rule 4.
tooth 6 \
  's/        ++b->pub_retry;/        \/* ++b->pub_retry; *\//' \
  'refused publishes are not counted (rule 4)'

# 7. The budget predicate lies: a working state called cheap, so the most
#    expensive step in the firmware (the reseed) skips the budget entirely.
tooth 7 \
  's/{ return b->st != BS_IDLE \&\& b->st != BS_PUB; }/{ return b->st == BS_COEFS; }/' \
  'the budget predicate calls the reseed cheap'

restore
echo
python3 "$HERE/burst_gate.py"
echo "BURST TEETH: seven caught, clean tree green."
