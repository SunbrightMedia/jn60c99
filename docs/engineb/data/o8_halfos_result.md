# O8 — half-oversampling, DCO path: BUILT, GATED, and it needs a decision

Date 2026-08-05 (Opus 5), executing O8 against `../F5_HALFOS_DESIGN.md`.
Reversible throughout: `EB_HALF_OS` defaults to 0 and the 4x path is
untouched, so nothing here changes any build until a flag is set.

**The sentence first: the DCO half-oversampling path works, it costs 3,826
instructions less at 6 voices (2.15x -> 1.82x over the 44.1 kHz two-core
budget), and it changes the instrument's sound MORE than the relaxation the
user approved. The extra change is that the fork is 16-17 dB CLEANER than the
plugin at high pitch, not merely differently-aliased. That is the decision
this document asks for.**

## 1. What was built

| piece | state |
|---|---|
| `EB_HALF_OS` / `EB_DCO_SUBSTEPS` in `eb_fork_config.h` | default 0 / 4 |
| `eb_dco_step4` at 2 sub-steps | done |
| `eb_render.c` increment wiring (`inc*2`, `g` UNCHANGED) | done |
| 24-tap designed 2x FIR (`eb_halfos_fir.h`) + `eb_decim_tick` fork arm | done |
| VCF path (F5 §3, `G' = 2G/(1-G^2)`) | **NOT started** — see §6 |

## 2. Gate 1 — response match: PASS

`tools/engineb/gen_halfos_fir.py`. The 4x reference is MEASURED by executing
`eb_decim_tick` with the biquad bypassed, not read off the tap-map comment,
and the reconstruction is checked for symmetry before anything is built on
it.

- in-band |H| match, 20 Hz..16 kHz: **worst 0.0783 dB** (bound 0.1)
- notch region 16-19 kHz, absolute |H| gap: 0.0747 (the 4x peak there is
  0.2711)
- stopband from 26 kHz: −54.4 dB
- group delay 4x 87.9 us vs 2x 130.4 us = 42.5 us = 1.87 output samples

**F5 SPECIFICATION ERROR 1, mine to correct: gate 1 said "to 18 kHz".** The
port's 4x decimator has a NOTCH at ~18 kHz (−28.9 dB) — it is not a
lowpass, it IS the instrument's top-end tone. A 0.1 dB bound evaluated inside
a −29 dB notch is unachievable by any filter and would be measuring the
notch's position rather than the response the ear gets. The match band is 16
kHz, where |H| is still ≥ −10 dB, and the notch region is reported in
absolute terms beside it.

## 3. Gate 2 — alias level: PASSES ITS BOUND, and the reading beside it is the finding

`tools/engineb/o8_gate2.py`, on the SHIPPING modules built twice from one
source (`data/o8_alias_probe.c`), patch 32's real recalled coefficients.

| ~f0 | plugin's own 4x floor | fork 2x floor | rise | harmonic delta <16 kHz |
|---|---|---|---|---|
| 441 Hz | −111.4 | −111.4 | +0.0 | 1.82 |
| 882 Hz | −108.6 | −108.6 | +0.0 | 1.27 |
| 1.76 kHz | −127.0 | −127.7 | −0.6 | 3.27 |
| 3.5 kHz | −53.6 | −122.6 | −69.0 | 0.65 |
| 7.1 kHz | −51.1 | −67.5 | **−16.5** | 0.01 |
| 10.6 kHz | **−43.1** | −60.1 | **−17.1** | 0.01 |

F5's bound is a RISE bound (+1 dB) and no band rises, so **gate 2 passes as
written**. What it does not cover is the column that matters here.

**F5's alias table is not reproducible, and the reason is a defect in F5's
own probe.** F5 reported ±0.7 dB at every band. That probe computed
`g = 0.00390625f / inc` with the ALREADY-DOUBLED increment — i.e. it halved
`g`, which is exactly the mis-wiring the null gate rejected in this session
(up to 4.95 dB of in-band tilt). Re-measured on the shipping code with `g`
correct, the alias floor DROPS. Checked rather than assumed: substituting
F5's own Kaiser half-band for the designed FIR gives bit-for-bit the same
floors (−122.5 / −67.5 / −60.1), so the drop is the 2x path itself and not
the filter design; and rebuilding with `g` halved gives −58.2 / −56.4 with
the tone peak down 3.6-5.0 dB, which reproduces neither F5's table nor a
usable engine.

