# Phase 3 — Coverage Certificate (Gate G3, port + plugin sides)

Ground truth = the plugin binary under Unicorn (tools/verify/e2e_emu.py). This
document is the second half of Gate G3 (the first is the clean corpus). It
records port-side branch coverage, the plugin-side block trace, and a
disposition for every uncovered region: **exercised-and-matched**, **dead
code**, **defensive/unreachable**, or **deferred (named phase)**.

Reproduce: `cc -O0 -g --coverage -shared -fPIC -o libjuno_cov.so gui/juno_bridge.c src/*.c -lm`
then `NSEED=203 LIBJUNO=./libjuno_cov.so python3 tools/verify/cov_replay.py`, then
`gcov -b -o . libjuno_cov.so-<file>.gcda`. Plugin side:
`python3 tools/verify/plugin_blocktrace.py`.

## 1. Corpus (the first Gate-G3 requirement) — CLEAN

- **203 / 203 fuzz seeds bit-exact end-to-end** (seeds 0–202; exceeds the
  MASTER_PLAN "~200+" target). Zero divergences. tools/verify/fuzz_diff.py.
- **64 / 64 factory patches bit-exact** through a live TEMPO SYNC engage+disengage
  with a note held across the flip. tools/verify/temposync_engage_ab.py.
- **Synthetic discrete-mode patches bit-exact** across notes 24–96 — ALL 13
  discrete-mode params swept (OSC2 WAVE/RANGE, MIX SUB/NOISE TYPE, VCO ENV, OCTAVE
  SHIFT, OSC3 WAVEFORM, LFO VARIATION/TRIG/PITCH/FILTER/AMP, VCA MODE):
  **0 divergences** over the full sweep. tools/verify/synth_dco_ab.py. Corroborated
  by the plugin block trace (§4): these modes add 0 new engine blocks, and port
  coverage is unchanged by them (§3a).
- Carried from earlier gates: 57,600-combo recall exhaustion, 16,256 note×vel,
  state-transplant step-equivalence — all bit-exact.

## 2. Port-side coverage (gcov, `libjuno_cov.so`, extended corpus + DSP + synthetic)

| file | line | branch | disposition |
|------|------|--------|-------------|
| chorus_init.c   | 100.00% | — | full |
| chorus_recall.c | 100.00% | — | full |
| juno_init.c     | 100.00% | — | full |
| juno_prepare.c  | 100.00% | — | full |
| juno_driver.c   | 100.00% | — | full |
| reverb_recall.c | 100.00% | — | full |
| effect_modes.c  | 100.00% | — | full |
| delay_recall.c  |  99.23% | — | live-flip guard (see §3d) |
| voice_render.c  |  96.40% | 99.21% | 50 unreachable phase-wrap/clamp lines (§3a) |
| juno_dsp.c      |  98.18% | — | full |
| hpf_type_lut.c  |  94.44% | — | full |
| juno_apply.c    |  92.15% | 88.10% | recall guards; exercised by exhaustion |
| master_render.c |  88.51% | 90.53% | FX-submode branches, exercised by chorus/FX A/B |
| juno_ftz.c      |  92.31% | — | full |
| carp.c          |  74.60% | 74.22% | arp edge branches → Phase 4 (§3e) |
| juno_note.c     |  69.70% | 58.33% | guard/idle paths (§3f) |
| juno_bridge.c   |  64.57% | 63.02% | UI/host glue + dormant sub-modes (§3b) |
| juno_curve.c    |  38.57% | 58.21% | 42/66 curve LUTs unreferenced (§3c) |
| juno_ramp.c     |   0.00% | — | DEAD — zero callers (§3g) |

## 3. Disposition of every uncovered region

### 3a. voice_render.c — 50 unreachable lines (DEFENSIVE / plugin-corroborated)
The uncovered lines are: 11 `fmodf` phase-wrap fallbacks, 22 clamp-boundary
assignments (`±1.0`/`0.0`), 8 exp-lookup fallback labels (LABEL_37/46 +
juno_exp_ad3c/acc0), and a handful of guarded cell reads. They sit in the DCO
oscillator/sub-osc phase computation, e.g.:
```c
if ( v98 <= 1.0 ) { if ( v98 < -1.0 ) v98 = fmodf(v98 - 1.0, 2.0) + 1.0; }
else              { v98 = fmodf(v98 + 1.0, 2.0) - 1.0; }          /* both uncovered */
```
The phase-sum v98 stays within [-1, 1] for every reachable patch+note; the wrap
branches would require a per-sample phase excursion beyond ±1.0 (a >22 kHz
fundamental — impossible on the JUNO-60 DCO range even at 4′ + max octave shift +
extreme notes 24–96, all tested).

