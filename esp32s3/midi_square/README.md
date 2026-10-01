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
| Battery sense: 10k from charger OUT+ to the pin, 10k from the pin to GND | 10 |
| Charger CHRG / STDBY (LED pins, each via 10k; optional) | 13 / 14 |
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
- `WAVES: voice render check ... MATCH` -- a libm-free render CRC vs the host
  (test/wave_crc.c): the board plays the samples the host measured.
- `IRAM: ... all in IRAM` -- the voice loop and the FX stage run from IRAM
  (main/linker.lf), read from the linked symbols, not from the .lf file.
- `STRESS (muted) 6 voices x 7 osc, morph, chorus 255, reverb 255: core1 X% (FX alone F%)
  core0 Y%, split a/b` -- the measured WORST CASE per 5 ms block; FAIL (latched)
  above 90 %. The split is ADAPTIVE: core 1 carries the FX, so it takes fewer voices.
- `OLED: SSD1306 128x32 at 0x3C, try N` (cold start: up to 10 tries with bus
  reset; re-init every 2 s heals a display that reset later), `INTRO: .. worst
  frame gap .. (smooth)`, `KNOBS: 1..5 ...`, `PARAM <name> <value>` per move.
- `STAT ... cpu1=avg%/max% (fx F%) cpu0=.. split=a/b oled=frames/errors | SIL | HEALTH`.
  SIL is measured on the VOICE (pre-FX): a reverb tail is not a stuck note.
  STUCK = a block that BEGAN with all voices idle (and no key during it) was not 0.

## v7 costs and fixes (2026-09-30, from the v6 board log)
- v6 STRESS FAIL (core1 146 %): the FX stage alone was ~60 % idle. Fixes: the
  delay stage runs its own OFF law (EB_NODELAY, fail-closed, gated EXACTLY 0 vs
  the full recall path) instead of the 524 KB PSRAM ring; audio code in IRAM;
  64 KB / 64 B-line data cache; voice loop with the shape switch hoisted
  (test/render_equiv.c: BIT-EXACT vs the frozen v6 loop, test/ref_render.c).
- v6 LOOPBACK 5/6 bytes: the core-0 voice worker preempted the bit-banged byte;
  each byte is now one critical section.
- Knobs: 8x oversample, IIR 0.10, 1 % deadband, 4 % focus move (the test now uses
  the board's +-3 % noise). A 100 nF cap from each wiper to GND helps most.
- Screen: the intro starts after the boot tests (v6 stutter = STRESS loading
  core 0). BOARD v7: `INTRO: 87 frames in 2601 ms, worst frame gap 30 ms (smooth)`.
- BOARD v7 (measured): `STRESS ... core1 65% (FX alone 41%) core0 66%, split 2/4 PASS`
  (v6: core1 146 %, core0 74 %). Idle FX 41-43 % of core 1. LOOPBACK PASS.

## v8 (2026-09-30)
- Dimming: v7 faded CONTRAST alone (143 -> 14) and the board showed it "only very
  slightly" dimmer. v8 fades contrast to 0, pre-charge 0xF1 -> 0x11 and VCOMH
  0x40 -> 0x00 in one 2 s smoothstep after 10 s idle (host test: each register
  one-way, contrast <= 8 and pre-charge <= 1 step per frame; tooth bites).
- REVERB default 0 (was 25 %). Host measurement: the HALL part is 85 % fundamental
  (-33 dB at 25 %, under the note and after it) -- the "sine in the background".

## Gates
- `sh test/run.sh` -- voice DSP (pitch, running status, chord pitches by
  Goertzel, stealing, morph, unison, attack, release) + UI frames (intro, focus,
  pick-up, knob-noise immunity, dimming; PNG contact sheet) + render equivalence
  vs the frozen v6 loop + the WAVES host CRC. 7 teeth.
- `bash tools/fx_build.sh` -- the FX chain above.
- `sh test/qemu.sh` -- boots the fake-DMA image in QEMU (quad PSRAM override:
  sdkconfig.qemu): FX CRCs + render CRC MATCH, SELFTEST PASS. QEMU has no ADC, so
  the real image stops at boot there, and no GPIO pads, so LOOPBACK fails there.

## v9 (2026-10-01): battery gauge
- The overview's empty 5th column shows the battery: percent and volts (alternating),
  CHG, FULL, or USB (no sense wire). Below 15 % the icon blinks; at 5 % a LOW BATT
  screen shows for 2.5 s of every 20 s. Gauge = resting LiPo table (ui_bat_pct,
  host-tested, tooth 8); under load it reads a few % low.
- Wired-or-not is measured at boot (pull-down probe on GPIO 10): `BATT: ... divider
  found` or `nothing wired`. STAT carries `bat=`. CHRG and STDBY both LOW reads as
  "on battery" (not a real charger state).

