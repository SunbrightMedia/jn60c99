# JUNO-60 (JU-06A) C99 port — project memory

**Read `GOAL.md` first — it is the user's own statement of the goal and is binding.**
Short form: a bit-exact C99 port of the Roland Cloud JUNO-60 (JU-06A) VST3 DSP that
sounds EXACTLY like the original, playable in the browser (WASM), portable to a
Teensy 4.1 later. The shipped engine is plain portable C99 — emulation is an
analysis tool only; nothing emulated may be required at runtime. Recall must be
correct for ANY preset value, not just the factory bank's ("this byte is 0 in every
factory patch" is not an excuse to skip it).

## The one rule everything else serves

**The original `.vst3` is the ONLY ground truth.** The port must be SELF-PROVING:
every coefficient proven bit-exact against the plugin's own machine code, executed
under Unicorn. Never validate by ear, never ask the user to A/B — that is a
"capture" and is forbidden. "Done" = `make verify` green, i.e. zero non-PROVEN rows
in `PROVENANCE.tsv` (the status authority; it supersedes GOAL.md's pointer to
`docs/AUDIBLE_RECALL_PLAN.md` and every prose doc).

## Hard rules (violating any of these corrupts the project)

- **THE DIAGNOSTIC-CAPTURE COVENANT (user-granted 2026-07-17, THE MOST IMPORTANT
  RULE).** The user provided DAW bounces of the real plugin (Ableton Live 12.0,
  120 BPM, 44100 Hz, first 8 presets of bank 1, one note vel 100, 0.5 s silence +
  2 s note + 1.5 s tail; session copies in `scratchpad/diag_bounces/presetN.wav`).
  These are **DIAGNOSTIC USE ONLY** — the only captures this project will ever
  receive, granted under that explicit condition:
  - NEVER derive, copy, fit, or tune ANY coefficient, table, or constant from them.
  - NEVER use them as a gate reference or as ledger provenance. PROVEN continues to
    mean "the plugin's machine code executed under Unicorn" — nothing else.
  - Their ONLY permitted roles: (1) locating WHERE the harness's driving of the
    plugin diverges from a real host's, and (2) the completion test for that
    harness investigation. Every fact they point to must then be re-derived by
    executing the binary (e.g., controller defaults read from the controller's own
    init code) before it may enter the port or the ledger.
  - Never commit them to git. If they leak into a coefficient's history, that
    coefficient is CAPTURED and must be replaced.

- **Ground truth = the plugin binary executed under Unicorn.** Running its machine
  code is allowed and is NOT a capture. Reading the plugin's own `Script.xml`
  (in `truth/`) is allowed plugin data.
- **NEVER open, read, or reference files named `user_patch5_ableton.json` or
  `captured_coeffs.json`** — anywhere, ever, including in subagent/workflow prompts.
  They are runtime captures; reading one risks contaminating a coefficient with a
  value not derived from the plugin. If such a file appears, delete it by name
  without reading it. (The rule stands even while no such file exists.)
- **No captures as data.** No Frida dumps or runtime snapshots feeding the port.
  A constant whose provenance is a capture is a bug to be replaced (ledger status
  CAPTURED).
- **Two-process rule:** never build a Unicorn E2E instance AND ctypes-load
  `libjuno.so` in the same Python process. Oracle and port runs are separate
  processes; they meet only through pickles.
- **Harness = plumbing only.** Emulation harnesses may set up memory, stub
  Win32/COM/CRT/ABI, hook istream reads, wire registers, and observe. They may
  NEVER reimplement plugin logic (no hand blob→param map, no hand value transform,
  no reconstructed recall table used as ground truth).
- **Label every claim** PROVEN(executed) / READ(static decomp or Script.xml) /
  INFERRED. No over-claiming, ever.

## Ground truth & paths

`truth/` holds `JUNO60.vst3`, `Script.xml`, `presetbankog1.bin`, `SHA256SUMS`
(checksum-verified). Resolve paths ONLY through `tools/verify/truth.py`
(`truth.VST3 / .SCRIPT_XML / .BANK`, `$JUNO_TRUTH` override, `verify()`/`require()`).
Never hardcode an uploads/absolute path — those die with the container.
`refs/allcode_decomp.tgz` is the full IDA decompile (provenance for RECONSTRUCTED
rows). Git history was rewritten 2026-07 to purge RE dumps — never restore them
from an old clone.

## Build & verify

- `make libjuno.so` — the engine (GUI + ctypes gates load this).
- `make test` — functional suite (unit battery: self-consistency + frozen-recording
  checks; it does NOT compare against the live plugin).
