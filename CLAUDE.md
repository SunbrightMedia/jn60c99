# ⚑ RULE 1 — LANGUAGE (user-binding, repeated because it is always ignored)
**Respond ONLY in ASD-STE100 Simplified Technical English. Keep replies under
~150 words unless the user asks for detail. Tables and code do not count.**
The user says "STE" when you break this. Do not make them say it.

# ⚑ THE FIVE MANTRAS (user-binding, 2026-08-13; mantra 5 added 2026-09-16)
**Every action must advance one of these. If it advances none, do not do it.**
1. **REWRITE** the `.vst3` code, bit-exact.
2. **CONFIRM** that what you rewrote is correct — test it in every
   circumstance, not the convenient one.
3. **OPTIMIZE** the code AND your own work as you go.
4. **LEAVE A LEGACY** — what is done and what is learned must be repeatable for
   the next plugin, documented in the most efficient way possible.
5. **MY CODE IS NEVER ITS OWN JUDGE.** Every line I write is graded against
   PROVEN code that cannot lie — a differential oracle — and NO gate is believed
   until it is SEEN TO FAIL on a real defect. The harness is the prime suspect:
   it never reimplements plugin logic, and it carries an isolation control that
   MUST equal a known-proven path. (Every bringup defect so far was MY code —
   glue, harness, config, a threshold — never the proven engine. So trust the
   oracle, never my own word.)

Order matters. 1 before 2 is wrong (unproven code). 2 before 3 is required
(never optimize what is not proven). 4 is not last in time — write it as you
go, or it is not written. 5 underwrites 2: a CONFIRM that only my own harness
graded is NOT a confirmation — the oracle grades, and I must have watched it
fail.

# ⚑ ONE BOARD PER SYNTH (USER-BINDING 2026-09-23, overrides every multi-board line below)
NO multi-ESP32-S3 runs, ever: the user judged chip-to-chip linkage not stable enough. Every synth runs on ONE
board of ESP32-S3-class power. Two-chip / CHAIN4 / 4-slot multi-chip plans below are RETIRED (history only).
An engine that does not fit one board gets a cheaper engine graded against the bit-exact port. END_GOAL.md top.

