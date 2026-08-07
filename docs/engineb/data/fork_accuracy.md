# IS THE FORK SONICALLY ACCURATE? — the composite, measured for the first time

Date 2026-08-06 (Opus 5), answering a direct question: "and it's sonically
accurate?"

**THE SHORT ANSWER: the trunk is bit-exact and stays that way. Of the fork's
levers, three are proven on the WHOLE ENGINE and two are not — and the two that
are not are the two the speed ladder depends on.**

Every fork lever had been gated ALONE, on one module, against a bound chosen
for that lever. **The composite had never been measured at all.** That is the
same hole this project has found twice before: "the defect only a composite
could find", and "a verification that has never been seen to fail is not a
verification".

## What is proven on the whole engine

| lever | gate | scope |
|---|---|---|
| the trunk | **EXACTLY 0** | 36 scenarios, both rates, vs the port; 11/11 bit-exact vs the PLUGIN |
| DCO edge short-circuits | **EXACTLY 0** | same |
| glide exponent hoist | **EXACTLY 0** | same |
| shared LFO | **EXACTLY 0** | same |
| `vcf_res` tabulation | **−108.8 dB** | same — and that clears the TRUNK bound, not just the fork's |

These are not in question. A build with only these levers is either
bit-identical to the port or 108.8 dB below it.

## What is NOT proven on the whole engine

### pitch fork + exp fork — marginal

Band-limited null (18 kHz low-pass, delay-aligned), 36 scenarios at 44.1 kHz:
**−79 to −89 dB global.** F5's bound is −80/−60, and **9 of 36 scenarios fall
short of it**, worst −79.1 dB global / −61.9 dB block on the arpeggiated
scenario.

That is 1 dB outside a bound, not a different sound. But it is outside it, and
no document said so before now.

### half-oversampling — −36 dB, and it was never gated this way

O8 accepted half-oversampling on **alias LEVEL** (F5's gate 2) and on harmonic
level. F5's design also specified a **gate 3** — a band-limited null at
−80/−60 — and `tools/engineb/halfos_gate.py` exists to run it.

**Run on half-oversampling alone, it measures −35.7 dB.** That is 44 dB above
its own stated bound.

### THE GATE HAD A DEFECT OF ITS OWN, found on the way

The first version aligned only INTEGER lags. F5's design says the 2×
decimator is **1.87 output samples** longer than the port's, so integer
alignment leaves **0.87 of a sample of pure delay** in the residual — and a
pure delay of d samples costs `2πfd/fs` radians, about 1.8 % at 1 kHz and 18 %
at 10 kHz. **That is −35 dB on its own.**

So the gate was potentially measuring its own missing fraction of a sample and
blaming the lever. It now aligns fractionally, in the frequency domain, which
is exact rather than interpolated.

**It did not change the verdict.** After fractional alignment half-OS still
measures −35.9 dB, and the correlation peak sits at an integer lag. The defect
was real and had to be fixed before the number could be trusted; the number
survived the fix.

## WHY THIS DOES NOT SINK THE LADDER

**`REAL_TIME.md`'s engine does not contain half-oversampling.** The
band-limited DCO replaces `eb_dco_step4` AND the whole decimator, so there is
no oversampling left to halve. The priced configuration is:

    fork pitch + fork exp + shared LFO + vcf_res table + wavetable DCO

`EB_HALF_OS` is not in it, and its −36 dB does not appear in the shipping
engine.

## SO WHAT IS ACTUALLY UNPROVEN

**The wavetable DCO has never run inside the engine.** Its gate
(`tools/engineb/wt_gate.py`) is a probe: one patch's recalled coefficients, six
pitches, a fixed pulse width, comparing spectra. It passes well — alias floor
down 71 to 92 dB, harmonics within 2.88 dB against half-OS's own 3.27 — but:

* it has never been driven by the engine's own coefficient chain,
* it has never seen a modulated pulse width in a real scenario,
* it has never been compared against the PLUGIN, only against the port's DCO,
* and its residual TABLES do not exist yet — the probe builds equivalents by
  DFT.

## The honest answer

**No, not yet — and the gap is one specific, named thing.**

The engine as it stands today, with every lever that is actually wired in, is
either bit-exact or 108.8 dB below the port. That part is solid.

The speed result in `REAL_TIME.md` depends on a DCO that is **designed,
measured in a probe, and not yet built into the engine**. Until
`eb_dco_wt.c` runs inside `eb_engine_render` and nulls against the port across
all 36 scenarios — and then against the PLUGIN — nobody should say the fast
engine sounds right.

That gate is the next piece of work, and it is the one that answers this
question properly.
