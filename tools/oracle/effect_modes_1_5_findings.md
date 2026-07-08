# EFFECT TYPE modes 1 and 5 — identity, structural coefficients, per-patch recall

Ground truth = the binary only (`aea4b19d-JUNO60VST3_64bit.vst3`, ImageBase
0x180000000, decompile rebased to 0x7FF91DC60000), driven under Unicorn
(`scratchpad/oracle/emu2.py`). No captures of the running commercial plugin were
used. RTTI names are read straight from the PE. All coefficient dumps are for
**SR = 96000 Hz** (what the tests use) unless a SR sweep is shown.

Scripts that produced everything below (all in `scratchpad/oracle/`):
`rtti_names.py`, `dump_modes_1_5.py`, `dump_modes_1_5_clean.py` (authoritative
structural dump → `modes_1_5_structural.json`), `desc_modes.py`,
`mode1_recall_sweep.py` (→ `mode1_recall_sweep.json`, `mode1_luts.c`),
`finalize_modes_1_5.py`, `sr_sweep_modes_1_5.py`.

---

## 0. TL;DR

* **EFFECT TYPE mode 1 = DISTORTION + PANNER.** Internal class
  `sCDSPSystem8::DlyPan` (vtable RVA 0x9c1618). A cubic-polynomial waveshaper
  (hard clip to ±1) feeding a stereo panner whose position is the EFFECT TONE
  knob. Param-DB names are "DS Drive / DS Level / DS Mute / DS TONE" ("DS" =
  distortion). Master engine block **86288…87152**. **Not a chorus.**
* **EFFECT TYPE mode 5 = a second CHORUS / ENSEMBLE variant.** Internal class
  `sCDSPSystem8::DlyMfx1` (vtable RVA 0x9c18a0). BBD-style modulated delay +
  LFO + comb/allpass network, param-DB names "Delay Time / LFO Rate / LFO Depth
  / Ip Fc / On/Off / Mute". Master engine block **96336…96912**. It is a chorus
  *family* member but a **different class with different coefficients** than the
  mode-2/3/4 chorus (`DlyCh`): e.g. Delay Time 0x3c1abc15 vs 0x3c0e0000, LFO
  Depth 0x3b442984 vs 0x3b83126f.

So: of the two "unshipped" modes, **mode 1 is a distinct effect (distortion),
mode 5 is a chorus variant** — matching the task's hypothesis.

---

## 1. The decompiled mode selector (ground truth for identity)

The effect container is the embedded object at `ST_END+0x10` (RTTI
`CPrmDSPJu60Plugin`, vtable RVA 0x9c3018). `cont+1480` holds the mode 0..5. Three
functions dispatch on it; the identity comes from **`sub_7FF91E018180` @ RVA
0x3B8180** (per-mode sub-effect config, `decomp_380000.c:23315`) and the
container setSampleRate **`sub_7FF91E01C980` @ 0x3BC980** (`:25783`):

```
switch (*(int*)(a1+1480)) {                 // cont+1480 = EFFECT TYPE 0..5
  case 0: v3 = a1+6784;  ... }   // sub-effect @cont+6784
  case 1: v4 = a1+6976;  ... }   // sub-effect @cont+6976   <-- MODE 1
  case 2: v5 = a1+7184;  ... }   // sub-effect @cont+7184
  case 3: v6 = a1+7400;  ... }   // sub-effect @cont+7400
  case 4: v7 = a1+7616;  ... }   // sub-effect @cont+7616
  case 5: v8 = a1+7824;  ... }   // sub-effect @cont+7824    <-- MODE 5
```

Each `cont+off` is a distinct C++ object; its first qword is the class vtable.
Reading the RTTI Complete-Object-Locator → TypeDescriptor for each vtable
(`rtti_names.py`) gives the class identities:

