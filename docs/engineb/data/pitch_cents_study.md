# The pitch relaxation question, measured in cents — the decision data

Date 2026-08-04 (Fable 5). The user asked whether a cheaper pitch with a
relaxed standard is acceptable. This page holds the measurements the decision
needs. Nothing here was judged by ear; every figure is computed.

## 1. The instrument's own detune yardstick

The plugin detunes its own voices on purpose. UNISON patch 61, all eight
voices on MIDI note 60, per-voice DCO increment (cell 4784) read from the
running engine:

    -2.23  +0.00  -6.67  +7.31  -10.87  +4.19  -6.54  +0.99   cents vs median
    peak-to-peak spread: 18.2 CENTS

That is the shipped character of the instrument. It is the scale against
which any pitch deviation must be compared.

## 2. NAIVE plain-float pitch is DEAD — it is not a detune, it is broken

Worst error of the float structural mimicry vs the exact double evaluation,
swept at 1e-5 steps over the whole clamp range, by output band:

| |P| band | worst error |
|---|---|
| 0.3 – 1.0 (mid notes) | **128.5 cents** |
| 0.1 – 0.3 | 466.4 cents |
| > 1.0 (high notes) | **3,183 cents ≈ 2.7 octaves** |
| 1e-2 – 0.1 | 2,977 cents |
| real pluck-POLY trajectory, worst | 31.2 cents |

The 2^37 cancellation of the port's own sum structure, carried in 24-bit
float, produces value spikes that are octaves wrong at specific CVs. The
"maybe it is just a tiny detune" hypothesis is measured false. Anyone
tempted by plain float again starts here.

## 3. The one live candidate: RECENTERED float, with a cents gate

P2 §2 killed recentered evaluation under the −100 dB NULL because it
computes the TRUE function while the port's double output carries its own
amplified rounding (up to 2^-53 × 2^37 ≈ 1e-5 relative ≈ 0.017 cents) — the
null sees the difference, integrates it in phase, and fails.

Under a CENTS standard that same property reads the other way: a recentered
per-row float polynomial tracks the true function to ~0.001 cents
(well-conditioned, few ULP), and therefore differs from the PLUGIN by at most
the plugin's own numerical noise — bounded ≈ 0.02 cents, about **1,000×
smaller than the instrument's own 18-cent voice scatter**. Cost: a plain
float Horner, ~800 instr/sample for all 8 voices, against v7's 21,792.

The gate for it is objective and exhaustive, no ear involved: sweep every
representable CV region, bound |1200·log2(P_new/P_plugin)| ≤ 0.05 cents;
everything downstream of pitch stays EXACTLY 0 given the same pitch. The
−100 dB audio null does NOT apply to this module under the relaxed standard —
that is precisely the relaxation — and the phase-integration residual it
would show corresponds to a fixed detune three orders below the instrument's
own scatter.

**This trade needs the USER's explicit sign-off, because it changes the
accuracy standard for one module.** The bound (0.05 cents) must be verified
by building the table and running the sweep; the ~0.02-cent figure above is
an argued bound, not yet a measured one.

## 4. What it buys, honestly

| configuration | instr/sample | vs S3 budget 6,300–9,500 |
|---|---|---|
| today's shipping build | 55,167 | 5.8×–8.8× |
| + recentered pitch (−21,000) | ~34,200 | 3.6×–5.4× |
| + C2 + C5 (~−5,500) | ~28,700 | 3.0×–4.5× |
| + C4 fixed-point/SIMD (×2.5 on audio path) | ~19,600 | 2.1×–3.1× |
| + C6 reduced oversampling | ~13,900 | 1.5×–2.2× |
| + 6 voices (the last resort) | ~10,400 | 1.1×–1.7× |

Even with everything, the S3 lands marginal — silicon's cycles-per-
instruction decides. For comparison, on a part with a DOUBLE FPU (Teensy 4.1,
named in GOAL.md) the pitch problem does not exist, no standard is relaxed,
and the same ladder lands under budget with margin.
