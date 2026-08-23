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
- **Buttons — polarity is frozen in copper, so pick one convention.** The pull
  resistor **must** be on the board (10 kΩ): through a mux, unselected channels
  would otherwise float, and an MCU internal pull-up only sits on the shared ADC
  pin, not per channel. Its *direction* is etched in — pull-**up** (to VCC) idles
  HIGH, press → LOW (active-low); pull-**down** (to GND) is the reverse. You
  can't flip it in firmware, and it must be **uniform across all button boards**
  or firmware needs per-channel logic. **Recommend active-low pull-up** (the
  universal convention). Debounce in firmware.
- **LEDs — common-anode vs common-cathode is also frozen in copper.** It sets
  current direction (common-anode → shared pin to VCC, on = pull the color pin
  LOW/sink; common-cathode → shared pin to GND, on = drive HIGH/source), the
  driver arrangement, *and* your on/off logic — all dictated by the physical LED
  you buy. Pick one type, design for it, label it on the silk. Current-limit
  resistor **on the breakout** so the cable only carries `LED±` + logic-level
  drive; size for 5 V (e.g. ~330 Ω green) so it's safe at both rails. RGB = one
  resistor per color.
- **Encoders:** quadrature needs fast/interrupt reads — **do not** mux these.
  Route straight to GPIO. Include the push-switch pin if the encoder has one.
- **PB86:** treat button and lamp as two independent 2-pin sub-circuits with two
  connectors. Button → Lane A (pull resistor). Lamp → Lane C (resistor).

---

## 5. The central mux board (Lane A) — chainable, ratiometric

- **Chip:** `74HC4067` (16:1 single-ended analog mux, 2–6 V). 16 channels = your
  16 JST ins, 4 address lines (`S0–S3`), enable (`EN̄`/`INH`), one common (`SIG`).
- **16× JST-XH-3 input ports.** Each port = `GND · WIPER/SIG · VCC`. GND and VCC
  rails are shared across all ports (that's what feeds the pot ends / pull-ups).
- **Decoupling:** 100 nF across the 4067's VCC/GND, close to the chip. A bulk
  10 µF on the board is cheap insurance.
- **Grounding:** single solid ground pour; keep the analog return clean. Star or
  at least a continuous pour under the input ports.

### Dual-voltage: take VCC from the dev board (works at 3.3 V *and* 5 V)

**Put no regulator on any board.** Feed VCC in from the dev board and the whole
input system is voltage-agnostic:

- **Analog is ratiometric.** A pot divides its top rail; the ADC measures against
  that *same* rail. Feed the pot HI reference from dev-board VCC → the reading is
  a fraction of full-scale whether that rail is 3.3 or 5 V.
- **Match mux VCC to MCU logic level.** `74HC` thresholds are ratiometric
  (VIH ≈ 0.7·VCC), so a 3.3 V MCU driving a 5 V-powered mux is marginal. Since
  VCC comes *from* the dev board, logic level and mux VCC track automatically —
  no level shifter, no jumper. 3.3 V board → all 3.3; 5 V board → all 5.
- **Only LED resistors are voltage-sensitive** (brightness ∝ V, not ratiometric).
  Size them for 5 V; they run a little dimmer at 3.3 V. That's the one exception.

### Dev-board interface & chaining: **8 pins for one mux, +1 per mux**

Every line except the enable is a shared bus, so extra muxes are nearly free:

| Line | Count | Shared across muxes? |
|------|-------|----------------------|
| `S0 S1 S2 S3` (address) | 4 | **Yes** — one bus to all muxes |
| `SIG` (common analog out) | 1 | **Yes** — outputs wire-OR onto **one** ADC pin |
| `VCC`, `GND` | 2 | **Yes** |
| `EN̄` (enable) | 1 | **No** — one GPIO per mux |

One mux = 4+1+2+1 = **8 pins**. Add a mux → it shares address/SIG/power and you
enable one at a time via its own `EN̄` → **+1 GPIO per mux**. A disabled 4067's
common goes high-Z, so tying all `SIG`s together is safe, and **only one ADC pin
is ever used** — that's what makes it fit any dev board (ADC pins are the scarce
resource; many boards have only 1–4).

- Give each board a **chain-in and chain-out** connector carrying the 7 shared
  lines `{S0..S3, SIG, VCC, GND}` as a pass-through bus, plus its own `EN̄`
  broken out. Daisy-chain the bus; run one `EN̄` wire from each board to a GPIO.
- **Settling gotcha:** the 4067's on-resistance (~70–200 Ω) + ADC sample-and-hold
  means you must **wait a few µs after switching address/enable** before
  sampling. The wiper series-R (small) + filter cap keep source impedance low.

### How many can you chain? (the "hard limit")

- **Simple mode (one EN̄ GPIO per mux):** limited by **spare GPIO** →
  realistically **8–16 muxes = 128–256 inputs**. Electrical ceilings sit higher:
  leakage + capacitance of disabled outputs on the shared `SIG` slowly grow
  settling time (fine to dozens), and the address bus wants a buffer past
  ~20–30 loads. There's also a *time* limit — a few µs settle × N channels;
  256 ch ≈ ~1 ms/scan (~1 kHz update), still plenty; thousands get sluggish.
- **Scale mode (out of GPIO):** decode the `EN̄`s from *extra address lines* with
  a `74HC138`/`74HC154` instead of one GPIO each. Muxes then cost address *bits*,
  not pins — 4 mux-select lines → 16 muxes → **256 inputs on ~11 dev pins**. Run
  the decode lines through the chain connector so boards stay identical. This is
  the "as many as you'll ever need" path.

So there's no real chip-count ceiling: the limit is GPIO (simple mode) or your
required scan rate (scale mode). Design the connector for simple mode now, leave
footprints/lines for the decoder later.

Outputs/LEDs are a **separate** small board (e.g. `74HC595` → resistors →
JST-XH-2 lamp ports) — they can't ride an input mux.

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

Voltage is **solved** — VCC comes from the dev board, so the input system runs
at 3.3 V *and* 5 V unchanged (§5). Input count is **solved** — the mux board is
chainable (§5). What's left:

1. **Button polarity** — active-low pull-up (recommended) vs active-high
   pull-down. Frozen in copper; pick once, apply to every button board.
2. **RGB common** — common-anode or common-cathode. Frozen in copper; dictated
   by the LED you buy.
3. **MCU / dev board** you'll read this with (RP2040 / Teensy / STM32 / AVR) —
   mainly affects how many EN̄ GPIOs you have, i.e. simple vs scale chaining.
4. **LED brightness control** — simple on/off (GPIO / `74HC595`) or PWM/dimming
   (changes the driver choice).
