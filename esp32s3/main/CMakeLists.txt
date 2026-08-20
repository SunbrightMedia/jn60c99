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
    if(S3_USBMIDI)
        # USB MIDI is OPT-IN. It pulls in TinyUSB and puts a USB interrupt on a
        # core that renders audio; a build that does not want a DAW attached
        # should not carry either.
        list(APPEND APP_SRC "s3_usbmidi.c")
    endif()
    set(APP_EMBED "s3_listen.bin")
else()
    set(APP_SRC "juno_s3_main.c" "../../tools/engineb/qemu/harness.c")
    set(APP_EMBED "")
endif()

# -DS3_RECALL=1 : DEVICE RECALL. The coefficients are built ON THE CHIP from
# 134 compact patch bytes, so the 1.69 MB frozen blob is not embedded at all.
#
# ⚠ THE RECALL SOURCES ARE AN EXPLICIT LIST, NEVER A GLOB, and this is the one
# thing in this file that must not be waved past. A glob over src/ would take
# 21 objects instead of 10 -- including voice_render.c, master_render.c and
# juno_dsp.c, a SECOND COPY of the DSP the fork exists to replace -- and the
# build would still succeed.
#
# AND ADDING src/ AT ALL COSTS THIS BUILD A GATE. The comment at the top of
# this file is not decoration: the engine_b-only glob is what makes a module
# that quietly grows a dependency on src/ fail HERE, on the firmware, naming
# the symbol. With src/ objects in the image, an eb_*.c that started calling
# juno_triangle would link cleanly from tomorrow. The only other enforcement is
# engine_b/tests/test_standalone_link, which is NOT in the top-level `make
# test` (playbook defect 23 verbatim). So: that test must go into `make test`
# in the same commit as this list, or the standalone invariant is unenforced
# the day recall lands. THAT IS STILL OWED AS OF THIS COMMIT.
if(S3_RECALL)
    set(RECALL_SRCS
        ${CMAKE_CURRENT_LIST_DIR}/../../src/juno_apply.c
        ${CMAKE_CURRENT_LIST_DIR}/../../src/juno_curve.c
        ${CMAKE_CURRENT_LIST_DIR}/../../src/juno_driver.c
        ${CMAKE_CURRENT_LIST_DIR}/../../src/juno_note.c
        ${CMAKE_CURRENT_LIST_DIR}/../../src/delay_recall.c
        ${CMAKE_CURRENT_LIST_DIR}/../../src/reverb_recall.c
        ${CMAKE_CURRENT_LIST_DIR}/../../src/chorus_recall.c
        ${CMAKE_CURRENT_LIST_DIR}/../../src/finefx_recall.c
        ${CMAKE_CURRENT_LIST_DIR}/../../src/effect_modes.c
        ${CMAKE_CURRENT_LIST_DIR}/../../src/hpf_type_lut.c
        ${CMAKE_CURRENT_LIST_DIR}/../../engine_b/dev/ebdev.c
        ${CMAKE_CURRENT_LIST_DIR}/../../engine_b/dev/eb_recall.c
        ${CMAKE_CURRENT_LIST_DIR}/../../engine_b/dev/eb_devseq.c)
    set(APP_EMBED "")          # the blob is REPLACED, not carried alongside
else()
    set(RECALL_SRCS "")
endif()

# REQUIRES is resolved at CONFIGURE time, so a generator expression in it is
# silently wrong -- it fails inside __build_resolve_and_add_req with no useful
# message. Build the list first.
# tinyusb is required UNCONDITIONALLY, and that is deliberate. IDF resolves
# REQUIRES in an early expansion pass where this file's own cache variables are
# not reliably visible, so `if(S3_USBMIDI) list(APPEND ...)` produced a main
# component with NO tinyusb requirement and a build that failed on a missing
# tusb.h -- a conditional that silently does not fire. With S3_USBMIDI off the
# class code is unreferenced and --gc-sections drops it.
# esp_driver_gpio: O6's role strap reads a pin. In ESP-IDF v6 the GPIO driver
# is its OWN component -- `driver` no longer carries it -- so without this the
# build fails on `driver/gpio.h: No such file or directory`, which reads like a
# missing SDK and is really a missing REQUIRES line.
set(APP_REQ esp_driver_i2s esp_driver_uart esp_driver_gpio driver esp_timer
            esp_hw_support tinyusb)

