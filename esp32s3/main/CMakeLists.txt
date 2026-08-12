# The fork engine = every engine_b/eb_*.c, by glob, the same rule the
# standalone-link test enforces on the host: if a module quietly grows a
# dependency on src/, THIS build fails with an undefined reference and names
# the symbol -- on the firmware, where it matters.
file(GLOB EB_SRCS ${CMAKE_CURRENT_LIST_DIR}/../../engine_b/eb_*.c)

# WHICH FIRMWARE. -DS3_LISTEN=1 builds the LISTEN firmware (audio out of I2S);
# the default is the F4 measurement harness. They are separate app_main()s and
# only one may be linked, so this is a hard either/or rather than a flag the
# code reads.
if(S3_LISTEN)
    set(APP_SRC "juno_s3_listen.c")
    set(APP_EMBED "s3_listen.bin")
else()
    set(APP_SRC "juno_s3_main.c" "../../tools/engineb/qemu/harness.c")
    set(APP_EMBED "")
endif()

idf_component_register(
    SRCS ${APP_SRC} ${EB_SRCS}
    INCLUDE_DIRS "." "../../engine_b" "../../src" "../../tools/engineb/qemu"
    EMBED_FILES ${APP_EMBED}
    LDFRAGMENTS "linker.lf"
    REQUIRES esp_driver_i2s driver esp_timer)

# The project's load-bearing flags, verbatim from the host build. FMA does
# not exist on the LX7, but the flag stays uniform so nobody has to reason
# about which build has it.
# -std=c99 ONLY on the ENGINE sources. The app file includes IDF headers,
# and IDF's xtensa headers use `asm`, which strict ISO C rejects -- the
# listen build failed exactly there. The engine's contract (c99, no
# contraction) applies to the engine; the app file keeps IDF's own default.
# -flto: THE CHEAPEST ROUTE TO THE ILP THE BOARD SAYS IS MISSING.
#
# MEASURED slope: 5,343 cycles per voice, flat -- two voices cost exactly
# twice one, so nothing overlaps today. c/i is 1.56 because dependent
# single-precision chains stall, and the fix is to give the FPU independent
# work to fill the stalls with: the OTHER voice's arithmetic.
#
# The obstacle is that every module is a separate translation unit, so the
# compiler cannot interleave across the per-voice calls in eb_render.c even
# though the voices are provably independent. Link-time optimisation removes
# exactly that obstacle without touching a line of DSP. If it does not move
# the number, hand-fusing the DCO and ladder for two voices is next.
#
# -ffp-contract=off still applies, so no FMA can appear; LTO reorders and
# inlines, it does not re-associate float arithmetic.
target_compile_options(${COMPONENT_LIB} PRIVATE
    -O2 -flto -ffp-contract=off -fno-strict-aliasing
    -DEB_FORK_S3 -DEB_LFO_SHARED=1 -DEB_VCF_RES_LUT=256 -DEB_IDF
    ${S3_EXTRA_DEFS})
# EB_VCF_RES_LUT=256 -- MEASURED on the user's S3: 1,009 cycles per
# critical-path voice, 6 voices 14,441 -> 11,353. The shaper's tail is a pure
# function of one scalar, so a table replaces it with a load pair and a lerp.
# 256 rather than 2,048 because the sonic gate reads 0.40 dB at both -- the
# no-table control's own number -- while 256 costs 1 KB a voice instead of
# 8 KB. A 32-entry run degrades to 0.96 dB, which is the control proving the
# gate responds to this table at all.
set_source_files_properties(${EB_SRCS} PROPERTIES COMPILE_OPTIONS "-std=c99")

if(NOT S3_LISTEN)
    # EB_DELAY_LEN: 32768 here, NOT the shipping 524288. The harness keeps its
    # delay state in a STATIC struct, and 524288 puts 4 MB of ring inside it,
    # which internal .bss cannot hold. The ring length does not change the
    # per-sample instruction count (the index mask is one instruction either
    # way) -- but it DOES change what memory the delay path touches, so the
    # cycle number that build prints is an INTERNAL-SRAM figure.
    target_compile_definitions(${COMPONENT_LIB} PRIVATE EB_DELAY_LEN=32768)
endif()

# THE LISTEN FIRMWARE'S VOICE CAP is a build constant with a runtime meaning:
# raise it, reflash, watch the underrun counter. -DS3_VOICES=N on the idf.py
# command line.
if(S3_VOICES)
    target_compile_definitions(${COMPONENT_LIB} PRIVATE S3L_VOICES=${S3_VOICES})
endif()

# STEP 1: -DS3_NOFX=1 builds the VOICE-CHAIN-ONLY firmware (no master/FX, no
# PSRAM rings). It is the smallest build that makes sound and it isolates
# placement cost from arithmetic cost.
if(S3_NOFX)
    target_compile_definitions(${COMPONENT_LIB} PRIVATE S3L_NOFX=1)
endif()

# -DS3_RING_SRAM=N caps every delay ring at N samples and tries INTERNAL RAM
# first, falling back to PSRAM at full length per ring.
#
# ⚠ THIS BLOCK DID NOT EXIST UNTIL 2026-08-11, AND ITS ABSENCE COST A FLASH.
# S3_RING_SRAM was passed on the idf.py command line, CMake stored it in the
# cache as an UNINITIALIZED variable, and nothing ever read it. The build
# succeeded, the cache showed `S3_RING_SRAM:UNINITIALIZED=32768`, and the
# firmware was byte-for-byte the PSRAM one. The board then returned numbers
# IDENTICAL TO THE DECIMAL to the previous run -- which is the same signature
# a fixed point leaves, and would have been read as "the hypothesis is dead"
# if the missing `RINGS:` lines had not given it away.
#
# CMake does not warn about a -D it never uses. So the rule this earns is:
# a knob is not a knob until something reads it, and the way to check is the
# firmware's own printed banner, not the command line you typed.
if(S3_RING_SRAM)
    target_compile_definitions(${COMPONENT_LIB} PRIVATE
                               S3L_RING_SRAM=${S3_RING_SRAM})
endif()

# -DS3_LAYOUT=1: the CHIP-LAYOUT SWEEP. Voice range, core split and the FX
# stage all become RUNTIME values, so every candidate two-chip layout is
# measured in ONE flash instead of one flash each. Needs S3L_FX_PIPE=1.
if(S3_LAYOUT)
    target_compile_definitions(${COMPONENT_LIB} PRIVATE S3L_LAYOUT=${S3_LAYOUT})
endif()

if(S3_LTO)
    target_link_options(${COMPONENT_LIB} INTERFACE -flto)
endif()

# -DS3_OFFLINE=1: render into PSRAM first, then loop playback. Sidesteps the
# real-time shortfall entirely so the engine can be HEARD while the
# performance work continues.
if(S3_OFFLINE)
    target_compile_definitions(${COMPONENT_LIB} PRIVATE S3L_OFFLINE=1)
endif()

if(S3_TONE)
    target_compile_definitions(${COMPONENT_LIB} PRIVATE S3L_TONE=1)
endif()
