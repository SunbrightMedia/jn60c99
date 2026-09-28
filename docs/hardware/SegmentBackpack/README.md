# SegmentBackpack — 4-digit 7-segment display on an I2C HT16K33A (2026-09-23)

`SegmentBackpack.kicad_sch` = the user's schematic (KiCad 10) WITH the address network wired by net labels (Claude's edit,
requested by the user 2026-09-23; `add_address_labels.py` is the exact script that made the edit from the user's upload:
2-pad jumpers, labels on every JP/D/R pin, stale GND labels, no-connects on U1 23-25 and two loose A1/A2 labels removed).
A pin-to-label check found every pin on its intended label and no loose label. KiCad ERC was NOT run here — run it.

## Parts (LCSC numbers as placed in the schematic)
| ref | part | LCSC | note |
|---|---|---|---|
| U1 | HT16K33A-28SOP | C5444737 | VDD 4.5-5.5 V -> runs at +5V |
| LED1-4 | FJ8106BH 0.8" red, common anode | C10692 | pins 7 A, 6 B, 4 C, 2 D, 1 E, 9 F, 10 G, 5 DP; 3 + 8 = the digit's common anode |
| Q1, Q2 | BSS138 | C52895 | I2C level shifter 3V3 <-> 5V (Q1 SDA, Q2 SCL) |
| R25, R26 | 10 k 0805 | C17414 | 5 V-side pull-ups (SDA5, SCL5) |
| R1-R3 | 39 k 0805 (0805W8F3902T5E) | C25826 | address resistors; C25826 is the USER's choice — its page was not visible from here: confirm 39 k / 0805 |
| D1-D3 | 1N4148W | C81598 | pin 1 = cathode (bar), pin 2 = anode (datasheet-checked by the user) |
| JP1-JP3 | SolderJumper_2_Open | — | footprint Jumper:SolderJumper-2_P1.3mm_Open_TrianglePad1.0x1.5mm |
| C62 | 100 nF 0603 | C14663 | U1 decoupling |
| C53 | 10 uF 0805 | C15850 | bulk, +5V |
| J16, J17 | JST-XH 4-pin | — | parallel bus in/out: 1 GND, 2 +3V3, 3 SDA, 4 SCL |
| J32 | JST-XH 2-pin | — | 1 GND, 2 +5V |

## Nets
- Segments on COM0-7: COM0 (pin 2) SEG_A, COM1 SEG_B ... COM6 SEG_G, COM7 (pin 9) SEG_DP. Digits on ROW3-6: pin 22 DIG1,
  21 DIG2, 20 DIG3, 19 DIG4. VDD pin 28 = +5V, VSS pin 1 = GND, SCL pin 26 / SDA pin 27 = the 5 V side (SCL5/SDA5 via Q2/Q1).
- BSS138: gate -> +3V3, source -> the 3V3 bus line, drain -> the 5 V line (SDA5 / SCL5) with R25/R26 to +5V. The 3V3-side
  pull-ups live on the ESP32 bus, not here.
- ADDRESS (HT16K33 method: a diode + 39 k from COM0/AD to a ROW pin sets that bit to 1; open = 0):
  | bit | chain |
  |---|---|
  | A0 | U1 pin 2 (SEG_A) - JP1 - A0_J - D1 - A0_D - R1 - A0 = U1 pin 23 (ROW2) |
  | A1 | U1 pin 2 - JP2 - A1_J - D2 - A1_D - R2 - A1 = U1 pin 24 (ROW1) |
  | A2 | U1 pin 2 - JP3 - A2_J - D3 - A2_D - R3 - A2 = U1 pin 25 (ROW0) |
  Address = 0x70 + 4*A2 + 2*A1 + A0. A PCA9539 on the same bus owns 0x74-0x77 -> keep JP3 OPEN there (0x70-0x73).

## ⚠ OPEN: diode direction (not verified — every datasheet host was blocked from Claude's network)
The file puts each bar (pin 1, K) toward the resistor/ROW side, anode toward COM0 (INFERRED: the pin names say COM1-3 are
key-scan DRIVE pins and ROWs are key INPUTS, so COM0/AD probably drives and the ROWs read). Check the address-setting figure
of the HT16K33 datasheet (SparkFun or Adafruit copy) and swap the A_J / A_D labels on D1-D3 if it shows the bar toward COM0.
A wrong direction cannot damage anything (39 k limits ~0.1 mA): the chip just reads 0 for that bit (address stays 0x70).

## Placement
| part | next to |
|---|---|
| C62 | U1 pins 28 (VDD) and 1 (VSS) — same end of the SOP-28, as close as possible |
| C53 | J32 (+5 V in) or near C62 |
| R25 / R26 | Q1 / Q2, on the drain (5 V) side |
| R1 / R2 / R3 | U1 pins 23 / 24 / 25 |
| D1-D3, JP1-JP3 | one small group between R1-R3 and U1 pin 2; jumpers reachable with an iron |

## Lesson paid (2026-09-23)
Claude first said "delete JP1-JP3, nothing fitted = 0x70" — true for ONE board, wrong for "many addresses", and the
3-pad-to-GND jumpers it had drawn were the XL9555/PCA955x style, which the HT16K33 does not use. Read the chip's own
address method before advising on jumpers.
