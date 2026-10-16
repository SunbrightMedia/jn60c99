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
if [ ! -f "$SO" ] || [ ! -f "$TMPL" ]; then          # the one build (the lift in parts, both flavors)
    sh "$R/tools/lift/jn_build.sh"
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
