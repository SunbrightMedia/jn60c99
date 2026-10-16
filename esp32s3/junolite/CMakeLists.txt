# JUNO LITE -- a quick, NOT bit-exact JUNO-style synth for ONE ESP32-S3: 6 voices,
# mip-mapped wavetables, two-saw pulse, 1x ladder VCF, half-rate chorus. README.md.
cmake_minimum_required(VERSION 3.16)
include($ENV{IDF_PATH}/tools/cmake/project.cmake)
project(junolite)
