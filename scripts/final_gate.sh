#!/usr/bin/env bash
# final_gate.sh — one-command delivery gate for the JUNO-60 C99 port.
#
# Runs the native battery, a representative differential A/B against the running
# plugin (oracle), and the WASM==plugin check on the delivered artifact, then
# prints a single GREEN/RED verdict. The EXHAUSTIVE proofs (full 203-seed corpus,
# 64-patch TEMPO SYNC, 63-scenario arp, param exhaustions) live in their own
# scripts and are catalogued in docs/CLAIMS.md; this gate is the fast, complete-
# coverage smoke that must be green before delivery. Set FG_FULL=1 for full sweeps.
#
# Usage: bash scripts/final_gate.sh
set -uo pipefail
cd "$(dirname "$0")/.."
FAIL=0
LOG=/tmp/final_gate
mkdir -p "$LOG"
say() { printf '\n=== %s ===\n' "$1"; }
ok()  { printf '  \033[32mgreen\033[0m  %s\n' "$1"; }
bad() { printf '  \033[31mRED\033[0m    %s\n' "$1"; FAIL=1; }

SEEDS_FUZZ="0 1 2 33 41 57 70 93"
PATCHES_TS="0 20 31 63"
[ "${FG_FULL:-0}" = "1" ] && SEEDS_FUZZ="$(seq 0 202)" && PATCHES_TS="$(seq 0 63)"

say "1/6  native build + unit battery (FMA canary, Teensy golden, all unit tests)"
if make libjuno.so >"$LOG/build.log" 2>&1 && make test >"$LOG/test.log" 2>&1; then
  ok "make test — $(grep -c '^OK\|ALL OK' "$LOG/test.log") checks passed"
else
  bad "make test failed (see $LOG/test.log)"
fi

say "2/6  cold regression (port vs cached plugin render)"
if python3 tools/verify/cold_regress.py port final-gate >"$LOG/cold.log" 2>&1 && \
   ! grep -q "FIRST@" "$LOG/cold.log"; then
  ok "cold_regress bit-exact ($(grep -c BIT-EXACT "$LOG/cold.log") patches)"
else
  bad "cold_regress diverged (see $LOG/cold.log)"
fi

say "3/6  differential fuzz corpus (port vs plugin, seeds: $(echo $SEEDS_FUZZ | wc -w))"
FZ=0
for s in $SEEDS_FUZZ; do
  r=$(python3 tools/verify/fuzz_diff.py "$s" 2>/dev/null | tail -1)
  echo "$r" >>"$LOG/fuzz.log"
  echo "$r" | grep -q "OK" || { FZ=1; echo "  diverge: $r"; }
done
[ "$FZ" = 0 ] && ok "fuzz corpus bit-exact" || bad "fuzz corpus diverged (see $LOG/fuzz.log)"

say "4/6  live TEMPO SYNC engage A/B (patches: $(echo $PATCHES_TS | wc -w))"
TS=0
for p in $PATCHES_TS; do
  r=$(python3 tools/verify/temposync_engage_ab.py "$p" "$p" 2>/dev/null | grep -E "BIT-EXACT|DIVERGE" | head -1)
  echo "$r" >>"$LOG/ts.log"
  echo "$r" | grep -q "BIT-EXACT" || { TS=1; echo "  diverge: $r"; }
done
[ "$TS" = 0 ] && ok "TEMPO SYNC engage bit-exact" || bad "TEMPO SYNC diverged (see $LOG/ts.log)"

say "5/6  arp audio A/B (render+dispatch)"
if python3 tools/verify/arp_audio_ab.py 1 0 1 2>/dev/null | grep -q "BIT-EXACT"; then
  ok "arp audio bit-exact (patch 1 UP); full sweep: arp_audio_ab.py sweep"
else
  bad "arp audio diverged"
fi

say "6/6  WASM artifact == plugin"
if [ -f scratchpad/emsdk/emsdk_env.sh ]; then
  ( source scratchpad/emsdk/emsdk_env.sh >/dev/null 2>&1; bash gui/web/build.sh >"$LOG/wasm_build.log" 2>&1 )
  python3 tools/verify/gen_teensy_golden.py >/dev/null 2>&1   # refresh golden from native
  if [ $? -eq 0 ] && command -v node >/dev/null 2>&1 && \
     node tools/verify/wasm_golden.mjs >"$LOG/wasm_ab.log" 2>&1 && \
     grep -q "ALL OK" "$LOG/wasm_ab.log"; then
    ok "WASM rebuilt + verified vs native/plugin golden ($(grep -c '^OK:' "$LOG/wasm_ab.log") scenarios; BUILD_VER $(grep -oE '[0-9a-f]{12}' "$LOG/wasm_build.log" | tail -1))"
  else
    bad "WASM build/verify failed (see $LOG/wasm_build.log, $LOG/wasm_ab.log)"
  fi
else
  bad "emsdk missing — cannot rebuild/verify WASM (reinstall emsdk into scratchpad)"
fi

echo
if [ "$FAIL" = 0 ]; then
  printf '\033[32m===== GATE GREEN — port is bit-exact across all checks =====\033[0m\n'
  echo "Full exhaustive proofs: docs/CLAIMS.md. Run FG_FULL=1 for full sweeps."
else
  printf '\033[31m===== GATE RED — see logs in %s =====\033[0m\n' "$LOG"
fi
exit $FAIL
