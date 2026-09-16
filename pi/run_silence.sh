#!/bin/sh
# run_silence.sh — the SHIP-LAW silence probe under QEMU, and its seen-to-fail.
# Builds the JUNO_SILENCE image (boot bank, no notes, 4-core render) and proves
# the idle output is SILENT; then rebuilds with JUNO_SIL_STUCK (a held note) and
# proves the probe verdicts STUCK. A detector that cannot fail is not believed.
#
# Reuses the Circle lib from a prior --qemu --multicore build; run_split.sh or
# run_qemu.sh configures it if needed.
set -e
HERE="$(cd "$(dirname "$0")" && pwd)"
CIRCLE="$HERE/circle"
PREFIX=aarch64-linux-gnu-
K="$HERE/kernel"

sh "$HERE/build_engine.sh" >/dev/null
( cd "$CIRCLE" && ./configure -r 3 -p "$PREFIX" --qemu --multicore -f >/dev/null )
make -C "$CIRCLE/lib" -j"$(nproc)" >/dev/null
make -C "$CIRCLE/lib/sound" -j"$(nproc)" >/dev/null

run () {  # $1 = extra make flags, $2 = out file, $3 = expected verdict
    make -C "$K" clean >/dev/null 2>&1 || true
    make -C "$K" JUNO_SILENCE=1 $1 >/dev/null
    timeout 90 qemu-system-aarch64 -M raspi3b -kernel "$K/kernel8.img" \
        -serial "file:$2" -serial null -display none < /dev/null > /dev/null 2>&1 || true
    grep -E "SIL:|SILENCE PROBE RESULT" "$2" || true
    grep -q "RESULT: $3" "$2"
}

echo ">> silence probe (expect SILENT)"
run ""              "${TMPDIR:-/tmp}/juno_sil_ok.txt"    "SILENT" \
    && echo "PASS: idle is SILENT" || { echo "FAIL: idle not silent"; exit 1; }

echo ">> seen-to-fail: JUNO_SIL_STUCK (expect STUCK)"
run "JUNO_SIL_STUCK=1" "${TMPDIR:-/tmp}/juno_sil_stuck.txt" "STUCK" \
    && echo "PASS: probe catches a stuck idle" || { echo "FAIL: probe did not catch STUCK"; exit 1; }

echo "RESULT: SILENCE PROBE PROVEN (accepts the floor, catches STUCK)"
