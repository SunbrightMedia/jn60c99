# Build + test for the JUNO-60 C99 port.
CC      ?= cc
# -ffp-contract=off: FORBID fused multiply-add contraction. The engine's
# bit-exactness is defined against the plugin's x86 SSE2 output, which has NO
# FMA (verified: 0 vfmadd/vfmsub in libjuno.so, and a -ffp-contract=off build is
# byte-identical to the default x86 build). On a target with hardware FMA (the
# Teensy 4.1 / ARM Cortex-M7 VFPv5) the compiler could otherwise fuse a*b+c into a
# single-rounding instruction and silently diverge. This flag keeps every multiply
# and add separately rounded, matching the reference on every target. The FMA
# canary (tests/test_fma_canary.c) fails loudly if contraction ever slips through.
CFLAGS  ?= -std=c99 -O2 -ffp-contract=off -Wall -Wextra -Wno-unused-parameter -Wno-missing-field-initializers -fno-strict-aliasing
LDLIBS  ?= -lm

SRC     := $(wildcard src/*.c)
OBJ     := $(SRC:.c=.o)

.PHONY: all test clean gui provenance verify
all: $(OBJ)

# The honest finish-line gate: functional tests must pass AND the LIVE plugin
# comparisons must pass AND the provenance ledger must have zero CAPTURED /
# unproven rows. `make verify` stays RED while any of those fails, which is the
# point: `make test` merely checks that the code works; `make verify` checks that
# it is PROVEN against the plugin — the comparison actually RUNS, every time.
#
# Reference pickles are the plugin's OWN execution (Unicorn oracle) and live in
# scratchpad/ (ephemeral); when missing they are regenerated from truth/ (slow,
# one-time per container). The port side + diffs re-run fresh each time (seconds).
# Two-process rule: each python3 below is a separate process (oracle vs libjuno).
SCRATCH := $(abspath scratchpad)
verify: test
	@FAIL=0; \
	test -f $(SCRATCH)/index_cell_map.pkl    || python3 tools/verify/index_cell_map.py    || FAIL=1; \
	test -f $(SCRATCH)/plugin_recall_ref.pkl || python3 tools/verify/plugin_recall_ref.py || FAIL=1; \
	test -f $(SCRATCH)/recall_render_ref.pkl || python3 tools/verify/recall_render_ab.py --ref || FAIL=1; \
	python3 tools/verify/port_state_dump.py >/dev/null 2>&1 || FAIL=1; \
	echo "=== LIVE GATE 1/2: recall_gate (port vs plugin's own recall) ==="; \
	python3 tools/verify/recall_gate.py || FAIL=1; \
	echo "=== LIVE GATE 2/2: render A/B (port render vs plugin's own render) ==="; \
	python3 tools/verify/recall_render_ab.py --port || FAIL=1; \
	echo "=== LEDGER ==="; \
	python3 tools/verify/provenance_check.py || FAIL=1; \
	python3 tools/verify/completeness_scan.py || FAIL=1; \
	exit $$FAIL
provenance:
	python3 tools/verify/provenance_check.py

# Shared library for the test GUI (gui/juno_gui.py via ctypes).
gui: libjuno.so
libjuno.so: gui/juno_bridge.c $(SRC)
	$(CC) $(CFLAGS) -shared -fPIC -o $@ $^ $(LDLIBS)

# Windows DLL for the GUI (cross-compile with mingw-w64, or native MinGW).
# -static: no MinGW runtime DLLs needed; imports only KERNEL32 + msvcrt.
# A prebuilt juno.dll is committed so Windows users can run the GUI directly.
CC_WIN ?= x86_64-w64-mingw32-gcc
dll: juno.dll
juno.dll: gui/juno_bridge.c $(SRC)
	$(CC_WIN) $(CFLAGS) -shared -static -o $@ $^ $(LDLIBS)

test: tests/test_fma_canary tests/test_teensy_golden tests/test_voice_alloc tests/test_helpers tests/test_voice_smoke tests/test_master_smoke tests/test_apply_golden tests/test_poly_consistency tests/test_delay_recall tests/test_reverb_recall tests/test_denormal tests/test_note_path tests/test_prepare_rate tests/test_arp_onset tests/test_recall_rate tests/test_arp_release tests/test_bend_mod_sens tests/test_condition_scatter tests/test_arp_pattern tests/test_param_setter
	./tests/test_fma_canary
	./tests/test_teensy_golden
	./tests/test_helpers
	./tests/test_voice_smoke
	./tests/test_master_smoke
	./tests/test_apply_golden
	./tests/test_poly_consistency
	./tests/test_delay_recall
	./tests/test_reverb_recall
	./tests/test_denormal
	./tests/test_note_path
	./tests/test_prepare_rate
	./tests/test_arp_onset
	./tests/test_recall_rate
	./tests/test_arp_release
	./tests/test_bend_mod_sens
	./tests/test_condition_scatter
	./tests/test_arp_pattern
	./tests/test_param_setter
	./tests/test_voice_alloc

tests/test_fma_canary: tests/test_fma_canary.c
	$(CC) $(CFLAGS) -o $@ $< $(LDLIBS)

tests/test_teensy_golden: tests/test_teensy_golden.c gui/juno_bridge.c $(SRC)
	$(CC) $(CFLAGS) -Itests -o $@ tests/test_teensy_golden.c gui/juno_bridge.c $(SRC) $(LDLIBS)

tests/test_param_setter: tests/test_param_setter.c $(SRC)
	$(CC) $(CFLAGS) -o $@ $^ $(LDLIBS)

tests/test_voice_alloc: tests/test_voice_alloc.c $(SRC) gui/juno_bridge.c
	$(CC) $(CFLAGS) -o $@ tests/test_voice_alloc.c gui/juno_bridge.c $(SRC) $(LDLIBS)

tests/test_helpers: tests/test_helpers.c $(SRC)
	$(CC) $(CFLAGS) -o $@ $^ $(LDLIBS)

tests/test_voice_smoke: tests/test_voice_smoke.c $(SRC)
	$(CC) $(CFLAGS) -o $@ $^ $(LDLIBS)

tests/test_master_smoke: tests/test_master_smoke.c $(SRC)
	$(CC) $(CFLAGS) -o $@ $^ $(LDLIBS)

tests/test_apply_golden: tests/test_apply_golden.c $(SRC)
	$(CC) $(CFLAGS) -o $@ $^ $(LDLIBS)

tests/test_poly_consistency: tests/test_poly_consistency.c $(SRC)
	$(CC) $(CFLAGS) -o $@ $^ $(LDLIBS)

tests/test_delay_recall: tests/test_delay_recall.c $(SRC)
	$(CC) $(CFLAGS) -o $@ $^ $(LDLIBS)

tests/test_reverb_recall: tests/test_reverb_recall.c $(SRC)
	$(CC) $(CFLAGS) -o $@ $^ $(LDLIBS)

clean:
	rm -f $(OBJ) tests/test_helpers tests/test_voice_smoke tests/test_master_smoke \
	      tests/test_apply_golden tests/test_poly_consistency tests/test_delay_recall tests/test_reverb_recall tests/test_denormal tests/test_note_path tests/test_prepare_rate tests/test_arp_onset tests/test_recall_rate tests/test_arp_release tests/test_bend_mod_sens tests/test_condition_scatter tests/test_arp_pattern

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

tests/test_denormal: tests/test_denormal.c $(SRC)
	$(CC) $(CFLAGS) -o $@ $^ $(LDLIBS)

tests/test_note_path: tests/test_note_path.c $(SRC)
	$(CC) $(CFLAGS) -o $@ $^ $(LDLIBS)

tests/test_prepare_rate: tests/test_prepare_rate.c $(SRC)
	$(CC) $(CFLAGS) -o $@ $^ $(LDLIBS)

tests/test_arp_onset: tests/test_arp_onset.c $(SRC)
	$(CC) $(CFLAGS) -o $@ $^ $(LDLIBS)

tests/test_recall_rate: tests/test_recall_rate.c $(SRC)
	$(CC) $(CFLAGS) -o $@ $^ $(LDLIBS)

tests/test_arp_release: tests/test_arp_release.c $(SRC)
	$(CC) $(CFLAGS) -o $@ $^ $(LDLIBS)

tests/test_bend_mod_sens: tests/test_bend_mod_sens.c $(SRC)
	$(CC) $(CFLAGS) -o $@ $^ $(LDLIBS)

tests/test_condition_scatter: tests/test_condition_scatter.c $(SRC)
	$(CC) $(CFLAGS) -o $@ $^ $(LDLIBS)

tests/test_arp_pattern: tests/test_arp_pattern.c $(SRC)
	$(CC) $(CFLAGS) -o $@ $^ $(LDLIBS)
