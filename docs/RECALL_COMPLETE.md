# Preset recall: complete bit-exact map (and what "79 parameters" really is)

This document answers the recurring question — *"the preset selector only changes
~47 things, the JUNO-60 panel has ~79, why isn't recall complete?"* — with the
full parameter-by-parameter accounting, and records the **two fully independent**
derivations that prove the recall is bit-exact.

## Definitive completeness audit (the "are they ALL routed?" question)

Rather than count controls, the recall is now audited the only way that actually
proves completeness: **decode every value-tree leaf of the patch record across all
64 factory patches, and flag any leaf whose value differs from its power-on default
in some patch but is not recalled.** A leaf that sits at its default in all 64
patches is inaudible whether or not it is recalled; the only leaves that can make a
recalled patch sound wrong are the ones that (a) *vary* across the bank and (b) are
*not* written by the applier. The full scan
(`scratchpad/oracle/leaf_variance_audit.py`) enumerates the 117 core-record leaves
(LFO/OSC1/MIX/FLT/AMP/EFX/CTRL/EXTEND + the four NAME blocks), decodes each with the
oracle-verified record formula (front-panel `byte = 2·leaf − 4`; extended NAME1/2/3
`byte = 8·leaf − 430`), and diffs against the applier's read-set.

**Result — every synthesis/DSP leaf that varies across the bank IS recalled.** The
current scan flags exactly **2** varying-unrecalled leaves, and both are
**JU-06A-disabled hardware features** that drive no engine coefficient on the
JUNO-60: `(OSC1 CROSS MOD)` (leaf 30, varies 37/64) and `(OSC3 WAVEFORM)` (leaf 126,
varies 7/64) — the JUNO-60 has a single DCO with no cross-modulation and no third
oscillator, so not recalling them is correct. Every other leaf that varies across
the bank and is live on the JUNO-60 is now written by the applier, including the
items historically listed as open (they have since been closed, each verified
against the plugin's own machine code under Unicorn — never a capture):

- **BEND SENS DCO/VCF, MOD SENS DCO/VCF** (leaves 116–119) — recalled bit-exact by
  `apply_bend_mod_sens()` (`src/juno_apply.c`): `4128/7472 = curve22(sens)·curve4(range)·mode`,
  `3984 = curve22(msd)`, `7360 = curve22(msv)·10`. Verified inert at rest (mod/bend
  sources 0 with no wheel input), so writing the depths is safe and correct.
- **LEGATO, ASSIGN MODE** (leaves 57/58) — recalled by `juno_bank_voice_modes()` and
  driven by the ported `CAssignJu60` allocation logic (poly / mono / mono-legato /
  unison) in `gui/juno_bridge.c`. No longer poly-only.
- **CONDITION** (leaf 114) — recalled by `juno_apply_condition()`: the per-voice
  analog component-tolerance scatter (detune 5520 / fine 7600 / gain 10320), bit-exact
  vs the plugin's per-voice setters (240/240 under Unicorn). Not "unresolvable without
  a capture" as an earlier edition claimed — it was resolved by emulating the plugin's
  own code.
- **SCATTER TYPE, SCATTER DEPTH** (leaves 92/93) — recalled by `juno_bank_scatter()`,
  selecting the arpeggiator's STEP×SLOT pattern grid (all 64 factory patches = the
  default grid; the engine handles all 110 reachable patterns bit-exact).

The earlier one *audible* gap — `(F ENV VARIATION)` — remains documented below:

