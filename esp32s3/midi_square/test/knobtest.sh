#!/bin/sh
# Build the KNOB TEST image into esp32s3/flash/knobtest/ (own build dir: fast rebuilds).
cd "$(dirname "$0")/.." || exit 1
idf.py -B build_knobtest -DMSQ_KNOBTEST=1 build >/dev/null || exit 1
D=../flash/knobtest; mkdir -p $D
cp build_knobtest/bootloader/bootloader.bin $D/ && cp build_knobtest/partition_table/partition-table.bin $D/partitiontable.bin \
  && cp build_knobtest/juno_s3.bin $D/juno_s3.bin && ls -la $D
