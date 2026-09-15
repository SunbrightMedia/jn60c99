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

## ENGINE ON METAL — BIT-EXACT (2026-09-15)
The original port (src/, 8 voices, all FX, NO levers, NO compromises) is linked
into the bare-metal kernel and renders audio on the emulated Pi 3A+ at the new
default **48000 Hz**. Every patch is byte-identical to the plugin.

- Default rate: **48 kHz** (proven-exact; friendlier DAC clocking; ~half the
  3A+ compute). Passed once to `juno_gui_create`.
- Shared render+hash core `pi/probe/juno_probe_core.c` is compiled with the
  SAME proven bit-exact flags on host and on metal, so an equal hash means
  equal samples. `pi/probe/host_ref.c` prints the x86 reference; the x86 engine
  nulls EXACTLY 0 vs the plugin, so those hashes ARE the plugin.
- The engine is built into `libjunoengine.a` by `pi/build_engine.sh` with the
  proven flags + only bare-metal-safe additions (freestanding, no stack
  protector, no PIC) — none touch arithmetic. `pi/kernel/bare_libm.c` supplies
  the engine's only libm calls (fabsf/fmodf/lrint/fmax*/fmin*) as exact ops
  (AArch64 instructions + an exact `fmodf`); no glibc libm is linked. Both the
  48 kHz path and bare_libm were re-proven bit-exact under qemu-user (12/12)
  BEFORE the metal run.
- The factory bank is embedded (`bank_blob.S` .incbin) — no filesystem needed.

RESULT, on `qemu-system-aarch64 -M raspi3ap` (captured UART):
```
juno: ENGINE bit-exact gate: original port, 8 voices, no levers
juno: rate 48000 Hz, bank 1294295 bytes, 4000 frames/patch, note 60 vel 105
juno: patch  0  hash 1830844881997e88  pk 0.195906  == MATCH
   ... (all 12 patches) ...
juno: BIT-EXACT RESULT: 12/12 patches identical to the plugin
juno: FULL SYNTH BIT-EXACT ON BARE METAL — EXACT WAVEFORM MATCH
```
The chain is closed: **plugin == x86 == aarch64-user == aarch64 bare-metal.**
One command: `sh pi/run_qemu.sh raspi3ap`.

## NEXT (open, in order)
1. ~~Circle build; boot to metal.~~ **DONE.**
2. ~~Link the engine; render audio; EXACT waveform match vs the plugin.~~
   **DONE (above) — offline render, 12-patch spread. Widen to all 64 next.**
3. I2S DAC output driver (48 kHz) → a real-time render callback pulls
   `juno_gui_render` into the DMA ring; SILENCE PROBE on the shipped output.
4. Input: GPIO keys/octave/pots (same panel law as S3 `S3L_PANEL`), MIDI-in.
5. Real-time SIGNAL gate on the live callback: output CRC + a DISCONTINUITY/tick
   metric vs the host render. The S3 tick passed every STATE gate because none
   watched the waveform. On the Pi the waveform IS the gate.
6. Multi-core split (voices across the 4 A53 cores; shared RAM, no links) to
   hit real time; then the 64-patch on-metal gate under the live clock.
7. Cardless dev flash (rpiboot over USB); production SD-NAND / eMMC later.

## HARD LESSON carried in (SHIP LAW)
Never validate by ear, live layer included. No Pi image ships to the user
until its own signal gate proves the end state. The user's ears are not the
detector.
