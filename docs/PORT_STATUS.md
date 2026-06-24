# Port status & the chorus/driver boundary

Honest accounting of what is ported exactly, what remains, and what is **not in
our extracted data**. The user asked for hard truth over guesses; this records it.

## CURRENT STATE (latest — read this first)

**Extraction is COMPLETE and permanent.** The entire plugin (77,167 functions) is
archived in `refs/` (`manifest.tsv` index + `allcode_decomp.tgz` full decompile).
No further IDA sessions or live captures are needed — everything is searchable
offline.

**Done and PROVEN against the live plugin** (`make validate`, see docs/VALIDATION.md):
- Voice DSP (`voice_render`), master mix + stereo BBD chorus + output
  (`master_render`), coefficient init (`juno_engine_init`), chorus constructor
  (`juno_chorus_init`) — all transcribed exact.
- Init validated: **2289/2289 engine_init offsets bit-exact; 0 stable gaps** over
  all 1585 DSP-read offsets vs the live plugin (preset PD The Juno Pad, 96 kHz).
- Runtime coefficients for that patch captured & validated (279 values); used as
  the validation ORACLE, not as the port's source.

**Remaining (offline transcription from the full dump; nothing needed from the user):**
1. **#1 note/MIDI handler** — note→pitch/gate + voice allocation (makes it play).
   Buried in the VST3/threading layer (voice mgmt is pointer-based 40-byte structs,
   not flat `+10512` offsets). Under research.
2. **#2 parameter→coefficient appliers** — to honour any patch from original code
   (not per-patch captures). Surface being scoped from the full dump.
3. **Polyphony** — transcribe voices 1-7 (all 8 decompiles+asm are in the dump).
4. **Per-block driver** — refine `juno_driver` to mirror `sub_180398EC0` (enable
   flag + skip counter → master → prune) exactly.

Per the user's directive: transcribe the ORIGINAL code for #1/#2 (the captures are
only the validation oracle). Each piece is checked against the captured ground
truth as it lands.

---

## Ported — exact, compiling, tested
| Piece | Source | Notes |
|-------|--------|-------|
| `juno_wrap24`, `juno_triangle` | 0x368D60/0x368FC0 | leaf helpers, self-checked |
| `juno_voice_render` | 0x180369070 | full synth voice (DCO, 4-pole VCF, ADSR×2, VCA, unison bank); all helper args from asm |
| `juno_engine_init` | 0x1803990C0 | 2293-store coefficient init, sample-rate aware |
| lookup tables | .rdata | exponent + pitch tables, exact |

This is the synth core — the part the previous attempt got wrong. It is done.

## Multi-voice instantiation — solvable from our data
The 8 voice renders are one routine at different bases. Per-voice region strides
(verified by diffing voice 0 vs voice 1 offsets):
- main voice block (≈ offsets 320–10672): **+10512 per voice**
- shared/global block (84272–84432): **+0** (all voices read the same)
- aux array (101504): **+32 per voice**
So one parameterised `voice_render` (or 8 generated copies) can serve all voices.
No extra data needed.

## NOT in our extracted data (do not fabricate)

### 1. The chorus DSP
The "chorus cluster" (0x3C52E0, 0x3C8120, 0x3C8390, 0x3C86A0, 0x3C87E0, 0x3C6F00)
is **entirely threading / task-queue plumbing** — zero float DSP (verified by
scanning all 129 closure functions: the only heavy float-math functions are the
8 voice renders). The audio worker loop `0x3C6F00` dispatches downstream work
through an **indirect vtable call** `(*(...+104))(...)` taken when `a2==0`; the
static call-graph walk in extract_dsp.py cannot follow indirect calls, so the
stereo BBD chorus routine was never captured. **Its code is not in `dsp_dump`.**

To port the chorus we must first locate it. Options:
- **Frida**: hook the indirect call site in `0x3C6F00` (or the process callback)
  to log the target function address at runtime, then one targeted IDA dump of
  that function (+ its coefficient init). Small and precise.
- **Static**: resolve the vtable at `*(obj+8)`, method `+104` — needs the class
  identity; harder without runtime.

### 2. Voice mix / output / note-trigger
`voice_render` writes a mono sample (overwrite) per voice; the summation of the 8
voices, the stereo output routing, and the MIDI-note → pitch/gate field mapping
live in the host/threading layer **above** our closure (the same indirect-call
boundary). A plain sum of voice outputs is the standard and almost-certainly
-correct behaviour, but it is an assumption, not transcribed. The note-on gate is
`*(state+101504)==1.0`; the pitch-field mapping is not in our data.

## UPDATE — master/chorus located; resume plan

The static float-DSP search found the missing master process:
**`sub_180363380`** = 8-voice mix + stereo BBD chorus (circular delay at
`a1+91728`) + true-stereo output. Decompile is in
`audio_search/000_*` and `init_dump/020_*`; disassembly in `master_deps/`.

Helpers it needs are now ported (`juno_pitch_poly`, `juno_wrap_unit`,
`juno_wrap_hi` in `src/juno_dsp.c`).

**Remaining to finish the chorus (next session, fresh context):**
1. Transcribe `sub_180363380` (2875 lines) the same way as voice_render
   (translate_voice-style: offsets→JF/JI; resolve dropped helper args from
   `master_deps/master_sub_180363380_*.asm`; helpers → juno_* names).
2. Chorus coefficients: ~250 read-only offsets `sub_1803990C0` doesn't set are
   produced by **`sub_180388170`** (the param/coeff setup; touches 20/25 chorus
   signature offsets). **Hex-Rays returns None on it** — transcribe from its
   disassembly (dump asm of 0x388170), or capture the resulting values once.
   Until then the chorus state is zero (dry path still correct).
