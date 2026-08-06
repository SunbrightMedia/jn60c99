# WHERE EVERY INSTRUCTION GOES — the S3 fork profiled below module level

Date 2026-08-06 (Opus 5), at the user's request after "there has to be another
way". Static Xtensa instruction counts, ENTRY FUNCTIONS ONLY (reset/init
bodies excluded — they do not run per sample), S3 fork, 6 voices, 44.1 kHz.
The DCO uses `dco_price.py`'s MEASURED branch rates rather than a static
worst case.

| module | per call | calls | per sample | share |
|---|---|---|---|---|
| **dco** | **1,452** | 6 | **8,712** | **40.1 %** |
| **vcf_ladder** | 461 | 6 | **2,766** | **12.7 %** |
| vcf_res | 222 | 6 | 1,332 | 6.1 % |
| vca_hpf | 211 | 6 | 1,266 | 5.8 % |
| glide | 172 | 6 | 1,032 | 4.7 % |
| envgen | 81 | 12 | 972 | 4.5 % |
| decim | 152 | 6 | 912 | 4.2 % |
| pwm_cv | 142 | 6 | 852 | 3.9 % |
| reverb | 765 | 1 | 765 | 3.5 % |
| vcf_cv | 95 | 6 | 570 | 2.6 % |
| chorus | 569 | 1 | 569 | 2.6 % |
| lfo (shared) | 489 | 1 | 489 | 2.2 % |
| pitch (fork) | 60 | 6 | 360 | 1.7 % |
| delay | 260 | 1 | 260 | 1.2 % |
| everything else | | | 880 | 4.0 % |
| **TOTAL core** | | | **21,737** | |
| dispatch arms (worst DELAY 1,979 + worst EFFECT 1,156) | | | 3,135 | |

## The two lines that matter

**DCO — 40 %.** Broken down by `dco_price.py` with measured branch rates,
per sub-sample step:

| part | instr | notes |
|---|---|---|
| **p_pulse** | **165** | **runs 100 % of steps** |
| p_fixed | 87 | phase accumulate + wrap, paid always |
| p_sub | 50 | 38.6 % of steps |
| p_saw | 31 | 53.4 % of steps |
| p_sat / shortcut | 25 / 16 | full saturator only 1.15 % of steps |

**The pulse block costs 5.3x the saw block and always runs.** Inside it,
`eb_triangle_wrap` alone is **53 instructions** and `eb_wrap_unit` 33 — a
fixed one-variable nonlinearity evaluated on every sub-sample of every voice.
At 6 voices that is 24 evaluations per audio sample. **The pulse block alone
is ~14 % of the whole engine** (165/363 x 40.1 %).

**VCF ladder — 12.7 %.** `eb_vcf_substep` is 87 instructions and runs 4x per
call (4x oversampling), so 348 of the 461 is the oversampled inner loop.

## What this says about the levers

Everything killed this week was attacked at the wrong altitude. C1 targeted
pitch (**1.7 %**). C2 targeted vcf_res and vcf_cv (**8.7 %** combined, and
stochastic). C5 targeted call overhead (**~1 %**). Meanwhile the DCO has been
40 % of the engine the entire time and has never been restructured, and
nothing has ever been tabulated.

**Untried, in order of size:**

1. **Tabulate `eb_triangle_wrap`** (53 instr -> ~6 with a LUT + lerp). It is a
   fixed function of one variable and it is FEED-FORWARD, which is precisely
   the case C4's post-mortem said survives fixed-point/approximation — the
   error does not recycle. Appears in the pulse path 24x per sample.
2. **The pulse edge is `clamp1(tri(t/pw) * g * 256 * amp)`.** The saturator
   shortcut already fires on 98.85 % of steps, which says the edge sits at
   +/-1 almost always; only the transition region needs the full evaluation.
   A branch on the clamp before computing the triangle would skip most of the
   165.
3. **`p_fixed` (87)** is per-step overhead paid whether or not anything
   sounds — 24 x 87 = 2,088 instructions/sample, 9.6 % of the engine, just
   accumulating and wrapping phase.
4. **VCF sub-step (87 x 4)**: the half-OS rung was declined on skirt error,
   but a corrective one-pole after the ladder was never tried.

None of these is a DSP redesign. They are the same arithmetic, evaluated
cheaper — a different category from every lever that died this week, all of
which tried to compute LESS OFTEN rather than compute the same thing FASTER.
