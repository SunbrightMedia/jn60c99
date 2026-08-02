# THE ACCURACY STANDARD — corrected 2026-08-02

**This supersedes the four-tier scheme in `DECISION_B.md`. That scheme conceded
a limit that does not exist, and in doing so hid the limit that does.**

## What I claimed, and why it was wrong

I wrote that the analog noise, the chorus LFO phase and the per-voice CONDITION
scatter "cannot be phase-matched by a different implementation", so they could
only ever be checked spectrally and statistically ("Tier 2").

That was wrong. **Nothing in this engine is stochastic.**

* The "analog noise" is a **digital LFSR** — closed, autonomous, deterministic.
  A shift register is trivially reproducible and costs a few operations a sample.
* The chorus LFO is a **phase accumulator** with a known increment and a known
  power-on value.
* CONDITION scatter is a **deterministic per-voice function of one patch byte**,
  computed at recall time, not per sample.

The whole project already proves total determinism: every gate is bit-exact and
reproduces run to run, on x86, on ARM and in WASM. There is no randomness to be
statistically equivalent to.

Measured just now, to be sure rather than to argue:

    determinism (identical driving, twice): IDENTICAL

**So the correct standard is: everything gets a sample-domain null. There is no
category of "can only be checked approximately."** Any error in engine B comes
from an approximation we CHOSE, and a chosen approximation has a measurable
budget that must be justified — it is never an excuse.

## The limit that actually exists, which the wrong claim was hiding

Free-running state is **load-bearing and audible**. Same patch, same note, the
only difference being how long the engine idled first:

| idle before note-on | output vs cold |
|---|---|
| 1 sample | **DIFFERENT** |
| 48 samples | **DIFFERENT** |
| 441 | **DIFFERENT** |
| 4,410 | **DIFFERENT** |
| 44,100 | **DIFFERENT** |

Even **one sample** of idling changes every sample of the note that follows. The
DCO phases, the noise LFSR and the FX LFOs all free-run, and where they stand at
note-on is part of the sound. This is the same mechanism as
`docs/COLDSTART_UNISON_FINDING.md`: all 8 DCOs boot phase-aligned and take ~4 s
of DSP to decorrelate, which is why the first note of a UNISON patch is ~2x hot
and much darker until they spread.

### Why this is the real constraint on engine B

The single largest optimisation available — **skip idle voices** — directly
attacks this. The plugin free-runs all 8 voices every sample by design; that is
the 98% idle floor. An engine that skips idle voices has different free-running
state, so the next note allocated to that voice sounds different.

**But the optimisation survives, if it is done correctly.** A free-running
oscillator's phase after N idle samples is computable in **O(1)** —
`phase += increment * N`, wrapped — not O(N). The same is true of any
accumulator, and an LFSR is cheap enough to just run. So the design rule is:

> **Skip the AUDIO work for a silent voice. Never skip its state advance.
> Advance free-running state analytically instead of by rendering it.**

That is what makes 8 voices affordable without changing what the ninth note
sounds like.

## The standard, restated

1. **Sample-domain null against the oracle, for everything.** Target
   **≤ −100 dB** global RMS *and* worst-1024-block. No spectral fallback, no
   statistical fallback, no exemption for "analog" behaviour.
2. **Every deviation is a chosen approximation with a written budget.** If a LUT
   or a polynomial is used in place of an exact computation, its error is
   measured, recorded per module, and must sum to less than the total budget.
   "It is an approximation" is a design decision that needs justification, not a
   licence.
3. **Parameter laws exhaustive** — every byte 0-255, every rate.
4. **Lockstep, which is new and is where the risk actually lives.** Engine B must
   hold the same free-running state as the oracle across idle periods, patch
   changes and voice allocation. Specifically it must null after 1, 48, 441,
   4410, 44100 and 441000 idle samples, and after a voice has been allocated,
   released and re-allocated.
5. **All 64 factory patches plus the Chillwave bank**, in real note sequences,
   in every voice-assign mode.

## A gate hole this exposes, today

**Every scenario in `tools/trackb/null_ab.py` starts from a cold engine.** Not
one of them idles first. So the entire scenario set is structurally incapable of
catching a lockstep failure — the exact class of defect that produced the warm
chorus-arm divergence and the MONO retrigger bug, both of which were invisible
to every cold gate.

Idle-prefix scenarios are therefore a **prerequisite**, not an improvement. They
must exist before engine B's first module is written, because without them a
skipped-voice optimisation would pass every gate and be wrong.
