# ★★★ THE SHIPPING FORK HAS NO LFO, AND NO GATE CAN SEE IT (2026-08-11)

Found by an adversarial reviewer pointed at the two-chip link design; verified
here by reading every link in the chain. This is a CORRECTNESS defect in the
firmware the user has been flashing all night, not a cost finding.

## The chain, each link read directly

**1. The device forces voice 0 at rest.** The wake masks are

    s3_listen_meta.h:29   {0x80,0xc0,0xe0,0xf0,0xf8,0xfc,0xfe,0xff}

and only `0xff` -- eight voices -- has bit 0 set. Every board measurement
tonight used `0xe0`, three voices. The shipping build additionally carries
`S3L_VOICE_LO=5`, so voice 0 is not even in core 0's range.

**2. Voice 0 at rest makes the shared prologue quit before the LFO.**

    eb_render.c:79-85
      sh->lfo_del = sh->lfo_und = sh->lfo_pul = 0.0f;
      ...
      sh->v0_atrest = e->v[0].atrest ? 1 : 0;
      if (sh->v0_atrest) { sh->ready = 1; return; }

It returns with `ready = 1` and the three LFO outputs left at zero.

**3. The voice loop then believes it.**

    eb_render.c:491-493
      if (sh && sh->ready) { lfo_del = sh->lfo_del; ... }

`ready` is set, so every voice takes the published value, which is 0.

**4. And the allocator makes voice 0 the LAST voice ever assigned.**

    eb_alloc.c:99   for (w = NV - 1; w >= 0; --w)  /* TOP-DOWN -- load-bearing */

So under `EB_LFO_SHARED=1` the instrument has an LFO only at FULL EIGHT-NOTE
POLYPHONY. At one to seven notes there is no vibrato, no PWM sweep, no filter
modulation, anywhere, on any voice.

## ⚠ WHY NO GATE COULD EVER HAVE CAUGHT IT

    engine_b/shim/standalone/juno_driver.c:337
      for (v = 0; v < JUNO_NUM_VOICES; ++v) EBE.v[v].atrest = 0;

**The gate's own shim holds every voice awake.** Its comment says why, and the
repo already knew half of this: it keeps "the at-rest shortcut -- an UNGATED
claim that a resting voice's output is exactly 0 -- out of the measurement".

What nobody connected is the other half: under `EB_LFO_SHARED` the at-rest
shortcut does not merely silence ONE resting voice, **it silences the LFO for
the WHOLE INSTRUMENT.** The certified fork and the shipping firmware differ in
exactly the flag that decides whether the LFO exists, so the 3.17 dB sonic
gate certifies an instrument the board has never run.

Re-run tonight to be sure it is not a regression: the gate still reads worst
band **3.17 dB**, its recorded control value. The gate is not broken. It is
blind, by construction, in the one place that mattered.

## What this does to every number measured tonight

**Every cycle figure on this board was taken with the LFO not running.** The
117-cycle "prologue" is the noise LFSR plus an early return. The real prologue
carries `eb_cvgate`, `eb_glide_tick` and `eb_lfo_tick`, and none of it has ever
executed on silicon.

    chip B, measured   5,440 against 5,442   <- LFO-FREE
    the LFO's cost     UNMEASURED

An estimate of ~1,480 cycles/sample exists from the workflow. It is a static
instruction count times a c/i borrowed from different code, and its own
components are wrong in both directions (one of the two `expf` sites is
memoised; the `fmodf` slow arm is measured at 9.75 %, not 100 %). **Do not
plan against it.** Six of seven estimates in this project were optimistic.

## The fix direction, not yet built

The port runs every voice's LFO every sample, free-running, whether or not the
voice sounds -- that is what makes the phases identical across voices, which is
the fact `EB_LFO_SHARED` was built on. The fork must therefore tick the shared
LFO UNCONDITIONALLY in the prologue, independent of voice 0's at-rest state,
and voice 0's cvgate/glide inputs to it must come from somewhere valid when
voice 0 is silent.

That is a real change to the fork's arithmetic and it needs its own sonic gate
run before any cycle number is quoted.

## The two rules this earns

1. **A flag that changes what the DEVICE does must be exercised BY THE GATE at
   the device's own setting.** `atrest` is set from a wake mask on the device
   and forced to 0 in the gate. Any such flag is a blind spot by construction.
2. **A shortcut justified per-voice must be re-justified when something SHARED
   depends on that voice.** The at-rest claim was "a resting voice outputs 0",
   which is true and was never the whole story once one voice owned the LFO.

# THE FIX IS IN AND BOTH GATES ARE NEUTRAL (2026-08-11)

`EB_LFO_FREERUN`, defaulting to `EB_LFO_SHARED`, runs voice 0's
cvgate/glide/LFO chain whether or not voice 0 sounds.

    trunk null gate (--module standalone)   VERDICT: PASS, residual EXACTLY 0
    fork sonic gate (lastmile_run.sh)       3.17 dB, the SAME 12 rows as the
                                            recorded control

