#!/bin/sh
# jn_midi_gate.sh -- L5's MIDI-controller drive (docs/JUNO_LIFT.md): the fixed plan jn_search_seq.plan_midi (a held
# chord under every CC 0..127 at three values, the mod wheel at sixteen offsets in one block, pitch bend and
# aftertouch across their range, sustain holding released keys, all notes off on a sounding chord, voice-count and
# engine-rate changes between notes) through the oracle (jn_search_ref.py) and the lifted host (jn_search_c.py), two
# processes, compared after EVERY op (status, end-state digest, heap / arena tops, output words). Its tooth (the first
# note one semitone up) MUST make them differ.
# usage: sh tools/lift/jn_midi_gate.sh [refdir]      (run from the repo root; the oracle side ~3 min)
set -e
R=$(pwd); D=${1:-$R/build/jn_host/midi_ref}
SO=$R/build/jn_host/libjunohost.so; T=$R/build/jn_host/jn_host_template.bin
[ -f "$SO" ] && [ -f "$T" ] || { echo "no lifted host -- run sh tools/lift/jn_build.sh"; exit 2; }
if [ ! -f "$D/meta.json" ] || [ -n "$JN_REFS" ]; then python3 "$R/tools/lift/jn_search_ref.py" "$D" midi; fi
python3 "$R/tools/lift/jn_search_c.py" "$SO" "$T" "$D"
python3 "$R/tools/lift/jn_search_c.py" "$SO" "$T" "$D" --tooth
echo "jn_midi_gate: GREEN (every op equal; the tooth bites)"
