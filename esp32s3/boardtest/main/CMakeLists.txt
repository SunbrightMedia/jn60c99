idf_component_register(SRCS "main.c" "tone.c"
                       INCLUDE_DIRS "."
                       REQUIRES esp_driver_i2s esp_timer)
