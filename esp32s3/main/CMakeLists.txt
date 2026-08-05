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
    REQUIRES driver esp_timer)

# The project's load-bearing flags, verbatim from the host build. FMA does
# not exist on the LX7, but the flag stays uniform so nobody has to reason
# about which build has it.
target_compile_options(${COMPONENT_LIB} PRIVATE
    -std=c99 -O2 -ffp-contract=off -fno-strict-aliasing
    -DEB_FORK_S3 -DEB_LFO_SHARED=1 -DEB_IDF)

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
