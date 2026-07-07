# FX per-patch recall — findings (JUNO-60 / JU-06A VST3)

Ground truth = the binary only (`aea4b19d-JUNO60VST3_64bit.vst3`), driven under
Unicorn. No captures of the running commercial plugin were used; the one
cross-reference to `src/runtime_coeffs_data.c` is itself a binary-derived table
and is used only as an *independent* check, never as a source.

## TL;DR

The master DSP (`sub_180363380` / `src/master_render.c`) reads ~156 bound FX cells.
Their per-patch VALUE SOURCE splits cleanly into three groups:

1. **Delay block (102352…)** — already covered bit-exact by `src/delay_recall.c`.
2. **Reverb-ECF (10759…)** — the two per-patch cells covered by `src/reverb_recall.c`;
   the rest of that block is prepare-constant.
3. **Chorus blocks (91120… and 96336…)** — NOT previously covered. This is the new
   result. The chorus is driven per-patch by exactly three front-panel/deep bytes:
   `EFFECT TYPE` (mode/routing), `EFFECT DEPTH` (wet), `EFFECT TONE` (noise / LFO rate).
   The block's *structural* constants (LFO rate/phase/depth, BBD delay time, error
   depth) are mode-selected PREPARE outputs, not per-byte curves.

Everything below labelled **VERIFIED** was reproduced bit-for-bit by running the
plugin's own value-tree dispatch `sub_7FF91E019A30`; the two harnesses used are the
processor value-tree oracle (`emu_valuetree.py`, VT) and the full-instance builder
(`tools/oracle/emu2.py`, CWaveGen::build @0x3C68D0).

---

## 1. FX topology & gating (from the binary)

Two effect slots, each an integer selector chased through `state+136`:

| slot | selector | driven by | master switch |
|---|---|---|---|
| 1 | `v39 = **(*(a1+136)+136)`  | DELAY TYPE (`state[JUNO_PROG_DLY]`) | line 860 |
| 2 | `v551 = **(*(a1+136)+112)` | EFFECT TYPE | line 2351 |

Which engine block each selector value makes the master read (verified by reading
the offset references inside each branch of `master_render.c`):

**slot 1 (v39 = DELAY TYPE):**
- `0` (and default) → **delay** block `102352…102688`  (LABEL_69)   ← delay_recall
- `1` → BBD/tap-delay block `4297584…4297984`
- `2,3` → chorus block `6395312 / 6396xxx`
- `4,5` → flanger `6429xxx/6430xxx` + delay2 `6497xxx` + chorus2 `10692xxx`

**slot 2 (v551 = EFFECT TYPE):**
- `0` → OD block `84544/85136/85152/85984`
- `1` → DS/distortion block `86288/86304/87056`
- `2,3,4` → **chorus block `91120…91280`**   ← THE JUNO-60 chorus (tests use v551=2)
- `5` → chorus block `96336…96416`

The JUNO-60 uses the slot-2 chorus (`91120`); the tests/driver set `chorus_mode=2`.
`EFFECT TYPE` range is 0–5, default 2 (Script.xml line 1522).

Bank distribution of EFFECT TYPE across the 64 presetbankog1 patches:
`{1:1, 2:33, 3:22, 5:8}` → 33 use the `91120` block at mode 2, 22 at mode 3, 8 use
the `96336` block at mode 5, 1 uses distortion. (No mode 0 or 4.)

---

## 2. Per-patch driving bytes (record/blob positions) — VERIFIED

Byte positions are cross-checked against the ALREADY-VALIDATED delay/reverb recall,
which pin `DELAY TYPE = rec 650 / dispatch 875` and `REVERB TIME = rec 666 / dispatch
877`. The effect-selector block is locally contiguous in both the record stream
(`rec = 8·leaf − 414`) and the dispatch DB (`dispatch = leaf + 742` in this block):

| param | record/blob pos | dispatch idx | range | note |
|---|---|---|---|---|
| EFFECT DEPTH | **blob 50** | 794 | 0–255 | front-panel EFX |
| EFFECT TYPE  | **rec 634**  | 873 | 0–5   | = v551 mode selector |
| EFFECT TONE  | **rec 642**  | 874 | 0–255 | |
| DELAY TYPE   | rec 650      | 875 | 0–5   | = v39 (delay_recall) |
| REVERB TYPE  | rec 658      | 876 | 0–5   | (unused by master) |
| REVERB TIME  | rec 666      | 877 | 0–255 | (reverb_recall) |

`blob_val(rec,bp) = ((b[2bp]&0xF)<<4)|(b[2bp+1]&0xF)`, blob=rec+16.
`rec_byte(rec,off) = ((rec[off]&0xF)<<4)|(rec[off+1]&0xF)`.

---

## 3. THE FX RECALL TABLE (deliverable, C-ready)

Format like `juno_apply.c` BINDINGS: `{source byte, transform, engine_offset, name}`.
`curve` = LUT means a 256-entry byte→bits table captured from the dispatch (as
delay/reverb already do). LUTs saved to `scratchpad/oracle/chorus_luts.c` and
`chorus_luts.json`.

