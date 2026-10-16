# BOARD TEST -- first power-up of the ESP32-S3 motherboard + Headphone_Dac board.
# Plays a left beep, a right beep and a short melody out of I2S, forever, and logs
# what it wrote. No synth. Build: build.sh (output in ../flash/boardtest/). README.md.
cmake_minimum_required(VERSION 3.16)
include($ENV{IDF_PATH}/tools/cmake/project.cmake)
project(boardtest)
