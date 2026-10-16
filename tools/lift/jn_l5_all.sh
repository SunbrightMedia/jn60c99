#!/bin/sh
# jn_l5_all.sh -- EVERY L5 gate of the JUNO lift in one command (docs/JUNO_LIFT.md): init; process() at 48 / 44.1 /
# 96 kHz; the bank (all 64 factory patches through the patch browser); DAW state save/load; the editor's set; the
# surfaces (voice count, engine-rate setting, UI timer, MIDI learn / forget, commit, state round trip, host-rate
# changes); the editor attached and its windows' zoom (jn_zoom_seq.py). Each gate: the oracle reference (Unicorn, its own process -- reused from build/jn_host/<gate> when present;
# JN_REFS=1 remakes every one), the lifted host's C side EXACTLY 0 (ctypes, its own process), and its teeth SEEN TO
# FAIL. Needs the build (sh tools/lift/jn_build.sh). A long job: run it with tools/run_job.sh.
# usage: sh tools/lift/jn_l5_all.sh            (run from the repo root)
set -e
R=${REPO:-.}
OUT="$R/build/jn_host"; SO="$OUT/libjunohost.so"; T="$OUT/jn_host_template.bin"; L="$R/tools/lift"
{ [ -f "$SO" ] && [ -f "$T" ]; } || { echo "no build -- run sh tools/lift/jn_build.sh"; exit 2; }
ref() {          # ref <dir> <oracle command...>: make the reference unless it exists (JN_REFS=1: always)
    d=$1; shift
    if [ -n "$JN_REFS" ] || [ -z "$(ls "$d" 2>/dev/null)" ]; then rm -rf "$d"; "$@"; else echo "  (reusing $d)"; fi
}
echo "[1/8] init (setupProcessing + setActive from the template)"
ref "$OUT/ref" python3 "$L/jn_host_mem_ref.py" "$OUT/ref"
python3 "$L/jn_host_mem_c.py" "$SO" "$T" "$OUT/ref"; python3 "$L/jn_host_mem_c.py" "$SO" "$T" "$OUT/ref" --tooth
for hz in 48000 44100 96000; do
    echo "[2-4/8] process() at $hz Hz"
    d="$OUT/proc_ref_$hz"; [ "$hz" = 48000 ] && d="$OUT/proc_ref"
    ref "$d" python3 "$L/jn_proc_ref.py" "$d" "$hz"
    python3 "$L/jn_proc_c.py" "$SO" "$T" "$d"; python3 "$L/jn_proc_c.py" "$SO" "$T" "$d" --tooth
done
echo "[5/8] the bank: all 64 factory patches through the patch browser"
ref "$OUT/bank_ref" python3 "$L/jn_bank_ref.py" "$OUT/bank_ref"
python3 "$L/jn_bank_c.py" "$SO" "$T" "$OUT/bank_ref"; python3 "$L/jn_bank_c.py" "$SO" "$T" "$OUT/bank_ref" --tooth
echo "[6/8] DAW state save / load"
ref "$OUT/state_ref" python3 "$L/jn_state_ref.py" "$OUT/state_ref"
python3 "$L/jn_state_c.py" "$SO" "$T" "$OUT/state_ref"
for m in getstate skip note; do python3 "$L/jn_state_c.py" "$SO" "$T" "$OUT/state_ref" --tooth "$m"; done
echo "[7/8] the editor's set"
ref "$OUT/editor_ref" python3 "$L/jn_editor_ref.py" "$OUT/editor_ref"
python3 "$L/jn_editor_c.py" "$SO" "$T" "$OUT/editor_ref"; python3 "$L/jn_editor_c.py" "$SO" "$T" "$OUT/editor_ref" --tooth value
echo "[8/8] the surfaces (voice count, engine rate, UI timer, learn / forget, commit, state, host rates)"
grep -q '"rates": true' "$OUT/surf_ref/meta.json" 2>/dev/null || rm -rf "$OUT/surf_ref"
ref "$OUT/surf_ref" python3 "$L/jn_surf_ref.py" "$OUT/surf_ref"
python3 "$L/jn_surf_c.py" "$SO" "$T" "$OUT/surf_ref"; python3 "$L/jn_surf_c.py" "$SO" "$T" "$OUT/surf_ref" --tooth
echo "[9/9] the editor: attached on four screens, window zoom 25-200 % on the main and patch windows"
ref "$OUT/zoom_ref" python3 "$L/jn_zoom_ref.py" "$OUT/zoom_ref/ref.json"
python3 "$L/jn_zoom_c.py" "$SO" "$T" "$OUT/zoom_ref/ref.json"; python3 "$L/jn_zoom_c.py" "$SO" "$T" "$OUT/zoom_ref/ref.json" --tooth
echo "jn_l5_all: GREEN (9 gates EXACTLY 0 against the oracle; every tooth bites)"
