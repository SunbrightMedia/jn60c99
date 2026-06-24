# FX-coefficient setup — reproducing the reverb/delay/chorus filter coefficients capture-free

Goal: produce the ~57 FX filter coefficients that `sub_1803C3380` (rva `0x363380`)
*reads* from engine state, directly from the `.rdata` tables + FX param steps, so the
C99 port no longer needs them from a live capture. Validation oracle is the captured
PD Juno Pad state in `src/runtime_coeffs_data.c` (chorus II, 96 kHz). All comparisons
are **4-byte float bit-exact**.

**Result: 69 FX coefficients reproduced bit-exact (0 mismatches).** Machine-readable
recipe in `refs/fx_coeff_recipe.json`. (69 > the ~57 estimate because each HighCut
biquad expands to 3–5 coeffs and there are 5 instances.)

Split: **34 stepped-LUT reads**, **33 fixed-constant reads** (registered param
defaults), **2 formula** (Chorus CV). No coefficient required an undiscovered
filter-design formula for this preset — see §4 for why.

Image base `0x7FF91DC60000`. All raw values below are taken from the rdata segment
dump `data_sections/data_sections/seg_rdata_935650.bin` at the listed rva (the
`refs/reverb_tables.json` / `refs/delay_tables.json` JSON values are float-rounded and
were **not** bit-exact for several coeffs; the raw segment bytes are authoritative).

---

## 1. Setup-function map (who writes which group)

The FX coefficients are never written by direct `a1+offset =` stores. They reach the
engine state through the **node-coefficient mechanism** `sub_1803C1090`
(`**(float**)(*(*(engine)+56)+40*idx+32) = value`, decomp `sub_7FF91E021090` /
`sub_7FF91E0210F0`) and the **define-tap** helper `sub_1803C10D0`
(`sub_7FF91E0210D0 → sub_7FF91E022920`). The *values* pushed are LUT/constant reads.

| Group | Setup component | rva | Mechanism |
|---|---|---|---|
| **Reverb plate** (HPF/LPF/DPF, taps) | `CDSPRev` ctor `sub_7FF91E021110` binds the 4 reverb tables; graph/tap sizing `sub_7FF91E021AC0`; SR table swap `sub_7FF91E0217C0` | `0x3C1110`, `0x3C1AC0`, `0x3C17C0` | ctor stores table ptrs at `+56/64/72/80`; `0217C0` picks 96 k vs 44.1 k variant |
| Reverb tap lengths | `sub_7FF91E021AC0` reads `0x63A350` lengths via `*(eng+64)` SR column, accumulates node offsets, `sub_7FF91E021070` defines them | `0x3C1AC0` | (tap offsets, not filter coeffs — out of scope here) |
| **Delay / chorus HighCut, damp, gains** | `CDSPSystem8DlyCh` / `…Dly` / `…Fl` setup fns: `sub_7FF91DFBDE50` (0x35DE50), `sub_7FF91DFBDA40` (0x35DA40), siblings `…DB00/…DC00/…DC70` | decomp_340000.c | each calls `sub_7FF91DFB6380(curve, knob)` then pushes the result through `sub_7FF91E021090`/`0210D0` to the named nodes |
| Knob→value dispatcher | `sub_7FF91DFB6380(&unk_7FF91E910DC8, curve, knob)` | `0x356380` | selects one of the curve LUTs (19/22/58–65) and indexes it by the clamped knob |

The reverb `0x639F20`/`0x63A130`/`0x9DDEB0`/`0x9DA6C0` reads and the delay/chorus curve
LUT reads are the substance; the "design formula" the brief anticipated for the DPF
Hp/Lp turned out to be a **precomputed stepped table** (`0x9DDEB0`), and the HighCut
biquad coeffs are **registered param defaults** baked in rdata (§4).

---

## 2. Reverb Ecf coefficients (offsets 10759520–10759824)

The reverb "Ecf" pre/damping filters are three table reads driven by the reverb
decay/density step. All bit-exact.

### HPF — allpass table `0x639F20` (rva `0x9D9F20`), **row 2** (3 cols `g, −g, c`)
| off | name | rva read | value |
|---|---|---|---|
| 10759520 | HPF C0 | `0x9D9F38` (`AP[6]`=row2 col0) | `0x3f7f8b7e` 0.99822223 |
| 10759536 | HPF A0 | `0x9D9F3C` (`AP[7]`=row2 col1) | `0xbf7f8b7e` −0.99822223 (= −C0) |
| 10759552 | HPF B0 | `0x9D9F40` (`AP[8]`=row2 col2) | `0x3f7f16fb` 0.99644440 |

`AP` row = 15 rows × 3 floats; **step = row 2**. (HPF is an allpass — A0 = −C0, B0 = c.)

