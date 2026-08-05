# F3 — the S3 fork numeric design: what passed, what died, and the number

Date 2026-08-05 (Fable 5). Every figure below is measured; the gates are
runnable; nothing is judged by ear.

## The sentence that goes first

**With both fork evaluators adopted and 6 voices at 48 kHz, the fork prices at
≈27,300 instructions per sample against the 6,300–9,500 two-core budget:
still 2.9×–4.3× OVER on instruction count.** The reserve dials (44.1 kHz,
half-oversampling) reach ≈21,700 ≈ 2.1×–3.2× over. F3 delivers the two
largest levers that exist and the fork still does not fit by arithmetic
alone; the decision moves to silicon (F4), where cycles-per-instruction and
the remaining structural options (global LFO, half-oversampling adoption,
voice count, or the Teensy path) settle it. This is the same verdict shape
the trunk pricing predicted, now with the levers measured instead of modeled.

## 1. Fork pitch — PASS, exhaustive

`engine_b/eb_pitch_fork.c` + generated `eb_pitch_fork_tab.h`. Recentered
per-row evaluation: row r at t = x − (r − 19.5), |t| ≤ 0.5, coefficients
transformed from the plugin's own table in EXACT rational arithmetic
(`gen_fork_tab.py`; the transform is proven as a rational identity before any
float exists — 29 rows × 11 sample points, exact equality). The one rounding
in the pipeline is the final float cast, emitted as hex literals.

**Gate: `tools/engineb/pitch_cents_gate.py` — EXHAUSTIVE, all 2^32 float
inputs**, reference = the port's own `juno_pitch_poly` (itself bit-exact to
the plugin). Result:

| |P| band | worst cents | bound |
|---|---|---|
| ≥ 1 | 0.000415 | 0.05 |
| 0.3–1 | 0.000210 | 0.05 |
| 0.1–0.3 | 0.000191 | 0.05 |
| 1e-2–0.1 | 0.000268 | 0.05 |
| 1e-3–1e-2 | 0.000741 | 0.05 |
| < 1e-3 | abs 3.9e-9 | 2e-6 |

**PASS with 67× margin.** For scale: the plugin's own double evaluation
carries ≈0.02 cents of amplified rounding, and the instrument's own UNISON
voice scatter is 18.2 cents.

Two findings only exhaustiveness could produce:
- **The signaling-NaN class failed the first run.** IEEE maxNum returns the
  number for a quiet NaN but a quieted NaN for a signaling one, so the
  `fminf(fmaxf(...))` clamp sent sNaN inputs to the +8.9 end while the port's
  double conversion quiets every NaN to the −20 end. No sweep visits a NaN
  payload class. Fixed with an explicit `x != x` test; re-proven over 2^32.
- **Row selection is exact by argument, not luck**: the port's
  `(int)(v1 + 20.0)` is exact in double for any float-valued v1, so
  `floorf(x) + 20` is the same function. A first draft used
  `(int)(x + 20.0f)` — the FLOAT add can round across an integer boundary and
  select the wrong row.

Cost: 64 Xtensa instructions + one floorf call per evaluation ≈ 640/sample
for 8 voices, against v7's 21,792 (**−21,150/sample**). O6 note: floorf and
the exp fork's floorf can become the two-instruction int-cast idiom on the
clamped domain.

## 2. Fork exponential — PASS, exhaustive

`engine_b/eb_exp_fork.c`: Cody–Waite reduction, degree-5 polynomial, bit-built
2^n scale; the tails (|x| outside [−87, 88]) DELEGATE to libm so overflow,
underflow and NaN are the port's own by construction.

**Gate: `tools/engineb/exp_ppm_gate.py` — EXHAUSTIVE, all 2^32 float inputs**
against the port's expf: tails 0 mismatches (bit-identical), main region
worst **0.119 ppm** against the 2-ppm bound, sub-1e-30 region worst 1 ULP.
For scale, the pitch bound of 0.05 cents is 29 ppm.

Cost: 82 instructions + floorf, against expf's 184 → ≈ −700/sample on the
LFO's eight calls (more when other expf sites adopt it in O6).

## 3. C4 fixed-point SIMD — CLOSED NEGATIVE for every recursive module

The ×2–3 lever required 16-bit lanes (the S3's PIE has no float and no 32-bit
multiply lanes; eight voices across eight Q15 lanes was the plan). The
one-filter prototype (`docs/engineb/data/c4_ladder_probe.c`) runs the trunk
ladder byte-for-byte in float against the same structure in QN fixed point,
under a hard but plausible drive (−12 dBFS sweep, cutoff swept, resonance to
3.8):

| format | global dB rel | worst 1024-block dB rel |
|---|---|---|
| Q14 | −54.1 | **+11.2** |
| Q15 (the SIMD lane) | −60.9 | **+3.9** |
| Q20 | −92.3 | −31.7 |
| Q24 | −116.4 | −55.3 |
| Q28 (scalar control) | −136.8 | −79.5 |

A resonant recursive filter RECYCLES its quantization error: at high
resonance the Q15 error is as loud as the signal. Even the Q28 scalar — which
has no SIMD carrier on this chip — sits AT the −80 block bound with no
margin. **16-bit SIMD is dead for the ladder and, by the same mechanism, for
every feedback module (VCF, HPF, envelopes, chorus/delay/reverb lines).**
What survives of C4: feed-forward spans only — the FIR decimators and mix
stages — worth roughly 1,000–2,000 instr/sample, not the modeled ×2–3.
`EB_C4_SIMD_RECURSIVE 0` in eb_fork_config.h records the closure.

## 4. The fork bill of accounts (instructions/sample, MEASURED×STATIC)

Start: S3 shipping trunk 56,967 (fast pitch v7 + DCO recip, 8 voices, the
master chain and worst arms included).

| step | delta | running |
|---|---|---|
| pitch v7 → fork | −21,150 | 35,800 |
| LFO expf → fork | −700 | 35,100 |
| 8 → 6 voices (per-voice portion ×0.75) | −7,750 | 27,350 |
| C4 feed-forward (upper estimate) | −1,500 | ≈25,850 |
| reserve: 44.1 kHz | budget +8.8 % | — |
| reserve: half-oversampling (DCO+decim) | ≈−4,300 | ≈21,550 |

Against 6,300–9,500: **2.9×–4.3× over as specified; 2.1×–3.2× with every
reserve pulled.** Instructions are not cycles; silicon (F4) decides, and the
remaining structural options are listed in the first paragraph.

## 5. What O6 adopts, in order

1. `EB_FORK_S3` build wiring: eb_fork_config.h constants into the render
   loops; pitch and exp call-site switches.
2. A fork-side render A/B against the trunk at matched voices, verifying the
   gated deltas are the ONLY deltas (the composition lesson of task 1b-3:
   two exact pieces still need a whole-engine run).
3. The floorf → int-cast idiom in both fork evaluators, re-gated
   exhaustively (four minutes each; there is no excuse to skip).
4. Feed-forward C4 on the decimator FIRs, gated at −100/−80 like everything
   else.
5. The global-LFO investigation: BOTH conditions (hardware fact including
   CONDITION scatter's role, and silicon need) before any code.