### 3a. Mode selectors (per patch) — VERIFIED
```
EFFECT TYPE  rec 634  -> v551 (slot-2 mode)   [driver must route v551 = this per patch]
DELAY TYPE   rec 650  -> v39  (slot-1 mode)   [already: state[JUNO_PROG_DLY]]
```
Both are bit-exact reads from the bank (`bank_fx_scan.py`).

### 3b. CHORUS block 91120 — EFFECT TYPE ∈ {2,3,4} — NEW, VERIFIED
The per-patch levels are identical for modes 2/3/4 (confirmed: the dispatch writes
the same 91200/91216/91232 for all three).

| source byte | transform | engine off | name | evidence |
|---|---|---|---|---|
| EFFECT DEPTH (blob 50) | `CHORUS_WET_LUT[b]`   | 91232 | Wet Level  | LUT via idx794; 0→0.0, 255→1.17 (0x3f95c28f) |
| EFFECT DEPTH (blob 50) | constant `1.3` (0x3fa66666) | 91216 | Dry Level | idx794 writes 1.3 for **every** depth 0..255 |
| EFFECT TONE  (rec 642) | `CHORUS_NOISE_LUT[b]` | 91200 | Noise Level | LUT via idx874; ≈ tone/255·0.005 (±1 ULP, so LUT) |

Structural constants of this block (NOT per-byte; mode-2 PREPARE outputs, written by
CWaveGen::build, reproduced BIT-EXACT and equal to runtime_coeffs mode-II):
```
91120 Delay Time  = 0x3c0e0000   91168 LFO Phase = 0x3f800000
91136 Error Depth = 0x3f77b282   91184 LFO Depth = 0x3b83126f
91152 LFO Rate    = 0x3727c5ac   91264 On/Off    = 0x3f800000
91248 Ip Fc = 0x37ffd974  91280 Mute = 0x3f800000   (enable-step constants)
```

### 3c. CHORUS block 96336 — EFFECT TYPE == 5 — NEW, VERIFIED (levels)
Different routing than modes 2/3/4:

| source byte | transform | engine off | name | evidence |
|---|---|---|---|---|
| EFFECT DEPTH (blob 50) | `b/255.0` (linear) | 96400 | On/Off  | idx794; **0 bit-mismatches /256** vs b/255 |
| EFFECT TONE  (rec 642) | `CHORUS5_LFORATE_LUT[b]` | 96352 | LFO Rate | LUT via idx874 |

Structural constants of the 96336 block (Delay Time 96336, LFO Depth 96368, Ip Fc
96384, Mute 96416) are the mode-5 PREPARE outputs — see the FLAGGED section: my
BUILD only triggered the default (mode-2) chorus prepare, so these came out 0 and
are taken from the runtime_coeffs live capture, NOT independently re-derived.

### 3d. DELAY block 102352 — DELAY TYPE == 0 — ALREADY COVERED (delay_recall.c)
Confirmed the offsets delay_recall writes are exactly the master's v39==0 per-patch
coefficient reads; the cells it does NOT write (102000–102336 buffer taps, 102448
Use-IIR=0, 102496 High-Cut-Sw=0, 102704–102784 filter state) are runtime STATE, not
patch coefficients — correctly not recalled.

### 3e. REVERB-ECF 10759… — global — ALREADY COVERED (reverb_recall.c)
`10759408 Rev Ecf Level = REVLVL_LUT[REVERB LEVEL blob51]`,
`10759680 Rev Ecf DPF0 Lp = REVTIME_LUT[REVERB TIME rec666]`.
The other reverb-ECF cells the master reads (Density 10759392, Dir/Glb Lev, Depth,
Rate, HPF/LPF/DPF coeffs) are PREPARE-constants (in runtime_coeffs), not per-patch.

---

## 4. Verification evidence

- **Harness A (processor value-tree, `emu_valuetree.py`)**: constructs the real
  processor `sub_7FF91E013320`, drives `sub_7FF91E019A30(this, idx, 1, value)`,
  captures each engine cell write. Reproduces the known delay rows (idx796→102528 =
  0x3f48c8c9 at value 200 = 200/255) and the front-panel anchors.
- **Key discovery**: EFFECT DEPTH / EFFECT TONE are *mode-routed* — they write to
  whichever effect block EFFECT TYPE (idx 873) currently selects. With EFFECT
  TYPE=2/3/4 they write the 91120 chorus block; with 5 the 96336 block; with 0/1 the
  OD/DS blocks (`chorus_mode_test.py`). This is why an un-primed dispatch sweep saw
  no chorus writes — the sequence must set EFFECT TYPE first.