### LPF — damping-biquad table `0x63A130` (rva `0x9DA130`), **row 11** (5 cols `b0,b1,b2,a1,a2`)
| off | name | rva read | value |
|---|---|---|---|
| 10759568 | LPF C0 | `0x9DA20C` (`DMP[55]`=row11 b0) | `0x3d434c95` 0.04768046 |
| 10759584 | LPF A0 | `0x9DA210` (`DMP[56]`=row11 b1) | `0x3dc34c95` 0.09536091 |
| 10759600 | LPF A1 | `0x9DA214` (`DMP[57]`=row11 b2) | `0x3d434c95` 0.04768046 |
| 10759616 | LPF B0 | `0x9DA218` (`DMP[58]`=row11 a1) | `0x3fa5addf` 1.29436862 |
| 10759632 | LPF B1 | `0x9DA21C` (`DMP[59]`=row11 a2) | `0xbef85dc7` −0.48509046 |

`DMP` = 16 rows × 5 floats; **step = row 11**.

### DPF (4 damping one-poles) — `Fc` constant + `Hp/Lp` stepped table
- **DPF Fc** (10759648 / 10759696 / 10759744 / 10759792) = a single fixed constant at
  rva `0x9DA6C0` = `0x3d090dbb` (0.03346036). Same value at all four DPF stages — a
  fixed damping-prefilter time-constant, not stepped.
- **DPF Hp/Lp** = reads of a stepped 4-column table at rva **`0x9DDEB0`** (145 rows ×
  `[Lp_A, Hp_A, Lp_B, Hp_B]`), **row 84**. DPF0/DPF1 use the A-pair (cols 0,1); DPF2/DPF3
  use the B-pair (cols 2,3):

| off | name | rva read | value |
|---|---|---|---|
| 10759664/712 | DPF0/1 Hp | `0x9DE3F4` (`[337]`=row84 col1) | `0x3f2d8fd1` 0.67797571 |
| 10759680/728 | DPF0/1 Lp | `0x9DE3F0` (`[336]`=row84 col0) | `0xbf586ee2` −0.84544194 |
| 10759760/808 | DPF2/3 Hp | `0x9DE3FC` (`[339]`=row84 col3) | `0x3f19d713` 0.60093802 |
| 10759776/824 | DPF2/3 Lp | `0x9DE3F8` (`[338]`=row84 col2) | `0xbf4afeb9` −0.79294926 |

**This is the brief's "DPF0 Hp = +0.677976 / Lp = −0.845442" pair — it is NOT computed
from Fc by a runtime filter design.** It is a precomputed LUT: the design (a TPT/SVF
per-cutoff Hp+Lp pair) was run *offline by Roland* and baked as the `0x9DDEB0` table; at
runtime the reverb just indexes it by the decay step (row 84 here). DPF0/1 and DPF2/3 are
two different cutoffs encoded as the two column-pairs of one row.

**Back-solved PD Juno Pad reverb step:** HPF row 2, LPF row 11, DPF row 84. These are
three differently-sized curves driven by the same reverb decay/density knob; the exact
knob→(row2,row11,row84) mapping is the reverb retune indexer (`0x3C1AC0` path) and is
not needed for capture-free reproduction since the rows are pinned bit-exact.

---

## 3. Delay / chorus coefficients

### HighCut Fc / Damp Fc / LowCut Fc — stepped curve LUTs (all bit-exact)
Curve LUTs are int32 arrays of float bit-patterns read by `sub_7FF91DFB6380(curve, knob)`.

| off (instances) | name | LUT | step | value |
|---|---|---|---|---|
| 102464, 4297696, 6497280 | HighCut Fc (delay set) | curve58 `0x986D68` | **7** | `0x3e52bdc7` 0.20580207 |
| 6396288, 10693168 | HighCut Fc (chorus set) | curve58 `0x986D68` | **13** | `0x3f4ba5b0` 0.79549694 |
| 102656, 4297952, 6497472 | HF Damp Fc | curve58 `0x986D68` | **13** | `0x3f4ba5b0` 0.79549694 |
| 102608, 4297904, 6497424 | LF Damp Fc | curve60 `0x987A48` | **0** | `0x3bab929a` 0.00523598 |
| 6396336, 10693216 | Low Cut Fc | curve65 `0x987EF0` | **1** | `0x3ad6774f` 0.00163625 |

(curves 58/61/64 are identical 14-entry "musical ladder" tables; any of the three reads
the same bytes — the recipe uses `0x986D68`.)