**Why it drops.** The naive shaping's aliases fold about 44.1 kHz at 2x
instead of 88.2 kHz at 4x. More of them land above 22 kHz, where the
decimator removes them; those that survive land higher in the band, where
the port's own top-end droop attenuates them further. The instrument's
gritty top end gets cleaner.

**Harmonic levels.** Match to 0.01 dB at high pitch. At low pitch they differ
by up to 3.3 dB, always at bins 65-90 dB below the fundamental and always
above 14 kHz. Gate 1 measured the two cascades' responses equal to 0.078 dB,
so this is not the filter — it is the shaping nonlinearity's own high
harmonics differing between a waveform sampled at 176.4 kHz and one sampled
at 88.2 kHz. It is the lever's signature and no filter design removes it.

## 4. Gate 3 — the band-limited null: INVALID AS WRITTEN, and that is my second specification error

F5 specified a −80 dB global / −60 dB block residual measured through an 18
kHz low-pass. It was built (`tools/engineb/halfos_gate.py`, lag-aligned by
cross-correlation) and it failed at −33 to −45 dB on all 36 scenarios.

Before treating that as a defect, the fold arithmetic was worked out. For a
1764 Hz saw:

| harmonic | at 2x stage | after decimation |
|---|---|---|
| 25 (44,100 Hz) | 44,100 Hz | **0 Hz** |
| 30 (52,920 Hz) | 35,280 Hz | **8,820 Hz** |
| 40 (70,560 Hz) | 17,640 Hz | **17,640 Hz** |
| 48 (84,672 Hz) | 3,528 Hz | **3,528 Hz** |

**Repositioned aliases land IN BAND by definition.** An 18 kHz low-pass
cannot separate the alias repositioning the user approved from an
implementation defect, because the approved change lives inside the pass
band. No correct implementation of this lever can pass that gate, so a
failure carries no information — and neither would a pass.

This is the second time in this session I have changed a gate specification I
wrote, so it is stated as an error rather than folded in quietly. The
difference from a gate loosened to get a pass is that the arithmetic above
shows the bound is unreachable BY CONSTRUCTION rather than merely hard: the
same category of argument as gate 1's notch, and it is checkable in four
lines.

**What replaces it**: gates 1 and 2, which do discriminate — a wrong filter
fails gate 1 at decades, a mis-wired increment fails gate 2's harmonic column
at decades (both were observed this session, on real defects), and the
identity build (`EB_HALF_OS=0`) still nulls EXACTLY 0 through the trunk's own
battery, which is what keeps the fork honest about what it changed.

## 5. The cost, and the third modelled saving that measured zero

`engine_price.py --fast-pitch --recip --fork --shared-lfo --half-os`:

| build | instr/sample | cycles (x0.95) | vs ~10,900 |
|---|---|---|---|
| fork + shared LFO | 24,686 | ~23,450 | 2.15x |
| + half-OS DCO | **20,860** | **~19,817** | **1.82x** |

**The decimator saves NOTHING.** F5 modelled −450. MEASURED on Xtensa: the
4x arm is 151 instructions and the 2x arm is 151 instructions — 24 folded,
unrolled taps at half rate cost exactly what 32 folded taps at full rate
cost. Getting there took two rewrites that are recorded in the code because
both were counter-intuitive: the first form (masked ring) cost **176**, i.e.
the "half" decimator was MORE expensive than the whole one it replaces, and
the rolled-but-linear form cost 166. Only the double-written linear buffer
plus a full unroll reaches parity. The saving in the table is the DCO's alone.

A defect found by the same rewrite and worth recording: the double-written
buffer needs TWO index increments per audio sample, and dropping the second
one leaves the newest sample overwritten next call. It measured as a 50-58 dB
harmonic error — loud, obvious, and caught immediately by gate 2's harmonic
column, which is the column F5 never specified.

## 6. Where O8 stops, and what it is waiting for

The VCF half-oversampling rung (F5 §3, worth a further ~2,900) is NOT built.
It is not blocked by anything technical — the algebra is exact and needs no
frequency knowledge — but it ships behind the SAME `EB_HALF_OS` flag and
inherits the same relaxation, so building it before the relaxation is settled
would be building on an unapproved premise.

**The decision, in one sentence.** The user approved "alias positions not
preserved, alias level matched". What is measured is "alias positions not
preserved, and 16-17 dB LESS alias content than the plugin above ~7 kHz" —
the fork is cleaner than the instrument on bright high notes, which F5's own
standard ("this project does not get to be better any more than worse")
forbids by default.