# ⚑ READ FIRST, IN ORDER
1. `END_GOAL.md` — WHAT we build (user's words, binding). Short form: audibly
   identical, 6 voices, ONE ESP32-S3-class board (amended 2026-09-23; was two), full FX incl. chorus, seamless
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
5. `docs/INDEX.md` — every doc classified LIVING / REFERENCE / ARCHIVED with
   the question it answers. Look there BEFORE reading docs at random.

# THE ONE RULE EVERYTHING SERVES
The original `.vst3` (in `truth/`, checksummed, resolve paths ONLY via
`tools/verify/truth.py`) is the ONLY ground truth. The port is SELF-PROVING:
every constant proven against the plugin's own machine code executed under
Unicorn. Never validate by ear; never ask the user to A/B. "Done" =
`make verify` green = zero non-PROVEN rows in `PROVENANCE.tsv` (status: 20/20
PROVEN). USER-BINDING 2026-08-13: ZERO approximations in `src/` —
`tools/verify/approx_audit.py` enforces it every `make verify`.
USER-BINDING 2026-08-24: a green gate is NOT completeness. `make verify` green
means "the port agrees with the plugin WHERE THE GATES LOOK". Completeness is
governed by `docs/PORT_COMPLETENESS_CHARTER.md` — binding for EVERY .vst3 port:
census from the binary before gates, a tooth on the gate's own REACH, no TODO
behind a green gate, mutation reach (`tools/verify/mutation_gate.py`), and the
scope table stated with every claim. Never report "complete/100%" from a green
gate alone. If the user's own count disagrees with mine, theirs is evidence and
mine is a hypothesis (playbook 80).

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
- **LONG JOBS ONLY VIA `tools/run_job.sh`** (2026-08-26: two multi-hour gate
  runs died silently -- shell-tied, then killed by my own `pkill -f`, which
  MATCHES MY OWN SHELL's command text; progress was then reported from stale
  logs). run_job = setsid + registry + EXIT verdict; a dead job prints DIED,
  never looks finished. NEVER `pkill -f` ANYTHING -- kill exact pids from the
  registry. NEVER report a job's result without its EXIT file. Status:
  `sh tools/status.sh`. While a long job runs, keep a Monitor on its EXIT
  file (re-arm at each expiry): an idle session's container is reclaimed and
  the job dies with it (playbook 140).

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
- `jx3p/`, `jp8/`, `tb303/` — the next-synth ports, each with `truth/`
  (checksummed), `tools/`, `docs/S3_STATUS.md` (its only status page).
  `pi/` — the bare-metal Raspberry Pi track (Circle). `docs/hardware/` —
  boards, BOM, ordering, the user's board snapshots.
- Costs/levers/history: `docs/` + `docs/engineb/data/` — cite, do not restate.

# LIVE STATE (update in place, no dated blocks here, EVER; detail lives in
# FINAL_GUIDE.md / docs/ — this section is one line-group per arc)
- **src/ + trunk**: host layer 2026-10-07: the render driver + arp controller
  (A24) and the render object -- the 96 kHz engine of the default setting, the
  converter, silence outside the rate table (A25) -- are ported and bit-exact
  through the plugin's own process() (host_process_gate.py, 21 chains;
  docs/HOST_RENDER_LAYER.md); so are the MIDI controllers -- bend, mod wheel,
  expression, the 51 default CC assignments, parameter records (A26,
  midi_ctl_gate.py), and sustain CC 64 (a hold in the keyboard object) + all
  notes off CC 123 (A27), and a host-rate change on a running instance (A28,
  host_rate_gate.py), and the start-up as the plugin boots, its build's ramps in
  flight (A29, boot_gate.py, from the first sample), and an engine-rate switch on a
  running engine, setSampleRate in place (A30, rate_switch_gate.py), and the MIDI
  CC map in the DAW state -- setState empties and refills it (A31,
  ccmap_state_gate.py), and the state save (getState byte for byte, setState's
  stream framing), the UI-timer drain and MIDI learn (A32, state_save_gate.py).
  Open (task #36, the host-call census): the edit controller's own state and
  parameter list; a shared static buffer in the driver (multi-instance race,
  task #41). The web app's WASM is not rebuilt with the converter yet (needs
  emcc). Engine: PROVENANCE 33/33 PROVEN; full verify of
  cd63fc1 GREEN (job verify_fix3, EXIT 0, every section ran); ARM golden OK
  (job arm_golden_cd63, toolchain installed by apt in that container). The
  commits after cd63fc1 (A24..A31) carry their own gates; a full make verify
  of the last commit is owed (task #37). The two days 2026-10-05/06
  were audited: docs/AUDIT_2026-10-06.md (read its HANDOFF section first). CLAIMS B1-B12
  closed (B12: a fresh plugin plays the key's own velocity, A23). The PRODUCT paths are the plugin's own: juno_gui_plugin_init (six voices, 960-sample start-up
  mute), juno_gui_state_load (DAW preset), juno_gui_load_patch (its patch
  browser) -- host edits, gated by state_load_gate.py against queues the booted
  plugin makes (docs/B6_WRAPPER_BOOT.md). juno_gui_apply_bank is the recall MODEL
  the older gates use, not a product path. The web app runs the product
  paths (CLAIMS C4: `make webapp` = WASM build, WASM == native on the app's
  calls with a reach guard, headless-Chromium check); the device firmware
  still calls apply_bank. `make test static` before every commit. Gates compare
  the port in the oracle's FP mode (DAZ, no FTZ: playbook 120). Do not touch
  src/ except through a gate.
- **ONE-BOARD RULE**: every multi-chip arc is HISTORY — the S3 fork O4 arc
  (two chips), the CLASSIC 4-slot plan, CHAIN4 (four boards played through
  the storm on 2026-09-14). Their full live-state text, facts and owed items
  are archived verbatim in docs/HISTORY.md ("LIVE STATE archive"). What fits
  ONE S3: docs/ONE_BOARD_BUDGET.md — a faithful 6-voice JUNO does NOT (fork
  ~2,600 cyc/voice; one S3 holds ~3-4 voices + FX); a wavetable synth and the
  TB-303 do. EB_CLASSIC byte law + docs/CLASSIC_PANEL.md stay valid.
- **Pi track** (docs/pi/PORT_PI.md): the bit-exact JUNO (8 voices, all FX)
  runs on ONE bare-metal BCM2837 (Pi 3A+/Zero 2 W) under QEMU: 69/69
  scenarios bit-exact, invariant swarm clean, multi-core split exact, PLAY
  image built (pi/). Whether this track is "one board of equivalent power"
  under the 2026-09-23 rule is the USER's call — ask before resuming it.
- **Hardware**: modular boards for any synth (motherboard, headphone DAC,
  faders, muxes, keys, MIDI, button packs, switches, 7-seg backpack).
  docs/hardware/SESSION_HANDOFF.md (read its 2026-09-28 section first),
  BOM v2 in docs/hardware/bom/, ordering in docs/hardware/ORDERING.md.
  The user draws every board; Claude answers at pin/net level.
- **JX-3P (E5)**: PLAYS AND SOUNDS RIGHT. Recall 64/64 EXACT, full chain
  EXACTLY 0, listen proofs green on oracle and C twin, web app published.
  jx3p/docs/S3_STATUS.md rules. Open: master FX in the app, host recall
  protocol, other rates. INFERRED defect for the JX owners: jx_emu.build()
  also hands BUILD a zero HOST (JP8 D7 / playbook 101) — check it.
- **JUPITER-8**: jp8/docs/S3_STATUS.md rules (read its RESUME HERE block).
  Steps 0-4 PROVEN at 44100. DRIVE2 is the oracle (the plugin's factory
  builds the HOST, recall through HOSTPARAM, no snap). The machine-code
  lifter's three layer gates are EXACTLY 0 on drive2 with teeth; the PSI
  template + the oracle-recorded recall table are exported (jp8/gen/).
  NEXT: jp8.h + jp8_engine.c (self-booting engine) + the full-chain gate
  64/64. The bit-exact JP8 is ~5.3x one S3.
- **TB-303**: intake + cost recon only (tb303/docs/S3_STATUS.md): voice + FX
  ~66 % of one S3, NOT listen-certified; the harness was lost — rebuild it
  from jp8/tools/jp8_emu.py.
- **Parked tracks**: DAW-parity (HOSTPATH_PARITY_SCOPE steps 2-5) and Track B
  Daisi sonic-identity fork (harness done, zero voice code, blind-gate warning
  stands). Both resumable from HISTORY.md pointers.
- Older silicon facts (O1-O3 proven, split 7, t5 algorithm bound, two-chip
  link step 2, completeness audit): FINAL_GUIDE.md + docs/HISTORY.md. They
  remain true; they are no longer the live edge.

# BUILD & GIT
`make libjuno.so` | `make test` | `make verify` (finish line) | WASM:
`gui/web/build.sh` + `wasm_golden.mjs`. `-ffp-contract=off` is load-bearing.
Branch: push -u origin <current claude/* branch>; retry 2s/4s/8s/16s; no PRs
unless asked. Trailer: use the attribution block the HARNESS specifies for the
current session (it names the model and session URL). Never hardcode a model
ID anywhere else.
ESP-IDF: containers are ephemeral. If `/home/user/esp-idf/export.sh` exists,
source it (v6.2). Otherwise clone v6.1 (`--depth 1 -b v6.1`, the newest tag
with a public release; the 6.2.0 lock has none) + `./install.sh esp32s3`;
`IDF_PYTHON_CHECK_CONSTRAINTS=no` if the constraints download 403s. `which
idf.py` without sourcing export.sh says nothing — do not conclude from it.
FLASHING -- PASTE THE COMMANDS EVERY SINGLE TIME A .bin IS SENT. Never say
"same command as before" and never make the user scroll back. Verbatim, both
lines, in this order, with the delete reminder first:
  1. "Delete the old juno_s3.bin from Downloads first" (Windows renames a
     duplicate to `juno_s3 (1).bin` and the flash then fails on the old file).
  2. `cd %USERPROFILE%\Downloads` (the prompt opens in the home folder; the
     flash line fails with "No such file" without it -- paid 2026-09-29).
  3. `python -m esptool --chip esp32s3 -b 460800 --before default-reset
     --after hard-reset write-flash --flash-mode dio --flash-size 8MB
     --flash-freq 80m 0x0 bootloader.bin 0x8000 partitiontable.bin
     0x10000 juno_s3.bin`
  4. `python -m serial.tools.miniterm COM4 115200`
     (COM4 since 2026-09-29 -- esptool's own "Connected ... on COM4" line;
     was COM3, before that COM5. The flash line auto-finds the port; the
     monitor line does not. If it fails, the port esptool printed wins.)
The three-bin set lives in `esp32s3/flash/meas/` -- partitiontable.bin has NO
hyphen. Send builds from THERE, never from `esp32s3/build/`, whose paths and
names do not match what the user has. Only send builds worth flashing
(playbook 11b: measure first; state the decision rule before sending).
MERGED single-file images (esptool merge-bin, e.g. juno_s3_CLASSIC6.bin) flash
with ONE line instead -- paste it verbatim too:
  `python -m esptool --chip esp32s3 -p <PORT> write-flash 0x0 <image>.bin`

# WORKING STYLE
SHIP LAW (USER-BINDING 2026-09-14, paid in five bench nights): "never
validate by ear" applies to the LIVE layer too. The firmware carries a
SILENCE PROBE (SIL: line, per-voice peaks of the shipped bank; STUCK
verdict when quiet input meets a non-silent bank). No image is sent to
the user unless its own log proves the end state (storm off -> SILENT).
The user's ears are never the detector again.
Simplest fix that holds; reuse proven tables/gates before new machinery. One
reversible commit per fix; not done until its gate is green. Proceed
autonomously on reversible work; stop for destructive or scope-changing calls.
USER-BINDING 2026-09-13: NEVER run multi-agent Workflows (they burn the
user's usage limits). Do the work directly; a single background agent for a
bounded search is the ceiling, used sparingly.
THIS FILE holds rules and pointers ONLY. Findings go in docs/. A dated block
added here is a defect.
