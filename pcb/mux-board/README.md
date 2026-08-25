# Dumb 16-channel analog mux board (`mux16`)

The core board of the control-surface system: one `74HC4067`, 16 JST-XH-3 analog
inputs, and a shared control bus that chains board-to-board. No microcontroller,
no decoder, no firmware. Ratiometric — runs at 3.3 V **and** 5 V because VCC
comes from the dev board.

Each input port is `GND · WIPER · VCC`, so a pot/fader plugs straight in; a
button board (with its own on-board pull resistor) rides the same WIPER pin.

JLCPCB assembles all SMD parts; you hand-solder the through-hole JST-XH headers
after buying them in bulk.

---

## Connector map (final)

| Ref | Part | Pins | Purpose | Pinout |
|-----|------|------|---------|--------|
| J1–J16 | `S3B-XH-A` | 3 | Analog inputs | `GND · WIPER · VCC` |
| J_IN_A | `S3B-XH-A` | 3 | Chain **in** — analog/power | `GND · SIG · VCC` |
| J_IN_D | `S4B-XH-A` | 4 | Chain **in** — digital | `S0 · S1 · S2 · S3` |
| J_OUT_A | `S3B-XH-A` | 3 | Chain **out** — analog/power | `GND · SIG · VCC` |
| J_OUT_D | `S4B-XH-A` | 4 | Chain **out** — digital | `S0 · S1 · S2 · S3` |
| J_EN | `S2B-XH-A` | 2 | Enable (to master) | `GND · EN̄` |

**Why split the 7-line bus into 3-pin + 4-pin:** keeps the analog SIG line (with
a GND neighbour) physically away from the four fast-switching digital select
lines, and the different pin counts are **mechanically keyed** so you can't
misplug analog into digital. IN and OUT are identical, so any chain cable fits
either end.

**Chain vs enable:** `S0–S3`, `SIG`, `VCC`, `GND` are a **shared bus** — IN and
OUT carry the *same nets* (straight passthrough), daisy-chaining board to board.
Only **EN̄ is unique per board**, so it gets its own 2-pin back to the master.
All muxes' `SIG` wire-OR together; a disabled 4067 goes high-Z, so only the one
enabled board drives the line.

---

## BOM

| Ref | Qty | Part | Footprint (KiCad std lib) | LCSC / note |
|-----|-----|------|---------------------------|-------------|
| U1 | 1 | `CD74HC4067M96` 16-ch analog mux, SOIC-24W | `Package_SO:SOIC-24W_7.5x15.4mm_P1.27mm` | **C496123** |
| J1–J16 | 16 | JST-XH 3-pin RA `S3B-XH-A` | `Connector_JST:JST_XH_S3B-XH-A_1x03_P2.50mm_Horizontal` | **C157928** |
| J_IN_A, J_OUT_A | 2 | JST-XH 3-pin RA `S3B-XH-A` | same as above | C157928 |
| J_IN_D, J_OUT_D | 2 | JST-XH 4-pin RA `S4B-XH-A` | `Connector_JST:JST_XH_S4B-XH-A_1x04_P2.50mm_Horizontal` | **C157925** |
| J_EN | 1 | JST-XH 2-pin RA `S2B-XH-A` | `Connector_JST:JST_XH_S2B-XH-A_1x02_P2.50mm_Horizontal` | **C157931** |
| C1 | 1 | 100 nF, 0805 | `Capacitor_SMD:C_0805_2012Metric` | **C49678** — fast/local decoupling |
| C2 | 1 | 10 µF, 0805 | `Capacitor_SMD:C_0805_2012Metric` | **C15850** — bulk reservoir |
| D1 | 1 | LED, **red, 0603**, normal brightness (~90 mcd) | `LED_SMD:LED_0603_1608Metric` | **C2286** — power indicator |
| R1 | 1 | **10 kΩ**, 0805 | `Resistor_SMD:R_0805_2012Metric` | **C17414** — LED limit, keeps it dim |
| R2–R17 | 16 | **330 Ω**, 0805 — **populated** | `Resistor_SMD:R_0805_2012Metric` | **C17630** — per-input series R |
| JP1 | 1 | solder jumper — **optional** | `Jumper:SolderJumper-2_P1.3mm_Open` | ties EN̄→GND for standalone |
| TP1–TP3 | 3 | test points | `TestPoint:TestPoint_Pad_D1.5mm` | SIG, VCC, GND |
| H1–H4 | 4 | M3 mounting hole Ø3.2 mm | `MountingHole:MountingHole_3.2mm_M3` | — |