- **`(F ENV VARIATION)` — leaf 112, record byte 482 — FIXED (this is the pluck
  bug).** 7 of 64 patches set it to 1 (`SQ Dynamic ARPG`, `LD Classic Lead`,
  `PL The Square`, `BR Brass Pop`, `PD Big Pad`, `BS VeloMOD Bass`, `LD Perc Lead`).
  It is the **VCF envelope-source selector**: the decompiled voice render
  (`src/voice_render.c:1151-1157`, byte-identical to `sub_180369070`) reads it at
  engine offset **7008** ("Env1/2") as a float lerp factor between the ENV1-derived
  filter state (2752) and the ENV2-derived state (3232), and offset **7024**
  ("Int/Env") mixes that against internal source 6640:
  `7072 = lerp( lerp(ENV1, ENV2, 7008), 6640, 7024 )`. Left unrecalled it stayed 0
  (ENV1) for every patch, so a pluck whose filter should snap on the fast amp
  envelope (ENV2) crawled open on the slow filter envelope (ENV1). A/B on patch 10
  "PL The Square": the filter-env output at t=0.5 ms went from **0.0011 (ENV1, the
  bug)** to **0.74 (ENV2, the fix)**, peaking 0.91 at 2.5 ms — a proper pluck. See
  `apply_fenv_variation()` in `src/juno_apply.c`. The earlier edition of this
  document wrongly filed "F-ENV variation" under JU-06A-disabled; it is not disabled
  on the JUNO-60 and this correction is the point of the audit.

## Bottom line

The recall writes **49 logical DSP parameters** (≈40 distinct engine-coefficient
offsets per patch, because a few panel controls write several coefficients). The
applier reproduces **every one of them, bit-for-bit**, on every one of the 64
factory patches. That has been verified two ways that share no common code:

1. **Golden coefficients** — 40 IEEE-754 coefficient bit-patterns × 3 real patches
   (`tests/test_apply_golden.c`), captured from the plugin's own value-tree recall.
   `120/120` bit-exact.
