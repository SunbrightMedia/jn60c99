# Phase-2 scenario matrix — results + fixes (VERIFIED)

Workflow run: `wf_793b296b-fe8` (6 scenario classes A/B-ing the plugin machine code
vs the port). 5/6 matrix agents completed; the `rate-44k` matrix agent and ALL five
adversarial Verify agents were killed by a session limit, so every "divergence-found"
below was **unverified by the workflow**. I re-derived and verified each one myself
against the plugin's own code under Unicorn before touching any source. Two were real,
fixable defects (fixed + re-verified); the rest are known-legit or oracle-bounded.

## Summary

| Scenario | workflow verdict | after my verification | status |
|---|---|---|---|
| A patch→patch switch (warm recall) | divergence-found | known-legit: warm recall isn't bit-exact-able (free-running phase) | no fix needed |
| B note lifecycle / retrigger | divergence-found | **REAL BUG** (DCO-retrigger latch) | **FIXED** — 45000-frame bit-exact |
| C chords + voice steal | divergence-found | **REAL BUG** (same latch) at 4th note; steal itself oracle-bounded | **FIXED** (through 8 voices); steal = Phase 4 |
| D long render (5 s tails) | all-exact 2/2 | confirmed all-exact | — |
| E live param move mid-note | divergence-found | **REAL BUG** (set_param over-reseed) | **FIXED** — all 9 params bit-exact |
| rate-44k 44.1 kHz | (killed) | **REAL BUG** (FX tables 48k-baked; 96k too) | **FIXED** — bit-exact at 44.1k & 96k, every FX type |

## The two real bugs (found by the matrix, verified + fixed by me)

