# MasterAudio — the 4-slot carrier board (design reference, 2026-09-02)

The user's board: hosts 1–4 socketed ESP32-S3 DevKitC-1 N16R8 boards (44-pin,
2×22 female headers), JLCPCB-assembled, all SMD, all parts LCSC. The user
draws the schematic by hand in KiCad; `MasterAudio_reference.kicad_sch` in
this directory is the machine-generated reference netlist (every connection as
global labels) to check against. PCB-stage notes: `PCB_PLACEMENT.md`.

## Socket row map (row 1 = top; L/R as viewed with USB at the bottom)

A 40-pin board centres in the 2×22 socket: rows 1 and 22 stay empty, all
signals then align. Print this on the silkscreen.

| Rows | Content |
|---|---|
| L1,L2 | 3V3 out of the dev board — per-slot net 3V3_ESPn, NEVER joined between slots (paralleling regulators) |
| L3 | EN/RST → JST J21–J24 (short to GND = reset) |
| L5–L7 | IO5/6/7 — slot 1 only: I2S to DAC through 33 Ω at the source |
| L8–L10 | IO15/16/17 — chain TX (slot n → slot n−1); slot 1's go to EXT2 spare |
| L11 | IO18 — slot 1: MIDI_RX |
| L15–L17 | IO9/10/11 — chain RX; slot 4's reserved for a future audio-in header |
| L21 / GNDs | +5V (fused) / ground |
| R5 | IO2 — slot 1: VOL_ADC (pot wiper → 10 k + 100 nF) |
| R6, R7 | IO42 CTRL_RSP (open-drain, ONE 10 k pullup to 3V3A), IO41 CTRL_BC — all slots |
| R14 | IO0 BOOT (slot 1 → JST J25) |
| R18 | IO21 — slot 1: MIDI_TX |
| R19, R20 | IO20/IO19 USB D+/D− per slot → CD4052 mux → upload USB-C |

DO NOT USE on any slot: R2/R3 (serial console IO43/44), R11–R13 (octal-PSRAM
IO35/36/37), R16 (IO48 onboard RGB LED — LED current spikes couple into the
DAC; measured precedent in this project). Strapping pins IO0/IO3/IO45/IO46
must float at boot.

## The audio chain

Slot 4 → 3 → 2 → 1, three wires per hop (BCK/WS/SD), TX pins IO15/16/17 into
RX pins IO9/10/11. Populate slots in order 1,2,3,4 — never skip. Slot 1 is
master: it mixes the chain into its own voices and drives the PCM5102A DAC.

## The blocks (full pin-by-pin connections: the reference .kicad_sch)

- POWER: USB-C (power-only) → polyfuse → +5V; 5.1 k on each CC pin; two 22 µF
  split across the rail; TPS7A2033 → 3V3A (clean analog rail — DAC, mux, opto,
  pot; never the ESP 3V3 pins); LM2776 (LCSC C69527) → VNEG (−5 V) for the
  TPA6120 + OPA1656 negative rails. TPA6120 CANNOT run from 5 V alone.
- DAC: PCM5102A, SCK/FLT/FMT/DEMP→GND, XSMT 10 k→3V3A, internal-pump caps
  2.2 µF ×3. Its pin 5 "VNEG" is its OWN internal rail — cap to GND only,
  NEVER the board VNEG net.
- LINE OUT: per channel one OPA1656 = unity buffer (hot) + 1 k/1 k inverter
  (cold), 33 Ω build-outs → TRS tip/ring. Balanced.
- HEADPHONE: TPA6120, gain 2 (1 k/1 k per channel), 10 Ω build-outs, thermal
  pad EP soldered to ground copper with vias (mandatory). Volume is DIGITAL:
  pot → VOL_ADC → firmware scales pre-quantize.
- MIDI: H11L1 opto in (220 Ω + 1N4148 across the LED, 470 Ω pullup on VO,
  DIN pin 2 OPEN on IN, grounded on OUT/THRU), two SN74AHCT1G126 buffers at
  +5 V (OE→+5V) for OUT and THRU, 220 Ω pairs per DIN; 3-pin JST internal
  MIDI at 3V3 level.
- UPLOAD: second USB-C (data) → USBLC6 ESD → CD4052 (VDD=3V3A, VEE/VSS=GND)
  → per-slot IO19/20. 4-position slide switch encodes A0/A1 (position 4
  drives both through two 1N4148; 10 k pulldowns). J4 must be plugged in
  during flashing — the upload port carries data only.
- Breakout: one 11-pin header per slot, same 8 free GPIOs on every slot
  (IO4,12,13,14,1,40,39,38) + 2×GND + that slot's 3V3.

## BOM deltas still owed (also in PCB_PLACEMENT.md checklist)

1 k → 8 · 10 k +1 (CTRL_RSP pullup) · PM254-1-11 16→20 (breakouts) ·
LM2776 C69527 +1 · 2.2 µF & 10 µF +1 each · JST S2B/S3B/S4B quantities still
blank · verify PJ-603 jack pinout and slide-switch pinout against datasheets.
