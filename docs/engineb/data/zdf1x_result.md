# EB_VCF_ZDF1X — CLOSED NEGATIVE, at the LINEAR stage
2026-08-09, Opus 5. Plan: docs/engineb/VCF_ZDF1X_PLAN.md. Flag kept, default
OFF, so the negative is reproducible in one command.

## The verdict, first
**The 1x refit fails the sonic gate at 23.77 dB, 30 of 36 scenarios**, and it
fails for a reason no fitting could have repaired. S4 (fit the saturation) was
NOT attempted: the plan requires the linear skeleton to be green first, and it
is not. Fitting a nonlinearity over a 20 dB linear error would have been
fitting two errors at once.

## Why it cannot work — the obstruction, named
The port's one-pole is

    H(z) = G(1 + z^-1)/(1 - A z^-1),   A = 1 - 2G

so it carries a ZERO AT NYQUIST, and the cascade carries four of them. At 4x
those zeros sit at 88.2 kHz and are inaudible bystanders. At 1x they sit at
22.05 kHz and gut the top octave. **No choice of cutoff moves them**, because
the corner and the zeros are set by different parts of the same expression.

Both ways out were built and measured (gate G-A, per-bin, real recalled
coefficients, over the MEASURED domain G in [0.000119, 0.209771],
k in [0, 3.981]):

  variant 1  bilinear corner match, zeros kept
             0.2-1.8 dB below G = 0.01;  up to 20.4 dB near Nyquist at
             G >= 0.05.  Resonance correct, top octave wrong.
  variant 2  pole mapped exactly (A^4), zeros dropped
             up to 51.2 dB, and the damage is AT THE RESONANT PEAK
             (45-51 dB at k = 3.98). The numerator carries loop phase, so
             removing it moves the peak. Top octave better, resonance wrong.

Keep the zeros and lose the top octave; drop them and lose the resonance.
That is a bind in the structure, not a tuning failure, and it is the cleanest
negative any ladder attempt has produced.

## What the exercise established anyway (all of it reusable)
1. **c9152 belongs to the 1x path.** The first draft dropped it with the
   decimator. Gate G-A's DC column then read port 0.97022 against 0.24254 --
   a ratio of EXACTLY 4.0000. c9136 scales the INPUT by 0.25 and c9152
   restores it; the decimator has unity DC gain and never carried that
   factor. **A fitted makeup gain in S4 would have absorbed a factor of four
   silently**, and the fit would have been hiding it.
2. **k reaches 3.981 over the whole battery** = 99.5 % of a 4-pole's
   self-oscillation threshold. The existing 36 scenarios DO drive the regime
   a fitted saturation is judged by; S2's synthetic high-resonance scenario is
   unnecessary. Measured, not assumed.
3. **The argument order is (in, G, k).** The res shaper's [0,1) return is the
   CUTOFF; cell 7536 is the resonance. eb_vcf_res.h's "[0,1)" note describes
   the former and reads as though it describes the latter.
4. **The port's ladder is ALREADY zero-delay.** `ins` arrives pre-multiplied
   by R = 1/(1+k*G^4) and the feedback is ins - s1*R*k, which IS the TPT
   solve. The 4x buys nothing for the linear filter -- it is there for the
   saturator, exactly as the header always said.

## Three defects in the gate, found by running it
- The bin array capped the sweep at 5.5 kHz, and the worst error then landed
  on the last bin examined in ALL 25 rows. A worst case that always sits on
  the edge of the examination is a defect in the examination.
