#!/bin/sh
# l3_teeth.sh -- L3's teeth (docs/JUNO_LIFT.md): each planted wrong semantic (tools/lift/l3_cases.py --tooth K) MUST be
# reported by the CPU side; the Unicorn side's own tooth (one flipped input bit) MUST be reported by it; the CPU
# against itself (--self) MUST agree. Builds into build/l3_tooth (the real build/l3 is left as it is).
# usage: sh tools/lift/l3_teeth.sh            (run from the repo root)
set -e
R=$(pwd); T=$R/build/l3_tooth; mkdir -p "$T"
BASE="-std=c99 -ffp-contract=off -fno-strict-aliasing -fwrapv -fPIC -DJP8_RELOC -DJP8_FLAT -DJP8_GS_BASE=0x580000000ULL -I$R/jp8/src -I$R/lift -I$R/tools/lift"
HB="-std=gnu99 -O2 -ffp-contract=off -fno-strict-aliasing -fwrapv -DJP8_RELOC -DJP8_FLAT -DJP8_GS_BASE=0x580000000ULL -I$R/jp8/src -I$R/tools/lift"
cc $HB -c "$R/tools/lift/l3_harness.c" -o "$T/h.o"
fail=0
for k in 1 2 3 4; do
  out=$(python3 "$R/tools/lift/l3_cases.py" --tooth $k --out "$T")
  ci=$(echo "$out" | sed -n 's/.*TOOTH [0-9]* in case \([0-9]*\).*/\1/p')
  cc $BASE -w -c "$T/l3_cases.c" -o "$T/c.o" && cc -o "$T/h" "$T/h.o" "$T/c.o" -lz -lm
  res=$("$T/h" "$T/image.bin" "$T/pool.bin" 64 64 --from "$ci" --to $((ci + 1)) --no-stream 2>&1 | tail -1)
  n=$(echo "$res" | sed -n 's/.*lift != CPU in \([0-9]*\) states.*/\1/p')
  if [ "${n:-0}" -gt 0 ]; then echo "TOOTH $k bit: case $ci, $n of 64 states differ"; else echo "TOOTH $k DID NOT BITE: $res"; fail=1; fi
done
python3 "$R/tools/lift/l3_cases.py" --out "$T" >/dev/null
cc $BASE -w -c "$T/l3_cases.c" -o "$T/c.o" && cc -o "$T/h" "$T/h.o" "$T/c.o" -lz -lm
if "$T/h" "$T/image.bin" "$T/pool.bin" 4 4 --to 4000 --no-stream --self >/dev/null 2>&1; then echo "SELF: the CPU agrees with itself (4000 cases)"; else echo "SELF FAILED"; fail=1; fi
u=$("$T/h" "$T/image.bin" "$T/pool.bin" 4 4 --to 3000 2>/dev/null | python3 "$R/tools/lift/l3_unicorn.py" --cases "$T/l3_cases.json" --tooth | tail -1)
case "$u" in *"Unicorn != CPU: none"*) echo "UNICORN TOOTH DID NOT BITE: $u"; fail=1 ;; *) echo "UNICORN TOOTH bit: $u" ;; esac
exit $fail
