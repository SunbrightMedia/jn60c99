> **ARCHIVED 2026-09-02 (phase-3 triage).** Executed to completion (2026-07). Successor for live status: FINAL_GUIDE.md + CLAUDE.md.

# FINAL SCOPE — the last scope. Opus: follow this to the letter, in order.

**User contract (binding):** this is the terminal scope. It does not spawn a new
"macro solution." Either the Exit Test passes and the project is DONE, or it
fails at a named step and we report the exact ceiling — no new theories, no
patch-by-patch chase, no fifth reframing. The reason every prior fix "shifted"
is that every gate fed the plugin the SAME values it fed the port, so any error
in value COMPUTATION was invisible. This scope removes that shared input once and
for all by running the plugin through its REAL host path and diffing audio.

**Covenant (unchanged, absolute):** the DAW captures in `scratchpad/diag_bounces/`
and `lastcatpureEVER.wav` are LOCATE-ONLY. No number from any capture may enter
the port, a gate reference, or the ledger. Ground truth = the plugin's machine
code executed under Unicorn. Two-process rule holds. Label PROVEN/READ/INFERRED.

**One reversible commit per step. Do not proceed to step N+1 until step N's
"DONE WHEN" is literally true. If a step is blocked, STOP and write the blocker
in `docs/FINAL_SCOPE_LOG.md` — do not invent an alternative path.**

---

## The whole plan in one line

Construct the plugin's processor under emulation → load preset 3 via its own
host preset path → render one note → diff vs the port → every differing cell is a
real bug; fix each by executing the plugin's own code that wrote it; freeze the
whole thing as the new gate; ship.

---

## STEP 0 — Baseline, no code changes
- `make verify` must be GREEN before touching anything. If red, STOP and log.
- Record HEAD sha in `docs/FINAL_SCOPE_LOG.md`.
- **DONE WHEN:** `make verify` exits 0 and the log has the sha.

## STEP 1 — Get the PROCESSOR to construct under emulation (unblocks everything)
Context already proven this session: the CONTROLLER (`createInstance 0x3473D0`)
constructs AND `initialize` returns kResultOk under emulation. The PROCESSOR
(`createInstance` returns the IAudioProcessor at class+272) faults in
`IComponent::initialize` inside a Windows-CRT config parse:
`0x3E49B0→0x3E4930 (magic static) →0x3E1330→0x3E16A0 (GT::CIniProfile
"BufferObject/Value" parse) → _invalid_parameter_noinfo_noreturn (0x6bc19c) →
int3 at 0x284c04`. This is CRT/TEB plumbing, NOT plugin DSP logic — stubbing it
is covenant-clean (same class as the existing HeapAlloc/Tls stubs in e2e_emu.py).

- In `tools/verify/e2e_emu.py`, add a stub so the magic-static thread-guard /
  `_invalid_parameter` path returns benignly instead of int3'ing. Prior harnesses:
  `scratchpad/p112_lifecycle2.py`, `p112_initdiag2.py`, `p112_ipdiag.py` already
  locate the exact call stack — reuse them.
- The INI profile it's parsing is a model-config string; if it needs a value,
  read what the plugin's own code expects (READ) — do NOT fabricate audio params.
- **DONE WHEN:** a scratchpad harness constructs the processor, calls
  `setupProcessing(44100)` and `setActive(true)`, and 9/9 engine units report
  `state != 0` and `proc vtable == PROC_VPTR` (the check already written at the
  end of `p112_lifecycle2.py`). Log the unit table.

## STEP 2 — Load preset 3 through the plugin's OWN host preset path
- Controller: `setComponentState` (slot 5, rva 0x347f20) OR the component's
  `IComponent::setState` (rva 0x34aaa0). Feed it the preset-3 blob the plugin's
  own bank parser produces (`tools/verify/real_bank_parse.py` already yields it).
- Flush controller→processor param sync the way the connect path does
  (0x320420 / the queue consumer 0x320B20 called directly — NOT via the thread
  pool; kill any run that spins >5 min in the pool wait loop).
- **DONE WHEN:** after the load, the processor's engine state cells for a KNOWN
  leaf (e.g. VCF CUTOFF cell 6736 on unit 0) are non-default and finite. Log 10
  sample cells.

