# HOSTPATH PARITY SCOPE — close every remaining gap between the port and a REAL host instance. Opus 5: execute to the letter, in order.

**Why this scope exists.** The engine is proven bit-exact against the plugin's own
machine code on every gated surface (recall, render, sequences, fuzz, voice-assign
28/28 + Chillwave 16/16). Yet the user still reports audible differences vs their
DAW instance: intense peaking on the first note of unison patches, peaks elsewhere,
a quieter-sounding filter, "many more problems", and a measured, bidirectional
per-patch residual vs the DAW bounces (centroid mean |Δ| ~12%, RMS ±10–18%).
Everything engine-side is exonerated; **the ONLY unexecuted code between our gates
and the user's ears is the VST3 wrapper lifecycle** (settings defaults, the
event→MIDI→queue note path, setState preset load) **plus the delivery chain**.
This scope derives all of it from the binary, by execution, and gates it forever.
No hand-tuned value may enter anywhere — this is the anti-bandaid plan.

**Covenant (absolute, unchanged):** the DAW bounces (`scratchpad/diag_bounces/`,
`lastcatpureEVER.wav`) are LOCATE + COMPLETION-TEST ONLY. No number derived from
them enters the port, a gate reference, or the ledger. Ground truth = the plugin's
machine code executed under Unicorn. Two-process rule holds. Label every claim
PROVEN(executed) / READ(static) / INFERRED. Never ask the user to A/B.

**One reversible commit per closed family. Do not advance past a STEP until its
DONE WHEN is literally true. If blocked, STOP and log the blocker in
`docs/HOSTPATH_PARITY_LOG.md` — do not invent an alternative path.**

---

## The symptom ledger (treat each as EVIDENCE, resolve each to a STATUS)

| # | User symptom | Current status | Owning STEP |
|---|---|---|---|
| S1 | "Starting note is peaking intensely" (unison patches) | Engine levels PROVEN == plugin (BS Glide peak 1.981; Boost 21 / Output Gain 22 are executed no-ops — `probes/assigner/boost_dispatch.py`; wrapper output has no gain stage, only the license-gated demo bit-crusher). Browser clamped at 0 dBFS → distortion; monitor fader shipped (delivery-level, the DAW-fader role). **Open question: does a real host's FULL lifecycle produce identical engine state → identical levels?** | STEP 3 |
| S2 | "Peaks in a bunch of other places" | Same as S1 — the five >1.0 patches are all Chillwave unison. Same open question. | STEP 3 |
| S3 | "Filter sounds even quieter" | Engine VCF laws PROVEN. Candidates: (a) velocity — port forces 100 (Kbd Vel SW OFF), which is READ but the DEFAULT is only INFERRED; (b) the SYSTEM Velocity Curve/Offset/Fixed-Velocity family, never derived; (c) perception vs clipped unison patches. | STEPS 1+2 |
| S4 | "Many, MANY more problems" | Unenumerable from prose → close the CLASS: prove the whole wrapper note/CC path and the whole setState path, so no wrapper transform can differ. | STEPS 2+3 |
| S5 | #124 bounce residual (centroid ~12%, RMS ±10–18%, bidirectional, per-patch) | Host-lifecycle-pinned (port == plugin's own recall+render bit-exact on those very patches). This is the completion metric. | STEP 5 |

---

## Known anchors (verified this project — reuse, do not re-derive)

- Wrapper `process()` = rva `0x34A380`: event→MIDI intake ON the calling thread;
  tail passes the OUTPUT BUFFER POINTER ARRAY to the queue consumer
  `sub_7FF91DF80B20` = `0x320B20` (decomp_340000.c:7843–8094). The consumer calls
  the engine render via `a1+96` and afterwards applies ONLY the license-gated
  demo bit-crusher (decomp_300000.c:27702+, `(int)(x*256) & ~mask * 2^-9`,
  gated on `sub_7FF91DED9E90()`); **there is no wrapper gain stage** (READ).
- MIDI push `0x31F4E0`, all-sound-off injector `0x3208E0`, connect forwarder
  `0x320A30`, connect path `0x320420` (pushes Kbd-Vel-SW + transport; flag byte
  queue+572). Velocity rule (READ, 3 sites): vel0→off(64); SW OFF→on:=100,
  off:=64; SW ON→raw. Event→MIDI vel byte = `trunc(velF*127.0)&0x7F`.
