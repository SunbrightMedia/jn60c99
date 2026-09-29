# Minisynth headphone amp — through-hole, one 5 V supply (written 2026-09-29)

For the wire-frame minisynths: ESP32-S3 + GY-PCM5102 (I2S DAC) + this amp. Volume is digital (pot -> ADC ->
sample scaling in firmware, 32-bit I2S, -6 dB fixed headroom so the 5 V amp cannot clip). Circuit INFERRED
(not simulated); check the NJM4556A datasheet pinout (standard dual op-amp: 1 OUTA, 2 -INA, 3 +INA, 4 V-,
5 +INB, 6 -INB, 7 OUTB, 8 V+). DigiKey pages below were found by web search 2026-09-29 (stock/price not read).

## Circuit
- U1 pin 8 = 5 V, pin 4 = GND; followers: pin 1-2, pin 7-6.
- 100 nF + 10 uF from pin 8 to GND, at the chip.
- VREF 2.5 V: 10 k from 5 V and 10 k to GND; 47 uF from VREF to GND.
- LOUT -> 1 uF -> pin 3; ROUT -> 1 uF -> pin 5; 100 k from pin 3 and pin 5 to VREF.
- pin 1 -> 33 R -> 220 uF (+ at chip) -> jack tip (L); pin 7 -> 33 R -> 220 uF -> ring (R); sleeve = GND.

## DigiKey BOM, one synth
| qty | part | value | manufacturer PN |
|---|---|---|---|
| 1 | op-amp DIP-8 | dual high-current | Nisshinbo NJM4556AD (NJM4556AD-ND) |
| (1) | DIP-8 socket, optional | 0.3" | CNC Tech 245-08-1-03 (TE 1-2199298-2 is discontinued) |
| 2 | electrolytic | 220 uF 16 V | Nichicon UVR1C221MED1TA (Panasonic ECA-1CM221 = P5139-ND out of stock 2026-09-29) |
| 1 | electrolytic | 47 uF 16 V | Panasonic ECA-1CM470 |
| 1 | electrolytic | 10 uF >=10 V | any in-stock radial (ECA-1EM100 = P5148-ND out of stock 2026-09-29); optional with a short 5 V wire |
| 2 | film | 1 uF 63 V | WIMA MKS2C041001F00KSSD |
| 1 | ceramic | 100 nF 50 V | KEMET C320C104K5R5TA |
| 2 | resistor 1/4 W | 33 R | Stackpole CF14JT33R0 |
| 2 | resistor 1/4 W | 10 k | Stackpole CF14JT10K0 |
| 2 | resistor 1/4 W | 100 k | Stackpole CF14JT100K |
| 1 | stereo jack (TRS) | 3.5 mm or 1/4" | Same Sky SJ1-3523N (CP1-3523N-ND), or the user's own 1/4" TRS jack |

## MIDI IN with a 6N137 (user's wiring convention, 2026-09-29)
USER-BINDING: the DIN jack's 5 pins form an arc ("smiley"); call them **position 1 (leftmost) .. 5 (rightmost)**.
Never use DIN standard numbers with this user. DIN order along the arc is 1-4-2-5-3, so position 3 = shield
(unused), positions 2 and 4 = the MIDI current loop, positions 1 and 5 = unused. Which of 2/4 is "+" depends on
the view side: wire one way, swap if the log shows edges=0 while playing (reverse = LED off, no damage).
6N137 (from memory; check the datasheet): 2 = LED anode, 3 = LED cathode, 5 = GND, 6 = open-collector output,
7 = enable (HIGH = on), 8 = VCC 4.5-5.5 V (NOT 3.3 V).
- position 2 -> 220 R -> pin 2; position 4 -> pin 3; 1N4148 across pins 2/3, stripe on pin 2.
- pin 8 -> 5 V; pin 7 -> 5 V; pin 5 -> GND; 100 nF pin 8 to pin 5 at the chip.
- pin 6 -> GPIO 18, 1 k pull-up to 3.3 V (never 5 V).
