# Polyphony — deriving the per-voice state layout from the binary

The goal is bit-exact, so voices 1–7 may not be a guessed offset shift. This
documents how the per-voice state layout was **derived from the plugin binary**
(no guessing), and how `voice_render` is parameterised to serve all 8 voices from
one exact transcription.

## The 8 specialised voice functions

The plugin compiled **8 copies** of the voice render, one per voice, evenly
spaced in the image:

| voice | function | rva |
|------:|----------|-----|
| 0 | `sub_7FF91DFC9070` | 0x369070 |
| 1 | `sub_7FF91DFCCE00` | 0x36CE00 |
| 2 | `sub_7FF91DFD0B90` | 0x370B90 |
| 3 | `sub_7FF91DFD4900` | 0x374900 |
| 4 | `sub_7FF91DFD8690` | 0x378690 |
| 5 | `sub_7FF91DFDC420` | 0x37C420 |
| 6 | `sub_7FF91DFE0190` | 0x380190 |
| 7 | `sub_7FF91DFE3F20` | 0x383F20 |

All are ~0x3D8C bytes and structurally identical (`src/voice_render.c` is the
exact transcription of voice 0).

## The derivation — diff the offset constants

Each copy references the engine state through absolute offsets `a1 + N`. Diffing
voice 0's ordered list of offset constants against voice 1's (and cross-checking
voices 2 and 7) shows **every one of the 1222 references** falls into exactly one
of three regions, each with a single constant stride:

| region | voice-0 offsets | stride (v1 − v0) | v2 | v7 | count |
|--------|-----------------|------------------|----|----|------:|
| **main** (per-voice) | 176 … 10672 | **10512** | 21024 (2×) | 73584 (7×) | 1204 |
| **shared** (global) | 84272 … 84432 | **0** | 0 | 0 | 15 |
| **aux** (one-shot edge) | 101504 | **32** | 64 (2×) | 224 (7×) | 3 |

So voice *v* reads its per-voice state at `+v*10512`, the shared block at the same
address as every other voice, and the aux edge at `+v*32`. The strides are the
**measured** differences between the compiled functions, not an assumption.

Two independent confirmations that the layout is exactly this:

1. **Perfect tiling.** The 8 main blocks tile the space up to the shared region
   with no overlap: `176 + 8*10512 == 84272`, the first shared offset.
2. **Bit-exact self-consistency** (`tests/test_poly_consistency.c`). Rendering
   each voice *in isolation* with the same note in its own region produces output
   **bit-identical to voice 0**, sample for sample (4096/4096). Any mis-classified
   offset (a per-voice slot left unshifted, or a shared slot shifted) would make
   the voices diverge; none do.

## The parameterisation

`juno_voice_render(base, voice, outL, outR)` sets `a1 = base + voice*10512`. The
1204 main references (`JF(a1, N)`) then auto-resolve to the voice's own block. The
18 non-main sites are edited to use `base` directly:

- the **15 shared** sites use `JF(base, 84xxx)` — unshifted, so all voices read the
  block at the same offset. **Correction (end-to-end A/B):** the block `[84272,84436)`
  is a self-contained analog-noise/LFSR generator, and the plugin does NOT chain it
  across 8 sequential voice calls — it runs 8 *isolated* engine units (BUILD
  `sub_7FF91E0268D0` allocates 9× `operator new(0xA83010)`), each stepping its OWN copy
  once/sample in lockstep. So all voices must read the SAME one-step advance, not a
  chained 8-step run. `juno_driver_render_voices` snapshots the block and restores it
  before each voice to reproduce that; the earlier "chains across voices" claim was
  wrong and made the noise step 8× too fast. (This does not affect the offset
  classification below — the block is still at the shared offset; only its per-sample
  stepping cardinality changed.)
- the **3 aux** sites use `JF(base, 101504 + voice*32)`.

`voice == 0` gives `a1 == base`, so voice 0 is bit-identical to the original
function and the existing smoke/golden tests are unchanged.

## Coefficients and rendering

- `juno_bank_apply` writes the patch coefficients into voice 0's block only, so
  `juno_driver_seed_voices` replicates voice 0's block `[176, 84272)` to voices
  1–7 after apply (the blocks tile exactly, so this is a clean memcpy per voice).
  Global coefficients (≥ 84272, e.g. VCA level at 101072) are single and stay put.
- The driver renders all 8 voices **in order 0..7 every sample** so the shared
  block chains as in the plugin, then feeds the 8 samples to `master_render`.
- The bridge adds an 8-voice allocator (free-voice, else oldest-steal) so held
  chords sound with real voices.

## What this is and isn't

This makes the port **polyphonic and faithful** — a JUNO plays chords, and each
voice is the exact voice-0 DSP on its own state. It is **not** a new
approximation: the region strides are read from the compiled binary and the
self-consistency test proves the classification bit-for-bit.
