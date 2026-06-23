# Port status & the chorus/driver boundary

Honest accounting of what is ported exactly, what remains, and what is **not in
our extracted data**. The user asked for hard truth over guesses; this records it.

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

### Two hard truths found (no fabrication)
- **Polyphony isn't free.** The 8 voice copies differ across THREE regions with
  DIFFERENT strides (main +10512, shared +0, aux +32), so a single uniform base
  shift CANNOT serve voices 1-7 — and the 8 decompiles differ in ~1800 lines
  (Hex-Rays re-numbered temps), so they aren't trivially generatable either.
  Faking it = a wrong approximation, so the driver renders **voice 0 exactly** and
  zeros 1-7. True polyphony needs per-voice asm for sub_18036CE00..sub_180383F20
  (transcribe each) OR a verified offset-classification to parameterise the one
  render. Bounded, but real work.
- **The master can't execute until the chorus coeffs exist.** Its BBD delay lines
  index as `(len-1) & idx`; the length fields are among the ~250 produced by
  sub_180388170, currently zero → mask `-1` → out-of-bounds read (verified
  segfault). Even the "dry" branch indexes the delay lines, so "dry path still
  correct" was optimistic. The driver therefore **gates** the master call on a
  length sentinel and emits the exact dry voice sum until coeffs load. Once
  `extract_chorus_coeffs.py` is run and sub_180388170 is transcribed, the gate
  opens and the full master/chorus runs.

## Recommendation
The exact DSP core is complete. Reaching a *playable, chorused* engine needs the
chorus code located (one targeted Frida-assisted extraction) and the host glue
(mix/note-trigger) decided. Both are bounded; neither affects the already-exact
voice core. Decision for the user: locate the chorus now, or proceed to wire a
standard-sum driver around the exact voice core first.
