# THE GOAL — read this first, every session

This is the single, entire goal of this project. Nothing here is optional and
nothing else is the goal. If you are an AI assistant working on this repo, read
this before doing anything, and do not "forget" it or hedge around it.

## The goal, in the user's words

1. A **bit-exact C99 port of the DSP engine** of the Roland Cloud JUNO-60
   (JU-06A / "Cloud 60") plugin.
2. On top of that, **whatever it needs to sound EXACTLY the same as the original
   plugin, playable in the browser.** Not "close." Not "the parts that were
   easy." The exact same sound.
3. The end purpose: **eventually port it to a small microcontroller** (e.g.
   Teensy). So the port must stay portable C99 — no heavy dependencies, no
   x86-only tricks, no runtime emulation in the shipped code.

That is the whole ask. Bit-exact DSP + whatever it takes to match the original's
sound in the browser, kept portable enough to run on a Teensy later.

## What this means concretely (do not lose these)

- **Ground truth is ONLY the decompiled + compiled plugin binary.** No captures,
  no external data, no Ableton-displayed numbers, no fitted curves, no guessed
  orderings. If a value/order isn't derivable from the binary, say so plainly —
  do not fabricate it and do not quietly ship a guess.
- **"Sound exactly the same" is the acceptance test**, not "N parameters bound."
  A preset must play identically to the original plugin. That includes the full
  signal path the original uses: voice DSP **and** the master/chorus/output
  stage, and a faithful note-on/gate/pitch path — not just a subset of
  coefficients that happen to be verifiable.
- **All parameters that affect the sound must be recalled correctly** from a
  preset, bit-exact, however they are stored in the file. "This param is 0 in
  this bank" is not an excuse to skip it — it must recall correctly for any
  value, because the microcontroller target will load arbitrary presets.
- **Keep it portable.** The shipped engine is plain C99. Unicorn/emulation are
  fine as *analysis tools* to recover the algorithm, but nothing emulated may be
  required at runtime.

## Honest status pointer

Current real state (params bound, what's verified, what's still wrong or missing)
is tracked in `docs/AUDIBLE_RECALL_PLAN.md`. Keep that honest and current. When
something is not done, or was found to be wrong, write that down — do not
overstate coverage.