# O1: the internal event boundary. ONE small portable file, compiled into the
# firmware exactly as the host gate compiles it (event/teeth.sh) -- a boundary
# proven on a workstation and a different boundary shipped is two boundaries.
set(EVENT_SRCS ${CMAKE_CURRENT_LIST_DIR}/../../event/juno_event.c)

idf_component_register(
    SRCS ${APP_SRC} ${EB_SRCS} ${RECALL_SRCS} ${EVENT_SRCS}
    INCLUDE_DIRS "." "../../engine_b" "../../engine_b/dev" "../../src"
                 "../../event"
                 "../../tools/engineb/devboot" "../../tools/engineb/qemu"
    EMBED_FILES ${APP_EMBED}
    LDFRAGMENTS "linker.lf"
    REQUIRES ${APP_REQ})

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
# ⚠ -flto IS OFF BY DEFAULT AS OF 2026-08-12, AND THAT IS A MEASURED DECISION.
#
# It was added to buy instruction-level parallelism across the per-voice calls.
# It did not: the board measures a FLAT voice slope -- two voices cost exactly
# twice one -- so nothing overlaps and LTO's own justification never landed.
#
# And it COSTS something that was never noticed: under LTO the libmain.a
# members are IR, so `linker.lf`'s IRAM mapping matches nothing and the whole
# engine runs XIP from flash through a small instruction cache. That mapping
# has been inert since the day it was written, MEASURED both ways (zero engine
# symbols in IRAM). The audio loop executes 44,100 times a second out of
# flash, which is exactly the thrash the mapping exists to remove.
#
# -DS3_LTO=1 puts it back. If it is ever put back, the IRAM mapping stops
# working again, so the firmware prints its own IRAM symbol count at boot.
if(S3_LTO)
    set(S3_LTO_FLAG -flto)
    message(STATUS "S3_LTO=1: LTO ON -- linker.lf's IRAM mapping will be INERT")
else()
    set(S3_LTO_FLAG "")
endif()
# JUNO_EVQ_PORT_HEADER supplies the producers' lock. WITHOUT IT the boundary
# silently compiles with a NO-OP lock -- correct for the single-threaded host
# gate and a data race here, where USB, DIN and the console all submit.
target_compile_options(${COMPONENT_LIB} PRIVATE
    -O2 ${S3_LTO_FLAG} -ffp-contract=off -fno-strict-aliasing
    -DJUNO_EVQ_PORT_HEADER="juno_event_port.h"
    -DEB_FORK_S3 -DEB_LFO_SHARED=1 -DEB_VCF_RES_LUT=256 -DEB_IDF
    ${S3_EXTRA_DEFS})
# EB_VCF_RES_LUT=256 -- MEASURED on the user's S3: 1,009 cycles per
# critical-path voice, 6 voices 14,441 -> 11,353. The shaper's tail is a pure
# function of one scalar, so a table replaces it with a load pair and a lerp.
# 256 rather than 2,048 because the sonic gate reads 0.40 dB at both -- the
# no-table control's own number -- while 256 costs 1 KB a voice instead of
# 8 KB. A 32-entry run degrades to 0.96 dB, which is the control proving the
# gate responds to this table at all.
# -Wno-array-bounds: WITHOUT -flto GCC can finally see through ebdev_at()'s
# `static inline` literal chain, and it then reports every cell offset past the
# first segment as "outside array bounds of ebdev_state" -- e.g. subscript
# 21068. It is right that the arithmetic leaves the member it started in and
# wrong that it leaves the OBJECT: ebdev_at returns a pointer into a different
# member of the same struct, which the analysis cannot follow.
#
# Suppressing a bounds warning is not free and this is why it is acceptable
# here rather than in general: the addressing has its own proof and its own
# runtime detector. engine_b/dev/ebdev.c carries an EXHAUSTIVE chain-vs-table
# self-test that the firmware runs at boot and PRINTS ("0 disagreements,
# 0 REQUIRED"), and every access that falls off the map increments a counter
# the board reports and mutes on. A real out-of-range access is caught by both;
# it is not being traded away for a quiet build.
set_source_files_properties(${EB_SRCS} PROPERTIES COMPILE_OPTIONS
    "-std=c99;-Wno-array-bounds;-Wno-stringop-overflow")

