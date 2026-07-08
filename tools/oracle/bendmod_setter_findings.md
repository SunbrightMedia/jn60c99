# BEND SENS / MOD SENS (DCO+VCF) — per-voice setter curve/transform, binary-derived

Ground truth = the VST3 binary executed under Unicorn + the machine-code disassembly.
No capture of the running plugin was used. Addresses: decompile base
0x7FF91DC60000 (RVA = VA − 0x7FF91DC60000); PE ImageBase 0x180000000. The curve
evaluator is `sub_7FF91DFB6380` (RVA **0x356380**, NOT 0x3B6380 — that number in the
task prompt is a typo; 0x7FF91DFB6380 − 0x7FF91DC60000 = 0x356380). It is the same
`juno_curve` table proven bit-exact for velocity curves 56/57.

## TL;DR — all four are `juno_curve(22, raw_record_byte)` (transform = ID)

| Script leaf (PATCH.NAME2) | leaf | default | dispatch idx | setter fn (VA) | vtable slot | recompute fn (VA) | curve | input transform | engine offset |
|---|---|---|---|---|---|---|---|---|---|
| BEND SENS DCO | 116 | 43 | **858** | `sub_7FF91DFBBC50` (0x35BC50) | OscVoice slot16 (vt+128) | `sub_7FF91DFBC630` (0x35C630) | **22** | **ID** (raw byte) | **4128** "Bend Range" DCO |
| BEND SENS VCF | 117 | 43 | **859** | `sub_7FF91DFB94C0` (0x3594C0) | FltVoice slot8 (vt+64) | `sub_7FF91DFB9BE0` (0x359BE0) | **22** | **ID** | **7472** "Bend Range" VCF |
| MOD SENS DCO | 118 | 22 | **860** | `sub_7FF91DFBC100` (0x35C100) | OscVoice slot21 (vt+168) | `sub_7FF91DFBC710` (0x35C710) | **22** | **ID** | **3984** "Mod Sens" DCO |
| MOD SENS VCF | 119 | 22 | **861** | `sub_7FF91DFB9AD0` (0x359AD0) | FltVoice slot13 (vt+104) | `sub_7FF91DFB9D10` (0x359D10) | **22** | **ID** | **7360** "MOD Sens" VCF |

The record byte is passed **unmodified** (no /2, no 255−a3, no offset) to `juno_curve(22, ·)`.
`juno_curve(22,·)` clamps its input to [0,255] internally; the Script range is 0..255,
so no extra clamp is needed. **VERIFIED BIT-EXACT** (below).

## TWO CORRECTIONS to the task's stated premise (both binary-proven)

1. **BEND SENS DCO/VCF land on engine offsets 4128 / 7472 ("Bend Range"), NOT 4112 / 7456.**
   4112/7456 ("Bend Level") are the **live pitch-bend WHEEL position** — engine
   descriptor 60/86, driven by dispatch **493** via `sub_7FF91DFBBD0`/`sub_7FF91DFB9440`
   with **curve 26** applied to `(14-bit_bend_value + 0x2000)` (0x2000 = 8192 = pitch-bend
   centre). That is an entirely different signal from the BEND SENS depth param. The
   MOD SENS offsets in the task (3984 / 7360) are correct.

2. **The dispatch indices are 858/859/860/861, not 844/845/846/847.**
   `disp_widx_map.json` shows 844..847 have EMPTY widget-index lists — that is why the
   task's probe of 844–847 produced zero curve calls. The real indices carry the
   per-voice descriptor sets:
   - 858 → [61,171,281,391,501,611,721,831]  (Bend Range DCO, all 8 voices)
   - 859 → [87,197,307,417,527,637,747,857]  (Bend Range VCF)
   - 860 → [52,162,272,382,492,602,712,822]  (Mod Sens DCO)
   - 861 → [80,190,300,410,520,630,740,850]  (MOD Sens VCF)
   leaf→dispatch = leaf + 742. (paramIdx→offset from param_descriptor_map.json:
   61→4128, 87→7472, 52→3984, 80→7360.)

