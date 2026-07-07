# Bit-exact audit: why it still sounds wrong (and the plan)

Honest accounting after the user reported timbre + arp still wrong despite
"bit-exact" claims. The word "bit-exact" was only ever true of individual
transcribed pieces (voice_render, master_render, recall curve values) — NOT of
the assembled instrument. The glue and the init baseline were never bit-exact.

## Proven non-bit-exact code (the actual bugs)

1. ~~**`juno_engine_init` is INCOMPLETE.**~~ — **FIXED (voice block).** Diffing my
   init against the plugin's own prepare (CWaveGen::setSampleRate 0x3C7A20, run
   under Unicorn) on the voice-0 block found 63 offsets the prepare sets that my
   init left ZERO. 29 are C++ object metadata (vtable ptr, heap pointers, counts)
   the flat engine never reads. The other **33 are DSP-read voice coefficients** —
   now written bit-exactly by `src/juno_prepare.c` (`juno_engine_prepare`), sourced
   from the binary's own setSampleRate output. 21 of the 33 are INVARIANT (not among
   the 79 recallable params, so no patch changes them) and were **0.0 before** when
   the binary wants unity (1.0) / 0.93 / 1.007 etc. — zeroed voice-path coefficients,
   the direct cause of "too dark / filtered". A/B PROOF: the compiled C engine's
   prepared voice-0 block `[176,10688)` now matches the binary with **zero
   mismatches** (`scratchpad/oracle/gen_voice_prepare.py`).

2. **`runtime_coeffs_data.c` is a CAPTURE of ONE patch ("PD The Juno Pad")** —
   PARTIALLY RETIRED, fully mapped. `juno_engine_prepare` now supplies 90 of the
   capture's offsets bit-exactly from the binary (setSampleRate + snap-all), and
   for those the capture no longer contributes (prepare runs after it and wins).
   A full-state A/B (`scratchpad/oracle/full_ab.py`) proves the C engine, WITHOUT
   the capture, matches the binary's BUILD+setSampleRate state on **1571/1573**
   DSP-read offsets (residuals: offset 136 = params pointer, set by attach_host;
   offset 4 = object-header count, not read as a coefficient).

   What the capture STILL provides — the "orphans" (read by the DSP, written by no
   engine code): **760 offsets (74 voice + 686 master/FX).** These are NOT
   setSampleRate output (both binary and prepare have them 0 at prepare time); they
   are populated later in the plugin's lifecycle. Precisely mapped:
   - **Envelope smoother inits** 2848/3328 and osc enable 6448 (=1.0): set by the
     smoother snap-all `sub_7FF91E0229B0` @0x3C29B0 (binary-derivable).
   - **Gate/velocity coefficients** 6864 (0.84252) / 9680 (1.15436): read by
     voice_render (smoother targets); the recall oracle's resolution (dispatch 450
     "Gate Notify", curve 56/57, CONST(100)) is a MISATTRIBUTION — juno_curve(56,
     100)=0.787 ≠ 0.84252 — so their true source is UNRESOLVED. Without them the
     voice output is scaled by 0 → silent; this is why the capture cannot yet be
     dropped outright.
   - **DCO PWM SOURCE** 3888: per-patch (blob 15), addable to recall once verified.
   - **Master/FX** 686 orphans: bound FX-parameter storage cells + the reverb
     tap-index / algorithm tables. Per-patch FX param VALUES (patch byte -> curve ->
     value) are the README's documented-unresolved FX/master recall path
     (see scratchpad/oracle/effect_prepare_findings.md — the descriptor map and the
     setValue write mechanism 0x3C1090 are known; the value source is not).
   - **Lifecycle caveat:** snap-all also ZEROES algorithm constants setSampleRate
     had written (6512/7440/9616), so the ready-to-play state is NOT a naive
     setSampleRate+snap-all compose — the true state needs the plugin's own
     end-to-end sequence (load-patch -> note-on -> render), whose render/process
     `sub_7FF91E027400` @0x3C7400 spawns worker threads (a poor emulation target).
   Net: the voice's static coefficients are bit-exact from the binary; the residual
   note-time/velocity + master/FX coefficients remain capture-sourced pending the
   above resolutions.

3. ~~**Arpeggiator is HAND-WRITTEN**~~ — **FIXED.** The hand-written arp (fixed
   8 Hz, wrong DOWN octave direction, guessed UP&DOWN order) has been replaced by a
   **bit-exact transcription of CArpeggio** (`src/carp.c`): the note selectors
   (UP `sub_7FF91E01EFC0` / UP&DOWN `sub_7FF91E01E5C0` / DOWN `sub_7FF91E01E850`),
   the pitch-sorted held-note list (insertion sort `sub_7FF91E023440`), octave
   fold, velocity math (`sub_7FF91E0235A0`) and the 24-PPQN clock with the extracted
   RATE/GATE tables are all copied field-for-field from the binary. Tempo (BPM) and
   gate are host inputs (the plugin's arp is host-tempo-synced). Full derivation +
   the honestly-flagged residual ambiguities in `docs/ARP_PROVENANCE.md`.

4. **Chorus mode hard-wired to II** (index.html), not recalled. 55/64 patches are
   type 2/3/4 = chorus (II is byte-identical-correct); modes 1&5 (9 patches) route
   to un-decompiled FX blocks.

5. ~~**`default_patch()` hand-values** (fast attack, reverb off)~~ — **MOSTLY FIXED.**
   The fast-attack hand-values (2784/3264) are gone: `juno_engine_prepare` now writes
   the binary's genuine power-on envelope coefficients. The one remaining reset is
   REVERB SEND (10759408) → 0.0, which is the binary power-on default (the FX
   parameter storage cells are all zero after BUILD + setSampleRate — verified under
   emulation, see item 6 / effect_prepare_findings.md), not a hand-fitted value.

## Plan (end goal: every DSP-read value bit-exact, C99, no captures/hand-values)
- Transcribe / derive the prepare (setSampleRate cascade + effect prepare) so init
  is COMPLETE and the master/effect coefficients are binary-sourced, not captured.
- Per-patch A/B: emulate the plugin's exact DSP-read state per patch, diff my
  engine, fix every divergence (add recall bindings / init constants).
- Retire runtime_coeffs_data.c and default_patch hand-values.
- Integrate the bit-exact CArpeggio transcription; recall chorus mode per-patch.
- Verify all 64 patches A/B-match, rebuild, deploy.