### Component notes
- **C1 (100 nF)** sits directly across U1 pins 24/12 — handles fast switching
  noise. **C2 (10 µF)** is the bulk reservoir that keeps VCC from sagging when
  the mux switches; matters extra because **VCC is also the ADC reference**
  (ratiometric). Keep both, close to the chip.
- **LED (D1) + R1 — sized for *barely visible*:** use a **red** LED (Vf ~1.8 V —
  blue/white need ~3 V and go marginal at 3.3 V), normal brightness (~90 mcd),
  **not** a super-bright part. **10 kΩ** sets ~0.15 mA at 3.3 V / ~0.32 mA at 5 V
  — roughly **1/130 of the LED's 20 mA rating**, so it emits ~0.7 mcd: a faint
  glow. Current is fixed by Ohm's law, so dimness is guaranteed regardless of the
  LED. Want it fainter still → 22 kΩ (C17673), but very weak at 3.3 V.
- **Series resistors R2–R17 (populated, 330 Ω):** one in each wiper line.
  Zero steady-state error into the high-Z ADC; limits a fault (input shorted
  to a rail / miswired cable) to ~15 mA at 5 V — inside the 4067's ±25 mA
  absolute max, with margin 220 Ω wouldn't leave. **Voltage-independent**
  (ratiometric-neutral) and swamped by any pot's source impedance.
- **3.3 V / 5 V compatibility comes from the ratiometric design, NOT resistor
  values.** The only resistor that even mildly cares about voltage is R1 (LED),
  and it's fine on both.
- **JP1:** for single-board use with no master, close JP1 to tie EN̄ to GND
  (always enabled). Cut/omit it when a master drives EN̄ through J_EN.

---

## Netlist (capture exactly this)

**Shared rails**
- **VCC** ← U1.24 · J1–J16 pin 3 · J_IN_A.3 · J_OUT_A.3 · C1+ · C2+ · R1 (to D1 anode)
- **GND** ← U1.12 · J1–J16 pin 1 · J_IN_A.1 · J_OUT_A.1 · J_EN.1 · C1− · C2− · D1 cathode

> **Pin numbers verified against the TI datasheet (SCHS209C, C496123).** Note the
> 4067 has **no VEE** — pin 12 is plain GND — and **E (pin 15) is active-LOW**
> (E high ⇒ all channels off).

**Analog channels** (each wiper → its mux channel; through R2–R17 if populated)
| Net | From | To U1 pin |
|-----|------|-----------|
| CH0…CH15 | J1.2 … J16.2 | 9,8,7,6,5,4,3,2,23,22,21,20,19,18,17,16 |

**Shared bus (passthrough IN↔OUT, all same nets)**
| Net | U1 pin | J_IN | J_OUT | To dev/master |
|-----|--------|------|-------|---------------|
| SIG | 1 | J_IN_A.2 | J_OUT_A.2 | ADC |
| VCC | 24 | J_IN_A.3 | J_OUT_A.3 | 3.3 / 5 V |
| GND | 12 | J_IN_A.1 | J_OUT_A.1 | GND |
| S0 | 10 | J_IN_D.1 | J_OUT_D.1 | GPIO |
| S1 | 11 | J_IN_D.2 | J_OUT_D.2 | GPIO |
| S2 | 14 | J_IN_D.3 | J_OUT_D.3 | GPIO |
| S3 | 13 | J_IN_D.4 | J_OUT_D.4 | GPIO |

**Enable (per-board)**
- **EN̄** ← U1.15 · J_EN.2 · (JP1 to GND for standalone)

**Test points:** TP1→SIG, TP2→VCC, TP3→GND.

---

## Analog signal integrity — the finicky bits and their fixes

Analog muxing has a bad reputation but the failure modes are known:

1. **Channel bleed (the #1 surprise):** reading channel N right after N−1 shows a
   ghost of N−1 — the ADC sample cap didn't finish charging through the mux
   (~100 Ω) + source impedance. **Fix in firmware:** wait ~10–30 µs after
   switching (or read-discard-read) before sampling.
2. **Source impedance:** use **10 kΩ linear pots** — high-value pots (100 kΩ)
   settle slowly and pick up more noise.
3. **Reference noise:** ratiometric ⇒ VCC noise = reading noise. Decoupling caps
   earn their keep; keep VCC clean and consistent.
4. **Cable pickup:** wiper + SIG lines are antennas. Keep cables reasonable,
   SIG flanked by GND.
5. **Firmware oversampling:** read each channel 4–16× and average — *the* trick
   for stable, jitter-free bits. Free.
6. **Escape hatch:** an op-amp buffer (voltage follower) on SIG before the ADC
   drops source impedance to ~zero and makes settling/cable issues vanish. Not
   needed now — just know it exists.

**Precision:** 256–512 steps per pot = 8–9 effective bits. Your MCU's 10–12-bit
ADC has headroom. With 10 kΩ pots + settle delay + oversampling + good
decoupling, clean 8–9-bit control is a normal result — even with a full 256
inputs on one shared SIG line. Precision is set by **noise and ADC bits, not
input count.**

---

## PCB layout guidance

- **Size:** keep well under 100 × 100 mm for JLCPCB's cheapest tier.
- **16 JST inputs along the board edges**, right-angle mouths facing outward so
  cables clear the board. Label each `CH0…CH15` on silk with pin-1 markers.
- **U1 central; C1 (100 nF) straight across pins 24/12**, as close as possible;
  C2 (10 µF) nearby.
- **Solid ground pour both layers**, stitched; continuous return under the input
  area. Short, direct WIPER traces. Keep the digital select lines away from SIG.
- **4× M3 holes (H1–H4):** Ø3.2 mm, ≥3 mm from edges and any future V-cut line;
  standardize their spacing to match the other breakout boards.
- **Silk:** board name `MUX16 v1`, J_IN/J_OUT/J_EN pinouts, channel numbers,
  pin-1 markers.

---

## System architecture — chaining, master board, scaling

### Two 4-bit buses
- **S0–S3** = *which channel* inside a mux (0–15). Shared by every mux.
- **M0–M3** = *which mux* is active. Fed to the **master board's `74HC154`**
  (4→16 decoder, active-low outputs), which generates the 16 enable lines. The
  dumb mux boards never see M lines — they just receive their one `EN̄`.

### Master board (separate PCB, build later)
- `74HC154` : inputs `A B C D` ← `M0 M1 M2 M3`; enable inputs `Ē1 Ē2` → GND
  (or one to a GPIO for a global blank); outputs `Y0–Y15` → 16× `S2B-XH-A`
  (`EN̄ + GND`), one to each mux board's J_EN. 100 nF decoupling.
- Connector to the **first mux board's chain-in:** `3-pin (GND/SIG/VCC)` +
  `4-pin (S0–S3)` — identical to a mux chain connector. **M0–M3 do NOT go to the
  chain** (the decoder consumes them).
- Connector to the **dev board:** see pins-to-dev below.

### Pins back to the dev board (fixed, scales by +1 per doubling)
| Inputs | Muxes | Masters | Pins to dev | Breakdown |
|--------|-------|---------|-------------|-----------|
| 16 | 1 | 0 | **7** | S0–3, SIG, VCC, GND |
| 256 | 16 | 1 | **11** | + M0–3 |
| 512 | 32 | 2 | **12** | + M4 (or parallel ADC) |
| 1024 | 64 | 4 | **13** | + M5 |
| 2048 | 128 | 8 | **14** | + M6 |

8 control lines = an 8-bit address = 1-of-256. Grouped for the dev connector:
`3-pin (GND/SIG/VCC) + 4-pin (S0–3) + 4-pin (M0–3)`.

### Scaling past one shared SIG (parallel ADC)
One shared SIG + one ADC is comfortable to **~128–256 inputs**. Beyond that you
hit: scan speed (one ADC sweeping everything), SIG-line capacitance/leakage from
many muxes, and VCC IR-drop corrupting the ratiometric reference on far boards.

**Fix — give each master its own SIG → its own ADC pin.** This needs **no board
change** (each master already has one SIG line); you just don't tie them
together at the dev end. Bonus: masters no longer arbitrate a shared line, so you
**drop the master-select bit (M4) and its inverter**, read all masters in
parallel (≈N× faster), and cut per-line loading. Then distribute power robustly
(thick VCC / star feeds) to protect the reference. At very large scale
(~1000+ inputs), local digitization (smart boards) becomes the better path.

---

## JST-XH `S#B-XH-A` mechanical (right-angle)

- Pitch **2.50 mm**; pin-to-pin span = 2.5 × (n−1); contact posts 0.64 mm sq;
  recommended PCB hole ~1.0 mm.
- 3-pin span 5.0 mm (housing ~9.9 mm); side-entry, cable exits parallel to board.
- KiCad footprints `Connector_JST:JST_XH_S#B-XH-A_1x0#_P2.50mm_Horizontal`
  already encode exact pads/courtyard — confirm against the JST datasheet.

## JLCPCB order (cheapest)

1.6 mm · 2-layer · 1 oz Cu · HASL (leaded) · green mask · no special options.
Order the 5-pcs minimum; buy C157928 and the other XH headers on the same order
to combine shipping. Panelize identical boards with KiKit later (`../README.md`).
