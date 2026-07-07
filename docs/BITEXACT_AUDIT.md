# Bit-exact audit: why it still sounds wrong (and the plan)

Honest accounting after the user reported timbre + arp still wrong despite
"bit-exact" claims. The word "bit-exact" was only ever true of individual
transcribed pieces (voice_render, master_render, recall curve values) — NOT of
the assembled instrument. The glue and the init baseline were never bit-exact.

## Proven non-bit-exact code (the actual bugs)

1. **`juno_engine_init` is INCOMPLETE.** Diffing my init against the plugin's own
   prepare (CWaveGen::setSampleRate 0x3C7A20, run under Unicorn) on the voice-0
   block: 2645/2708 offsets identical, **63 differ — all "plugin sets it, my init
   leaves ZERO"** (0 cases of "both set, different"). So the transcription isn't
   wrong, it's INCOMPLETE. ~30 of the 63 are object metadata (irrelevant to the
   flat engine); ~23 are true invariant constants the capture happens to supply
   correctly; ~8 are patch-dependent (recall covers most; 5520 "Duty Tune" leaks).

2. **`runtime_coeffs_data.c` is a CAPTURE of ONE patch ("PD The Juno Pad").** It
   fills the init gap + the master/chorus/output coefficients. A snapshot of one
   dark, reverbed pad applied under every patch = the "too dark/filtered" color.
   Non-bit-exact by definition. Retiring it needs the effect PREPARE derived from
   the binary — the effect objects live at part+6784/6976/7184/7400/7616/7824/8176
   and their coeff-compute is gated on the effect-type selector (part+1480); the
   master reads them flattened into the state at 4297584/6395312/6497168/10692016/
   10759376.

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

5. **`default_patch()` hand-values** (fast attack, reverb off) — not from the binary.

## Plan (end goal: every DSP-read value bit-exact, C99, no captures/hand-values)
- Transcribe / derive the prepare (setSampleRate cascade + effect prepare) so init
  is COMPLETE and the master/effect coefficients are binary-sourced, not captured.
- Per-patch A/B: emulate the plugin's exact DSP-read state per patch, diff my
  engine, fix every divergence (add recall bindings / init constants).
- Retire runtime_coeffs_data.c and default_patch hand-values.
- Integrate the bit-exact CArpeggio transcription; recall chorus mode per-patch.
- Verify all 64 patches A/B-match, rebuild, deploy.
