#!/bin/sh
# jn_bank_gate.sh -- L5 (bank) of the JUNO lift (docs/JUNO_LIFT.md): the lifted JUNO plays EVERY factory patch bit-
# exact. The plugin's OWN patch browser load (junoh_load_patch -> rva 0x335850) of all 64 records, each followed by a
# short play, graded in TWO processes (the two-process rule): the oracle (Unicorn, jn_bank_ref.py) writes the output
# words + the patch records + the end-state memory; the C side (ctypes, jn_bank_c.py) loads the same records through
# the lifted patch browser, plays the same drive, and compares EXACTLY. A tooth (a semitone up) must make it differ.
# This is the first gate to exercise junoh_load_patch (the init / process gates drove only the boot patch).
# Reuses build/jn_host/libjunohost.so + its template if present (from jn_host_gate.sh); builds them otherwise.
# usage: sh tools/lift/jn_bank_gate.sh            (run from the repo root; a long oracle run -> tools/run_job.sh)
set -e
R=${REPO:-.}
OUT="$R/build/jn_host"; mkdir -p "$OUT"
SO="$OUT/libjunohost.so"; TMPL="$OUT/jn_host_template.bin"
BASE="-std=c99 -ffp-contract=off -fno-strict-aliasing -fwrapv -fPIC -DJP8_RELOC -DJP8_FLAT -DJP8_GS_BASE=0x580000000ULL -I$R/jp8/src -I$R/lift"
if [ ! -f "$SO" ] || [ ! -f "$TMPL" ]; then
    [ -f "$R/scratchpad/lift/juno_reach.json" ] || { echo "no L1 census -- run tools/verify/juno_lift_reach.py"; exit 2; }
    echo "[build] generate the host-flavor lift"
    sh "$R/tools/lift/gen_juno_lift.sh"
    echo "[build] the template"
    python3 "$R/tools/lift/jn_host_ref.py" "$TMPL" >/dev/null
    echo "[build] libjunohost.so"
    cc $BASE -w -c "$R/lift/jn_lift.c" -o "$OUT/jn_lift.o"
    cc $BASE -pedantic-errors -c "$R/jp8/src/jp8_rt.c" -o "$OUT/jn_rt.o"
    cc $BASE -pedantic-errors -c "$R/lift/jn_host.c" -o "$OUT/jn_host.o"
    cc -shared -o "$SO" "$OUT/jn_lift.o" "$OUT/jn_rt.o" "$OUT/jn_host.o" -lm
else
    echo "[build] reusing $SO"
fi
echo "[1/3] the oracle bank reference (Unicorn, a process of its own) -- all ${JUNO_BANK_PATCHES:-64} factory patches"
python3 "$R/tools/lift/jn_bank_ref.py" "$OUT/bank_ref"
echo "[2/3] the lifted patch browser + play vs the oracle (ctypes), EXACTLY 0"
python3 "$R/tools/lift/jn_bank_c.py" "$SO" "$TMPL" "$OUT/bank_ref"
echo "[3/3] the note tooth (a semitone up must differ)"
python3 "$R/tools/lift/jn_bank_c.py" "$SO" "$TMPL" "$OUT/bank_ref" --tooth
echo "jn_bank_gate: GREEN (every factory patch bit-exact through the lifted patch browser; tooth bites)"
