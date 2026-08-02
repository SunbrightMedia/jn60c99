# engine B unit tests. Run from anywhere: `make -C engine_b/tests`.
# The bank-reading test walks up to find truth/presetbankog1.bin.
CC     ?= cc
CFLAGS ?= -std=c99 -O2 -Wall -Wextra -ffp-contract=off -I..
BIN     = test_sizes test_freerun test_patch118

all: $(BIN)
	@echo; ./test_sizes
	@echo; ./test_freerun
	@echo; ./test_patch118

test_sizes:    test_sizes.c ../eb_types.h ; $(CC) $(CFLAGS) -o $@ $<
test_freerun:  test_freerun.c ../eb_engine.c ../eb_patch.c ; $(CC) $(CFLAGS) -o $@ $< ../eb_engine.c ../eb_patch.c -lm
test_patch118: test_patch118.c ../eb_patch.c ; $(CC) $(CFLAGS) -o $@ $< ../eb_patch.c

clean: ; rm -f $(BIN)
.PHONY: all clean
