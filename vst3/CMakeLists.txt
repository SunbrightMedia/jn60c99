# CMakeLists.txt — build the JUNO-60 C99 engine as a VST3 instrument.
#
# The audio engine (../src) is a self-contained, bit-exact C99 transcription and
# needs nothing external. This wrapper additionally needs the Steinberg VST3 SDK.
#
# Usage:
#   cmake -B build -DVST3_SDK_DIR=/path/to/vst3sdk
#   cmake --build build --config Release
#
# Produces JUNO60_C99.vst3. Ship refs/preset_banks/bank1.bin in the bundle's
# Resources (or set the JUNO_FACTORY_BANK env var / -DJUNO_FACTORY_BANK=...).

cmake_minimum_required(VERSION 3.19)
project(JUNO60_C99 VERSION 1.0.0 LANGUAGES C CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_C_STANDARD 99)

if(NOT VST3_SDK_DIR)
    message(FATAL_ERROR
        "VST3_SDK_DIR not set. Point it at the Steinberg VST3 SDK:\n"
        "  cmake -B build -DVST3_SDK_DIR=/path/to/vst3sdk")
endif()

# Bring in the SDK (defines smtg_add_vst3plugin + the sdk/base/pluginterfaces targets).
add_subdirectory(${VST3_SDK_DIR} ${CMAKE_BINARY_DIR}/vst3sdk EXCLUDE_FROM_ALL)

set(ENGINE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/../src)
set(HOST_DIR   ${CMAKE_CURRENT_SOURCE_DIR}/../host)

# The bit-exact engine: every C file under src/ EXCEPT the capture oracle, which
# the product does not use (it is kept only for regression tests).
file(GLOB ENGINE_SRC ${ENGINE_DIR}/*.c)
list(FILTER ENGINE_SRC EXCLUDE REGEX "runtime_coeffs_data\\.c$")

set(PLUGIN_SRC
    ${ENGINE_SRC}
    ${HOST_DIR}/juno_synth.c
    juno_processor.cpp
    juno_controller.cpp
    juno_factory.cpp)

smtg_add_vst3plugin(JUNO60_C99 ${PLUGIN_SRC})

target_include_directories(JUNO60_C99 PRIVATE ${ENGINE_DIR} ${HOST_DIR} ${VST3_SDK_DIR})
target_link_libraries(JUNO60_C99 PRIVATE sdk base pluginterfaces)

# -fno-strict-aliasing is required by the engine's offset-addressed state model.
set_source_files_properties(${ENGINE_SRC} PROPERTIES COMPILE_OPTIONS "-fno-strict-aliasing")

# The product is capture-free by default. Define JUNO_USE_CAPTURE to restore the
# old memory-capture seed (regression only); it also needs runtime_coeffs_data.c.
