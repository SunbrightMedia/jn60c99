# Control-Surface Interconnect System

A cheap, semi-universal set of small breakout PCBs for control-surface parts
(pots, faders, buttons, LEDs, encoders…) plus a central board that muxes them
all down to a small number of wires going to a microcontroller.

Design goals, in order: **cheap**, **modular** (any part → standard cable →
central board), **hand-solderable**, **panel-friendly** (many small boards per
JLCPCB order).

---

## 1. The one decision that shapes everything: analog in / digital in / LED out

"Connect them all together through an analog mux" only cleanly covers **analog
and slow-digital INPUTS**. It does *not* cover LEDs (outputs) or fast digital
(encoders). Split the system into three lanes and the whole thing gets simple:

| Lane | Parts | Path to MCU | Central board |
|------|-------|-------------|---------------|
| **A. Analog/slow-digital in** | pots, faders, buttons* | 16 JST → **74HC4067** 16:1 analog mux → 1 ADC pin | the mux board you described |
| **B. Fast digital in** | rotary encoders (quadrature) | direct to GPIO / interrupt pins | *not* through the mux |
| **C. Outputs** | LEDs, RGB LEDs, PB86 lamp | current-limit resistor on the breakout → GPIO or a `74HC595` driver board | a separate (optional) output board |

\* **Buttons can ride the analog mux.** The ADC just reads ~0 V or ~VCC and you
threshold it in firmware. This is what makes the system feel "universal": every
Lane-A input is just "a channel," whether it's a continuous pot or an on/off
button. The only requirement is the line must have a *defined level* — so the
button breakout carries its own pull resistor (see §4).

**Consequence:** the "16-in mux board" is an **input** board. LEDs are a
parallel system. The PB86 (button + lamp) straddles both lanes — its button pins
go to a Lane-A cable, its lamp pins go to a Lane-C cable. That's why it needs
more than one connector.

---

## 2. Connector & pinout standard (the actual "interconnect")

The value of this project is the *standard*, not any single board. Lock these
down first and every board just conforms.

- **Connector:** JST-XH, 2.5 mm pitch, through-hole. Good balance of
  cheap/available/reliable and easy to hand-crimp. Buy housings + crimps + the
  matching board headers in bulk from LCSC in the *same* JLC order (combined
  shipping).
- **Pin 1 is always the same reference.** Pick a rule and never break it:
  - **Pin 1 = GND / LO reference** (silkscreen a square pad + a `▉` mark).
  - Last pin = VCC / HI reference where a part needs it.
  - Middle pin(s) = the signal(s).

### Canonical pinouts

| Board | Pins | JST | Pin order (1 → N) |
|-------|------|-----|-------------------|
| Pot / fader (Lane A) | 3 | XH-3 | `GND(LO)` · `WIPER` · `VCC(HI)` |
| Button (Lane A) | 2 | XH-2 | `GND` · `SIG` (pull resistor on-board) |
| LED (Lane C) | 2 | XH-2 | `LED−` · `LED+` (resistor on-board) |
| RGB LED (Lane C) | 4 | XH-4 | `COM` · `R` · `G` · `B` (3 resistors on-board) |
| Encoder (Lane B) | 4 (or 5) | XH-4/5 | `GND` · `A` · `B` · `SW` (+`VCC` if needed) |
| PB86 (button+lamp) | 2 + 2 | two XH-2 | button cable + lamp cable, kept separate |

> Keep pin *order* consistent even when pin *count* differs, so a person
> crimping cables never has to think about which end is ground.

---

## 3. What every breakout board should include

