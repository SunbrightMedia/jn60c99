# engine B unit tests. Run from anywhere: `make -C engine_b/tests`.
# The bank-reading test walks up to find truth/presetbankog1.bin.
CC     ?= cc
CFLAGS ?= -std=c99 -O2 -Wall -Wextra -ffp-contract=off -I..
BIN     = test_sizes test_freerun test_patch118 test_modcv_block test_decim test_render_guard test_pitch_tab test_eb_dsp test_standalone_link

# HEADERS ARE BUILD INPUTS. Every constant, the whole free-run contract and the
# patch layout live in ../*.h. Until 2026-08-02 the recipes below listed only
# .c files, so editing a header rebuilt NOTHING and the stale binaries printed
# PASS against the OLD constants -- demonstrated by breaking eb_phase_advance in
# eb_engine.c's header path and watching FREE-RUN CONTRACT: PASS. Same false-
# green class CLAUDE.md records for src/*.h.
HDR     = $(wildcard ../*.h)

all: $(BIN)
	@echo; ./test_sizes
	@echo; ./test_freerun
	@echo; ./test_patch118
	@echo; ./test_modcv_block
	@echo; ./test_decim
	@echo; ./test_render_guard
	@echo; ./test_pitch_tab
	@echo; ./test_eb_dsp
	@echo; ./test_standalone_link

test_sizes:    test_sizes.c $(HDR) ; $(CC) $(CFLAGS) -o $@ $<
# eb_alloc.c IS REQUIRED and was missing. When step 1 replaced eb_engine.c's
# skeleton allocator with the real one, this rule was not updated, so
# test_freerun stopped LINKING -- and nobody saw it, because this suite is
# not in the top-level `make test`. A unit test that does not build is not a
# failing test, it is an absent one, and it was absent for two days.
test_freerun:  test_freerun.c ../eb_engine.c ../eb_patch.c ../eb_alloc.c $(HDR) ; $(CC) $(CFLAGS) -o $@ $< ../eb_engine.c ../eb_patch.c ../eb_alloc.c -lm
test_patch118: test_patch118.c ../eb_patch.c $(HDR) ; $(CC) $(CFLAGS) -o $@ $< ../eb_patch.c
test_modcv_block: test_modcv_block.c ../eb_pwm_cv.c $(HDR) ; $(CC) $(CFLAGS) -o $@ $< ../eb_pwm_cv.c -lm
test_decim: test_decim.c ../eb_decim.c $(HDR) ; $(CC) $(CFLAGS) -o $@ $< ../eb_decim.c -lm
test_pitch_tab: test_pitch_tab.c ../eb_pitch.c ../eb_pitch_tab.h $(HDR) ; $(CC) $(CFLAGS) -DEB_PITCH_FAST=1 -I../../src -o $@ $< ../eb_pitch.c -lm
# ONLY engine_b sources on this line. That is the whole test: adding a src/
# object here would defeat it silently.
test_standalone_link: test_standalone_link.c $(filter-out ../eb_engine.c,$(wildcard ../eb_*.c)) $(HDR) ; $(CC) $(CFLAGS) -DEB_DELAY_LEN=65536 -I../../src -o $@ $< $(filter-out ../eb_engine.c,$(wildcard ../eb_*.c)) -lm
test_eb_dsp: test_eb_dsp.c ../eb_dsp.c ../../src/juno_dsp.c $(HDR) ; $(CC) $(CFLAGS) -I../../src -o $@ $< ../eb_dsp.c ../../src/juno_dsp.c -lm
test_render_guard: test_render_guard.c $(wildcard ../eb_*.c) $(HDR) ; $(CC) $(CFLAGS) -DEB_DELAY_LEN=65536 -I../../src -o $@ $< $(filter-out ../eb_engine.c,$(wildcard ../eb_*.c)) -lm

clean: ; rm -f $(BIN)
.PHONY: all clean
