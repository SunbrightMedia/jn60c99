#!/bin/sh
# jp8_host_gate.sh -- the JUPITER-8 HOST gate: the plugin's own VST3 entries a host calls -- setupProcessing,
# setActive, process(), getState, setState -- its own patch load, its UI timer's drain and MIDI learn (the CC menu's
# Learn / Forget) and its own engine workers, LIFTED, run by
# jp8/src/jp8_host.c on the memory the host oracle had after booting the plugin up to the point a host learns its
# sample rate, against the host oracle itself (jp8_host_seq.py drive, jp8_host_ref.py oracle + template,
# jp8_host_c.py C side; two processes).
#   0. the host path's dynamic reach over the 64 factory patches and the drive's other steps
#      (jp8/gen/jp8_hostreach_<rate>.json; jp8_host_dynreach.py regenerates it, ~45 min), united with the reach of
#      THIS gate's drive (its patches, ~8 min; jp8_reach_merge.py); "roots" are the entries the drive called, read
#      from the plugin's own vtables
#   1. lift: those roots, every indirect call target of the reach; --alloc-tailcall (a jmp to operator new is a tail
#      call, never a body to follow: playbook 234); --hostcalls (every stub call answered by jp8_host.c), --hook
#      0x4460E7 (the jobs) and 0x4456F0 (a worker's park); build CHECKED (every access bounds-checked, -O1) and
#      PRODUCT (the fast pass, -O2), both on the one-offset map (JP8_FLAT) with the oracle's TEB as the gs base
#   2. the oracle: the template and the references
#   3. both builds: CONTROL 1 (after the setup calls), then every step's result, every output word, every state
#      byte, every performEdit, the worker jobs and the memory after
#   4. the teeth, each must FAIL: T1 ONE addss of the lift turned subss (the FINE TUNE setter 0x38633e, reached by every
#      patch load); T2 the last flagged unit's job skipped by the transport (-DJP8H_TOOTH_SKIPJOB); T3 one heap byte of
#      the template changed (CONTROL 1 must bite); T4 the setActive after a new host rate dropped (-DJP8H_TOOTH_RATE);
#      T5 every state value the IBStream hands setState one off (-DJP8H_TOOTH_STREAM); T6 the UI timer never drains
#      (-DJP8H_TOOTH_NODRAIN: the learned CC map and the store stay as they were)
# env: JP8_HOST_PATCHES (default 2,63,0,12), JP8_HOST_RATES (default 48000; e.g. "48000 44100 96000": one lift for
#      all, the oracle and both builds at each, the teeth at the first), JP8_HOST_SKIP_EMU=1 (reuse references),
#      JP8_HOST_REACH (another reach file, e.g. a short one while developing)
#   sh tools/run_job.sh jp8_host_gate sh jp8/tools/jp8_host_gate.sh
set -e
HERE="$(cd "$(dirname "$0")" && pwd)"; REPO="$(cd "$HERE/../.." && pwd)"; OUT="$REPO/build/jp8_host"; mkdir -p "$OUT"
export JP8_EMU_QUIET=1
RATES="${JP8_HOST_RATES:-${JP8_HOST_RATE:-48000}}"; RATE="${RATES%% *}"   # the first setup rates; the teeth on the first
export JP8_HOST_RATE="$RATE"
# the broad reach is the 48000 one for every first rate (the patches' code does not change with the rate; the gate's
# own drive, reached at each of its rates below, holds what does)
REACH="${JP8_HOST_REACH:-$REPO/jp8/gen/jp8_hostreach_48000.json}"; REF="$OUT/ref_${RATE%.*}"; SRC="$REPO/jp8/src/jp8_host_lift.c"
TOOTH=0x38633e
BASE="-std=c99 -pedantic-errors -ffp-contract=off -fno-strict-aliasing -fwrapv -fPIC -DJP8_RELOC -DJP8_FLAT -DJP8_GS_BASE=0x580000000ULL -I$REPO/jp8/src"
CHK="$BASE -O1 -DJP8_RELOC_CHECK=2"; PRD="$BASE -O2 -DJP8_RELOC_CHECK=0"
echo "=== 0. the reach: the 64 patches, and this gate's own drive at each first rate ($RATES) ==="
[ -f "$REACH" ] || python3 "$HERE/jp8_host_dynreach.py" "$REACH" 0-63 48000
# the drive after 64 patches is not the drive after these four: a crafted state's next block can call what the long
# drive never did (job jp8_host_gate3b: an indirect target at step 85) -- the lift holds both (jp8_reach_merge.py)
GREACHES=""; LREACH="$OUT/hostreach_lift.json"
for R in $RATES; do
    GREACH="$OUT/hostreach_gate_${R%.*}.json"; GREACHES="$GREACHES $GREACH"
    python3 "$HERE/jp8_host_dynreach.py" "$GREACH" "${JP8_HOST_PATCHES:-2,63,0,12}" "$R" > "$OUT/hostreach_gate_${R%.*}.log" 2>&1   # set -e: a failure stops here
    tail -1 "$OUT/hostreach_gate_${R%.*}.log"
