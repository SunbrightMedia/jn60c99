#!/bin/sh
# native_check.sh -- jp8/apps/jp8_render graded against THE NATIVE ORACLE: the real JUPITER-8 plugin on a CPU (its
# own DLL in a Windows process under wine, jp8_native_host.exe), not under Unicorn -- so a denormal result inside the
# plugin's ScopedNoDenormals is flushed as on a PC (scope row 23). Two processes meet only through the plan and the WAV:
#   1. the CLI from the committed lift (jp8/apps/build_render.sh) and the render check's MIDI file (a chord over two
#      tracks, a tempo change, CC 1 / 7 / 11 / 64, pitch bend, channel pressure, a second channel)
#   2. for every rate and patch: the CLI renders (WAV + plan), the native plugin replays the plan through its own
#      process() after its own patch load, and every output word must be equal (jp8_native_check.py)
#   3. determinism: the first run again, natively -- the same bytes
#   4. the teeth, each must FAIL: N1 the WAV with one bit flipped; N2 a port DEFECT -- the CLI built from the lift
#      with the host gate's T1 slip (one addss of the FINE TUNE setter turned subss), its WAV against the native run
#   sh jp8/tools/native/native_check.sh ["patches" = "0 .. 63"] ["rates" = "48000"] [outdir = build/jp8_native]
#   sh jp8/tools/native/native_check.sh full [outdir]     (the 64 patches at 48000, 44100 and 96000; one word, so
#                                                          tools/run_job.sh can run it: it re-parses its command)
# needs: wine64 (or JP8_WINE), x86_64-w64-mingw32-gcc (or JP8_MINGW). exit 0 = every run EXACTLY 0, both teeth bite.
set -e
HERE="$(cd "$(dirname "$0")" && pwd)"; REPO="$(cd "$HERE/../../.." && pwd)"
if [ "${1:-}" = full ]; then PATCHES="$(seq -s ' ' 0 63)"; RATES="48000 44100 96000"; OUT="${2:-$REPO/build/jp8_native}"
else PATCHES="${1:-$(seq -s ' ' 0 63)}"; RATES="${2:-48000}"; OUT="${3:-$REPO/build/jp8_native}"; fi
case "$OUT" in /*) ;; *) echo "outdir must be an absolute path: $OUT"; exit 2;; esac
mkdir -p "$OUT/cli" "$OUT/runs"
echo "=== 1. the CLI and the MIDI file ==="
sh "$REPO/jp8/apps/build_render.sh" "$OUT/cli"
gunzip -c "$REPO/jp8/gen/jp8h_template.bin.gz" > "$OUT/cli/jp8h_template.bin"
python3 "$REPO/jp8/tools/jp8_render_check.py" --write-midi "$OUT/check.mid"
echo "=== 2. the port against the native plugin: rates $RATES; patches $PATCHES ==="
n=0; first=""
for R in $RATES; do
    for P in $PATCHES; do
        W="$OUT/runs/p${P}_$R"
        "$OUT/cli/jp8_render" "$OUT/cli/jp8h_template.bin" "$REPO/jp8/truth/1_Preset.bin" "$P" "$OUT/check.mid" "$W.wav" "$R" 2 "$W.plan" 2> "$W.render.log"
        if ! python3 "$HERE/jp8_native_check.py" "$P" "$W.plan" "$W.wav" "$R" --work "$OUT/work" --keep "$W.native" > "$W.log" 2>&1; then
            tail -n 4 "$W.log"; echo "*** NATIVE CHECK RED: patch $P at $R Hz ***"; exit 1
        fi
        echo "patch $P at $R Hz: $(tail -n 1 "$W.log" | sed 's/.*): //')"
        n=$((n + 1)); [ -n "$first" ] || first="$P $R"
    done
done
set -- $first; P1=$1; R1=$2; W1="$OUT/runs/p${P1}_$R1"
echo "=== 3. determinism: patch $P1 at $R1 Hz natively again ==="
python3 "$HERE/jp8_native_check.py" "$P1" "$W1.plan" "$W1.wav" "$R1" --work "$OUT/work" --keep "$W1.native2" > "$W1.log2" 2>&1
cmp "$W1.native" "$W1.native2"
echo "two native runs: the same $(wc -c < "$W1.native") bytes"
echo "=== 4. the teeth ==="
python3 - "$W1.wav" "$OUT/tooth_n1.wav" <<'EOF'
import sys
w = bytearray(open(sys.argv[1], 'rb').read()); off = 44 + 8 * 100000 + 4      # frame 100000, the right channel
w[off] ^= 1; open(sys.argv[2], 'wb').write(w)
EOF
if python3 "$HERE/jp8_native_check.py" "$P1" "$W1.plan" "$OUT/tooth_n1.wav" "$R1" --against "$W1.native" > "$OUT/tooth_n1.log" 2>&1; then
    echo "*** NATIVE TOOTH N1 DID NOT BITE ***"; exit 1
fi
echo "tooth N1 bites (one bit of the WAV): $(tail -n 1 "$OUT/tooth_n1.log" | sed 's/.*): //')"
python3 - "$REPO/jp8/src/jp8_host_lift.c" "$OUT/lift_t1.c" 38633e <<'EOF'
import sys
src, dst, rva = sys.argv[1], sys.argv[2], int(sys.argv[3], 16)
tag = "/*%x addss " % rva; out = []; n = 0
for line in open(src):
    if tag in line:          # as jp8_host_gate.sh's T1: the statement's first JP8_ADDSS becomes JP8_SUBSS, marked
        stmt = line.split("*/", 1)
        assert len(stmt) == 2 and stmt[1].count("JP8_ADDSS"), line
        line = stmt[0] + "*/ /* TOOTH: + replaced by - */" + stmt[1].replace("JP8_ADDSS", "JP8_SUBSS", 1); n += 1
    out.append(line)
assert n == 1, "tooth site 0x%x found %d times" % (rva, n)
open(dst, "w").write("".join(out))
EOF
JP8_RENDER_LIFT="$OUT/lift_t1.c" sh "$REPO/jp8/apps/build_render.sh" "$OUT/cli_t1" > "$OUT/cli_t1.log" 2>&1
"$OUT/cli_t1/jp8_render" "$OUT/cli/jp8h_template.bin" "$REPO/jp8/truth/1_Preset.bin" "$P1" "$OUT/check.mid" "$OUT/tooth_n2.wav" "$R1" 2 "$OUT/tooth_n2.plan" 2> /dev/null
cmp "$OUT/tooth_n2.plan" "$W1.plan"              # the same host calls: only the port's arithmetic differs
if python3 "$HERE/jp8_native_check.py" "$P1" "$W1.plan" "$OUT/tooth_n2.wav" "$R1" --against "$W1.native" > "$OUT/tooth_n2.log" 2>&1; then
    echo "*** NATIVE TOOTH N2 DID NOT BITE ***"; exit 1
fi
echo "tooth N2 bites (the port with the T1 slip): $(tail -n 1 "$OUT/tooth_n2.log" | sed 's/.*): //')"
echo "JP8 NATIVE CHECK GREEN: $n runs (rates $RATES) EXACTLY 0 against the plugin on a CPU, deterministic, 2 teeth bite"
