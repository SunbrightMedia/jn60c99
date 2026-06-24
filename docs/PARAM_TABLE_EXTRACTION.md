# Parameter → denormalize-table extraction (JUNO-60 VST3)

Definitive map of `paramID → (offset, tableId)` for the preset-apply LUT engine,
recovered by statically linking each parameter to the `sub_356380` denormalize LUT
it uses. Deliverables: `refs/param_table_full.json`, `src/juno_param_table.h`.

Image base `0x7FF91DC60000` (rva = runtime − base). Dispatcher `sub_356380`
(= `sub_7FF91DFB6380`, rva 0x356380) maps `tableId → dword_7FF91E5C*/5E*[clamp(step)]`.

## Result (coverage)

- **Total engine params** (`docs/PARAM_MAP.tsv`, registry `sub_388170`): **1121**.
- **Resolved: 673** (60%).
  - **534 DEFINITIVE** (`inferred=0`):
    - **61** `oracle` — bit-exact members of `refs/recovered_param_steps.json`.
    - **473** `vtable` — CDSPJu60* setter vtable → `sub_356380` tableId, node==paramID.
  - **16 `vtable-multi`** (`inferred=0`): engine node written by >1 setter (coarse/fine
    or sync-mode variants); primary tableId chosen, alternates recorded in JSON `alts`.
  - **123 `name-fallback`** (`inferred=1`): param name maps to a *single* tableId across
    all definitively-resolved params (ambiguous names excluded). Structurally unvalidated.
- **Unresolved: 448** — **235** switches/booleans/MIDI-notify (identity 0/1, **no LUT**,
  no tableId needed) + **213** non-LUT params: synth params applied via the *scale+offset*
  family (`sub_356150`, not `sub_356380` — no denormalize table) and the FX filter
  coefficients (High Cut / Rev Ecf / DS·OD·MT·FZ tone — computed by reverb/delay/chorus
  setup, see `docs/PARAM_APPLY_MAP.md` §VALIDATION, the "29% FX-derived" set).

## Oracle agreement: **61 / 61 overlapping offsets, bit-exact (0 disagree).**

The oracle (`refs/recovered_param_steps.json`, 88 offset→table from bit-exact PD Juno
Pad capture) is treated as authoritative wherever it overlaps the vtable map. Over the
61 oracle offsets that have a `PARAM_MAP` paramID, the final map agrees 100%.

### Where the vtable map and the oracle's bit-match diverged (and why the map is still sound)

Before applying oracle-precedence, the raw vtable map disagreed with the oracle on 8 of
its 18 synth offsets. Investigated bit-exactly against the LUTs:

- **6 are genuine cross-table ambiguities**: the captured coefficient is a bit-exact
  member of BOTH the oracle's table and the setter's table (e.g. off 6864 = t21[107] **and**
  t56[107]; off 9584 = t21[22] **and** t24[150]; off 9616/9680 = t56 **and** t57). The
  oracle's recovery picked one valid member; the static setter names the other. Both are
  bit-exact — not a contradiction. The map keeps the oracle value for these offsets.
- **1 was a real extraction bug, now fixed**: samplerate-selected tableIds are computed
  into a *variable* (`v7 = (v6 != 48000) + 43`), which the first literal-only scan missed,
  leaving the switch tableId (52) instead of the 96 kHz time table (44). Fixed by
  resolving the SR ternary to the 96 kHz branch. Two setters are SR-selected:
  `0x356E30 → 41` (HPF, 44100→39/48000→40/96000→41) and `0x35A570 → 44` (LFO Delay).
- **1 residual (off 7440, pid85 "Velocity Offset")**: oracle t24[63] (member); the setter
  on that engine node uses t56 (NOT a member). Oracle wins (it is bit-exact, the setter
  is not). Likely a node-field permutation in the FltVoice velocity cluster; flagged, not
  fabricated.

## Method (the wiring that worked)

```
setter(obj, a2, step):
    sub_356380(&unk_7FF91E910DC8, TABLEID, step);    // -> coefficient (hidden xmm0)
    sub_3C1090(engine, a2, node = *(obj + FIELD));   // state[40*node+32] = coeff
```

1. **Extract setters → tableId.** Scan every function in `allcode/decomp_340000.c` for
   `sub_7FF91DFB6380(<x>, <tableId>, ...)`. 139 functions qualify. tableId is usually an
   int literal; for the 2 SR-selected setters it is a variable resolved to the 96 kHz
   branch. Within a setter, each engine write `sub_3C1090/0F0(engine, a2, *(obj+FIELD))`
   is paired with the **most recent `sub_356380` tableId** before it.

