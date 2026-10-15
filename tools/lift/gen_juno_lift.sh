#!/bin/sh
# L2 of the JUNO lift (docs/JUNO_LIFT.md): generate lift/jn_lift.c -- the plugin's own machine code as C99.
# Roots = every function the L1 census reached (scratchpad/lift/juno_reach.json); --dyn resolves indirect calls
# from the same census. The lifter is the proven JP8 one, image-generic via LIFT_BIN (tools are shared, not forked).
# usage: sh tools/lift/gen_juno_lift.sh            (run from the repo root; writes lift/jn_lift.c)
set -e
R=${REPO:-.}
REACH="$R/scratchpad/lift/juno_reach.json"
[ -f "$REACH" ] || { echo "no $REACH -- run tools/verify/juno_lift_reach.py first (L1)"; exit 2; }
ROOTS=$(python3 -c "import json;print(','.join('%#x'%r for r in json.load(open('$REACH'))['functions']))")
LIFT_BIN="$R/truth/JUNO60.vst3" python3 "$R/jp8/tools/jp8_lift.py" "$R/lift/jn_lift.c" "$ROOTS" --dyn "$REACH" --name jn
