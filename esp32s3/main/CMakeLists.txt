# The fork engine = every engine_b/eb_*.c, by glob, the same rule the
# standalone-link test enforces on the host: if a module quietly grows a
# dependency on src/, THIS build fails with an undefined reference and names
# the symbol -- on the firmware, where it matters.
file(GLOB EB_SRCS ${CMAKE_CURRENT_LIST_DIR}/../../engine_b/eb_*.c)

idf_component_register(
    SRCS "juno_s3_main.c"
         "../../tools/engineb/qemu/harness.c"
         ${EB_SRCS}
    INCLUDE_DIRS "." "../../engine_b" "../../src" "../../tools/engineb/qemu"
)

# The project's load-bearing flags, verbatim from the host build. FMA does
# not exist on the LX7, but the flag stays uniform so nobody has to reason
# about which build has it.
target_compile_options(${COMPONENT_LIB} PRIVATE
    -std=c99 -O2 -ffp-contract=off -fno-strict-aliasing
    -DEB_FORK_S3 -DEB_LFO_SHARED=1 -DEB_IDF
    # EB_DELAY_LEN: 32768 here, NOT the shipping 524288. The harness keeps its
    # delay state in a STATIC struct, and 524288 puts 4 MB of ring inside it,
    # which internal .bss cannot hold. The ring length does not change the
    # per-sample instruction count (the index mask is one instruction either
    # way) -- but it DOES change what memory the delay path touches, so the
    # cycle number this firmware prints is an INTERNAL-SRAM figure. The
    # PSRAM-resident ring measurement is a named F4 task, not a footnote:
    # allocate the shipping rings with heap_caps_malloc(MALLOC_CAP_SPIRAM)
    # and re-measure before quoting any cycles-per-sample as the product's.
    -DEB_DELAY_LEN=32768)
