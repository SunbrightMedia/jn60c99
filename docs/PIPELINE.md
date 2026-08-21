# THE PIPELINE — .vst3 in → two ESP32-S3 boards out (E3, END_GOAL item 7)

This is the document the next synth starts from. Every phase names its tools,
its gate, and the defect class the gate exists to catch. The JUNO-60 port is
the worked example; the METHOD is the deliverable. Where a tool still carries
a JUNO constant, `python3 tools/verify/dejuno_audit.py` prints it — that list
is the parameterisation owed before phase 0 of the JX-3P.

The one rule everything serves: **the original .vst3 is the only ground
truth.** Never validate by ear. Every constant is proven against the plugin's
own machine code executed under an emulator. "Done" = the gates are green.

The mantras, in order: REWRITE bit-exact → CONFIRM in every circumstance →
OPTIMIZE only what is proven → LEAVE A LEGACY as you go.

---

## Phase 0 — Freeze the truth

**In:** the .vst3 binary. **Out:** a checksummed `truth/` directory.

* Copy the plugin binary and its factory bank into `truth/`. Checksum them.
* All path resolution goes through `tools/verify/truth.py` — no tool ever
  hardcodes a path to the truth (and the de-JUNO audit enforces it).
* Start `PROVENANCE.tsv` empty. Every constant that enters the port gets a row:
  PROVEN(executed) / READ(static) / INFERRED. CAPTURED = forbidden.

**Gate:** checksums verified by `make verify` on every run, forever.
**Defect class:** silently drifting reference material (playbook: a number
quoted N times is not thereby measured).

⚠ **The diagnostic-capture covenant, from day one.** DAW bounces and runtime
captures may LOCATE divergence; they may never be a source of constants or a
gate reference. A capture-derived constant is a bug by definition.

## Phase 1 — Static extraction

**In:** the binary. **Out:** decompiled DSP source, tables, parameter metadata.

* `tools/extract_dsp.py`, `extract_tables.py`, `extract_init.py`,
  `extract_param_meta.py`, `extract_param_setter.py`, `extract_everything_static.py`
  — pull the render functions, coefficient tables and parameter plumbing out of
  the binary as annotated decompile text.

**Gate:** none yet — extraction output is INFERRED until phase 2 executes it.
**Defect class:** believing a decompile. Do not. Label everything.

## Phase 2 — The oracle: execute the plugin's own code

**In:** the binary + a harness. **Out:** PROVEN constants and reference audio.

* `tools/verify/e2e_emu.py` runs the plugin's machine code under Unicorn:
  recall a patch, render blocks, dump the full state. This is the oracle every
  later phase nulls against.
* `tools/oracle/derive_coeffs.py` and the per-subsystem probes derive each
  recall constant BY EXECUTION and write its PROVENANCE row.
* **Two-process rule:** never load the port library and a Unicorn instance in
  one Python process. They meet only through pickles.

**Gate:** `make verify` — zero non-PROVEN rows in `PROVENANCE.tsv`; the
approximation audit (`tools/verify/approx_audit.py`) enforces ZERO
approximations in `src/`.
**Defect class:** a plausible constant that was never executed.

## Phase 3 — Transcribe the DSP, mechanically

**In:** decompiled render code. **Out:** `src/` — the frozen bit-exact port.

* `tools/translate_voice.py`, `translate_master.py`, `translate_init.py`,
  `translate_chorus_init.py` rewrite flat-state accesses into C mechanically.
  Hand transcription of 400-line arms is a typo farm; the transformers refuse
  to emit while any access is unclassified.
* `-ffp-contract=off` everywhere, forever. It is load-bearing: one fused
  multiply-add changes the null from EXACTLY 0 to "close".

**Gate:** the null — port output minus oracle output must be EXACTLY 0, all
patches, all block sizes. Not small: zero.
**Defect class:** the two ways transformers lie (arm_xform.py's header lists
both: multi-line accesses missed by line regexes; output that compiles and is
wrong). Check the output, never trust the tool.

## Phase 4 — Recall: patches from bytes, not blobs

**In:** the factory bank format. **Out:** derived recall in `src/`, gated.

* Decode the bank (`tools/decode_bank.py`); derive every parameter→cell
  binding by perturb-and-diff on the oracle, never by reading the decompile
  alone. `tools/verify/param_cell_map.py`, `param_exhaust.py` are the pattern.
* Exhaustive value sweeps, not sampled: this port found a parameter live at
  exactly 1 value of 256 (ASSIGN MODE). Sampling would have missed it, and did.
* Per-synth data properties (which patches use an arp, delay types…) are
  DERIVED per bank at gate time, never hardcoded (playbook: the arp-list fix).

**Gate:** recall gate + render A/B (`tools/verify/recall_gate.py`,
`recall_render_ab.py`, `userbank_parity.py` for user banks as INPUT only).
**Defect class:** a binding derived from one patch that another patch refutes.

## Phase 5 — Fork for the target (engine B)

**In:** frozen `src/`. **Out:** `engine_b/` — restructured for the chip.

