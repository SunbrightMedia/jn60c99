#!/bin/bash
# build.sh -- build the QEMU ESP32-S3 instruction-count harness.
#   tools/engineb/qemu/build.sh          -> harness.elf (xtensa, bare metal)
#   tools/engineb/qemu/build.sh host     -> harness_host (native, sanity only)
#
# Flags mirror the project's port build where they are load-bearing:
#   -ffp-contract=off        (the project-wide no-FMA rule; Xtensa LX7 has no
#                             double FMA anyway, but keep the flag uniform)
#   -fno-strict-aliasing, -std=c99, -O2
#   -mlongcalls              (matches tools/engineb/cost.py's s3 flags)
#   -DEB_DELAY_LEN=32768     (NOT the task's 16384: patch 0's REAL delay time
#                             is a 16,872-sample tap, which a 16384 ring
#                             cannot hold -- the tap wrapped into unwritten
#                             zeros and latched `overrun`, caught by the host
#                             sanity run.  The ring length does not change the
#                             per-sample instruction count -- the index mask
#                             is one instruction either way -- and 32768*2*4 =
#                             256 KB fits QEMU's modeled 1.44 MB DRAM.  On the
#                             real S3 neither fits internal SRAM: the delay
#                             ring is the allocation that forces PSRAM.)
set -e
cd "$(dirname "$0")/../../.."          # repo root

QDIR=tools/engineb/qemu
MODS="engine_b/eb_envgen.c engine_b/eb_pwm_cv.c engine_b/eb_vcf_cv.c \
      engine_b/eb_vcf_ladder.c engine_b/eb_vca_hpf.c engine_b/eb_dco.c \
      engine_b/eb_decim.c engine_b/eb_noise_svf.c engine_b/eb_pitch.c \
      engine_b/eb_cvgate.c engine_b/eb_chorus.c engine_b/eb_delay.c \
      engine_b/eb_reverb.c"
CFLAGS="-std=c99 -O2 -ffp-contract=off -fno-strict-aliasing \
        -Iengine_b -Isrc -I$QDIR -DEB_DELAY_LEN=32768"

if [ "$1" = "host" ]; then
    gcc $CFLAGS -DEB_HOST -o "$QDIR/harness_host" "$QDIR/harness.c" $MODS -lm
    echo "built $QDIR/harness_host"
    exit 0
fi

export PATH=/root/.espressif/tools/xtensa-esp-elf/esp-16.1.0_20260609/xtensa-esp-elf/bin:$PATH
CC=xtensa-esp32s3-elf-gcc

$CC $CFLAGS -mlongcalls -nostartfiles \
    -Wl,-T,"$QDIR/link.ld" -Wl,--gc-sections \
    -o "$QDIR/harness.elf" \
    "$QDIR/crt0.S" "$QDIR/uart.c" "$QDIR/harness.c" $MODS -lm

xtensa-esp32s3-elf-readelf -l "$QDIR/harness.elf" | sed -n '1,30p'
xtensa-esp32s3-elf-size "$QDIR/harness.elf"

# verify every loadable segment lands inside the QEMU-modeled SRAM ranges
xtensa-esp32s3-elf-readelf -l "$QDIR/harness.elf" | python3 -c '
import sys
bad = False
for line in sys.stdin:
    f = line.split()
    if f and f[0] == "LOAD":
        va, memsz = int(f[2], 16), int(f[5], 16)
        iram = 0x40370000 <= va and va + memsz <= 0x403F0000
        dram = 0x3FC80000 <= va and va + memsz <= 0x3FDF0000
        if not (iram or dram):
            print("SEGMENT OUT OF SRAM: %#x + %#x" % (va, memsz)); bad = True
sys.exit(1 if bad else 0)'
echo "built $QDIR/harness.elf (all segments inside iram/dram)"
