#!/bin/sh
# jn_l5_midi.sh -- every L5 gate with its teeth (jn_l5_all.sh), then the MIDI-controller drive (jn_midi_gate.sh).
# usage: sh tools/lift/jn_l5_midi.sh            (run from the repo root; with tools/run_job.sh)
set -e
R=${REPO:-.}
sh "$R/tools/lift/jn_l5_all.sh"
sh "$R/tools/lift/jn_midi_gate.sh"
echo "jn_l5_midi: GREEN"