2. **Setters live in per-class vtables in `.rdata`.** Scanning `seg_rdata_935650.bin`
   (rva 0x935650..0xC43000) for 8-byte LE pointers to setter rvas finds 196 setter
   pointers in **22 vtables** clustered at rva 0x987fb8..0x9894xx. Each vtable's class
   name is read from the MSVC RTTI col-locator stored immediately before its first method
   slot (col-locator +12 = TypeDescriptor RVA; name string at TypeDescriptor +16 in
   `seg_data_C43000.bin`). Classes: `CDSPJu60{Amp,Env,Flt,Lfo,Osc}Voice`, `VoiceCmn`,
   `Noise`, `PatchLev`, `Mst`, the `Efx*` chorus/insert blocks, `System8Dly*`.

3. **vtable class → paramID via the constructor.** Each `CDSPJu60*` constructor
   (e.g. EnvVoice `sub_358180`) is a per-voice `switch(case)` that **stores the global
   paramIDs directly into the object fields** the setters read:
   `EnvVoice case0: +60=31 +64=37 +68=32 +72=34 +76=33 …`. The engine write indexes by
   `*(obj+FIELD)`, and that field's value **is the descriptor/node index = paramID**
   (verified: `sub_388170` registers all 1121 descriptors sequentially, so node index ==
   paramID — confirmed e.g. EnvVoice node 33 → off 2800 = pid 33). So:

   ```
   tableId(paramID) = tableId(setter) where setter's FIELD-value (from the ctor case) == paramID
   ```

   Every voice/part instance (8 ctor cases) reuses the same setter vtable but stores a
   different paramID block in its fields, so one extraction covers all blocks.

   **Boundary:** `CDSPJu60EfxCh/EfxCe` ctor fields hold global pids (906–922) and resolve
   the same way; the `CDSPSystem8Dly*` (delay/reverb) ctor fields hold *local* indices into
   a separate engine instance (the large `4297584+` offsets), NOT global pids — those FX
   coefficients are covered by the oracle/FX-setup path, not this node==pid join.

4. **Validate against the oracle** (above); apply oracle-precedence on overlaps.

## Setter → tableId table (139 setters; class = wiring vtable, "(unwired)" = secondary in-chain writer)

