# tools/verify — the proof instruments

Every bit-exactness / faithfulness claim in `docs/` is backed by one of these
scripts. They were developed in the (gitignored) session scratchpad; they are
committed here so the proofs are **reproducible after this session dies** — in
particular for the Teensy era, where the golden corpus must be re-provable after
every compiler or hardware change.

Ground truth is ONLY the plugin's own machine code executed under Unicorn
emulation (`e2e_emu.py`). No captures, no fitted curves, no reference WAVs.

## Inputs you must supply (not committed — Roland's binaries)

The scripts reference these session-upload paths as constants near the top of
each file; place the files there or edit the constants:

| constant | file |
|---|---|
| `BIN` (e2e_emu.py) | `JUNO60VST3_64bit.vst3` (the Roland Cloud plugin binary) |
| `BANK` | `presetbankog1.bin` (the 64-patch factory bank) |
| `SCRIPT_XML` (e2e_emu.py) | `Script.xml` (the plugin's parameter-leaf schema) |

Python deps: `unicorn`, `pefile`, `numpy`. Port side: build `libjuno.so` at the
repo root (`make libjuno.so`). WASM checks need node + the built `gui/web/`.

## Index — what each script proves

**Oracle core**
- `e2e_emu.py` — the full-instance engine oracle: BUILD + setSampleRate + recall
  dispatch + per-sample voice/master render of the plugin's own code under
  Unicorn. Canonical cold sequence: `build → snap_all → recall → snap_all →
  clear_latch → set_ftz → note_on → render`.

**Cold bit-exactness**
- `cold_regress.py` — cold single-note A/B vs cached plugin refs (usage:
  `plugin` to cache refs, `port <tag>` to compare a rebuilt libjuno.so).
- `cold44_mode5.py` — all 8 v551==5 patches × {44.1k, 48k}, 12000 frames.
- `rate_audio_final.py` — one patch per DELAY TYPE + patch 9, × {44.1k, 96k}.

**Rate-arm derivation (the 44.1/96 kHz fix, commits 5db92c9/23e2b1e/…)**
- `rate_fullscan.py` — FULL-STATE cold differential scan port-vs-plugin per rate;
  the 48k diff set is the proven-benign baseline; rate-ONLY cells are defects.
- `rate88_dump.py`, `rev_fc44.py` — 88.2k clamp-classification + REVERB TYPE
  dispatch arms.

**Finite-domain exhaustion (Phase-2 ledger)**
- `param_exhaust.py` — every panel param × 256 bytes × 3 rates, cold (19,200).
- `param_exhaust2.py` — same domain, WARM and MID-NOTE configs (2 × 19,200).
- `notevel_exhaust.py` — 128 notes × 127 velocities through the plugin's own
  note-on (16,256), proves note/velocity separability.

**Note-control mechanism proofs**
- `latch_probe.py`, `latch_reads.py`, `latch_arm_when.py` — the DCO-retrigger
  latch story: armed at BUILD, consumed per-voice on first render, never
  re-armed by note-on (write/read hooks on the plugin's own dispatch).

**Scenario matrix (Phase-2)**
- `scenA_switch.py` — patch→patch switching with tails (documents the warm-recall
  free-running-phase limit).
- `scenB_plugin.py` / `scenB_port_cmp.py` — note lifecycle: note → 24000-frame
  tail → retrigger → soft retrigger, 45000-frame bit compare.
- `scenC_plugin.py` / `scenC_port_cmp.py` — chords + 8-voice fill + steal.
- `scenE_port_check.py` — live param moves mid-note (9 params) vs the plugin's
  live dispatch, bit compare.

**Warm behavior (phase-invariant: warm is NOT bit-exact-able — free-running phase)**
- `warm_all64.py` (48k) / `warm_all64_44k.py` — all-64 warm sweep: RMS, stereo
  balance, best-lag correlation; flags anything outside thresholds.
- `flag_selfband.py` / `flag_selfband_44k.py` / `selfband_bal.py` — the
  adjudicator: the plugin rendered against ITSELF at different idle lengths;
  a flag clears only if the port sits inside the plugin's own variation band.

**Delivered artifacts**
- `wasm_ab.mjs` — browser-path WASM vs plugin cold, all 64 patches @48k.
- `wasm_rate44_check.mjs` — WASM cold @44.1k vs plugin refs.
- `wasm_scen_check.mjs` — WASM Scenario B (retrigger) + E (live params).
- `bundle_webapp.py` / `verify_webapp.mjs` — pack the self-contained artifact
  HTML (WASM+bank inlined) and drive it in headless Chromium (boot → bank →
  apply → keypress → real audio, zero console errors).

## Known open ledger items (as of Gate G2 closure)

1. Patches 7 & 39: warm-only, 44.1k-only stereo-balance residual ≤0.7 dB
   (corr ≈0.99, cold bit-exact). Root cause not isolated; Phase-3 transplant /
   Phase-4 assigner splice will settle it.
2. 9th-note voice steal: ~1 ULP, assigner-managed layer (Phase 4).
3. Warm recall (patch switch after rendering): not bit-exact-able by
   construction (free-running phase); matches within 1.6–3.7% diff-RMS.
4. Rate arms measured for {44100, 48000, 88200, 96000} only; other rates fall
   back to the 96k arm.
