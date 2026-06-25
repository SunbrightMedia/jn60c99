# FX mode → coefficient mappings (extracted from the binary)

How each discrete FX selector (reverb type, FX-A type, JUNO chorus mode) maps to
the concrete engine coefficients. Extracted from the decompile/asm + rdata data
segments. This is what activates the (already bit-exact) FX DSP per-patch.

## 1. Reverb type → tap table + DPF Fc — FULLY STATIC (capture-free) ✅

The reverb ctor `sub_7FF91E021110` (rva 0x3C1110) binds 4 tables; the SR-swap
`sub_7FF91E0217C0` selects the 96 kHz set. The **reverb-TYPE table is at rva
`0x9DA600`** (`seg_rdata_935650.bin`), **6 rows × 16 cols (64 bytes/row), row = type**.
The retune `sub_7FF91E021AC0` (rva 0x3C1AC0, decomp_3C0000.c:1052) reads
`col13 = *(int*)((type<<6) + 0x9DA600 + 52)` and uses it as the **column index** into
the 20-row × 3-col tap-length table at rva **`0x9DA350`** to build the 34 node tap
offsets (decomp_3C0000.c:1101-1157). Col0 is the per-type **DPF damping Fc**.

| type | name | col0 (DPF Fc) | col13 (tap column) |
|--:|---|--:|--:|
| 0 | AMBIENCE | 0.065229 | 0 |
| 1 | ROOM | 0.130276 | 1 |
| 2 | HALL1 | 0.130276 | 2 |
| **3** | **HALL2** | **0.0334604** | **2** |
| 4 | PLATE | 0.706031 | 2 |
| 5 | MOD | 0.706031 | 2 (+ col8=0.992188, col12=1.0 mod depth) |

**SQ ARPG (DB876=3=HALL2):** tap column 2 (longest taps: 1910, 1516, 906, 360,
1346, … from `0x9DA350` col 2, see `refs/reverb_tables.json`) + DPF Fc 0.0334604.
This cross-checks the recipe's "Rev Ecf DPF Fc const @ 0x9DA6C0 = 0.0334604" — which
is exactly `0x9DA600 + 3·64` = HALL2's col0.

**Honest boundary:** the allpass/damping *rows* (HPF/LPF/DPF-Hp/Lp in
`0x639F20`/`0x63A130`/`0x9DDEB0`) are **not** type-driven — they are selected by the
reverb **decay/density knob** (Ecf nodes 0x454-0x45F via `sub_7FF91E021290`). The
recipe pinned them for SQ ARPG's decay; deriving them needs the patch's decay step.

⇒ **Reverb HALL2 is activatable capture-free** (DSP already bit-exact; tap column +
DPF Fc are static). Remaining: feed the decay-knob step for the damping rows.

## 2. System-8 FX-A type → coefficients — STATIC per-program ✅ (SQ ARPG = DELAY)

All 6 FX-A algorithms are constructed at fixed engine offsets by `sub_7FF91E013010`
(rva 0x3B3010); the mode int at a1+1480 drives a `switch` dispatch in
`sub_7FF91E018E50` (rva 0x3B8E50):

| mode (DB875) | type | sub-object off | ctor rva |
|--:|---|--:|--:|
| **0** | **DELAY** (SQ ARPG) | a1+6784 | 0x35FAB0 |
| 1 | PAN DELAY | a1+6976 | 0x3C2450 |
| 2 | CHORUS1 | a1+7184 | 0x35DA40 |
| 3 | CHORUS2 | a1+7400 | 0x35DA40 |
| 4 | FLANGER | a1+7616 | 0x35EAD0 |
| 5 | DELAY+CHORUS | a1+7824 | 0x3C0830 |

Per-program coefficients are static (curve LUTs + rdata defaults in
`refs/fx_coeff_recipe.json`, bit-exact). The DB875→mode setter is a retn-0 nullsub,
so only the mode int + the runtime output-mix gains (85152 DS-Level / 85168 Mute /
85184 BiasMute) are host-side — which is exactly why offline FX-A is silent unless
the driver thru-routes 84624→84672/84704 (see `juno_driver.c` fxa_bypass).