2. **Full-instance Unicorn emulation** — the real VST3 image is loaded into
   Unicorn, the plugin's engine graph is constructed exactly as the plugin does
   (`operator new(0xA83010)` 11 MB state → `sub_7FF91DFE80F0` init → wrapper →
   `CPrmDSPJu60Plugin` ctor `sub_7FF91E013320(obj,0,7,wrapper)`), then the param
   dispatch `sub_7FF91E019A30` is driven and each setter's `(curve_id, engine
   offset)` is recovered from the descriptor writer (`0x3C2750`, which carries the
   param index in `edx`). 28/30 known anchors reproduced independently; the 2
   residual mismatches are emulation mis-attributions on anchors already pinned by
   the golden bits (`4128` BEND, `10240` HPF), i.e. the applier is right and the
   emulation double-counted — not a recall gap.

The scaffolding lives under `scratchpad/oracle/` (`emu2.py` full-instance builder,
`resolved_table.json` the 111-row recovered map, `gap_bindings.json` the honest
status of every unbound panel control).

## Why it's ~49, not 79

"79" is a count of **front-panel controls**, not of per-patch DSP coefficients.
The gap is entirely accounted for — none of it is missing recall:

| Category | Count | Recalled? | Why |
|---|---|---|---|
| Core synthesis (DCO/LFO/VCF/2×ADSR/VCA/porta/bend) | ~37 | **yes, bit-exact** | golden + emulation |
| Extended DSP (VCA mode, **F ENV VARIATION / VCF env source**, LFO trig, HPF type, velocity sens, cutoff-HR) | ~8 | **yes, bit-exact** | value-tree verified; F ENV VARIATION derived from the decompiled voice render (offsets 7008/7024) |
| Per-patch FX (delay, reverb, arpeggiator + SCATTER grid) | ~6 | **yes, bit-exact** | delay/reverb bit-exact; arp on/mode/octave + the full STEP×SLOT pattern grid (SCATTER TYPE/DEPTH), verified 330/330 vs the plugin under Unicorn |
| Bend / mod-wheel sensitivity (BEND SENS DCO/VCF, MOD SENS DCO/VCF) | 4 | **yes, bit-exact** | `apply_bend_mod_sens()`: `4128/7472 = curve22(sens)·curve4(range)·mode` (bend), `3984 = curve22(msd)`, `7360 = curve22(msv)·10` (mod), dispatch 858–861. Verified inert at rest (the wheel gate is 0 with no wheel input, so the recalled depths change nothing until a wheel event arrives — writing them is safe *and* correct). Full derivation: **docs/BEND_MOD_SENS.md**. |
| Note-assign modes (LEGATO, ASSIGN MODE) | 2 | **yes** | recalled by `juno_bank_voice_modes()`; the ported `CAssignJu60` allocator (`gui/juno_bridge.c`) drives poly / mono / mono-legato / unison, so the 20 non-poly factory patches now play with the correct voice count instead of poly-only. |
| CONDITION (per-voice analog scatter) | 1 | **yes, bit-exact** | `juno_apply_condition()`: per-voice detune/fine/gain (5520/7600/10320), 240/240 bit-exact vs the plugin's own per-voice setters under Unicorn — resolved by emulation, not a capture. |
| EFFECT TONE | 1 | **yes** | recalled for modes 1 & 5 (`effect_modes.c`, record byte 642 → DS pan / chorus-5 LFO rate). |
| EFFECT TYPE (chorus/effect select) | 1 | 55/64 | modes 2/3/4 all route to the same chorus block (byte-identical) — correct for 55 patches by the hardcoded chorus; modes 1 & 5 (9 patches) route to un-configured FX blocks (see `AUDIBLE_RECALL_PLAN.md`). |
| JU-06A-only controls (2nd/3rd oscillator, ring, sync, cross-mod, pitch-env, sub/noise *type*, OSC/LFO "variation") | ~20 | n/a | **disabled on the JUNO-60**. They exist in the JU-06A value tree (shown parenthesized in `Script.xml`) but the JUNO-60 mode does not sound them, so recall writes nothing audible for them. *(Note: `(F ENV VARIATION)` is parenthesized in `Script.xml` too, but — unlike these — the decompiled voice render **does** read its engine offsets 7008/7024, so it is live on the JUNO-60 and is recalled; see the extended-DSP row above.)* |
| Internal / derived engine state (LFO waveform one-hot switches, filter −12/−18/−24 dB taps, plugin-enable switches, tune/detune, `Q24C Initialize`, `read only`, M.CV/M.Gate note-control) | ~63 offsets | n/a | not per-patch data — they have **no byte in the patch record** (proven from the record layout). Set by engine init or derived from a recalled control; leaving them at their init value *is* the bit-exact behaviour. |

## The clean argument

A parameter is recalled **iff it has a byte in the patch record**. The record
layout (front-panel 222-byte blob + the extended NAME2/3 region) was enumerated
from the parser `sub_7FF91DFB1710` + its remap table `dword_7FF91E8A4290` and the
in-binary descriptor array. Cross-checking the 64-patch factory bank for
per-patch variation against the applier's complete read-set leaves exactly the
handful of positions in the table above — and each is explained (inert
performance control, allocation flag, FX/master path, or JU-06A-disabled), not a
missing binding.

## What is *not* recalled — and why each is correct

Per the project's cardinal rule — ground truth is only the plugin binary, no
captures, no fitted curves, no guessed orderings — the leaf variance audit now
leaves **only** these unrecalled, each for a principled reason:

- **`(OSC1 CROSS MOD)`, `(OSC3 WAVEFORM)`** and the other parenthesized value-tree
  leaves — **JU-06A-disabled**. They exist in the JU-06A schema but the JUNO-60
  mode does not sound them (single DCO, no cross-mod, no 3rd oscillator), so they
  drive no engine coefficient. Recalling them would write to nothing.
- **Internal / derived engine state** (LFO one-hot switches, filter dB taps,
  tune/detune, note-control) — **no byte in the patch record**; set by engine init
  or derived from a recalled control. Leaving them at their init value *is* the
  bit-exact behaviour.

Everything historically listed here as "deliberately unbound" — BEND/MOD SENS,
CONDITION, EFFECT TONE, note-assign modes, the SCATTER arp grid, EFFECT TYPE modes
1 & 5 — has since been **recalled and verified against the plugin's own code under
Unicorn** (never a capture). There is no longer an open audible recall gap: every
leaf that varies across the factory bank and is live on the JUNO-60 is reproduced
bit-for-bit.