1. The **part footprint** (from the *real* part's datasheet — see §7).
2. The **JST-XH header** with the standard pinout.
3. **2× M3 clearance holes** — Ø **3.2 mm** finished, NPTH is fine. Standardize
   their position/spacing relative to the part so mounting is predictable across
   the family. Keep them ≥ 3 mm from board edges and any panel V-cut line.
4. **Silkscreen:** board name + version (e.g. `POT-3 v1`), pin-1 marker, and a
   one-word label per pin. Future-you will thank present-you.
5. Board outline as small as the part + connector + mounting allow — smaller =
   more per panel = cheaper.

---

## 4. Per-board notes worth designing in

- **Pots/faders:** add a footprint for a **wiper-to-GND filter cap** (place for
  10–100 nF, leave DNP if unused). It knocks down noise/aliasing at the ADC for
  ~2 ¢. Optionally a **series resistor** (100 Ω–1 kΩ) in the wiper line to
  protect the ADC and help mux settling. Tie the two pot ends to HI/LO
  references, wiper to the WIPER pin.
- **Buttons:** put the **pull resistor on the board** (10 kΩ). Decide pull-up
  (to VCC, active-low) vs pull-down (to GND, active-high) *once* for the whole
  system. With a pull-up, `SIG` idles high and the button pulls it to GND — the
  mux/ADC reads it fine. Optional RC or just firmware debounce.
- **LEDs:** current-limit resistor **on the breakout** so the cable only carries
  `LED+`/`LED−` and logic-level drive. Size for your LED + drive voltage
  (e.g. ~330 Ω @ 5 V for a standard green). RGB = one resistor per color; note
  common-anode vs common-cathode on the silkscreen.
- **Encoders:** quadrature needs fast/interrupt reads — **do not** mux these.
  Route straight to GPIO. Include the push-switch pin if the encoder has one.
- **PB86:** treat button and lamp as two independent 2-pin sub-circuits with two
  connectors. Button → Lane A (pull resistor). Lamp → Lane C (resistor).

---

## 5. The central mux board (Lane A)

- **Chip:** `74HC4067` (16:1 single-ended analog mux). 16 channels = your 16 JST
  ins, 4 address lines (`S0–S3`) + `EN̄` + one common (`SIG`) out.
- **16× JST-XH-3 input ports.** Each port = `GND · WIPER/SIG · VCC`. GND and VCC
  rails are shared across all ports (that's what feeds the pot ends / pull-ups).
- **Out headers:** break out `SIG` (to MCU ADC), `S0–S3`, `EN̄`, `VCC`, `GND` to
  a 0.1″ header so any dev board (RP2040 / Teensy / STM32 / Arduino) can drive
  it. Optionally a second 4067 footprint for 32 channels later.
- **Decoupling:** 100 nF across the 4067's VCC/GND, close to the chip. A bulk
  10 µF on the board is cheap insurance.
- **Firmware gotcha to design around:** the 4067's on-resistance (~70–200 Ω)
  plus the ADC sample-and-hold means you must **wait a few µs after switching
  the address** before sampling. Lower source impedance (the wiper series-R
  small, the filter cap helping) and a settle delay fix it.
- **Grounding:** single solid ground pour; keep the analog return clean. Star or
  at least a continuous pour under the input ports.

Outputs/LEDs would be a **separate** small board (e.g. `74HC595` → resistors →
JST-XH-2 lamp ports) if you want the same connectorized approach for LEDs.

---

## 6. Panelization & keeping it cheap (JLCPCB)

- Stay **≤ 100 × 100 mm** per panel to hit the cheapest 5-pcs tier.
- **1.6 mm, 1 oz copper, HASL (leaded is cheapest), green mask, no special
  options.** No ENIG needed — nothing here is fine-pitch.
- **Tile identical boards** into a panel with **V-cuts** (straight edges) or
  mouse-bites (irregular outlines). Use **KiKit** (or KiCad's built-in panelize)
  to generate the panel. A 4×2 = 8-up fader panel is a good unit; order the
  5-pcs minimum → 40 faders for a few dollars.
- Different board *types* on one panel can bump you out of the cheap tier or get
  flagged as "panelized by customer" — safest cheap path is **one board type per
  panel**, several panel orders. Combine everything (all panels + JST parts) into
  one shipment.
- Leave V-cut clearance: keep copper/silk ~0.5 mm off the cut line and mounting
  holes well clear of it.

---

## 7. How to actually approach it (build order)

1. **Pick real parts first.** "Semi-universal" still needs exact footprints.
   Choose specific LCSC part numbers for: the pot, the fader (e.g. an ALPS
   RSA0N-style 60 mm), the button, the PB86, the LED/RGB, the encoder. Pull each
   datasheet's mechanical drawing.
2. **Build a shared KiCad library** with: the standardized JST-XH symbols/
   footprints, and a reusable "M3 mount + pin-1 marker" fragment. One source of
   truth for the standard.
3. **Do the connector/pinout spec (§2) as a one-pager** and freeze it.
4. **Design the simplest board first — the button breakout** (2-pin, one
   resistor). It validates your standard, your mounting-hole jig, your
   silkscreen conventions, and your panelization end-to-end for ~nothing.
5. Then pot → LED → RGB → encoder → PB86, reusing the library each time.
6. **Design the mux board last**, once the input pinout is proven by real cables.
7. Order **one panel of the button board + a handful of JST parts** as a cheap
   test run *before* committing to a big multi-board order. Verify fit, crimp,
   mounting, and mux read on the bench, then scale.

### Suggested repo layout

```
pcb/
├── README.md                 (this file — the spec)
├── lib/                      shared KiCad symbols + footprints (the standard)
├── breakouts/
│   ├── button/               one KiCad project per board type
│   ├── pot/
│   ├── fader/
│   ├── led/
│   ├── rgb-led/
│   └── encoder/
├── mux-board/                the 74HC4067 input board
├── panels/                   KiKit panelization scripts/output
└── bom/                      chosen LCSC part numbers + datasheets
```

---

## 8. Open decisions (answer these and the design falls out)

1. **System voltage:** 3.3 V or 5 V? (Sets pull/LED resistor values and MCU
   choice.) The 74HC4067 runs at either.
2. **MCU / dev board** you'll read this with (RP2040? Teensy? STM32? bare AVR?).
3. **Button polarity:** pull-up/active-low vs pull-down/active-high (pick once).
4. **RGB common:** common-anode or common-cathode LEDs?
5. **How many total inputs** in the finished surface? (>16 → plan the 2nd 4067
   or a 4067 + 4051 mix now.)
6. **LED count / brightness control:** simple on/off (GPIO/595) or PWM/dimming
   (changes the driver choice)?
