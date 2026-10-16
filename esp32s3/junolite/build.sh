#!/bin/sh
# build.sh -- host check, then the merged image ../flash/junolite/juno_lite.bin (flash at 0x0).
set -e
cd "$(dirname "$0")"
T=${TMPDIR:-/tmp}/junolite_host
cc -O2 -Wall -Wextra -o "$T" test/host_check.c main/jl_synth.c -lm && "$T" "$T.wav"
idf.py -B build build
mkdir -p ../flash/junolite
python -m esptool --chip esp32s3 merge-bin -o ../flash/junolite/juno_lite.bin --flash-mode dio --flash-size 8MB \
  --flash-freq 80m 0x0 build/bootloader/bootloader.bin 0x8000 build/partition_table/partition-table.bin 0x10000 build/junolite.bin
ls -l ../flash/junolite/juno_lite.bin