done
python3 "$HERE/jp8_reach_merge.py" "$LREACH" "$REACH" $GREACHES
ROOTS=$(python3 -c "import json,sys; r=json.load(open(sys.argv[1]))['roots']; print(','.join('0x%x' % v for v in sorted(set(r.values()))))" "$LREACH")
echo "roots: $ROOTS"
echo "=== 1. lift + build ==="
python3 "$HERE/jp8_lift.py" "$SRC" "$ROOTS" --dyn "$LREACH" --alloc 0x6F5B04 --alloc-tailcall --name host --hostcalls --hook 0x4460E7,0x4456F0
python3 "$HERE/jp8_fast.py" "$SRC" "$OUT/jp8_host_lift_fast.c"
cc $CHK -w -c -o "$OUT/hlift_chk.o" "$SRC"
cc $CHK -c -o "$OUT/hrt_chk.o" "$REPO/jp8/src/jp8_rt.c"; cc $CHK -c -o "$OUT/hhost_chk.o" "$REPO/jp8/src/jp8_host.c"
cc -shared -o "$OUT/libjp8host_chk.so" "$OUT/hlift_chk.o" "$OUT/hrt_chk.o" "$OUT/hhost_chk.o" -lm
cc $PRD -w -c -o "$OUT/hlift_prd.o" "$OUT/jp8_host_lift_fast.c"
cc $PRD -c -o "$OUT/hrt_prd.o" "$REPO/jp8/src/jp8_rt.c"; cc $PRD -c -o "$OUT/hhost_prd.o" "$REPO/jp8/src/jp8_host.c"
cc -shared -o "$OUT/libjp8host_prd.so" "$OUT/hlift_prd.o" "$OUT/hrt_prd.o" "$OUT/hhost_prd.o" -lm
for R in $RATES; do
    RREF="$OUT/ref_${R%.*}"
    echo "=== 2. the oracle at $R: template + references ==="
    if [ -n "${JP8_HOST_SKIP_EMU:-}" ] && [ -f "$RREF/meta.json" ]; then echo "reusing $RREF"; else JP8_HOST_RATE=$R python3 "$HERE/jp8_host_ref.py" "$RREF"; fi
    echo "=== 3. the C side at $R: checked build ==="
    JP8_HOST_RATE=$R python3 "$HERE/jp8_host_c.py" "$RREF" "$OUT/libjp8host_chk.so"
    echo "=== 3. the C side at $R: product build ==="
    JP8_HOST_RATE=$R python3 "$HERE/jp8_host_c.py" "$RREF" "$OUT/libjp8host_prd.so"
done
echo "=== 4. the teeth ==="
bite() {    # bite <name> <refdir> <lib>: the run must FAIL
    n=$1; shift
    if python3 "$HERE/jp8_host_c.py" "$@" > "$OUT/tooth_$n.log" 2>&1; then echo "*** TOOTH $n DID NOT BITE ***"; exit 1; fi
    echo "tooth $n bites ($(tail -1 "$OUT/tooth_$n.log" | grep -o '[0-9]* differences' || echo 'a trap')): $(grep -v 'CONTROL 1: the memory' "$OUT/tooth_$n.log" | grep -m1 'word \|TRAP\|differ' | cut -c1-170)"
}
python3 - "$SRC" "$OUT/jp8_host_lift_t1.c" "$TOOTH" <<'EOF'
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
cc $BASE -O1 -DJP8_RELOC_CHECK=0 -w -c -o "$OUT/hlift_t1.o" "$OUT/jp8_host_lift_t1.c"
cc -shared -o "$OUT/libjp8host_t1.so" "$OUT/hlift_t1.o" "$OUT/hrt_prd.o" "$OUT/hhost_prd.o" -lm
bite T1 "$REF" "$OUT/libjp8host_t1.so"
for t in 2:SKIPJOB 4:RATE 5:STREAM 6:NODRAIN; do
    cc $PRD -DJP8H_TOOTH_${t#*:} -c -o "$OUT/hhost_t${t%%:*}.o" "$REPO/jp8/src/jp8_host.c"
    cc -shared -o "$OUT/libjp8host_t${t%%:*}.so" "$OUT/hlift_prd.o" "$OUT/hrt_prd.o" "$OUT/hhost_t${t%%:*}.o" -lm
    bite "T${t%%:*}" "$REF" "$OUT/libjp8host_t${t%%:*}.so"
done
rm -rf "$OUT/ref_t3"; mkdir -p "$OUT/ref_t3"; cp "$REF/words.bin" "$REF/states.bin" "$OUT/ref_t3/"
python3 - "$REF" "$OUT/ref_t3" <<'EOF'
import sys, json, struct, zlib, hashlib
src, dst = sys.argv[1], sys.argv[2]
b = bytearray(open(src + "/jp8_host_template.bin", "rb").read())
nreg = struct.unpack_from("<I", b, 8)[0]; p = 12; done = False
for _ in range(nreg):                     # the first run of the heap region: one byte flipped
    base, size, nruns = struct.unpack_from("<QQI", b, p); p += 20
    for _ in range(nruns):
        off, ln = struct.unpack_from("<II", b, p); p += 8
        if base == 0x310000000 and not done: b[p + ln // 2] ^= 0x01; done = True
        p += ln
assert done
b[-4:] = struct.pack("<I", zlib.crc32(bytes(b[:-4])) & 0xFFFFFFFF)
open(dst + "/jp8_host_template.bin", "wb").write(b)
m = json.load(open(src + "/meta.json")); m["template_sha256"] = hashlib.sha256(bytes(b)).hexdigest()
json.dump(m, open(dst + "/meta.json", "w"))
EOF
bite T3 "$OUT/ref_t3" "$OUT/libjp8host_prd.so"
echo "JP8 HOST GATE (setup, process(), patch load, MIDI controllers, rate changes, the UI timer, MIDI learn, state, the edit controller, workers; first rates $RATES, patches ${JP8_HOST_PATCHES:-2,63,0,12}) GREEN: checked + product builds EXACTLY 0, 6 teeth bite"
