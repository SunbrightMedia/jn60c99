#!/bin/sh
# jn_state_gate.sh -- L5 (state) of the JUNO lift (docs/JUNO_LIFT.md): the DAW state round trip through the lifted
# JUNO's OWN getState / setState (IComponent slots 13 / 12) is bit-exact. Two processes (the two-process rule): the
# oracle (jn_state_ref.py, Unicorn) loads patch P, saves its state, moves to patch Q, restores P, saves again, and
# plays; the C side (jn_state_c.py, ctypes) does the same through the lifted entries and compares the state bytes, the
# result code, and every output word + the end-state memory EXACTLY. Three teeth (getstate / skip / note) each make
# one graded quantity differ, so none is a vacuous pass. Reuses build/jn_host/libjunohost.so + its template.
# usage: sh tools/lift/jn_state_gate.sh            (run from the repo root)
set -e
R=${REPO:-.}
OUT="$R/build/jn_host"; mkdir -p "$OUT"
SO="$OUT/libjunohost.so"; TMPL="$OUT/jn_host_template.bin"
BASE="-std=c99 -ffp-contract=off -fno-strict-aliasing -fwrapv -fPIC -DJP8_RELOC -DJP8_FLAT -DJP8_GS_BASE=0x580000000ULL -I$R/jp8/src -I$R/lift"
if [ ! -f "$SO" ] || [ ! -f "$TMPL" ]; then
    [ -f "$R/scratchpad/lift/juno_reach.json" ] || { echo "no L1 census -- run tools/verify/juno_lift_reach.py"; exit 2; }
    echo "[build] generate the host-flavor lift"; sh "$R/tools/lift/gen_juno_lift.sh"
    echo "[build] the template"; python3 "$R/tools/lift/jn_host_ref.py" "$TMPL" >/dev/null
    echo "[build] libjunohost.so"
    cc $BASE -w -c "$R/lift/jn_lift.c" -o "$OUT/jn_lift.o"
    cc $BASE -pedantic-errors -c "$R/jp8/src/jp8_rt.c" -o "$OUT/jn_rt.o"
    cc $BASE -pedantic-errors -c "$R/lift/jn_host.c" -o "$OUT/jn_host.o"
    cc -shared -o "$SO" "$OUT/jn_lift.o" "$OUT/jn_rt.o" "$OUT/jn_host.o" -lm
else
    echo "[build] reusing $SO"
fi
echo "[1/3] the oracle state reference (Unicorn, a process of its own)"
python3 "$R/tools/lift/jn_state_ref.py" "$OUT/state_ref"
echo "[2/3] the lifted getState / setState round trip vs the oracle (ctypes), EXACTLY 0"
python3 "$R/tools/lift/jn_state_c.py" "$SO" "$TMPL" "$OUT/state_ref"
echo "[3/3] the teeth (each must make one graded quantity differ)"
for m in getstate skip note; do
    python3 "$R/tools/lift/jn_state_c.py" "$SO" "$TMPL" "$OUT/state_ref" --tooth "$m"
done
echo "jn_state_gate: GREEN (DAW state save/load bit-exact through the lifted entries; all three teeth bite)"