## 3. JUNO Chorus mode → Chorus CV (6395312 / 10692016) — RECOVERED, static, bit-exact ✅

**Resolved — it IS statically derivable** (the earlier "host-pushed, not in the PE"
conclusion was wrong; the producer just hadn't been read). The setter is
`sub_7FF91DFBE590` (rva **0x35E590**, `CDSPSystem8DlyCh` vtable slot 0 — the chorus
LFO-rate setter):

```
value = LUT22(step) * 11.0 - 8.0          // float32
```
- `LUT22` (tableId 22) @ rva `0x96D2E0` = exact linear `step/255` (0 deviations / 256).
- scale `11.0` @ rva `0xAE5370`; offset `8.0` @ rva `0xAE5350`.
- paramID `this[+0x6C] = 0x3DF = 991` ("Chorus CV" @ 6395312); 2nd instance idx 1065
  @ 10692016 (same class). Written via `sub_7FF91E021090(eng, base, 991, value)`.

**Per-mode steps (recovered, bit-exact round-trip):**

| JUNO Chorus | step | CV | bits | captured |
|---|--:|--:|---|---|
| CH1 (Chorus I)  | **62** | −5.32549002 | `0xC0AA6A6A` | `0xC0AA6A6A` ✓ |
| CH2 (Chorus II) | **50** | −5.84313726 | `0xC0BAFAFB` | `0xC0BAFAFB` ✓ |

The two engine instances carry the fixed Chorus I / II rates (mode selects routing);
`(step·11)/255 − 8` reproduces both captured floats exactly. Implemented capture-free
in `src/juno_fx.c` (`juno_chorus_set_rates`), wired into `juno_preset_load`. The
`−1358/255` "formula" in `refs/fx_coeff_recipe.json` was a back-fit; the true
mechanism is the above. **The chorus has no remaining capture dependency.** The only
non-literal bit is the DB873-mode→step selection, now a proven 2-entry table
{CH1:62, CH2:50}.

### (historical) earlier conclusion — NOT static in the PE

Verified three ways that **6395312 is never written by any statically-decompiled
function**: registered as node #988 (`sub_180388170`) with only the generic
descriptor template (no baked per-mode value); zero-init = 0; the static coeff init
`sub_1803990C0` writes every *neighbor* (6395408=−4.75, 6395648=SR rate-scale,
6395664=fallback) but **skips 6395312**; and the codes 1358/1490 / floats −5.32549,
−5.84314 appear **nowhere** in the rdata/data segments (byte-scanned). The
`−code/255` formula in `refs/fx_coeff_recipe.json` is a **back-fit to the captured
float**, not an engine mechanism.

CH1 and CH2 are the *same* JUNO BBD DSP instance; the per-mode value is **host-pushed**
via the DB873→engine bridge (`sub_7FF91E021090(host, base, 988, value)`), whose
numeric mapping is the runtime red-black tree (`docs/DB_ENGINE_BRIDGE.md`).

⚠️ Note: the one *static* per-mode chorus rate table that DOES exist —
`CDSPJu60EfxCh::setMode` (rva 0x357B80), table @ `0x988200/0x9881F0/0x9881E0`, seeds
0.0015/0.0015/0.0033 — drives the **FX-A chorus** (offsets 91120-91280), **NOT** the
JUNO BBD chorus at 6395312. Don't confuse them.

⇒ The JUNO chorus CV (2 instances) is the single coefficient not recoverable from
the PE statically. It needs either the DB873→CV host mapping reproduced, or a tiny
2-value capture. It currently runs on the captured −5.32549/−5.84314, which give the
correct ~0.4 Hz CH1 rate — so the chorus is plausibly already right; this is the last
≈1% of "fully capture-free."
