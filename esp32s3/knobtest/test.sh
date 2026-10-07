#!/bin/sh
# Build the bare KNOB TEST into ../flash/knobtest/ (3 files to flash).
cd "$(dirname "$0")" || exit 1
idf.py build >/dev/null || { idf.py build 2>&1 | grep -E "error" | head; exit 1; }
D=../flash/knobtest; mkdir -p $D
cp build/bootloader/bootloader.bin $D/ && cp build/partition_table/partition-table.bin $D/partitiontable.bin && cp build/juno_s3.bin $D/ && ls -la $D
