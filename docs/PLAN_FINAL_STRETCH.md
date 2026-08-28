# THE FINAL STRETCH — EXECUTION PLAN (binding, 2026-08-28)

THE GOAL (the user's words, verbatim intent): **6 voices, WITH FX, at 44.1 kHz,
under 10 ms key-to-sound latency, NO pops/clicks/stutters, audibly
imperceivable to the plugin, on 2 ESP32-S3 chips.** No excuses. This plan is
the route. Execute top to bottom. Every step has a gate; a step is DONE only
when its gate is green. The bench is REMOTE (tools/bench/bench_agent.py flashes
on push, logs come back in commit messages) — no human needed to measure.

THE ARITHMETIC THIS PLAN LIVES ON (all measured, chip B, 3 voices + FX):
- budget 5,442 cyc/sample; worst patches today 5,981–6,040 → gap 539–598.
- levers in hand: PROLOGUE-C1 (180–480) + lfotail (40–150) + wrap-dco (4–13)
  on the critical core = **224–643**; lfotail+setpitch ALREADY LANDED bit-exact.
- Target is PARITY AT WORST CASE, not a % margin. Control work (MIDI, knobs,
  recall) runs BOUNDED in core-0 slack — it never rides the audio budget.

## STEP 1 — PROLOGUE-C1 (the big lever). Build it.
Move `eb_engine_render_shared` (prologue+LFO, ~717 cyc, engine_b/eb_render.c:72-174)
off core 0's per-sample loop onto core 1, one chunk ahead, like the FX pipe.
- Delete core 0's per-sample prologue call + `w_ready` store/spin
  (esp32s3/main/juno_s3_listen.c:2654-2657).
- Add a batch loop in `worker()` (juno_s3_listen.c:2398-2525): compute all n
  prologues for chunk C+1 into a SECOND `w_shb` bank (double-buffer at
  juno_s3_listen.c:2124; +5,120 B internal at CHUNK=128). Sync once per chunk
  at the existing `w_go/w_done` barrier.
- Consume path already exists (`render_range` with `sh!=NULL`,
  eb_render.c:449-456, 587-593).
- Flag: `-DS3L_PROLOGUE_C1=1`. Off = today's build, byte-identical.
HOST GATES (before any flash): forkbit bit-identical over the scenario battery
with EB_SPLIT_TEST=7; a PROLOGUE_STATEWRITE_BY_VOICE counter that MUST read 0
and MUST be seen to fail; sonic_gate at a patch-recall boundary (the LFO lands
one chunk late there — the one non-exact edge; bound: existing gate limits).

## STEP 2 — wrap-dco micro-lever (fold in, same sitting).
Swap `eb_lfo_wrap`'s body (engine_b/eb_lfo.c:72-81) to the `eb_dco_wrap` form
(eb_dco.h:299-313). Bit-identical over all 2^32 inputs (test_dco_wrap.c green).
GATE: fork-vs-fork LFO bit A/B = 0.

## STEP 3 — bound EVERY control burst (no-clicks, forever).
The machines exist (eb_notestep.h, eb_burststep.h, proven O2/O3). Finish:
- Cap per-block burst work so worst block = render + bounded slice ≤ period.
  The slice budget comes from core-0 slack AFTER Step 1 (measure, then set).
- MIDI parse + knob writes: already chunked (b17: 76,779 edits, unknown=0).
- Program change: spread stays; the 6-deep buffer is what hid its misses —
  after this step it must miss ZERO blocks. Counter: `BSTMISS=<n>`, must be 0
  on a patch-step soak, and must be SEEN non-zero with the cap removed.

## STEP 4 — shrink the pipeline (the latency step).
Only after Step 3's counter is 0:
- `CHUNK 256 → 128` (2.9 ms/block; 128 % 4 == 0 keeps every CR split legal).
- `dma_desc_num 6 → 2` (juno_s3_listen.c:3246).
- Keep S3L_FX_PIPE (one chunk). PROLOGUE-C1 adds NO user latency (it computes
  ahead, same output samples).
Budget: MIDI ~1 ms + block wait 0–2.9 + FX pipe 2.9 + DMA 2×128 ≈ 5.8
→ **~9.6 ms worst, ~8.2 ms typical.** UNDER 10.

## STEP 5 — ONE flash, the verdict flash.
Build the LISTEN.md line + `-DS3L_PROLOGUE_C1=1` + Step-4 constants, with
S3L_TIME_PROLOGUE=1 and the counters. Push; the bench flashes and returns:
1. `WHOLELOOP p0/p50` — worst patch ≤ 5,442-equivalent at CHUNK=128. GATE.
2. `LFOTAIL=0`, `BSTMISS=0`, `un=0`, B5 starvation counter 0 over a 10-min
   soak with patch steps + MIDI storm. GATE (this IS "no pops", measured).
3. GPIO latency mark: set a pin high at MIDI note-parse, low at the DMA
   write of the block carrying that note's first sample; bench logs the delta.
   Add DMA depth (2 blocks) analytically. Must read < 10 ms. GATE.

## STEP 6 — if Step 5's gate 1 is short (the no-excuses branch).
The gap after Steps 1–2 is bounded (≤ ~374 cyc pessimistic). Grind it closed,
in this order, all EXACTLY-0: (a) seedcopy with its new recall-mid-note
scenario (25–60); (b) the exactly0-audit list (nsvf/vcf_res dead stores,
wrap-swap 25); (c) per-module CCOUNT attribution on the worst patch, then cut
the top hot spot found. Repeat Step 5. Do NOT touch: sample rate, voice count,
FX, chip count, bit-exactness of the trunk.

## STEP 7 — prove the whole goal, then stop.
- 6 voices across 2 chips: the link is proven (mix=OPEN); run the full 6-voice
  two-board soak with the Step-5 counters on BOTH boards.
- F1 stress gate green; F2: send the user long stereo A/B renders (ladder3,
  1-based patch names) for the final ear check.
- Write the numbers into FINAL_GUIDE.md. Done = every gate above green.

RULES THAT DO NOT BEND: trunk stays bit-exact (null EXACTLY 0). Every lever
host-proven before flashing. Every counter seen to fail before believed.
Long jobs via tools/run_job.sh. No model IDs in pushed artifacts.
