#!/bin/sh
# jp8_full_gate.sh -- the JUPITER-8 FULL-CHAIN gate (S3_STATUS step 3): the self-booting engine (jp8/src/jp8_engine.c)
# against the drive2 oracle, two processes (jp8_full_seq.py drive, jp8_full_emu.py oracle, jp8_full_c.py engine).
# Neither side replays the other's calls: the engine boots from the template with its own tables.
#   1. build: CHECKED = the lift (jp8_lift.c) with every access bounds-checked (JP8_RELOC_CHECK=2), -O1;
#             PRODUCT = the fast pass of the lift (jp8_fast.py), no bounds check, -O2
#   2. the oracle references (CONTROL 0 inside: the template == the oracle's post-static-init memory)
#   3. both builds: CONTROL 1 (init hash), RUN A (whole render events), RUN B (re-init + random chunks): EXACTLY 0
#   4. the teeth, each must FAIL (first patch only): T1 a note-on one key up (-DJP8_FULL_TOOTH); T2 ONE addss of the lift
#      turned into subss at jp8_full_seq.TOOTH_RVA (the FINE TUNE setter, reached by every recall), the lifter's own
#      --tooth transform; T3 one bit of the constructed [HOST+8] flipped after the FACTORY (-DJP8_HOST_TOOTH, CONTROL 1
#      must bite); T4 the template without its stack residue (--no-stack, CONTROL 1 must bite; PORT_LESSONS 12)
# env: JP8_FULL_PATCHES (default 2,63,0,12), JP8_FULL_RATE (44100 | 96000), JP8_FULL_SKIP_EMU=1 (reuse references)
#   sh tools/run_job.sh jp8_full sh jp8/tools/jp8_full_gate.sh
set -e
HERE="$(cd "$(dirname "$0")" && pwd)"; REPO="$(cd "$HERE/../.." && pwd)"; OUT="$REPO/build/jp8_full"; mkdir -p "$OUT"
RATE="${JP8_FULL_RATE:-44100}"; REF="$OUT/ref_${RATE%.*}"; export JP8_EMU_QUIET=1
TOOTH=$(python3 -c "import sys; sys.path.insert(0,'$HERE'); import jp8_full_seq as Q; print(Q.TOOTH_RVA)")
FIRST=$(python3 -c "import sys; sys.path.insert(0,'$HERE'); import jp8_full_seq as Q; print(Q.PATCHES[0])")
BASE="-std=c99 -pedantic-errors -ffp-contract=off -fno-strict-aliasing -fwrapv -fPIC -DJP8_RELOC -I$REPO/jp8/src"
CHK="$BASE -O1 -DJP8_RELOC_CHECK=2"; PRD="$BASE -O2 -DJP8_RELOC_CHECK=0"
echo "=== 1. build (checked + product) ==="
python3 "$HERE/jp8_fast.py" "$REPO/jp8/src/jp8_lift.c" "$OUT/jp8_lift_fast.c"
cc $CHK -w -c -o "$OUT/lift_chk.o" "$REPO/jp8/src/jp8_lift.c"
cc $CHK -c -o "$OUT/rt_chk.o" "$REPO/jp8/src/jp8_rt.c"; cc $CHK -c -o "$OUT/eng_chk.o" "$REPO/jp8/src/jp8_engine.c"
cc -shared -o "$OUT/libjp8_chk.so" "$OUT/lift_chk.o" "$OUT/rt_chk.o" "$OUT/eng_chk.o" -lm
cc $PRD -w -c -o "$OUT/lift_prd.o" "$OUT/jp8_lift_fast.c"
cc $PRD -c -o "$OUT/rt_prd.o" "$REPO/jp8/src/jp8_rt.c"; cc $PRD -c -o "$OUT/eng_prd.o" "$REPO/jp8/src/jp8_engine.c"
cc -shared -o "$OUT/libjp8_prd.so" "$OUT/lift_prd.o" "$OUT/rt_prd.o" "$OUT/eng_prd.o" -lm
echo "=== 2. oracle references (drive2, $RATE Hz) ==="
if [ -n "${JP8_FULL_SKIP_EMU:-}" ] && [ -f "$REF/p$(printf %02d "$FIRST")/meta.json" ]; then echo "reusing $REF"; else python3 "$HERE/jp8_full_emu.py" "$REF"; fi
echo "=== 3. the engine: checked build ==="
python3 "$HERE/jp8_full_c.py" "$REF" "$OUT/libjp8_chk.so"
echo "=== 3. the engine: product build ==="
python3 "$HERE/jp8_full_c.py" "$REF" "$OUT/libjp8_prd.so"
echo "=== 4. the teeth (patch $FIRST) ==="
bite() {    # bite <name> <lib> [args...]: the run must FAIL
    n=$1; lib=$2; shift 2
    if python3 "$HERE/jp8_full_c.py" "$REF" "$lib" --patches "$FIRST" --runs A "$@" > "$OUT/tooth_$n.log" 2>&1; then
        echo "*** TOOTH $n DID NOT BITE ***"; exit 1
    fi
    echo "tooth $n bites: $(grep -m1 'differs\|oracle\|rc -' "$OUT/tooth_$n.log" | cut -c1-200)"
}
cc $PRD -DJP8_FULL_TOOTH -c -o "$OUT/eng_t1.o" "$REPO/jp8/src/jp8_engine.c"
cc -shared -o "$OUT/libjp8_t1.so" "$OUT/lift_prd.o" "$OUT/rt_prd.o" "$OUT/eng_t1.o" -lm
bite T1 "$OUT/libjp8_t1.so"
python3 - "$REPO/jp8/src/jp8_lift.c" "$OUT/jp8_lift_t2.c" "$TOOTH" <<'EOF'
import sys
src, dst, rva = sys.argv[1], sys.argv[2], int(sys.argv[3], 16)
tag = "/*%x addss " % rva; out = []; n = 0
for line in open(src):
    if tag in line:          # jp8_lift.py --tooth: the statement's first JP8_ADDSS becomes JP8_SUBSS, marked
        stmt = line.split("*/", 1)
        assert len(stmt) == 2 and stmt[1].count("JP8_ADDSS"), line
        line = stmt[0] + "*/ /* TOOTH: + replaced by - */" + stmt[1].replace("JP8_ADDSS", "JP8_SUBSS", 1); n += 1
    out.append(line)
assert n == 1, "tooth site 0x%x found %d times" % (rva, n)
open(dst, "w").write("".join(out))
EOF
cc $BASE -O1 -DJP8_RELOC_CHECK=0 -w -c -o "$OUT/lift_t2.o" "$OUT/jp8_lift_t2.c"
cc -shared -o "$OUT/libjp8_t2.so" "$OUT/lift_t2.o" "$OUT/rt_prd.o" "$OUT/eng_prd.o" -lm
bite T2 "$OUT/libjp8_t2.so"
cc $PRD -DJP8_HOST_TOOTH -c -o "$OUT/eng_t3.o" "$REPO/jp8/src/jp8_engine.c"
cc -shared -o "$OUT/libjp8_t3.so" "$OUT/lift_prd.o" "$OUT/rt_prd.o" "$OUT/eng_t3.o" -lm
bite T3 "$OUT/libjp8_t3.so"
bite T4 "$OUT/libjp8_prd.so" --no-stack
echo "JP8 FULL-CHAIN GATE (drive2, $RATE Hz, patches ${JP8_FULL_PATCHES:-2,63,0,12}) GREEN: checked + product builds EXACTLY 0, 4 teeth bite"
