cmake_minimum_required(VERSION 3.16)
include($ENV{IDF_PATH}/tools/cmake/project.cmake)
# The output is named juno_s3.bin ON PURPOSE: the flash command in CLAUDE.md
# names juno_s3.bin verbatim, so this test image flashes with the same line.
project(juno_s3)
