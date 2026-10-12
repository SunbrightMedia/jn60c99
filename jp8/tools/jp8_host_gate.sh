#!/bin/sh
# jp8_host_gate.sh -- the JUPITER-8 HOST gate: the plugin's own VST3 entries a host calls -- setupProcessing,
# setActive, process(), getState, setState -- its own patch load, its UI timer's drain and MIDI learn (the CC menu's
# Learn / Forget), its own engine workers and (v8) its editor's open and window zoom, LIFTED, run by
# jp8/src/jp8_host.c on the memory the host oracle had after booting the plugin up to the point a host learns its
# sample rate, against the host oracle itself (jp8_host_seq.py drive, jp8_host_ref.py oracle + template,
# jp8_host_c.py C side; two processes).
#   0. the host path's dynamic reach over the 64 factory patches and the drive's other steps
#      (jp8/gen/jp8_hostreach_<rate>.json; jp8_host_dynreach.py regenerates it, ~45 min), the reach of the sweep
#      (jp8/gen/jp8_hostreach_sweep_48000.json, ~90 min), united with the reach of THIS gate's drive without the sweep
#      (its patches, ~8 min; jp8_reach_merge.py); "roots" are the entries the drive called, read from the plugin's
#      own vtables
#   1. lift: those roots, every indirect call target of the reach; --alloc-tailcall (a jmp to operator new is a tail
#      call, never a body to follow: playbook 234); --hostcalls (every stub call answered by jp8_host.c), --hook
#      0x4460E7 (the jobs), 0x4456F0 (a worker's park), 0x44580A (a job's render done) and 0x31B790 (a window's fit to
#      the screen: the editor's windows found by their call); build CHECKED (the plain
#      lift, every access bounds-checked, -O1), PRODUCT (the fast pass, then jp8_xlane.py: every xmm register in three
#      scalars; guest memory not volatile, -DJP8_MQ=; -O2) and THREADS (the product with the workers on POSIX threads,
#      JP8H_THREADS: a platform layer), all on the one-offset map (JP8_FLAT), the oracle's TEB as gs base
#   2. the oracle: the template and the references
#   3. the three builds (THREADS three times): CONTROL 1 (after the setup calls), then every step's result, every
#      output word, every state byte, every performEdit, the worker jobs and the memory after
#   4. the teeth, each must FAIL: T1 ONE addss of the lift turned subss (the FINE TUNE setter 0x38633e, reached by every
#      patch load); T2 the last flagged unit's job skipped by the transport (-DJP8H_TOOTH_SKIPJOB); T3 one heap byte of
#      the template changed (CONTROL 1 must bite); T4 the setActive after a new host rate dropped (-DJP8H_TOOTH_RATE);
#      T5 every state value the IBStream hands setState one off (-DJP8H_TOOTH_STREAM); T6 the UI timer never drains
#      (-DJP8H_TOOTH_NODRAIN: the learned CC map and the store stay as they were); T7 the C side's heap never reuses a
#      freed block (-DJP8H_TOOTH_NOREUSE: the oracle's does); T8 a parameter info's short title copied from its title
#      (-DJP8H_TOOTH_INFO: every title is set, every short title empty -- keyed to the content, playbook 236); T9 the
#      lane pass swaps lanes a and b in every store of a register to the CPU struct (JP8_XLANE_TOOTH=1); T10 host
#      automation of EFFECT TYPE never arrives (-DJP8H_TOOTH_SWEEP: the sweep's effect types must be graded); T11
#      one byte of the shipped template flipped (jp8_template_check.py --tooth: stage 2b must see it); T12 the
#      software-float build with no software DAZ / FTZ at all (-DJP8_SOFTFP_TOOTH_NOFLUSH: denormals reach the
#      engine's state on this drive -- the memory after must see it); T13 the host tempo off by half
#      (-DJP8H_TOOTH_TRANSPORT: the tempo is what the plugin reads of the context; v8's tempos under a synced arpeggio
#      must be graded); T14 the
#      screen's width and height swapped in GetSystemMetrics (-DJP8H_TOOTH_EDITOR: the editor window's zoom must see it)
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
SWEEP_PATCH=$(python3 -c "import sys; sys.path.insert(0,'$HERE'); import jp8_host_seq as Q; print(Q.SWEEP_PATCH)")
BASE="-std=c99 -pedantic-errors -ffp-contract=off -fno-strict-aliasing -fwrapv -fPIC -DJP8_RELOC -DJP8_FLAT -DJP8_GS_BASE=0x580000000ULL -I$REPO/jp8/src"
CHK="$BASE -O1 -DJP8_RELOC_CHECK=2"; PRD="$BASE -O2 -DJP8_RELOC_CHECK=0 -DJP8_MQ="
echo "=== 0. the reach: the 64 patches, and this gate's own drive at each first rate ($RATES) ==="
[ -f "$REACH" ] || JP8_HOST_SWEEP=0 python3 "$HERE/jp8_host_dynreach.py" "$REACH" 0-63 48000
# the sweep's reach (v7: every panel parameter's positions, the effects, the arpeggiator, the assign modes; ~90 min)
SREACH="${JP8_HOST_SREACH:-$REPO/jp8/gen/jp8_hostreach_sweep_48000.json}"
[ -f "$SREACH" ] || python3 "$HERE/jp8_host_dynreach.py" "$SREACH" "$SWEEP_PATCH" 48000
# the drive after 64 patches is not the drive after these four: a crafted state's next block can call what the long
# drive never did (job jp8_host_gate3b: an indirect target at step 85) -- the lift holds both (jp8_reach_merge.py)
GREACHES=""; LREACH="$OUT/hostreach_lift.json"
for R in $RATES; do
    GREACH="$OUT/hostreach_gate_${R%.*}.json"; GREACHES="$GREACHES $GREACH"
    # the sweep (v7) is in the broad reach: it plays SWEEP_PATCH whatever the patches, and the engine it drives runs at
    # its own rate whatever the first rate (code it misses is a trap on the C side: the gate goes red, never silent)
    JP8_HOST_SWEEP=0 python3 "$HERE/jp8_host_dynreach.py" "$GREACH" "${JP8_HOST_PATCHES:-2,63,0,12}" "$R" > "$OUT/hostreach_gate_${R%.*}.log" 2>&1   # set -e: a failure stops here
    tail -1 "$OUT/hostreach_gate_${R%.*}.log"
