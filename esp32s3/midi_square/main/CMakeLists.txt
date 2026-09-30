# test/qemu.sh only: idf.py -DMSQ_QEMU=1 swaps the I2S driver for a timer and
# drops the ADC knobs (never shipped). QEMU has no SAR ADC: with blank eFuses the
# esp_adc startup self-calibration spins forever before app_main.
set(msq_req esp_driver_i2s esp_driver_uart esp_driver_gpio esp_driver_i2c esp_timer)
if(NOT MSQ_QEMU)
    list(APPEND msq_req esp_adc)
endif()
# The JUNO FX stage ONLY: the proven engine_b master chain and what it links.
set(EB ${CMAKE_CURRENT_LIST_DIR}/../../../engine_b)
set(EB_FX_SRCS
    ${EB}/eb_master.c ${EB}/eb_master_in.c ${EB}/eb_master_out.c ${EB}/eb_delay.c
    ${EB}/eb_delay_t1.c ${EB}/eb_delay_t23.c ${EB}/eb_delay_t5.c ${EB}/eb_dly_t4.c
    ${EB}/eb_fx_e0.c ${EB}/eb_fx_e1.c ${EB}/eb_fx_e5.c ${EB}/eb_reverb.c ${EB}/eb_chorus.c
    ${EB}/eb_dsp.c)
idf_component_register(SRCS "main.c" "msq_core.c" "fx.c" "panel.c" "ui.c" "gfx.c" "oled.c" ${EB_FX_SRCS}
                       INCLUDE_DIRS "." ${EB} ${CMAKE_CURRENT_LIST_DIR}/../../../src
                       REQUIRES ${msq_req}
                       LDFRAGMENTS "linker.lf")
# -ffp-contract=off is load-bearing (no FMA may appear, or the FX stage stops
# matching the proven recall path bit for bit); same flags as the host gate.
target_compile_options(${COMPONENT_LIB} PRIVATE -ffp-contract=off -fno-strict-aliasing)
set_source_files_properties(${EB_FX_SRCS} PROPERTIES COMPILE_OPTIONS
    "-std=c99;-w")
# The recalled patch has the delay OFF: run the delay stage's own off law, not
# the core over its 524 KB PSRAM ring (EB_NODELAY, fail-closed; proven equal to
# the full path by tools/fx_gate.c).
set_source_files_properties(${EB}/eb_master.c PROPERTIES COMPILE_DEFINITIONS "EB_NODELAY=1")
# TOOTH (test only): -DMSQ_TOOTH_FMA=1 lets GCC fuse multiply-adds in the FX
# stage; the boot render-CRC check MUST then report MISMATCH.
if(MSQ_TOOTH_FMA)
    set_source_files_properties(${EB_FX_SRCS} PROPERTIES COMPILE_OPTIONS "-std=c99;-w;-ffp-contract=fast")
endif()
if(MSQ_QEMU)
    target_compile_definitions(${COMPONENT_LIB} PRIVATE MSQ_QEMU)
endif()
