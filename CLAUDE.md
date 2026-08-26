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

# LIVE STATE (2026-08-13 — update in place, no dated blocks here, EVER)
- COMPLETENESS AUDIT: the user counted 63 panel params in a host vs my 32 and
  was right. Census now 57 pools (probe_pools/juno_scope_probe). THREE REAL
  DEFECTS found and fixed, each invisible to a green gate: (1) JUNO EFFECT
  DEPTH 1..63 wrote a ramp where the plugin SATURATES -- no factory patch uses
  1..63; (2) JX unordered-compare -- the plugin CLAMPS on NaN (comiss;ja), the
  port did not, so the master emitted NaN; (3) JX cell 1088 -- LFO RATE H
  shares it with LFO RATE and RESETS it last, derived keep-clean. New binding
  rules in docs/PORT_COMPLETENESS_CHARTER.md; new gates census_exhaustive,
  fxsweep, nan_ab, mutation_gate, unordered_audit. NaN is reachable on JX
  (fixed) and NOT reachable on JUNO (latent, docs/NAN_SEMANTICS_SCOPE.md).
  Playbook 80 (self-scoping gate) and 81 (unordered compares).
- 12-bank user parity vs src/: recall 768/768 PASS. Render re-running after
  the arp-list fix; prior 111 fails are UNATTRIBUTED until it lands.
- Fork on silicon (2026-08-18, b6_split_sweep.md): CRC MATCH all patches (key
  regenerated). SPLIT 7 (shipping, KEEP IT): non-delay 5,112-5,389 UNDER 5,442,
  patches 5/16/21/49 6,526-6,821 OVER. wait=5 cyc PROVEN --> core 1 is the
  bottleneck, core 0 spins. SPLIT 8 (2 voices core 0, FX alone core 1): delay
  5,801-5,910, non-delay 5,735-5,881 -- buys 900 on delay, costs 600 elsewhere,
  compliant on NOTHING. Bound: core 0's 2-voice pass = 5,522-5,706 flat, i.e.
  ~2,805/voice, so 2 voices alone spend the budget. RINGS ARE NOT THE LEVER
  (moving-tap 30.0 cyc/tap vs scattered 229; b4_second_run attribution
  WITHDRAWN). Moving whole voices CANNOT close it; the balanced ideal
  (5,610+fx)/2 = 4,105/4,830 needs the MASTER CHAIN SPLIT ACROSS CORES, cost
  one block (5.8 ms) of latency. That is the next design step. Burst ~2.1 M,
  misses 1-4 blocks per patch step (C10 binding). ovr_late/drift timer anomaly
  still open (b4_first_run.md §5).
- O1 and O2 DONE and proven on silicon (b12). O2's cost: one chunked step adds
  189 us to its block, bounded; key audible in 2 blocks. O2's old acceptance
  rule was UNPASSABLE (playbook 64): an IDLE block runs 6,001 us against the
  5,804 us period, so miss=0 is unreachable for any subsystem. That +197 us is
  O4's real deficit and the whole remaining one.
- O3 BUILT, GATED AND COMPILED FOR THE TARGET; UNFLASHED. (ESP-IDF v6.2 IS
  here: `. /home/user/esp-idf/export.sh` then `idf.py build`. `which idf.py`
  without sourcing export.sh says nothing -- do not conclude from it.)
  A knob = write 2 record bytes, WARM recall, rebuild only its class. Median
  parameter moves 32 of 12,276 coef bytes; 2,036/2,040 warm==cold, the 4 that
  differ are latches that settle. eb_param_class.h is GENERATED and re-derived
  every run. 57 teeth green: sh tools/engineb/o3_gates.sh. Knob waits up to 48
  blocks behind a note storm -- a POLICY the user may overturn.
- O3 PROVEN ON SILICON over 52 min: 76,779 edits, unknown=0, pubretry=0,
  15.0x coalescing, applymax=302,245 cyc (b17).
- O4's LEVER DECIDED (b20): the ARITHMETIC in eb_delay_t5.c. Full-length MSPP
  windows only (n>=150k, no straddling): hot 4 windows delay 2,073-2,089, all
  patches 5/21/49; other 37 windows 657-1,012. NO non-type-5 above 1,500, NO
  type-5 below. Gap 1,012->2,073, ratio 2.53x. (Patch 16 never got a full
  window this run -- NOT claimed.)
  THREE RIVALS DEAD BY MEASUREMENT, each rule written before its run:
  * EB_ZEROCOEF on t5 -- 4 of 65 coefficients always zero vs a >=20 rule (host).
  * ring placement -- FOUR moving taps read 15.1 cyc/tap vs ONE at 29.8, so
    12 reads = 181 cyc = 15 % of the 1,231 excess vs a >=70 % rule. Four
    streams are CHEAPER per tap than one; b6's PSRAM withdrawal survives the
    four-stream case it was never tested on.
  * master-chain split -- 5.8 ms latency on all 64 to fix 4 (b19).
  STRUCTURAL: EB_ZEROCOEF is in 7 VOICE modules and NO delay module. The voice
  chain got the EXACTLY-0 treatment; the master chain never did.
  ⚠ Nothing absolute from an MSPROF build is a cost: 6 counter reads/sample sit
  inside it. sum is NOT fx. Ratios and the hot-set identity only.
