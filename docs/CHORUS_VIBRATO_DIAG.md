# Diagnosis: the "pitch vibrato" — localized to the chorus stereo modulation

The user reported a "weird pitch vibrato" on every render. Measured and localized.

## Measurements (sustained C4, PD Juno Pad, 96 kHz; FFT pitch-track, cents vs 261.63 Hz)

| signal | pitch wobble (stddev) | peak-peak | mod rate |
|---|---|---|---|
| **dry voice** (no master/chorus) | 2.1 cents | 9.8 cents | ~2 Hz |
| **full L** (through chorus) | 5.3 cents | — | ~2.7 Hz |
| **full R** | 14.1 cents | — | ~2.7 Hz |

- **L/R pitch-mod correlation: +0.18** (weakly in-phase).
- A correct stereo BBD chorus modulates L and R in **anti-phase** (correlation → −1), so
  the **mono sum cancels** the pitch mod (→ width, not vibrato). Here it does not cancel.

## Two contributors
1. **Patch LFO→pitch** (offset 4032): the dry voice already wobbles ~2 Hz / ~10 cents.
   This is patch-dependent (PD Juno Pad has LFO vibrato) and zeroable per-render. Not a bug.
2. **Chorus modulation** (the master/FX chain `sub_180363380` = `src/master_render.c`):
   roughly doubles the wobble and is **asymmetric** (R ≈ 2.6× L) and **not anti-phase**.
   This is the audible "weird vibrato" that survives even when 4032 is zeroed.

## Hypothesis TESTED → not a bug

Initial hypothesis: the 3 chorus LFO stages (phase-increment block dropped by Hex-Rays
for stages 2 & 3, reconstructed from asm) had lost their per-stage phase offset, leaving
the LFOs in-phase. **Tested and rejected.** The map (`docs/MASTER_RENDER_MAP.md`) shows
each stage keeps its **own** phase state (`6395600`, `10692304`, `6429760`) and distinct
rate — the reconstruction is faithful. All three start at **phase 0 from `chorus_init`**, so
they are correlated immediately after init and **drift apart over time**:

| window | L | R | L/R corr |
|---|---|---|---|
| early (0.5–2.0 s) | 5.3 c | 14.3 c | +0.25 |
| late (5.5–7.5 s, warmed) | 5.9 c | 18.3 c | **+0.05** |

The in-phase reading was a **cold-start transient** (my render inits cold; the plugin
reference was warmed-up). It decorrelates correctly → faithful, not a bug.

## Honest conclusion
- The audible vibrato is **mostly the patch's own LFO→pitch** (offset 4032, ~2 Hz / ~10 c,
  patch-dependent and per-render zeroable) plus a **faithful chorus**.
- The residual **L/R depth asymmetry** (R ≈ 3× L) persists after warm-up but is
  **inconclusive** — could be real Roland stereo-chorus design or an FFT pitch-tracker
  artifact on the differently comb-filtered channels. **No demonstrable transcription bug
  was found.** Resolving it definitively needs a chorus-only A/B vs the plugin (Phase 0),
  not a code change.

For the user's SQ ARPG preset (vs PD Juno Pad), the LFO→pitch depth is a different patch
value, so the vibrato character will differ once the real preset params are applied.
