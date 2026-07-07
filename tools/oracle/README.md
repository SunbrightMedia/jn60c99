# Recall verification oracle

Reproducible harness that proves the preset-recall applier (`src/juno_apply.c`)
is bit-exact by **running the plugin's own code** under Unicorn, independent of
the golden-coefficient test. See `docs/RECALL_COMPLETE.md` for the conclusion.

## Requirements
- `pip install unicorn capstone pefile` (versions used: unicorn 2.1.4, capstone
  5.0.7, pefile 2024.8.26).
- The original VST3 binary. The harness path points at the uploaded artifact
  (`aea4b19d-JUNO60VST3_64bit.vst3`, ImageBase 0x180000000); set `BIN` to your
  copy. The binary is **not** committed.

## What it does (`full_instance_emu.py`)
Builds the entire DSP engine graph the way the plugin does — the constructor
`sub_7FF91E0268D0 @0x3C68D0` runs with only `operator new` (`0x67522C`) and the
Win32 imports stubbed (HeapAlloc→bump allocator, etc.), producing the real
`CPrmDSPJu60Plugin` (vtable RVA `0x9C3018`) with 8 wired voice components. It then
drives the parameter dispatch `sub_7FF91E019A30(this, dispatch_index, flag=1,
value)` and recovers, per setter, the `(curve_id, engine_offset)` pair by hooking
the curve function `0x356380` (edx=curve_id, r8d=value) and the descriptor writer
`0x3C2750` (paramIdx in edx → offset via the descriptor table).

## Key binary facts (derived, not guessed)
- Dispatch ABI: `rcx`=this, `edx`=dispatch_index, `r8d`=flag (1 ⇒ immediate),
  `r9d`=value.
- Curve fn `0x356380`: `edx`=curve_id, `r8d`=value(0..255) → `xmm0`.
- `dispatch_index == Script.xml DB_index`, and `DB_index = value-tree leaf + 728`
  (verified: leaf113=VCA MODE=DB841, leaf129=HPF TYPE=DB857). Extended
  `record_pos = 490 + 8*(DB − 841)`.
- The vtable setter thunks (slots 187–352) are runtime-wired *broadcasters* to the
  per-voice components — which is why full-instance construction (not the isolated
  ctor) is required to see the coefficient writes.

## Result
- 120/120 golden coefficient bit-patterns exact (40 offs × 3 patches).
- Full-instance emulation independently reproduces the front-panel primary
  bindings (28/30 anchors; the 2 residuals are golden-settled small-int params).
- Non-front-panel controls (tune/detune/mod-sens/bend-sens/FX/master) route
  through the master/FX/flat-param path outside the voice graph; the emulation
  cannot cleanly pair their writes, so they are **flagged unresolved, never
  guessed**. `gap_bindings.json` records each with an honest confidence.

## Files
- `full_instance_emu.py` — the emulator.
- `resolved_table.json` — 79 emulation-resolved dispatch indices (30 authoritative).
- `full_recall_table.json` — 49 verified rows + flagged unresolved.
- `gap_bindings.json` — the remaining panel controls, per-row confidence.
- `static_table.json` — dispatch map, slot→thunk, 155-leaf curve catalog, parser
  record map, ABI notes.

## Prepare / runtime-coeffs derivation (derive_coeffs.py)

`derive_coeffs.py` builds the full instance and runs the real PREPARE to derive the
`src/runtime_coeffs_data.c` baseline from the binary:
- BUILD  = CWaveGen::build       (RVA 0x3C68D0, vtable[1])
- PREP   = CWaveGen::setSampleRate (RVA 0x3C7A20, vtable[3]) — sample rate is a
  **float in XMM1** (NOT a GP reg; emu2.call() only sets rcx/rdx/r8/r9, so drive
  emu_start manually and set XMM1 = float32(96000.0)).
setSampleRate does ~23M coefficient writes (zero import stubs, correct graph) and
reproduces 45/279 runtime coeffs bit-for-bit. The remaining ~205 invariant coeffs
are per-voice/effect internals whose captured values are confirmed present in the
emulated sub-objects; fully sourcing them needs every effect mode enabled + the
non-linear effect-object -> flat-offset remap that master_render.c flattened.
NOTE: sub_180388170 is declareParameters (param-descriptor DB), NOT a coeff generator.