### Bug 1 — DCO-retrigger latch armed on note-on instead of at BUILD  (Scenarios C & B)
Root-caused with `scratchpad/oracle/latch_{probe,reads,arm_when}.py` (hook every write
to the plugin's 9 unit states during its own note_on / note_off / build under Unicorn):
- The DSP-consumed retrigger latch is **aux Array A**, state `101504 + v*32` (each voice
  unit reads its own slot). The plugin arms all 8 copies to 1.0 **once at engine BUILD**
  (before setSampleRate); each voice's first rendered sample consumes its slot; thereafter
  the DCO free-runs. **note-on never re-arms Array A** — it writes a different, DSP-inert
  cell (aux Array B, `101520 + v*32`).
- The port armed Array A in `juno_note_on` on **every** note (masked in the cold single-note
  A/B, where note-on precedes any render, so both sides have it set at sample 0). Any note
  played after rendering had begun re-phased the DCO → divergence at the first post-note
  sample (Scenario C 4th note @6001; Scenario B retrigger @30001).
- Fix (`src/juno_init.c`, `src/juno_note.c`): arm Array A for all 8 voices in
  `juno_engine_init` (mirroring BUILD); remove the arm from `juno_note_on`.
- Verified: cold single-note **still bit-exact** (old==new==plugin, no regression);
  Scenario B (note→tail→retrigger→soft retrigger) **BIT-IDENTICAL over 45000 frames**,
  patches 13 & 43; Scenario C **bit-exact through all 8 held voices** (was @6001). Full
  unit suite green + new `test_note_path` regression guard.

### Bug 2 — live set_param re-seeded/re-conditioned all voices  (Scenario E)
`juno_gui_set_param` ran `juno_driver_seed_voices` (whole per-voice block copy voice0→1..7)
+ `juno_apply_condition` after every edit — the RECALL propagation path. The plugin's LIVE
param dispatch writes only the target cell (identical float in all 8 per-voice copies, or
the single master cell), 0 smoothers, nothing else. The reseed reset each voice's evolved
runtime state (envelope/LFO phase, drift tables) mid-note.
- Fix (`gui/juno_bridge.c`): replicate only the one written value to the other voices
  (per-voice cells), drop seed_voices/apply_condition from the live setter.
- Verified against the plugin's live dispatch (`scratchpad/oracle/scenE_port_check.py`):
  all 9 tested params **BIT-EXACT** over a 9000-frame mid-note move (was diverging at the
  first post-change sample in every case).

## Delivered WASM
Rebuilt `gui/web/juno.wasm` (BUILD_VER 78321a130687, includes the FX rate arms).
Verified the delivered artifact: cold browser-path A/B 57/64 bit-exact vs plugin at
48 kHz (unchanged baseline; the 7 are SQ arp patches under the arp-on harness), cold
@44100 BIT-EXACT (4 patches, `wasm_rate44_check.mjs`), Scenario B 45000-frame
bit-exact, Scenario E all 9 bit-exact (`scratchpad/oracle/wasm_scen_check.mjs`).

## Not fixed (correctly)
- **Scenario A** (patch→patch switch): the divergence begins exactly at the mid-stream
  recall = a **warm recall** (recall issued after rendering). Minimization (idle render
  alone before recall breaks bit-exactness; back-to-back cold recalls stay bit-identical)
  confirms it is the documented free-running-phase limit, not a defect. Everything up to
  and including the release tail is bit-exact; post-switch matches within 1.6–3.7% diff-RMS.
- **Scenario C voice steal** (9th note): after the latch fix, the only residual is the
  9th-note steal, ~1 ULP / 0.1% RMS, in the assigner-managed voice-allocation layer that
  the leaf-driven oracle cannot bit-verify (Phase 4 thread-pool splice).
- **rate-44k (44.1 kHz full-path)**: run this session — surfaced a **real, pre-existing**
  drift (1-ULP seed at the FX read-back onset ~frame 2722, accumulating to ~1.7% RMS),
  now **ROOT-CAUSED AND FIXED**. The seed was NOT a per-sample computation: the
  FILT/DLY1/S1CHORUS/S1REVERB/MODE1 constant tables (and 10 prepare reverb-Ecf cells)
  were captured at 48 kHz only, while ~35 of their cells are RATE-DEPENDENT (the
  plugin's FX config writes per-rate arms: a continuous 2sin(pi*f/H) family, a
  96k-clamped family, 2-class {44100, else} switches, an affine H*0.02-2 predelay).
  96 kHz carried the same class of error (2x on the 2sin family); 48 kHz was
  accidentally exact, masking everything. Method: full-state cold differential scan
  port-vs-plugin per rate (44.1/48/88.2/96) with the 48k diff set as the
  proven-benign baseline — every rate-ONLY cell measured bit-for-bit from the
  plugin's own build+recall and encoded as exact per-rate arms.
  **Verified fixed**: rate-ONLY state cells = 0 (one patch per DELAY TYPE x 3 rates);
  cold audio BIT-EXACT 12000 frames at BOTH 44.1 kHz and 96 kHz for patches
  13/4/11/19/5/9 (every FX routing, incl. the sole v551==1 patch); 48 kHz cold +
  Scenario B + Scenario E regressions unchanged; delivered WASM re-verified at both
  rates. Scripts: `scratchpad/oracle/rate_fullscan.py`, `rate88_dump.py`,
  `rev_fc44.py`, `rate_audio_final.py`, `wasm_rate44_check.mjs`.
  Residual open item: the browser runs chorus mode 2 (mode-0 was the bit-exact
  harness convention); a warm 44.1 kHz phase-metric sweep like WARM_ALL64 has not
  yet been repeated at 44.1 kHz — queued with the finite-domain exhaustion work.

## Finite-domain exhaustion (MASTER_PLAN Phase-2 ledger)

**Params x 256 (state-level, vs the plugin's own dispatch):** every exposed panel
binding (25 rows over 21 blob positions) x all 256 byte values x 3 rates
(44100/48000/96000) = 19200 comparisons, plugin dispatch (idx = blob+744, all 9
units, snap) vs port `juno_apply_param`, engine cell compared bitwise
(`scratchpad/oracle/param_exhaust.py`). Initial result 19197/19200: the 3
mismatches were ONE bug at all 3 rates — HPF byte 2 -> cell 10272 landed on curve
10's LUT entry 2 (3.0) where the plugin writes 0 for every byte (min(byte,3)
transcription artifact; no factory patch carries byte 2, so every recall A/B
missed it). Fixed in `juno_curve.c` (bytes >= 2 -> entry 3); re-swept: **19200/19200
identical**. For finite domains, exhaustive testing IS proof.

Inherited exhaustive counts (verified in earlier phases, same oracle standard):
128/128 note->M.CV bits (`juno_mcv_bits`), full velocity sweep through curves
56/57, 256/256 per SR-variant curve arm at 3 rates (`test_recall_rate`),
REVERB (TYPE 0..5) x (TIME 0..255) tables, 48/48 sync divisions x rates.

Remaining Phase-2 items: warm/mid-note variants of the param sweep (state-level),
note x velocity state-write exhaustion runner, 44.1 kHz warm phase-metric sweep
(chorus mode 2), then Gate G2 ledger consolidation.
