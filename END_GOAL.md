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

## 7. THE PROCESS MUST BE REPEATABLE (added by the user 2026-08-12, BINDING)

The user's own words:

> the PROCESS that is used, all the way from importing the .vst3 file into
> claude, to getting the .vst3's DSP engine fully working on two ESP32S3's,
> should be as REPEATABLE as possible, to prevent further frustration and to
> make the process extremely quick compared to how long it has taken to make it
> the first time.

**This is a DELIVERABLE, not a nice-to-have.** The next synth — the JX-3P, and
whatever follows it — must take days, not a month. The first one took a month
because every method had to be invented while it was being used. None of that
may have to be invented twice.

### What it means in practice

**The reusable half is the METHOD, not the DSP.** The JUNO's transcribed
arithmetic transfers to nothing. These transfer to everything:

- `.claude/workflows/` — every multi-agent run, kept whole. Point
  `fork-adversarial-audit` at another fork and it hunts the same defect
  classes, because the classes belong to the method.
- `docs/engineb/METHOD_PLAYBOOK.md` — the defect catalogue.
- The gate shapes: null to EXACTLY 0, the third-octave sonic gate, teeth on
  every gate, `plugin_check`, the two-process rule, PROVEN/READ/INFERRED.
- The harness: the Unicorn oracle, the shim pattern, the cell-map generator,
  the compact patch format, the device gate.

**So every tool built from here is built to be pointed at a different synth.**
Hardcoding a JUNO constant into a tool that did not need it is a defect against
this item, the same as a wrong coefficient is a defect against item 1.

**And the pipeline must be written down end to end.** From "here is a .vst3" to
"two boards are playing it": every step, in order, with the gate that closes it
and the trap that is waiting in it. A method that lives only in one session's
memory has not been made repeatable.

### How progress on this item is measured

Not by how tidy the tools look. **By how fast the SECOND synth goes.** Until
another synth has been through the pipeline, every claim about repeatability is
INFERRED and must say so.

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

## DECIDED: parameter resolution — 8-bit now, 10-bit later, no CPU cost either way

The user asked whether moving to 10-bit parameters later would cost real-time
headroom. **It does not, and the reason is structural rather than a matter of
degree.**

    patch bytes  ->  [curve tables]  ->  float coefficients  ->  [audio loop]
      8 or 10 bit                             identical              identical

The per-sample render path NEVER READS A PARAMETER. Grepping `eb_render.c` for
`eb_params` / `patch` returns only comments; the loop reads `eb_render_coefs`,
which is floats. A float coefficient is a float coefficient whether it came
from a table index or an interpolation between two table entries, so the DSP
cannot tell and the per-sample cost is bit-for-bit identical.

What 10-bit actually costs:
  per parameter change   one lerp instead of a bare table index -- a few
                         instructions, ONCE, inside the recall burst
  storage                79 bytes -> ~99 in the compact patch
  PER SAMPLE             ZERO

Label: **READ**, from the code structure. It cannot be MEASURED until device
recall exists, because today no parameter can change on the device at all. The
structural argument is strong -- for 10-bit to cost per-sample cycles the audio
path would have to read parameters, and it demonstrably does not -- but it is
not yet an executed result and must not be quoted as one.

THE DECISION, so it is not re-litigated:
  Build the parameter path at 8-BIT first. That is the plugin's own resolution
  (its front-panel bytes are 0-255, already proven exhaustively over all 256
  values at three rates) and it is what the whole recall chain is gated on.
  Add 10-bit LATER as a build flag, once encoders exist and the user can judge
  by ear whether 256 steps feels coarse -- most likely it will not, except
  perhaps on filter cutoff.

THE HONEST CAVEAT ON 10-BIT, recorded now rather than discovered later: every
4th value lands on a plugin-verified point and the three between are values the
PLUGIN CANNOT PRODUCE. They cannot be proven against the reference. The gates
would certify the 256 anchors exactly and verify the interpolated points only
as smooth and monotonic between two proven neighbours. That is a mild,
deliberate departure from "audibly identical to the plugin" in the direction of
finer control. **It is the user's call, and it is recorded as a decision rather
than slipped in.**


## THE INVARIANT (user, 2026-08-12) -- a sharpening of item 4, equally binding

Verbatim: **"i want the final fork to be as IMMUTABLE as possible, as in there
is NO way for the code to break under any circumstance. this includes stutters
and such in any capacity, caused in any way, including changing a bunch of
parameters at once."**

What it means in practice, and it is a HARD REAL-TIME requirement rather than a
performance target: the audio block always completes on time for EVERY input --
worst patch, full polyphony, a program change and a parameter storm on the same
block. Bounded worst case, not a good average.

The policy when more is asked than fits: **the change arrives later; the audio
never breaks.** Latency degrades, continuity does not.

FINAL_GUIDE.md carries the four rules and the stress gate that proves it. A
track step is not DONE until it satisfies this.
