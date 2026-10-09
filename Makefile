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
# HEADERS ARE BUILD INPUTS, NOT DOCUMENTATION. Constant TABLES live in headers
# (juno_tables.h, chorus_luts.h, effect_luts.h, finefx_tables.h, carp_patterns.h,
# hpf_type_lut.h): a coefficient edit that touches ONLY a header used to rebuild
# NOTHING, so every test binary and libjuno.so silently kept testing the old
# constants -- a false-green generator of exactly the class that bit this project
# twice on 2026-07-31. Every link rule below lists $(HDR); recipes use
# $(filter %.c,$^) so the headers stay prerequisites without reaching the driver.
HDR     := $(wildcard src/*.h) $(wildcard gui/*.h)
OBJ     := $(SRC:.c=.o)
$(OBJ): $(HDR)

.PHONY: all test clean gui provenance verify static completeness engineb engineb-quick verify-jx3p webapp native
all: $(OBJ)

# JX-3P port finish line: recall (C==oracle) + integration render (voice+master
# C==plugin) across 3 rates, all EXACTLY 0. Self-proving from the checksummed
# JX3P.vst3. Override coverage with JX_VERIFY_RATES / JX_VERIFY_N / JX_VERIFY_PATCHES.
verify-jx3p:
	sh jx3p/tools/jx_verify.sh

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
# The static and ledger gates of `make verify`, alone: seconds, no oracle. Run
# `make test static` before EVERY commit (playbook 119): on 2026-10-05 four of
# them went red across three commits, unseen, because only the gate being worked
# on was run.
STATIC_GATES := pathcheck shadow_bounds_gate shadow_sync_gate completeness_gate deferred_noop_gate approx_audit provenance_check completeness_scan reinit_check
static: libjuno.so
	@mkdir -p $(SCRATCH); FAIL=0; for g in $(STATIC_GATES); do \
	  if python3 tools/verify/$$g.py > $(SCRATCH)/static_$$g.log 2>&1; then echo "  ok   $$g"; \
	  else echo "  RED  $$g  (log: $(SCRATCH)/static_$$g.log)"; FAIL=1; fi; \
	done; exit $$FAIL

verify: test libjuno.so
	@FAIL=0; \
	mkdir -p $(SCRATCH); \
	python3 tools/verify/pathcheck.py || FAIL=1; \
	newest=$$(ls -t $(ORACLE_DEPS) | head -1); \
	fresh() { [ -f "$$1" ] && [ "$$1" -nt "$$newest" ]; }; \
	fresh $(SCRATCH)/index_cell_map.pkl || python3 tools/verify/index_cell_map.py || FAIL=1; \
	fresh $(SCRATCH)/plugin_recall_ref.pkl || python3 tools/verify/plugin_recall_ref.py || FAIL=1; \
	fresh $(SCRATCH)/recall_render_ref.pkl || python3 tools/verify/recall_render_ab.py --ref || FAIL=1; \
	for r in 8000 11025 16000 22050 32000 37800 44100 47999 48000 50000 64000 88200 96000 96001 176400 192000 352800 384000; do fresh $(SCRATCH)/recall_exhaustive_$$r.pkl || python3 tools/verify/recall_exhaustive_ref.py $$r || FAIL=1; done; \
	python3 tools/verify/port_state_dump.py >/dev/null 2>&1 || FAIL=1; \
	echo "=== LIVE GATE 1/7: recall_gate (port vs plugin's own recall, 64 patches) ==="; \
	python3 tools/verify/recall_gate.py || FAIL=1; \
	echo "=== LIVE GATE 2/7: exhaustive recall (every byte 0..255 x 18 rates) ==="; \
	python3 tools/verify/recall_exhaustive_gate.py || FAIL=1; \
	echo "=== RATE SWEEP (CLAIMS A13/B4): whole object after recall + renders, 64 patches x 18 host rates ==="; \
	fresh $(SCRATCH)/rate_sweep_ref.pkl || python3 tools/verify/rate_sweep_gate.py --ref || FAIL=1; \
	python3 tools/verify/rate_sweep_gate.py --port || FAIL=1; \
	echo "=== LIVE GATE 3/7: render A/B (port render vs plugin's own render, 57 non-arp) ==="; \
	python3 tools/verify/recall_render_ab.py --port || FAIL=1; \
	echo "=== LIVE GATE 4/7: arp SCHEDULE (plugin's own arp vs carp.c, 7 arp patches) ==="; \
	fresh $(SCRATCH)/arp_sched_ref.pkl || python3 tools/verify/arp_sched_ab.py --ref || FAIL=1; \
	python3 tools/verify/arp_sched_ab.py --port || FAIL=1; \
	echo "=== LIVE GATE 5/7: arp RENDER (schedule replay into plugin, 7 arp patches) ==="; \
	python3 tools/verify/arp_render_ab.py --port || FAIL=1; \
	python3 tools/verify/arp_render_ab.py --ref || FAIL=1; \
	echo "=== HOST PROCESS (CLAIMS B14): the plugin's own process() == the trusted engine path, then the render driver (arp clock, tempo, offsets, the arp controller), 5 chains ==="; \
	python3 tools/verify/host_process_gate.py --control || FAIL=1; \
	fresh $(SCRATCH)/host_process_ref.pkl || python3 tools/verify/host_process_gate.py --ref || FAIL=1; \
	python3 tools/verify/host_process_gate.py --port || FAIL=1; \
	fresh $(SCRATCH)/midi_ctl_ref.pkl || python3 tools/verify/midi_ctl_gate.py --ref || FAIL=1; \
	python3 tools/verify/midi_ctl_gate.py --port || FAIL=1; \
	fresh $(SCRATCH)/host_rate_ref.pkl || python3 tools/verify/host_rate_gate.py --ref || FAIL=1; \
	python3 tools/verify/host_rate_gate.py --port || FAIL=1; \
	fresh $(SCRATCH)/boot_ref.pkl || python3 tools/verify/boot_gate.py --ref || FAIL=1; \
	python3 tools/verify/boot_gate.py --port || FAIL=1; \
	fresh $(SCRATCH)/rate_switch_ref.pkl || python3 tools/verify/rate_switch_gate.py --ref || FAIL=1; \
	python3 tools/verify/rate_switch_gate.py --port || FAIL=1; \
	fresh $(SCRATCH)/ccmap_state_ref.pkl || python3 tools/verify/ccmap_state_gate.py --ref || FAIL=1; \
	python3 tools/verify/ccmap_state_gate.py --port || FAIL=1; \
	fresh $(SCRATCH)/state_save_ref.pkl || python3 tools/verify/state_save_gate.py --ref || FAIL=1; \
	python3 tools/verify/state_save_gate.py --port || FAIL=1; \
	{ fresh $(SCRATCH)/product_bank_ref_44100.pkl && fresh $(SCRATCH)/product_bank_ref_48000.pkl; } || python3 tools/verify/bank_product_gate.py --ref --jobs 3 || FAIL=1; \
	python3 tools/verify/bank_product_gate.py --port || FAIL=1; \
	echo "=== LIVE GATE 6/7: cold-state A/B (port init/prepare vs plugin build+setSR, 18 rates) ==="; \
	for r in 8000 11025 16000 22050 32000 37800 44100 47999 48000 50000 64000 88200 96000 96001 176400 192000 352800 384000; do \
	  python3 tools/verify/coldstate_ab.py --port $$r || FAIL=1; \
	  python3 tools/verify/coldstate_ab.py --ref  $$r || FAIL=1; \
	done; \
	echo "=== LIVE GATE 7/7: render A/B at 44100 + NON-standard 88200 (recall->render chain) ==="; \
	for sr in 44100 88200; do \
	  fresh $(SCRATCH)/recall_render_ref_$$sr.pkl || JUNO_RENDER_SR=$$sr JUNO_RENDER_REF_PKL=$(SCRATCH)/recall_render_ref_$$sr.pkl python3 tools/verify/recall_render_ab.py --ref || FAIL=1; \
	  JUNO_RENDER_SR=$$sr JUNO_RENDER_REF_PKL=$(SCRATCH)/recall_render_ref_$$sr.pkl python3 tools/verify/recall_render_ab.py --port || FAIL=1; \
	done; \
	echo "=== PILLAR-3: exhaustive fine-FX (port applier vs plugin's own setter, every byte x 18 rates x 9 contexts) ==="; \
	fresh $(SCRATCH)/finefx_cellsweep_ref.pkl || python3 tools/verify/finefx_cellsweep.py || FAIL=1; \
	$(MAKE) -s tools/verify/finefx_port_dump && python3 tools/verify/finefx_pillar3_gate.py || FAIL=1; \
	echo "=== ET-MODE A/B: synthetic EFFECT TYPE 0..5 recall (port vs plugin; no factory patch reaches modes 2-5) ==="; \
	fresh $(SCRATCH)/etmode_ref.pkl || python3 tools/verify/etmode_ab.py --ref || FAIL=1; \
	python3 tools/verify/etmode_ab.py --port || FAIL=1; \
	echo "=== EFFECT PARAMS: DEPTH + TONE, every byte x EFFECT TYPE 0..5/6/255 x 3 rates, dispatched AND fresh recall (whole object + render) ==="; \
	fresh $(SCRATCH)/effect_param_ref.pkl || python3 tools/verify/effect_param_gate.py --ref || FAIL=1; \
	python3 tools/verify/effect_param_gate.py --port || FAIL=1; \
	echo "=== FLANGER (DELAY TYPE 4) LEAVES: every byte of 18 leaves x 2 contexts x 3 rates, fresh recall (whole object + render) ==="; \
	fresh $(SCRATCH)/fx_leaf_flanger_ref.pkl || python3 tools/verify/fx_leaf_gate.py --ref flanger || FAIL=1; \
	python3 tools/verify/fx_leaf_gate.py --port flanger --recall-only || FAIL=1; \
	echo "=== SEEDED RECALL: 60 legal seeds (+30 wild, reported: CLAIMS B8), every recalled leaf random, whole object + render, 3 rates ==="; \
	fresh $(SCRATCH)/seed_recall_ref.pkl || python3 tools/verify/seed_recall_gate.py --ref || FAIL=1; \
	python3 tools/verify/seed_recall_gate.py --port || FAIL=1; \
	echo "=== WARM RECALL: N recalls through ONE engine, plugin vs port (every gate above recalls COLD) ==="; \
	echo "    p39,40 CARRY / p1,9 WRITE (the two directions of the chorus WET law) and p0,0 (the"; \
	echo "    IDENTITY case), each judged on the WHOLE state since CLAIMS A17 (2026-10-05). MEASURED"; \
	echo "    on fresh references: p1,9's 102608/102656 were the slot-1 patch-change sequence (red at"; \
	echo "    481bc99, green with src/delay_recall.c slot1_stale/slot1_off); p39,40 was already green."; \
	for s in 39,40 1,9 0,0; do \
	  wp=$(SCRATCH)/warm_recall_`echo $$s | tr , -`_44100.pkl; \
	  fresh $$wp || python3 tools/verify/warm_recall_gate.py --ref --seq $$s --cells 91232 || FAIL=1; \
	  python3 tools/verify/warm_recall_gate.py --port --seq $$s --cells 91232 || FAIL=1; \
	done; \
	echo "=== WARM CHAINS (CLAIMS A17/B1): 22 chains of recalls through ONE engine (type variants, legal seeds, DELAY LEVEL edges), whole object after every step, 3 rates ==="; \
	fresh $(SCRATCH)/warm_chain_ref.pkl || python3 tools/verify/warm_chain_gate.py --ref || FAIL=1; \
	python3 tools/verify/warm_chain_gate.py --port || FAIL=1; \
	echo "=== WARM RENDER (CLAIMS A18/B1): patch changes on a RUNNING engine, notes + renders between recalls, audio + rendered state, settled recall model ==="; \
	fresh $(SCRATCH)/warm_render_settled.pkl || python3 tools/verify/warm_render_gate.py --ref settled || FAIL=1; \
	python3 tools/verify/warm_render_gate.py --port settled || FAIL=1; \
	echo "=== WARM RENDER LIVE (CLAIMS A19): the same chains with the plugin's recall ramps NOT settled (4/24/36 ms), port juno_gui_apply_bank_live ==="; \
	fresh $(SCRATCH)/warm_render_live.pkl || python3 tools/verify/warm_render_gate.py --ref live || FAIL=1; \
	python3 tools/verify/warm_render_gate.py --port live || FAIL=1; \
	echo "=== HOST-ROLE EDITS: DAW automation through the plugin's host entry, no snap (CLAIMS A20) ==="; \
	fresh $(SCRATCH)/host_edit_ref.pkl || python3 tools/verify/host_edit_gate.py --ref || FAIL=1; \
	python3 tools/verify/host_edit_gate.py --port || FAIL=1; \
	echo "=== HOST EDIT SCRATCH (CLAIMS A35): only the recall's cells per edit -- randomized outside them == the full copy, 172 patches ==="; \
	python3 tools/verify/edit_cover_gate.py || FAIL=1; \
	echo "=== KEY HOLD AND THE KEYBOARD NOTE VALUE (CLAIMS A36): the UI timer's notes, the release at every patch change, the keyboard's writes ==="; \
	fresh $(SCRATCH)/keyhold_ref.pkl || python3 tools/verify/keyhold_gate.py --ref || FAIL=1; \
	python3 tools/verify/keyhold_gate.py --port || FAIL=1; \
	python3 tools/verify/keyhold_gate.py --port-tooth || FAIL=1; \
	echo "=== THE LFO LED AND THE LEVEL METERS (CLAIMS A37): the plugin's store, peaks, reads, frame, tick and draw, part 1 and the running plugin ==="; \
	fresh $(SCRATCH)/led_meter_ref.pkl || python3 tools/verify/led_meter_gate.py --ref || FAIL=1; \
	python3 tools/verify/led_meter_gate.py --port || FAIL=1; \
	python3 tools/verify/led_meter_gate.py --port-tooth || FAIL=1; \
	echo "=== THE PATCH WINDOW (CLAIMS A39): the plugin's patch manager -- keys, buttons, list and bank name mouse, dialogs, files, histories, model calls after every command, plugin vs port; 19 teeth ==="; \
	for sp in 9:40 1:200 2:200 3:200 4:200 5:200 6:200 7:200 100:200; do \
	  s=$${sp%%:*}; n=$${sp##*:}; \
	  fresh $(SCRATCH)/patch_manager_ref2_$${s}_$${n}.pkl || rm -f $(SCRATCH)/patch_manager_ref2_$${s}_$${n}.pkl; \
	  python3 tools/verify/patch_manager_gate.py --seed $$s --steps $$n > $(SCRATCH)/pm_gate_$$s.log 2>&1 || FAIL=1; \
	  grep -v '^REACH' $(SCRATCH)/pm_gate_$$s.log | tail -5; \
	done; \
	for ts in 1:9:40 2:5:200 3:9:40 4:1:200 5:6:200 6:9:40 7:9:40 8:100:200 9:9:40 10:9:40 11:9:40 12:9:40 13:9:40 14:9:40 15:9:40 16:1:200 17:9:40 18:9:40 19:1:200; do \
	  t=$${ts%%:*}; r=$${ts#*:}; \
	  python3 tools/verify/patch_manager_gate.py --seed $${r%%:*} --steps $${r##*:} --tooth $$t > $(SCRATCH)/pm_tooth_$$t.log 2>&1 || { echo "patch manager tooth $$t DID NOT BITE"; FAIL=1; }; \
	  tail -1 $(SCRATCH)/pm_tooth_$$t.log; \
	done; \
	echo "=== THE WINDOW ZOOM (CLAIMS A40): a window's fit to the screen -- the plugin's getter and fit, its editor attached, vs the port's; 16 screens; 4 teeth ==="; \
	fresh $(SCRATCH)/zoom_fit_ref.pkl || python3 tools/verify/zoom_fit_gate.py --ref || FAIL=1; \
	python3 tools/verify/zoom_fit_gate.py --port || FAIL=1; \
	python3 tools/verify/zoom_fit_gate.py --port-tooth || FAIL=1; \
	echo "=== REINIT == CREATE: juno_gui_reinit leaves a fresh context (state save, CCs, a learn, the keyboard note value, a render) ==="; \
	python3 tools/verify/reinit_check.py || FAIL=1; \
	echo "=== VOICE COUNT (CLAIMS B10): the shipped 6 voices, counts 1..9 changed while notes sound, audio + rendered state incl. stopped units ==="; \
	fresh $(SCRATCH)/voice_count_ref.pkl || python3 tools/verify/voice_count_gate.py --ref || FAIL=1; \
	python3 tools/verify/voice_count_gate.py --port || FAIL=1; \
	echo "=== PLUGIN PRESET PATHS (CLAIMS A22): initialize / setState / patch-browser load, the plugin's own queues through the host entry ==="; \
	fresh $(SCRATCH)/state_load_ref.pkl || python3 tools/verify/state_load_gate.py --ref || FAIL=1; \
	python3 tools/verify/state_load_gate.py --port || FAIL=1; \
	echo "=== WRAPPER VELOCITY (CLAIMS A23): the MIDI note intake and its velocity switch, the plugin's own push, byte for byte ==="; \
	fresh $(SCRATCH)/wrapper_velocity_ref.pkl || python3 tools/verify/wrapper_velocity_gate.py --ref || FAIL=1; \
	python3 tools/verify/wrapper_velocity_gate.py --port || FAIL=1; \
	echo "=== SHADOW CELLS: bounds (cannot false-fail an A/B) + WRITER-SET invariant (prog == clamp(shadow)) ==="; \
	python3 tools/verify/shadow_bounds_gate.py || FAIL=1; \
	python3 tools/verify/shadow_sync_gate.py || FAIL=1; \
	echo "=== DIFFERENTIAL FUZZ (SEAL 4 / Pillar-2b): random polyphonic sequences, port vs plugin, 24 seeds x 3 rates ==="; \
	fresh $(SCRATCH)/fuzz_ref.pkl || python3 tools/verify/fuzz_diff.py --ref || FAIL=1; \
	python3 tools/verify/fuzz_diff.py --port || FAIL=1; \
	echo "=== ALL-VOICE NOTE STATE (CLAIMS A11/B3): every voice's whole state after every note event, plugin vs port ==="; \
	fresh $(SCRATCH)/note_bcast_ref.pkl || python3 tools/verify/note_bcast_gate.py --ref || FAIL=1; \
	python3 tools/verify/note_bcast_gate.py --port || FAIL=1; \
	echo "=== VOICE STEAL (CLAIMS A12/B2): more held notes than voices, audio + every voice's state, plugin vs port ==="; \
	fresh $(SCRATCH)/steal_ref.pkl || python3 tools/verify/steal_gate.py --ref || FAIL=1; \
	python3 tools/verify/steal_gate.py --port || FAIL=1; \
	echo "=== COLD/WARM UNISON: the app must not present the phase-aligned cold engine (docs/COLDSTART_UNISON_FINDING.md) ==="; \
	python3 tools/verify/coldwarm_unison.py || FAIL=1; \
	echo "=== VOICE ASSIGN (KEY ASSIGN/LEGATO/PORTAMENTO): note SEQUENCES through the plugin's own allocator vs the port's ==="; \
	fresh $(SCRATCH)/assigner_ab_ref.pkl || python3 tools/verify/assigner_ab.py --ref || FAIL=1; \
	python3 tools/verify/assigner_ab.py --port || FAIL=1; \
	echo "=== RENDER-LOOP STRUCTURE: block-size invariance (1/64/128/512/600) + warm apply-on-running-engine ==="; \
	fresh $(SCRATCH)/renderstruct_ref.pkl || python3 tools/verify/renderstruct_ab.py --ref || FAIL=1; \
	python3 tools/verify/renderstruct_ab.py --port || FAIL=1; \
	echo "=== #112 HOST-PATH ROLES: which dispatch indices behave differently for a HOST than for RECALL ==="; \
	python3 tools/verify/hostpath_roles.py || FAIL=1; \
	echo "=== #112 HOST MODULATION: port juno_mod_byte vs the plugin's own modulation setters ==="; \
	fresh $(SCRATCH)/hostmod_ref.pkl || python3 tools/verify/hostmod_gate.py --ref || FAIL=1; \
	python3 tools/verify/hostmod_gate.py --port || FAIL=1; \
	echo "=== PILLAR-1 completeness gate (fresh re-enumeration from binary vs COVERAGE.tsv) ==="; \
	python3 tools/verify/completeness_gate.py || FAIL=1; \
	echo "=== PILLAR-1 DEFERRED-CONTROLLER executed no-op lock (each deferred row proven not engine-reachable) ==="; \
	python3 tools/verify/deferred_noop_gate.py || FAIL=1; \
	echo "=== ARM/EMBEDDED: same corpus, ARM32 under qemu + bare-metal M7 compile (#144) ==="; \
	bash tools/embed/arm_golden.sh; rc=$$?; \
	if [ $$rc -eq 3 ]; then echo "SKIP: ARM cross toolchain absent (apt-get install gcc-arm-linux-gnueabihf qemu-user-static gcc-arm-none-eabi) -- NOT a pass"; \
	elif [ $$rc -ne 0 ]; then FAIL=1; fi; \
	echo "=== LEDGER ==="; \
	echo "=== APPROXIMATION AUDIT (zero approximations in the port) ==="; \
	python3 tools/verify/approx_audit.py || FAIL=1; \
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

# The web app (gui/web): build the WASM, then grade the DELIVERED artifact --
# the recall corpus (wasm_golden.mjs), the app's own calls native vs WASM with
# a reach guard (wasm_product_gate.py), and the bundled page in headless
# Chromium (real audio, no console errors). Needs emcc on PATH (source
# emsdk_env.sh) and playwright-core resolvable by node. `env node`: emsdk_env.sh
# puts the emsdk folder, which holds a DIRECTORY named node, first on PATH, and
# make's own PATH search stops there ("node: Permission denied"). skin_kb_check holds the
# skin's keyboard equal to JUNO-60.exe's: it needs `make native` first, and Wine.
# JUNO-60.exe (gui/win, CLAIMS C6): built into scratchpad/dist/ -- it embeds Roland's
# artwork and the user's banks, LOCAL ONLY. Needs mingw-w64; the checks need Wine
# (WINEPREFIX) or Windows. exe_oracle_check plays 8 seeded performances through the
# program's own inputs into THE PLUGIN ITSELF (Unicorn), then its tooth: every seed
# must FAIL. cc_menu_gate runs the plugin's own right-button handler on the plugin's own
# panel tree against the program's CC assign menu (CLAIMS A38); its teeth are builds
# with -DCC_TOOTH=N (1 and 8 cannot bite: the search order is not observable here).
# The program's own teeth (-DEXE_TOOTH=n): 1 a hidden LED not updated (the LED show rule),
# 2 no window zoom conversion at the patch window's open. exe_pm_check plays the patch
# manager gate's references through the program's patch window (CLAIMS A39); the web
# target's skin_pm_check plays them through the page's, with teeth on the page's code.
native: libjuno.so
	python3 tools/dist/make_native.py
	python3 tools/dist/native_check.py
	for t in replay glue tick cc; do if python3 tools/dist/native_check.py --tooth $$t; then echo "native_check tooth $$t DID NOT BITE"; exit 1; fi; done
	python3 tools/dist/exe_oracle_check.py --exe scratchpad/dist/JUNO-60.exe --seeds 1,2,3,4,5,6,7,8
	python3 tools/dist/exe_oracle_check.py --exe scratchpad/dist/JUNO-60.exe --seeds 1,2,3,4,5 --tooth
	python3 tools/dist/exe_oracle_check.py --exe scratchpad/dist/JUNO-60.exe --seeds 1,2,4 --tooth cc
	python3 tools/verify/cc_menu_gate.py
	for t in 2 3 4 5 6 7; do python3 tools/verify/cc_menu_gate.py --quick --tooth $$t || exit 1; done
	for t in 1 2; do python3 tools/dist/make_native.py --define EXE_TOOTH=$$t --out scratchpad/dist/JUNO-60_t$$t.exe || exit 1; \
	  if python3 tools/dist/exe_oracle_check.py --exe scratchpad/dist/JUNO-60_t$$t.exe --seeds 1,2,3,4,5,6,7,8 > scratchpad/exe_tooth_$$t.log 2>&1; \
	  then echo "exe tooth $$t DID NOT BITE"; exit 1; else echo "exe tooth $$t BITES"; fi; done
	python3 tools/dist/exe_pm_check.py --exe scratchpad/dist/JUNO-60.exe --seeds 9:40,1:200,2:200,3:200,4:200,5:200,6:200,7:200,100:200

webapp: libjuno.so
	bash gui/web/build.sh
	env node tools/verify/wasm_golden.mjs
	python3 tools/verify/wasm_product_gate.py
	python3 tools/verify/wasm_product_gate.py --tooth
	python3 tools/verify/bundle_webapp.py
	env node tools/verify/verify_webapp.mjs
	env node tools/verify/skin_check.mjs
	env node tools/verify/skin_kb_check.mjs --exe scratchpad/dist/JUNO-60.exe
	for t in velocity hold gap ccedge ccmods; do env node tools/verify/skin_kb_check.mjs --exe scratchpad/dist/JUNO-60.exe --seeds 1,2 --tooth $$t || exit 1; done
	python3 tools/verify/skin_pm_check.py --seeds 9:40,1:200,2:200,3:200,4:200,5:200,6:200,7:200,100:200
	python3 tools/verify/skin_pm_check.py --seeds 9:40 --tooth capture
	for t in keys button; do python3 tools/verify/skin_pm_check.py --seeds 1:200 --tooth $$t || exit 1; done

# Shared library for the test GUI (gui/juno_gui.py via ctypes).
gui: libjuno.so
# The product code keeps every stack frame under 16 KB: the WASM stack is 64 KB and a
# 121 KB context copied onto it overflowed silently (playbook 158).
FRAME_GUARD := -Werror=frame-larger-than=16384
# the shared library's sources (tools/verify/patch_manager_gate.py builds its teeth from them)
print-libjuno-srcs:
	@echo gui/juno_bridge.c gui/juno_pm.c $(SRC)
libjuno.so: gui/juno_bridge.c gui/juno_pm.c $(SRC) $(HDR)
	$(CC) $(CFLAGS) $(FRAME_GUARD) -shared -fPIC -o $@ $(filter %.c,$^) $(LDLIBS)

# TRACK B candidate engine: the sealed engine with hand-written NATIVE kernels
# substituted for their transcribed counterparts (native/*.c shadow src/*.c by
# filename). Never shipped by `make verify` -- it is the SUBJECT of the Track B
# null A/B, not a party to the bit-exact seal:
#   make juno_cand.so && python3 tools/trackb/null_ab.py --cand ./juno_cand.so
# With native/ empty this builds a byte-identical twin of libjuno.so, whose
# residual must be EXACTLY 0 -- the comparator's own passthrough proof.
NATIVE     := $(wildcard native/*.c)
NATIVE_OUT := $(patsubst native/%.c,src/%.c,$(NATIVE))
CAND_SRC   := $(filter-out $(NATIVE_OUT),$(SRC)) $(NATIVE)
.PHONY: cand
cand: juno_cand.so
juno_cand.so: gui/juno_bridge.c $(CAND_SRC) $(HDR) $(wildcard native/*.h)
	@echo "candidate = $(words $(NATIVE)) native kernel(s) replacing: $(NATIVE_OUT)"
	$(CC) $(CFLAGS) -Isrc -shared -fPIC -o $@ $(filter %.c,$^) $(LDLIBS)

# Windows DLL for the GUI (cross-compile with mingw-w64, or native MinGW).
# -static: no MinGW runtime DLLs needed; imports only KERNEL32 + msvcrt.
# A prebuilt juno.dll is committed so Windows users can run the GUI directly.
CC_WIN ?= x86_64-w64-mingw32-gcc
dll: juno.dll
juno.dll: gui/juno_bridge.c $(SRC) $(HDR)
	$(CC_WIN) $(CFLAGS) -shared -static -o $@ $(filter %.c,$^) $(LDLIBS)

test: tests/test_fma_canary tests/test_rate_laws tests/test_teensy_golden tests/test_multi_instance tests/test_voice_alloc tests/test_helpers tests/test_voice_smoke tests/test_master_smoke tests/test_apply_golden tests/test_poly_consistency tests/test_delay_recall tests/test_reverb_recall tests/test_denormal tests/test_note_path tests/test_prepare_rate tests/test_arp_onset tests/test_recall_rate tests/test_arp_release tests/test_bend_mod_sens tests/test_condition_scatter tests/test_arp_pattern tests/test_param_setter
	./tests/test_fma_canary
	./tests/test_rate_laws
	./tests/test_teensy_golden
	./tests/test_multi_instance
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

tests/test_fma_canary: tests/test_fma_canary.c $(HDR)
	$(CC) $(CFLAGS) -o $@ $< $(LDLIBS)

# Pillar-3 exhaustive fine-FX gate: port-side coefficient dumper (compiled from the
# shipping src/*.c). finefx_pillar3_gate.py diffs it against the oracle reference.
tools/verify/finefx_port_dump: tools/verify/finefx_port_dump.c src/finefx_recall.h src/delay_recall.h $(SRC) $(HDR)
	$(CC) $(CFLAGS) -o $@ tools/verify/finefx_port_dump.c $(SRC) $(LDLIBS)

tests/test_teensy_golden: tests/test_teensy_golden.c tests/teensy_golden.h gui/juno_bridge.c $(SRC) $(HDR)
	$(CC) $(CFLAGS) -Itests -o $@ tests/test_teensy_golden.c gui/juno_bridge.c $(SRC) $(LDLIBS)

tests/test_multi_instance: tests/test_multi_instance.c gui/juno_bridge.c $(SRC) $(HDR)
	$(CC) $(CFLAGS) -D_POSIX_C_SOURCE=200809L -o $@ tests/test_multi_instance.c gui/juno_bridge.c $(SRC) $(LDLIBS) -lpthread

tests/test_param_setter: tests/test_param_setter.c $(SRC) $(HDR)
	$(CC) $(CFLAGS) -o $@ $(filter %.c,$^) $(LDLIBS)

tests/test_voice_alloc: tests/test_voice_alloc.c $(SRC) gui/juno_bridge.c $(HDR)
	$(CC) $(CFLAGS) -o $@ tests/test_voice_alloc.c gui/juno_bridge.c $(SRC) $(LDLIBS)

tests/test_helpers: tests/test_helpers.c $(SRC) $(HDR)
	$(CC) $(CFLAGS) -o $@ $(filter %.c,$^) $(LDLIBS)

tests/test_voice_smoke: tests/test_voice_smoke.c $(SRC) $(HDR)
	$(CC) $(CFLAGS) -o $@ $(filter %.c,$^) $(LDLIBS)

tests/test_master_smoke: tests/test_master_smoke.c $(SRC) $(HDR)
	$(CC) $(CFLAGS) -o $@ $(filter %.c,$^) $(LDLIBS)

tests/test_apply_golden: tests/test_apply_golden.c $(SRC) $(HDR)
	$(CC) $(CFLAGS) -o $@ $(filter %.c,$^) $(LDLIBS)

tests/test_poly_consistency: tests/test_poly_consistency.c $(SRC) $(HDR)
	$(CC) $(CFLAGS) -o $@ $(filter %.c,$^) $(LDLIBS)

tests/test_delay_recall: tests/test_delay_recall.c $(SRC) $(HDR)
	$(CC) $(CFLAGS) -o $@ $(filter %.c,$^) $(LDLIBS)

tests/test_reverb_recall: tests/test_reverb_recall.c $(SRC) $(HDR)
	$(CC) $(CFLAGS) -o $@ $(filter %.c,$^) $(LDLIBS)

# ENGINE B FOUNDATION, one command. Runs every foundation gate in dependency
# order and stops at the first red with a message that says what to DO. The
# whole policy (order, why, what --quick omits) is in tools/engineb/foundation.sh
# and docs/engineb/FOUNDATION.md. Never add a gate here without adding it there.
engineb:
	@bash tools/engineb/foundation.sh
engineb-quick:
	@bash tools/engineb/foundation.sh --quick

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

tests/test_denormal: tests/test_denormal.c $(SRC) $(HDR)
	$(CC) $(CFLAGS) -o $@ $(filter %.c,$^) $(LDLIBS)

tests/test_note_path: tests/test_note_path.c $(SRC) $(HDR)
	$(CC) $(CFLAGS) -o $@ $(filter %.c,$^) $(LDLIBS)

tests/test_prepare_rate: tests/test_prepare_rate.c $(SRC) $(HDR)
	$(CC) $(CFLAGS) -o $@ $(filter %.c,$^) $(LDLIBS)

tests/test_arp_onset: tests/test_arp_onset.c $(SRC) $(HDR)
	$(CC) $(CFLAGS) -o $@ $(filter %.c,$^) $(LDLIBS)

tests/test_rate_laws: tests/test_rate_laws.c src/rate_laws.h src/finefx_tables.h
	$(CC) $(CFLAGS) -o $@ $(filter %.c,$^) $(LDLIBS)

tests/test_recall_rate: tests/test_recall_rate.c $(SRC) $(HDR)
	$(CC) $(CFLAGS) -o $@ $(filter %.c,$^) $(LDLIBS)

tests/test_arp_release: tests/test_arp_release.c $(SRC) $(HDR)
	$(CC) $(CFLAGS) -o $@ $(filter %.c,$^) $(LDLIBS)

tests/test_bend_mod_sens: tests/test_bend_mod_sens.c $(SRC) $(HDR)
	$(CC) $(CFLAGS) -o $@ $(filter %.c,$^) $(LDLIBS)

tests/test_condition_scatter: tests/test_condition_scatter.c $(SRC) $(HDR)
	$(CC) $(CFLAGS) -o $@ $(filter %.c,$^) $(LDLIBS)

tests/test_arp_pattern: tests/test_arp_pattern.c $(SRC) $(HDR)
	$(CC) $(CFLAGS) -o $@ $(filter %.c,$^) $(LDLIBS)