| mode | sub-effect @ | vtable RVA | RTTI class            | effect (param-DB) |
|------|--------------|-----------|------------------------|-------------------|
| 0    | cont+6784    | 0x9c1550  | `sCDSPSystem8::DlyDly`  | Overdrive ("OD")  |
| **1**| **cont+6976**| **0x9c1618** | **`sCDSPSystem8::DlyPan`** | **Distortion+Pan ("DS")** |
| 2    | cont+7184    | 0x9c16e0  | `sCDSPSystem8::DlyCh`   | Chorus            |
| 3    | cont+7400    | 0x9c16e0  | `sCDSPSystem8::DlyCh`   | Chorus (same class as 2) |
| 4    | cont+7616    | 0x9c17c0  | `sCDSPSystem8::DlyFlSt` | Flanger-Stereo    |
| **5**| **cont+7824**| **0x9c18a0** | **`sCDSPSystem8::DlyMfx1`** | **Chorus/Ensemble variant** |
| dflt | cont+8176    | 0x9de990  | `CDSPRev`               | Reverb            |

(The prior notes' "OD/DS" guesses were only param-DB labels; the RTTI above is
the authoritative class identity. NOTE: mode 4 is a *different* class
(`DlyFlSt`) from modes 2/3 (`DlyCh`), a nuance the "modes 2/3/4 are byte-identical
chorus" claim glosses over — but mode 4 is unused by the factory bank so it is
out of scope here.)

### Confirmed against the master DSP consumer (`src/master_render.c`)
`v551 = **(*(a1+136)+112)` is EFFECT TYPE. Its branches read exactly the blocks
above: `v551==1` → 86096…87152 (line 2353), `v551==5` → 95888…96912 (line 2605),
`v551∈{2,3,4}` → the chorus block 90368…91728, `v551==0` → 84960…86080.
The **mode-1 branch is a cubic waveshaper** (`v714*v714*v714`, `fminf(.,1.0)`
hard-clips, cascaded stages) ending in a **panner** at line 2455-2469 where
`*(a1+87056)` ("DS TONE", range −1..+1) crossfades L/R — hence the class name
`DlyPan`. The **mode-5 branch is a chorus** (LFO via `juno_wrap_unit` on
96352/96368, fractional BBD delay line at 96928 + comb/allpass 96432…96592).

---

## 2. MODE 1 (Distortion+Pan) — structural coefficient table @ 96000 Hz

Dumped from the binary by the faithful sequence **BUILD → snap-all
(`0x3C29B0`) → setSampleRate (`CWaveGen::setSampleRate 0x3C7A20`, XMM1=f32(SR),
structural last)** — `dump_modes_1_5_clean.py` → `modes_1_5_structural.json`.
"engine_offset" is part-relative (the offset `master_render` reads). All 35
structural cells were reached bit-exactly; the 4 non-structural cells (per-patch
/ enable) are covered in §3.

| off | hex @96k | float | kind | SR |
|----:|----------|------:|------|----|
| 86288 | *per-patch* | — | DS Drive  | see §3 |
| 86304 | *per-patch* | — | DS Level  | see §3 |
| 86320 | *enable*    | — | DS Mute   | see §3/§6 |
| 86352 | 0x3c800000 | 0.015625 | structural | const |
| 86368 | 0x407e8800 | 3.97705 | structural | SR-fam |
| 86384 | 0xc07e8800 | −3.97705 | structural | SR-fam |
| 86400 | 0x3f7f1400 | 0.996399 | structural | SR-fam |
| 86416 | 0x3d99569d | 0.0748722 | structural | const |
| 86432 | 0xbf54c86e | −0.831183 | structural | const |
| 86448 | 0x40133d75 | 2.30063 | structural | const |
| 86464 | 0x3d2d79d5 | 0.0423525 | structural | SR-fam |
| 86480 | 0x3b6b3350 | 0.00358887 | structural | SR-fam |
| 86496 | 0x3ec00000 | 0.375 | structural | const |
| 86512 | 0x80003951 | −2.05e-41 (≈−0) | structural | const |
| 86528 | 0x3f4e9e15 | 0.8071 | structural | const |
| 86544 | 0x4094bcb8 | 4.64804 | structural | const |
| 86560 | 0x4124bbc3 | 10.2958 | structural | const |
| 86576 | 0x3e180000 | 0.148438 | structural | const |
| 86592 | 0x396b3333 | 0.000224304 | structural | SR-fam |
| 86608 | 0x3d81a000 | 0.0632935 | structural | SR-fam |
| 86624 | 0xbd81a000 | −0.0632935 | structural | SR-fam |
| 86640 | 0x3f7f8c00 | 0.99823 | structural | SR-fam |
| 86816 | 0x3f000000 | 0.5 | structural | const |
| 86832 | 0x3e800000 | 0.25 | structural | const |
| 86848 | 0x3f400000 | 0.75 | structural | const |
| 86864 | 0x43570e23 | 215.055 | structural | const |
| 86880 | 0x3fc00000 | 1.5 | structural | const |
| 86896 | 0xbf000000 | −0.5 | structural | const |
| 86912 | 0x3da03143 | 0.078219 | structural | SR-fam |
| 86928 | 0x3dcb79b5 | 0.0993532 | structural | SR-fam |
| 86944 | 0x3e12e1bc | 0.143439 | structural | SR-fam |
| 86960 | 0x3e3748c7 | 0.178989 | structural | SR-fam |
| 87056 | *per-patch* | — | DS TONE | see §3 |
| 87072 | 0x4068ca68 | 3.63735 | structural | SR-fam |
| 87088 | 0xc05a0840 | −3.40675 | structural | SR-fam |
| 87104 | 0x3f44f760 | 0.7694 | structural | SR-fam |
| 87120 | 0x3f831cb4 | 1.02431 | structural | SR-fam |
| 87136 | 0xbf759990 | −0.959374 | structural | SR-fam |
| 87152 | 0x3f7bd2fc | 0.983688 | structural | SR-fam |