- **Bit-exact cross-check vs the independent runtime_coeffs live capture**
  ("PD The Juno Pad", chorus mode II): my LUTs reproduce it exactly —
  `CHORUS_WET_LUT[255] = 0x3f95c28f` (= its Wet), `Dry = 0x3fa66666`, and
  `CHORUS_NOISE_LUT[55] = 0x3a8d5a27` (= its Noise). I.e. that preset had EFFECT
  DEPTH=255, EFFECT TONE=55, and the recall reconstructs both cells bit-for-bit
  (`chorus_final_capture.py`, `struct_and_coverage.py`).
- **Mode-5 On/Off = depth/255**: 0 mismatches over all 256 (`chorus_verify.py`).
- **Structural mode-2 constants**: CWaveGen::build reproduces the 91120 structural
  cells (Delay Time / Error Depth / LFO Rate / LFO Phase / LFO Depth / On/Off)
  bit-exact vs runtime_coeffs (`struct_and_coverage.py`).

---

## 5. HONEST GAPS — flagged, never guessed

1. **Per-MODE structural chorus constants (modes 3 & 4 vs 2, and mode 5).**
   The master reads the same `91120` block for EFFECT TYPE 2, 3, and 4, but the
   *structural* LFO/BBD constants that distinguish Chorus I / II / I+II are written
   by the effect object's mode-select PREPARE (the reverb harness located it in
   `setSampleRate` case0..5 switching on part+1480), a step that neither
   CWaveGen::build nor CWaveGen::setSampleRate reached in emulation (the effect
   objects other than the default mode-2 chorus stay inert — their smoother vector
   is built in a later setActive step). Consequently only the **mode-2** structural
   block is independently derived. Whether modes 3/4 differ from mode 2 (and the
   entire mode-5 `96336` structural block) is **UNRESOLVED**. In the bank this
   affects 22 mode-3 patches + 8 mode-5 patches. Recommended follow-up: drive the
   per-mode effect PREPARE / setActive on the full CJu60Sim part (part+1480 = mode,
   then the effect's prepare vtable slot) and re-read the block per mode.

2. **CHORUS deep-edit params** (Script.xml PAT2_CHO: CHORUS PRE DELAY, LOW CUT, HIGH
   CUT, LFO SOURCE, LFO EXT GAIN/OFFSET). No dispatch index was found that writes the
   master-read `91120/96336` cells from these; they presumably feed the mode PREPARE
   or are inert on the JUNO-60. Their per-patch effect on the master-read cells could
   NOT be demonstrated from the binary → treat as not-driving until (1) is resolved.
   (For a genuine JUNO-60 bank these are expected to be at their defaults on every
   patch; that should be checked against the bank before relying on it.)

3. **Ip Fc (91248) and Mute (91280)** in the mode-2 chorus are set by the effect
   ENABLE step, not by any per-byte dispatch. Their values (0x37ffd974, 1.0) are
   prepare/enable constants, taken from the runtime_coeffs baseline; they are NOT
   per-patch, but they are also not re-derived here beyond the build's mode-2 result.

---

## 6. Integration notes (for the C port; research only — no src edits made)

- The driver currently hardcodes `v551 = chorus_mode` (constant 2). To honour the
  patch, route **`v551 = EFFECT TYPE` (rec 634)** per patch, exactly as v39 already
  follows DELAY TYPE. Then a mode-5 patch reads the `96336` block, a mode-1 patch the
  distortion block, etc. (Doing so also requires those blocks to be correctly
  populated — see gap #1 for modes 3/4/5.)
- Add a `juno_apply_chorus(state, rec)` analogous to delay/reverb:
  ```
  int depth = blob_val(rec, 50);      /* EFFECT DEPTH */
  int tone  = rec_byte(rec, 642);     /* EFFECT TONE  */
  int etype = rec_byte(rec, 634);     /* EFFECT TYPE  -> v551 */
  if (etype in {2,3,4}) {
      JF(state, 91216) = 1.3f;                                  /* Dry  const  */
      JF(state, 91232) = bits(CHORUS_WET_LUT[depth]);           /* Wet         */
      JF(state, 91200) = bits(CHORUS_NOISE_LUT[tone]);          /* Noise       */
  } else if (etype == 5) {
      JF(state, 96400) = depth / 255.0f;                        /* On/Off      */
      JF(state, 96352) = bits(CHORUS5_LFORATE_LUT[tone]);       /* LFO Rate    */
  }
  ```
  LUT bodies are in `scratchpad/oracle/chorus_luts.c`.

## Files produced (scratchpad/oracle/)
- `fx_recall_findings.md` (this file)
- `chorus_luts.c` / `chorus_luts.json` — CHORUS_WET_LUT, CHORUS_NOISE_LUT, CHORUS5_LFORATE_LUT (256-entry, bit-exact)
- `chorus_curves.json` — raw dry/wet/noise sweeps
- `fx_idx_to_off.json` — dispatch-index → engine-offset map (processor VT)
- probes: `chorus_mode_test.py`, `chorus_full_sweep2.py`, `chorus_verify.py`,
  `chorus_final_capture.py`, `struct_and_coverage.py`, `chorus_prepare_probe.py`,
  `bank_fx_scan.py`, `fx_sweep.py`
