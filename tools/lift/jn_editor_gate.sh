#!/bin/sh
# jn_editor_gate.sh -- L5 (editor) of the JUNO lift (docs/JUNO_LIFT.md): the editor's SET through the lifted JUNO's
# OWN model (rva 0x283DB0) is bit-exact. Two processes (the two-process rule): the oracle (jn_editor_ref.py, Unicorn)
# sets every parameter record at a few values and records the performEdit sequence the plugin's controller makes, then
# renders a warm block; the C side (jn_editor_c.py, ctypes) does the same through junoh_model_set and compares the
# performEdits, the output words and the end-state memory EXACTLY. A tooth (each value one higher) must make them
# differ. Reuses build/jn_host/libjunohost.so + its template.
# usage: sh tools/lift/jn_editor_gate.sh            (run from the repo root)
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
echo "[1/3] the oracle editor reference (Unicorn, a process of its own)"
python3 "$R/tools/lift/jn_editor_ref.py" "$OUT/editor_ref"
echo "[2/3] the lifted model set vs the oracle (ctypes), EXACTLY 0"
python3 "$R/tools/lift/jn_editor_c.py" "$SO" "$TMPL" "$OUT/editor_ref"
echo "[3/3] the value tooth (each set one higher must differ)"
python3 "$R/tools/lift/jn_editor_c.py" "$SO" "$TMPL" "$OUT/editor_ref" --tooth value
echo "jn_editor_gate: GREEN (the editor's set bit-exact through the lifted model; tooth bites)"
