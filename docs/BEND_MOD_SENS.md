# BEND SENS / MOD SENS (DCO + VCF) — derived bit-exact, deferred to the wheel path

The four "sensitivity" leaves — BEND SENS DCO/VCF (PATCH.NAME2 leaves 116/117) and
MOD SENS DCO/VCF (118/119) — scale how far the **pitch-bend wheel** and **mod wheel**
push the DCO pitch and the VCF cutoff. Full derivation:
`scratchpad/oracle/bendmod_setter_findings.md`. Ground truth = the binary.

## The transform is pinned bit-exact
All four are **`juno_curve(22, raw_record_byte)`** (curve 22, identity transform), proven
bit-for-bit by driving the plugin's real param dispatch `sub_7FF91E019A30` at the correct
indices and matching the curve fn's xmm0 return over the full 0..255 grid:

| leaf | param | dispatch | curve | engine offset | record byte |
|------|-------|:--------:|:-----:|:-------------:|:-----------:|
| 116 | BEND SENS DCO | 858 | 22 (ID) | **4128** "Bend Range" DCO | 514 |
| 117 | BEND SENS VCF | 859 | 22 (ID) | **7472** "Bend Range" VCF | 522 |
| 118 | MOD SENS DCO  | 860 | 22 (ID) | 3984 "Mod Sens" DCO | 530 |
| 119 | MOD SENS VCF  | 861 | 22 (ID) | 7360 "MOD Sens" VCF | 538 |

Two premises from the original investigation were **corrected** by the disassembly:
- **BEND SENS lands on 4128/7472, not 4112/7456.** 4112/7456 ("Bend Level") are the *live
  pitch-bend wheel position* (dispatch 493, curve 26 of `bend14 + 0x2000`) — a different
  signal entirely.
- **Dispatch indices are 858–861 (leaf + 742), not 844–847** (which have empty widget
  lists — the reason an earlier probe of 844–847 saw nothing).

## Why it is NOT shipped as a flat recall (and why that is correct, not a shortcut)
The engine coefficient our `voice_render` reads at 4128/7472/3984/7360 is not the raw
sens — it is a **product** the plugin recomputes, and the disassembly gives it exactly:

```
MOD SENS DCO  3984 = juno_curve(22, byte) * enable@44
MOD SENS VCF  7360 = juno_curve(22, byte) * enable@44 * 10.0
BEND SENS DCO 4128 = juno_curve(22, byte) * (gate@36 ? juno_curve(4, wheel@24) : 0) * rangeConst
BEND SENS VCF 7472 = juno_curve(22, byte) * (gate@36 ? juno_curve(4, wheel@24) : 0) * rangeConst
```

The `enable@44` (mod) and `gate@36`/`wheel@24` (bend) factors are written **only by the
live pitch-bend / mod-wheel event handlers — by no param-dispatch index at all**. So:

1. **At patch load with no wheel input, all four coefficients are 0**, independent of the
   recalled sens byte. Leaving 4128/7472/3984/7360 at their inert value (init 0 for
   3984/7360; the BEND RANGE binding on 4128/7472, also 0 at rest because its wheel bracket
   is 0) is **bit-exact for any dry preview** — which is what the port already does. Proven
   empirically: setting these to 0, v/255, or the real curve gives byte-identical output.
2. **Our flat "one curve → one offset" model cannot represent the product.** `juno_apply.c`
   already binds front-panel BEND RANGE → the *same* 4128/7472 (its own `rangeConst`
   factor); BEND SENS is a *different* voice field the plugin multiplies in. Writing
   `juno_curve(22, byte)` directly into 4128/7472/3984/7360 would **overwrite the product
   with one partial factor** — incorrect, not merely redundant. There is also no
   pitch-bend / mod-wheel input in the preview to exercise the other factors.

Per the cardinal rule (no guessing, no incorrect simplification), the sens value is
therefore **derived and documented, not force-fit into the flat offsets**.

## What to do when live pitch-bend / mod-wheel is added
Wire the real per-event product above:
```c
/* on patch recall: store the curved sens into the voice's bend/mod field */
bend_sens_dco = juno_curve(22, byte116);   mod_sens_dco = juno_curve(22, byte118);
bend_sens_vcf = juno_curve(22, byte117);   mod_sens_vcf = juno_curve(22, byte119);
/* per sample/event, form the engine coefficient: */
off3984 = mod_sens_dco  * mod_enable;              /* mod wheel */
off7360 = mod_sens_vcf  * mod_enable * 10.0f;
off4128 = bend_sens_dco * (bend_gate ? juno_curve(4, bend_wheel) : 0.0f) * rangeConst;
off7472 = bend_sens_vcf * (bend_gate ? juno_curve(4, bend_wheel) : 0.0f) * rangeConst;
/*   rangeConst = {0:1, 1:2, 2:3, 3:4}[BEND MODE] (semitone multiplier) */
```
This also requires reconciling the existing flat BEND RANGE binding on 4128/7472 with the
BEND SENS factor (they are two inputs to one product) — a modelling change scoped to the
wheel path, not the dry engine.