* Restructure, don't rewrite: hoist per-sample parameter reads into
  coefficient builds (`eb_coefs`, `eb_master_coefs`). This hoist is the entire
  speed advantage over the plugin's structure — and the reason a patch change
  costs a burst. Both follow; accept both.
* Dispatch arms are transformed by `tools/engineb/arm_xform.py`, cell
  classifications by `gen_fork_tab.py` / `gen_devcells.py`.
* The trunk NEVER approximates. Target-specific approximations live behind
  flags and face a sonic gate; the trunk's gate is EXACTLY 0.

**Gate:** `make engineb` via `tools/engineb/null_b.py` — fork vs port null
EXACTLY 0, all 64 patches, every module. Standalone-link test: no fork module
may quietly depend on `src/`.
**Defect class:** "conceptually identical" restructuring that moves one sample.

## Phase 6 — Cost, measured on silicon

**In:** the fork. **Out:** a budget verdict per patch, measured not modeled.

* Budget = cycles/sample at the target clock (5,442 at 240 MHz / 44.1 kHz).
* Measure ON THE BOARD with CCOUNT. Emulator instruction counts size RATIOS
  only. Profilers: verify the instrument in the artifact that ships (objdump
  the ELF; playbooks 69–73 are all instruments that didn't reach their subject).
* The three facts that must not be re-litigated: one chip cannot do it; the
  split matters more than any lever; bursts, not averages, cause stuttering.
* Every lever gets a decision rule WRITTEN BEFORE its measurement (this port's
  O4: four rivals eliminated that way, none adjusted after).

**Gate:** the health line — miss rates per class, `NOTE MUST NOT EXCEED QUIET`;
worst-case patch under budget, not the average.
**Defect class:** optimizing the unproven; quoting a profiled build's absolute
numbers; a budget for work that cannot fit (playbook 63).

## Phase 7 — An instrument, not a render engine

**In:** a fast engine. **Out:** notes, patch changes, knobs — in real time.

The invariant: **audio never breaks, for any input; changes may land late.**

* O1 — one event boundary (`event/juno_event.h`, synth-agnostic by audit).
  Inside the box nothing speaks MIDI.
* O2 — chunk the recall burst behind a shadow/publish contract: `step()`
  returns 0 to ASK, advances only on `published()`. Three state machines
  (note / patch burst / parameter) share one shadow; the interlock is gated
  as a model (`tools/engineb/devboot/interlock_gate.c`) AND played by a robot
  on the board (playbook 63: parts being right never says the instrument works).
* O3 — knobs: a parameter edit rebuilds only its class
  (`eb_param_class.h`, GENERATED per synth by perturb-and-diff — an item-7
  tool). Warm recall == cold recall, gated both ways.
* Device recall CRCs against a host answer key generated by the same source
  through the same addressing — chip arithmetic vs host arithmetic, the one
  question no host gate answers.

**Gates:** `tools/engineb/o2_gates.sh` (44 teeth), `o3_gates.sh` (57 teeth).
**Defect class:** a knob with no source on the device (playbook 67 — gate the
whole signal path, not the machinery); an acceptance rule that is unpassable
(playbook 64).

## Phase 8 — Two chips, one instrument (O6)

**In:** one board working. **Out:** six voices across two boards.

* D1: ONE DAC, chip A the only clock; B is an I2S slave that transmits. Drift
  impossible by construction. `esp32s3/main/s3_link.h`.
* D2: control UART handshake — role, patch, **coefficient CRC** (same index +
  different coefficients is the silent killer), voice-range disjointness.
* D3: per-voice-distinct tables take a GLOBAL voice base
  (`juno_apply_*_at`); otherwise both chips deal the same analog scatter —
  silent, CRC-clean, audible only as a narrow chord.
* D4: one image flashed twice, role by strap pin; unstrapped = today's
  single board, unchanged. All decisions are pure functions, gated on the host
  BEFORE first silicon (`tools/engineb/o6_gates.sh`).
* Bring-up is staged: UART first (proves ground/pins/roles cheap), audio link
  second. A first flash must diagnose itself.

**Gate:** `o6_gates.sh` + the on-device handshake verdicts.
**Defect class:** logic whose first execution is on hardware; silent
self-consistent wrongness (the D3 species).

## Phase 9 — Prove, then repeat

* F1: full-state stress gate; F2: user acceptance (the user plays it — the
  only ear-step, and it is acceptance, not validation).
* E: keep `docs/engineb/METHOD_PLAYBOOK.md` current THE DAY a defect is paid
  for; run `dejuno_audit.py`; then E5 — this document is only PROVEN when a
  second synth has traversed it.

---

## The working rules that made every phase survivable

1. Every detector must be SEEN TO FAIL before it is believed.
2. FREEZE the tree while any gate runs — and never `git add -A` during one:
   tooth-planting gates edit the tree themselves (playbook 74).
3. Verify the artifact, not the report: exit codes lie (73), macros don't
   cross translation units (72), host builds prove host arms only (70).
4. Write the decision rule before the measurement; never adjust it after.
5. One reversible commit per fix; not done until its gate is green.
6. Findings go in dated `docs/**/data/` files; state lives in ONE live-state
   block updated in place. A dated block in the rules file is a defect.
