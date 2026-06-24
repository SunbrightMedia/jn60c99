# OPEN: the pitch drift / vibrato — reopened as a live DSP concern

**Status: UNRESOLVED.** An earlier pass concluded this was "faithful, not a bug"
on the strength of FFT pitch-tracking that matched a warmed-up reference. That
conclusion is **withdrawn.** The user — who can hear detail the crude pitch-tracker
cannot isolate — reports a persistent "weird pitch drift" on every render and
believes it "might be part of a bigger issue" in the DSP, not just a patch LFO
depth. Per their explicit direction, **this is not to be judged by WAV/FFT
matching against a reference render.** It is chased through the code.

## What we think we know (to be re-verified against the decompile, not audio)

Two contributors were previously identified; both need re-examination as code, not
as spectra:

1. **Patch LFO→pitch** (voice-state offset 4032): the dry voice wobbles even with
   master/chorus bypassed. Patch-dependent (depends on the preset's LFO depth).
   This is *expected* modulation — but verify the LFO rate, depth scaling, and
   delay/ramp are transcribed correctly, and that the depth the apply engine
   writes to 4032 matches the preset's real step value.
2. **Chorus stereo modulation** (`sub_180363380` = `src/master_render.c`): the 3
   chorus LFO stages have their own phase state (`6395600`, `10692304`, `6429760`)
   and distinct rates. Hex-Rays dropped the phase-increment block for stages 2 & 3;
   it was reconstructed from asm (`docs/MASTER_RENDER_MAP.md`). **Re-audit that
   reconstruction** — a wrong increment, a wrong initial phase, or a sign error
   here would produce exactly a slow, wrong pitch drift that survives bypassing the
   patch LFO.

## Why the old "not a bug" verdict was unsafe

- It leaned on a single warmed-up reference and FFT correlation — exactly the
  audio-matching the user has ruled out as the arbiter.
- It dismissed the L/R depth asymmetry (R ≈ 3× L) as "inconclusive / possibly an
  FFT artifact." That asymmetry is now a **lead**, not noise: an anti-phase stereo
  BBD chorus should cancel pitch-mod in the mono sum; ours does not. If the three
  LFO phase offsets / increments are wrong, the channels won't sit anti-phase and
  the mod won't cancel — heard as vibrato/drift instead of width.

## Finding 1 (DONE): the chorus LFO phase math is faithful — RULED OUT

Re-derived all three chorus LFO phase accumulators directly from the disassembly
(`master_deps/master_sub_180363380_180363380.asm`) and diffed against
`src/master_render.c`:
- **Stage 1** (fully rendered by Hex-Rays) matches the decompile verbatim:
  `incr = clamp(pitch,±512)·rate`; `±2/±4` reduction; `==0 → fallback`;
  `phase += incr`; `if(phase>1) phase = fmodf(phase+1,2)−1`; store
  `phase·scale + (scale−1)`.
- **Stages 2 & 3** (increment block dropped by Hex-Rays, reconstructed from asm)
  are byte-faithful to the disassembly. Verified the stage-2 block instruction by
  instruction at `0x180363EC7–F47`: the `±2/±4` reduction is `+(-4.0)` when
  `≥4.0` else `+(-2.0)` when `≥2.0` (consts `dword_180AE5510=-4`,
  `dword_180AE54F8=-2`) — identical to the C. `juno_wrap_hi(x)` is exactly stage
  1's inline `if(x>1) fmodf(x+1,2)−1`. Every offset = stage-1 offset − 6395376 +
  stage base (consistent across all three).

**Conclusion: the chorus LFO *code* is not the drift source.** The drift must come
from the *values* feeding these LFOs (the runtime-applied **rate** `JF(…+272)`,
**depth/scale**, and the LFO→delay-time mapping), or from the voice's own
LFO→DCO-pitch path (offset 4032), or BBD read-pointer interpolation. The rate/depth
coefficients arrive through the parameter-apply path, so the investigation now
moves into the runtime translation (below).

## Remaining plan (code-first, no reference renders)
2. **Trace the LFO→pitch path** (offset 4032) from the apply engine: confirm the
   rate/depth/ramp coefficients written there match the decompiled LFO and the
   preset's real step values — i.e. that the drift magnitude is what the patch
   actually specifies, not an apply bug.
3. **Check the BBD read-pointer interpolation** in the delay lines: pitch drift in
   a BBD chorus is produced by the modulated fractional read pointer; a wrong
   interpolation or clock-rate scaling there bends pitch directly.
4. Only if all three are confirmed faithful do we treat the residual as genuine
   plugin behavior — and even then, report it as "matches the code," not "matches
   a render."

This investigation is folded into the runtime-translation phase (the DB→engine
param bridge), since the LFO depth that lands at offset 4032 comes through exactly
that path.
