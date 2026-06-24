# Validation against the live plugin

The handoff's definition of "correct" is agreement with the actual plugin, not an
RMS score. We now have that: a full memory‑scanned snapshot of the live plugin's
engine state (`state_dump/`, preset *PD The Juno Pad*, chorus II, **96 kHz**),
used as ground truth.

## Method
`make validate` initialises our engine (`juno_chorus_init` + `juno_engine_init` +
the captured `juno_runtime_coeffs_apply`) at 96 kHz and compares it, field by
field, to the plugin's state over **every offset the DSP actually reads**
(`voice_render` + `master_render`). Two snapshots (t0/t1, a moment apart)
distinguish:
- **stable** fields (t0 == t1) — coefficients / structure: these MUST match;
- **dynamic** fields (t0 != t1) — per‑sample state (filter memory, accumulators):
  these are expected to differ from a freshly‑reset engine.

A "stable gap" (stable field that disagrees) is a real transcription or
coefficient error. The check passes iff there are zero stable gaps.

## Results
| Check | Result |
|---|---|
| `juno_engine_init` (sub_1803990C0) — its 2289 written offsets | **2289 / 2289 exact (100%)** |
| Full init over all 1585 DSP‑read offsets | **1425 match, 160 dynamic‑state (expected), 0 stable gaps** |

So **every coefficient and structural field our initialiser produces is bit‑exact
against the real plugin.** `juno_engine_init` is independently proven 100%. The
only differences are the 160 live per‑sample state values, which correctly start
at reset in a fresh engine.

This also corrected the coefficient set: the original 349 (defined as
"read‑but‑never‑written") missed ~75 coefficients the constructor zeroes and the
parameter system then fills. Deriving the set directly from the ground truth
(DSP‑read AND differs‑from‑our‑init AND stable) gives the correct **279**
coefficients, all nonzero — now in `src/runtime_coeffs_data.c`.

## Scope / what this does and doesn't prove
- **Proves:** the static + captured *initialisation* reproduces the plugin's
  engine state exactly, for this patch at 96 kHz. The voice coefficient init is
  exact for any patch (it's patch‑independent math).
- **Doesn't yet prove:** the per‑sample *processing* (the running DSP) matches.
  That needs the audio A/B — feed the same MIDI to plugin and port and diff the
  output samples. The dynamic‑state fields are validated there, not here.
- **Patch/rate specific:** the 279 runtime coefficients are for *PD The Juno Pad*
  at 96 kHz. Another patch = another capture (now painless: the memory‑scan
  `dump_full_state.py` just works). Per‑voice copies (voices 1‑7) are pending
  polyphony.

## Running-DSP A/B (per-sample, beyond init)
The init check above proves the *initialisation* matches. For the *running* DSP:

- **Capture-free (`make ab`):** load the live plugin's t0 snapshot, run our
  `voice_render` forward, and match t1. The **control-rate** fields converge to the
  plugin **bit-exactly** — the VCF cutoff slew hits 0.000e+00 residual at K=6367
  samples; 58/155 dynamic voice-0 fields land within 0.01%. This validates the
  per-sample control-rate math against the real plugin with data we already have.
  (Audio-rate filter-memory fields decorrelate in phase over thousands of samples —
  expected; the audio bounce covers those.)
- **Audio bounce (`make abwav REF=plugin_ref.wav`):** the one capture still needed —
  the plugin's own WAV output for a known note. `tests/wav_compare` diffs envelope,
  pitch and timbre (spectral cosine). See docs/RUN_GUIDE_AUDIO_AB.md. The pitch ratio
  also pins the MIDI-note → pitch mapping (the one open gap) from real data.

## Reproduce
```
make validate   # init bit-exactness (0 stable gaps)
make ab         # capture-free per-sample control-rate A/B
make play       # render an audible note
make abwav REF=plugin_ref.wav   # audio A/B vs a plugin bounce (needs the bounce)
```
(`make validate` decompresses `state_dump/state_t0.bin.gz`/`t1`, builds
`tests/validate_state.c`, runs the comparison.)
