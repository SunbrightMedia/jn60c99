idf_component_register(SRCS "main.c" "msq_core.c"
                       INCLUDE_DIRS "."
                       REQUIRES esp_driver_i2s esp_driver_uart esp_driver_gpio esp_timer)
# test/qemu.sh only: idf.py -DMSQ_QEMU=1 swaps the I2S driver for a timer (never shipped)
if(MSQ_QEMU)
    target_compile_definitions(${COMPONENT_LIB} PRIVATE MSQ_QEMU)
endif()
