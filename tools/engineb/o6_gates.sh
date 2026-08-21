#!/bin/sh
# o6_gates.sh -- EVERY GATE O6 OWNS SO FAR, teeth included.
#
# ⚠ WHAT IS NOT HERE, and must not be forgotten because the list looks full:
#   * THERE IS NO SECOND BOARD. D1 (shared clock, one DAC) and D2 (patch
#     distribution + CRC handshake) cannot be gated at all yet, and the
#     PIN-to-WIRE mapping is UNPROVEN. What follows is LOGIC ONLY.
#     Wiring: docs/engineb/TWO_CHIP_WIRING.md
#   * D3 is proven against the frozen port (`make verify` green with src/
#     touched); D4 is proven only against itself.
#
# usage: sh tools/engineb/o6_gates.sh
set -e
HERE=$(cd "$(dirname "$0")" && pwd)
REPO=$(dirname "$(dirname "$HERE")")
mkdir -p "$REPO/build"
fails=0

printf '\n======== O6/D3 global voice index (2 states) ========\n'
SRC=$(ls "$REPO"/src/*.c | grep -vE 'test_|_main\.c' | tr '\n' ' ')
cc -std=c99 -O1 -w -ffp-contract=off -I "$REPO/src" -DD3_FIXED \
   -o "$REPO/build/d3gate" "$HERE/d3_voiceindex_gate.c" $SRC -lm
"$REPO/build/d3gate" "$REPO/truth/presetbankog1.bin" | tail -3 || fails=$((fails+1))
# THE TOOTH: built WITHOUT the fix, the same gate must go red. A detector that
# has never been seen to fail is not believed (playbook 1).
cc -std=c99 -O1 -w -ffp-contract=off -I "$REPO/src" \
   -o "$REPO/build/d3gate_unfixed" "$HERE/d3_voiceindex_gate.c" $SRC -lm
if "$REPO/build/d3gate_unfixed" "$REPO/truth/presetbankog1.bin" >/dev/null 2>&1; then
    printf '   *** D3 TOOTH NOT CAUGHT: the gate passes WITHOUT the fix.\n'; fails=$((fails+1))
else
    printf '   D3 tooth caught (red without juno_apply_*_at)\n'
fi

printf '\n======== O6/D4 role by strap pin (13 checks, 3 teeth) ========\n'
cc -std=c99 -O1 -Wall -Wextra -I "$REPO/esp32s3/main" \
   -o "$REPO/build/d4gate" "$HERE/d4_role_gate.c"
"$REPO/build/d4gate" | tail -4 || fails=$((fails+1))
for t in 1 2 3; do
    if "$REPO/build/d4gate" "$t" >/dev/null 2>&1; then
        printf '   tooth %s NOT CAUGHT\n' "$t"; fails=$((fails+1))
    else
        printf '   tooth %s caught\n' "$t"
    fi
done

printf '\n======== O6/D1+D2 link table + handshake (20 checks, 3 teeth) ========\n'
cc -std=c99 -O1 -Wall -Wextra -Wno-unused-function -I "$REPO/esp32s3/main" \
   -o "$REPO/build/d1gate" "$HERE/d1_link_gate.c"
"$REPO/build/d1gate" | tail -3 || fails=$((fails+1))
for t in 1 2 3 4 5 6 7; do
    if "$REPO/build/d1gate" "$t" >/dev/null 2>&1; then
        printf '   tooth %s NOT CAUGHT\n' "$t"; fails=$((fails+1))
    else
        printf '   tooth %s caught\n' "$t"
    fi
done

printf '\n========================================\n'
if [ "$fails" -eq 0 ]; then
    echo "O6 GATES: ALL GREEN, every tooth caught."
    echo "   D3 proven against the frozen port. D4 proven against itself only."
    echo "   D1/D2 LOGIC gated. NO WIRE EXISTS: pins, peripherals, UART UNPROVEN."
else
    echo "O6 GATES: $fails RED."; exit 1
fi
