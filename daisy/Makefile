# Daisy Seed firmware for the JUNO-60 C99 port.  See daisy/README.md.
#
#   make LIBDAISY_DIR=/path/to/libDaisy            # build
#   make LIBDAISY_DIR=... program-dfu              # flash the app
#
# The engine is ~375 KB of code and the H750 has only 128 KB of internal flash,
# so APP_TYPE must be BOOT_QSPI (app in the 7936 KB QSPI flash, launched by the
# Daisy bootloader) -- BOOT_NONE cannot fit and will fail to link.

TARGET = juno60_daisy
APP_TYPE = BOOT_QSPI

LIBDAISY_DIR ?= ../../libDaisy

# Repo root, so this works from any checkout location.
ROOT := $(abspath $(dir $(lastword $(MAKEFILE_LIST)))..)

CPP_SOURCES = juno60_daisy.cpp

# The engine (plain C99) plus the golden-corpus driver. golden_shim.c #includes
# tests/test_teensy_golden.c verbatim, so the DEVICE RUNS THE SAME CODE as the
# host gate -- not a copy that can drift out of sync. The shim exists because the
# main/printf renames MUST be file-scoped, not global: see golden_shim.c for the
# silent-boot-failure that a global -Dmain= causes.
C_SOURCES  = $(wildcard $(ROOT)/src/*.c)
C_SOURCES += $(ROOT)/gui/juno_bridge.c
C_SOURCES += golden_shim.c

# Second compilations of the two hot render TUs, renamed so the linker can put
# them in ITCM while the originals stay in QSPI. The firmware then A/Bs code
# PLACEMENT inside a single boot instead of needing two images and two flashes.
# They add ~32 KB of QSPI (the load copies) and no arithmetic whatsoever.
C_SOURCES += voice_render_itcm.c
C_SOURCES += master_render_itcm.c

C_INCLUDES += -I$(ROOT)/src -I$(ROOT)/gui -I$(ROOT)/tests

# ---------------------------------------------------------------------------
# C_DEFS is interpolated into libDaisy's CFLAGS, which is how we inject flags
# that must reach every translation unit.
#
# -ffp-contract=off is LOAD-BEARING AND NOT OPTIONAL. The port's bit-exactness
# is defined against x86 SSE2, which has no FMA. FPv5-D16 does, and libDaisy's
# core/Makefile sets NO -ffp-contract flag, so GCC falls back to its default of
# 'fast' and will happily fuse a*b+c into one single-rounded VFMA. That is a
# silent divergence on every patch. tests/test_fma_canary.c exists precisely to
# catch this, and E1 in the firmware will fail loudly if it slips.
#
# NOTE: main/printf renames are deliberately NOT here. They live inside
# golden_shim.c, because libDaisy compiles its own startup_stm32h750xx.c with
# these same flags -- a global -Dmain= silently redirects Reset_Handler into the
# corpus driver and the build still succeeds. See golden_shim.c.
C_DEFS += -ffp-contract=off -fno-strict-aliasing

# Serve the engine's one big allocation from SDRAM without editing engine source.
LDFLAGS += -Wl,--wrap=malloc -Wl,--wrap=calloc -Wl,--wrap=free -Wl,--wrap=realloc

SYSTEM_FILES_DIR = $(LIBDAISY_DIR)/core

# THE ITCM LINKER SCRIPT IS NOW THE ONLY BUILD. There is no ITCM_HOT=0 image
# any more and there must not be one: the image contains BOTH placements at
# once (QSPI originals + ITCM shadow copies) and selects between them at run
# time, so the A/B is one flash rather than two. Removing the two-image scheme
# is the point -- a second image would reintroduce the flash it was built to
# avoid, and would also compare numbers taken from two different link layouts.
LDSCRIPT = $(CURDIR)/juno_itcm.lds
C_DEFS  += -DITCM_HOT=1

include $(SYSTEM_FILES_DIR)/Makefile

# Belt and braces: also append after the include, in case a future libDaisy
# stops interpolating C_DEFS. CFLAGS is recursively expanded and consumed in the
# compile rules, so a late += still reaches every file.
CFLAGS   += -ffp-contract=off
CPPFLAGS += -ffp-contract=off

# Two post-link assertions. Run both after every build:  make check
.PHONY: check
check: check-fpcontract verify-entry

# Reset_Handler must branch to OUR main, and main must survive the link. A global
# -Dmain= (or anything else that renames main) silently redirects the entry point
# and --gc-sections then deletes main plus everything it referenced, all with a
# clean exit 0. That happened during development and the only symptom would have
# been a dead board. Never again.
.PHONY: verify-entry
verify-entry:
	@echo "checking the reset vector reaches main()..."
	@[ -f $(BUILD_DIR)/$(TARGET).elf ] || { echo "  build first"; exit 2; }
	@$(PREFIX)nm $(BUILD_DIR)/$(TARGET).elf | grep -qE " T main$$" \
	  || { echo "FAIL: main() is not in the ELF -- it was renamed or GC'd"; exit 1; }
	@ep=$$($(PREFIX)nm $(BUILD_DIR)/$(TARGET).elf | grep -E " T Reset_Handler$$" | cut -d' ' -f1); \
	 $(PREFIX)objdump -d --start-address=0x$$ep --stop-address=$$((0x$$ep + 0x80)) \
	   $(BUILD_DIR)/$(TARGET).elf | grep -qE "bl\s+[0-9a-f]+ <main>" \
	  || { echo "FAIL: Reset_Handler does not call main -- entry point hijacked"; \
	       echo "      (a global -Dmain= leaks into libDaisy's startup file)"; exit 1; }
	@echo "OK: Reset_Handler -> main, and main survived the link"

# Prove the flag survived. `make check-fpcontract` greps the built objects for
# any fused multiply-add; a hit means bit-exactness is already broken and E1
# will fail on device.
.PHONY: check-fpcontract
check-fpcontract:
	@echo "scanning for fused multiply-add in the engine objects..."
	@found=0; for o in $(BUILD_DIR)/voice_render.o $(BUILD_DIR)/master_render.o \
	                   $(BUILD_DIR)/voice_render_itcm.o $(BUILD_DIR)/master_render_itcm.o; do \
	  [ -f "$$o" ] || { echo "  MISSING $$o (build first)"; exit 2; }; \
	  n=$$($(PREFIX)objdump -d "$$o" | grep -cE "vfma|vfms|vfnma|vfnms" || true); \
	  echo "  $$o: $$n fused ops"; [ "$$n" = "0" ] || found=1; \
	done; \
	if [ "$$found" = "0" ]; then echo "OK: no FMA -- bit-exactness preserved"; \
	else echo "FAIL: FMA present, -ffp-contract=off did not take effect"; exit 1; fi