- t5 CANNOT COME DOWN (b21). Its cost is the ALGORITHM, not the compilation:
  it writes 101 distinct persistent state fields per sample vs t23's 41 and
  t1's 33 -- 2.46x against the MEASURED 2.53x cost ratio. Bit-exactness forbids
  dropping any of them. restrict/aliasing tried both ways and REFUTED
  (992->992 struct member, 992->991 local, ld/st slightly worse); reverted.
- THE SPLIT IS RE-PRICED (b22): eb_master_render is a CLOSED PER-SAMPLE LOOP
  (effect(n) -> fb84672/fb84704 -> input(n+1), eb_master_in.c:28). A lockstep
  split parallelises nothing (the chain is serial inside one sample); a
  chunk-pipelined split delivers the feedback a CHUNK late -- NOT bit-exact,
  a SONIC change judged by the fork gate, on top of the 5.8 ms. b6 priced the
  latency and never the feedback. Today's S3L_FX_PIPE is legitimate because it
  moves the WHOLE chain, keeping the loop sample-deep inside.
- O6 STEP 2 PROVEN ON THE WIRE (2026-08-23): two boards linked, hs=OK,
  pattern lock (lock=YES), CRC-proven audio, mix=OPEN -- B's 3 voices reach
  the DAC. Five wire defects paid+gated (playbook 77/77b + lock_search_gate).
  Open: advert age-out flap (bad= counts) to quantify. Bench is REMOTE:
  tools/bench/bench_agent.py flashes both boards on push and returns logs
  via commit messages -- no human needed at the bench. D3 FIXED AND WIRED END TO END: juno_apply_*_at
  (base = global voice of local slot 0), EB_DEVSEQ_VOICE_BASE set from the
  strap BEFORE the boot recall, and the devcrc ANSWER KEY EXISTS PER BASE
  (base-0 tables byte-identical; generator refuses if base 3 fails to move the
  key -- seen to fail). D4 role-by-strap (GPIO 4; unstrapped = chip A = today's
  board). D1/D2 gated as LOGIC: direction table (every wire exactly one
  driver; A is link MASTER and RECEIVER), UART2 handshake (role, patch,
  coefficient CRC, voice-range disjointness -- all six rejections toothed).
  Gates: sh tools/engineb/o6_gates.sh. Wiring: docs/engineb/TWO_CHIP_WIRING.md
  (6 wires + ground + 1 jumper; both boards get the SAME image). UNPROVEN
  until wired: pins, peripherals, UART. Patch-follow + audio link = step 2,
  deliberately deferred to the bench that can exercise them.
- E3/E4 DONE AS WRITTEN: docs/PIPELINE.md (9 phases, every cited path exists);
  tools/verify/dejuno_audit.py CLEAN with the 16 owed constants printed.
  PROVEN only when the JX-3P traverses it (E5).
- O4 3-VOICE VERDICT RETRACTED AS UNATTRIBUTED (2026-08-23, playbook 78):
  the "3-voice" build was the F4 harness (rm -rf build dropped S3_LISTEN;
  the DEVCHORD compile-time net proves a real 3-voice listen build could not
  even have compiled -- the chord-3 answer key did not exist). Every number
  recorded for it came from a frozen capture of the 2-VOICE probe build.
  What IS measured at 2 voices: quiet 6.3-7.07 ms vs the 5.804 ms period
  with un=0 -- and un= is BLIND (50 ms timeouts only); B5 (DMA on_sent
  descriptor counter, the non-blind starvation meter) is in the new build.
  NOW IN FLIGHT: the FIRST real 3-voice listen build (chord-3 key
  regenerated, [LISTENv3] provenance tag on every report line). The full
  canonical reconfigure line lives in esp32s3/LISTEN.md.

# BUILD & GIT
`make libjuno.so` | `make test` | `make verify` (finish line) | WASM:
`gui/web/build.sh` + `wasm_golden.mjs`. `-ffp-contract=off` is load-bearing.
Branch: push -u origin <current claude/* branch>; retry 2s/4s/8s/16s; no PRs
unless asked. Trailer verbatim:
`Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>`
`Claude-Session: https://claude.ai/code/session_019dkoF3tvNYDygVXy9RBXJb`
FLASHING -- PASTE THE COMMANDS EVERY SINGLE TIME A .bin IS SENT. Never say
"same command as before" and never make the user scroll back. Verbatim, both
lines, in this order, with the delete reminder first:
  1. "Delete the old juno_s3.bin from Downloads first" (Windows renames a
     duplicate to `juno_s3 (1).bin` and the flash then fails on the old file).
  2. `python -m esptool --chip esp32s3 -b 460800 --before default-reset
     --after hard-reset write-flash --flash-mode dio --flash-size 8MB
     --flash-freq 80m 0x0 bootloader.bin 0x8000 partitiontable.bin
     0x10000 juno_s3.bin`
  3. `python -m serial.tools.miniterm COM5 115200`
The three-bin set lives in `esp32s3/flash/meas/` -- partitiontable.bin has NO
hyphen. Send builds from THERE, never from `esp32s3/build/`, whose paths and
names do not match what the user has. Only send builds worth flashing
(playbook 11b: measure first; state the decision rule before sending).

# WORKING STYLE
Simplest fix that holds; reuse proven tables/gates before new machinery. One
reversible commit per fix; not done until its gate is green. Proceed
autonomously on reversible work; stop for destructive or scope-changing calls.
THIS FILE holds rules and pointers ONLY. Findings go in docs/. A dated block
added here is a defect.
