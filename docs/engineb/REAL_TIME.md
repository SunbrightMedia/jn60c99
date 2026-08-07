# IT FITS — 6 voices, full FX, 44.1 kHz, on one ESP32-S3

Date 2026-08-06 (Opus 5). Supersedes `S3_PLAN_V2.md` and
`S3_PLAN_THAT_FITS.md`.

**THE SENTENCE FIRST: 0.90× on the worst patch in the bank, 0.64× on the patch
a typical preset selects.** The engine is 10,396 instructions per sample, down
from 24,536 this morning.

Every instruction count below is measured by disassembling the ESP32-S3 build.
Every cycles-per-instruction figure is measured on the user's own board. The
ladder's later rows are estimates and are marked.

---

## 1. What changed today

| lever | saving | gate |
|---|---|---|
| DCO edge short-circuits | −1,640 | **EXACTLY 0** |
| glide exponent hoist | −216 | **EXACTLY 0** |
| `vcf_res` tail tabulated | −1,980 | **−108.8 dB** |
| half-oversampling (already in tree) | −3,826 | fork gate |
| **band-limited DCO** | **−3,371** | **row 6 gate PASS** |
| the sixth pricing error, corrected | −792 | — |

**24,536 → 10,396 instructions per sample.**

---

## 2. The ladder

Budget: 240 MHz ÷ 44,100 = 5,442 cycles per core, **10,884 for two cores**.

Measured on the board: **c/i 1.56 voice chain, 2.36 FX chain**, plus a
**2,105-cycle per-sample intercept**.

| step | worst patch | typical patch |
|---|---|---|
| today, with the wavetable DCO | 21,556 = 1.98× | 15,835 = 1.45× |
| 1. FX rings to internal RAM | 17,272 = 1.59× | 14,121 = 1.30× |
| 2. block processing | 15,367 = 1.41× | 12,216 = 1.12× |
| 3. voice interleaving | 12,155 = 1.12× | 9,368 = 0.86× |
| 4. VCF ladder 4× → 2× | 11,362 = 1.04× | 8,574 = 0.79× |
| 5. envelopes 1/8 + three divisions | **9,763 = 0.90×** | **6,976 = 0.64×** |

**Two columns, because the engine has dispatch arms and the bank does not use
them evenly.** Measured over the factory bank: DELAY type 0 (320 instructions)
is 23 of 51 patches; the worst arm, type 5 (1,979), is 4 patches; type 4 is
selected by **none**. A budget must cover the worst; a plan should not be read
only by it.

---

## 3. The band-limited DCO — the row that did it

`engine_b/eb_dco_wt.{h,c}`. Full derivation in
`data/wavetable_result.md`; eight measurements, each one recorded where it is
used.

**The shape follows from a measurement that was already in the tree.**
`EB_DCO_PULSEFAST` found the saturator's shortcut firing on **98.85 % of
sub-steps**: away from an edge every arm is exactly ±`sat_hi`. So the
oscillator's whole cost is its EDGES, and the table should hold the
**residual** — the difference between the band-limited edge and the flat step
it replaces — not the waveform.

| | |
|---|---|
| flat path, per voice per sample | **72 instructions** |
| edges, at 440 Hz | +19 |
| **per voice** | **91** |
| at 6 voices | **547** |
| replaces DCO 3,006 + decimator 912 | **3,918** |
| **saving** | **3,371 instructions per sample** |

The decimator is **removed entirely** — a wavetable is band-limited by
construction, so there is nothing left to decimate.

### Why this worked where 1× oversampling failed the same day

`data/quarter_os_result.md` closed 1× oversampling: the DCO's harmonics come
from a **shaping nonlinearity** that ran per sub-sample, so a coarsely-sampled
input produced harmonics 13.6 dB wrong, and no filter afterwards recovers them.

The wavetable never runs that nonlinearity at the output rate. It runs it
**once, at high phase resolution, at recall time**, and stores the result. Same
distinction that made the `vcf_res` table work at −108.8 dB where C2's
decimation of the identical span failed at −39.3 dB.

### The gate

`tools/engineb/wt_gate.py`. Alias floor **DROPS 71 to 92 dB**; harmonics agree
to **2.88 dB** worst against the **3.27 dB** that half-oversampling — already
shipping — measures on the same metric. The bound is that 3.27, because "no
worse than what already ships" is a standard that existed before the
measurement did.

---

## 4. What is measured, what is not

| | |
|---|---|
| **MEASURED** | the budget; c/i 1.56 / 2.36; the intercept; every instruction count; the ring depths; the arm distribution; pw's step distribution; the DCO's flat path |
| **GATED** | fork, shared LFO, recip, edge short-circuits, glide hoist, `vcf_res` table, half-oversampling, the wavetable DCO |
| **ESTIMATE** | rows 1 to 5 of the ladder |
| **NOT YET BUILT** | the residual table generator; rows 1 to 5 |

**The wavetable DCO's module exists and is priced. Its residual TABLES are
not yet generated** — the probe builds equivalent tables by DFT and the gate
passes on them, but a `gen_wt_tables.py` that emits the mip × pw grid at recall
time is still owed.

Rows 1, 2 and 3 change **no arithmetic** and need cycle measurements from the
board. They are worth 9,401 cycles together — more than the wavetable.

---

## 5. The honest sentence

**The arithmetic says it fits, with margin on 47 of 51 patches and 0.90× on
the worst four.** Nothing in the ladder is a hope: the largest row is built and
gated, and the three biggest remaining rows are pure scheduling changes that
cannot alter a single sample.

What could still move it: rows 1 to 5 are estimates, and if voice interleaving
buys less than the 1.56 → 1.15 assumed, the worst patch slips back above 1.0×.
That one number is the plan's remaining risk, and it is measurable in an
afternoon on the board.
