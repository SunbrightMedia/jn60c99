# ⚑ RULE 1 — LANGUAGE (user-binding, repeated because it is always ignored)
**Respond ONLY in ASD-STE100 Simplified Technical English. Keep replies under
~150 words unless the user asks for detail. Tables and code do not count.**
The user says "STE" when you break this. Do not make them say it.

# ⚑ THE FOUR MANTRAS (user-binding, 2026-08-13)
**Every action must advance one of these. If it advances none, do not do it.**
1. **REWRITE** the `.vst3` code, bit-exact.
2. **CONFIRM** that what you rewrote is correct — test it in every
   circumstance, not the convenient one.
3. **OPTIMIZE** the code AND your own work as you go.
4. **LEAVE A LEGACY** — what is done and what is learned must be repeatable for
   the next plugin, documented in the most efficient way possible.

Order matters. 1 before 2 is wrong (unproven code). 2 before 3 is required
(never optimize what is not proven). 4 is not last in time — write it as you
go, or it is not written.

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
  `sh tools/status.sh`.

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

# LIVE STATE (update in place, no dated blocks here, EVER; detail lives in
# FINAL_GUIDE.md / docs/ — this section is one line-group per arc)
- **src/ + trunk**: SEALED. `make verify` green, PROVENANCE 20/20 PROVEN,
  WASM republished. Do not touch src/ except through a gate.
- **Fork on S3 (O4 arc, through b43)**: ⚠ VOICE-5 DEFECT (fixed e611f7d-era,
  see HISTORY): S3L_VOICE_LO=6 carried into "3-voice" builds — voice 5's audio
  NEVER RENDERED, so every earlier 3-voice timing number was 2-voice. The
  first honest 3-voice build (JUNO-3V, [LISTENv3] tags) is STAGED in
  esp32s3/flash/meas/ and UNFLASHED — no honest 3-voice budget exists yet.
  Levers refuted ON SILICON (do not re-litigate): reverb-half (+135 net),
  per-file -O3 on FX (0), fuse-VCA (+168). Landed: EB_ZEROCOEF_T5 (−70 fx,
  legal set G1/G3/G5 only). CHUNK=64 click causes closed one by one: bench
  demo bursts, console key auto-repeat, reporter UART (S3L_REPORT_SECS),
  DMA depth. Exact-only cost MEASURED (b43): the bit-exact engine is ~2x the
  fork; two chips CANNOT run it, four could at ~88-90% on paper.
- **CLASSIC port (user-directed 2026-09-02)**: EB_CLASSIC = the 1982 panel.
  Master chain drops delay/reverb/e5 (each replaced by its module's own OFF
  law); ZERO FX rings; strict byte law `eb_patch_classicize` pins every
  non-1982 parameter at neutral FOREVER, recall included (ENV2:=ENV1,
  VCA TONE:=128 proven passthrough, EFFECT TYPE clamped {2,3,4}).
  Correctness standard: vs the VST limited the same way. Binding doc:
  docs/CLASSIC_PANEL.md. USER-BINDING 2026-09-03: classic must come from the
  ORIGINAL PORT's sound = trunk + EXACTLY-0 levers only (src/ cannot fit S3).
  MEASURED on silicon (b44, docs/engineb/data/b44_classic_silicon.md): byte
  law proven on-chip on both engines; delay=22 reverb=4; exact-classic voice
  ≈5,045 cyc (v1 minus wait — v1 INCLUDES the spin, never quote it raw) →
  6 voices + chorus ≈31–35k → the 4-slot board (40k) at 78–88% is the
  machine. Fork classic: two chips ≈70–77% INFERRED. Owed: silence the
  single-board LINK BAD-PAIR churn before the next budget number.
- **CHAIN4 (2026-09-03)**: the 4-board build EXISTS and is STAGED in
  esp32s3/flash/chain4/pos{1..4} (three-bin sets). Design binding:
  docs/engineb/CHAIN4.md. The pair-sum law proven EXACTLY 0 on host
  (tools/engineb/chain_gate.sh, tooth bites); base 0 + one chord-6 key on
  all four chips; hops = the proven pairwise link ×3, TDM4; notes ride a
  checksummed event chain from chip 1. Pos 1 alone: VERIFIED GREEN on
  silicon (b45, 10th flash sha 5a326f29d) -- cyc 5,217/5,442, miss 0/10k
  over 160 s, drift/deficit FROZEN, un=0; note path + event tap PROVEN
  (robot). The miss ghost = the donated tick vs an untaught detector
  (3 wrong attributions on the way -- b45 records all). EVQ-refused
  HEALTH line under robot flood is the queue working, not a fault.
  Law: one exact voice per core MAX; prologue+master must ride the light
  core (S3L_PROLOGUE_C1, no REV_PIPE). Next: wire hop 1<-2 (CHAIN4.md
  section 6); criterion hs=OK + mix=OPEN + CRC MATCH.
- **Hardware (user-directed)**: MasterAudio 4-slot carrier board for N16R8
  DevKitC-1 boards (JLCPCB/LCSC). The user draws the schematic by hand;
  docs/hardware/ holds the connection reference, PCB placement notes, and
  open BOM items (LM2776 C69527 is the -5 V rail; TPA6120 needs it).
- **JX-3P (E5)**: PLAYS AND SOUNDS RIGHT (2026-09-05). Two harness defects
  hid for weeks behind green gates (playbook 87 SETSR ABI = float in xmm1;
  playbook 88 bank decode 16 bytes off) plus one bridge defect (link
  pointers to template copies, PORT_LESSONS 8). All fixed, all gated:
  recall 64/64 EXACT, full chain 9/9 EXACTLY 0 incl. FREQ-MOD patches,
  listen proofs GREEN on oracle AND C twin (jx_listen.py / jx_listen_c.py:
  pitch tracks keys, harmonic, idle silent, release decays). 64-patch full
  gate: see S3_STATUS. Web app rebuilt + republished (one link, artifact
  d8679bea). Pipeline for the next synth: docs/PORT_PIPELINE.md + tools
  pe_recon / abi_check / audio_metrics / jx_bank_census. Open: master FX
  in the app (dry voice sum ships), true host recall protocol, other rates.
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
  2. `python -m esptool --chip esp32s3 -b 460800 --before default-reset
     --after hard-reset write-flash --flash-mode dio --flash-size 8MB
     --flash-freq 80m 0x0 bootloader.bin 0x8000 partitiontable.bin
     0x10000 juno_s3.bin`
  3. `python -m serial.tools.miniterm COM3 115200`
     (COM3 since the 2026-08-29 PC reset -- was COM5; if flashing fails, the
     user re-checks Device Manager -> Ports and we update this line again.)
The three-bin set lives in `esp32s3/flash/meas/` -- partitiontable.bin has NO
hyphen. Send builds from THERE, never from `esp32s3/build/`, whose paths and
names do not match what the user has. Only send builds worth flashing
(playbook 11b: measure first; state the decision rule before sending).
MERGED single-file images (esptool merge-bin, e.g. juno_s3_CLASSIC6.bin) flash
with ONE line instead -- paste it verbatim too:
  `python -m esptool --chip esp32s3 -p <PORT> write-flash 0x0 <image>.bin`

# WORKING STYLE
Simplest fix that holds; reuse proven tables/gates before new machinery. One
reversible commit per fix; not done until its gate is green. Proceed
autonomously on reversible work; stop for destructive or scope-changing calls.
THIS FILE holds rules and pointers ONLY. Findings go in docs/. A dated block
added here is a defect.