if(S3_RECALL)
    # EB_DEVCELLS is the rebase. It used to be a PYTHON TEXT REWRITE inside
    # tools/engineb/devrecall_gate.py, which could not ship -- an ESP-IDF build
    # cannot run a regex over its own inputs, and a gate that proves a scratch
    # tree nobody flashes proves the wrong tree. It is now #ifdef'd into the
    # checked-in sources (src/juno_engine.h's JCELL and five others), so the
    # 1,152-case gate and THIS FIRMWARE compile the same bytes.
    #
    # EBDEV_NV=8, not 6. The 96 bytes 6 would save are not worth configuring
    # the device differently from the gate that certifies it -- playbook
    # defect 28, which cost this project a dead LFO through a whole night.
    target_compile_definitions(${COMPONENT_LIB} PRIVATE
                               S3L_RECALL=1 EB_DEVCELLS EBDEV_NV=8
                               # EB_RECALL_PROF: two cycle counters around the
                               # two halves of the burst. The burst measured
                               # 1.95 M cycles against a stated 90,000, so the
                               # next step is to find out WHERE before anything
                               # is optimised. Two counter reads per burst.
                               EB_RECALL_PROF=1
                               EBDEV_MISSLIST_N=64 EBSH_MAX_CTX=1
                               DEVCHORD_N=${S3_VOICES})
    # EB_RECALL_FX_PIPE MUST FOLLOW S3L_FX_PIPE, and it arrives inside the
    # S3_EXTRA_DEFS string, so it is matched out of it rather than assumed.
    # WHAT GOES WRONG IF IT DOES NOT: with the FX pipeline, core 1's next pass
    # runs eb_master_render over the PREVIOUS chunk's voices. Publishing the
    # master coefficients immediately puts the NEW patch's delay/reverb/chorus
    # on voices rendered under the OLD one -- one chunk, 5.8 ms, of the wrong
    # effect on every program change. eb_recall.c defers it by exactly one
    # block when this is set. juno_s3_listen.c #errors if the two disagree, so
    # a silent mismatch is not shippable.
    string(FIND "${S3_EXTRA_DEFS}" "S3L_FX_PIPE=1" _fxpipe_at)
    if(NOT _fxpipe_at EQUAL -1)
        target_compile_definitions(${COMPONENT_LIB} PRIVATE EB_RECALL_FX_PIPE=1)
        message(STATUS "RECALL: EB_RECALL_FX_PIPE=1 (master coefficients "
                       "deferred one block, matching S3L_FX_PIPE)")
    endif()
    # src/ predates the IDF warning set: the BINDINGS table in juno_apply.c
    # uses partial struct initialisers and IDF promotes that to an ERROR.
    set_source_files_properties(${RECALL_SRCS} PROPERTIES COMPILE_OPTIONS
        "-std=c99;-Wno-missing-field-initializers;-Wno-array-bounds;-Wno-stringop-overflow")
endif()

if(S3_PATCH_SECS)
    target_compile_definitions(${COMPONENT_LIB} PRIVATE
                               S3L_PATCH_SECS=${S3_PATCH_SECS})
endif()
if(S3_RECALL_NOMUTE)
    target_compile_definitions(${COMPONENT_LIB} PRIVATE S3L_RECALL_NOMUTE=1)
endif()

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
