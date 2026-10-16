# BOARD TEST — first power-up of the ESP32-S3 motherboard + Headphone_Dac

No synth. It plays, forever: 0.5 s silence, **LEFT** beep 440 Hz (1.5 s), **RIGHT**
beep 880 Hz (1.5 s), a short melody on both channels (the opening of Tárrega's
*Gran Vals*, 1902, public domain — the phrase the Nokia ringtone used), 1.5 s silence.
Level: peak 1036 = −30 dBFS (the TPA6120 stage has gain 2 and no volume control).

## Pins (READ from the fab netlist, docs/hardware/bom/inputs/*_netlist.ipc)
| signal | motherboard | DevKitC-1 | Headphone_Dac |
|---|---|---|---|
| BCK | H1A1 pad 5 | GPIO 5 | J16.2 → R5 → U1.13 |
| WS  | H1A1 pad 6 | GPIO 6 | J16.3 → R6 → U1.15 |
| SD  | H1A1 pad 7 | GPIO 7 | J16.4 → R7 → U1.14 |
| power | AUDIO 3-pin: GND, +5V (DevKit 5V pin), +3V3 (DevKit 3V3) | | J11: GND, +5V, 3V3A |
The DevKitC-1 J1 order (3V3, 3V3, RST, IO4, IO5, IO6, IO7 …) maps pads 5/6/7 to
GPIO 5/6/7 (INFERRED from that order; the netlist's 3V3/5V/GND pads agree).
`docs/hardware/MOTHERBOARD_PINOUT.md` lists IO15/16/17: the fabbed board uses 5/6/7.
PCM5102A: SCK and FMT to GND (internal PLL, I2S format), XSMT pulled high (unmuted).

## Log (115200 baud, the DevKit's UART port)
    === BOARD TEST v1 (no synth) -- I2S BCK=GPIO5 WS=GPIO6 SD=GPIO7, 44100 Hz ...
    BT I2S started
    BT stage=LEFT 440Hz  frames= 66150 peakL= 1036 peakR=    0
    ...
    BT-LOOP 2  frames=405720  9.200 s  rate=44100 Hz (want 44100)  i2s_errors=0
`rate` is the I2S clock as the blocking writes measure it: ~44100 proves the S3
side clocks out data. It cannot prove the DAC board: that is the user's test.

## Checks
- `test/host_check.c` — renders the device's own tone.c, grades lengths, channel
  isolation, peaks, pitch; writes a WAV. Seen to fail on 3 planted defects
  (channel leak, wrong pitch, over-level).
- `test/qemu.sh` — boots the image in QEMU (no I2S there: a timer stub) and checks the log.
- `build.sh` — host check + image → `../flash/boardtest/board_test.bin` (merged, flash at 0x0).

## If there is no sound
1. No `BT I2S started` / no BT lines → the S3 side (power, USB port, image).
2. BT lines OK, `rate` ~44100, silent → the DAC board: 3V3A and +5V at J11, VNEG ≈ −5 V
   (U12 LM2776), XSMT high, the I2S cable pin order (pin 1 = GND on both ends).
3. Only one side sounds → that channel's HP path (U2, R8/R9, jack J8).