done
python3 "$HERE/jp8_reach_merge.py" "$LREACH" "$REACH" "$SREACH" $GREACHES
ROOTS=$(python3 -c "import json,sys; r=json.load(open(sys.argv[1]))['roots']; print(','.join('0x%x' % v for v in sorted(set(r.values()))))" "$LREACH")
echo "roots: $ROOTS"
echo "=== 1. lift + build ==="
python3 "$HERE/jp8_lift.py" "$SRC" "$ROOTS" --dyn "$LREACH" --alloc 0x6F5B04 --alloc-tailcall --name host --hostcalls --hook 0x4460E7,0x4456F0,0x44580A,0x31B790
python3 "$HERE/jp8_fast.py" "$SRC" "$OUT/jp8_host_lift_fast.c"
python3 "$HERE/jp8_xlane.py" "$OUT/jp8_host_lift_fast.c" "$OUT/jp8_host_lift_xl.c"
cc $CHK -w -c -o "$OUT/hlift_chk.o" "$SRC"
cc $CHK -c -o "$OUT/hrt_chk.o" "$REPO/jp8/src/jp8_rt.c"; cc $CHK -c -o "$OUT/hhost_chk.o" "$REPO/jp8/src/jp8_host.c"
cc -shared -o "$OUT/libjp8host_chk.so" "$OUT/hlift_chk.o" "$OUT/hrt_chk.o" "$OUT/hhost_chk.o" -lm
cc $PRD -w -c -o "$OUT/hlift_prd.o" "$OUT/jp8_host_lift_xl.c"
cc $PRD -c -o "$OUT/hrt_prd.o" "$REPO/jp8/src/jp8_rt.c"; cc $PRD -c -o "$OUT/hhost_prd.o" "$REPO/jp8/src/jp8_host.c"
cc -shared -o "$OUT/libjp8host_prd.so" "$OUT/hlift_prd.o" "$OUT/hrt_prd.o" "$OUT/hhost_prd.o" -lm
THR="$PRD -D_POSIX_C_SOURCE=200809L -DJP8H_THREADS"      # the platform layer: the workers on POSIX threads
cc $THR -w -c -o "$OUT/hlift_thr.o" "$OUT/jp8_host_lift_xl.c"
cc $THR -c -o "$OUT/hrt_thr.o" "$REPO/jp8/src/jp8_rt.c"; cc $THR -c -o "$OUT/hhost_thr.o" "$REPO/jp8/src/jp8_host.c"
cc -shared -o "$OUT/libjp8host_thr.so" "$OUT/hlift_thr.o" "$OUT/hrt_thr.o" "$OUT/hhost_thr.o" -lm -lpthread
SFP="$PRD -DJP8_SOFTFP=2"                                 # a host without x86 FTZ / DAZ: the float modes in software
cc $SFP -w -c -o "$OUT/hlift_sfp.o" "$OUT/jp8_host_lift_xl.c"
cc $SFP -c -o "$OUT/hrt_sfp.o" "$REPO/jp8/src/jp8_rt.c"; cc $SFP -c -o "$OUT/hhost_sfp.o" "$REPO/jp8/src/jp8_host.c"
cc -shared -o "$OUT/libjp8host_sfp.so" "$OUT/hlift_sfp.o" "$OUT/hrt_sfp.o" "$OUT/hhost_sfp.o" -lm
for R in $RATES; do
    RREF="$OUT/ref_${R%.*}"
    echo "=== 2. the oracle at $R: template + references ==="
    if [ -n "${JP8_HOST_SKIP_EMU:-}" ] && [ -f "$RREF/meta.json" ]; then echo "reusing $RREF"; else JP8_HOST_RATE=$R python3 "$HERE/jp8_host_ref.py" "$RREF"; fi
    echo "=== 2b. the shipped template (jp8/gen/jp8h_template.bin.gz, what jp8/apps/jp8_render boots) == the oracle's at $R ==="
    python3 "$HERE/jp8_template_check.py" "$REPO/jp8/gen/jp8h_template.bin.gz" "$RREF/meta.json"
    echo "=== 3. the C side at $R: checked build ==="
    JP8_HOST_RATE=$R python3 "$HERE/jp8_host_c.py" "$RREF" "$OUT/libjp8host_chk.so"
    echo "=== 3. the C side at $R: product build ==="
    JP8_HOST_RATE=$R python3 "$HERE/jp8_host_c.py" "$RREF" "$OUT/libjp8host_prd.so"
    echo "=== 3. the C side at $R: product build, the workers on threads (3 runs: a race would show) ==="
    for k in 1 2 3; do                       # (no pipe: set -e must see the driver's own exit status)
        L="$OUT/threads_${R%.*}_$k.log"
        if ! JP8_HOST_RATE=$R python3 "$HERE/jp8_host_c.py" "$RREF" "$OUT/libjp8host_thr.so" > "$L" 2>&1; then cat "$L"; exit 1; fi
        tail -1 "$L"
    done
    if [ "$R" = "$RATE" ]; then
        echo "=== 3. the C side at $R: software floats (JP8_SOFTFP=2: DAZ / FTZ from the guest's MXCSR, in C) ==="
        JP8_HOST_RATE=$R python3 "$HERE/jp8_host_c.py" "$RREF" "$OUT/libjp8host_sfp.so"
    fi
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
for t in 2:SKIPJOB 4:RATE 5:STREAM 6:NODRAIN 7:NOREUSE 8:INFO 10:SWEEP 13:TRANSPORT 14:EDITOR; do
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
JP8_XLANE_TOOTH=1 python3 "$HERE/jp8_xlane.py" "$OUT/jp8_host_lift_fast.c" "$OUT/jp8_host_lift_t9.c"
cc $PRD -w -c -o "$OUT/hlift_t9.o" "$OUT/jp8_host_lift_t9.c"
cc -shared -o "$OUT/libjp8host_t9.so" "$OUT/hlift_t9.o" "$OUT/hrt_prd.o" "$OUT/hhost_prd.o" -lm
bite T9 "$REF" "$OUT/libjp8host_t9.so"
cc $SFP -DJP8_SOFTFP_TOOTH_NOFLUSH -c -o "$OUT/hrt_t12.o" "$REPO/jp8/src/jp8_rt.c"   # the flush modes are set in jp8_rt.c / jp8_host.c
cc $SFP -DJP8_SOFTFP_TOOTH_NOFLUSH -c -o "$OUT/hhost_t12.o" "$REPO/jp8/src/jp8_host.c"
cc $SFP -DJP8_SOFTFP_TOOTH_NOFLUSH -w -c -o "$OUT/hlift_t12.o" "$OUT/jp8_host_lift_xl.c"
cc -shared -o "$OUT/libjp8host_t12.so" "$OUT/hlift_t12.o" "$OUT/hrt_t12.o" "$OUT/hhost_t12.o" -lm
bite T12 "$REF" "$OUT/libjp8host_t12.so"
if python3 "$HERE/jp8_template_check.py" "$REPO/jp8/gen/jp8h_template.bin.gz" "$REF/meta.json" --tooth > "$OUT/tooth_T11.log" 2>&1; then echo "*** TOOTH T11 DID NOT BITE ***"; exit 1; fi
echo "tooth T11 bites (the shipped template, one byte flipped): $(tail -1 "$OUT/tooth_T11.log" | cut -c1-150)"
echo "JP8 HOST GATE (setup, process(), patch load, MIDI controllers, the host transport, rate changes, the UI timer, MIDI learn, state, the edit controller and what a DAW asks it, the editor's open and zoom, workers, the heap's reuse; first rates $RATES, patches ${JP8_HOST_PATCHES:-2,63,0,12}) GREEN: checked + product + threads builds EXACTLY 0, the shipped template the oracle's, software floats EXACTLY 0, 14 teeth bite"
