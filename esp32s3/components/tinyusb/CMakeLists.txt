# TinyUSB, vendored -- see USBMIDI.md in this directory for WHY it is vendored
# rather than pulled from the component registry.
#
# ONLY the device side and ONLY the MIDI class are compiled. TinyUSB is a large
# tree and most of it is other MCUs, host mode and classes this instrument does
# not have. A narrower build is also a narrower thing to be wrong about.
set(TUSB_SRC "${CMAKE_CURRENT_LIST_DIR}/src")

idf_component_register(
    SRCS
        "${TUSB_SRC}/tusb.c"
        "${TUSB_SRC}/common/tusb_fifo.c"
        "${TUSB_SRC}/device/usbd.c"
        "${TUSB_SRC}/class/midi/midi_device.c"
        "${TUSB_SRC}/portable/synopsys/dwc2/dcd_dwc2.c"
        "${TUSB_SRC}/portable/synopsys/dwc2/dwc2_common.c"
    INCLUDE_DIRS
        "${TUSB_SRC}"
        "${CMAKE_CURRENT_LIST_DIR}/cfg"
    PRIV_REQUIRES
        esp_hw_support esp_hal_usb freertos esp_rom hal soc)

# CFG_TUSB_MCU picks the port. OPT_MCU_ESP32S3 selects the dwc2 files above;
# getting this wrong produces a build that links and a device that never
# enumerates.
target_compile_options(${COMPONENT_LIB} PUBLIC
    -DCFG_TUSB_MCU=OPT_MCU_ESP32S3
    -DCFG_TUSB_OS=OPT_OS_FREERTOS)
target_compile_options(${COMPONENT_LIB} PRIVATE
    -Wno-unused-parameter -Wno-sign-compare -Wno-array-bounds)