| setter rva | class | tableId(s) |
|---|---|---|
| 0x3562b0 | CDSPJu60AmpVoice | 22 |
| 0x356310 | CDSPJu60AmpVoice | 57 |
| 0x356cd0 | (unwired) | 3 |
| 0x356e30 | (unwired) | 41 SR@96k |
| 0x356fb0 | CDSPJu60AmpVoice | 51 |
| 0x357060 | CDSPJu60AmpVoice | 24 |
| 0x3570c0 | CDSPJu60AmpVoice | 52 |
| 0x357100 | CDSPJu60AmpVoice | 22 |
| 0x357160 | CDSPJu60AmpVoice | 57 |
| 0x357230 | CDSPJu60EfxCe | 22 |
| 0x357390 | CDSPJu60EfxCe | 22 |
| 0x357580 | CDSPJu60EfxCe | 52 |
| 0x357740 | CDSPJu60EfxCh | 22 |
| 0x3577b0 | CDSPJu60EfxCh | 19 |
| 0x357a00 | CDSPJu60EfxCh | 52 |
| 0x357d60 | CDSPJu60EfxCmn | 25 |
| 0x357e40 | CDSPJu60EfxCmn | 52 |
| 0x357fc0 | CDSPJu60EfxFz | 19 |
| 0x358020 | CDSPJu60EfxFz | 22 |
| 0x358120 | CDSPJu60EfxFz | 24 |
| 0x3586c0 | CDSPJu60EnvVoice | 50 |
| 0x3588a0 | CDSPJu60EnvVoice | 50 |
| 0x358910 | CDSPJu60EnvVoice | 52 |
| 0x359440 | CDSPJu60FltVoice | 26 |
| 0x3594d0 | CDSPJu60FltVoice | 46 |
| 0x359530 | CDSPJu60FltVoice | 52 |
| 0x359630 | CDSPJu60FltVoice | 52 |
| 0x359670 | CDSPJu60FltVoice | 52 |
| 0x359700 | CDSPJu60FltVoice | 24 |
| 0x359790 | CDSPJu60FltVoice | 47 |
| 0x3597f0 | CDSPJu60FltVoice | 22 |
| 0x3598f0 | CDSPJu60FltVoice | 22 |
| 0x359a60 | CDSPJu60FltVoice | 22 |
| 0x359af0 | CDSPJu60FltVoice | 31 |
| 0x359be0 | (unwired) | 4 |
| 0x359d10 | (unwired) | 22 |
| 0x359de0 | CDSPJu60FltVoice | 52 |
| 0x359e20 | CDSPJu60FltVoice | 52 |
| 0x359e60 | CDSPJu60FltVoice | 56 |
| 0x359ed0 | CDSPJu60FltVoice | 22 |
| 0x359f30 | CDSPJu60FltVoice | 56 |
| 0x35a570 | CDSPJu60LfoVoice | 44 SR@96k |
| 0x35a660 | CDSPJu60LfoVoice | 52 |
| 0x35a6b0 | CDSPJu60LfoVoice | 51 |
| 0x35a7e0 | CDSPJu60LfoVoice | 52 |
| 0x35a840 | CDSPJu60LfoVoice | 52 |
| 0x35a8a0 | CDSPJu60LfoVoice | 52 |
| 0x35a900 | CDSPJu60LfoVoice | 52 |
| 0x35a960 | CDSPJu60LfoVoice | 52 |
| 0x35a9c0 | CDSPJu60LfoVoice | 52 |
| 0x35aa20 | CDSPJu60LfoVoice | 52 |
| 0x35aa80 | CDSPJu60LfoVoice | 22,48 |
| 0x35ac40 | CDSPJu60LfoVoice | 52 |
| 0x35aca0 | (unwired) | 48 |
| 0x35ad00 | CDSPJu60LfoVoice | 53 |
| 0x35ad70 | CDSPJu60LfoVoice | 52 |
| 0x35adb0 | CDSPJu60LfoVoice | 52 |
| 0x35aef0 | CDSPJu60Mst | 18 |
| 0x35af50 | CDSPJu60Mst | 19 |
| 0x35b0c0 | CDSPJu60Noise | 52 |
| 0x35bb80 | CDSPJu60OscVoice | 52 |
| 0x35bbd0 | CDSPJu60OscVoice | 26 |
| 0x35bea0 | CDSPJu60OscVoice | 5 |
| 0x35bee0 | CDSPJu60OscVoice | 52 |
| 0x35c030 | CDSPJu60OscVoice | 0 |
| 0x35c090 | CDSPJu60OscVoice | 22 |
| 0x35c1d0 | CDSPJu60OscVoice | 52 |
| 0x35c230 | CDSPJu60OscVoice | 28 |
| 0x35c290 | CDSPJu60OscVoice | 54 |
| 0x35c2f0 | CDSPJu60OscVoice | 52 |
| 0x35c3d0 | CDSPJu60OscVoice | 45 |
| 0x35c4b0 | CDSPJu60OscVoice | 54 |
| 0x35c510 | CDSPJu60OscVoice | 54 |
| 0x35c570 | CDSPJu60OscVoice | 54 |
| 0x35c5d0 | CDSPJu60OscVoice | 54 |
| 0x35c630 | (unwired) | 4 |
| 0x35c710 | (unwired) | 22 |
| 0x35c860 | CDSPJu60PatchLev | 49 |
| 0x35cce0 | CDSPJu60VoiceCmn |  |
| 0x35ce20 | CDSPJu60VoiceCmn | 27 |
| 0x35ce90 | CDSPJu60VoiceCmn | 6 |
| 0x35cef0 | CDSPJu60VoiceCmn | 55 |
| 0x35cf90 | CDSPJu60VoiceCmn | 27 |
| 0x35d000 | CDSPJu60VoiceCmn | 52 |
| 0x35d040 | CDSPJu60VoiceCmn | 52 |
| 0x35d080 | CDSPJu60VoiceCmn | 7 |
| 0x35d1a0 | CDSPJu60VoiceCmn | 52 |
| 0x35db00 | CDSPSystem8DlyCh | 22 |
| 0x35db80 | CDSPSystem8DlyCh | 22 |
| 0x35dd50 | CDSPSystem8DlyCh | 22 |
| 0x35ddd0 | CDSPSystem8DlyCh | 22 |
| 0x35de50 | CDSPSystem8DlyCh | 64 |
| 0x35e290 | CDSPSystem8DlyCh | 65 |
| 0x35e590 | CDSPSystem8DlyCh | 22 |
| 0x35e630 | CDSPSystem8DlyCh | 22 |
| 0x35e6b0 | CDSPSystem8DlyCh | 19 |
| 0x35e740 | CDSPSystem8DlyCh | 22 |
| 0x35eb90 | CDSPSystem8DlyChSt | 22 |
| 0x35ec10 | CDSPSystem8DlyChSt | 22 |
| 0x35ede0 | CDSPSystem8DlyChSt | 22 |
| 0x35ee60 | CDSPSystem8DlyChSt | 22 |
| 0x35eee0 | CDSPSystem8DlyChSt | 64 |
| 0x35f320 | CDSPSystem8DlyChSt | 65 |
| 0x35f570 | CDSPSystem8DlyChSt | 22 |
| 0x35f610 | CDSPSystem8DlyChSt | 22 |
| 0x35f690 | CDSPSystem8DlyChSt | 19 |
| 0x35f720 | CDSPSystem8DlyChSt | 22 |
| 0x35fcf0 | CDSPSystem8DlyDly | 22 |
| 0x35fd70 | CDSPSystem8DlyDly | 22 |
| 0x35fdf0 | CDSPSystem8DlyDly | 59 |
| 0x35ff30 | CDSPSystem8DlyDly | 58 |
| 0x360300 | CDSPSystem8DlyDly | 59 |
| 0x3603b0 | CDSPSystem8DlyDly | 60 |
| 0x3604f0 | CDSPSystem8DlyDly | 22 |
| 0x360920 | CDSPSystem8DlyMfx1 | 22 |
| 0x3609a0 | CDSPSystem8DlyMfx1 | 22 |
| 0x360b70 | CDSPSystem8DlyMfx1 | 22 |
| 0x360bf0 | CDSPSystem8DlyMfx1 | 22 |
| 0x360c80 | CDSPSystem8DlyMfx1 | 64 |
| 0x3610e0 | CDSPSystem8DlyMfx1 | 65 |
| 0x361350 | CDSPSystem8DlyMfx1 | 22 |
| 0x3613f0 | CDSPSystem8DlyMfx1 | 22 |
| 0x361630 | CDSPSystem8DlyMfx1 | 22 |
| 0x3616b0 | CDSPSystem8DlyMfx1 | 22 |
| 0x361740 | CDSPSystem8DlyMfx1 | 59 |
| 0x361890 | CDSPSystem8DlyMfx1 | 58 |
| 0x361c80 | CDSPSystem8DlyMfx1 | 59 |
| 0x361d40 | CDSPSystem8DlyMfx1 | 60 |
| 0x361e80 | CDSPSystem8DlyMfx1 | 22 |
| 0x361f00 | CDSPSystem8DlyMfx1 | 19 |
| 0x361f80 | CDSPSystem8DlyMfx1 | 22 |
| 0x362690 | CDSPSystem8DlyPan | 22 |
| 0x362710 | CDSPSystem8DlyPan | 22 |
| 0x362790 | CDSPSystem8DlyPan | 59 |
| 0x3628d0 | CDSPSystem8DlyPan | 58 |
| 0x362ca0 | CDSPSystem8DlyPan | 59 |
| 0x362d50 | CDSPSystem8DlyPan | 60 |
| 0x362fb0 | CDSPSystem8DlyPan | 22 |
| 0x363040 | CDSPSystem8DlyPan | 22 |