**Both are unchanged, and that was the prediction, not a relief.** The gate's
shim holds every voice awake, so `sh->v0_atrest` is 0 in every gated run and
the branch removed here never executed under test. Identical code, identical
order, identical arithmetic, for every input either gate has ever presented.

The gates being unable to move is the same fact as the gates being unable to
catch the bug. A neutral gate result here CONFIRMS the blind spot rather than
clearing it.

Verified at the firmware's own flag set rather than assumed:

    AT THE FIRMWARE'S OWN FLAGS: SHARED=1 FREERUN=1
    trunk build:                 SHARED=0 FREERUN=0

`juno_s3_LFO.bin` is the first firmware in this project that has an LFO.

## What is NOT known

**The cost.** Every cycle figure in this repository was taken with the LFO
absent, including chip B's 5,440 against 5,442. That number is real for the
program that produced it, and that program is not the instrument.

An estimate exists and is deliberately not repeated here: it is a static
instruction count times a cycles-per-instruction ratio borrowed from different
code, and its own components are wrong in both directions. Six of seven
estimates in this project flattered themselves.

One flash replaces every cycle figure in the repo with one that describes the
actual instrument.

# ★ THE LFO COSTS 600 CYCLES, MEASURED (2026-08-11)

    OWN3C (no LFO)   whole loop 5,440
    LFO              whole loop 6,040
    the LFO                       600 cycles/sample

    vs budget 5,442 : OVER by 598 = 1.110x
    drift +113 ms/s = 11.3 % behind; 6,040/5,442 = 11.0 % -- the two agree

**This is the first cycle figure in this project that describes the actual
instrument.** Every number before it was taken with the modulation absent.

## The estimate was 2.5x HIGH, and that is new

The workflow's static estimate was ~1,480 cycles. The board says 600. **This is
the FIRST estimate in this project to be pessimistic rather than optimistic** --
the running record was six of seven flattering themselves.

Worth recording why, because it is the opposite failure and has its own lesson:
the estimate charged four `expf` calls where `eb_lfo.c` has two and one of them
is memoised, and it charged two full `fmodf` bodies against a slow arm CLAUDE.md
records as MEASURED at 9.75 % of calls. Both errors are of the same kind as the
optimistic ones -- **pricing code that was not read** -- they simply happened to
point the other way this time. The direction of an estimate's error is not a
property of the estimator's temperament; it is a property of not measuring.

## Where chip B now stands

    chip B, 3 voices + FX, WITH the LFO   6,040 against 5,442, over by 598

The 696-cycle gap that `S3L_VOICE_LO` closed has been replaced by a 598-cycle
gap that is real work the instrument must do. The difference is that this one
buys something: the synth modulates.

## What has NOT been confirmed

**That it sounds different.** A correctness fix which changes no audible
behaviour has fixed nothing, and the log cannot show that. The listening check
is outstanding and it outranks the cycle number.

# THE FIX IS PROVEN AT THE LFO, AND SILENT ON THIS PATCH (2026-08-11)

The user's correction was right: I asked them to listen instead of measuring.
`tools/engineb/device_sonic.c` now does the measuring, under the DEVICE's own
wake masks -- the configuration no gate in this repo can adopt.

    EB_LFO_FREERUN=0        lfo_del  lfo_und  lfo_pul   residual
      chord 1  wake 0x80     0.0000   0.0000   0.0000   --
      chord 8  wake 0xff     0.0000   1.9962   2.0000   --

    EB_LFO_FREERUN=1
      chord 1  wake 0x80     0.0000   1.9962   2.0000   EXACTLY 0
      chord 8  wake 0xff     0.0000   1.9962   2.0000   EXACTLY 0

**THE DEFECT AND THE FIX ARE BOTH PROVEN.** Before: a one-note chord had an
LFO span of ZERO on every output; the eight-note chord had the full swing. The
LFO existed only at full polyphony, exactly as claimed. After: every chord has
the eight-note swing.

**AND THE AUDIO IS EXACTLY 0 ON THIS PATCH, which is also correct.** The blob
carries ONE patch and that patch routes no LFO to audio. The modulation now
runs and reaches nothing. Both facts are true and neither weakens the other.

Consequences, stated so nobody has to re-derive them:
- The 600-cycle cost measured on the board is REAL -- the chain executes.
- The audible benefit CANNOT be shown on this blob and has not been shown.
  Demonstrating it needs a blob regenerated from an LFO-routed patch, which is
  one `gen_listen_coefs.py <patch>` run away and has not been done.

## ⚠ MY FIRST PROBE WAS BLIND, IN THE SAME WAY AS THE BUG

The first version watched only `eb_lfo_tick`'s RETURN value, the DELAYED
output. It read 0.0000 even with voice 0 awake, which looks exactly like "the
LFO does nothing" and was actually "you are watching the wrong wire":
`eb_lfo.c` records `k2096 == 0, k2112 == 0` for this patch, so the delayed path
carries nothing by construction. The modulation is on the other two outputs.

I built a measurement that could not see its subject, while hunting a bug whose
whole nature is a measurement that could not see its subject. The tool now
reports all three outputs, and its header says why.

**The rule: when an output reads exactly zero, prove the wire is connected
before concluding the source is dead.**
