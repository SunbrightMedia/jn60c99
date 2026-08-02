# Engine B — VOICE PATH BUDGET

Date 2026-08-02. Target: ESP32-S3, one core, 240 MHz, 48 kHz, **3,500 cyc/sample
for the whole engine**, 8 voices.

Every number below is copied from the module's own measurement run. Nothing here
is estimated except where the row says ESTIMATE, and every estimate carries a
band. Costs are `tools/engineb/cost.py` S3 nominal at 8 voices (MODELED from a
MEASURED host instruction density plus the S3 static instruction count); the
bracketed pair is that tool's band. Accuracy is `tools/engineb/null_b.py` over
its 30 scenarios (17 with an idle prefix).

---

## 1. Modules written

| module | src range | accuracy (MEASURED) | S3 cyc/sample (MODELED) | band |
|---|---|---|---|---|
| ENV1+ENV2 ADSR (`eb_envgen.c`) | 964-1075 | bit-exact | **1,188** | measured, 81 instr |
| DCO oscillator (`eb_dco.c`) | 1718-2136 | null 30/30 **EXACTLY 0**; wrap bit-identical over all 2^32 float32 patterns | **17,413** | 10,329 .. 32,811 |
| VCF ladder core (`eb_vcf_ladder.c`) | 1298-1515 | null 30/30 **EXACTLY 0**; `eb_wrap24` bit-identical over all 2^32 | **4,273** | 2,633 .. 11,566 |
| VCA + HPF out (`eb_vca_hpf.c`) | 1516-1640 | null 30/30 **EXACTLY 0** | **1,543** | 958 .. 4,106 |
| VCF cutoff CV (`eb_vcf_cv.c`) | 1150-1229 | null 30/30 **EXACTLY 0** | **686** | 418 .. 1,855 |
| pitch/PWM mod CV (`eb_pwm_cv.c`) | 1076-1128 | null 30/30 **EXACTLY 0** | **474** (tick) | 295 .. 1,263 |
| — same, block form | | bit-identical to tick over 16,000,000 random comparisons, 0 mismatches | 73 .. 581 | not yet gated as the shipped shape |

Not one shipped module takes an approximation. The standard actually met is
bit-equality, which is stronger than the -100 dB standard. **The accuracy work is
done and it is not the problem.**

## 2. Running total

Written so far, S3 nominal, tick shapes as shipped:

```
1,188  envelopes
17,413  DCO
 4,273  VCF ladder
 1,543  VCA + HPF
   686  VCF cutoff CV
   474  mod CV
------
25,577 cyc/sample   =  731 % of the 3,500 budget
```

Optimistic end of every band summed: 15,821 (452 %). Pessimistic: 52,789.
With the mod-CV block form at its low end instead of the tick: 25,176.

The envelopes were quoted at 34 % of budget. They are now **4.6 %** of what has
been written.

## 3. Unwritten voice path — ESTIMATE

| block | src | ESTIMATE S3 cyc/sample | band | basis |
|---|---|---|---|---|
| polyphase decimator, 26-tap FIR + correction biquad | 2137-2172 | 1,400 | 700 .. 3,500 | STATIC op count × the measured DCO density; runs once per sample per voice, not per sub-sample |
| noise SVF (LFSR itself DONE) | 1129-1149 | 400 | 200 .. 1,200 | STATIC; two-integrator loop, 8 voices |
| CV/gate conditioning | 654-693 | 300 | 100 .. 800 | STATIC; smoothers + gates, and the **worst-gated range in the engine (4/13 observable)** — the estimate is the cheap part, the risk is that it cannot be validated |
| voice summing / master feed | — | 150 | 80 .. 400 | STATIC |
| **subtotal unwritten** | | **~2,250** | 1,080 .. 5,900 | |

Voice path projected total: **~27,800 cyc/sample** (band 16,900 .. 58,700).

## 4. The blunt answer

**No. Not close, and not by a margin that any implementation work closes.**

The voice path alone is **~27,800 against 3,500 — 7.9× over, a shortfall of
~24,300 cyc/sample.** The FX are measured by a parallel workflow and are
additional; at 0 cost for the FX the answer is still no.

At 240 MHz / 48 kHz the machine has 5,000 cycles per sample of wall clock in
total, so the engine as written cannot run even if it were the only code on the
chip.

The cost is structural, not sloppy. Three exact optimisations were already found
and taken (DCO clamp-constant hoist −45 %, VCF CV recall hoisting −29 %, mod CV
block hoist), and the residue is arithmetic that must happen:

- The DCO is 78 % of everything written, and its driver is **4× oversampling**:
  32 invocations per sample, each with three saturators (a sin Taylor series),
  three triangles and a divide.
- The VCF ladder is 4× oversampled for the same reason: MEASURED-STATIC 1,872
  float-arithmetic instructions per sample before any memory access.

Options, in the user's stated priority order — everything before voice count:

