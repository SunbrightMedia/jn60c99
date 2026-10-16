#!/bin/sh
# build.sh -- host check, then the image, merged into ONE file to flash at 0x0:
#   ../flash/boardtest/board_test.bin   (no hyphens: the download path strips them)
# Needs ESP-IDF sourced (CLAUDE.md BUILD & GIT).
set -e
cd "$(dirname "$0")"
T=${TMPDIR:-/tmp}/boardtest_host
cc -O2 -Wall -Wextra -o "$T" test/host_check.c main/tone.c -lm && "$T" "$T.wav"
idf.py -B build build
mkdir -p ../flash/boardtest
python -m esptool --chip esp32s3 merge-bin -o ../flash/boardtest/board_test.bin \
  --flash-mode dio --flash-size 8MB --flash-freq 80m \
  0x0 build/bootloader/bootloader.bin 0x8000 build/partition_table/partition-table.bin \
  0x10000 build/boardtest.bin
ls -l ../flash/boardtest/board_test.bin