If that is acceptable, O8 finishes the VCF rung and the fork lands at roughly
1.55x. If it is not, `EB_HALF_OS` stays 0, everything above remains in the
tree as a measured negative result, and the fit ladder keeps only the levers
that preserve the instrument exactly.

## 7. The VCF rung — BUILT, MEASURED, CLOSED NEGATIVE

The user accepted the alias relaxation, so the VCF rung was built. It does not
hold, and the reason is not the relaxation that was accepted.

**Two things had to be corrected first, and both were caught by the gate
rather than by reading.**

1. **F5 §3's parameterisation is wrong.** It states `G = tan(pi f / fs)` and
   derives `G' = 2G/(1-G^2)`. Matching the port's own one-pole,
   `H(z) = G(1+z^-1)/(1 - (1-2G)z^-1)`, against the bilinear lowpass shows
   `G = g/(1+g)` with `g = tan(pi f/fs)` — G is the bilinear GAIN, not the
   prewarped tangent. The correct map goes through g and back:
   `g4 = G/(1-G)`, `g2 = 2g4/(1-g4^2)`, `G' = g2/(1+g2)`. F5's form measured
   up to **29 dB** of error; the corrected form fixes the cutoff exactly.
2. **The sub-step weights are READ, not designed.** Dumped from a recalled
   engine: c9216=0.75, c9232=0.25, c9248=0.5, c9200=1.0 — exactly linear
   interpolation at 1/4, 1/2, 3/4, 1. The two half-rate instants are 1/2 and
   1, which are the port's OWN second and fourth inputs, used verbatim.

**With both corrections the rung still fails, structurally.** Measured on the
shipping ladder at G=0.1 (cutoff 5,596 Hz), k=2.0:

| band | 4x response rel. peak | 2x error |
|---|---|---|
| 20-200 Hz | −7.3 dB | +0.01 dB |
| 200-1000 Hz | −6.7 | −0.03 |
| 1-4 kHz | −2.6 | −0.50 |
| 4-6 kHz | 0.0 | −0.88 |
| 6-9 kHz | −3.2 | **−2.56** |
| 9-13 kHz | −17.8 | **−6.28** |
| 13-16 kHz | −29.8 | **−12.36** |

DC gain matches to 0.05 %, so this is not a level error, and gate 1 already
proved the decimator matches to 0.078 dB, so it is not the filter design.
**It is the ladder itself**: a bilinear filter run at half the rate cannot
have the same shape near its own Nyquist. The transform fixes the CUTOFF and
nothing fixes the SHAPE. At 16 kHz the 2x filter sits at 0.63 of its Nyquist
where the 4x filter sits at 0.32.

**Why that is a different decision from the one the user made.** The DCO rung
changes alias content at −43 to −51 dB. This changes the FILTER'S OWN SKIRT by
2.6 to 12.4 dB in the audible band, per patch — i.e. brightness, on every
patch whose cutoff is below about 8 kHz, which is most of them. Accepting the
alias relaxation does not imply accepting this, and treating it as covered
would be exactly the "gate loosened until it passed" failure this document
already records twice.

`EB_HALF_OS_VCF` is therefore a SEPARATE flag, defaulted 0 **even when
EB_HALF_OS is 1**. The code stays in the tree so the negative result is one
command away instead of a paragraph.

MEASURED cost of what was declined: 762 -> 476 executed Xtensa instructions
per voice per sample, i.e. **1,716 at 6 voices** — not F5's modelled 3,150.

## 8. Where O8 ends

| build | instr/sample | cycles (x0.95) | vs ~10,900 |
|---|---|---|---|
| fork + shared LFO | 24,686 | ~23,450 | 2.15x |
| **+ half-OS DCO (shipping O8)** | **20,860** | **~19,817** | **1.82x** |
| + half-OS VCF (DECLINED) | 19,144 | ~18,187 | 1.67x |

**Fifth modelled lever killed by measurement** (C1 integration, C4 resolution,
C5 registers, C2 stochastic content, now the VCF half-OS rung's response
shape). O8 delivers 2.15x -> 1.82x and no more. O9 (tabulation, ~-2,900) and
O10 (DCO structural, ~8,700 available) are what remain between here and 1.0x
at 6 voices; 4 voices with the DCO rung is roughly 1.2x.
