# Dumb 16-channel analog mux board (`mux16`)

The simplest useful board: one `74HC4067`, 16 JST-XH-3 analog inputs, one 8-pin
header out to the dev board. No microcontroller, no decoder, no firmware.
Ratiometric — runs at 3.3 V *and* 5 V (VCC comes from the dev board).

Each of the 16 input ports is `GND · WIPER · VCC`, so it directly fits a pot or
fader; a button board with an on-board pull resistor also works (its signal
rides the same WIPER pin).

## What's in this folder

| File | What it is |
|------|-----------|
| `mux16.kicad_pro` | KiCad 9 project — open this |
| `mux16.kicad_sch` | Blank schematic sheet, ready to populate (see **Schematic capture** below) |
| `mux16.kicad_pcb` | Blank 1.6 mm 2-layer board |
| `sym-lib-table` | Maps the `control-surface` symbol library (for the `MUX_74HC4067` symbol) |
| `../lib/control-surface.kicad_sym` | Custom `74HC4067` symbol with our exact pin/net names |

> The schematic is intentionally blank. Hand-authored auto-wired KiCad files
> can carry silent connection errors, so instead you get a guaranteed-correct
> **BOM + netlist** to capture from — it's a ~15-minute paste-in and then ERC
> proves it. Everything else (project, symbol, footprints, layout spec) is done.

## BOM

| Ref | Qty | Part | Footprint (KiCad standard lib) | LCSC |
|-----|-----|------|-------------------------------|------|
| U1 | 1 | `CD74HC4067` 16-ch analog mux, SOIC-24W | `Package_SO:SOIC-24W_7.5x15.4mm_P1.27mm` | search `CD74HC4067` (SOIC-24, confirm) |
| J1–J16 | 16 | JST-XH 3-pin, right-angle, `S3B-XH-A` | `Connector_JST:JST_XH_S3B-XH-A_1x03_P2.50mm_Horizontal` | **C157928** |
| J_OUT | 1 | 1×8 pin header, 2.54 mm | `Connector_PinHeader_2.54mm:PinHeader_1x08_P2.54mm_Vertical` | any |
| C1 | 1 | 100 nF, 0805 | `Capacitor_SMD:C_0805_2012Metric` | any |
| C2 | 1 | 10 µF, 0805 | `Capacitor_SMD:C_0805_2012Metric` | any |
| H1–H2 | 2 | M3 mounting hole (Ø3.2 mm) | `MountingHole:MountingHole_3.2mm_M3` | — |

## Netlist (capture exactly this)

**Power / shared rails**
- **VCC** ← U1 pin 24 · every JST pin 3 (J1–J16.3) · C1 + · C2 + · J_OUT pin 7
- **GND** ← U1 pin 12 · every JST pin 1 (J1–J16.1) · C1 − · C2 − · J_OUT pin 8

**Analog channels** (each pot/fader wiper → its own mux channel)
| Net | From | To (U1 pin) |
|-----|------|-------------|
| CH0  | J1.2  | 8  |
| CH1  | J2.2  | 7  |
| CH2  | J3.2  | 6  |
| CH3  | J4.2  | 5  |
| CH4  | J5.2  | 4  |
| CH5  | J6.2  | 3  |
| CH6  | J7.2  | 2  |
| CH7  | J8.2  | 1  |
| CH8  | J9.2  | 22 |
| CH9  | J10.2 | 21 |
| CH10 | J11.2 | 20 |
| CH11 | J12.2 | 19 |
| CH12 | J13.2 | 18 |
| CH13 | J14.2 | 17 |
| CH14 | J15.2 | 16 |
| CH15 | J16.2 | 15 |

**Control / out to dev board** (this is the "8 pins")
| Net | U1 pin | J_OUT pin | Dev-board pin type |
|-----|--------|-----------|--------------------|
| SIG | 23 | 1 | **ADC** |
| S0  | 11 | 2 | GPIO |
| S1  | 13 | 3 | GPIO |
| S2  | 14 | 4 | GPIO |
| S3  | 10 | 5 | GPIO |
| EN̄  | 9  | 6 | GPIO (active-LOW; tie to GND if you never disable it) |
| VCC | 24 | 7 | 3.3 V or 5 V in |
| GND | 12 | 8 | GND |

That's the whole board: 16 analog in → 1 ADC out, plus 4 select + enable + power.

## Schematic capture (≈15 min in Eeschema)

1. Open `mux16.kicad_pro`. If prompted about the `control-surface` library, accept
   (it's mapped in `sym-lib-table`).
2. Place **U1** = `control-surface:MUX_74HC4067`.
3. Place **J1–J16** = `Connector:Conn_01x03_Pin` (or `Connector_Generic:Conn_01x03`).
4. Place **C1, C2** = `Device:C`; **J_OUT** = `Connector:Conn_01x08_Pin`.
5. Place `power:VCC`, `power:GND`, and one `power:PWR_FLAG` on both VCC and GND.
6. Wire per the netlist above. Easiest method: drop a short stub on each pin and
   use **net labels** (`VCC`, `GND`, `CH0`…`CH15`, `SIG`, `S0`–`S3`, `EN`) rather
   than long wires — connectivity is by matching label name.
7. Assign footprints per the BOM table.
8. Run **ERC** — it should be clean. Fix anything it flags before layout.

## PCB layout guidance

- **Size:** aim well under 100 × 100 mm to stay in JLCPCB's cheapest tier.
- **Place the 16 JST connectors along the board edges** (right-angle housings
  overhang the edge — see mechanical note below) so cables exit cleanly.
- **U1 central**, `C1` (100 nF) right across U1 pins 24/12, as close as possible.
  `C2` (10 µF) nearby.
- **Ground pour** on both layers, stitched; keep a continuous return under the
  input area. Short, direct WIPER traces — analog.
- **M3 holes (H1, H2):** Ø3.2 mm, ≥3 mm from board edges and any future V-cut
  line. Standardize their spacing so it matches your other breakout boards.
- **Silk:** label each JST (`CH0`…), pin-1 markers, board name `MUX16 v1`, and
  the J_OUT pinout.

## JST-XH `S3B-XH-A` mechanical (footprint reference)

- **Pitch:** 2.50 mm, 3 contacts in a line.
- **Pin-to-pin span (end to end):** 5.0 mm; **housing length:** ~9.9 mm.
- **Contact posts:** 0.64 mm square; **recommended PCB hole:** ~1.0 mm dia.
- **Right-angle (side entry):** the housing lies flat and the cable exits
  *parallel* to the board — leave clearance past the board edge / keep the
  connector opening facing outward.
- The KiCad footprint `Connector_JST:JST_XH_S3B-XH-A_1x03_P2.50mm_Horizontal`
  already encodes the exact pads and courtyard — use it and confirm against the
  JST `S3B-XH-A` datasheet drawing.

## JLCPCB order settings (cheapest)

1.6 mm · 2-layer · 1 oz Cu · HASL (leaded) · green mask · no special options.
Order the 5-pcs minimum. Buy the C157928 connectors on the same order to combine
shipping. Panelize identical boards with KiKit later (see `../README.md` §6).
