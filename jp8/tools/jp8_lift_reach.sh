#!/bin/sh
# jp8_lift_reach.sh -- the REACH of the lifted code (charter section 5): every factory patch through the layer-1 drive
# (render + note path), one patch at a time through the SAME oracle/C pair as jp8_lift_gate.sh (the library must already be
# built by the gate). One verdict line per patch into jp8/logs/lift_reach64.log; exit 0 only when all 64 are EXACTLY 0.
#   sh tools/run_job.sh jp8_lift_reach64 sh jp8/tools/jp8_lift_reach.sh
set -u
HERE="$(cd "$(dirname "$0")" && pwd)"; REPO="$(cd "$HERE/../.." && pwd)"; OUT="$REPO/build/jp8_lift"; LOG="$REPO/jp8/logs/lift_reach64.log"
export JP8_LIFT_LAYER=render JP8_EMU_QUIET=1
: > "$LOG"; ok=0
for p in $(seq 0 63); do
    export JP8_LIFT_PATCHES=$p; rm -rf "$OUT/reach"
    if python3 "$HERE/jp8_lift_emu.py" "$OUT/reach" > "$OUT/reach_emu.log" 2>&1 && python3 "$HERE/jp8_lift_c.py" "$OUT/reach" "$OUT/libjp8lift.so" > "$OUT/reach_c.log" 2>&1; then
        echo "patch $p: $(grep 'A/B' "$OUT/reach_c.log")" >> "$LOG"; ok=$((ok+1))
    else
        echo "patch $p: FAIL -- $(grep -m1 'TRAP\|differ\|Traceback\|Error' "$OUT/reach_c.log" "$OUT/reach_emu.log" | head -1)" >> "$LOG"
    fi
done
rm -rf "$OUT/reach"
echo "JP8 LIFT REACH: $ok / 64 patches EXACTLY 0" >> "$LOG"; tail -1 "$LOG"
[ "$ok" = 64 ]
