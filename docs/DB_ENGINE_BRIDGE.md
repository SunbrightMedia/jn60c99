# DB-index → engine bridge (JUNO-60 capture-free preset path)

Bridges the proven, DB-indexed factory-bank decode (`refs/preset_bank.json`,
DB 755..877) to the working param-apply engine (`src/juno_params.c`,
`docs/PARAM_MAP.tsv`) so factory presets — in particular **SQ Dynamic ARPG** — can be
rendered without a runtime capture.

Deliverables: `refs/db_engine_bridge.json` (the mapping), `refs/sqarpg_engine_steps.json`
(SQ ARPG applied), this doc.

---

## 1. Which path worked — **Path B (semantic + ordered alignment)**

**Path A (static translation) was conclusively ruled out**, confirming the
`refs/default_patch.json` `_meta` boundary with disassembly evidence:

- The patch-model that receives all 4966 DB defaults (`CPrmDSPSystem8Dly<CPrmDSPJu60>`,
  ctor rva 0x3B3320, vtable rva 0x9C19F8) exposes its registration setter at **vtable+88
  = rva 0x3B1790 = `nullsub_1032` (`retn 0`)** — a no-op for the Juno class. The
  4966-default seeding loop (`decomp_3C0000.c:4987`) therefore stores nothing.
- The only runtime DB→engine binding is **`sub_7FF91E027AE0` (rva 0x3C7AE0)**: it looks
  up a **red-black tree** (root `qword_7FF91E910E18`) keyed by VST3 ParamID, reads the DB
  index from node+8, range-checks it against the DB record, and calls the **same vtable+88
  nullsub** with the DB index passed **verbatim** (no `db→offset` arithmetic). The tree
  seed is a static `{key, db_index}` immediate list (recoverable: DB755..814 key =
  `0x60000A + 2*(db-755)`), but it carries **no engine-paramID/offset** — that lives only
  in the descriptor registry `sub_388170`, keyed by engine paramID, which is exactly what
  `docs/PARAM_MAP.tsv` already captures. **No static numeric DB-index→offset map exists.**

What Path A *did* yield and is folded into the bridge: the engine's own **value-bias
transforms** in that switch — `case 769: value−11` (bipolar ±11), `case 871:
value=(v!=0)` (model bool), `case 665/20/707: −100`, `case 22: −12`.

So the bridge is built by **semantic alignment of the DB specs to the engine params**,
anchored on discrete selectors and validated across all 64 presets.

---

## 2. Decode correction (load-bearing)

`refs/preset_bank.json`'s `db_global_fx_params` (DB854..877) used a **wrong +200 offset**
that violated DB864/DB868 ranges. The correct global/FX decode is **stride-4 from the
reverb anchor**:

```
block-1 (DB755..853): pos = (db-755) + 11          # proven by embedded name anchor
block-2 (DB854..877): pos = 321 + (db-876)*4       # CORRECTED (was +200)
```

Range-fit on the 64-preset bank:

| block | params | within [min,max] for all 64 |
|---|---|---|
| block-1 DB755..853 | 83 | **83/83 (100%)** |
| block-2 DB854..877 (corrected stride-4) | 24 | **24/24 (100%)** |

The corrected block-2 makes every selector land on its semantic default
(DB870 master-tune = 128 center for all; DB872 filter = LPF-24; DB868 sub-osc wave in
0..5; DB876 reverb = HALL2 for SQ ARPG). The old +200 put DB868 at 0..255 (invalid) and
mis-identified the chorus selector. **All values in `sqarpg_engine_steps.json` use the
corrected decode.**

---

## 3. The mapping table

`engine_paramId` = base-voice paramID 0..109 (`PARAM_MAP.tsv`); the render broadcasts to
all 8 voices (`offset + 10512*v`). A DB step (0..255) **is** the engine LUT step
(`coefficient = lut[tableId][step]`) unless `value_bias` is noted.

### HIGH confidence

