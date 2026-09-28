#!/bin/sh
# jp8_lift_gates_all.sh -- the three drive2 lift-gate layers in one run (render, recall, boot), one log each.
#   sh tools/run_job.sh jp8_gates_d2 sh jp8/tools/jp8_lift_gates_all.sh
# Reuses existing oracle references when present (JP8_LIFT_SKIP_EMU=1); the boot layer builds its own.
HERE="$(cd "$(dirname "$0")" && pwd)"; LOGS="$HERE/../logs"; rc=0
export JP8_EMU_QUIET=1 JP8_LIFT_SKIP_EMU=1
for L in render recall boot; do
    case $L in render) f=lift_gate_layer1_drive2;; recall) f=lift_gate_layer2_recall_drive2;; boot) f=lift_gate_layer3_boot_drive2;; esac
    JP8_LIFT_LAYER=$L sh "$HERE/jp8_lift_gate.sh" > "$LOGS/$f.log" 2>&1; r=$?
    echo "layer $L exit $r ($(tail -n 1 "$LOGS/$f.log"))"; [ $r = 0 ] || rc=1
done
exit $rc