- `IComponent::setState` = `0x34aaa0` (real IBStream impl), `getState` = `0x349ea0`.
  IComponent = class+48 (vt `0x967af0`), IAudioProcessor = class+272 (vt `0x967b68`),
  `createInstance` returns IAudioProcessor ⇒ class base = ptr−272.
  Component/controller CONSTRUCTION under Unicorn already works:
  `scratchpad/proc_create.py` / `ctrl_create.py`.
- Engine host param entry = engine vtbl+112 = `0x3C7AE0`: per unit,
  `proc[u]->+88(idx,0,v)` **then** `assign[u]->+8(4)` (the assigner refresh —
  `e2e_emu.assigner_notify()`); special-routes 831–835/756 to the arp object at
  `HOST+136+64u`; host-only value transforms idx 20/22/665/707/769/871.
- SYSTEM tree: names rva `0x9a0030` (stride 8; 'Keyboard Velocity SW' = index 12
  area; Boost Mode 21, Output Gain 22, VOLUME 373, Volume CC#7 496, PERFORM
  LEVEL 615, PART LEVEL 661/703); param DB rva `0x5EC040 + 16*id` (4966 ids,
  formatter `0x3ABB40`); engine descriptor DB rva `0x98c040 + 16*idx`.
- The paramID→index map global (rva `0xCB0E18`) is NULL after build/proc-create/
  ctrl-create — do NOT call `0x3C7AE0` with VST3 paramIDs; call `0x3B9A30` +
  `assigner_notify()` directly (they are its entire effect, PROVEN).
- **METHODOLOGY:** read `docs/P112_FINDINGS.md` §8 (4 protocol errors) plus §the
  new 5th (ASSIGNER_MODE_FINDING.md): *never validate a hand-written component
  against an oracle in which the plugin code it replaces was unreachable* —
  before concluding "the plugin does X", prove not-X could have executed.
- Probe style: `probes/assigner/laneX_*.py` (build → recall via
  `recall_render_ab.prepare_recall` → mutate via the plugin's OWN code → diff
  full 9×0xA83010 state → render RMS). Two-process for any port comparison.

---

## STEP 0 — Baseline
- `make verify` must be GREEN end-to-end with the regenerated (post-assigner-fix)
  references. It is resumable: reference pickles under `scratchpad/` persist;
  after any container restart just re-run `make verify` — `fresh` skips what's
  done. Record HEAD sha + the full gate tally in `docs/HOSTPATH_PARITY_LOG.md`.
- **DONE WHEN:** verify exits 0 and the log has sha + tally.

## STEP 1 — SYSTEM defaults, PROVEN (kills the last INFERRED label in the note path)
- The port's `kbd_velocity_sw` default (OFF→force 100) is INFERRED. Flip it to
  PROVEN by executing the SETTINGS OBJECT's own initialization under Unicorn:
  construct the controller (`ctrl_create.py`), locate the settings/system object,
  and read back the REAL defaults of the whole `fm.SYSTEM.COM` family —
  Keyboard Velocity SW, **Fixed Velocity, Velocity Curve, Velocity Offset**
  (these three have never been derived and directly gate S3), Local SW, MASTER
  TUNE, Boost Mode, Output Gain, Volume/CC7 handling. If the object resists
  construction, fall back to the DB defaults at `0x5EC040+16*id` (READ) plus the
  connect-path writer `0x320420` executed against a stubbed queue (PROVEN for
  what it pushes).
- Wire any default that differs from the port's into `juno_bridge.c`/webapp.
- **DONE WHEN:** a table of SYSTEM defaults labeled PROVEN/READ is in the LOG,
  and the port's wrapper layer provably matches it.

## STEP 2 — The wrapper NOTE/CC path, EXECUTED end-to-end (closes S3/S4's class)
- Single-threaded, no pool: drive the REAL chain `0x34A380` preamble →
  `0x31F4E0` queue push → `0x320B20` consume (call the consumer directly with
  the queued events; kill any >5-min spin) on a recalled engine, for the matrix:
  note-on velocities {1, 64, 100, 127, float in-between} × Kbd Vel SW {ON, OFF}
  × note-off, sustain CC64 hold/release, CC7, CC1 mod, pitch bend, all-notes-off.
  Hook the assigner entries (vtbl+16/+24, the `arp_sched_ab.py` pattern) and
  record exactly what reaches them + the full engine-state delta.
- Diff against the port's wrapper layer (`juno_gui_midi_note_on/off`,
  `juno_gui_set_kbd_velocity`, CC handling) driven with the same events,
  two-process. EVERY difference (a velocity curve, an offset, a CC transform,
  an ordering rule) = derive its law from the executed code, port it, and add
  the case to the gate in STEP 4.
