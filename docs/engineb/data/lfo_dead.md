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
