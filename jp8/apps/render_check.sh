#!/bin/sh
# render_check.sh -- jp8_render graded against the plugin, end to end, from a fresh clone (two processes: the CLI is
# C, the oracle is jp8_host_emu under Unicorn; they meet only through the plan and the WAV):
#   1. build the CLI from the committed lift (build_render.sh)
#   2. the check's MIDI file (jp8_render_check.py --write-midi: a chord over two tracks, a tempo change, CC 1 / 7 /
#      11 / 64, pitch bend, channel pressure, a second channel, a note-on of velocity 0)
#   3. the shipped template gunzipped (jp8/gen/jp8h_template.bin.gz; the host gate's stage 2b grades it)
#   4. the render, writing its plan (every block's events and parameter points as handed to process())
#   5. the oracle replays the plan through the plugin's own process(): every output word must equal the WAV's
#   6. the tooth: the same WAV with one bit flipped must be seen (exit 1)
#   sh jp8/apps/render_check.sh [patch=2] [rate=48000]        (about 15 min: two oracle runs of ~5 s of audio)
# exit 0 = EXACTLY 0 and the tooth bites.
set -e
HERE="$(cd "$(dirname "$0")" && pwd)"; REPO="$(cd "$HERE/../.." && pwd)"; OUT="$REPO/build/jp8_render"
P="${1:-2}"; R="${2:-48000}"
sh "$HERE/build_render.sh" "$OUT"
python3 "$REPO/jp8/tools/jp8_render_check.py" --write-midi "$OUT/check.mid"
gunzip -c "$REPO/jp8/gen/jp8h_template.bin.gz" > "$OUT/jp8h_template.bin"
"$OUT/jp8_render" "$OUT/jp8h_template.bin" "$REPO/jp8/truth/1_Preset.bin" "$P" "$OUT/check.mid" "$OUT/check.wav" "$R" 2 "$OUT/plan.txt"
python3 "$REPO/jp8/tools/jp8_render_check.py" "$P" "$OUT/plan.txt" "$OUT/check.wav" "$R"
python3 - "$OUT/check.wav" "$OUT/check_tooth.wav" <<'EOF'
import sys
w = bytearray(open(sys.argv[1], 'rb').read()); off = 44 + 8 * 100000 + 4      # frame 100000, the right channel
w[off] ^= 1; open(sys.argv[2], 'wb').write(w)
EOF
if python3 "$REPO/jp8/tools/jp8_render_check.py" "$P" "$OUT/plan.txt" "$OUT/check_tooth.wav" "$R" > "$OUT/tooth.log" 2>&1; then
    echo "*** RENDER TOOTH DID NOT BITE ***"; exit 1
fi
echo "render tooth bites: $(tail -1 "$OUT/tooth.log")"
echo "JP8 RENDER CHECK GREEN (patch $P at $R Hz)"