3. Wire the driver: per-sample loop calls the per-voice renders into 8 buffers,
   then `sub_180363380(state, voiceBufs, outLR)`. Multi-voice strides known
   (main +10512, shared +0, aux +32).

The dry synth voice + filter + envelopes + init are exact and complete; the
above is the stereo-chorus/output layer on top.

## DONE this session (branch claude/cool-volta-hnunqw)

1. ✅ **Master transcribed** → `src/master_render.c` (`juno_master_render`,
   sub_180363380). Body kept verbatim (IDA `_DWORD/_QWORD/_WORD/__int16` as
   typedefs/macros, `a1` an `unsigned char*`) with 19 fixups only where Hex-Rays
   dropped an XMM arg / mangled SIMD. **Every dropped arg recovered from the asm**
   and documented in `docs/MASTER_RENDER_MAP.md` — notably the 3 chorus LFO
   stages (stages 2 & 3 had the whole phase-increment block dropped; reconstructed
   from asm, identical to the fully-decompiled stage 1) and the 3 output
   `wrap_unit` LFOs. Compiles clean under `-Wall -Wextra`.
2. ✅ **IDA extraction script** for the coeff generator →
   `tools/extract_chorus_coeffs.py` (+ `docs/RUN_GUIDE_CHORUS_COEFFS.md`). Dumps
   the **disassembly of sub_180388170** (Hex-Rays = None on it), its caller
   context (for args), and its referenced `.rdata` float values. **User must run
   this in IDA 9.3** and upload `chorus_coeffs/`.
3. ✅ **Driver wired** → `src/juno_driver.c` / `.h` (`juno_driver_render_sample`):
   renders voices into the 8-buffer layout the master expects (even slots
   a2[0,2,…14]), supplies the chorus-mode selectors via a host-params shim
   (`juno_driver_attach_host`), and calls the master. `make test` green
   (`tests/test_master_smoke.c`).

## UPDATE 2 — chorus coeff source corrected; full pipeline runs

The IDA `chorus_coeffs/` dump (sub_180388170 + sub_1803A1300) arrived and rewrote
the picture:

- **`sub_180388170` is NOT the coeff generator** — my ranking heuristic was fooled.
  Its "constants" are parameter NAME strings (`aMasterTune`, `aLfoRate`, …) and it
  `push_back`s ~1121 parameter descriptors. It's the **parameter registry**; for
  each param it does `lea rax,[rdi+coeffOffset]` + a default and calls the
  registrar `sub_1803ABA00`. It writes **zero** floats to the audio state.
- **`sub_1803A1300` (was "zeroinit") IS the chorus constructor** — 2982 stores: the
  integer **BBD delay-line lengths** (`[2199956]=0x80000`, `[6395252]=0x80000`,
  `[95828]=1024`, …) + ring indices + buffer zeroing. Ported verbatim →
  `src/chorus_init.c` (`juno_chorus_init`), wired before the voice init. **With the
  lengths set, the master no longer reads out of bounds: the full master/chorus
  path now runs end-to-end, finite over 2048 samples.**
- **The 241 missing coefficients** (read-only in the master, set by no static
  init — count verified by offset diff) are **applied at runtime** from parameter
  defaults/presets, several through a param→curve map. The faithful, non-fitted
  way to get them is a **live capture** → `tools/capture_chorus_coeffs.js` +
  `docs/RUN_GUIDE_CHORUS_CAPTURE.md`. The apply path is already wired
  (`juno_chorus_coeffs_apply` ← `src/chorus_coeffs_data.c`); it's a no-op until the
  capture is pasted in, at which point the chorus comes alive.

Current init sequence: `juno_chorus_init` → `juno_engine_init` →
`juno_runtime_coeffs_apply` → per-sample `juno_driver_render_sample`.

### Hard truths found (no fabrication)
- **Polyphony isn't free.** The 8 voice copies differ across THREE regions with
  DIFFERENT strides (main +10512, shared +0, aux +32), so a single uniform base
  shift CANNOT serve voices 1-7 — and the 8 decompiles differ in ~1800 lines
  (Hex-Rays re-numbered temps), so they aren't trivially generatable either.
  Faking it = a wrong approximation, so the driver renders **voice 0 exactly** and
  zeros 1-7. True polyphony needs per-voice asm for sub_18036CE00..sub_180383F20
  OR a verified offset-classification to parameterise the one render.
- **The engine is silent until the runtime parameter layer is applied** — to BOTH
  voice and chorus. The static inits set the math coefficient *tables* and the
  chorus *structure* (delay lengths), but NOT the patch: 349 offsets (107 voice +
  242 chorus) are read by the DSP and written by no init. They are applied at
  runtime by the parameter system. Verified: triggering voice 0's note-on gate
  with no patch yields silence. These 349 are captured from the live plugin
  (`tools/capture_runtime_coeffs.js`) — the runtime-only case the handoff allows.
- **`sub_180388170` is the parameter registry, not the coeff generator** — the
  earlier ranking heuristic was fooled by coincident offsets. Corrected.

## Recommendation / next action
The exact DSP transcription (voice core + master/chorus + chorus constructor) is
complete and the full pipeline **runs finite end-to-end**. The single highest-
value step to a *playable* engine is **one Frida capture** of the 349 runtime
coefficients for a default patch (`docs/RUN_GUIDE_RUNTIME_CAPTURE.md`); paste it
into `src/runtime_coeffs_data.c` and a note sounds with the chorus live. After
that: per-voice polyphony, then per-stage numerical validation against the plugin
(still the real definition of "correct" — at 0% so far).
