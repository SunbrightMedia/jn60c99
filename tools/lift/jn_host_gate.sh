#!/bin/sh
# jn_host_gate.sh -- L5 (init) of the JUNO lift (docs/JUNO_LIFT.md): the lifted JUNO host boots EXACTLY like the
# oracle. It builds libjunohost.so (lift/jn_lift.c + jp8/src/jp8_rt.c + lift/jn_host.c), then in TWO processes
# (the two-process rule): the oracle (Unicorn) dumps the memory after boot_host + setup(48000, 512), and the C side
# (ctypes) runs junoh_init and compares image + heap + host-object arena byte for byte. A tooth (a different rate)
# must make the C side differ. EXACTLY 0 is the bar. More of the host surface (process, state, patch, editor) is
# added to the compare as jn_host.c grows.
# usage: sh tools/lift/jn_host_gate.sh         (run from the repo root)
set -e
R=${REPO:-.}
OUT="$R/build/jn_host"; mkdir -p "$OUT"
[ -f "$R/scratchpad/lift/juno_reach.json" ] || { echo "no L1 census -- run tools/verify/juno_lift_reach.py"; exit 2; }
echo "[1/5] generate the host-flavor lift"
sh "$R/tools/lift/gen_juno_lift.sh"
echo "[2/5] the template (facts + stubs + registers)"
python3 "$R/tools/lift/jn_host_ref.py" "$OUT/jn_host_template.bin" >/dev/null
BASE="-std=c99 -ffp-contract=off -fno-strict-aliasing -fwrapv -fPIC -DJP8_RELOC -DJP8_FLAT -DJP8_GS_BASE=0x580000000ULL -I$R/jp8/src -I$R/lift"
echo "[3/5] build libjunohost.so"
cc $BASE -w -c "$R/lift/jn_lift.c" -o "$OUT/jn_lift.o"
cc $BASE -pedantic-errors -c "$R/jp8/src/jp8_rt.c" -o "$OUT/jn_rt.o"
cc $BASE -pedantic-errors -c "$R/lift/jn_host.c" -o "$OUT/jn_host.o"
cc -shared -o "$OUT/libjunohost.so" "$OUT/jn_lift.o" "$OUT/jn_rt.o" "$OUT/jn_host.o" -lm
echo "[4/5] the oracle reference (Unicorn, a process of its own)"
python3 "$R/tools/lift/jn_host_mem_ref.py" "$OUT/ref"
echo "[5/7] the lifted host vs the oracle after init (ctypes) + the tooth"
python3 "$R/tools/lift/jn_host_mem_c.py" "$OUT/libjunohost.so" "$OUT/jn_host_template.bin" "$OUT/ref"
python3 "$R/tools/lift/jn_host_mem_c.py" "$OUT/libjunohost.so" "$OUT/jn_host_template.bin" "$OUT/ref" --tooth
echo "[6/7] the oracle process() reference (Unicorn, a process of its own)"
python3 "$R/tools/lift/jn_proc_ref.py" "$OUT/proc_ref"
echo "[7/7] the lifted process() output words vs the oracle (ctypes) + the note tooth"
python3 "$R/tools/lift/jn_proc_c.py" "$OUT/libjunohost.so" "$OUT/jn_host_template.bin" "$OUT/proc_ref"
python3 "$R/tools/lift/jn_proc_c.py" "$OUT/libjunohost.so" "$OUT/jn_host_template.bin" "$OUT/proc_ref" --tooth
echo "jn_host_gate: GREEN (init memory + process output words both EXACTLY 0, teeth bite)"