`SR` column (`sr_sweep_modes_1_5.py`, dumps at 44100/48000/96000):
* **const** — identical across all three SRs (fixed constant, ship as-is).
* **SR-fam** — 48000 and 96000 are **bit-identical**, 44100 differs. These effect
  coefficients are quantized to an SR *family* (44.1k vs 48k/96k), not continuous
  in SR. At the test rate 96000 the table above is exact; a 44.1k build needs the
  44100 column (in `sr_sweep_modes_1_5.py` output).

---

## 3. MODE 1 — per-patch recall (VERIFIED, bit-exact)

Driven by the plugin's real value-tree dispatch `sub_7FF91E019A30(this, idx, 1,
value)` (harness `scratchpad/unit2/emu_valuetree.py`), primed with **EFFECT
TYPE(idx 873)=1**, then sweeping EFFECT DEPTH(idx 794) and EFFECT TONE(idx 874)
0..255 (`mode1_recall_sweep.py`). Byte positions match the already-validated
chorus recall: EFFECT DEPTH = blob 50, EFFECT TONE = rec 642, EFFECT TYPE = rec
634 (`fx_recall_findings.md §2`).

| source byte | transform | engine off | name | notes |
|---|---|---|---|---|
| EFFECT DEPTH (blob 50) | `MODE1_DS_DRIVE_LUT[b]` (256, bit-exact) | 86288 | DS Drive | 0→0.0, 255→1.0, monotone; LUT saved |
| EFFECT DEPTH (blob 50) | constant `0x41008081` (8.03137) | 86304 | DS Level | constant for **every** depth (like chorus Dry) |
| EFFECT TONE (rec 642) | `MODE1_DS_TONE_LUT[b]` (256, bit-exact) | 87056 | DS TONE (pan) | bipolar −1..+1, closed form below |
| EFFECT DEPTH (blob 50) | `EFFECT_SW_LUT[b]` (256) | 84544 | Effect SW | **shared** slot-2 wet ctrl (all modes) |

**DS TONE (87056) closed form is exact** (verified over all 256):
```
tone <  128 :  (tone - 127) / 127.0
tone >  128 :  (tone - 128) / 127.0
tone == 127|128 : 0.0        (two-code centre dead-band)
```
(e.g. tone=0→−1, 64→−63/127=−0.496063, 128→0, 200→+72/127=0.566929, 255→+1.)
It is the pan position; the master panner crossfades L/R by it.

**Effect SW (84544)** is not mode-1-specific — it is the shared slot-2 effect
wet/enable that `master_render` reads at line 807 for **all** modes and stores to
84576. It is driven by EFFECT DEPTH through a saturating curve
(`0→0.0, depth 1→0.0574, 32→0.7418, 63→0.9954, ≥64→1.0`). It is **not currently
recalled in `src/`** (`grep` finds no writer; only `84560 "Mute SW" = 1.0` is set
by `juno_prepare.c`). Flagged as a likely gap affecting every effect mode.

LUT bodies (bit-exact) written to `scratchpad/oracle/mode1_luts.c`:
`MODE1_DS_DRIVE_LUT`, `MODE1_DS_TONE_LUT`, `EFFECT_SW_LUT`.

---

## 4. MODE 5 (Chorus/Ensemble variant) — structural coefficient table @ 96000 Hz

Same faithful sequence; `modes_1_5_structural.json`. All 33 structural cells
reached bit-exactly.

| off | hex @96k | float | kind | SR |
|----:|----------|------:|------|----|
| 96336 | 0x3c1abc15 | 0.00944426 | structural (Delay Time) | **SR-continuous** |
| 96352 | *per-patch* | — | LFO Rate | see §5 |
| 96368 | 0x3b442984 | 0.0029932 | structural (LFO Depth) | const |
| 96384 | *enable*    | — | Ip Fc | see §5/§6 |
| 96400 | *per-patch* | — | On/Off | see §5 |
| 96416 | *enable*    | — | Mute | see §5/§6 |
| 96432 | 0x3f7fddb4 | 0.999477 | structural | SR-fam |
| 96448 | 0xbf7fddb4 | −0.999477 | structural | SR-fam |
| 96464 | 0x3f7fbb68 | 0.998953 | structural | SR-fam |
| 96480 | 0x3cb5ba65 | 0.0221836 | structural | SR-fam |
| 96496 | 0x3d35ba65 | 0.0443672 | structural | SR-fam |
| 96512 | 0x3cb5ba65 | 0.0221836 | structural | SR-fam |
| 96528 | 0x3fbaa8e9 | 1.45828 | structural | SR-fam |
| 96544 | 0xbf0c091e | −0.547014 | structural | SR-fam |
| 96560 | 0x3f79634c | 0.974171 | structural | SR-fam |
| 96576 | 0xbf79634c | −0.974171 | structural | SR-fam |
| 96592 | 0x3f72c698 | 0.948343 | structural | SR-fam |
| 96608 | 0x3f700000 | 0.9375 | structural | const |
| 96624 | 0x3e900000 | 0.28125 | structural | const |
| 96640 | 0x3b135691 | 0.0022482 | structural | SR-fam |
| 96656 | 0x3f100000 | 0.5625 | structural | const |
| 96672 | 0x3ee00000 | 0.4375 | structural | const |
| 96688 | 0x396b65e0 | 0.000224493 | structural | SR-fam |
| 96704 | 0x3a6b65df | 0.000897972 | structural | SR-fam |
| 96720 | 0x3f000000 | 0.5 | structural | const |
| 96736 | 0x3f000000 | 0.5 | structural | const |
| 96752 | 0x40000000 | 2.0 | structural | const |
| 96768 | 0x3ea00000 | 0.3125 | structural | const |
| 96784 | 0x350637bd | 5e-07 | structural | SR-fam |
| 96800 | 0x40bb8000 | 5.85938 | structural | SR-fam |
| 96816 | 0x39000000 | 0.00012207 | structural | const |
| 96832 | 0x38800000 | 6.10352e-05 | structural | const |
| 96848 | 0x3d800000 | 0.0625 | structural | SR-fam |
| 96864 | 0x3c000000 | 0.0078125 | structural | const |
| 96880 | 0xbc000000 | −0.0078125 | structural | const |
| 96896 | 0x3fb4fdf4 | 1.414 (≈√2) | structural | const |
| 96912 | 0x3f34fdf4 | 0.707 (≈1/√2) | structural | const |

* **96336 Delay Time** is the only cell continuously SR-dependent (44100=0x3b8c0000,
  48000=0x3b98bc15, 96000=0x3c1abc15) — recompute per SR. (Matches the chorus
  block-A/B Delay-Time behaviour.)
* **96368 LFO Depth** = 0x3b442984 fixed constant.
* SR-fam cells: 48000==96000 bit-identical, 44100 differs.

---

## 5. MODE 5 — per-patch recall (VERIFIED; already in `src/`)

Same primed value-tree dispatch, EFFECT TYPE=5 (`chorus_mode_test.py`,
`chorus_verify.py`). This is already implemented in `src/chorus_recall.c` +
`src/chorus_luts.h`:

| source byte | transform | engine off | name | evidence |
|---|---|---|---|---|
| EFFECT DEPTH (blob 50) | `b / 255.0` (linear) | 96400 | On/Off | 0 mismatches /256 vs b/255 |
| EFFECT TONE  (rec 642) | `CHORUS5_LFORATE_LUT[b]` (256) | 96352 | LFO Rate | LUT in `src/chorus_luts.h` |

(EFFECT DEPTH also writes the shared 84544 "Effect SW" =`EFFECT_SW_LUT[depth]`,
same as §3.)

---

## 6. HONEST GAPS — the enable-gate cells (flagged, not directly driven)

Three cells are **multiplicative enable gates** that master_render multiplies the
effect output by, so they must equal their *enabled* value when the mode is
active — but they could **not** be reached in emulation. This is the same
documented limitation as the mode-5 chorus in `chorus_structural_findings.md §5`:
sub-effects other than the default mode-2 chorus are **constructed but never
enabled**, so their param smoother-targets stay 0 and neither snap-all nor a
driven `setActive` (`sub_7FF91E0193E0`, RVA 0x3B93E0) populates them. I confirmed
this directly: `dump_modes_1_5.py` drives the full setActive for modes 1 and 5 →
**0 effect-region cells written** (the enable chain no-ops because dependent state
isn't allocated), and `desc_modes.py` shows the mode-2 twins (91248 Ip Fc,
91280 Mute) DID get their targets from BUILD while the mode-1/5 equivalents read 0.

| off | name | best value | grounding |
|---|---|---|---|
| 86320 | DS Mute (mode 1) | `0x3f800000` (1.0) | multiplicative gate `out*=DS_Mute` (master line 2443); enabled value = 1.0, same as the derived chorus Mute 91280=1.0 and the prepare constant `84560 "Mute SW"=1.0` (`juno_prepare.c`) |
| 96384 | Ip Fc (mode 5) | `0x37ffd974` | identical "Ip Fc" param of the chorus family; its block-A twin 91248=0x37ffd974 WAS derived from the binary via snap-all |
| 96416 | Mute (mode 5) | `0x3f800000` (1.0) | identical "Mute" gate; block-A twin 91280=1.0 derived from the binary |

These 3 are transferred from their binary-derived twins + confirmed by the DSP
structure (a gate that must be 1.0/Fc-constant when the effect passes audio). They
are the ONLY values in this report not driven directly from the binary for their
own offset. Everything else (72 structural cells + all per-patch LUTs) is
bit-exact from the binary.

---

## 7. Bottom line for the C port

* **Route `v551 = EFFECT TYPE` (rec 634) per patch** (as v39 already follows DELAY
  TYPE). A mode-1 patch then reads the 86288-block, a mode-5 patch the 96336-block.
* **Mode 1 (distortion+pan):** ship the §2 structural table @ target SR (const +
  SR-fam split; use 44100 column for a 44.1k build). Recall per patch:
  `86288 = MODE1_DS_DRIVE_LUT[depth]`, `86304 = 0x41008081`,
  `87056 = MODE1_DS_TONE_LUT[tone]`, `86320 = 1.0` (§6). LUTs in `mode1_luts.c`.
* **Mode 5 (chorus variant):** ship the §4 structural table; `96336` recompute per
  SR; recall `96400 = depth/255`, `96352 = CHORUS5_LFORATE_LUT[tone]` (already in
  `src/chorus_recall.c`); `96384 = 0x37ffd974`, `96416 = 1.0` (§6).
* **Also (all modes):** `84544 "Effect SW" = EFFECT_SW_LUT[depth]` is a shared
  slot-2 wet control currently NOT recalled in `src/` — verify against the bank
  whether it must be applied.

## Artifacts (scratchpad/oracle/)
`effect_modes_1_5_findings.md` (this) · `modes_1_5_structural.json` (offset→hex,
modes 1 & 5, @96k) · `mode1_recall_sweep.json` (full 256-pt sweeps) ·
`mode1_luts.c` (MODE1_DS_DRIVE_LUT / MODE1_DS_TONE_LUT / EFFECT_SW_LUT) ·
`rtti_names.py` · `dump_modes_1_5.py` · `dump_modes_1_5_clean.py` ·
`desc_modes.py` · `mode1_recall_sweep.py` · `finalize_modes_1_5.py` ·
`sr_sweep_modes_1_5.py`.
