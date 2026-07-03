# Build + test for the JUNO-60 C99 port.
CC      ?= cc
CFLAGS  ?= -std=c99 -O2 -Wall -Wextra -Wno-unused-parameter -fno-strict-aliasing
LDLIBS  ?= -lm

SRC     := $(wildcard src/*.c)
OBJ     := $(SRC:.c=.o)

.PHONY: all test clean
all: $(OBJ)

test: tests/test_helpers tests/test_voice_smoke tests/test_master_smoke tests/test_arp_smoke tests/test_regression
	./tests/test_helpers
	./tests/test_voice_smoke
	./tests/test_master_smoke
	./tests/test_arp_smoke
	./tests/test_regression

tests/test_helpers: tests/test_helpers.c $(SRC)
	$(CC) $(CFLAGS) -o $@ $^ $(LDLIBS)

tests/test_voice_smoke: tests/test_voice_smoke.c $(SRC)
	$(CC) $(CFLAGS) -o $@ $^ $(LDLIBS)

tests/test_master_smoke: tests/test_master_smoke.c $(SRC)
	$(CC) $(CFLAGS) -o $@ $^ $(LDLIBS)

# Arpeggiator smoke test (faithful CArpeggio transcription; self-contained).
tests/test_arp_smoke: tests/test_arp_smoke.c src/arp.c src/arp.h
	$(CC) $(CFLAGS) -o $@ tests/test_arp_smoke.c src/arp.c $(LDLIBS)

# Regression guards: rec0 oracle bit-exact, SR-family selection, note-path
# invariants, preset render smoke. Run on every change.
tests/test_regression: tests/test_regression.c $(SRC)
	$(CC) $(CFLAGS) -o $@ $^ $(LDLIBS)

clean:
	rm -f $(OBJ) tests/test_helpers tests/test_voice_smoke tests/test_master_smoke tests/test_arp_smoke tests/test_regression tests/sound_test

# Faithful sound test: run our DSP forward from the live plugin's captured state.
sound: tests/sound_test.c $(SRC)
	gunzip -kf state_dump/state_t0.bin.gz
	$(CC) $(CFLAGS) -o tests/sound_test tests/sound_test.c $(SRC) $(LDLIBS)
	./tests/sound_test state_dump/state_t0.bin /tmp/juno_sound 96000

# Play an actual note (NOTE=midi, default 60) through the full stereo chorus path.
NOTE ?= 60
play: tests/play_note.c $(SRC)
	$(CC) $(CFLAGS) -o tests/play_note tests/play_note.c $(SRC) $(LDLIBS)
	./tests/play_note /tmp/juno_note.wav 4 1.5 $(NOTE)

# Render a scale (proves per-note pitch). `make scale` -> /tmp/juno_scale.wav
scale: tests/play_scale.c $(SRC)
	$(CC) $(CFLAGS) -o tests/play_scale tests/play_scale.c $(SRC) $(LDLIBS)
	./tests/play_scale /tmp/juno_scale.wav 0.55

# Render a chord progression (proves polyphony). `make chord` -> /tmp/juno_chord.wav
chord: tests/play_chord.c $(SRC)
	$(CC) $(CFLAGS) -o tests/play_chord tests/play_chord.c $(SRC) $(LDLIBS)
	./tests/play_chord /tmp/juno_chord.wav

# Render the "SQ Dynamic ARPG" preset overlay (arpeggio + block). -> /tmp/juno_preset*.wav
preset: tests/play_preset.c $(SRC)
	$(CC) $(CFLAGS) -o tests/play_preset tests/play_preset.c $(SRC) $(LDLIBS)
	./tests/play_preset /tmp/juno_preset.wav
	./tests/play_preset /tmp/juno_preset_block.wav block

# Hold a chord through the arpeggiator (UP/DOWN/UP-DOWN, ranges). -> /tmp/juno_arp.wav
# Override: make arp ARGS="up range3 140"
arp: tests/play_arp.c $(SRC)
	$(CC) $(CFLAGS) -o tests/play_arp tests/play_arp.c $(SRC) $(LDLIBS)
	./tests/play_arp /tmp/juno_arp.wav $(ARGS)

# Phase 0 oracle: render port from an event log + A/B vs a plugin reference WAV.
#   make oracle REF=/path/plugin.wav EV=tests/oracle/cmaj_sqarpg.txt
EV ?= tests/oracle/cmaj_sqarpg.txt
oracle: tests/render_events.c $(SRC)
	$(CC) $(CFLAGS) -o tests/render_events tests/render_events.c $(SRC) $(LDLIBS)
	./tests/render_events $(EV) /tmp/port_oracle.wav
	@if [ -f "$(REF)" ]; then python3 tools/ab_compare.py "$(REF)" /tmp/port_oracle.wav; \
	 else echo "(set REF=/path/to/plugin_reference.wav to run the A/B comparison)"; fi

# Capture-free per-sample A/B: run our DSP forward from t0, match t1 (control-rate).
ab: tests/ab_persample.c $(SRC)
	gunzip -kf state_dump/state_t0.bin.gz state_dump/state_t1.bin.gz
	$(CC) $(CFLAGS) -o tests/ab_persample tests/ab_persample.c $(SRC) $(LDLIBS)
	./tests/ab_persample state_dump/state_t0.bin state_dump/state_t1.bin state_dump/.dspreads.txt 20000

# Audio A/B: compare the port's note against a plugin bounce (REF=path to plugin.wav).
# Renders the port note, then diffs envelope / pitch / timbre. See docs/RUN_GUIDE_AUDIO_AB.md.
REF ?= plugin_ref.wav
abwav: tests/play_note.c tests/wav_compare.c $(SRC)
	$(CC) $(CFLAGS) -o tests/play_note tests/play_note.c $(SRC) $(LDLIBS)
	$(CC) $(CFLAGS) -o tests/wav_compare tests/wav_compare.c $(LDLIBS)
	./tests/play_note /tmp/juno_note.wav 4 1.5
	./tests/wav_compare $(REF) /tmp/juno_note.wav

# Smoke test + before/after for the construction-time parameter-default init.
tests/test_init_default: tests/test_init_default.c $(SRC)
	$(CC) $(CFLAGS) -o $@ tests/test_init_default.c $(SRC) $(LDLIBS)

init_default: tests/test_init_default
	./tests/test_init_default

# Validate the port's init against the live-plugin state dump (state_dump/).
validate: tests/validate_state.c $(SRC)
	gunzip -kf state_dump/state_t0.bin.gz state_dump/state_t1.bin.gz
	@python3 -c "import re;\
r=set();\
[r.update(int(m) for m in re.findall(r'a1, ?(\d+)\)',open(f).read())) for f in ('src/voice_render.c','src/master_render.c')];\
[r.update(int(m) for m in re.findall(r'a1 \+ (\d+)\b',open(f).read())) for f in ('src/voice_render.c','src/master_render.c')];\
print('\n'.join(str(o) for o in sorted(o for o in r if 0<o<=12058620)))" > state_dump/.dspreads.txt
	$(CC) $(CFLAGS) -o tests/validate_state tests/validate_state.c $(SRC) $(LDLIBS)
	./tests/validate_state state_dump/state_t0.bin state_dump/state_t1.bin state_dump/.dspreads.txt
