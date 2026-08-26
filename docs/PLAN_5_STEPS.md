# THE 5-STEP PLAN TO THE END GOAL (written 2026-08-26, user-approved scope)

Binding scope contract: work that advances none of these five steps is scope
creep and is not done. Each step has a DONE test that a tool prints, not an
opinion. Execute in order; a step is not started until the one before it has
its DONE line, except where marked PARALLEL.

## STEP 1 — Land the outstanding proof runs (machine-hours, not hand work)
- `jx_full` (64 patches x 3 rates, N=64) to a green EXIT file.
- The 5 mutation-survivor confirmations under full `make verify`
  (delay_const, ramp_const, arp_const, apply_const, note_const); every
  confirmed survivor gets a gate written for it, or a written acceptance.
- Report ONLY from `bench/jobs/*/EXIT`. All long runs via `tools/run_job.sh`.
DONE = `sh tools/run_job.sh --list` shows FINISHED ok for both, and
SCOPE_AUDIT rows they cover updated with the evidence.

## STEP 2 — Make the JX port stand alone (the real remaining hand work)
Three pieces, each transcribed from the binary, each with a gate SEEN TO FAIL
before it is believed (charter rules 2/3):
- note allocator (the plugin's note-on/off voice assignment),
- cold init/prepare in C (SCOPE_AUDIT row 8: cold state must EXIST),
- ramp walker `sub_1803F40E0` (the stepper `jx_ramp.c` is done; the
  pointer-list container is not) — closes SCOPE_AUDIT row 2.
DONE = an A/B that starts from NOTHING (no oracle seed), plays notes, and
nulls EXACTLY 0 against the plugin doing the same.

## STEP 3 — The JX webapp, built the SAME way as the JUNO one
Purpose (user's words): sanity-check the work by ear BEFORE the S3 effort.
Reuse `gui/web/build.sh` + the JUNO wasm harness shape; JX parameters and
banks. No new machinery where the JUNO shape fits.
DONE = the page plays all 64 factory patches with every census parameter
live, and `wasm_golden` nulls the wasm against the native build.

## STEP 4 — Back to the S3 (Track order per FINAL_GUIDE.md)
The JX work paused Track B/C at a known state; resume it, do not restart it:
- flash and measure the O3 build already compiled (UNFLASHED);
- land the first REAL 3-voice listen build ([LISTENv3], B5 meter);
- O4's decided lever: the t5 arithmetic on core 1 vs the +197 us deficit;
- O6 step 2 open items (advert age-out flap).
DONE = health line per FINAL_GUIDE rules; six voices across two chips
remains the target, no third chip, no dropped FX (END_GOAL invariants).

## STEP 5 — E5: prove REPEATABILITY by traversal (mantra 4)
The JX-3P traverses the whole documented pipeline (`docs/PIPELINE.md`, 9
phases) end to end. Every gap found on the way is fixed in the PIPELINE
DOC, not in a one-off script, so synth #3 inherits it. Measure the
wall-clock of each phase and record it in the doc.
DONE = `tools/verify/dejuno_audit.py` CLEAN + every PIPELINE phase has a
JX artifact and a measured duration. This closes END_GOAL item 7.

## Standing rules while executing (no exceptions)
- Long jobs ONLY via `tools/run_job.sh`; report only from EXIT files.
- Every new gate is seen to fail before it is believed.
- Charter (`docs/PORT_COMPLETENESS_CHARTER.md`) applies to every step.
- Findings go in docs/; status goes in FINAL_GUIDE.md health lines.