- **DONE WHEN:** the executed event matrix produces identical assigner-level
  calls + engine state on both sides, or every difference has a derived,
  ported, gated law.
- ALSO in this step: audit the port's LIVE-EDIT parity with `0x3C7AE0` — the
  real entry runs `assigner_notify` after EVERY host write; confirm the port's
  `juno_gui_set_param`/host_set path re-reads voice-mode state exactly when the
  plugin would (PORTAMENTO already mirrored; verify nothing else in the
  BINDINGS panel can change allocator-visible state without a refresh).

## STEP 3 — setState H1 completion (closes S1/S2's open question + the #124 core)
- Feed the REAL preset blob for each of presets 0–7 (the bounce set) + BS Solid
  through the plugin's OWN `IComponent::setState` (`0x34aaa0`) on a constructed
  component, flush controller→processor sync (the connect path / queue consumer
  called directly), then FULL-STATE DIFF all 9×0xA83010 units vs our
  recall-driven engine for the same preset. Every differing cell is, by
  definition, a wrapper-lifecycle effect our recall lacks.
- For each divergent cell family: re-derive the writing code's law per byte
  (PROVEN), wire into the port's recall, extend `recall_render_ab`'s reference
  so the render A/B covers it.
- Then the LEVEL question (S1/S2) answers itself: render the setState-driven
  engine and compare peak/RMS to the recall-driven render — identical state ⇒
  identical levels ⇒ the monitor fader is confirmed as pure delivery (a DAW
  fader), not a mask; different state ⇒ we found the real attenuator and port it.
- If `initialize`'s CRT/TLS wall blocks the full component path, do NOT fight
  it: setState's own IBStream parse + the enumerated engine calls it makes are
  directly callable — the walls are documented in `docs/P112_FINDINGS.md`.
- **DONE WHEN:** setState-vs-recall full-state diff = 0 cells on all probed
  presets (or every divergent family derived, ported, gated).

## STEP 4 — Freeze it: `hostlifecycle_ab.py` in `make verify`
- New permanent gate: (a) the STEP 2 event matrix through both wrapper layers,
  bit-exact; (b) one setState-vs-recall state diff on ≥2 presets incl. one
  UNISON patch; (c) the STEP 1 defaults asserted against the port's values.
- **DONE WHEN:** in `make verify`, green, and mutation-tested (flip one port
  constant → gate must go red).

## STEP 5 — Completion test (covenant role 2 ONLY) + ship
- Re-run `scratchpad/bounce_relocate.py`: the per-patch centroid AND RMS deltas
  vs the 8 DAW bounces should collapse toward 0 if STEPS 1–3 closed real gaps.
  Whatever the numbers, they go in the LOG as diagnosis — never into code.
- `make verify` green → `bash gui/web/build.sh` → `wasm_golden.mjs` 8/8 →
  re-bundle with the Chillwave bank → `verify_webapp.mjs` → republish the SAME
  artifact URL → commit, push `claude/c99-gui-fable5-yfhak1`.
- **DONE WHEN:** artifact republished, branch pushed, verify green, LOG updated
  with the before/after residuals.

---

## THE EXIT TEST (no ambiguity)
This scope is DONE when EITHER:
1. STEPS 1–4 landed (all defaults PROVEN, event matrix bit-exact, setState diff
   0-or-ported, gate green) AND STEP 5's residual measurement is recorded; OR
2. A STEP hits a documented hard wall (named rva + failure mode in the LOG),
   everything before it is landed and gated, and the wall is stated as the
   single remaining surface — with no new theory invented to paper over it.

## HARD DON'Ts (each has burned this project before)
- DON'T tune, fit, or "correct" ANY value toward a capture or by ear. If a
  symptom can't be reproduced by executing plugin code, its status is OPEN, not
  guessed. The monitor fader is the ONLY permissible delivery-side control and
  its value is a UI default, never a claim about the plugin.
- DON'T fight the thread pool (call consumers directly; kill >5-min spins).
- DON'T compare after partial restore / without descriptor writes / outside
  ranges / against a pristine engine / against an oracle that can't reach the
  code under test (P112 §8 + the 5th error).
- DON'T leave a divergence uncharacterized, and DON'T start a new investigation
  thread when a step blocks — STOP and log.
- DON'T let the fuzz/gates rot: any new wrapper behavior must land WITH its
  gate case in the same commit.
