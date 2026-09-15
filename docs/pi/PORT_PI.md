# PORT_PI — bare-metal Raspberry Pi bring-up (LIVING)

Binding order (user, 2026-09-15): "Start the zero 2 w bare-metal bring up, we
will first flash and debug on a raspberry pi 3A+ compute board as zero 2 w's
are months away."

## Why this track exists
The four-ESP32-S3 chain is retired. Every live-bench failure of the prior week
lived in the transport layer this project INVENTED — the chain, the links, the
scheduler — never in the ported DSP. The user's decision: delete that layer.
Run ALL six voices + full FX on ONE bare-metal board, no Linux, no RTOS. The
glue that remains (render callback, I2S out, key/pot in, boot) is ~300 lines,
not thousands.

- Target silicon: BCM2837 (4× Cortex-A53, AArch64). Same binary on Zero 2 W,
  Pi 3A+, Pi 3B — one build serves all three.
- Prototype board: Pi 3A+ (Zero 2 W's are months out; identical SoC).
- Framework: Circle (bare-metal C++, boots direct to metal, interrupt-driven
  I2S). MiniDexed (bare-metal polyphonic DX7 on the same SoC) is the precedent.

## LOAD-BEARING RISK — RETIRED (2026-09-15)
The whole plan rested on one claim: the bit-exact engine keeps its seal when
built for ARM. PROVEN, before any board is bought.

- Harness: `tools/pi/arm_bitexact.c` — renders factory patches through the
  engine's own `juno_gui_*` API, FNV-1a over the raw float output bytes. Any
  single-bit float difference changes the hash.
- Method (two-build diff, x86 native vs aarch64 cross under qemu):
  ```
  FLAGS="-std=c99 -O2 -ffp-contract=off -fno-strict-aliasing -w -Isrc -Igui"
  SRC="$(ls src/*.c) gui/juno_bridge.c tools/pi/arm_bitexact.c"
  cc              $FLAGS         -o /tmp/be_x86 $SRC -lm
  aarch64-linux-gnu-gcc $FLAGS -static -o /tmp/be_arm $SRC -lm
  /tmp/be_x86       truth/presetbankog1.bin
  qemu-aarch64 /tmp/be_arm truth/presetbankog1.bin
  ```
- RESULT: **ALL 64 PATCHES BIT-IDENTICAL x86 == aarch64.** Every hash equal,
  byte for byte. The 12-patch spread, on the record:

  | patch | hash (both x86 and aarch64) |
  |------:|-----------------------------|
  |  0 | d14d61ab4a49c2e0 |
  |  5 | 4cbf32a7cfb7da99 |
  | 11 | bd92b9d0c65bc0c5 |
  | 21 | 82ab70f24e5c790b |
  | 27 | 69d542f68ec306f6 |
  | 36 | 179b9b437819e100 |
  | 42 | b8897422945c1047 |
  | 48 | 46599f527bff2f69 |
  | 55 | e6eb98f21104a7ca |
  | 60 | dfffa67b09018295 |
  | 63 | 92cf4ba60d44c912 |
  |  7 | 1b1a5e850afdf3d6 |

## The one bug the ARM build found
`src/juno_ftz.c` `juno_enable_hw_ftz()` reached the flush-to-zero control
register with AArch32-only `vmrs/vmsr fpscr`. That does not assemble on
AArch64. Without it the denormal reverb/delay tails would NOT flush and would
diverge from x86 — a SILENT bit-exactness break, not a crash. Fixed: AArch64
uses `mrs/msr fpcr`, same FZ bit 24. This is the first real ARM-port defect,
caught by the gate before silicon.

## Cost headroom (why one board fits)
6 voices + FX ≈ 1.7 GHz-equivalent (S3 measurement, b45). Pi 3A+ / Zero 2 W =
4× 1.4 GHz Cortex-A53. Budget is comfortable; the S3's problem was never the
DSP cost, it was the invented transport.

## BOOT STEP — DONE (2026-09-15)
Circle Step51 is a pinned submodule at `pi/circle`. The platform glue is
`pi/kernel/` (~150 lines total): `kernel.{h,cpp}` boot to metal, init UART +
timer, print a banner; `main.cpp` is the Circle entry; `bare_stubs.c` is the
one shim the `aarch64-linux-gnu-` toolchain needs (`__getauxval` → 0, selects
the portable atomic path; Circle upstream uses `aarch64-none-elf-` and has no
such call). `build.sh` makes the hardware image; `run_qemu.sh` is the gate.

RUN-PROOF (not "it built" — it BOOTS AND RUNS): the `--qemu` variant booted on
the emulated **Pi 3A+** (`qemu-system-aarch64 -M raspi3ap`, the exact prototype
board, BCM2837), captured UART:

```
logger: Circle 51 started on Raspberry Pi 3 Model A+ 512MB (AArch64)
00:00:00.56 juno: JUNO bare-metal bring-up — BOOT OK
00:00:00.56 juno: Circle on Raspberry Pi 3 Model A+
00:00:00.56 juno: SoC BCM2837, 512 MB RAM, 4 cores
00:00:01.00 juno: alive t=1 ... t=5
00:00:05.00 juno: BOOT PROOF COMPLETE — halting.
```

The kernel reaches our code, reads the SoC/RAM/cores correctly, runs a 5-beat
heartbeat, and halts clean. Same source also builds the hardware `kernel8.img`
(one image serves Zero 2 W / 3A+ / 3B). Repeat: `sh pi/run_qemu.sh raspi3ap`.

Container deps (ephemeral): `apt-get install -y gcc-aarch64-linux-gnu
g++-aarch64-linux-gnu qemu-system-arm`.

## NEXT (open, in order)
1. ~~Circle build system for BCM2837; boot to metal, UART.~~ **DONE (above).**
2. I2S DAC output driver (48/44.1 kHz) → the render callback pulls
   `juno_gui_render` into the DMA ring. NOTE: the engine is C99 + libm
   (expf/fabsf). On bare metal, link it against Circle's math (`addon/`) or
   newlib; prove the same bit-exact hash on-metal as the qemu-user run.
3. Input: GPIO keys/octave/pots (same panel law as S3 `S3L_PANEL`), MIDI-in.
4. SIGNAL-level gate: device output CRC + a DISCONTINUITY/tick metric vs the
   host render. The S3 tick passed every state gate because NO gate watched the
   waveform. On the Pi the waveform IS the gate.
5. Cardless dev flash (rpiboot over USB); production SD-NAND / eMMC later.

## HARD LESSON carried in (SHIP LAW)
Never validate by ear, live layer included. No Pi image ships to the user
until its own signal gate proves the end state. The user's ears are not the
detector.
