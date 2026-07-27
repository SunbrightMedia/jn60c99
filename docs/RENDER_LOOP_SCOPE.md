# RENDER LOOP SCOPE — derive the REAL per-block render structure. Opus 5: follow this to the letter, in order.

**Why this scope exists (read `docs/ENUM_HUNT_STATUS.md` first):** recall is now
PROVEN complete (165-index enumerator vs port full-state A/B = 0 diffs, BS Solid
included), the settings/connect path is refuted, and port == plugin recall+render
is bit-exact 57/57 — yet the real instance differs audibly (BS Solid mid-band,
user hears "more noise oscillator"), host-independently. The ONLY remaining
hand-written code both sides share is the RENDER LOOP STRUCTURE:
`tools/verify/e2e_emu.py::render()` (oracle) and `src/juno_driver.c` (port)
were written to mirror EACH OTHER, not derived from the binary. Every render
A/B compares two copies of the same assumption, so a structural error there is
invisible to every gate. This scope derives the real structure from the binary,
re-expresses the oracle to match, and lets the A/B finally see the difference.

**Covenant (unchanged, absolute):** captures (`scratchpad/diag_bounces/`,
`lastcatpureEVER.wav`) are LOCATE/COMPLETION-TEST ONLY. No number from any
capture enters the port, a gate reference, or the ledger. Ground truth = the
plugin's machine code executed under Unicorn. Two-process rule holds. Label
every claim PROVEN(executed) / READ(static) / INFERRED.

**One reversible commit per step. Do not proceed to step N+1 until step N's
DONE WHEN is literally true. If blocked, STOP and write the blocker in
`docs/RENDER_LOOP_LOG.md` — do not invent an alternative path.**

---

## The whole plan in one line

Map the plugin's real per-block render path (the pool callback 0x3C7400 and its
work items) from decomp, confirm it by single-threaded execution, rebuild the
oracle's render() to that exact structure, A/B it against the port at real host
block sizes — every divergence is a real bug with a law derivable from the
binary; wire the fix, freeze a structural gate, ship.

---

## Known anchors (verified this project — do not re-derive, do verify usage)

- Oracle loop: `tools/verify/e2e_emu.py:326 render(n, block=600)` — HAND-WRITTEN:
  per block it (1) adds b to an assigner counter at `assign[v]+168` for all 8
  voices (attributed to sub_7FF91DFB5AB0 — VERIFY), (2) renders each voice v
  WHOLE-BLOCK from unit v via VOICE_WRAP, in order 0..7, (3) renders the master
  from unit 8 via MASTER_WRAP over the block, wiring a2[16] = per-voice
  (main,sub) buffer pairs. Buffer layout and call ABI are in the file.
- VOICE_WRAP = rva 0x398F30 `(state, voiceIdx, DWORD** outPair)`; the real
  per-voice function dispatches by voice index to specialized subs
  (0x369070..0x383F20) + post-step 0x3C24A0. MASTER_WRAP = rva 0x398EC0
  `(state, float** a2x16, ptr->{outL,outR})` == the master output stage that
  process() itself uses (proven, docs/BSSOLID_DIAGNOSIS.md).
- Engine iface vtable rva 0x9df1d8: slot1 BUILD (0x3C68D0), slot3 setSR
  (0x3C7A20), **slot7 process** , slot15 noteOff (0x3C72D0), slot16 noteOn
  (0x3C7330). The per-block render callback under the thread pool = rva
  0x3C7400. Wrapper process() = 0x34A380 (event→MIDI→queue intake ON the
  calling thread; pool ONLY under DSP render). Queue consumer = 0x320B20.
- Engine state: 9 units (`e.state[0..8]`); voice stride 10512; **plugin voice v
  renders at state[v] + v*10512** (unit v, slot v — proven in the arp work);
  master lives in unit 8. Shared analog-noise block per unit at 84272..84436
  (LFSR float state cell 84336, stepped inside voice render,
  `src/voice_render.c:573-621`); aux one-shot array 101504+v*32 is per-VOICE.
- Port driver: `src/juno_driver.c` — `juno_driver_render_voices` SNAPSHOTS the
  noise block (84272, len 164), RESTORES it before each of the 8 voices so all
  step from the same state, advances it once per block total;
  `juno_driver_render_sample` is sample-interleaved (voices then master, per
  sample). This policy was chosen to match the oracle, NOT derived from the
  binary — it is under test here.
