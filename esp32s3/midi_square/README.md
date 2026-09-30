# MINISYNTH -- the ESP32-S3 bench synth (grew from the MIDI square test)

DIN MIDI -> 6 voices (each a 7-oscillator unison stack, waveform morph sine >
triangle > saw > square with band-limited saw/square, its own attack/release;
same key reuses its voice, else free, else quietest releasing, else the oldest
held note is stolen; voices 1-3 render on core 1, 4-6 on a core-0 worker) -> the **JUNO
FX stage only** (the proven engine_b master chain: JUNO CHORUS 2 + HALL 1, delay
off) -> PCM5102 over I2S, 48 kHz. Five knobs, two banks, 128x32 SSD1306 OLED.
Not a JUNO voice port.

## Pins
| signal | S3 GPIO |
|---|---|
| I2S BCK / LCK / DIN | 5 / 6 / 7 |
| MIDI RX (6N137 pin 6, 1 k to 3.3 V) | 18 |
| Knob 1 SHIFT / 2 / 3 / 4 / 5 (wipers; ends to 3.3 V and GND) | 1 / 2 / 4 / 8 / 9 |
| OLED SDA / SCL (3.3 V, GND) | 11 / 12 |
Wiring pictures: docs/hardware/midi_in_6n137.png, docs/hardware/PCM5102_MODULE.md.

## Controls
| knob | bank A (MAIN) | bank B (SHIFT) |
|---|---|---|
| 1 | SHIFT: below half = A, above half = B (hysteresis) | |
| 2 | WAVE sine..tri..saw..square | UNISON 1..7 oscillators, detune to +-25 cents |
| 3 | ATTACK 1 ms .. 2 s | RELEASE 10 ms .. 2 s |
| 4 | CHORUS = EFFECT DEPTH byte 0..255 (0 = bypass) | REVERB = REVERB LEVEL byte 0..255 |
| 5 | free | free |
A knob takes the SCREEN only after a 2 % move (ADC noise cannot flip it);
knob 5 (no parameter) never takes it. After a bank change a knob PICKS UP (no jump): the bar is dotted and the screen
says TURN > / < TURN until the knob crosses the stored value.

## The JUNO FX (bit-exact, and how that is proven)
- `tools/fxgen.c` runs the port's own recall (factory patch 14: chorus arm, delay
  off), forces EFFECT TYPE 3 (JUNO CHORUS 2), TONE 0, REVERB TYPE 2 (HALL 1), and
  recalls every EFFECT DEPTH and REVERB LEVEL byte (256 each). It FAILS if any
  field other than cho.wet / in.k84544 / rev.send moves. Output: main/gen/msq_fx.h.
  Built 32-bit (the state holds ring pointers; the S3 is ILP32); the 64-bit run
  must give the identical coefficient image and tables.
- `tools/fx_gate.c`: firmware path (fx.c + tables) == recall path, EXACTLY 0 on 7
  scenarios incl. knob moves mid-note and in the tail. Tooth (one LSB) MUST fail.
- On the S3 at boot: coef CRC and 730 KB state CRC vs host, and a fixed-signal
  RENDER CRC vs the host (tools/fx_crc.c) -- proves the S3 arithmetic. Tooth: a
  -ffp-contract=fast build reports MISMATCH (354 fused ops vs 0 shipped).
- Run all: `bash tools/fx_build.sh` (needs gcc-multilib).

## What the log proves
- `FX: ... coef crc .. state crc .. MATCH`, `FX: render check ... MATCH`
- `SELFTEST ... PASS` (starvation tooth, A4 pitch/peak/silence, FX dry path ~6000)
- `LOOPBACK ... PASS` (pin -> UART -> parser -> synth)
- `STRESS (muted) 6 voices x 7 osc, morph, chorus 255, reverb 255: core1 X% core0 Y%`
  -- the measured WORST CASE per 5 ms block; FAIL (latched) above 90 %.
- `OLED: SSD1306 128x32 at 0x3C`, `KNOBS: 1..5 ...`, `PARAM <name> <value>` per move
- `STAT ... out=.. cpu=avg%/max% oled=frames/errors | SIL | HEALTH`. SIL is measured
  on the VOICE (pre-FX): a reverb tail is not a stuck note.

## Gates
- `sh test/run.sh` -- voice DSP (pitch, running status, chord pitches by
  Goertzel, stealing, morph, unison, attack, release) + UI frames (intro, focus,
  pick-up, knob-noise immunity; PNG contact sheet). 5 teeth.
- `bash tools/fx_build.sh` -- the FX chain above.
- `sh test/qemu.sh` -- boots the fake-DMA image in QEMU (quad PSRAM override:
  sdkconfig.qemu): FX CRCs + render CRC MATCH, SELFTEST PASS. QEMU has no ADC, so
  the real image stops at boot there, and no GPIO pads, so LOOPBACK fails there.
