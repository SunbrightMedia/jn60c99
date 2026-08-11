# THE END GOAL — USER-BINDING, STATED 2026-08-11

The user said this once and said it is the most important thing they will ever
say on this project. It is written here so it never has to be said again, and
so every future session reads it before anything else.

## The goal, verbatim in substance

1. **Sonically accurate** — to a degree that is AUDIBLY IDENTICAL.
2. **The full 6-voice fork on EXACTLY TWO ESP32-S3 boards.** No more boards
   than that.
3. **With full FX, including chorus.**
4. **Seamless, real-time — no stuttering or issues whatsoever.**
5. **Complete, unadulterated control over EVERY parameter**, including preset
   recall.
6. **Confidently proven to be accurate.**

**That is the only thing this project works towards. It is the assistant's
entire responsibility, and the assistant owns it.**

## What that means in practice, so it cannot be quietly reinterpreted

**"Audibly identical" is the standard, not "close".** The trunk stays
BIT-EXACT (null gate, residual EXACTLY 0). The fork is held to the third-octave
sonic gate, and the final judgement is the user's ear on WAVs. A number that
passes a gate the user cannot hear is not the goal being met.

**"Exactly two boards" is a hard constraint, not a target.** Permanently ruled
out, never to be re-proposed: a third chip, a different chip, 32 kHz, fewer
than six voices, dropping any FX. If the numbers say the goal is unreachable
without one of those, THAT SENTENCE GOES FIRST in the report — it does not get
buried under a cycle table.

**"No stuttering whatsoever" means headroom, not parity.** A build that meets
the budget exactly drops audio the first time a patch changes, because recall
is a burst. Parity is not the finish line; margin is.

**"Every parameter" includes the ones nobody has built yet.** Device recall
(patch bytes -> coefficients) does not exist on the device today. Neither does
MIDI, parameter control, preset storage, the arpeggiator, tuning, or a front
panel. All of them are part of this goal. **A render engine is not an
instrument**, and progress reports must not present one as the other.

**"Confidently proven" means the gate must be able to fail.** Every claim
carries PROVEN (executed) / READ (source) / INFERRED. A subtraction is not a
measurement. A gate configured differently from the device proves nothing about
the device — that error hid a dead LFO through an entire night of work.

## The reporting rule this earns

The failure that made the user state this was not a technical one. It was
**reporting cycle counts as the headline while the thing being timed could not
be played.** Every fact was on the record; none of it was foregrounded.

So: **progress is measured against the six items above, in the user's words,
and a status report says which of them are met.** Not how many cycles were
saved this session.