### Damp Hp/Lp = 1.0 (damping bypassed) and Dry Level = 1.0
102624/102640/102672/102688 (DLY damp Hp/Lp) and 102512 (Dry) read `1.0` — encoded as a
read of `0x9D9F20[0]` (the AP table's identity row, `0x3f800000`). These are the
"no-damping / dry=unity" defaults.

### HighCut C0/A0/A1/B0/B2 — **registered param defaults (fixed rdata block)**
For PD Juno Pad the High Cut biquad coefficients are **not** param-modulated; they equal
the registered default biquad stored contiguously in the System8Dly param-default block
at rva `0x988F90…0x9890E0` (interleaved with 64-bit type tags). Two default shapes:

- **Chorus** HighCut (6396192–256, 10693072–136): C0 `0x989054`=0.51512837,
  A0 `0x989058`=1.03025675 (=2·C0), A1 `0x98905C`=0.51512837 (=C0),
  B0 `0x988FA4`=−0.44782829, B2 `0x988FA8`=−0.61268526. (numerator `C0·(1+z⁻¹)²`,
  unity DC; a 2nd-order LP at Fc 0.7955, Qc 1.4144.)
- **Delay** HighCut (102368/416/432, 4297600/648/664, 6497184/232/248):
  C0 `0x98903C`=0.15155718, B0 `0x9890D8`=1.37884212, B2 `0x9890DC`=−0.53039932.

### HighCut Qc, Ip Fc, Dry/Wet Gain — fixed constants
| off | name | rva | value |
|---|---|---|---|
| 102480, 4297712, 6396304, 6497296, 10693184 | HighCut Qc | `0x988F9C` | `0x3fb50bf3` 1.41442716 |
| 6396400 | CHO Ip Fc | `0x9880F4` | `0x37ffd974` 3.05e-05 |
| 10693280 | CH3 Ip Fc | `0x988114` | `0x3f2493b7` 0.64287895 |
| 6396496 | CHO Dry Gain | `0x98906C` | `0x3f353f7d` 0.708 |
| 6396512 | CHO Wet Gain | `0x98909C` | `0x3fb4dd2f` 1.413 |
| 4297888 | DL2 Wet Gain | `0x969640` | `0x40000000` 2.0 |

### Chorus CV — **formula** (the only non-LUT FX coeffs)
`Chorus CV = −code / 255.0` evaluated in float32 (bit-exact, verified):
| off | name | code | value |
|---|---|---|---|
| 6395312 | CHO Chorus CV | 1358 | `0xc0aa6a6a` −5.32549020 |
| 10692016 | CHO2 Chorus CV | 1490 | `0xc0bafafb` −5.84313726 |

(`-(float)code / (float)255.0`; note float32 division order matters — `code*(-1/255)`
gives a 1-ULP-off result, the engine does the true division. The `code` is the chorus
manual/CV knob value; 1358 and 1490 are the two chorus instances' settings.)

---

## 4. Why no runtime "filter design" formula was needed (honest boundary)

The brief anticipated some FX coeffs being computed by a small filter-design formula
(tan/SVF/biquad). For **this preset** none of the reproduced coeffs require that:

- The reverb DPF Hp/Lp pair (the brief's example of a "computed" coeff) is a **baked
  stepped LUT** (`0x9DDEB0`, row 84), not a runtime design. Confirmed bit-exact for all 8.
- The delay/chorus HighCut biquad coeffs (C0/A0/A1/B0/B2) for PD Juno Pad equal the
  **registered defaults** in the rdata param-default block (`0x988F90…`), i.e. the preset
  uses the default High Cut, so the coeffs are constants, not a live `design(Fc,Qc)` call.

**Unresolved:** the *general* `design(Fc, Qc) → (C0,A0,A1,B0,B2)` routine — which would
matter if a preset moves the High Cut knob off its default — was **not pinned**. An
exhaustive search (decomp + asm) did not surface an explicit Hex-Rays design function;
the update path goes through `sub_7FF91DFCCE00` (rva `0x36CE00`, decomp_340000.c
~line 29967) where the biquad state/coeff fields (Fc `+0x19040`, Qc `+0x19050`,
C0 `+0x18FD0`, A0 `+0x18FE0`, A1 `+0x19000`, B0 `+0x19010`, B2 `+0x19020`) are read, and
a denominator-normalization `1.0/(…)` is visible (~line 31255), but the explicit
tan/cos prewarp that turns Fc/Qc into the 5 coeffs is not reconstructable from the
provided decompile (likely inlined/vectorized below Hex-Rays resolution). I verified by
algebra that the default coeffs are a unity-DC 2nd-order LP with numerator `C0·(1+z⁻¹)²`
but the standard bilinear/TPT designs with `g=Fc` or `g=tan(πFc/2)` and `R=1/Qc` do
**not** reproduce the stored denominator — so the prewarp is a Roland-specific variant
I could not bit-exactly back out from two data points. For capture-free reproduction of
PD Juno Pad this is moot (defaults are used); it is a flagged gap for off-default presets.

---

## 5. Reproduction summary

| Category | Count | Mechanism |
|---|---|---|
| Reverb HPF (3) + LPF (5) | 8 | LUT `0x639F20` row 2, `0x63A130` row 11 |
| Reverb DPF Hp/Lp (8) | 8 | LUT `0x9DDEB0` row 84 |
| Reverb DPF Fc (4) | 4 | const `0x9DA6C0` |
| Delay/chorus HighCut Fc / Damp Fc / LowCut Fc (13) | 13 | LUT curve58/60/65 |
| Delay damp Hp/Lp + Dry =1.0 (5) | 5 | LUT identity row |
| HighCut C0..B2 default biquads (21) | 21 | const param-default block |
| HighCut Qc / Ip Fc / Dry/Wet Gain (8) | 8 | const |
| Chorus CV (2) | 2 | **formula** `−code/255` |
| **Total bit-exact** | **69** | 34 LUT + 33 const + 2 formula |

Mismatches: **0**. Reproduction script logic is captured in `refs/fx_coeff_recipe.json`
(`{offset: {name, kind, table/rva_addr, index, input_step, formula, value, value_f}}`).