- `make verify` — the finish line: `test` + the LIVE plugin comparisons (recall_gate
  67-cell diff + full render A/B, both actually executed every run; reference
  pickles auto-regenerate from truth/ when the scratchpad is fresh) + the
  provenance ledger check + the completeness scan (every constant-bearing source
  file must be claimed by a ledger row's `sources` column — the net that catches
  MISSING rows, which is how the delay-feedback capture survived). RED while any
  gate fails or any CAPTURED/RECONSTRUCTED/UNVERIFIED row remains.
- `bash gui/web/build.sh` — WASM rebuild (emsdk); `node tools/verify/wasm_golden.mjs`
  proves WASM == native.
- `-ffp-contract=off` is load-bearing (reference is x86 SSE2, no FMA); the FMA
  canary test fails loudly if contraction slips in.

## Canonical gates (tools/verify/)

`truth.py` (paths/checksums) · `e2e_emu.py` (the Unicorn oracle) ·
`real_bank_parse.py`/`real_recall.py` (plugin's own parser + recall) ·
`plugin_recall_set.py` (plugin's own recall enumerator, rva 0x3B48A0) ·
`plugin_recall_ref.py` (self-proven recall reference) · `recall_gate.py`
(port vs plugin recall, 67/67 voice cells, 64 patches) · `recall_exhaustive_ref.py`
+ `recall_exhaustive_gate.py` (recall EXHAUSTED: every single-input front-panel cell
vs the plugin's setter over all 256 byte values x 3 rates; multi-input product/joint
cells deferred to recall_gate + formula tests) · `recall_render_ab.py`
(render A/B vs the plugin's own recall+render — the ONLY reliable FX gate, because
FX state is prepare/render-populated and cannot be gated from a cold apply_bank) ·
`gen_teensy_golden.py`/`wasm_golden.mjs` (Teensy/WASM reproducibility) ·
`provenance_check.py` (ledger linter) · `completeness_scan.py` (constants→ledger
attribution net; also audit-trails positive "captur*" comment mentions).

## Known open work (live list = PROVENANCE.tsv)

- **Render A/B: ALL 64 factory patches BIT-EXACT.** 57 non-arp (recall_render_ab)
  + 7 arp via two dedicated gates in `make verify` (recall_render_ab's oracle can't
  arpeggiate — no transport clock):
  - **arp SCHEDULE: PROVEN 7/7** — `arp_sched_ab.py` drives the plugin's OWN arp under
    emulation (recall + controller-method enable + transport ticks, assigner hooked)
    and diffs vs carp.c. Closed #96: the plugin's per-beat re-latch re-quantizes the
    step grid to the beat once per enable (commit 527398e).
  - **arp RENDER: PROVEN 7/7** — `arp_render_ab.py` replays the proven schedule into
    the plugin's render. The former [1,33,41] divergence's root cause (PROVEN,
    b2_statediff/b2_bcast2: the plugin's note events broadcast the "any key held"
    flag — cell 1856, = held-count>0 — to ALL 8 voices; the port set it only on the
    allocated voice, so an idle voice's free-run state diverged and the arp gating it
    inherited the seed) is FIXED by `juno_note_broadcast_held()` called from the
    assigner-level note paths (synth_note_on/off + bank-apply flush). Layout note:
    plugin voice v renders at state[v]+v*10512, NOT state[v]+0.
- **init/prepare constants: PROVEN** (`coldstate_ab.py`, LIVE GATE 6/7). The port's
  power-on state (init + prepare + chorus_init) is bit-identical to the plugin's own
  constructor + setSampleRate under Unicorn at 44100/48000/88200/96000/192000 — only
  the benign C++ header (<176, audio-inert) + 6 FX-recall-default cells (self-proved
  inert) differ. Retired the live-state-dump cross-check (the last capture). Caught +
  fixed 5 real 44100-only reconstruction bugs (102656 spurious rate-case; 4 Rev Ecf
  DPF Fc missing the 44100 arm) the single-rate live dump never exercised.
- **other host sample rates: PROVEN.** cold-state bit-exact at 88200/192000;
  recall PROVEN (exhaustive 624 + HPF 10240 exact multiply-first law — audit
  re-derived it independently and confirmed bit-exact at 60000 Hz too, 6144
  comparisons 0 mismatch); render is rate-agnostic (grep-verified: no state[16]
  read in voice/master render) and LIVE GATE 7/7 runs the full 57-patch render
  A/B at BOTH 44100 and 88200 — both BIT-EXACT 57/57 (44.1k added post-audit:
  it closed the one coverage gap, no render gate at the most common host rate).
- **PROVENANCE.tsv is 17/17 PROVEN** — zero RECONSTRUCTED/CAPTURED/UNVERIFIED. The
  binding finish line (`make verify` green = zero non-PROVEN rows) is met.
- **WARM (DAW-idled) parity: PROVEN for the driving tested.** Warm A/B = build →
  72000 idle samples → recall → note → 24000 render, BIT-EXACT (chillwave patch 3
  "BS Solid", the user-reported case; scratchpad warm_ab_p3.py). Root causes (both
  invisible to every cold gate):
  1. **Power-on slot-2 routing**: the plugin boots with EFFECT routing v551=2
     (chorus I) — read from its own params chase AND its state cell 11022052
     (= Prog_ID_EFX, the cell its EFFECT TYPE setter writes clamp(v,≤5) into,
     proven all 256 values). Its master therefore FREE-RUNS the v551∈2..4 chorus
     arm (LFO 90624.., BBD ring 95824..) from power-on. The port seeded 0 (Pan
     arm, silent-input = frozen state) → every chorus patch diverged warm. Fixed:
     JUNO_PROG_EFX moved 11022060→11022052 (the plugin's own cell), power-on
     default 2 written by juno_engine_prepare, 11022052 REMOVED from
     coldstate_ab's exclusion (gate strengthened).
  2. **Warm apply clobbered per-voice runtime**: patch LOAD did a full
     seed_voices block copy; the plugin's recall writes coefficient cells only.
     After idle, per-voice smoother runtime (rel 3344/3360/4640/4752/5296/5312 —
     outputs converged onto the per-voice CONDITION targets) is voice-distinct;
     the copy falsified voices 1..7, and a warm note lands on a rotation voice
     (not voice 0 — cold gates never see this). Fixed: ctx_recall LOADs now use
     the same changed-bytes delta replication as live edits.
  **Unit-mapping facts (per-unit diff harness = scratchpad idle_units.py):** the
  oracle renders voice v from unit v and the MASTER from unit 8 (e2e_emu.render);
  unit-0's master region is idle-dead. The aux one-shot array 101504+v*32 is
  per-VOICE state (compare vs unit v; unit 8's copies are dead 1.0s). Post-fix
  the idle-72000 per-unit diff is: voices 0/8 + noise + aux EXACT; master vs
  unit 8 differs ONLY in the 5 still-excluded FX-recall-default cells (known
  inert) — and warm note allocation lands on the same voice both sides.
- WASM artifacts REBUILT + verified: `gui/web/build.sh` (now with `-ffp-contract=off`)
  regenerates `gui/web` + `docs` from current source; `wasm_golden.mjs` proves the
  delivered WASM is bit-exact to native (8/8) on the 44.1 kHz golden corpus. emsdk
  lives at `scratchpad/emsdk` (source `emsdk_env.sh` before building).

## Host-lifecycle fidelity (user "still sounds wrong" arc, 2026-07-20)

- **THE GATES' STRUCTURAL BLIND SPOT (the lesson of this arc):** every gate
  compares port vs the plugin driven by OUR harness entries (recall dispatch +
  engine NOTEON). A real host enters through the VST3 wrapper (events→MIDI→
  queue→engine), and that layer TRANSFORMS the input. Port==oracle can be green
  while both differ from the real thing. Treat any user ear report that
  survives green gates as evidence against the gates.
- **Wrapper velocity policy (Stage 1, FIXED in port):** the wrapper's MIDI layer
  applies SYSTEM "fm.SYSTEM.COM.Keyboard Velocity SW" (flag byte queue+572,
  refreshed from the settings object in the connect path rva 0x320420). READ —
  three decomp sites with the identical rule (0x31F4E0 queue push, 0x3208E0
  all-sound-off injector, 0x320A30 connect forwarder): note-on vel 0 → becomes
  note-off(64); SW OFF → every note-on vel := 100, note-off vel := 64; SW ON →
  raw. So the real plugin by default IGNORES played velocity (JUNO-60-faithful)
  while the port passed it raw — audible on EVERY patch when playing live
  (velocity scales VCF+VCA). Port now mirrors the layering: engine entry
  juno_gui_note_on stays RAW (gates drive it, = oracle NOTEON); new wrapper
  entries juno_gui_midi_note_on/off + juno_gui_set_kbd_velocity carry the
  policy; webapp keys + Web MIDI use the wrapper path with a Kbd Vel SW toggle
  (default OFF = force 100). Default OFF is INFERRED (settings-object default
  needs the full wrapper lifecycle, #112); the policy itself is READ.
  Event→MIDI vel byte = trunc(velF*127.0)&0x7F (wrapper preamble 0x34A380).
- **Bounce locator (covenant role 1; scratchpad bounce_locator.py + session
  diag_bounces/):** port vs the user's 8 factory-preset Ableton bounces at the
  session's exact driving (44.1k/120BPM/vel100/0.5+2+1.5s). Pitch, onset,
  sustain RMS match. RESIDUAL (Stage 2, OPEN): port DARKER on 6/8 presets
  (centroid −7..27%), attack-window RMS ±10..20% patch-dependent (preset 0
  port louder, preset 5 port 22% quieter), stereo-corr differs, preset 6 lacks
  a ±0.4Hz pitch wobble. NOT velocity (100→100 through the wrapper; no single
  velocity reconciles brightness+level). Next: real-lifecycle state diff
  (plugin-via-process()+events vs plugin-via-harness — plugin against itself).
- **System tree map (for #112):** "fm.SYSTEM.COM.*" (Keyboard Velocity
  SW/Fixed Velocity/Curve/Offset, Local SW, MASTER TUNE, Boost Mode, Output
  Gain, ...): name table rva 0x9a0030 (SW = index 12), param DB {min,max,..}
  rva 0x5EC040 + 16*id (4966 ids, formatter 0x3ABB40), engine iface vtable rva
  0x9df1d8 (BUILD slot1, setSR slot3, process slot7, noteOff 15, noteOn 16).
  Old real-process harness: scratchpad/oracle/real_process_run.py (per-block
  render callback 0x3C7400 — BELOW the event layer; events enter via the
  wrapper process preamble 0x34A380 → queue → consumer).

## Standing audit caveats (Phase-E confirmation audit, 2026-07-17)

- Commit be3f1db's "these only affected 44.1 kHz reverb" OVERSTATES audible impact:
  recall unconditionally rewrites all 5 fixed prepare cells per patch
  (juno_apply_reverb writes the 4 DPF Fc with its own independently-derived
  REV_FC44/REV_FC tables — audit-verified == the plugin's setter; delay_recall
  writes 102656), so the old bugs were recall-masked for every patch render. Their
  only reachable surface was the pre-recall power-on state at 44.1k (reverb send 0).
  The cold-state fix is still required — the plugin's cold state is the ground truth.
- coldstate_ab now excludes 5 cells (was 6): 11022052 was NOT inert plumbing — it
  is the plugin's slot-2 EFFECT-routing int (power-on 2), and its exclusion hid
  the warm chorus-arm divergence (see WARM parity above). The old "none read in
  any render source" claim was wrong for it (master reads it through the
  params+112 chase every sample). The remaining 5 (102544, 10759360/472/840,
  11022344) keep their audited inert status; 11022344 is the warmup-mute latch
  the port never needs.
- coldstate_ab.py hardcodes the main-tree libjuno.so + pickle paths — run from a
  git worktree it silently gates the MAIN tree's library (project-wide convention,
  but a sharp edge for worktree-based testing).
- HPF 10240 law precision (audit re-trace): the divisor is cvtdq2ps of an INTEGER
  rate dword (== f32(H) for every integer host rate; port mirrors the int
  semantics), and the plugin SKIPS the mul/div at exactly 96000 (port does too via
  the table arm). T96 fetch lives in helper rva 0x3563BE.., store via 0x3C2763.

## Standing audit caveats (B1 confirmation audit, 2026-07-16)

- `delay_fb_sweep.py` is one-shot EVIDENCE, not a recurring gate: it always exits 0
  and is not in `make verify`. Ongoing enforcement of the delay law = exhaustive
  recall + render A/B + test_delay_recall (mutation-tested: both catch a wrong
  constant at exact coordinates).
- Commit 603f927's "no previously-passing patch changed" was argued too broadly:
  12 other TYPE-0 delay patches DID get new feedback coefficients; the gates
  confirm they still pass, but the diff alone didn't prove it.
- The feedback OFF-gate (102560 → 0 when DELAY LEVEL < 2) rests on captured OFF
  states; render-equivalent either way (wet=0), but re-prove via emulation when
  convenient.
- `gui/web/build.sh` now passes `-ffp-contract=off` (matches the native build); the
  wasm_golden WASM==native gate remains the standing safety net (8/8 bit-exact).

## Git

- Branch `claude/c99-gui-fable5-yfhak1`. `git push -u origin <branch>`, retry on
  network errors (2s/4s/8s/16s backoff). No PRs unless explicitly asked. Never put
  a model ID in commits, code, or any pushed artifact.
- Commit trailer (verbatim, every commit):
  `Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>`
  `Claude-Session: https://claude.ai/code/session_012SxLAY1bDPn2jACwFDPupA`

## Working style

Simplest fix that holds; reuse proven `juno_curve` tables and existing gates before
adding machinery. One reversible commit per fix; a change isn't done until its gate
is green. Proceed autonomously on reversible work; stop only for destructive or
scope-changing decisions.
