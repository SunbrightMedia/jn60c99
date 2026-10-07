set(MS ${CMAKE_CURRENT_LIST_DIR}/../../midi_square/main)
idf_component_register(SRCS "main.c" ${MS}/oled.c ${MS}/gfx.c ${MS}/ui.c ${MS}/panel.c ${MS}/msq_core.c ${MS}/outstage.c
                       INCLUDE_DIRS "." ${MS}
                       REQUIRES esp_driver_i2s esp_driver_gpio esp_driver_i2c esp_timer esp_adc
                       EMBED_FILES ${MS}/snd/startup_48k_s16le.raw)
