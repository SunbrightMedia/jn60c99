#!/bin/sh
# jp8_verify.sh -- the JUPITER-8 FINISH LINE: every gate of the port, in one run, every fact re-derived from the
# checksummed binary (jp8/truth/). Green here == the port is bit-exact for what the gates cover; what they do NOT
# cover is jp8/docs/SCOPE_AUDIT.md (its OPEN rows are printed at the end -- a green run is never "done" alone).
#   A. THE LIFT ON DRIVE2 (jp8_lift_gates_all.sh): the render, recall and boot layers against the drive2 oracle --
#      every output word, the heap and the stack, each layer's tooth.
#   B. THE SELF-BOOTING ENGINE (jp8_full_gate.sh): jp8_engine.c against the drive2 oracle at 44100 and 96000, the
#      checked and the product build, 4 teeth.
#   C. THE HOST PATH (jp8_host_gate.sh): the plugin's own VST3 entries lifted, at the first rates 48000, 44100 and
#      96000 -- the checked, the product and the threaded builds, the teeth.
#   D. MUTATION REACH (jp8_mutation_gate.py) on C's build: one-instruction slips, each counting its runs and changes;
#      exit 0 only when no slip SURVIVED (changed values the gate did not see).
#   E. THE PRODUCT (jp8/apps/render_check.sh): the render CLI built from C's lift, its WAV replayed through the plugin's
#      own process() on the oracle, EXACTLY 0, and its tooth.
# Long: run it as a job from a snapshot (tools/snap_tree.sh):  sh tools/run_job.sh jp8_verify sh jp8/tools/jp8_verify.sh
# env: JP8_VERIFY_SKIP="A B" (sections left out -- printed as SKIPPED, never as green)
HERE="$(cd "$(dirname "$0")" && pwd)"; REPO="$(cd "$HERE/../.." && pwd)"; rc=0
SKIP=" ${JP8_VERIFY_SKIP:-} "
sec() {     # sec <letter> <title> <command...>
    l=$1; t=$2; shift 2
    case "$SKIP" in *" $l "*) echo "=== $l. $t: SKIPPED (JP8_VERIFY_SKIP)"; return 0;; esac
    echo "=== $l. $t ==="
    if "$@"; then echo "=== $l: GREEN"; else echo "=== $l: RED"; rc=1; fi
}
cd "$REPO" || exit 1
( cd jp8/truth && sha256sum -c --quiet SHA256SUMS ) || { echo "jp8/truth/ does not match its SHA256SUMS"; exit 1; }
sec A "the lift on drive2 (render, recall, boot)" sh jp8/tools/jp8_lift_gates_all.sh
sec B "the self-booting engine at 44100" sh jp8/tools/jp8_full_gate.sh
sec B "the self-booting engine at 96000" env JP8_FULL_RATE=96000 sh jp8/tools/jp8_full_gate.sh
sec C "the host path at 48000, 44100, 96000" env JP8_HOST_RATES="48000 44100 96000" sh jp8/tools/jp8_host_gate.sh
sec D "mutation reach on the host path's build" python3 jp8/tools/jp8_mutation_gate.py build/jp8_host/ref_48000 --n 40
sec E "the render CLI against the plugin (patch 2, its tooth)" sh jp8/apps/render_check.sh 2 48000
echo "--- the scope table's OPEN rows (jp8/docs/SCOPE_AUDIT.md): what this run does not prove"
grep -E '^\| [0-9]+ \|' jp8/docs/SCOPE_AUDIT.md | grep -v '\*\*CLOSED' | sed 's/^| \([0-9]*\) | \([^|]*\)| \*\*\([^*]*\)\*\*.*/  row \1 -\2: \3/' | cut -c1-160
[ $rc = 0 ] && echo "JP8 VERIFY GREEN (sections A-E)" || echo "JP8 VERIFY RED"
exit $rc