| DB | → engine target | offset | tableId | basis |
|----|-----------------|--------|---------|-------|
| **760** | OSC1 Feet (pid43) | 3840 | 5 | **statically proven** anchor; spec `64..2 FEET` identical+unique |
| **870** | Master Tune (pid3) | 368 | 6 | spec `-1200..+1200CENT` def=128 center, unique; all 64 = 128 |
| **800** | Key Assign `POLY1/MONO/UNISON/POLY2` | (voice-alloc mode) | — | unique spec; **validated**: BS 9/11 = MONO, all 12 PD = POLY1 |
| **873** | **JUNO Chorus mode** → driver `chorus_mode` | (master_render) | — | `…JUNO CH1\|JUNO CH2…`; the JUNO chorus selector (see §5) |
| **875** | System-8 FX-A type (delay/mod slot) | (FX chain) | — | `DELAY\|PAN DELAY\|CHORUS1\|CHORUS2\|FLANGER\|DELAY+CHORUS` |
| **876** | Reverb type | (FX chain) | — | `AMBIENCE\|ROOM\|HALL1\|HALL2\|PLATE\|MOD`; block-2 anchor |
| **872** | Filter type (LPF/HPF slope) | (VCF) | — | `LPF-24..HPF-24`; JUNO = LPF-24 |
| **871** | Model JUNO-60/106 | (driver) | — | bridge case 871 booleanizes; all 64 = JUNO-60 |

### MEDIUM confidence

| DB | → engine target | basis |
|----|-----------------|-------|
| **759** | PWM source → PWM SW {LFO/ENV1/ENV2/Manual} (pid46-49 one-hot) | `MAN\|LFO\|ENV1±\|ENV2±` 6-way → 4 engine switches; sign = ENV polarity. SQ ARPG=MAN |
| **769** | Coarse transpose ±11 (bridge bias −11) | bridge case 769 confirms ±11 bipolar; all 64 = 11 (=0 after bias) |
| **868** | Sub-osc waveform | unique spec; corrected decode gives valid 0..5 |

### LOW confidence (section-correct, exact target not bijective — render-improving, mark as tentative)

| DB | → tentative engine target | offset | tableId | basis |
|----|---------------------------|--------|---------|-------|
| 772 | JU OSC Sub Lev (pid65) | 4224 | 54 | BS mean 172 ≫ PD 30 → bass-heavy = SUB |
| 770 | JU OSC Sqr Lev (pid64) | 4208 | 54 | DCO mixer level (def128, all present) |
| 771 | JU OSC Saw Lev (pid63) | 4192 | 54 | DCO mixer level (def0) |
| 779 | Osc Noise Level (pid69) | 6528 | 12 | noise section, adjacent to PINK/WHITE selector DB775 |
| 795 | VCA ENV Sustain (pid33) | 2800 | 50 | PD 136 ≫ BS 52 (pads sustain); spec `OFF\|1..255` |
| 796 | VCA ENV Release (pid35) | 2832 | 38 | PD 93 ≫ BS 20 (pads release); spec `OFF\|1..255` |

Saw-vs-square and ENV1-vs-ENV2 assignments within these LOW rows are **not proven** — they
are section-level placements that move the render in the right direction.

---

## 4. Cross-preset validation evidence

- **Range constraint**: every mapped DB index's value lies within its DB `[min,max]` for
  all 64 presets (block-1 83/83, block-2 24/24).
- **Discrete semantics track patch category** (the strongest evidence the alignment is
  real, not coincidental):
  - DB760 feet: BS/BR lowest (16'/8'), bells highest — bass low, bells bright.
  - DB800 key-assign: BS→MONO(1) 9/11; **all** PD→POLY1(0); LD mostly MONO/UNISON.
  - DB873 chorus: PD lean to JUNO CH2(3) (lusher), BS/LD to CH1(2) — musically sensible.
- **DB868** range collapses from an impossible 0..255 (old decode) to a valid 0..5 once the
  stride-4 correction is applied — independent confirmation of the corrected block-2.

---

## 5. SQ Dynamic ARPG — chorus & LFO (the user's open question)

