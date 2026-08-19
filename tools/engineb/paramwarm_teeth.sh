#!/bin/sh
# paramwarm_teeth.sh -- prove the warm-vs-cold gate can go RED.
#
# The gate says: "the order-dependent set is EXACTLY these four records".
# Three teeth attack that claim from three sides. A tooth that does not fire
# is printed NOT CAUGHT and fails this script.
#
# ⚠ TOOTH 3 IS THE IMPORTANT ONE. Teeth 1 and 2 test the COMPARISON. Only
# tooth 3 tests the REASONING the verdict rests on -- that all four divergent
# parameters are latches rather than accumulations. A gate can compare
# perfectly and still be believed for the wrong reason.
set -e
REPO=$(cd "$(dirname "$0")/../.." && pwd)
B="$REPO/build/parammap/teeth"
BANK="$REPO/truth/presetbankog1.bin"
SRC="$REPO/tools/engineb/devboot/paramwarm.c"
CC=${CC:-cc}
mkdir -p "$B"
EB=$(ls "$REPO"/engine_b/*.c | grep -v "test_")
FLAGS="-std=c99 -O2 -ffp-contract=off -fno-strict-aliasing -w"
bad=0

run_tooth() {
    name="$1"; sedexpr="$2"
    sed "$sedexpr" "$SRC" > "$B/t.c"
    $CC $FLAGS -I"$REPO/src" -I"$REPO/engine_b" -o "$B/t" "$B/t.c" \
        "$REPO"/src/*.c $EB -lm 2>/dev/null || {
        printf '%-58s SKIPPED (build failed)\n' "$name"; bad=1; return; }
    if "$B/t" "$BANK" "$B/out.tsv" >"$B/log" 2>&1; then
        printf '%-58s NOT CAUGHT\n' "$name"; bad=1
    else
        printf '%-58s CAUGHT\n' "$name"
    fi
}

echo "=========================================================="
echo "PARAMWARM TEETH"
echo "=========================================================="

# 1. Drop a record from EXPECT. The gate must report it as UNEXPECTEDLY
#    order-dependent -- the direction that means a new stale path.
run_tooth "1  drop 650 from EXPECT (must report unexpected)" \
          's/{ 116, 120, 634, 650 }/{ 116, 120, 634, 999 }/'

# 2. Add a record to EXPECT that is NOT order-dependent. The gate must report
#    it as NO LONGER order-dependent -- the direction that means a transition
#    stopped firing, which is the easier one to overlook.
run_tooth "2  add 200 to EXPECT (must report no-longer)" \
          's/static const int EXPECT\[4\] = { 116, 120, 634, 650 }/static const int EXPECT[5] = { 116, 120, 634, 650, 200 }/; s/for (i = 0; i < 4; ++i) if (EXPECT\[i\]/for (i = 0; i < 5; ++i) if (EXPECT[i]/'

# 3. Break the WARM path so it stops being warm: reseed before the second
#    apply. Every divergence then vanishes and the set collapses to empty --
#    the gate must notice that all four stopped diverging. This is the tooth
#    that guards the classification, not the comparison.
run_tooth "3  reseed before the 2nd apply (warm becomes cold)" \
          's|recall_only(wb, b \* 7);                  /\* P. over live state \*/|reseed(); recall_only(wb, b * 7);|'

echo "----------------------------------------------------------"
if [ "$bad" -eq 0 ]; then
    echo "PARAMWARM TEETH: ALL CAUGHT"
else
    echo "PARAMWARM TEETH: A TOOTH DID NOT FIRE -- the gate is not believed"
    exit 1
fi