- A raw magnitude RATIO is unbounded where both responses are 100 dB down. A
  relevance floor (within 60 dB of the port's own peak) was added, and the raw
  figure kept beside it rather than replaced.
- **The proxy was not the charter gate.** Per-bin magnitude is far stricter
  than third-octave band ENERGY on rendered audio: the 2x path, which this
  repo records at 0.03 dB, measures 2.14 dB per-bin on the same probe. Both
  numbers are true and they answer different questions. Only the sonic gate
  decides -- which is why the verdict above comes from the sonic gate and not
  from G-A.

## Consequence for the schedule
The ladder's oversampling cannot go to 1x. Its floor is 2x, where the LINEAR
cascade is already close and the failure (3.17 dB, EB_HALF_OS_VCF) is entirely
in the NONLINEARITY. That is the next thing to attack, and it has never been
attacked by FITTING -- the three ADAA orders addressed aliasing, which is a
different defect from level.

# PART 2 — THE 2x PATH, AND WHY OVERSAMPLING IS NOW CLOSED
2026-08-09, same session. Everything below is measured.

## The reframing that made the rest quick
`EB_HALF_OS_VCF` measures 3.17 dB and the record attributed it to "in-band
harmonics from half-rate waveshaping". **That attribution is wrong.** Gate G-A
run on the 2x path with the saturator OFF ON BOTH SIDES measures a band error
of 2.758 dB. The residual is overwhelmingly LINEAR, which is why three ADAA
orders (2.22 / 5.77 / 33.94, centred 3.25) never moved it -- they were all
treating aliasing, and the defect is response.

## Attempt 1 — fit the saturation drive. CLOSED NEGATIVE.
`EB_VCF_SATFIT`, nl = sat(x*a)*(m/a), identity at a = m = 1.
MEASURED over the full 36-scenario battery, worst third-octave band:

    a = 0.85   3.43 dB        a = 1.30   (worse)
    a = 1.00   3.17 dB  <- MINIMUM, and it reproduces the recorded figure
    a = 1.15   3.52 dB        a = 1.80  12.16 dB
                              a = 2.20  16.00 dB

a = 1.0 is a local minimum and both directions are worse, so the 2x residual
is not a saturation LEVEL error. The a = 1 row is also the harness's own
non-vacuity control: it lands on 3.17 dB exactly, so the flag is the identity
when unset and the measurement is of the thing it claims.

## Attempt 2 — retune the cutoff map. HALVES IT, NOT ENOUGH.
The current map matches the corner exactly, which is not the same as
minimising in-band error. Per-G optimal G' (numerical, 20 Hz - 18 kHz):

    G = 0.001   4.06 -> 2.03 dB      G = 0.12    2.95 -> 1.09 dB
    G = 0.01    4.05 -> 1.97 dB      G = 0.2097  0.94 -> 0.60 dB
    G = 0.05    3.87 -> 1.64 dB

Best case ~2.0 dB against a 1.0 dB bound. And the residual after retuning is
strongly k-DEPENDENT (k = 0 and k = 3.98 differ by ~2 dB at 18 kHz), so no
FIXED spectral correction folded into the decimator can absorb it: applying
the best single correction leaves a worst residual of 3.67 dB.

## Why any rate reduction fails — one sentence
The port's one-pole carries a zero at Nyquist. Lowering the rate moves those
four zeros down into the audio band: the numerator-only mismatch is
+1.70 dB at 10 kHz, +4.55 at 16 kHz and +7.43 at 20 kHz for 2x, and roughly
doubles again for 1x. It is G-dependent through the pole interaction and
k-dependent through the loop, so it is not one fixed curve that one fixed
filter can undo.

## The exact 1x equivalent EXISTS, and dies on the chip, not the maths
Hankel singular values of the port's own 1x impulse response give the system
order directly (a fitter cannot fake it; a bad fitter cannot hide it):

    G = 0.001   order 4        G = 0.12    order 8
    G = 0.01    order 7        G = 0.2097  order 7
    G = 0.05    order 8

So a 1x equivalent is an ARMA of 4 poles and ~8 zeros -- around 12 multiplies
a sample against the ~170 flops the 4x path costs. The poles even have a
CLOSED FORM: (1 - Az^-1)^4 + kG^4(1 + z^-1)^4 = 0 factors through the fourth
roots of -1, so z_j = (A + c_j)/(1 - c_j) with c_j = k^(1/4) G w_j, and the
decimated poles are z_j^4.

**It dies on the ESP32-S3's arithmetic, not on accuracy.** That form needs a
k^(1/4) and FOUR COMPLEX DIVISIONS every sample. The S3 has NO hardware FP
divide -- eb_vcf_ladder.c's own header opens by saying the single division in
R is a soft-float call, measured rather than avoided. Four more per sample
costs more than the four sub-steps they replace.

The tabulated alternative -- a shared 2D (G,k) table of the 4 poles -- is the
only route left, and it is a NEW RESEARCH PROJECT rather than a closing move:
its accuracy near k = 3.98 (99.5 % of self-oscillation, which the battery does
reach) is exactly where pole-radius interpolation error is most audible, and
nothing here has measured that.

## STATUS
Oversampling reduction is CLOSED at 4x for every structure tried or costed:
1x direct (23.77 dB), 2x + drive fit (3.17 dB, a minimum), 2x + retuned map
+ fixed correction (3.67 dB), exact-1x ARMA (arithmetic, not accuracy).
