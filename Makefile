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

.PHONY: all test clean gui provenance verify completeness
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
# Oracle/generator sources: if ANY is newer than a cached reference pickle, that
# pickle is STALE (it was built by an older oracle) and MUST be regenerated. A
# stale ref silently gates the port against an outdated oracle -- exactly how an
# oracle edit (adding dispatched leaves) could pass unnoticed. Airtight: the ref
# always tracks the code that made it.
ORACLE_DEPS := $(wildcard tools/verify/*.py)
# libjuno.so is a prerequisite so the libjuno-based gates (port_state_dump,
# etmode_ab --port) never test a STALE binary: a src/*.c change that no factory
# patch exercises (e.g. the EFFECT TYPE 4 flanger arm) would otherwise pass every
# gate against an out-of-date library. Caught by etmode_ab.py, 2026-07-22.
verify: test libjuno.so
	@FAIL=0; \
	fresh() { p="$$1"; shift; [ -f "$$p" ] || return 1; for d in "$$@"; do [ "$$p" -nt "$$d" ] || return 1; done; }; \
	fresh $(SCRATCH)/index_cell_map.pkl $(ORACLE_DEPS)    || python3 tools/verify/index_cell_map.py    || FAIL=1; \
	fresh $(SCRATCH)/plugin_recall_ref.pkl $(ORACLE_DEPS) || python3 tools/verify/plugin_recall_ref.py || FAIL=1; \
	fresh $(SCRATCH)/recall_render_ref.pkl $(ORACLE_DEPS) || python3 tools/verify/recall_render_ab.py --ref || FAIL=1; \
	for r in 44100 48000 96000; do fresh $(SCRATCH)/recall_exhaustive_$$r.pkl $(ORACLE_DEPS) || python3 tools/verify/recall_exhaustive_ref.py $$r || FAIL=1; done; \
	python3 tools/verify/port_state_dump.py >/dev/null 2>&1 || FAIL=1; \
	echo "=== LIVE GATE 1/7: recall_gate (port vs plugin's own recall, 64 patches) ==="; \
	python3 tools/verify/recall_gate.py || FAIL=1; \
	echo "=== LIVE GATE 2/7: exhaustive recall (every byte 0..255 x 3 rates) ==="; \
	python3 tools/verify/recall_exhaustive_gate.py || FAIL=1; \
	echo "=== LIVE GATE 3/7: render A/B (port render vs plugin's own render, 57 non-arp) ==="; \
	python3 tools/verify/recall_render_ab.py --port || FAIL=1; \
	echo "=== LIVE GATE 4/7: arp SCHEDULE (plugin's own arp vs carp.c, 7 arp patches) ==="; \
	fresh $(SCRATCH)/arp_sched_ref.pkl $(ORACLE_DEPS) || python3 tools/verify/arp_sched_ab.py --ref || FAIL=1; \
	python3 tools/verify/arp_sched_ab.py --port || FAIL=1; \
	echo "=== LIVE GATE 5/7: arp RENDER (schedule replay into plugin, 7 arp patches) ==="; \
	python3 tools/verify/arp_render_ab.py --port || FAIL=1; \
	python3 tools/verify/arp_render_ab.py --ref || FAIL=1; \
	echo "=== LIVE GATE 6/7: cold-state A/B (port init/prepare vs plugin build+setSR, 5 rates) ==="; \
	for r in 44100 48000 96000 88200 192000; do \
	  python3 tools/verify/coldstate_ab.py --port $$r >/dev/null || FAIL=1; \
	  python3 tools/verify/coldstate_ab.py --ref  $$r || FAIL=1; \
	done; \
	echo "=== LIVE GATE 7/7: render A/B at 44100 + NON-standard 88200 (recall->render chain) ==="; \
	for sr in 44100 88200; do \
	  fresh $(SCRATCH)/recall_render_ref_$$sr.pkl $(ORACLE_DEPS) || JUNO_RENDER_SR=$$sr JUNO_RENDER_REF_PKL=$(SCRATCH)/recall_render_ref_$$sr.pkl python3 tools/verify/recall_render_ab.py --ref || FAIL=1; \
	  JUNO_RENDER_SR=$$sr JUNO_RENDER_REF_PKL=$(SCRATCH)/recall_render_ref_$$sr.pkl python3 tools/verify/recall_render_ab.py --port || FAIL=1; \
	done; \
	echo "=== PILLAR-3: exhaustive fine-FX (port applier vs plugin's own setter, every byte x 4 rates) ==="; \
	fresh $(SCRATCH)/finefx_cellsweep_ref.pkl $(ORACLE_DEPS) || python3 tools/verify/finefx_cellsweep.py || FAIL=1; \
	$(MAKE) -s tools/verify/finefx_port_dump && python3 tools/verify/finefx_pillar3_gate.py || FAIL=1; \
	echo "=== ET-MODE A/B: synthetic EFFECT TYPE 0..5 recall (port vs plugin; no factory patch reaches modes 2-5) ==="; \
	fresh $(SCRATCH)/etmode_ref.pkl $(ORACLE_DEPS) || python3 tools/verify/etmode_ab.py --ref || FAIL=1; \
	python3 tools/verify/etmode_ab.py --port || FAIL=1; \
	echo "=== DIFFERENTIAL FUZZ (SEAL 4 / Pillar-2b): random polyphonic sequences, port vs plugin, 24 seeds x 3 rates ==="; \
	fresh $(SCRATCH)/fuzz_ref.pkl $(ORACLE_DEPS) || python3 tools/verify/fuzz_diff.py --ref || FAIL=1; \
	python3 tools/verify/fuzz_diff.py --port || FAIL=1; \
	echo "=== VOICE ASSIGN (KEY ASSIGN/LEGATO/PORTAMENTO): note SEQUENCES through the plugin's own allocator vs the port's ==="; \
	fresh $(SCRATCH)/assigner_ab_ref.pkl $(ORACLE_DEPS) || python3 tools/verify/assigner_ab.py --ref || FAIL=1; \
	python3 tools/verify/assigner_ab.py --port || FAIL=1; \
	echo "=== RENDER-LOOP STRUCTURE: block-size invariance (1/64/128/512/600) + warm apply-on-running-engine ==="; \
	fresh $(SCRATCH)/renderstruct_ref.pkl $(ORACLE_DEPS) || python3 tools/verify/renderstruct_ab.py --ref || FAIL=1; \
	python3 tools/verify/renderstruct_ab.py --port || FAIL=1; \
	echo "=== #112 HOST-PATH ROLES: which dispatch indices behave differently for a HOST than for RECALL ==="; \
	python3 tools/verify/hostpath_roles.py || FAIL=1; \
	echo "=== #112 HOST MODULATION: port juno_mod_byte vs the plugin's own modulation setters ==="; \
	fresh $(SCRATCH)/hostmod_ref.pkl $(ORACLE_DEPS) || python3 tools/verify/hostmod_gate.py --ref || FAIL=1; \
	python3 tools/verify/hostmod_gate.py --port || FAIL=1; \
	echo "=== PILLAR-1 completeness gate (fresh re-enumeration from binary vs COVERAGE.tsv) ==="; \
	python3 tools/verify/completeness_gate.py || FAIL=1; \
	echo "=== PILLAR-1 DEFERRED-CONTROLLER executed no-op lock (each deferred row proven not engine-reachable) ==="; \
	python3 tools/verify/deferred_noop_gate.py || FAIL=1; \
	echo "=== LEDGER ==="; \
	python3 tools/verify/provenance_check.py || FAIL=1; \
	python3 tools/verify/completeness_scan.py || FAIL=1; \
	exit $$FAIL
provenance:
	python3 tools/verify/provenance_check.py

# PILLAR 1 completeness gate (AIRTIGHT_PLAN.md). Regenerates the value-tree leaf
# enumeration from truth/Script.xml and checks COVERAGE.tsv: RED on any ledger
# drift, any UNRESOLVED/SILENT row, or any GAP (a parameter the port does not
# apply). Standalone for now; folds into `verify` at the Seal (Stage D), once
# the GAP rows are closed. Rebuild the ledger (needs Unicorn) with:
#   python3 tools/verify/leaf_cellmap.py && python3 tools/verify/leaf_cellmap_fx.py \
#     && python3 tools/verify/port_writeset.py && python3 tools/verify/build_coverage.py
completeness:
	python3 tools/verify/completeness_gate.py

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

# Pillar-3 exhaustive fine-FX gate: port-side coefficient dumper (compiled from the
# shipping src/*.c). finefx_pillar3_gate.py diffs it against the oracle reference.
tools/verify/finefx_port_dump: tools/verify/finefx_port_dump.c src/finefx_recall.h src/delay_recall.h $(SRC)
	$(CC) $(CFLAGS) -o $@ tools/verify/finefx_port_dump.c $(SRC) $(LDLIBS)

tests/test_teensy_golden: tests/test_teensy_golden.c tests/teensy_golden.h gui/juno_bridge.c $(SRC)
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
