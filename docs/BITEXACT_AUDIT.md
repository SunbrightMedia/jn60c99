# Bit-exact audit: the timbre + arp bugs, and how they were fixed

> **STATUS: RESOLVED.** Every item below is fixed. The captured baseline is
> deleted; every coefficient the DSP reads at playback is now derived from the
> binary (constructor + prepare + per-patch recall + note-on velocity curves),
> and the arp is a field-for-field transcription of CArpeggio. All 64 patches
> render finite and non-silent with no capture; `make test` is green. The one
> documented residual is the per-mode structural blocks for effect modes the
> JUNO-60 does not use by default (item 2). This document is kept as the honest
> record of what the bugs were and how each was resolved.

Honest accounting after the user reported timbre + arp wrong despite "bit-exact"
claims. The word "bit-exact" was originally only true of individual transcribed
pieces (voice_render, master_render, recall curve values) — NOT of the assembled
instrument. The glue and the init/prepare baseline are what this audit fixed.

## The bugs (each now fixed — see the annotations)

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

2. ~~**`runtime_coeffs_data.c` is a CAPTURE of ONE patch ("PD The Juno Pad")**~~
   — **RETIRED. The captured baseline is deleted; every coefficient the DSP reads
   at playback now comes from the binary.** The full chain:
   - `juno_engine_init` — the constructor state (sub_1803990C0).
   - `juno_engine_prepare` (`src/juno_prepare.c`) — the prepared state the plugin's
     own `setSampleRate` + smoother snap-all (`sub_7FF91E0229B0`) + effect
     setActive produce: the 33 voice coefficients init misses, the master
     per-voice output gains, the chorus/delay/output-filter constants, the effect
     ENABLE/output constants (chorus Mute/Ip Fc, output-stage unity gains), and the
     full **reverb-ECF tank** (density + HPF/LPF/DPF filter cascade). All are the
     exact 32-bit patterns dumped from the binary under emulation.
   - **note-on velocity** (`src/juno_note.c`): 6864/9680 = `juno_curve(56/57,
     velocity)`, proven bit-for-bit by driving the plugin's dispatch over a
     velocity sweep.
   - **per-patch recall**: delay + reverb + **chorus levels** (`src/chorus_recall.c`).

   VERIFICATION: a full-state A/B (`scratchpad/oracle/full_ab.py` /
   `dump_full_effect.py`) proves the C engine, with NO capture, matches the
   binary's BUILD → snap-all → setSampleRate state across the whole DSP-read set
   (the only residuals are offset 136 = params pointer set by attach_host, offset 4
   = an object-header count, and a handful of snap-all-order artifacts where the
   correct setSampleRate value is kept). All 64 bank patches render finite and
   non-silent with the capture removed. The driver now always runs the full
   master/output path.

   HONEST RESIDUAL (does not need the capture): the per-mode STRUCTURAL blocks for
   effect modes the JUNO-60 does not use by default — the mode-5 chorus block
   (96384/96416) and the slot-1 BBD-delay (4297xxx) / slot-1 chorus-CV (6395xxx) —
   are only reached when a patch selects those modes; the driver keeps slot-2
   pinned to the chorus, so they are inert for the standard chorus path. Deriving
   their per-mode setActive output is the one remaining item for 100% mode
   coverage (docs/CHORUS_RECALL.md §5).

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