## Bit-exact verification (curve output vs juno_curve)

Built the full instance (`full_oracle.py`), located the CPrmDSPJu60Plugin, and drove
`sub_7FF91E019A30(pmgr, idx, 1, byte)` for idx∈{858,859,860,861} over a value grid.
Hooked the curve fn entry (0x356380) to read (curve_id, input) and captured its **xmm0
return** at the call's return address, comparing to `juno_curve(curve_id,input)` bit-for-bit.
Every one of the 8 per-voice curve calls used curve 22 with input == the raw byte, and
the plugin's float output matched `juno_curve(22,byte)` exactly:

```
grid byte:      0     1    22    43    64   100   127   128   200   254   255
input seen  =  byte  (identity, all 4 dispatch indices, all 8 voices)
plugin out  == juno_curve(22, byte)  bit-for-bit   (e.g. byte22=0x3db0b0b1,
               byte43=0x3e2cacad, byte100=0x3ec8c8c9, byte255=0x3f800000)
=> grid all-match = True for 858, 859, 860, 861
```

## The engine coefficient is a PRODUCT, zero at rest (from the disassembly, bit-exact)

The setters store the byte into a per-voice field and call a recompute that multiplies
the curve output by live bend/mod factors. Disassembly of the four recompute fns gives
the EXACT formula (each verified bit-exact by forcing the gate/enable field and reading
the engine slot — see `verify_product2.py` / `verify_bend.py`):

```
MOD SENS DCO  off 3984 = juno_curve(22, byte@40) * (float)enable@44
MOD SENS VCF  off 7360 = juno_curve(22, byte@40) * (float)enable@44 * 10.0   <-- extra x10
BEND SENS DCO off 4128 = juno_curve(22, byte@32) * (gate@36 ? juno_curve(4, wheel@24) : 0.0) * rangeConst@28
BEND SENS VCF off 7472 = juno_curve(22, byte@32) * (gate@36 ? juno_curve(4, wheel@24) : 0.0) * rangeConst@28
   rangeConst@28 switch = { 0/default:1.0, 1:2.0, 2:3.0, 3:4.0 }   (semitone multiplier)
```
Voice field byte offsets (relative to the OscVoice/FltVoice C++ object):
+0x20=field@32 (bend sens, c22), +0x24=field@36 (bend gate),
+0x18=field@24 (bend range/wheel, c4), +0x1c=field@28 (mode const),
+0x28=field@40 (mod sens, c22), +0x2c=field@44 (mod enable).

Forced-factor bit-exact checks (enable/gate := 1, engine slot read back):
```
MOD SENS DCO(3984), enable=1:  eng == juno_curve(22,byte)            ALL MATCH (grid 0..255)
MOD SENS VCF(7360), enable=1:  eng == juno_curve(22,byte)*10.0       ALL MATCH
BEND SENS DCO(4128), gate=1,mode=0(=x1.0): eng == juno_curve(22,byte)*juno_curve(4,wheel)*1.0
                                                                     ALL MATCH (wheel∈{0,5,23})
```

At rest the gate/enable factors are 0, so **all four coefficients are 0 regardless of the
sens byte** — matching the task's "inert at rest" note.

## Q3 — does patch RECALL drive these? (traced, decisive)

- The **only** path that writes the sens byte into the voice is the param dispatch
  `sub_7FF91E019A30` at indices 858/859/860/861 → BC50/94C0/C100/9AD0 → field@32 / field@40
  → recompute. Scanning **all** dispatch indices 0..1399 for the setter entry addresses:
  BC50 (bend sens @32) fires ONLY at 858; C100 (mod sens @40) ONLY at 860 (859/861 for VCF).
  This is the same dispatch a UI slider move and a patch recall (setState → value-tree leaf
  apply) both use, and these are genuine value-tree leaves (Script.xml PATCH.NAME2, with UI
  sliders), so recall/UI does deliver the byte here as `juno_curve(22,byte)`.

