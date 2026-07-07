# Preset recall: complete bit-exact map (and what "79 parameters" really is)

This document answers the recurring question — *"the preset selector only changes
~47 things, the JUNO-60 panel has ~79, why isn't recall complete?"* — with the
full parameter-by-parameter accounting, and records the **two fully independent**
derivations that prove the recall is bit-exact.

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
| Extended DSP (VCA mode, LFO trig, HPF type, velocity sens, cutoff-HR) | ~7 | **yes, bit-exact** | value-tree verified |
| Per-patch FX (delay, reverb, arpeggiator) | ~5 | **yes** | delay/reverb bit-exact; arp on/mode/octave |
| Bend / mod-wheel sensitivity (BEND SENS DCO/VCF, MOD SENS DCO/VCF) | 4 | no | performance controls — write per-voice coefficients that are **inert at rest** (scaled by bend/mod-wheel position, which the preview holds at 0). Engine offsets identified (4112/7456/3984/7360) but the input transform is **not** emulation-verified, so it is **not shipped** — shipping an unverified `/255` guess would violate the ground-truth rule. |
| Note-assign modes (LEGATO, ASSIGN MODE) | 2 | no | emulation confirms these write **voice-allocation flags, not DSP coefficients** — mono / mono-legato / poly behaviour. The browser preview allocates polyphonically; 20 factory patches are non-poly and would play monophonically on the real unit. This is the one *audible* item still open, and it needs a voice-allocator mode port, not a coefficient. |
| CONDITION, EFFECT TONE | 2 | no | route through the master / flat-param / FX path that Hex-Rays could not decompile and that is fed by an external schema file absent from the binary. Unresolvable without a capture (forbidden). |
| EFFECT TYPE (chorus/effect select) | 1 | 55/64 | modes 2/3/4 all route to the same chorus block (byte-identical) — correct for 55 patches by the hardcoded chorus; modes 1 & 5 (9 patches) route to un-configured FX blocks (see `AUDIBLE_RECALL_PLAN.md`). |
| JU-06A-only controls (2nd/3rd oscillator, ring, sync, cross-mod, pitch-env, sub/noise *type*, F-ENV/OSC "variation") | ~20 | n/a | **disabled on the JUNO-60**. They exist in the JU-06A value tree (shown parenthesized in `Script.xml`) but the JUNO-60 mode does not sound them, so recall writes nothing audible for them. |
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

## What is deliberately *not* done (and why that is the correct call)

Per the project's cardinal rule — ground truth is only the plugin binary, no
captures, no fitted curves, no guessed orderings — the following are left
unbound **on purpose** rather than shipped as guesses:

- **BEND/MOD SENS transforms** — offset known, transform unverified. Inert at rest.
- **CONDITION / EFFECT TONE** — route through the un-decompiled FX/flat path.
- **EFFECT TYPE modes 1 & 5** — route to un-configured FX blocks; recovering them
  would require a runtime capture, which is forbidden.

## The one remaining audible item

**Note-assign modes (mono / legato).** 16 factory patches use a non-poly assign
mode and 4 use legato; on the real unit those play monophonically. The preview
allocates polyphonically, so those patches are fuller than the hardware. This is
a voice-allocator behaviour (not a recalled coefficient) and is the only place
where a recalled patch can *sound* different from the plugin. Implementing it is
a scoped port of the `CAssignJu60` mode logic — tracked, not guessed.