**The audible chorus/vibrato is a PRESET parameter, not a DSP/transcription artifact.**

SQ ARPG (record 1), decoded with the corrected mapping:

| param | DB | value | meaning |
|---|---|---|---|
| **Chorus mode** | DB873 | 2 | **JUNO CH1 = JUNO-60 Chorus I** |
| FX-A slot | DB875 | 0 | DELAY (no extra System-8 chorus) |
| Reverb | DB876 | 3 | HALL 2 |
| Filter type | DB872 | 0 | LPF -24dB |
| Model | DB871 | 0 | JUNO-60 |
| OSC1 feet | DB760 | 3 | 8' |
| Key assign | DB800 | 0 | POLY1 |
| Noise | DB775 | 1 (WHITE), DB779=90 | white noise, mid level |
| PWM source | DB759 | 0 | MANUAL |
| Sub-osc wave | DB868 | 1 | −1OCT SIN |
| Master tune | DB870 | 128 | center |

So **SQ ARPG renders with JUNO Chorus I engaged**. The chorus mode feeds
`master_render`'s `chorus_mode` selector (read through the host-params pointer at
state+136; `mode 0` = bypass). The DSP itself (`src/master_render.c`) is a faithful
BBD stereo chorus — per `docs/CHORUS_VIBRATO_DIAG.md` no transcription bug was found —
so the right action is to **drive `chorus_mode` to the JUNO Chorus-I value** rather than
to suppress the chorus. The remaining vibrato character is the patch's own LFO→pitch
(block-1), which differs from PD Juno Pad and will read differently once the (LOW-conf)
block-1 mod params are mapped.

**LFO**: SQ ARPG's LFO rate/delay/depth live in the block-1 continuous region that is
**not bijectively mapped** (see §6). They are decoded to DB index and present, but the
exact engine offset for LFO rate vs LFO→pitch depth vs LFO→VCF depth is not statically
provable in the System-8 multi-OSC layout, so they are deliberately left in the unmapped
set rather than guessed. The chorus answer above does **not** depend on them.

---

## 6. Honest list of unmapped / uncertain

Decoded to DB index (proven) but **not** bijectively bound to an engine paramID, so left
out of the apply set (no fabrication):

- **VCF cutoff / resonance / env-amount / env-polarity / LFO-amount / kbd**: candidates
  among DB783/788/793/797/810 (always-present/centered) and DB784/786 (pad≫bass =
  movement), but the exact System-8 offset is unproven.
- **ENV A/D/S/R (full)**: DB795/796 are tentatively VCA sustain/release (LOW); attack/decay
  and the ENV1-vs-ENV2 split are not pinned. DB858-861 (block-2, def 43/43/22/22) read only
  coarse quantized values across the bank — not the primary audible envelope.
- **LFO rate / delay / depth(s)** (see §5).
- **PWM depth** (DB766 is the only PWM-manual candidate, but all 64 = 128 → untouched).
- **DCO pulse/saw on-off** switches and **HPF** amount.
- block-2 globals DB854-857/862-867/869/874/877 (ENV/mod/level/drive-amount fields).

These are enumerated in `refs/db_engine_bridge.json → db_engine_unmapped`.

---

## 7. How to render SQ ARPG

1. `refs/sqarpg_engine_steps.json → engine_lut`: for each `{offset:{step,tableId}}` call
   `juno_param_apply_lut(state, offset, tableId, step, broadcast=1)`. (HIGH: feet, tune;
   LOW: DCO/VCA levels — apply for a closer render, they are range-safe.)
2. `driver_fx`: set the FX/driver selectors — **most importantly `chorus_mode` = JUNO
   Chorus I** (DB873=2), reverb = HALL 2 (DB876=3), filter = LPF-24 (DB872=0).
3. Key-assign POLY1, OSC1 8', white noise, manual PWM per the audible summary.

The result is a render meaningfully closer to the real SQ Dynamic ARPG: correct
oscillator range, key mode, noise, **and the real JUNO Chorus I** — each mapping
defensible, with continuous fine-detail params honestly flagged as tentative.
