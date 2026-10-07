# KNOB TEST -- bare test firmware: intro + startup sound, then the 5 knobs and
# the button on the OLED and in the log; each press toggles the button LED.
# No synth, no FX. Build: test.sh (output in ../flash/knobtest/).
cmake_minimum_required(VERSION 3.16)
include($ENV{IDF_PATH}/tools/cmake/project.cmake)
project(juno_s3)
