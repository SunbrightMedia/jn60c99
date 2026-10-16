# JUNO LITE — a quick, NOT bit-exact JUNO-60-style synth on ONE ESP32-S3

The user's request (2026-10-16): "a basic working port on the S3 ... quickly, but it must work". The bit-exact port
does not fit one S3 (docs/ONE_BOARD_BUDGET.md); this is the cheap engine that does. It is NOT graded against the
bit-exact port yet (that sonic gate is the next step); nothing here is PROVEN equal to the plugin.

| part | how | cost lever |
|---|---|---|
| DCO | mip-mapped band-limited saw (11 tables x 2048, built at boot, ~0.4 s); pulse = saw(p) − saw(p+w); sub = same at half phase; noise | replaces the ~1,868 cyc/voice WT DCO |
| VCF | 4 one-pole ladder, 1x rate, soft-clipped feedback, cutoff per 64-sample block (g ramped) | replaces the 4x-oversampled ladder |
| ENV / VCA | ADSR per voice; VCA by ENV or GATE | — |
| FX | HPF on the sum; chorus I / II / I+II at half rate (22.05 kHz) | — |
| presets | 5 hand-set panels (Strings, Brass, PWM Pad, Bass, Organ) — NOT the factory bank | — |

Pins (fab netlist): I2S BCK/WS/SD = GPIO 5/6/7; MIDI IN = UART1 RX GPIO 17 (H1A1 pad 10, MIDI_RX), 31250 baud.
MIDI: omni; notes; bend ±2; CC1 mod (LFO→DCO), CC7 volume, CC71 resonance, CC74 cutoff, CC120/123 all off;
program change = preset. No MIDI → a demo plays every preset (6-note + 4-note chord) until the first MIDI note.

## Checks
- `test/host_check.c` (build.sh runs it): finite, never at the clip ceiling, every preset sounds, 6 voices, exact 0
  after release; saw at 2,217 Hz aliasing SNR 48 dB (≥ 30). Tooth: `-DJL_TOOTH_NOMIP` → 14 dB → FAIL (seen).
- `test/qemu.sh`: boots, 5 BENCH lines, the demo reaches 6 voices, silence probe SILENT, never STUCK (the probe was
  seen to fail: it read the chorus tail as STUCK until it waited > 100 blocks after the last voice).
- QEMU BENCH (NOT the chip's timing): 13–21 % of one core for 6 voices. The board's own BENCH lines decide.

## On the board (2026-10-16, the user's DevKitC-1 N16R8 on the motherboard, 70ad29c image)
BENCH (6 voices, one core, MEASURED): Strings 48.5 %, Brass 48.3 %, PWM Pad 62.2 %, Bass 58.3 %, Organ 61.8 %.
Demo 17 s: underruns 0, max block load 82 % (first block), SIL never STUCK; every JL peak equals the QEMU log's
(2602, 2458, 1973, ... 4645) — the chip renders the same samples as the host build. Core 0 is idle.
