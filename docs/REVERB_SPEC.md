# JUNO-60 Reverb (CDSPRev) — recovered specification

The reverb is a **Griesinger/Dattorro-style plate**, realized as a node graph inside
the shared `CJu60Sim` engine (per-sample solver = `sub_1803990C0`, slot 10). `CDSPRev`
itself only *configures* the graph (define-tap + set-coefficient calls). All defining
constants live in `.rdata` and are now extracted verbatim to `refs/reverb_tables.json`.

## Constant tables (image base 0x7FF91DC60000)
- **Tap lengths** `0x63A350` (rva 0x9DA350): 20 delay lines × 3 columns. The 3 columns are
  sample-rate variants (col scales ≈ ×1 / ×3 / ×7.8); the SR-config table picks one
  (engine sample rate is set to 96000 in the ctor). Rows 0–7 are the short
  input/early diffusers; rows 8–19 are the long tank lines.
- **Allpass diffuser gains** `0x639F20` (rva 0x9D9F20): row 0 = identity `(1,0,0)`;
  rows 1–14 = `(g, −g, c)` with g decreasing 0.99858 → 0.97229. This is the diffusion
  schedule (14 allpass stages — matches `CDSPRev+44 = 14`).
- **Damping biquads** `0x63A130` (rva 0x9DA130): groups of 5 `(b0,b1,b2,a1,a2)`,
  each a **unity-DC lowpass** (verified DC gain = 1.000 for all rows; b0=b2, b1=2·b0).
  Cutoff opens up down the table (b0 0.0004→0.021, a1 1.94→1.55) — the HF-damping
  schedule indexed by the decay/tone parameter.
- **SR config** `0x63A600` (rva 0x9DA600): per-sample-rate rows (stride 64 B) that select
  the tap column and base index.

## Signal flow (standard plate, constrained by the tables)
1. Input → series **allpass diffusers** (short taps, gains from 0x639F20) — smears the input.
2. **Tank**: the long delay lines (0x63A350 rows 8–19) in a feedback loop; each line has an
   embedded **damping biquad** (0x63A130) and a feedback gain set by the decay param.
3. Output taps are summed (stereo) from fixed points in the tank.

## Status / fidelity
- **Recovered exactly:** all delay lengths, all allpass gains, all damping-filter
  coefficients, and the stage counts — the full parameter set of the reverb.
- **Not yet pinned:** the exact tank interconnection / feedback routing and output-tap
  picks, which live inside the 33 KB unrolled SSE solver (`sub_1803990C0`). The triple
  grouping + classic plate structure constrain it heavily; a faithful implementation can
  be built on these real coefficients with the standard plate routing, then refined by
  reading the solver's reverb-state section (state offset ≈ +0xA83000).