## STEP 3 — The Exit Test oracle: render one note through the real host path
- With the processor loaded (STEP 2), send note-on(60,100) as a real VST3 event
  through `process()` (rva 0x34A380 — proven this session to run the event→MIDI→
  queue intake ON the calling thread; the pool is only under DSP render, which
  `e2e_emu.render()` already replaces). Render 2 s at 44100.
- This is a NEW oracle: `tools/verify/hostpath_render_ab.py`, two-process.
  `--ref` = this real-host render (Unicorn only). `--port` = libjuno
  `juno_gui_midi_note_on` path (ctypes only). Compare.
- **DONE WHEN:** `hostpath_render_ab.py --ref` produces a finite 2 s render for
  preset 3 and saves the pickle. (Do NOT require a match yet.)

## STEP 4 — Diff, and fix every divergence by executing the plugin's own code
- Run `--port`. If BIT-EXACT: jump to STEP 6 (the port was already right; the
  audible complaint was delivery, and STEP 5's gate locks it).
- If it diverges (expected — this is the whole point): for EACH divergent
  cell/region, find the plugin function that wrote it on the REAL path (the
  controller decode, the host param entry 0x3C7AE0 transform table, or the
  note-on→VCF-CV computation), execute it under Unicorn, READ the law, port it,
  re-dispatch. The BS Solid symptom (sustained VCF 7–21 dB dark above 700 Hz,
  see BSSOLID_DIAGNOSIS.md Round 4) MUST be one of the cells that shows up here;
  if it does not, the diff harness is wrong — STOP and log.
- **DONE WHEN:** `hostpath_render_ab.py` is BIT-EXACT (or within the documented
  ~1-ULP warm class) for preset 3, mono AND poly.

## STEP 5 — Generalize + FREEZE as the permanent gate (this is what stops the recurrence)
- Extend `hostpath_render_ab.py` to all 57 non-arp factory presets + the
  Chillwave bank's non-arp presets. Fix any new divergences the same way (STEP 4).
- Add `hostpath_render_ab.py` to `make verify` as a REQUIRED gate. From now on,
  "green" means "matches the plugin driven the way a DAW drives it," not "matches
  our own recall." Update CLAUDE.md's definition of done to point at this gate.
- **DONE WHEN:** `make verify` includes the host-path gate and is GREEN across all
  tested presets, AND `PROVENANCE.tsv` has zero non-PROVEN rows.

## STEP 6 — Ship
- `bash gui/web/build.sh` (emsdk at `scratchpad/emsdk`), then
  `node tools/verify/wasm_golden.mjs` = 8/8 bit-exact.
- Re-bundle: `python3 tools/verify/bundle_webapp.py --extra-bank
  "Chillwave=/root/.claude/uploads/89f5fa0d-6fc0-55d6-a056-fe6fb14fdde6/0e8b9cb5-Chillwave.bin"`
- `node tools/verify/verify_webapp.mjs` passes.
- Republish artifact to the SAME url
  (https://claude.ai/code/artifact/4c5a4e67-86ed-43e5-871c-695aa6275ac7),
  commit, push branch `claude/c99-gui-fable5-yfhak1`.
- **DONE WHEN:** artifact republished, branch pushed, `make verify` green.

---

## THE EXIT TEST (the definition of finished — no ambiguity)
The project is DONE when BOTH hold:
1. `make verify` is GREEN and INCLUDES the host-path render gate (STEP 5).
2. `hostpath_render_ab.py` is bit-exact (≤1-ULP warm class) on preset 3 (BS Solid)
   AND the full factory set, driven through the plugin's real host path.

If STEP 1 or STEP 2 proves genuinely impossible under emulation after an honest
attempt, that is the ONE acceptable failure exit: write in FINAL_SCOPE_LOG.md
exactly which plugin instruction cannot be emulated and why, and state plainly
that byte-exact host-path verification is not achievable in this environment —
that is a real, final answer, not a new scope. Do not substitute another plan.

## Hard DON'Ts (these caused the thrash)
- DON'T diagnose by ear or tune to a capture. Ever.
- DON'T add per-patch special cases. Fix the LAW, once, from the binary.
- DON'T declare "bit-exact ⇒ done" using any gate that feeds both sides the same
  values. Only the host-path gate counts now.
- DON'T open a new investigation thread if a step blocks. STOP and log.
