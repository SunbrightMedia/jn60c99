# P1 — the −100 dB null at 48,000 Hz. Hole H1 closed.

Date 2026-08-03 (Opus 5). Closes holes H1 and H2 of
`docs/engineb/DOUBT_AUDIT.md`.

## The hole

`tools/engineb/null_b.py` rendered every scenario at `null_ab.SR` = **44,100
Hz**, and had no way to render at any other rate. The ESP32-S3 build ships at
**48,000 Hz**. So no −100 dB sonic gate had ever run at the rate the target
actually uses, and the two fast-path results the plan depends on — the v7 pitch
null and the DCO reciprocal null — were 44.1k-only numbers being quoted as if
they described the shipping configuration. The whole-engine composite had also
never been run with `EB_PITCH_FAST=1` at any rate (H2).

## The change

`null_b.py --rate <hz>`. The rate is carried into the render worker as an
explicit argv element rather than an environment variable, because the worker is
a separate process and a rate that silently defaulted back on one side would
produce two streams of different lengths and a +999 dB residual — loud, but for
the wrong reason. `run()` additionally refuses to compare an oracle and a
candidate rendered at different rates; a reused oracle is exactly the object
that could outlive a rate change during a teeth battery.

`JUNO_EB_DCO_RECIP=1` was also added as a build hook. The reciprocal's −121.1 dB
result had been produced by hand-editing the header, so the gate that certified
it was not reproducible by anyone reading the file. It is now driven the same
way the pitch fast path is.

## The results — every one of these is a first

Gate: global ≤ −100 dB, worst-1024-block ≤ −80 dB, against the sealed port.

| build | 48,000 Hz | 44,100 Hz |
|---|---|---|
| self-test (no module substituted) | **EXACTLY 0** | EXACTLY 0 |
| composite `--module all`, default | **EXACTLY 0** | EXACTLY 0 |
| `--module pitch`, `EB_PITCH_FAST=1` | **−148.4 dB** | −123.6 dB |
| composite `--module all`, `EB_PITCH_FAST=1` | **−148.4 dB** | **−123.6 dB** |
| `--module dco`, `EB_DCO_RECIP=1` | **−121.5 dB** | −121.1 dB |
| **composite, FAST PITCH + RECIP (the S3 shipping build)** | **−121.5 dB** | **−121.1 dB** |

All PASS. Every scenario, both rates.

**Three things worth reading off this table.**

1. **48 kHz is not worse than 44.1 kHz — it is better.** The fast pitch nulls
   at −148.4 dB at the shipping rate against −123.6 dB at 44.1 kHz, 25 dB of
   additional margin. The doubt that motivated P1 was justified as a *process*
   matter (the measurement did not exist) but the risk did not materialise.

2. **The 44.1 kHz figures reproduce the previously published numbers exactly**
   — −123.6 dB and −121.1 dB. That is the evidence the rate plumbing did not
   perturb the harness, and that the new `EB_DCO_RECIP` build hook is faithful
   to the hand-edit it replaces.

3. **The composite residual equals the pitch-alone residual at each rate.**
   The other twelve modules contribute EXACTLY 0 even with the fast path
   integrated, which is an independent confirmation that pitch is the only
   inexact module in the engine.

**The S3 shipping configuration now has a sonic gate at its own rate, with
about 21 dB of margin on the global metric and about 41 dB on the block
metric.** It had none before this session.

## A harness defect this found — the teeth were blind at 48 kHz

Running the teeth battery at 48,000 Hz for the first time made the `dcopitch`
case report *"the planted error produced NO residual at all"*.

Cause: `src/juno_init.c:314` selects one of two precomputed constant sets,
`if (result == 44100)` and its else, and BOTH define `v32`. The mutation planted
unconditionally in the 44,100 arm, so at any other host rate it modified **dead
code**. The teeth case was not merely weak at 48 kHz; it measured nothing.

Fixed: the mutation now plants into whichever arm the run's rate executes
(`v32 = 991309769` in the else arm), and a wrong anchor count is a hard stop
instead of an assert.

This is the same class as every other defect this project has hit — a
verification that had never been seen to fail — and it was found only by
running the battery at a rate nobody had run it at.
