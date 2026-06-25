# Polyphony — voices 1–7 from voice 0, verified exact

The plugin compiled **8 specialised voice-render functions** (sub_180369070 = voice
0, sub_18036CE00, sub_180370B90, sub_180374900, sub_180378690, sub_18037C420,
sub_180380190, sub_180383F20 = voices 1–7). Rather than transcribe seven near-
duplicates, we proved they are the *same* code with shifted offsets and parameterised
the one transcription.

## Proof (tools cross-checked all 8 decompiles)
Each voice function references the same **1222 state offsets in the same order** as
voice 0. Diffing voice v against voice 0, every offset shifts by one of three
region strides:

| region | offsets | stride | example |
|---|---|---|---|
| main voice block | 610 (range [176, 10672]) | **+10512·v** | 320 → 10832 (v1) |
| shared/global block | 11 ([84000,90000)) | **+0** | 84272 → 84272 |
| aux slot | 1 (101504) | **+32·v** | 101504 → 101536 |

The only per-position differences were Hex-Rays emitting **commutative operands in
swapped order** (e.g. v0 `{2096,2112}` ↔ v2 `{23120,23136}` = both +21024) — the
offset *sets* match exactly. A range-classifier (`juno_voff`) reproduces **all 622
unique offsets for all 8 voices with zero mismatches**.

## Implementation
- `juno_voff(off, v)` (juno_engine.h) applies the verified region rule;
  `juno_voff(off,0) == off`.
- `voice_render.c` redefines its `JF/JI/JU` accessors through `juno_voff(off,_v)`,
  so `juno_voice_render_v(st,l,r,v)` renders voice v. `juno_voice_render(st,l,r)` is
  the `v=0` wrapper — **voice 0 stays bit-identical** (confirmed: `make validate`
  still reports 0 stable gaps).
- The driver renders all 8 voices; the master sums them.
- Per-voice patch coefficients (captured from voice 0) are **broadcast to all 8
  voices** in `juno_runtime_coeffs_apply` (the main-block fields [176,10672] only;
  globals written once) — the plugin's parameter system does the same. Without it
  only voice 0 would sound.

## Status
True 8-voice polyphony, each voice exact. `tests/play_chord.c` (`make chord`)
renders a C–G–Am–F progression; `juno_note_on(st, voice, midi_note)` plays a note on
any voice. Voice allocation (which physical voice a new note takes) is a host-layer
policy; the driver currently assigns voices explicitly.

## Correction: the M.CV pitch-base bug (chords only played the root)

The "True 8-voice polyphony" claim above was premature — voices 1-7 produced sound
but at the WRONG PITCH, so chords collapsed to the root. Root cause:

- **Offset 304 ("M.CV") is the per-voice pitch BASE**, and it sits **16 bytes BELOW**
  each voice's main block (voice 0 at 304, voice 1 at 10816, voice 2 at 21328 = each
  voice's block-start − 16). `voice_render` reads it via `juno_voff(304,v)=304+10512*v`.
- The parameter broadcast copies voice-0 params across voices at `+10512`. Offset
  10816 is *also* listed as a voice-0 param ("M.CV") in `PARAM_MAP.tsv`, so the
  broadcast writes that param value into **voice 1's pitch-base slot (10816)** — and
  likewise for voices 2-7. Result: voices 1-7's pitch base is overwritten with the
  wrong value (~2.0 instead of the patch base ~6.67). Only voice 0 was correct,
  because the capture seeded its M.CV directly.
- Proven by tracing the pitch path (`4448` note + `3776` mod; `3776 ← 752 ← M.CV/304`):
  with the same note, voice 0 M.CV=6.668 vs voices 1-7=2.000. Copying voice 0's M.CV
  to all voices restored a full C-E-G triad.

**Fix** (`src/juno_driver.c`, `juno_note_on`): re-seat each played voice's M.CV
(`304 + v*10512`) from voice 0's base, after the broadcast. Verified: full triad via
the normal `note_on` path; smoke tests green. Chords now play correctly.
