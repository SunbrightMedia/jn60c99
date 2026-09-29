# MIDI SQUARE — bench test image (not a synth port)

DIN MIDI in -> one square-wave voice (last-note priority, any channel, 2 ms
attack / 10 ms release, -12 dBFS) -> PCM5102 module over I2S, 48 kHz.

| signal | S3 pin |
|---|---|
| BCK | GPIO 5 |
| LCK (WS) | GPIO 6 |
| DIN | GPIO 7 |
| MIDI RX (UART1, 31,250 baud, pull-up on) | GPIO 18 |

No PSRAM is used, so the image boots on R8 and R2 modules. Console 115200.
Flash set: `esp32s3/flash/midi_square/` (bootloader.bin, partitiontable.bin,
juno_s3.bin — the name matches the CLAUDE.md flash line).

## What the log proves (the log is the detector, not the ear)
- `SELFTEST starvation tooth ... FIRES` — the DMA-starvation counter moved
  when the audio task was stalled on purpose (100 ms, at boot, while silent).
- `SELFTEST A4: 440.0 Hz ok, peak 8192 ok, after release ... SILENT` — an
  internal A4 through the same parser, renderer and I2S path (a 0.5 s beep).
- `NOTE ON/OFF` — one line per MIDI note event.
- `LOOPBACK rx18 idle=H: ... UART got 6, NOTE ON 1, NOTE OFF 1, edges +N, tone
  261.6 Hz ... PASS` — GPIO 18 sends itself a real note (open-drain bit-bang,
  31,250 baud) through the same pin, UART, parser and synth (a short C4 beep).
  The pad stays a GPIO and feeds UART1 through the matrix (playbook 102).
  `idle=L` = something outside holds the line low.
- `PIN rx18=H/L edges=N` counts every edge from outside, independent of the
  UART: edges=0 while playing (with LOOPBACK PASS) = no signal reaches GPIO 18.
- `STAT ... ferr=` — UART frame errors: non-zero while playing = wrong
  polarity/wiring on the MIDI input. `SIL:` SOUNDING / RELEASING / SILENT /
  STUCK. `HEALTH:` OK, or the FIRST fault, latched.

## Gates
- `sh test/run.sh` — host test of `msq_core.c` (the shipped file): pitch by
  zero crossings, running status, vel-0 note-off, real-time bytes inside a
  message, sysex, CC 123, 17-key overflow, exact silence after release. A
  tooth build (running status broken) MUST fail.
- `sh test/qemu.sh` — boots the image in QEMU. The real image MUST report
  SELFTEST FAIL (QEMU has no I2S: the detectors fire) and LOOPBACK FAIL
  (QEMU has no GPIO pads); the `-DMSQ_QEMU=1`
  image (timer plays the DMA) MUST report SELFTEST PASS.
