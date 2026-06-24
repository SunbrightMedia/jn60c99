# Port status

Current, honest accounting of the C99 JUNO-60 port. The whole VST3 is decompiled
in-repo (`refs/allcode_decomp.tgz` + `refs/manifest.tsv`), so every value is
derivable from the binary — there is no remaining dependency on live captures or
reference renders as a *source* (a couple of captures survive only as validation
oracles, noted below).

## What "done" means here

Two different bars, kept strictly separate:

- **Data layer — bit-exact and proven.** Identical IEEE-754 uint32 bit patterns
  vs the binary. Init: 2289/2289 `engine_init` stores. Param apply: the LUT
  mechanism (`sub_356380`) is 88/88 exact LUT members; FX-coefficient setup is
  69/69 exact. The 66 denormalize LUTs are transcribed as raw float32 bit
  patterns (`src/juno_param_luts.c`).
- **Audio DSP — transcribed, NOT numerically verified.** The voice render,
  master/chorus, and FX graph are faithful line-by-line transcriptions of the
  decompile, but no per-sample A/B against the plugin has been run, so "sounds
  identical" is not claimed. Renders are musically in the ballpark, not proven.

## Transcribed from the decompile (compiling, in `src/`)

| Piece | Source fn | File |
|-------|-----------|------|
| Voice render (DCO, 4-pole VCF, ADSR×2, VCA, unison) | `sub_180369070` | `src/voice_render.c` |
| Master mix + stereo BBD chorus + output | `sub_180363380` | `src/master_render.c` |
| Coefficient init (2289 stores, SR-aware) | `sub_1803990C0` | `src/*engine_init*` |
| Chorus constructor (BBD delay lengths, ring state) | `sub_1803A1300` | `src/chorus_init.c` |
| Leaf helpers (wrap24, triangle, poly pitch) | 0x368D60/0x368FC0 | `src/juno_dsp.c` |
| Param→coeff apply engine (LUT + switch) | `sub_356380` | `src/juno_params.c` |
| 66 denormalize LUTs (raw bit patterns) | `.rdata` tables | `src/juno_param_luts.c` |
| FX-coefficient setup (reverb/delay/chorus) | FX setup fns | (`refs/fx_coeff_recipe.json`) |
| Driver / per-sample loop | `sub_180398EC0` | `src/juno_driver.c` |

Polyphony: all 8 voice renders are voice 0's code at verified region strides
(main +10512, shared +0, aux +32); one parameterised render serves all 8, voice 0
bit-identical (`docs/POLYPHONY.md`).

## FX architecture (resolved)

The reverb and delay are **not** standalone DSP functions — they are sub-graphs of
`CJu60Sim`, a JUNO-60 circuit/signal-graph simulator (vtable @0x98AE98, ~10.7 MB
per-instance workspace), evaluated by large unrolled solver methods. Their setup
emits define-tap + coefficient-bind calls from recovered tables
(`refs/reverb_tables.json`, `refs/delay_tables.json`). Full detail and the two
faithful-vs-approximate transcription paths are in `docs/FX_ARCHITECTURE.md`.

## Preset path

The `KoaBankFile00003`/`PG-JU60` bank format is decoded
(`docs/PRESET_BANK_FORMAT.md`), proven by the 16-byte name anchor. Per-parameter
**steps** are recovered for real patches. The one statically-unavailable link is
the **DB-index ↔ engine-coefficient bridge**, which the plugin builds at runtime
as a red-black tree (`sub_3C7AE0`) — not statically reconstructable, so it is the
subject of the next phase (runtime translation; `docs/DB_ENGINE_BRIDGE.md`).

## Open / unverified

1. **Audio numerical validation** — no per-sample A/B has confirmed the DSP is
   bit-faithful; this is the real definition of "correct" and is still at 0%.
2. **Pitch drift / vibrato** — the user hears a pitch drift on sustained renders
   that may indicate a DSP issue, not just a patch LFO depth. Reopened as a live
   concern (`docs/CHORUS_VIBRATO_DIAG.md`); to be chased through the runtime
   translation, NOT via WAV matching.
3. **DB→engine continuous-param bridge** — runtime-built; the next work item.
4. **FX per-sample solver fidelity** — the CJu60Sim tank solvers (one of which
   Hex-Rays could not lift) are mapped but not yet transcribed to C.

## Validation oracles still in repo (not sources)

- `state_dump/*.bin.gz` — live-plugin memory snapshot; backs the 2289/2289 init
  bit-exact proof.
- `src/runtime_coeffs_data.c` — captured PD-Juno-Pad coefficient set; used only to
  cross-check the apply engine, never compiled in as the port's value source.