## What could NOT be resolved (honest boundary)

- **235 switch/boolean/notify params** — stored as exact 0.0/1.0, no denormalize table.
- **213 non-LUT numeric params**:
  - Synth params with **no `sub_356380` setter** writing their node (Detune, Mod Sens,
    ENV1/ENV2 Level, Cutoff Tune, AMP LEVEL, LFO Gain, Boost LPF/Thru Level, …). These use
    the **scale+offset apply** (`sub_356150`, per-object scale arrays + const
    `dword_7FF91E7450B4`) — a different mechanism with no tableId. Out of scope for the LUT map.
  - **FX filter coefficients** (High Cut B0/A0/Qc, Rev Ecf DPF/HPF/LPF, DS/OD/MT/FZ tone,
    Delay/Chorus CV) — computed by the reverb/delay/chorus setup from the FX tables
    (`refs/reverb_tables.json`, `refs/delay_tables.json`), not the param-LUT path.
- **16 vtable-multi nodes** — engine node shared by >1 host param/setter (Master Tune
  ← t6/t27/t55; LFO Tempo Rate ← t48/t53). Primary tableId chosen from the base
  (non-offset) setter; the controller param→slot binding needed to split each host param
  to its own setter is not statically clean here. Alternates kept in `refs/param_table_full.json`.
- **off 7440 / pid85** — one residual oracle-vs-setter divergence (see above); oracle kept.
