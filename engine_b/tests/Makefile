# engine B unit tests. Run from anywhere: `make -C engine_b/tests`.
# The bank-reading test walks up to find truth/presetbankog1.bin.
CC     ?= cc
CFLAGS ?= -std=c99 -O2 -Wall -Wextra -ffp-contract=off -I..
BIN     = test_sizes test_freerun test_patch118

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

test_sizes:    test_sizes.c $(HDR) ; $(CC) $(CFLAGS) -o $@ $<
test_freerun:  test_freerun.c ../eb_engine.c ../eb_patch.c $(HDR) ; $(CC) $(CFLAGS) -o $@ $< ../eb_engine.c ../eb_patch.c -lm
test_patch118: test_patch118.c ../eb_patch.c $(HDR) ; $(CC) $(CFLAGS) -o $@ $< ../eb_patch.c

clean: ; rm -f $(BIN)
.PHONY: all clean