- **CRUCIAL:** the gate/enable multipliers — field@36 (bend gate) and field@44 (mod enable)
  — are set by **NO dispatch index in 0..1399** (scanned; empty for BB70/9420/C0F0/9AC0).
  They are written only by the **live pitch-bend / mod-wheel event handlers** (a separate
  code path, not the recall/param dispatch). The bend range/wheel term field@24 is set by
  dispatch **801** (front-panel BEND RANGE, via curve 4) and the mode field@28 by dispatch
  **857**.

- **Therefore:** at patch load with no active wheel/mod input, offsets 4128/7472/3984/7360
  are **0**, independent of the recalled BEND/MOD SENS value. Leaving them at their init 0
  is bit-exact for any dry (no-wheel) preview — which is exactly what the port already does.
  The `juno_curve(22, byte)` contribution only becomes audible once the player engages the
  bender / mod, at which point the live handler multiplies it by the wheel/mod signal (and,
  for bend, curve4(range) × mode const).

## Consequence for the port (flag, not in the 4-param scope)

`src/juno_apply.c` already binds front-panel **BEND RANGE** (blob_pos 57) → offsets
**4128 AND 7472** with curve 10 (a value it itself flags as "emulation mis-attribution …
pinned by golden bits"). BEND SENS DCO/VCF (leaves 116/117) target the **same** engine
coefficients (4128/7472) but via a **different voice field** (field@32, curve 22) that the
plugin *multiplies* with the BEND RANGE contribution (field@24 curve4, field@28 mode). So
4128/7472 is a multi-factor product, and a single flat "one curve → one offset" binding
cannot represent both BEND RANGE and BEND SENS simultaneously. This is a pre-existing
modelling gap the port owner must reconcile; it does not change the at-rest (=0) behaviour.

## What CAN be shipped bit-exact today (for future MIDI-wheel support)

The record-byte → curve mapping is fully pinned:
```c
/* PATCH.NAME2 leaves; range 0..255; defaults BEND=43, MOD=22. Store the curved
   sens into the voice's bend/mod field; the engine coefficient is this * the live
   wheel/mod factor (0 at rest), so with no wheel input all four stay 0. */
bend_sens_dco = juno_curve(22, byte116);   /* -> field feeding off 4128 (Bend Range DCO) */
bend_sens_vcf = juno_curve(22, byte117);   /* -> off 7472 (Bend Range VCF)               */
mod_sens_dco  = juno_curve(22, byte118);   /* -> off 3984 (Mod Sens DCO)                 */
mod_sens_vcf  = juno_curve(22, byte119);   /* -> off 7360 (MOD Sens VCF); x10 at the slot */
```
The `*enable`, `*(gate?curve4(wheel):0)`, `*rangeConst`, and (VCF mod) `*10.0` factors
above are the exact per-sample/per-event multiplies the plugin applies; port them when
wiring live pitch-bend/mod-wheel.

## Residual uncertainty
- None on the curve/transform: `juno_curve(22, raw_byte)` is proven bit-for-bit over the
  full grid, through the plugin's real dispatch, for all four params, with the downstream
  product formulas confirmed from the disassembly and re-verified numerically.
- I did not drive a complete setState/recall end-to-end (only the dispatch cases it fires);
  this is not load-bearing because the at-rest coefficient is 0 whether or not recall pushes
  the value, and the value's curve is fixed regardless of who triggers the dispatch.
```
Scripts (scratchpad/oracle & scratchpad): drive_bendmod.py, drive_detail.py,
verify_curve.py, verify_product2.py, verify_bend.py, drive_801.py, scan_gate_full.py,
vt_dump.py, parse_setters.py, disasm.py.
```
