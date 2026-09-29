# test/qemu.sh only: idf.py -DMSQ_QEMU=1 swaps the I2S driver for a timer and
# drops the ADC knob (never shipped). QEMU has no SAR ADC: with blank eFuses the
# esp_adc startup self-calibration spins forever before app_main.
set(msq_req esp_driver_i2s esp_driver_uart esp_driver_gpio esp_timer)
if(NOT MSQ_QEMU)
    list(APPEND msq_req esp_adc)
endif()
idf_component_register(SRCS "main.c" "msq_core.c"
                       INCLUDE_DIRS "."
                       REQUIRES ${msq_req})
if(MSQ_QEMU)
    target_compile_definitions(${COMPONENT_LIB} PRIVATE MSQ_QEMU)
endif()