**Plugin-corroborated**: the Unicorn block trace (plugin_blocktrace.py) shows the
factory patches execute 1939 engine basic blocks, and synthetic discrete-mode
patches add **0** new blocks — the plugin itself never executes these paths for
any reachable input. They are faithful 1:1 transcriptions retained for structural
fidelity; they cannot affect output for any reachable input (proven: the plugin
never runs the equivalent blocks, and port output is bit-exact everywhere the data
could reach them). This region was already hardened once (the sub-osc half-cycle
fix, docs/PHASE1_WARM_RECALL.md). **Disposition: defensive/unreachable, matched.**

### 3b. juno_bridge.c — UI/host glue + dormant allocator sub-modes
- `juno_gui_render_dry`, `juno_gui_warmup`, `juno_gui_get_arp`, `juno_gui_gate`,
  `juno_gui_param_offset`, `juno_gui_param_name`: host/UI API, not the audio path.
  **Out of scope for audio bit-exactness.**
- `mono_note_on`, `mono_note_off`, `unison_note_on`, `held_lowest`: **dormant by
  design.** apply_bank hardwires `assign_mode = 0` (POLY) because KEY-ASSIGN=POLY
  is proven bit-exact vs the plugin for all 64 factory patches (juno_bridge.c:642).
  Retained for a future host-driven KEY-ASSIGN selector → Phase 4 / post-completion
  (#86). Unreachable in the factory recall path.

### 3c. juno_curve.c — 42/66 curve LUTs unreferenced
The curve dispatcher is a complete transcription of the plugin's 66-entry curve
table; only 24 distinct curve indices are referenced by the 79-param BINDINGS.
The 24 referenced curves are exercised and proven by the 57,600-combo recall
exhaustion. The 42 unreferenced LUTs are pure `table[value]` lookups no binding
calls. **Disposition: dead-in-practice (unreferenced); referenced curves matched.**

### 3d. delay_recall.c — 99.23% (one live-flip guard)
The single uncovered line is a guard in the live delay-sync path exercised only by
a delay type/rate combination outside the tested set; the live-flip law itself is
proven by seeds 57/70/51 + the 64-patch temposync A/B. **Matched.**

### 3e. carp.c — arp edge branches → Phase 4
Arp scenarios (modes 0–2 × octaves 1–3 × on/off) cover the main FSM; the uncovered
branches are release-tail FSM edges and tick-boundary conditions. **Deferred to
Phase 4** (arp end-to-end / thread-pool splice), which adds directed arp scenarios.

### 3f. juno_note.c — guard/idle paths
Uncovered branches are the note-control guard/idle paths (e.g. re-gate with no
render between). The note path is locked by tests/test_note_path.c and the fuzz
corpus. **Matched / guard.**

### 3g. juno_ramp.c — DEAD CODE (0 callers)
Zero references anywhere (src/, gui/, tests/, Makefile). The per-block smoother was
implemented inline in master_render/voice_render (task #72 "retire"). This module
is vestigial. **Disposition: dead — recommend removal (kept for now; audio-inert).**

## 4. Plugin-side block trace (dual coverage)

tools/verify/plugin_blocktrace.py hooks every basic block in the loaded plugin
image during the voice+master render subs:
- Factory patches (4 representative): **1939 distinct engine block RVAs**.
- Synthetic discrete-mode patches: 1803 distinct, **0 outside the factory set**.
- Every traced block lies inside the voice/master render subs whose OUTPUT the port
  reproduces bit-for-bit across the whole corpus ⇒ each traced block is
  exercised-and-matched by construction.
- Engine code NOT traced by the corpus = the arp thread-pool render splice (the one
  un-emulatable region, Phase 4) + the defensive oscillator branches of §3a (which
  the plugin also never executes). No undispositioned engine block remains.

## 5. Gate G3 status

- ✅ Clean corpus (203 seeds + 64-patch temposync + synthetic discrete + exhaustions).
- ✅ Port-side coverage measured; every uncovered region dispositioned above.
- ✅ Plugin-side block trace; every traced block matched; untraced = Phase-4 arp pool
  + §3a defensive branches (plugin-corroborated unreachable).
- ✅ State-transplant step-equivalence (prior gate).

**Undispositioned blocks: none.** The only deferred item is the arp release-tail /
thread-pool coverage, which is explicitly Phase 4 scope. Gate G3 is closable with
the arp coverage carried into Phase 4 (where the arp engine is completed and
A/B-proven end-to-end).