- Prior harnesses to reuse: `tools/verify/plugin_blocktrace.py` (UC_HOOK_BLOCK
  coverage pattern over the render subs), `scratchpad/oracle/real_process_run.py`
  (maps the process()→pool path; its lesson: NEVER wait on the pool — call
  consumers directly, kill any run spinning >5 min), `scratchpad/idle_units.py`
  (per-unit state diff), `probes/enum_hunt/` (this hunt's probe style).
- Decomp: `refs/allcode_decomp.tgz` + `refs/manifest.tsv` (rva→file map).
- METHODOLOGY WARNING: read `docs/P112_FINDINGS.md` §8 before ANY new
  differential (4 protocol errors that each produced tidy false divergences).

## The questions this scope answers (each becomes a row in the map)

- Q1 what 0x3C7400 actually runs per block: how work items are built, which
  function each runs with which args (which unit's state, which voice index,
  which buffers), and what ordering/barriers exist (voices→master?).
- Q2 what per-block pre/post work the real path does that render() lacks or
  invents: the assigner counter += b (is it real? where?), control-rate ticks,
  transport/tempo refresh, event splice at INTRA-BLOCK sample offsets (does the
  real path split a block at a note-on offset, where the oracle/port apply
  events only at block boundaries?).
- Q3 block-size law: is output invariant to host block size (64/128/256/512 vs
  the oracle's 600)? If not, what per-block state creates the dependence?
- Q4 the noise policy: while a note PLAYS, does unit v's noise block stay in
  lockstep with unit 0's (free-running identical) — and is the port's
  single-block snapshot/restore mathematically identical, INCLUDING with
  per-patch CONDITION (idx 856, non-default) scatter and a note landing on a
  rotation voice v>0? (The idle-only diff proved lockstep IDLE; playing was
  never tested.)
- Q5 the note-path terminus: does the queue consumer 0x320B20 deliver notes via
  engine noteOn/noteOff (slots 15/16 — what oracle+port use) or via the
  Note/Gate/Mute param bus (indices 433-474, which write the note-lifecycle
  cells 320/1856/6864/9680/9824 — see ENUM_HUNT_STATUS.md)? Same terminus =
  exonerated; different = derive the semantics.

---

## STEP 0 — Baseline, no code changes
- `make verify` must be GREEN. Record HEAD sha in `docs/RENDER_LOOP_LOG.md`.
- **DONE WHEN:** verify exits 0 and the log has the sha.

## STEP 1 — Static map of the real per-block path (READ)
- From the decomp: 0x3C7400 (pool callback), engine vtable slot7 process, the
  work-item structs it enqueues, and every function reachable from them down to
  VOICE_WRAP/MASTER_WRAP. Answer Q1/Q2/Q5 statically; note where Q3/Q4 state
  lives (which cells are per-block vs per-sample).
- Write `docs/RENDER_STRUCT_MAP.md`: the exact per-block sequence as the code
  writes it, every rva named with role and args. Label all READ.
- **DONE WHEN:** the map has no "unknown callee" between the block entry and the
  voice/master leaf calls, and each Q1-Q5 has a static answer or a named
  obstacle.

## STEP 2 — Execute and confirm (PROVEN)
- Single-threaded: call the derived work-item functions DIRECTLY under Unicorn
  in the derived order (never wait on the pool; kill >5 min spins). Hook
  invocations to record order, args, block length, and every read/write to the
  noise blocks (84272..84436 per unit) while (a) idle, (b) a note playing on
  voice 0, (c) a note playing on a rotation voice with CONDITION non-default.
- Diff the executed structure against render()'s structure; produce the table
  "real block path vs oracle render()" — every row PROVEN, including the Q4
  lockstep verdict and the Q5 terminus.
- **DONE WHEN:** the table exists in RENDER_STRUCT_MAP.md with each difference
  (or equivalence) PROVEN by an executed probe committed under `probes/render_loop/`.

## STEP 3 — Re-express the oracle; find the divergence
- Add `render_real(n, block)` to e2e_emu.py implementing the derived structure
  EXACTLY (keep the old render() untouched for regression comparison).
- Run three A/Bs, two-process, at 44100 AND 48000, block sizes 64/128/256/512/600:
  (a) render_real vs old render() — same driving (locates the structural delta);
  (b) render_real vs the PORT (`bssolid_ab.py` pattern) on BS Solid (Chillwave 3,
      note 60 vel 100, ≥2 s) — THE bug check;
  (c) render_real vs the PORT on 8 factory patches spread across FX families.
- If (b)/(c) diverge: characterize per-sample/per-cell, find the plugin function
  whose behavior the port's driver mis-structures, and STOP at the
  characterization — the fix is STEP 4. If nothing diverges anywhere at any
  block size: the render loop is EXONERATED; write that plainly in the log with
  the probes as evidence (that is a real answer — do NOT invent a new theory;
  the remaining surface is then STEP 2's Q5 result or outside the engine).
- **DONE WHEN:** either a characterized divergence exists, or the exoneration
  entry is written with all A/B outputs archived.

## STEP 4 — Fix the port (only if STEP 3 diverged)
- Port the derived structural law into `src/juno_driver.c` (+ the WASM driver
  path in `gui/web/` if it duplicates the logic). No hand-invented DSP: every
  behavioral constant comes from the executed plugin functions.
- Re-run: recall_render_ab 57/57 at 48k+44.1k, warm A/B, fuzz_diff, arp gates,
  bssolid_ab, `make verify` — all green.
- **DONE WHEN:** all listed gates green with the fix in.

## STEP 5 — Freeze the blind-spot closure (permanent gate)
- New gate `tools/verify/renderstruct_ab.py` in `make verify`: drives the REAL
  derived block structure (render_real) vs the port at ≥2 block sizes on ≥4
  patches incl. BS Solid's Chillwave record, bit-exact required. This makes the
  loop structure a gated surface forever (like etmode_ab did for EFFECT TYPE).
- Update CLAUDE.md's NEWEST block + PROVENANCE/COVERAGE if any new constant was
  ported. **DONE WHEN:** make verify includes it and is green.

## STEP 6 — Ship + completion test
- `bash gui/web/build.sh` (emsdk at `scratchpad/emsdk`), `node
  tools/verify/wasm_golden.mjs` 8/8, re-bundle with the Chillwave bank
  (`tools/verify/bundle_webapp.py --extra-bank ...` — path in FINAL_SCOPE.md
  STEP 6), `node tools/verify/verify_webapp.mjs`, republish the SAME artifact
  URL (https://claude.ai/code/artifact/4c5a4e67-86ed-43e5-871c-695aa6275ac7),
  commit, push `claude/c99-gui-fable5-yfhak1`.
- COMPLETION TEST (covenant role 2, diagnostic only): re-run the BS Solid
  spectral locator (`scratchpad` bssolid analysis pattern) against
  `lastcatpureEVER.wav` — the 780-2200 Hz deficit should close if STEP 4 fixed
  a real structural bug. Whatever the number, it goes in the LOG as diagnosis,
  never into code or gates.
- **DONE WHEN:** artifact republished, branch pushed, verify green, log updated.

---

## THE EXIT TEST (no ambiguity)
This scope is DONE when EITHER:
1. STEP 3 found a divergence AND STEPS 4-6 landed it (all gates + the new
   structural gate green, artifact shipped); OR
2. STEP 3 exonerated the render loop at every tested block size AND the Q4
   noise-lockstep and Q5 note-terminus questions are answered PROVEN — in which
   case the log states plainly that the engine + its drivers are structurally
   faithful and names the remaining candidate surface (wrapper event layer or
   out-of-engine), with no new scope invented here.

## Hard DON'Ts (these caused every past thrash)
- DON'T tune to or derive anything from a capture. Ever. (Completion test only.)
- DON'T fight the thread pool — call work-item functions directly; kill >5 min
  spins.
- DON'T "fix" the port from a theory: only from the executed structure.
- DON'T compare states after partial restore / without descriptor writes /
  outside param ranges / against a pristine engine (P112_FINDINGS §8).
- DON'T leave a divergence uncharacterized to jump ahead, and DON'T open a new
  investigation thread if a step blocks — STOP and log.
