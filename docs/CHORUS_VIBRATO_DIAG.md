# The pitch drift / vibrato — isolated to the (correctly-enabled) chorus

**Status: ISOLATED, pending one external check.** Single-note measurement (Finding
3, bottom) shows the voice is dead-stable pre-chorus and all drift is the chorus —
which the SQ ARPG patch itself enables (JUNO CH1) and which runs on recipe-exact
coefficients. The remaining question is whether the user's correct reference shows
the same authentic Chorus I wobble. History below is kept for the audit trail.

An earlier pass concluded this was "faithful, not a bug"
on the strength of FFT pitch-tracking that matched a warmed-up reference. That
conclusion was **withdrawn** then re-established on firmer (code + recipe) ground —
see Finding 3. The user — who can hear detail the crude pitch-tracker
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

**Conclusion: the chorus LFO *code* is not the drift source.**

## Finding 2 (DONE): the voice LFO→pitch path is faithful — RULED OUT

The voice's own LFO→DCO-pitch is the most direct pitch modulator. Compared
`src/voice_render.c` against the decompile (`sub_180369070`) for two regions:
- **LFO oscillator / rate+envelope** (decompile 28570–28591 ↔ `voice_render.c`
  756–777): verbatim identical — `v68=(v59−v65)·JF(1152)+v65`, `v69=JF(1088)` (LFO
  Rate), `v70=v68·JF(1040)−JF(1040)·v69+v69`, clamp, `expf(...)`, etc.
- **LFO→pitch application** (decompile 28858–28885 ↔ `voice_render.c` 1044–1071):
  verbatim identical — `v176 = JF(1792)·JF(4016)` (LFO sig · **LFO Gain**),
  `v180 = v176·JF(4032)` (· **LFO Level/depth**), summed into the DCO pitch
  accumulator at 3776.

**The LFO DSP code (chorus + voice) is verified faithful.** The pitch drift is
therefore governed by the **coefficient values** at the LFO offsets — JUNO voice
LFO params, all statically located in the registry (`docs/PARAM_MAP.tsv`):

| param | pid | offset | tableId |
|---|---|---|---|
| LFO Rate | 11 | 1088 | 22 |
| LFO Delay | 16 | 1920 | 44 |
| LFO Gain | 54 | 4016 | — |
| **LFO Level (→pitch depth)** | 55 | 4032 | 0 |

For **SQ Dynamic ARPG** these are currently **UNMAPPED** (`db_engine_bridge.json →
db_engine_unmapped`): the render leaves whatever the PD-Juno-Pad capture / init put
in those offsets, so the vibrato is literally *another patch's* LFO settings. This
matches the user's hope ("really hoping that has to do with the preset PARAMETERS
and not the actual DSP code"): it is the parameters, not the DSP.

## The fix path: bind the LFO (and other continuous) params DB→engine

The blocker is the **DB-index → engine-offset** binding for continuous params
(generic `0..255` specs that don't self-identify). The decisive static key would be
the **VST3-ParamID ↔ engine-offset** join (the red-black tree seed gives
VST3-ParamID ↔ DB-index by the formula `key = 0x60000A + 2·(db−755)`; the registry
gives registry-paramID ↔ offset). Recovering that join makes the whole bridge —
including LFO rate/depth — exact. This is the runtime-translation work tracked
separately.

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

## Finding 3 (current): single-note isolation — drift is the chorus, and the chorus is correctly enabled

Per the user's "play one note at a time" request, isolated the pitch on a single
sustained C4 by tapping the voice signal *before* the chorus (state offset 10672)
and the final output *after* it. Tools: `tests/measure_chorus_lfo.c` (dumps the
chorus LFO state and measures its period from the modulator) and
`tests/measure_pitch_drift.c` (quadrature-demod pitch tracker, 4-pole 30 Hz LP,
FFT of the cents signal).

Measured (96 kHz, SQ ARPG coeffs, chorus mode 2 = JUNO Chorus I):

| signal | mean | peak-to-peak | dominant mod |
|---|---|---|---|
| **pre-chorus voice** (off 10672) | −0.3c | **3.0c** | — (stable) |
| **post-chorus final** | −0.25c | **35.6c** | **2.86 Hz** (FFT) |

So the DCO/VCF/envelope path is rock-stable and in tune — the voice LFO→pitch depth
at 4032 is *not* producing audible drift in this render (Finding 2's worry doesn't
bite here). **All pitch movement is introduced by the chorus.** Mean is stable —
it's a periodic wobble, not a DC slide.

Three checks confirm the chorus is *supposed* to be on and is running on the right
numbers — i.e. the wobble is the genuine JUNO Chorus I vibrato, not an apply bug:

1. **The patch asks for it.** SQ Dynamic ARPG's engine data sets `chorus_mode =
   2 = JUNO CH1` (HIGH confidence — `sqarpg_engine_steps.json → driver_fx.873`,
   `audible_summary.chorus_db873 = "JUNO CH1"`). The render is not adding chorus
   that shouldn't be there.
2. **The coefficients are recipe-exact.** Loaded Chorus CV (6395312) = −5.32549 and
   depth (6395328) = 1.0 are bit-identical to `fx_coeff_recipe.json` ("CHO Chorus
   CV", formula). The SR-aware rate scale (6395648) loads as 0.00917 at 96 kHz, and
   the chorus *mix* LFO (6395680) measures **0.41 Hz** — the authentic Chorus I LFO
   rate. Nothing generic/PD-specific is leaking into the chorus.
3. **The DSP is verbatim.** The BBD delay read (`v294 = (int)(v293·−16384)`, swept
   by the filtered modulator through the all-pass/comb network, `master_render.c`
   ~1358) is line-for-line `sub_180363380`. The ~2.86 Hz pitch component (vs the
   0.41 Hz mix LFO) is the all-pass/comb network's own behaviour, produced by the
   original binary by construction.

**Corrected verdict:** the "weird pitch drift" is the faithful JUNO-60 Chorus I
pitch wobble (±~18c, recipe-correct depth/rate). The earlier guess that it ran on a
"too-deep generic depth" is withdrawn — the depth is the recipe value 1.0.

**Sole remaining open item (needs the user's reference, not more code):** does the
known-correct SQ ARPG render carry this same slow chorus wobble? If yes → match,
nothing to fix. If the reference is wobble-free → the real Chorus I is subtler than
the faithful transcription yields, and the next lead is the BBD delay-sweep
*magnitude* (the `−16384` fractional-index scaling and the delay-line clock), not
the LFO. A/B stimuli for that call: `note_chorusON.wav` vs `note_dry.wav`.
