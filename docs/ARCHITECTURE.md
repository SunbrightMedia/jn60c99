# Cloud 60 DSP architecture (derived from the decompile)

This is the map of the audio engine, reconstructed from the full decompile
(`refs/allcode_decomp.tgz`). It records what each function in the closure *is*, so
transcription doesn't re-derive it. ImageBase `0x180000000`. The decompile is the
spec (see `docs/DATA_PROVENANCE.md`).

## Processing model

The engine is **per-sample**, not block-based. One call to a voice-render
function produces **one stereo sample** for **one voice**, written through an
output pointer pair `{float* L, float* R}`. Blocks and voices are loops *around*
that call.

```
process worker (0x1803C6F00)            ── host/threading plumbing (NOT DSP)
  └ for s in 0..blockSize:
      └ voice dispatch (0x180398F30)    ── switch(voiceIndex) → per-voice render
          ├ voice_render[v] (0x180369070 … 0x180383F20)   ← THE core DSP
          └ prune finished voices (0x1803C24A0 → 0x1803C2E00)
      └ advance L/R output pointers by one float
  └ chorus (0x1803C52E0 + BBD stages)   ── stereo BBD chorus over the block
```

## The 8 voice-render functions are ONE function

`0x180369070, 0x18036CE00, 0x180370B90, 0x180374900, 0x180378690,
0x18037C420, 0x180380190, 0x180383F20` are **byte-for-byte identical logic**.
The only difference is the per-voice base offset baked into each copy
(compiler specialised one routine per voice). Verified by normalising decompiler
temp-var names and diffing: the bodies are identical; only struct offsets shift.

- Main voice-state block stride: **+10512 bytes** per voice
  (voice 0 reads `a1+320`; voice 1 reads `a1+10832`; etc.).
- A secondary per-voice array has stride **+32 bytes**
  (voice 0 `a1+101504`; voice 1 `a1+101536`).

**Implication for the port:** transcribe `voice_render(voice_state*)` **once**
and call it per active voice. Do NOT write eight copies.

## Voice dispatch — `0x180398F30(state, voiceIndex, out)`

- `state+20` (byte): voice-block enable flag — whole body gated on it.
- `state+11022344` (int): per-block **skip counter**. If `>0`, decrement, zero
  the output sample, prune, and return (voice idle this block). If `<=0`, render.
- `**out = 0; *out[1] = 0;` zero the current L/R sample, then `voice_render`
  adds into it. `out` is `{float* L, float* R}` at the current sample position.
- `switch(voiceIndex)` 0–7 selects the matching `voice_render[v]`, then calls the
  pruner `0x1803C24A0`.

## Leaf DSP helpers (transcribed — see `src/juno_dsp.c`)

- **`0x180368D60` → `juno_wrap24(x)`**: wrap to signed 24-bit fixed point —
  `round(x·2²⁴)` with a tie adjustment, mask to 24 bits, sign-extend via bit 24,
  scale by `2⁻²⁴`. The DCO **phase-accumulator wrap**; also inlined at the top of
  `voice_render` (with a negated scale).
- **`0x180368FC0` → `juno_triangle(phase)`**: wrap phase to `[-1,1)`, then
  piecewise map to a **triangle** (`2·p` for `|p|≤0.5`, `2−2·p` above, `−2−2·p`
  below). The JUNO triangle LFO / shaper.

## Voice lifecycle (light, not signal path)

- **`0x1803C24A0`**: walk the active-voice index list `[state+14*8 .. state+15*8]`;
  for each, call `0x1803C2E00` (still-active?) and drop finished voices from the
  list. Voice allocation bookkeeping.
- **`0x1803C2E00`**: per-voice "is still active" predicate (returns bool).

## Chorus cluster (stereo BBD) — transcribed

- **`0x1803C52E0`**: chorus process entry; calls the BBD stage functions
  `0x1803C8120, 0x1803C8390, 0x1803C86A0, 0x1803C87E0`.
- **`0x1803C5070`**: chorus allocation/init (heap). The stereo BBD chorus is now
  transcribed (`src/master_render.c` + `src/chorus_init.c`); its coefficients are
  **derived from the decompiled code + recovered tables**, not measured. (This
  supersedes the original plan, which had assumed a few chorus values would be
  runtime-only and need a capture — they were recovered statically instead.)
- Small helpers: `0x1803C56C0, 0x1803C5BC0, 0x1803C5CF0` (error/throw paths,
  not DSP).

## CRT / runtime noise in the closure (ignore for the port)

~80 of the 129 functions are MSVC runtime pulled in by the call graph:
`malloc/free/_calloc_base`, locale (`__acrt_*`), exception handling
(`_CxxThrowException`, `__report_gsfailure`), and math (`expf`, `fmodf`).
Only `expf` and `fmodf` matter to the DSP (envelope curve and phase wrap); use
the C library's. Everything else is not part of the audio algorithm.

## Transcription order (planned)

1. ✅ Leaf helpers `juno_wrap24`, `juno_triangle` (+ self-check).
2. Voice-state struct: name the ~300 offsets `voice_render` touches, stage by
   stage (DCO phase/saw/pulse/sub/noise → mix → HPF → 4-pole LPF → ADSR×2 →
   VCA → stereo out). Coefficients from `constants.txt`.
3. `voice_render` body, validated stage-by-stage against the decompile's
   intermediate signals.
4. Voice dispatch + lifecycle (clean offline driver, no host threading).
5. Chorus chain (coefficients derived statically from the decompile).
6. Assemble full engine; only then end-to-end.
