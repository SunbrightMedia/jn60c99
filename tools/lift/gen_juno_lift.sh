#!/bin/sh
# L2/L4 of the JUNO lift (docs/JUNO_LIFT.md): generate lift/jn_lift.c -- the plugin's own machine code as C99, in the
# HOST flavor (the twin of jp8_host_gate.sh's lift call). Roots = every function the L1 census reached
# (scratchpad/lift/juno_reach.json); --dyn resolves indirect calls from the same census. The lifter is the proven JP8
# one, image-generic via LIFT_BIN (tools are shared, not forked). Host-flavor flags:
#   --hostcalls        every import / COM-object stub call routes to jn_host.c's jp8_hostcall (not the generic shim)
#   --alloc 0x67522C --alloc-tailcall   the CRT allocator (e2e_emu ALLOC): its body is jp8_alloc(c); a jmp to it too
#   --replace 0x3C7400 the engine render's thread transport (CWaveGen vt+56) is served by the host (jp8_hook): the
#                      oracle stops at its entry and composes the render over the plugin's own voice/master, so does
#                      jn_host.c (the JUNO twin of jp8_host.c's thread transport; the DSP under it is the lifted code)
# usage: sh tools/lift/gen_juno_lift.sh            (run from the repo root; writes lift/jn_lift.c)
set -e
R=${REPO:-.}
REACH="$R/scratchpad/lift/juno_reach.json"
[ -f "$REACH" ] || { echo "no $REACH -- run tools/verify/juno_lift_reach.py first (L1)"; exit 2; }
ROOTS=$(python3 -c "import json;print(','.join('%#x'%r for r in json.load(open('$REACH'))['functions']))")
# the plugin's own code reached by an indirect transfer with no pdata of its own: adjustor/ILT thunks (pdata gaps)
# AND interior indirect-call/jmp targets (from the census edges). Not pdata starts, so added as roots explicitly.
EXTRA=$(python3 "$R/tools/lift/jn_extra_roots.py" "$REACH")
[ -n "$EXTRA" ] && ROOTS="$ROOTS,$EXTRA"
BIN=$(python3 -c "import sys;sys.path.insert(0,'$R/tools/verify');import truth;print(truth.VST3)")
LIFT_BIN="$BIN" python3 "$R/jp8/tools/jp8_lift.py" "$R/lift/jn_lift.c" "$ROOTS" --dyn "$REACH" \
    --name jn --hostcalls --alloc 0x67522C --alloc-tailcall --replace 0x3c7400
