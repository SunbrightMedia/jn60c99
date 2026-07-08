# EFFECT TYPE modes 1 & 5 — distortion+pan and the 2nd chorus/ensemble

The master's slot-2 selector `v551 = EFFECT TYPE` picks the effect algorithm. Modes
2/3/4 are the chorus (block A, 91120 — supplied by `juno_engine_prepare` + `chorus_recall`).
Modes **1** and **5** route to blocks `juno_engine_prepare` leaves zero, so a mode-1 or
mode-5 patch played silent-or-wrong until now (the driver pinned slot 2 to the chorus).
This ships both modes.

## Identity (RTTI, from the decompiled mode selector `sub_7FF91E018180`)
| EFFECT TYPE | RTTI class | effect | engine block | factory patches |
|:-----------:|------------|--------|:------------:|:---------------:|
| 1 | `sCDSPSystem8::DlyPan`  | **Distortion + Panner** (cubic hard-clip + stereo pan) | 86288–87152 | 1 |
| 5 | `sCDSPSystem8::DlyMfx1` | **2nd Chorus / Ensemble** (BBD delay + LFO + comb/allpass; a different class & coefficients than the mode-2/3/4 `DlyCh`) | 96336–96912 | 8 |

Full derivation: `scratchpad/oracle/effect_modes_1_5_findings.md`.

## What is written (all bit-exact from the binary)
`src/effect_modes.c` (`juno_apply_effect_modes`), called from `juno_bank_apply`:

- **Slot-2 routing.** Writes `state[JUNO_PROG_EFX] = EFFECT TYPE` so the master follows
  the patch (mirrors `DELAY TYPE → JUNO_PROG_DLY` for slot 1). The driver points the
  master's `params+112` chase at that cell (`src/juno_driver.c`).
- **Shared "Effect SW" (84544).** The slot-2 wet control the master reads for *every*
  mode; driven by EFFECT DEPTH via `EFFECT_SW_LUT` (was previously unrecalled — a
  side-finding of this work).
- **Mode 1:** the 35-cell structural block (`MODE1_STRUCT`, the plugin's own
  BUILD→snap-all→setSampleRate output @96 kHz) + per-patch recall:
  `86288 DS Drive = MODE1_DS_DRIVE_LUT[depth]`, `86304 DS Level = 0x41008081` (const),
  `87056 DS TONE (pan) = MODE1_DS_TONE_LUT[tone]` (closed form `(tone−127|128)/127`),
  `86320 DS Mute = 1.0` (gate, see below).
- **Mode 5:** the 33-cell structural block (`MODE5_STRUCT`) + recall
  `96400 On/Off = depth/255`, `96352 LFO Rate = CHORUS5_LFORATE_LUT[tone]`,
  `96384 Ip Fc = 0x37ffd974`, `96416 Mute = 1.0` (gates, see below).

The structural tables and LUTs are in `src/effect_luts.h`, generated verbatim from the
verified dumps (`scratchpad/oracle/modes_1_5_structural.json`, `mode1_luts.c`).

## Honest residual (the only non-directly-driven values)
Three cells are multiplicative enable-gates that could not be reached under emulation —
the non-default sub-effects are constructed but never *enabled*, so their smoother
targets stay 0 and neither snap-all nor a driven `setActive` populates them (the same
documented limitation as the mode-5 chorus in `chorus_structural_findings.md §5`). Their
*enabled* values are transferred from the binary-derived chorus twins and confirmed by
the DSP structure (a gate that must pass audio = 1.0; the Ip-Fc filter constant matches
its chorus-family twin):
- `86320 DS Mute = 1.0` (twin: chorus Mute `91280 = 1.0`, prepare `84560 = 1.0`)
- `96384 Ip Fc = 0x37ffd974` (twin: chorus `91248 = 0x37ffd974`, snap-all-derived)
- `96416 Mute = 1.0` (twin: chorus `91280 = 1.0`)

Everything else — 72 structural cells + every per-patch LUT + the routing — is bit-exact
from the binary for its own offset.

## Verification
- All 64 patches render finite and non-silent; `make test` green.
- The 9 mode-1/5 patches now route through their own blocks (native output ≠ the
  forced-chorus baseline). Modes 2/3/4 are unchanged: `master_render` reads block A for
  all of `v551 ∈ {2,3,4}`, exactly as the old fixed pin did, so chorus patches are
  byte-for-byte identical to before.
- SR note: most cells are constant or 48 k/96 k-identical; `96336` (mode-5 Delay Time)
  is continuously SR-dependent, and the SR-family cells differ at 44.1 kHz. The shipped
  tables are for 96 kHz (the engine rate); a 44.1 kHz build needs the 44100 column from
  `scratchpad/oracle/sr_sweep_modes_1_5.py` (tracked for the Teensy SR-portability pass).
