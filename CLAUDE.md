# ⚑ RULE 1 — LANGUAGE (user-binding, repeated because it is always ignored)
**Respond ONLY in ASD-STE100 Simplified Technical English. Keep replies under
~150 words unless the user asks for detail. Tables and code do not count.**
The user says "STE" when you break this. Do not make them say it.

# ⚑ READ FIRST, IN ORDER
1. `END_GOAL.md` — WHAT we build (user's words, binding). Short form: audibly
   identical, 6 voices, EXACTLY two ESP32-S3s, full FX incl. chorus, seamless
   real time, complete control of every parameter incl. recall, confidently
   proven, and THE WHOLE PROCESS REPEATABLE for the next synth (item 7). Plus
   THE INVARIANT: audio never breaks, for any input; changes may land late.
   Ruled out forever: third/different chip, 32 kHz, fewer voices, dropping FX.
2. `FINAL_GUIDE.md` — the ONLY status page. Five tracks A–E, the order, the
   health-line rules. Status = one line per track, ten lines max, regressions
   first, no cycle counts in headlines.
3. `docs/engineb/METHOD_PLAYBOOK.md` — 47 numbered defects. Update it the day
   a new one is paid for.
4. `docs/HISTORY.md` — the full dated log (the old CLAUDE.md, verbatim).
   Read it when an old number or claim needs provenance; the docs it cites win.

# THE ONE RULE EVERYTHING SERVES
The original `.vst3` (in `truth/`, checksummed, resolve paths ONLY via
`tools/verify/truth.py`) is the ONLY ground truth. The port is SELF-PROVING:
every constant proven against the plugin's own machine code executed under
Unicorn. Never validate by ear; never ask the user to A/B. "Done" =
`make verify` green = zero non-PROVEN rows in `PROVENANCE.tsv` (status: 20/20
PROVEN). USER-BINDING 2026-08-13: ZERO approximations in `src/` —
`tools/verify/approx_audit.py` enforces it every `make verify`.

# HARD RULES (violating any corrupts the project)
- **Diagnostic-capture covenant**: the user's DAW bounces (scratchpad
  diag_bounces/) are DIAGNOSTIC ONLY. Never derive/fit/tune any constant from
  them, never use as gate reference, never commit. Roles: locate harness-vs-
  host divergence + completion test. Re-derive every fact from the binary.
- **NEVER open/read/reference `user_patch5_ableton.json` or
  `captured_coeffs.json`** — anywhere, incl. subagent prompts. If such a file
  appears, delete it by name without reading it.
- No captures as data. A capture-derived constant is a bug (ledger CAPTURED).
- **Two-process rule**: never build a Unicorn E2E instance AND ctypes-load
  `libjuno.so` in one Python process. They meet only through pickles.
- Harness = plumbing only. It may never reimplement plugin logic.
- Label every claim PROVEN(executed) / READ(static) / INFERRED.
- The user's 12 banks (scratchpad/userbanks/) are INPUT, never ground truth,
  never committed.
- FREEZE the tree while any gate runs. Editing a comment is editing (defect
  paid 2026-08-13: one full 12-bank run invalidated).
- A number quoted N times is not thereby measured (playbook 46). MEASURE.
- Every detector/gate/tooth must be SEEN TO FAIL before it is believed.
- No model IDs in commits/code/pushed artifacts.

# STRUCTURE (what lives where)
- `src/` — the FROZEN bit-exact port. Transcribed DSP + derived recall.
  `make verify` is its finish line and is green.
- `engine_b/` — the trunk (bit-exact, null EXACTLY 0, all 64 patches) and the
  S3 fork (build flags; sonic gate). Trunk never approximates.
- `esp32s3/` — device firmware. Playable now: console keyboard, b/n patch
  step, 2 voices+FX real time (un=0, gap=block period). MIDI: UART GPIO 18
  proven path; USB MIDI does not enumerate yet (core alive, GSNPSID OK).
- `tools/verify/` — canonical gates. `tools/engineb/` — fork gates + device
  recall. `truth.py`, `e2e_emu.py` (oracle), `recall_gate.py`,
  `recall_render_ab.py` (arp set now DERIVED per bank via `juno_bank_arp` —
  never hardcode data properties), `userbank_parity.py`, `approx_audit.py`.
- Costs/levers/history: `docs/` + `docs/engineb/data/` — cite, do not restate.

# LIVE STATE (2026-08-13 — update in place, no dated blocks here, EVER)
- 12-bank user parity vs src/: recall 768/768 PASS. Render re-running after
  the arp-list fix; prior 111 fails are UNATTRIBUTED until it lands.
- Fork on silicon: 2v+FX fits (5,442 budget); DELAY TYPE 2/3/5 patches ~6,800
  = over budget = invariant violation; PSRAM scattered read ~244 cyc (rings
  live there); patch-change burst ~2.0 M cyc (attributed; note path ~135 k via
  eb_recall_build_voices, proven bit-identical + 2 teeth).
- Next per FINAL_GUIDE: C11 event API → C10 chunked recall → C9 per-param
  refresh; B3/B4 worst-case; D link (zero code); random full-state gate owed.

# BUILD & GIT
`make libjuno.so` | `make test` | `make verify` (finish line) | WASM:
`gui/web/build.sh` + `wasm_golden.mjs`. `-ffp-contract=off` is load-bearing.
Branch: push -u origin <current claude/* branch>; retry 2s/4s/8s/16s; no PRs
unless asked. Trailer verbatim:
`Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>`
`Claude-Session: https://claude.ai/code/session_019dkoF3tvNYDygVXy9RBXJb`
Flash instructions to the user: always BOTH the esptool write-flash line AND
`python -m serial.tools.miniterm COM5 115200`. Only send builds worth flashing
(playbook 11b: measure first; state the decision rule before sending).

# WORKING STYLE
Simplest fix that holds; reuse proven tables/gates before new machinery. One
reversible commit per fix; not done until its gate is green. Proceed
autonomously on reversible work; stop for destructive or scope-changing calls.
THIS FILE holds rules and pointers ONLY. Findings go in docs/. A dated block
added here is a defect.
