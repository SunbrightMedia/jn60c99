#!/bin/sh
# jn_rebuild_l5.sh -- after a lifter or glue change: the rebuild (jn_rebuild.sh: the build, the L2 check and its
# self-test), then every L5 gate on the new build (jn_l5_midi.sh: jn_l5_all.sh + the MIDI-controller drive).
# Oracle references are reused from build/jn_host when present (JN_REFS=1 remakes them). Run it with tools/run_job.sh.
# usage: sh tools/lift/jn_rebuild_l5.sh            (run from the repo root)
set -e
R=${REPO:-.}
sh "$R/tools/lift/jn_rebuild.sh"
sh "$R/tools/lift/jn_l5_midi.sh"
echo "jn_rebuild_l5: GREEN"
