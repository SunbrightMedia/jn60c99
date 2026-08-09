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