1. **Lower the oversampling ratio (the only lever big enough).** 4× → 2× halves
   the two dominant modules, ~10,800 cyc/sample off. It is a design task, not a
   flag: the 4× rate feeds the 26-tap polyphase FIR and `G` is derived for it
   (`[7856] = π·440/(4H)`), so the cutoff law and the decimator must be
   re-derived and the resulting error MEASURED before it can be accepted. **Its
   error is not measured and must not be guessed.** Even at 2× the total is
   ~17,000 — still 4.9× over. This is necessary and not sufficient.
2. **A faster or dual-core target.** Two S3 cores at 240 MHz = 7,000
   cyc/sample; still 4× short. The measured Daisy M7 numbers are of the same
   order. On current arithmetic no single-chip MCU in this class is within 3×.
3. **Table/approximation trades inside the DCO** (the sin-series saturator, the
   triangle). Each needs its own measured error budget; none has one, and the
   already-measured cheap ones are small: `EB_DCO_RECIP` buys 400..2,880 on the
   S3 at -121.1 dB worst global; the VCF's zero-tap removal buys 311 (7.3 %) at
   EXACTLY 0.
4. **6 voices — last resort, and it buys about 5 % here, not 25 %.** Cost in
   these modules is close to linear in voices (unlike the Daisy full-engine
   measurement, where the 91 % idle floor made polyphony no lever at all), so
   8→6 removes ~25 % of the voice path — ~6,900 cyc/sample — and still leaves
   ~20,900. It does not turn a no into a yes on its own and should not be spent
   first.

The honest reading: **no combination of the measured levers reaches 3,500.**
Options 1+2+4 together are ~6,400 against a 7,000 two-core budget with the FX
unpaid. That is a scoping decision for the user, and it should be taken now
rather than after another module is written.

## 5. Every place a module missed -100 dB

**No shipped module missed it.** All six null at EXACTLY 0. The list below is
every measured error near or below the gate — variants NOT shipped, plus the two
places the gate is known to be blind. They are recorded because they are the
error budget anyone will be tempted to spend.

| where | measured | cause | status |
|---|---|---|---|
| VCF ladder, saturation regrouped `x*(1+K*x⁴)` | **-130.5 dB** worst global | float regrouping; algebraically identical | PASSES the gate. Not taken; verbatim order shipped. |
| VCF ladder, FIR summed outward-to-centre | **-120.9 dB** | summation order | PASSES. Not taken. |
| VCF CV, smoother regrouping `(in-s)*rate+s → in*rate+s*(1-rate)` | **-127.2 dB** global, **-117.7 dB** worst block, 14/30 scenarios move | float regrouping | PASSES. Not taken. This module is **not protected by the gate against that class**. |
| DCO, `EB_DCO_RECIP=1` (divide → reciprocal multiply) | **-121.1 dB** global, **-115.2 dB** block | reciprocal approximation | PASSES; OFF by default; buys 400..2,880 cyc on S3. |
| gate calibration reference | `×(1+2⁻²³)` = -128.7 dB PASS; `×1.00003` = -90.4 dB FAIL | — | the gate's teeth: ~2 ULP passes, 3e-5 fails |

Two blind spots, MEASURED, not inferred:

- **mod CV (1076-1128): 9 of 21 coefficients are unreachable by all 30
  scenarios** — the [3744] arm, the bend term, env→pitch and env1/env2→PWM are
  all identically 0 in every scenario. Two algebraically identical regroupings
  planted on those paths passed at EXACTLY 0. Those lines are transcribed
  verbatim and must not be simplified until scenarios reach them.
- **CV/gate conditioning (654-693): 4/13 observable, the worst-gated range in the
  engine, and it is unwritten.** It should not be rewritten behind that gate.

Rejected variants that FAILED, for the record (these are not error budget, they
are proof the gate has teeth): VCF CV at 1/8 rate -23.1 dB global / -6.3 dB block
(29/30 fail — that path is audio-rate, and `docs/trackb/VCF.md` is wrong to
present it as control-rate); VCA control half at 1/16 rate **+3.9 dB, the error
louder than the signal**; DCO wrap "obvious" simplification -62.1 dB, 15/30.

## 6. Corrections owed to the blueprints

- `docs/trackb/VCF.md` — **wrong**: the cutoff-CV path is not control-rate.
  MEASURED, 29/30 fail at 1/8 rate.
- `docs/trackb/MOD.md` §3.9 — **wrong label**: [3744] is not a "mod-wheel term";
  it is the undelayed LFO through the common LFO gain. The formulas are correct.
- `docs/trackb/DCO.md` §1.1 — **wrong classification**: 4640 (phase) and 4672
  (sub counter) are filed SCRATCH and are the module's entire persistent state.
  4896 is filed a dead tap; the cell is dead but its value is read at :2132.
- `docs/trackb/VCF.md` (ladder) and `docs/trackb/CELLMAP.md` §§V..AB —
  **correct**, including both traps CELLMAP flags. No correction owed.
- CELLMAP's "3× oversampling" is wrong; 4× confirmed by execution.

## 7. Owed record-keeping

`docs/trackb/EQUIVALENCE.tsv` has no row for M-VCA: a parallel workflow held
uncommitted edits to `tools/engineb/ledger.py` and committing would have swept
their work. That row is still owed.
