**Adhere to and only respond in ASD-STE100 Simplified Technical English.**

# JUNO-60 (JU-06A) C99 port — project memory

**⚑⚑⚑ LIVE WORK ORDER (2026-08-04, USER-BINDING, supersedes all prior engine B
sequencing): `docs/engineb/PHASE1_ORDERS.md`.** The user has decided the
strategy: **the TRUNK is the full EXACT engine B — the splitting point for
every microcontroller (and future project-ssx synths); targets are FORKS by
build flags.** **Phase 1 is COMPLETE and CERTIFIED (2026-08-05, block below).** Phase 1 was:
step 2 (coef constructor + the standalone engine gate) DONE; C5 fusion CLOSED
NEGATIVE by measurement (`data/c5_fusion.md`); the METHOD PLAYBOOK written
(`METHOD_PLAYBOOK.md`, 27-entry defect catalogue); certification sweep GREEN.
**Phase 2 numeric design (F3) is DONE (2026-08-05, Fable 5) — read
`docs/engineb/F3_S3_FORK_DESIGN.md`. The sentence first: with both fork
evaluators and 6 voices @48 kHz the fork prices at ~27,300 instr/sample =
STILL 2.9-4.3x OVER; reserves reach ~21,550 = 2.1-3.2x. Silicon (F4) decides.
What passed, both EXHAUSTIVE over all 2^32 float inputs: fork PITCH
(recentered rows, exact-rational coefficient transform, worst 0.00074 cents
vs the 0.05 bound, 67x margin; the first run FAILED on the signaling-NaN
payload class, which no sweep can visit) and fork EXP (0.119 ppm vs 2 ppm,
tails bit-identical). What died: C4 16-bit SIMD on EVERY recursive module —
Q15 lanes measure +3.9 dB worst-block on the resonant ladder (error as loud
as the signal; `data/c4_ladder_probe.c`), and even scalar Q28 sits AT −80
with no margin; only feed-forward spans survive. **O6 IS DONE (2026-08-05, Opus 5) — F3_S3_FORK_DESIGN §6 holds the results.
MEASURED fork price 28,626 instr/sample at 6 voices = 3.0-4.5x over (the
estimate was 25,850). C4 IS NOW CLOSED ENTIRELY: feed-forward was kept alive
on the reasoning that a FIR does not recycle error -- true and irrelevant,
since Q15 measures -33.7 dB worst-block on the decimator and even Q20 fails;
"no feedback" answers ACCUMULATION, not RESOLUTION. THE LFO-RATE GATE EARNED
ITSELF: a cancelling expression amplifies expf's 0.119 ppm 9x to 1.108 ppm
before the phase accumulator. THE `exp` AUDIO NULL IS NEARLY VACUOUS and now
says so -- EXACTLY 0, but a tap found only FOUR distinct arguments at the LFO
site across 2,016,000 calls, so correctness rests on the exhaustive gates and
not on that null. GLOBAL-LFO PRECONDITION VERIFIED: LFO phase is identical in
all 8 voices across all 64 patches with staggered notes AND with LFO TRIG ENV
forced on -- ~4,100 instr/sample, the largest lever left, pending only
silicon need. THE SHARED LFO IS PROVEN EXACTLY 0 (same night, Fable 5): one LFO broadcast
to all voices nulls EXACTLY 0 on all 36 scenarios at BOTH rates against the
trunk oracle -- the per-voice LFOs are redundant computation, the hardware
fact showing through the plugin's own any-key-held broadcast. Preconditions
were forced first: LFO TRIG ENV on AND LFO DELAY TIME at max, 0 of 64
divergent. EB_LFO_SHARED stays default OFF (charter: silicon need is F4's;
trunk promotion is the USER's call -- the proof meets the trunk's standard).
Fork price with it: 24,686 = 2.6-3.9x over; ~20,400 with reserves. **F4 FIRST SILICON IS IN (2026-08-05, the user's own S3): c/i = 0.95.**
38,209 cycles/sample vs QEMU's 40,275 instructions for the IDENTICAL program
-- the Daisy pattern did NOT repeat; instruction counts ARE cycle counts on
this chip (within 5 %). Evaluator vectors BIT-EXACT on silicon; all fourteen
region sinks BIT-IDENTICAL to host/QEMU (the S3's FPU reproduces the host's
floats exactly); FX states ran FROM PSRAM, memory test OK. Full fork = ~23,400
cycles vs ~10,000 two-core = 2.3x over, and the ladder down is measured:
half-OS 1.9x, +C2 1.4x, +44.1k-or-4-voices AT/NEAR FIT. The S3 is ALIVE.
`esp32s3/flash/` holds the flash kit. **C2 IS CLOSED NEGATIVE (O7, same night) -- read `data/c2_result.md`. The
premise was wrong three ways: glide/pwm_cv carry PITCH (bias law forbids
them, so the prize was ~2,800 not ~5,500); vcf_res and vcf_cv both move ~100 %
PER SAMPLE (measured over 4.75M calls) because they carry the wrap24 DITHER,
and a stochastic term cannot be approximated -- holding and interpolating
both REMOVE it; and vcf_cv's smoother state update IS its computation. Gate:
N=1 EXACTLY 0 (identity, which is what makes the next row mean something),
N=2 FAILS at -39.3 dB on all 36 -- 60 dB above the gate. FOURTH modelled
lever killed by measurement (C1 integration, C4 resolution, C5 registers, C2
stochastic content). CONSEQUENCE, stated: 6 voices @44.1k is ~1.55x over
after both (still ungated) half-oversampling levers; 4 voices reaches ~1.1x.
The head pointer is F5 (half-oversampling design) with the voice-count
decision now a real one.** NO approximations in the trunk —
C2 moved OUT of trunk work (it is a −100 dB candidate, my earlier phase
assignment was wrong). Phase 2 (Fable, S3 fork): recentered pitch with a
0.05-CENT exhaustive gate (the plugin's own numerical noise bound, ~1000×
below its own 18.2-cent UNISON scatter — `data/pitch_cents_study.md`;
NAIVE float is measured DEAD: up to 2.7 OCTAVES wrong), LFO-rate ppm gate,
C4 fixed-point+SIMD, 6 voices @48 kHz as build constants; global-LFO only if
the hardware fact is verified AND silicon still needs it; reserve dials:
44.1 kHz, half-oversampling. Phase 3: Teensy fork, full standard. **The S3
verdict that forced this: full-standard 8-voice S3 is IMPOSSIBLE (pitch alone
= 2–3 budgets, irreducibility proven twice); the reporting lesson — when the
numbers say a goal is probably unreachable, that sentence goes FIRST.**

**★★★★★★★★★★★★★★★★ NEWEST (2026-08-05, Opus 5; CERTIFIED by Fable 5 same night — F2 CLOSED, evidence re-examined not re-told: eb_dsp diffed verbatim against the port by hand, no port symbol in any engine B object, 6/6 null verdicts read from the logs, teeth log read 70/0. Reviewer defect recorded: I passed a fix after testing only that its checker catches the OLD bug; the NEW default was wrong by one dirname and cost a verify cycle) — PHASE 1 COMPLETE: THE TRUNK
IS THE WHOLE INSTRUMENT, EVERY ARM, AND IT BUILDS WITHOUT THE PORT. Read
`docs/engineb/data/standalone_gate.md` and `docs/engineb/data/c5_fusion.md`.**
- **EVERY DISPATCH ARM IS ENGINE B'S AND EVERY ONE IS GATED.** 1b-3 transcribed
  DELAY TYPE 4 and the EFFECT LABEL_164 core (types 0 and >= 6); a third
  doctored scenario closed EFFECT TYPE 4 (FLANGER), which `eb_chorus` has
  always handled and no gate had ever executed. `eb_master_render` refuses
  nothing. **36 scenarios; `--module chorus`, `--module standalone` and the
  composite are EXACTLY 0 at BOTH 44,100 and 48,000 Hz.**
- **THE PORTABILITY DEBT IS PAID.** Four modules called `juno_pitch_poly`,
  `juno_triangle`, `juno_wrap_unit`, `juno_wrap_hi` out of `src/juno_dsp.c`, so
  the TRUNK could not be built for a target at all. `engine_b/eb_dsp.c` now
  holds verbatim copies; `tests/test_eb_dsp` holds them to the port's own
  (520,043 comparisons, BIT-IDENTICAL, three planted mutations caught, two
  measured INERT — the triangle's branch boundaries are continuous).
  **VERIFIED: engine B links with NO `src/` object.** `tests/test_standalone_link`
  keeps it that way by linking only `engine_b/eb_*.c`.
  **★ NO NULL GATE COULD EVER HAVE SEEN THIS** — every null build links the
  whole port by construction. It was found by linking engine B by hand, once.
- **★ C5 (call fusion) IS CLOSED NEGATIVE, and the model was the problem.** The
  prize is **~640 instr/sample (0.9 %), not ~2,000**: on a register-window
  machine `entry` rotates the window instead of spilling it, so a call is nearly
  free. And the mechanism costs more than the prize — one TU removes **2 of 118**
  call sites and grows code 1.3 %; forced inlining is **2.6x worse** on
  instructions, float loads and stores, with call sites RISING 116 -> 247.
  Same wall as `pitch_hoist_result.md`: sixteen float registers. Nothing adopted.
- **★ THE FIFTH PRICING ERROR, same flattering direction as the other four:
  `engine_price.py` had NO MASTER CHAIN in it.** `master_in`/`master_out` run
  every sample on every patch and were absent, as were all nine dispatch arms.
  **Default 71,535, S3 shipping 56,967** (was 69,735 / 55,167). Arms are priced
  in their own table because exactly one of each group runs — charging all five
  delays would bill a patch for four it does not have.
- **★ THE DEFECT ONLY A COMPOSITE COULD FIND.** Every DELAY arm ends with
  `v56 = 0.0; v58 = -1.0;`, which reads as decompiler register scratch. It is
  not: the EFFECT arms assign those on ONE branch only. All four delay shims had
  dropped the pair. `--module delay` alone EXACTLY 0; `--module arms_1b3` alone
  EXACTLY 0; **the two TOGETHER failed at -11.7 dB**, first differing sample
  4050. **A module's contract is the state it LEAVES as well as the value it
  RETURNS**, and no per-module gate can test that.
- **★ THE TEETH CASE FOR IT TOOK THREE REVISIONS, EACH A LESSON.** (1) It
  planted into DELAY-1's arm, which no scenario selects. (2) It DELETED the
  statement and measured EXACTLY 0 — an uninitialised local's value is not
  controlled, so the case measured the compiler. (3) MEASURED, perturbing each
  alone: **`v56 = 0.25` EXACTLY 0 (INERT), `v58 = -0.5` -27.8 dB (CAUGHT)**,
  both dropped -16.5 dB. The shims restore both; **the proof covers one**, and
  saying "the pair is gated" would be an over-claim.
- **★ TWO GATES WERE MEASURING SOMETHING ELSE.** `plugin_check` with no
  `--module` builds `src/` and certifies THE PORT — its own log said so while
  the headline read "11/11 agree with the PLUGIN". And `arm_coverage.py`
  rendered the DOCTORED scenarios against the PRISTINE bank, so it called two
  arms NOT REACHABLE while the null gate was covering them.
- **★ `tests/test_freerun` HAD NOT LINKED SINCE STEP 1** (the real allocator
  needs `eb_alloc.c`; the rule was never updated) and nobody saw it, because
  `engine_b/tests` is not in the top-level `make test`. **A unit test that does
  not build is not a failing test, it is an absent one.**
- **CERTIFICATION, all on ONE frozen tree:** nulls EXACTLY 0 as above ·
  `plugin_check --module standalone` **11/11 BIT-EXACT vs the PLUGIN at BOTH rates** · full `--teeth` at 48 kHz
  **PASS, 70 cases, zero gate defects and zero stale anchors** (`out:standalone` 3.16e-5 FAIL -90.0 dB 36/36 / 3.16e-6 PASS -109.8 dB; `out:chorus` FAIL 25 scenarios -- 24 before the EFFECT-4 scenario existed; `seedpoison` FAIL 24/36; `voicereseed` 35/36; `voiceidleskip` 36/36; `delayscratch` FAIL -28.3 dB in exactly ONE scenario, the doctored EFFECT-0 one, which is the only arm that reaches the branch) · `alloc_ab.py` 270/270 over all nine assign configurations,
  teeth 4/4 CAUGHT · `patch_roundtrip.py` 64/64 BIT-EXACT · `make test` green ·
  the `engine_b` unit suite green · `coef_audit` PASS (266 cells, both
  accessors) · `merge_shims --check` up to date · port-side `make verify`
  **GREEN, EXIT=0, all 21 ledger rows PROVEN** (it took three runs: run 1 died on gates whose scratch DEFAULT was a dead session directory, run 2 died on the FIX being wrong by one dirname -- `tools/verify/pathcheck.py` now fails the build on any gate that defaults outside the repo, teeth-proven both ways).
- **OPEN, and none of it is a Phase-1 item:** the allocator's RETRIG/PORTA_GATE
  events (they belong to `eb_patch`); engine B's own recall (coefficients still
  come from the PORT's recalled cells through `eb_render_coefs_build` /
  `eb_master_coefs_build`, which is HARNESS PLUMBING and says so); the at-rest
  voice shortcut, still unexercised.

**★★★★★★★★★★★★★★★ NEWEST (2026-08-04, Opus 5) — 1b-1 AND 1b-2 DONE: ENGINE B
RENDERS THE WHOLE INSTRUMENT. Read `docs/engineb/data/standalone_gate.md`.**
- **`null_b.py --module standalone`: all 33 scenarios, EXACTLY 0 vs the port at
  BOTH rates. `plugin_check`: 11/11 BIT-EXACT vs the PLUGIN at BOTH rates.**
  Voice chain AND master chain, engine B's own state throughout; the port's
  voice/master functions are linked and never called. Teeth MEASURED at 48 kHz:
  3.16e-5 FAIL −90.0 dB 33/33, 3.16e-6 PASS −109.8 dB, `seedpoison` FAIL 21/33.
- **1b-1: `master_render.c` went 22 % → 82 % claimed.** Seven new modules
  (master_in, master_out, delay_t1/t23/t5, fx_e1/e5), each EXACTLY 0.
  Everything still unclaimed is in an arm NO factory patch can select.
- **★ THE GATE WAS BLIND TO HALF THE MASTER.** The 30 inherited scenarios drove
  DELAY TYPE 0/1/5 and EFFECT 2/3/5 only — a module for any other arm could not
  be gated at all. Three scenarios from REAL factory patches closed DELAY 2/3
  and EFFECT 1; `tools/engineb/arm_coverage.py` checks it every run.
- **★ THAT COVERAGE FOUND A DEFECT ON ITS FIRST RUN: the arpeggiator never
  bumped `eb_coef_gen`,** so engine B was blind to arp notes and would have
  played SILENCE on all seven arpeggiated factory patches. The scenario that
  caught it was added for an unrelated reason (EFFECT TYPE 1's only patch has
  the arp on).
- **★ THE EFFECT SEND IS A ONE-SAMPLE FEEDBACK LOOP, NOT AN INSERT.** The port
  forms its output at :2367/:2375 and only THEN dispatches the effect arms at
  :2378; an arm reaches the audio through cells 84672/84704 on the NEXT sample.
  `eb_engine_render`'s old master modelled it as an insert and had no type
  dispatch at all.
- **★ THREE FORMS OF ONE TRAP, all int/float reinterpretation, each green
  before it was red:** a per-sample cell cached as a coefficient; an
  `int`-declared local carrying float BITS (converted twice, made an output
  exactly 0); and a `LODWORD` store into a float field (cell read back
  947597056 where the port had 5.99e-05). Guards: `coef_audit.py` (in the
  teeth), `arm_xform.carriers()`, and a `memcpy` rewrite.
- **★ `rev_pending[33]` WAS ONE SHORT** — EB_REV_NTAP is 34, so the reverb read
  past the array and its last tap latched garbage. Visible only as the B
  channel drifting in its last bits. Found by exporting the PORT's own
  intermediates (v530 diverged first) then comparing the two `eb_reverb_state`s
  BYTE FOR BYTE: first difference at byte 196 = `taps[33]`. `eb_render.h` had
  the identical off-by-one.
- **★ A `--quick` PASS IS NOT A RESULT.** `--quick` drops `long LFO+tail`,
  which is the ONLY scenario exercising `fx_e5`; that module's quick PASS was
  VACUOUS and it was genuinely broken. No module result may be quoted from a
  quick run.
- **★ F1's SEED-POISON CASE COULD NOT FIRE, and that was a measurement.**
  Perturbing the seeded cell 84768 changed nothing on all 33 scenarios: cell
  84816 multiplies it and is 0.0 in ALL 64 FACTORY PATCHES, so that feedback
  path is dead for this bank. Re-pointed at `fb84704` it fails 21/33.
- **MEASURED: the master chain's six delay rings need 6.10 MB** (three of 2 MB).
  `eb_master_rings` is CALLER-OWNED so no target can be misled about it.
- **⚠ PORTABILITY DEBT:** `eb_delay_t23`/`eb_delay_t5` call `juno_pitch_poly`
  and `juno_triangle` from `src/juno_dsp.c` — the PORT. Found by LINKING
  outside the harness; the null gates link the whole port and hid it.
- **OPEN:** 1b-3 (DELAY TYPE 4 + the EFFECT LABEL_164 core — no factory patch
  selects them, so they need a synthetic-recall gate BEFORE transcription, and
  they are NOT optional since the trunk is the full instrument); the
  allocator's RETRIG/PORTA_GATE events (belong to `eb_patch`); C5; the METHOD
  PLAYBOOK; the certification sweep.

**★★★★★★★★★★★★★★ (2026-08-04, Opus 5) — 1b-0 DONE: ENGINE B'S RENDER
FUNCTION HAS RUN, AND IT NULLS EXACTLY 0. Read `docs/engineb/data/voice_gate.md`.**
- **`null_b.py --module voices`, all 30 scenarios, EXACTLY 0 vs the port at BOTH
  44,100 and 48,000 Hz.** `eb_engine_render_voices()` — the 16 gated modules
  PLUS the wiring between them, driving engine B's OWN state from an
  `eb_render_coefs` — reproduces the port's eight per-voice samples bit for bit.
  **Full `--teeth` battery at 48 kHz: PASS (49 cases).** New teeth: bracket
  MEASURED 3.16e-5 FAIL −90.0 dB 30/30 / 3.16e-6 PASS −109.8 dB; `voicereseed`
  caught 29/30; `voiceidleskip` caught 30/30. Composite + decim re-gated PASS
  both rates; `make test` green.
- **STILL THE WEAKER GATE, as ruled.** The MASTER is still the port's (78 %
  untranscribed), recall is still the port's, the at-rest shortcut is still
  unexercised, `render_ok` stays UNSET. 1b-1 (master transcription) then 1b-2
  (standalone gate) are next.
- **FOUR defects found by RUNNING it, after eight had been found by reading it.
  Two were SILENT:**
  1. **The DCO oscillator levels were cached from per-sample cells** (4736/4752/
     4768, written at :1702-1707) → DCO emitted exactly 0 → the whole chain
     nulled at 0.0 dB rel, i.e. SILENCE. The coefficients are 4192/4208/4224.
     **★ WHY THE CHECK MISSED IT: it grepped `JF(a1,N) =` and the port copies
     all three with `JI`, as ints. A cell-writer audit that names only ONE
     ACCESSOR is not an audit.** `tools/engineb/coef_audit.py` now does it
     mechanically, both accessors, scoped to the constructor.
  2. **Cell 5456 cached too** (LATENT — fixing it changed no sample): it is
     eb_dcoprep's third output and the decimator's per-sample feedback term,
     discarded as `(void)pwm_out`. `k5456` is now a per-sample ARGUMENT so the
     type system refuses it. **The decim shim caches it too, so that gate is
     blind to this cell by scenario coverage, not by construction.**
  3. **The DCO retrigger one-shot (101504+v*32) belonged to NO module** — read
     at :589, cleared at :2178, both outside every boundary. A standalone engine
     would silently never retrigger; no COLD scenario can see it.
  4. **★ THE LOCKSTEP DEFECT: engine B's statics were never re-seeded per
     context.** The worker renders all 30 scenarios in ONE process, so scenario
     1 nulled EXACTLY 0 and all 28 others failed from their FIRST FRAME — first
     differing sample 42000, exactly scenario 1's length. It looks exactly like
     a broken DSP chain and is nothing of the kind. Re-seed is keyed on a MARKER
     in the state block's unused tail, not the pointer (freed addresses are
     reused); re-init and chorus-mode calls deliberately do NOT re-seed. Now a
     permanent teeth plant.
- **★ A THIRD "teeth case that could not reach its own mutation":** the output
  anchor inserts after the assignment and the crossing loop had no BRACES, so
  the statement landed outside it with `v == JUNO_NUM_VOICES`, wrote past the
  end of `vbuf`, and perturbed nothing — both bracket factors measured EXACTLY
  0. The uniqueness assert PASSED, because the anchor did match once.
  **Matching is not reaching.**
- 1b-1 groundwork MEASURED: `master_render.c:826-886` is the master input stage
  with **ZERO live-in, three live-out** — the eb_lfo shape, the first block.

**★★★★★★★★★★★★★ (2026-08-04, Fable 5) — P8 C1 EXECUTED TO ITS END:
DEAD, AND IT UNCOVERED THE LAW THAT STEERS EVERYTHING LEFT. Read
`docs/engineb/data/pitch_p2_study.md` §6.**
- **C1 (control-rate pitch) is CLOSED NEGATIVE by the strongest measurement in
  this repo:** the final Taylor form is accurate to 1e-7 worst / 4e-8 RMS on
  the REAL pluck-POLY trajectory (336,000 logged calls) — and the null still
  fails at −89.5 dB. A smooth deterministic error is a BIAS and the DCO phase
  INTEGRATES it; v7 passes because its ±1-ULP errors DITHER around zero, not
  because it is accurate. The design ladder (output extrapolation → Taylor →
  df/double derivatives + 2nd order + knot re-anchor + clamped-domain δ +
  pre-gain anchors) is in the study with each rung's kill. Also found on the
  way: the FLOAT derivative of the pitch polynomial has the WRONG SIGN
  (−0.104 vs +0.022) — the 2^37 cancellation applies to P′ too.
- **★ THE LAW (apply to every future candidate):** classify the target by its
  CONSUMER. Phase-integrated quantities (pitch increment → DCO phase, LFO
  rate → LFO phase) need bias < ~1e-9: NO causal approximation passes — only
  exact-to-dither evaluation. Memorylessly-consumed quantities (VCF
  coefficients, gains) tolerate ~1e-5. **So: pitch 21,792 instr/sample is
  IRREDUCIBLE by approximation (proven twice); C3 (incremental LFO expf) is
  dead by the same law; C2 survives only for non-integrating targets
  (vcf_res/vcf_cv coefficient paths, ~3,500).** Remaining big lever: C4
  fixed-point+PIE SIMD on the audio path. P8_PLAN.md carries the revision.
- EB_PITCH_CR > 1 is a #error pointing at the study; N=1 is bit-exact
  (reproduces −148.4 dB exactly) and stays as the harness self-test. The
  shipping default is untouched and re-proven.

**★★★★★★★★★★★★ NEWEST (2026-08-03 latest, Fable 5) — THE NUMBER CORRECTED
IN REVIEW, AND P8 IS PLANNED. Read `docs/engineb/P8_PLAN.md`.**
- **THE FOURTH PRICING ERROR, same flattering direction as Opus's three: libm
  was charged at ZERO.** expf = 184 instr on this toolchain (wrapper +
  __ieee754_expf body), fmodf = 137; the LFO alone runs expf per voice per
  sample. ~6,600/sample. The first correction then OVER-swung (10 conditional
  fmodf sites at full body = the DCO worst-case problem in miniature), so the
  rate was MEASURED: slow arm fires 9.75 % of wrap calls (EB_LFO_COUNT, 61 M
  calls, all 30 scenarios). **Corrected totals: default 69,735 (1 % from the
  audit's independent ~69,000 — two methods now agree), S3 shipping 55,167 =
  5.8–8.8× over.** Third restructure target now visible: **LFO 6,305/sample**
  joins pitch (21,792) and DCO (10,202) = 69 % of the engine.
- **P8 PLAN (supersedes the P8 sketch in DOUBT_AUDIT):** C1 control-rate pitch
  w/ increment interpolation (N=2/4/8 ladder, ~−15,300, Fable — the argument
  why it can pass where plain float failed: interpolation between CORRECT
  values is bounded zero-mean path error, not an integrating value error;
  vibrato decides); C2 control-rate CV for vcf_res/glide/pwm_cv/vcf_cv
  (~−5,500, Opus, after C1's gate shape exists); C3 LFO expf incrementally
  (~−1,300); C5 call fusion (EXACTLY-0-able, ~−2,000); C4 fixed-point+PIE SIMD
  on the audio path (the only ×2–3 lever, one-filter prototype first); C6
  reduced oversampling BEHIND all of those; 6 voices LAST, user's order.
  **Honest end-to-end arithmetic: full ladder ≈ 15,000/sample → 1.6–2.4× —
  near budget only at c/i ≈ 1.0. Silicon (P10) decides; the plan does not
  promise the goal.** Step 2 (eb_render_coefs constructor + eb_engine_render
  gate) is still OWED before silicon and unaffected.

**★★★★★★★★★★★ NEWEST (2026-08-03 late night, Opus 5) — STEP 1 DONE, AND THE
HONEST WHOLE-ENGINE NUMBER EXISTS. Read `docs/engineb/data/engine_cost.md`.**
- **THE ALLOCATOR IS ENGINE B'S AND IS GATED.** `eb_engine.c`'s SKELETON
  allocator ("free voice first, else oldest" — it said so) is replaced by
  `engine_b/eb_alloc.{h,c}`, CAssignJu60's real law transcribed from
  gui/juno_bridge.c (itself PROVEN 34/34 vs the plugin by assigner_ab.py).
  **`tools/engineb/alloc_ab.py`: 270/270 note sequences agree with the port's
  allocator after EVERY event, over all NINE assign configurations in the
  bank.** Audio is a POOR detector here (two allocators can differ only through
  CONDITION scatter — exactly how the POLY-only bug survived), so the gate
  compares BINDINGS. **Teeth PASS on four named errors:** bottom-up scan,
  reaped binding, forced POLY, highest-held release.
  Two defects in that gate, both found by running it: patch 1 has the ARP on so
  note-ons never reach the allocator (30 false failures), and *skipping* arp
  patches then silently dropped UNISON + every LEGATO config (9 → 4). Fixed by
  keeping the recalled config and forcing the arp off, asserted.
- **★ THE NUMBER: S3 shipping build (fast pitch v7 + DCO reciprocal) =
  48,564 instr/sample = 5.1×–7.7× OVER the 6,300–9,500 two-core budget.**
  Default bit-exact build = 63,484. MEASURED×STATIC via call-graph pricing,
  NO QEMU (`tools/engineb/engine_price.py`).
  Cross-checks: default 63,484 vs DOUBT_AUDIT's independent ~69,000 (8 %);
  pitch/call 4,281 & 2,592 vs the recorded ~4,450 & ~3,126 (4 % / 17 %).
- **THE P6 TRIPWIRE IS TRIPPED (>19,000 → start P8 at once).** Pitch (20,736,
  43 %) + DCO (10,202, 21 %) = **64 % of the engine**. P2 already killed the
  cheaper-arithmetic exits for pitch, so what remains for both is STRUCTURAL —
  P8's loop fusion / control-rate CV / reduced oversampling / fixed-point+SIMD,
  each still gated at −100/−80 dB.
- **THREE TOOL ERRORS, ALL CAUGHT, ALL FLATTERING:** summing whole-TU symbols
  counts a static helper ONCE though df_mul is called 11× (921 vs ~2,600);
  skipping `.text+0xNNN` relocations drops every intra-module call (priced
  eb_pitch_eval at **18**); `grep -l` for libgcc helpers finds objects that
  REFERENCE not DEFINE them (_divdc3.o "is" __muldf3 at 903 instr — the real
  105). **A measurement that flatters its subject deserves the suspicion a
  never-failing gate does.**
- **NOT DONE — step 2.** `eb_engine_render` is still NOT gated: nothing builds
  an `eb_render_coefs` yet. `render_ok` stays unset. The number above prices the
  per-sample DSP chain and EXCLUDES allocation, recall-time coefficient
  derivation, and eb_engine_render's own plumbing.

**★★★★★★★★★★ NEWEST (2026-08-03 late, Opus 5) — P5 SUBSTANTIALLY DONE. SIX
BLOCKS CLAIMED, `eb_render_needs` IS EMPTY, 96 % OF THE VOICE FUNCTION IS
ENGINE B'S.** New modules, each **EXACTLY 0 on all 30 scenarios at BOTH rates
on its FIRST run**: `eb_notecv` (:595-656, the shared 25-bit noise LFSR),
`eb_glide` (:682-796, portamento + FINAL PITCH CV + LFO rate chain), `eb_lfo`
(:797-963), `eb_noisemix` (:1141-1149), `eb_vcf_res` (:1230-1297, the VCF
resonance shaper), `eb_dcoprep` (:1702-1717, the DCO phase increment).
**Composite = 16 voice modules: EXACTLY 0 at both rates, 11/11 BIT-EXACT vs
the PLUGIN at both rates.**
- **THE METHOD THAT WORKED — REUSE IT.** Pick the boundary by a LIVE-VARIABLE
  analysis (eb_lfo's range has 4 live-in and ZERO live-out — that is why it
  lifts), then classify every RW cell by READ-BEFORE-WRITE. Of eb_lfo's 18 RW
  cells only **5 are state**; the rest are the port's delayed-copy idiom or
  write-then-read locals. Do it BY SCRIPT — but see the four ways the script
  LIES, below.
- **★ THE SCRIPT LIES IN FOUR WAYS, ALL FOUND BY READING THE CODE AFTERWARDS.
  Check every one of these on the next block:**
  1. **Branch-split cells.** vcf_res's 7520/7536 are written in the `if` arm
     and read in the `else` arm → they CARRY across samples, but a
     read-before-write scan calls them locals. Treating them as locals zeroes
     the filter on every else path.
  2. **Raw-pointer cells.** `*(float *)(a1 + 0x2000)` (= cell 8192) is
     invisible to a `JF(a1,N)` grep. A sweep of the whole function found
     EXACTLY ONE such access, so every other block's inventory is sound —
     because it was checked.
  3. **Self-assigned live-ins.** `v227 = f(v227, ...)` makes v227 look
     "assigned" to a naive live-in check; it is a genuine live-in. Split
     statements on `;` with DOTALL to catch it.
  4. **Per-sample cells masquerading as coefficients.** noisemix's 3536 is
     written at :1076 as a delayed copy. Caching it with the real coefficients
     would freeze a per-sample value, and **the generation guard could never
     catch it** because the cell does not change at recall time. ALWAYS grep
     `J[FI](a1, N) =` across the whole function before calling a cell a coef.
- **`eb_render_needs` went 8 → 0. `drive`/`held` were NEVER needs:** the port's
  :657-681 shows eb_cvgate's arguments are cells 176/208/272*240/304/544 — all
  recall values. An earlier eb_engine_render draft had GUESSED that call's
  inputs (it passed the envelopes). Fixing it also removed a one-sample skew
  (the port runs notecv→glide→LFO BEFORE the envelopes, whose gate is built
  from cells 560 and 1824 written in the SAME sample), and a noise-lockstep
  bug (the LFSR was being advanced per voice = 8× too fast; it is ONE call
  before the loop now, and the struct fields are singular so per-voice is no
  longer expressible).
- **THE GUARD STAYS ON.** Honestly remaining: the DCO coefficient-copy
  equivalence (believed, NOT gated), eb_engine.c's unproven allocator (F4), and
  the two delayed copies in :1665-1671. **That range is left in the port ON
  PURPOSE — it has NO arithmetic** (4 loads, 3 delayed copies); wrapping cell
  motion in a function would improve only the block count.
- **TWO HARNESS DEFECTS, both found by running it, both teeth-proven:**
  (1) `merge_shims.py`'s overlap guard kept only each module's **LAST** edit
  region (`owner` was a dict keyed by module). cvgate edits THREE ranges; a
  module spanning the first two merged clean, compiled, and nulled at **0.0 dB
  on all 30 scenarios**. It is a LIST now. (2) Two shims independently chose the
  same file-scope static name — compiles alone, collides only in the composite,
  error names neither module. Both refused now, by name.
- Teeth: brackets MEASURED for lfo/notecv/vcf_res/noisemix; **glide and
  dcoprep are FAIL-ONLY** (both carry pitch, so error integrates), joining
  pitch/pwm_cv/cvgate. **noisemix's FAIL case is 3e-5, NOT 1e-5** — 1e-5 lands
  at −99.8 dB, clearing the gate by 0.2 dB, i.e. a probe ON the threshold, the
  trap this harness was already caught by twice. Xtensa census: **zero
  soft-double in all six** modules.

**★★★★★★★★★ NEWEST (2026-08-03 night, Opus 5) — P1 AND P3 CLOSED. Read
`docs/engineb/data/null_48k.md` and `docs/engineb/data/dco_real_cost.md`.**
- **P1 / HOLE H1+H2 CLOSED. The −100 dB gate now runs at 48,000 Hz**
  (`null_b.py --rate`, worker-argv plumbed, plus a hard refusal to compare an
  oracle and candidate rendered at different rates). Added
  `JUNO_EB_DCO_RECIP=1` so that lever's null stops resting on a hand-edited
  header. **THE S3 SHIPPING BUILD (fast pitch + reciprocal, WHOLE ENGINE) NOW
  HAS A SONIC GATE AT ITS OWN RATE: −121.5 dB @48k, −121.1 dB @44.1k, all 30
  scenarios, ~21 dB margin.** Fast pitch alone: **−148.4 dB @48k** — 48 kHz is
  BETTER than 44.1k, not worse. The 44.1k figures reproduce the published
  −123.6/−121.1 exactly (the evidence the plumbing perturbed nothing), and the
  composite residual EQUALS the pitch-alone residual, so the other 12 modules
  are still EXACTLY 0 with the fast path integrated.
- **A harness defect found by running the teeth at 48k for the first time:** the
  `dcopitch` mutation planted into `juno_init.c`'s **44,100-only** constant arm
  (`:314 if (result == 44100)`; both arms define v32), so at any other rate it
  modified DEAD CODE and the case measured NOTHING. Fixed to plant into the arm
  the run's rate executes. Same class as every other defect here.
- **P3 / HOLE H4 CLOSED — the DCO's real cost, MEASURED×STATIC, NO QEMU in
  either half.** Host branch counters (`-DEB_DCO_COUNT`, write-only, bit-exact
  build re-proven EXACTLY 0 both rates) over the real gated scenario set on real
  recalled patches = 60,989,440 sub-sample steps, priced by static Xtensa
  `objdump` counts **including libgcc helper bodies** (`__divsf3` = 30 instr).
  MEASURED rates: **clamp shortcut fires 99.2–99.7 %**, saw arm on 53.4 %, sub
  arm on 38.6 %, **fmodf wrap taken 0 times in 61 M steps** — the two branches
  the synthetic QEMU run had defeated. **Real cost ~11,610 instr/sample, not
  17,581: QEMU was 51 % HIGH.** Priced on QEMU's own configuration the two
  methods agree to within 18 %. **EB_DCO_RECIP saves a further 1,408 (12 %)** and
  is now the best-evidenced unadopted lever (gated −121.5/−121.1 dB).
  Tools: `dco_rates.py` (rates) + `dco_paths.c`/`dco_price.py` (pricing), kept
  separate on purpose.
- Still open: H3 (~69,000 is an estimate of an engine that does not exist —
  needs P5 then P6) and H5 (instructions ≠ cycles — silicon only).
- **P2 CLOSED, NEGATIVE (same night, Fable 5) — read
  `docs/engineb/data/pitch_p2_study.md`. All three cheaper-pitch exits are
  dead, two by measurement:** (1) the phase-accumulator hypothesis CANNOT work
  — the port's increment is itself a float, a value difference cannot be
  repaired downstream; (2) recentering/truer-value schemes CANNOT match the
  port — its own sum structure amplifies its double rounding by up to 2^37
  near the polynomial's zeros (measured from juno_pitch_table in exact
  rationals), so only structural mimicry matches; (3) v7's two upgrades were
  isolated (v8 = simple accumulator −16 %, v9 = simple products −32 %): both
  **PASS 44.1 kHz (−110.2 / −106.0) and FAIL 48 kHz at −95.4 dB** on 'DCO neg
  pitch sweep' — the H1 trap live, caught only because P1 exists. **v7 stays;
  EB_PITCH_FAST > 1 is now a #error; pitch's ~21,300 instr/sample is the
  measured price of the gate.** DOUBT_AUDIT §4's best case worsens to
  ~54,000–61,000 → the P8 restructure track is more mandatory, not less.
  Probe variants v8/v9 + the 48k probe wrapper are in docs/engineb/data/.

**★★★★★★★★ (2026-08-03 evening, Fable 5) — THE DOUBT AUDIT. Read
`docs/engineb/DOUBT_AUDIT.md` FIRST; its plan P1–P12 SUPERSEDES
S3_ASSESSMENT §5.** What it found, in one breath:
- **HOLE H1 (real): no −100 dB null has EVER run at 48,000 Hz.** null_b.py
  renders every scenario at 44,100 (null_ab.SR). The fast-pitch −123.6 dB and
  RECIP −121.1 dB results are 44.1k-ONLY; quote them so until P1 closes this
  (null_b rate parameter + re-runs). The composite also never ran with
  EB_PITCH_FAST=1 (H2).
- **MEASURED CLEAN (new, STATIC Xtensa census): there is no second soft-double
  bomb.** Only eb_pitch.o carries df3 relocs among all engine B objects; the
  port-side remainder's non-pitch double sites are 5 power-of-two scales in
  voice_render.c (exact in float — WHY the float transcriptions null EXACTLY 0)
  + 15 once-per-sample master/FX sites mostly already replaced. The 8 unclaimed
  blocks hide no soft-double.
- **The honest complete-engine number is ~69,000 nominal instr/sample, not
  ~65,000** (that figure had ~6,800 harness scaffold in it and the ~11,300 of
  unwritten blocks missing from it). Best case after EVERY staged lever:
  ~35,000–42,000 vs an instruction budget of 6,300–9,500 (9,500 cycles at c/i
  1.0–1.5) → **~4–7× over. Tuning alone cannot close it.** The plan therefore
  contains a restructure track (P8: loop fusion EXACTLY-0-able; control-rate
  CV decimation; reduced oversampling w/ matched decimator; fixed-point + PIE
  SIMD) — every candidate must null at −100/−80 like everything else.
- Biggest cost unknowns, with retiring measurements: DCO real-mix (host branch
  rates × static Xtensa paths, NOT QEMU per-call — P3) and c/i (silicon, P10).

**★★★★★★★ (2026-08-03, Fable 5) — ENGINE B GREEN + THE S3 VERDICT
CORRECTED. Read `docs/engineb/S3_ASSESSMENT.md`; it supersedes the
"unreachable" verdict in `docs/engineb/LEVERS.md` (its §5 ranking is now
superseded by DOUBT_AUDIT.md).**
- **Engine B: 13 modules, whole-engine composite (`--module all`), EXACTLY 0 vs
  the port on all 30 scenarios AND 11/11 BIT-EXACT vs the PLUGIN at 44.1k and
  48k. Certified again 2026-08-03.** Gates: `null_b.py` (teeth for every
  module), `plugin_check.py --rate`, `merge_shims.py --check` (the composite is
  GENERATED; a stale one bit us once). `eb_engine_render` exists but REFUSES to
  run (render_ok guard) until `eb_render_needs` is empty — 8 named inputs
  (LFO, glide, key follow, velocity, CONDITION scatter...) are still port code.
- **The S3 feasibility analysis was redone with real Xtensa numbers:**
  `eb_pitch.c` computes its 13-term polynomial in DOUBLE, 8x/sample; the S3 has
  no double FPU → 18,200–22,300 executed instr/sample of soft-double (STATIC
  common-path census from libgcc's own bodies) — 3.6–4.5x the ENTIRE one-core
  budget, invisible on host (536 instr/sample). Corrected capacity: 5,000
  cyc/sample/core EXACT; two-core working budget ~9,500 (the binding
  constraints rank 8 voices + all FX above the one-core preference).
- **THE PITCH FIX IS DONE AND GATED (v7).** `engine_b/eb_pitch.c` now carries
  `#if EB_PITCH_FAST` (default 0 = bit-exact double; PROVEN EXACTLY 0).
  `JUNO_EB_PITCH_FAST=1 null_b.py --module pitch`, full 30 scenarios: **PASS,
  worst global −123.6 dB** (23.6 dB margin). The road (float32 FAIL 30/30;
  Dekker FAIL 2/30; v4/v5/v6 threshold/clamp/row variants BIT-IDENTICAL
  residuals = the error was a distributed 1-ULP carpet; v7 = error-free
  product lo-paths + compensated accumulator) is in
  `docs/engineb/data/pitch_precision_null.md` with the reproducible probe.
  **THE HOIST IS DONE (2026-08-03, Opus 5) — and the saving is 22 %, not the
  ~65 % this file used to imply. See `docs/engineb/data/pitch_hoist_result.md`.**
  API is now `eb_pitch_eval(cv, gain)` (the module reads its own row);
  `engine_b/eb_pitch_tab.h` is the generated build-time split, CHECKED against
  `df_coef` by `test_pitch_tab` (0 of 377 pairs differ). S3 census: NO
  soft-double on the per-sample path. All gates re-PROVEN (default EXACTLY 0;
  fast −123.6 dB, bit-identical to before the hoist; whole engine EXACTLY 0;
  11/11 vs the PLUGIN at 48k; 7/7 unit tests).
  **THE CORRECTION THAT MATTERS: removing soft-double does NOT remove the
  cost.** STATIC per call: double ~4,450 (230 body + 4,228 helpers), fast
  ~3,126 (324 body + 2,802 df helpers). Per sample 27,351 → ~21,300. Whole
  chain ~71,000 → **~65,000 vs ~9,500 two-core = ~6.8× over**, not ~4.6×.
  WHY, MEASURED: `always_inline` on the df helpers is WORSE (3,452 vs 3,126);
  the inlined mix is 1,254 `lsi` + 423 `ssi` — **1,677 of 3,452 instructions
  are float SPILLS**. The LX7 has 16 float registers and compensated
  double-float keeps more live than that. Left as calls on purpose.
  **NEXT IDEA (hypothesis, not a plan): move the precision to the DCO's PHASE
  ACCUMULATOR, not the polynomial.** The −100 dB failure was a pitch error
  INTEGRATING in phase; plain-float pitch failed only through that. One
  compensated add per sub-sample may buy what a whole compensated 13-term
  polynomial per sample is buying now. Build it and gate it like everything
  else.
- **THE QEMU HARNESS RAN — first executed-Xtensa numbers exist**
  (`docs/engineb/data/qemu_instr_counts.md`; raw log + harness committed in
  `tools/engineb/qemu/`; QEMU binary in the scratchpad, re-download recipe in
  the doc). **CCOUNT ticks once per 25 instructions in this build** (icount
  1 ns/instr × 40 MHz machine clock — the harness's own comment says
  per-instruction and is WRONG; scale cross-checked on four branch-light
  functions). MEASURED: whole chain 71,051 instr/sample; pitch-double
  27,351 (validates the model); dco_step4 17,581 (worst-case-ish — synthetic
  levels defeat the saturator shortcut; replay a REAL scenario to bound it);
  ladder 8,850; ALL FX only 1,635. vs 9,500 two-core budget: 7.5× today.
  Instructions ≠ cycles; c/i ≥ 1 on top.
  **⚠ THE PER-CALL FIGURES IN THAT TABLE ARE NOT TRUSTWORTHY (found 2026-08-03).**
  Two harness runs differing ONLY in `EB_PITCH_FAST` disagree by exactly
  500,000/1,000,000 raw counter units on UNCHANGED functions (chorus 302,276 vs
  1,302,275). CCOUNT advances 25 at a time at translation-block boundaries, so
  short spans sample the quantisation systematically and a code-layout change
  moves it. `sample_total` (~70,000-instruction span) is still sound; for
  per-function cost use STATIC `objdump` counts, which is what
  `pitch_hoist_result.md` does.
- **Ranked plan (S3_ASSESSMENT §5): pitch v3 → QEMU measurement → EB_DCO_RECIP
  (MEASURED −121 dB, passes the −100 gate) → VCF reciprocal → inline clamps →
  blockwise structure → two-core split → silicon → memory plan (256 KB delay
  ring vs 512 KB SRAM; the user's board has 8 MB PSRAM). Oversampling redesign
  ONLY if still over; 6 voices LAST (does not close the gap alone).**
- **Session lessons that must not be relearned:** host x86 counts are not S3
  costs in EITHER direction; the accuracy standard is the −100 dB SONIC gate
  (bit-exact kept where free); a store is not a signal (dead-store probes lie);
  regenerate the composite before trusting any whole-engine run; a
  verification that has never been seen to fail is not a verification.


**⚑⚑ LIVE WORK ORDER (2026-07-31, user-binding, supersedes the 07-27 pointer
below): `docs/ROADMAP_EMBEDDED.md` — the embedded big-picture plan. Execute
P0 (stabilize) → P1 (measure on silicon) → P2 (decide) → P3. The DAW-parity
work (HOSTPATH_PARITY_SCOPE STEP 2–5, #141/#124/#140) is now the PARALLEL
track, still valid, no longer the head pointer.**

**★★★★★★ NEWEST (2026-08-01) — P1 CLOSED. THE PORT HAS RUN ON SILICON. The
SILICON row of the label table is no longer empty; see the box at the top of
`docs/ROADMAP_EMBEDDED.md`.** Daisy Seed, the user's own board:
- **E1: golden corpus 8/8 BIT-EXACT on real M7.** Bit-exactness survives the
  real part, not just qemu. Everything else is a performance question now.
- **E2: 8 voices + FX = 93,288 cyc/sample against a 8,333 budget → 11.19× OVER.**
  SysClk is **400 MHz, not 480** (so the budget is 8,333 @48k, not 10,884). The
  measurement is **2.2× worse than the worst case we modeled** (band was 18–42k).
- **Polyphony is not a lever: the idle floor is 85,137 of the 93,288 (91%).**
  4 voices = 84,560, i.e. 9% cheaper than 8. "Fewer voices" is dead as an escape.
- **Memory placement is not a lever either: E3 measures D-cache ON vs OFF at
  1.05×.** The engine is not SDRAM-latency-bound. E4's scattered AXI-vs-SDRAM
  penalty is 6.26×, real but not dominant. ⚠ E3's ABSOLUTE numbers (287k
  cyc/sample for the same 8-voice workload E2 puts at 93k) are a 3× discrepancy
  that is UNRECONCILED — quote its ratio only.
- **Track B's STOP rule S1 does NOT fire** (4-voice Daisy = 10.1× over; Teensy@816
  = ~5× over on these numbers). Track B is now the only path to 8 voices — and it
  needs better than 10×, which no measured lever approaches. **P2 is now a real
  decision, not a formality.**
- Audio DOES come out of the codec and is audibly glitchy — the correct symptom
  of an 11× overrun, not a wiring or engine defect.
- **Five firmware defects were found by running it, four by the board itself:**
  the corpus leaked a 12 MB context per scenario; the SDRAM pool was a bump
  allocator that could not reclaim (fixing the leak alone changed nothing —
  `free` was a no-op); E2/E3 leaked their contexts too; the pool was READ before
  it was initialised and `.sdram_bss` is NOLOAD, so E0 walked power-on garbage;
  and newlib-nano's vsnprintf has no `%ll`, so every printed hash read `...lx`.
  **The host harness could not have caught the NOLOAD one — its pool is ordinary
  BSS and is already zero.** It now pre-fills 0xA5/0x5C/0x00/0xFF, and is
  mutation-checked (removing the guards → 7 failures).

**★★★★★ (2026-07-31 evening, Opus 5) — SEAL RE-PROVEN + WASM REPUBLISHED +
TRACK B HARNESS BUILT AND ITS OWN DEFECTS FOUND. Read `docs/trackb/PLAN.md` (685
lines, the execution plan) and `docs/TRACKB_CHARTER.md` (the gates).**
- **`make verify` GREEN end-to-end, EXIT=0**, first full run since the MONO
  retrigger fix, all references regenerated from `truth/`. ASSIGNER A/B is now
  **34/34** — patch 15 + the fuzz seed-15 `warmmono` script (with its 747-sample
  WARM PREFIX, the load-bearing part: `juno_init` arms the retrigger latch at
  BUILD, so every COLD gate is structurally blind to a missing re-arm).
  `arm_golden.sh` is folded in (#144); its missing-toolchain exit reports SKIP
  and is labelled NOT a pass.
- **WASM rebuilt + republished** (`wasm_golden` 8/8 bit-exact). The published
  artifact had predated the MONO fix, which audibly affects 14 factory patches.
- **Two stale-artifact holes closed:** no build rule depended on `src/*.h`, yet
  the constant TABLES live in headers — a coefficient edit touching only a header
  rebuilt NOTHING and every gate went green on the old constants. And
  `tools/verify/freshlib.py` now refuses a `libjuno.so` older than any engine
  source in the 13 port-side gates (teeth demonstrated both).
- **TRACK B (option C, the user's choice: Daisy + 8 voices + all FX, sonic
  identity instead of bit-exactness).** Substrate: `native/<x>.c` shadows
  `src/<x>.c` in `make juno_cand.so`; `native/voice_render.c` is a verbatim fork
  (passthrough null EXACTLY 0). **`src/` stays frozen and bit-exact — the two
  claims must never be conflated.** Four gates in `tools/trackb/`:
  `null_ab.py` (identity: 7 scenarios + 384 full-bank + 24 fuzz-with-param-edits;
  global RMS **and** worst-1024-block, both gating), `coverage_probe.py` (gcov:
  was it reached), `observability.py` (carriage + stored-value sensitivity),
  `canary.py` (**module admissibility** — plant 0.1% in each assignment).
- **The harness found five defects in ITSELF, all by being run:** (1) a
  multiplicative-only probe reported every at-rest-zero cell register-legal —
  cell 320 flipped to CARRIED once fixed; (2) an 11 MB context leak per render —
  OOM at 11.6 GB during the sweep; (3) the additive term `1e-20` does not survive
  the first multiply — the gate cell read NOT-CARRIED at every site with it and
  changed 83996/84000 samples with `+1.0`; (4) five of seven scenarios never
  RELEASED a note; (5) **gate #3 was over-claimed** — it cannot answer "would a
  wrong answer be noticed" (consumers read locals, and some SATURATE: ×3 on the
  gate cell changes nothing, +1 changes everything), so the claim is narrowed and
  `canary.py` answers module admissibility instead.
- **MEASURED, and the numbers to quote:** the −90 dB gate ignores errors up to
  ~200 ULP/sample (2 ULP lands at −129 dB); a tail-only 0.1% error is caught by
  the global metric in 5/7 scenarios and the block metric in **7/7**; the
  `noisegain` mutation is caught by 1 of 5 scenarios and **84 of 384** full-bank
  comparisons; carriage = **95 CARRIED / 188 NOT-CARRIED** of 283 written
  per-voice cells (`docs/trackb/CARRIAGE.tsv`, scenario-fingerprinted).
- **⚠ THE STANDING WARNING FOR THE NEXT SESSION:** the canary's first run, on M1b
  (`src/voice_render.c:1129-1149`), found **3 of 18 assignments observable, 15
  BLIND** — the whole Chamberlin noise SVF is invisible to the scenario set. NO
  MODULE MAY BE REWRITTEN BEHIND A BLIND GATE. Add scenarios that reach it first.
  Also unclosed from PLAN §6: F4 spectral, F6 branch coverage, F9 teeth over the
  bulk gates, F10 per-module mutations, F12 silent-count baseline, F15 ARM null,
  F16 optimization levels, F17 FTZ, F19 three-run determinism.
- **PLAN's own STOP rule S1 fires BEFORE any voice code is written:** if the P1
  silicon numbers show `F + 8V` fits the Teensy budget, or a bit-exact 4-voice
  Daisy is acceptable, Track B is abandoned in favour of fewer voices. There is
  still NO SILICON NUMBER.

**★★★★ (2026-07-31, embedded arc truth-up — read before trusting any
older embedded claim in this file):**
- **MONO retrigger latch FIXED (e611f7d):** the DCO retrigger latch (aux Array A,
  101504+v*32) arming is **MODE-DEPENDENT** — POLY note-on writes only inert
  Array B (101520); a MONO retrigger arms Array A. Port arms it in
  `mono_note_on`'s retrigger branch via `juno_note_retrig()`. Found by fuzz
  seed 15 (patch 15 BS VeloRez Bass, warm engine); invisible to every cold gate
  because juno_init arms Array A at BUILD. Fuzz 24/24 again; the old "never
  re-armed by note-on" comment in juno_note.c was measured on POLY only.
  **Plugin MONO law (PROVEN): last-note priority on press, LOWEST-held fallback
  on release.** ⚠ The published WASM artifact predates this fix (P0 item).
- **ARM/embedded PROVEN set:** golden corpus 8/8 bit-identical on ARM32 under
  qemu (`tools/embed/arm_golden.sh`); bare-metal M7 compile clean (373 KB text);
  expf glibc==newlib bit-identical over 32,000,423 inputs; whole audio path
  stack = 584 B; 32-bit pointer-width bug in master_render.c host-param chase
  FIXED (was x86-64-only `_QWORD` loads). `daisy/` firmware BUILDS AND LINKS
  (self-playing, E1–E5 instrumentation, bootloader-version guard); `teensy/`
  written but never compiled. Memory truth: voice = 10,512 B (+164 B shared
  noise), 8 voices = 86 KB; full-FX hot set ≈1.14 MB in a 10.5 MB span; chorus
  lives entirely in the low ~102 KB block.
- **Performance: NO SILICON NUMBER EXISTS.** x86 MEASURED 14,500 cyc/sample;
  M7 MODELED (llvm-mca, calibrated 2.15× on the x86 case) 30–42k; executed-path
  arithmetic says the honest band is **18–42k** (the model charges both sides of
  ~200 branches/voice). Daisy@480 budget 10,884 @44.1k → 1.7–4× over for
  8v+FX; **Teensy@816 (18,503) is ON THE BUBBLE**. Label discipline + standing
  rule "no optimization before a SILICON number" are in the roadmap.
- **Measured optimization levers (do not re-litigate):** block hoisting 2.8%
  (ceiling 17.4%), idle-voice skip 25.2%/silent voice but 0% at full polyphony
  (74.8% of voice arithmetic feeds next-sample state), triangle LUT ~11%
  STATIC, FTZ 2.4%. Scratch-cell story CORRECTED: the 202 scratch stores/voice
  are in **Roland's own binary** (Hex-Rays doesn't invent stores) — desktop
  OoO hides them, in-order M7 can't; elimination is legit (cells provably don't
  carry) but needs an AST tool, not regex (pilot 3 failed to parse; pilot 2 =
  13 single-typed cells committed, bit-exact, 0.6%). 155 cells are dual JF/JI-
  typed — typed locals CONVERT instead of REINTERPRET (pilot 1 broke 0/57).
- **⚠ STALE-ARTIFACT TRAP (bit twice in one day):** prebuilt `tests/test_*`
  binaries and a stale `libjuno.so` after a FAILED compile both produced false
  greens. Always fresh-build before trusting any --port gate run manually.

**⚑ prior LIVE WORK ORDER (2026-07-27, now the parallel DAW-parity track):
`docs/HOSTPATH_PARITY_SCOPE.md` — execute STEP 0→5 to the letter.**
User symptoms after the assigner fix (peaking unison first notes, other peaks,
"filter even quieter", more): S1/S2 levels are PROVEN the plugin's own (BS Glide
peak 1.981; Boost 21 / Output Gain 22 executed no-ops — `probes/assigner/
boost_dispatch.py`; wrapper output has NO gain stage, only a license-gated
demo bit-crusher at decomp_300000.c:27702). The browser was hard-clamping at
0 dBFS → webapp now has a MONITOR fader (delivery-only, default 0.45; the
DAW-fader role — engine untouched). The remaining surface is the WRAPPER
LIFECYCLE: SYSTEM defaults (Kbd Vel SW still INFERRED; Velocity Curve/Offset/
Fixed Velocity never derived), the event→MIDI→queue note path, and setState —
all specced with anchors in the scope doc. STEP 0 = finish `make verify`
(references regenerating post-assigner-fix; resumable, restart on container
death; 0 failures so far).

**★★★ NEWEST (2026-07-27, Opus 5) — THE "STILL SOUNDS WRONG" ROOT CAUSE IS FOUND
AND FIXED: the plugin's voice allocator never learned KEY ASSIGN. Read
`docs/ASSIGNER_MODE_FINDING.md` (probes in `probes/assigner/`).**
`CAssignJu60` caches ASSIGN MODE (param 800) at `assigner+16` and LEGATO (799) at
`assigner+20`. The ONLY writer is `sub_7FF91DFB49B0(assigner, 4)`, and the ONLY
caller of that is the engine's HOST parameter entry `sub_7FF91E027AE0`, which after
EVERY parameter write does, per unit: `proc[u]->+88(idx,0,v)` **and then**
`assign[u]->+8(4)`. Our recall made the first call and never the second, so under
the oracle the plugin's own allocator sat in **POLY for every patch**. An earlier
A/B measured the port against that oracle, concluded "all three KEY ASSIGN values
are polyphonic", and hard-forced `assign_mode = 0` / `legato = 0` in the bridge —
**oracle and port were then wrong together, so every render A/B was comparing two
copies of the same mistake.** (Exactly the user's own hypothesis: "if the issue is
truly invisible, there is something wrong with our tests.")
- PROVEN: assigner vptr rva `0x969740`, slot 1 (+8) = `0x3549B0` (`laneX_slot8.py`);
  after our recall the fields are (0,0) on all 9 units for every patch, after the
  plugin's own refresh BS Solid = mode 2, LD Classic Lead = mode 1
  (`laneX_mode_field.py`); notify-once == the host's notify-per-write, 0 differing
  cells over all 9 × 0xA83010 (`laneX_notify_placement.py`).
- **Audio impact, plugin vs ITSELF** (`laneX_audio_impact.py`, refresh the only
  difference): Chillwave 3 **BS Solid +16.65 dB**, Chillwave 4 **BS Glide
  +17.43 dB**, Chillwave 30 +7.61 dB, factory 61 +13.05 dB — ~every sample
  differing. Factory 5 (MONO) is level-neutral but every sample differs (voice 0 vs
  the port's voice 7 → different CONDITION scatter — the per-patch, bidirectional
  timbre shift #124's bounce locator kept reporting). Factory 0 (ASSIGN 0) is
  **bit-identical**: the non-vacuity control.
- Scope: **16/64 factory patches** (14 MONO, 2 UNISON) plus much of the Chillwave
  bank were played in the wrong voice-assign mode by the port AND by every gate.
- Fix: `e2e_emu.assigner_notify()` (the plugin's own 0x3549B0 on all 9 units);
  `prepare_recall` calls it, so render A/B, `fuzz_diff` and `renderstruct_ab` now
  drive a plugin in the patch's real mode; the bridge's two overrides are removed
  (the MONO/UNISON code in `docs/VOICE_MODES.md` was already correct — only
  switched off); new gate `tools/verify/assigner_ab.py` in `make verify` drives
  NOTE SEQUENCES (a single note cannot tell POLY from MONO — which is why the old
  single-note A/B "proved" the wrong thing) through both allocators.
- Post-fix the port reproduces the plugin's own RMS to 5 decimals on every mode:
  F0 0.07770, F5 0.03268, F61 0.10803, CW3 0.65162, CW4 1.12641, CW30 0.16745.
- **METHODOLOGY (add to `docs/P112_FINDINGS.md` §8): never validate a hand-written
  component against an oracle in which the plugin component it replaces was never
  reachable.** Before concluding "the plugin does X", check that the plugin's own
  code for *not*-X could have run in the harness at all.
- Also mapped (no gap): the host entry special-routes idx 831-835 (ARPEGGIO
  SW/TYPE/STEP, SCATTER TYPE/DEPTH) and 756 to the arpeggiator object at
  `HOST+136+64u` instead of the dispatch, and applies host-write-only value
  transforms to idx 20/22/665/707/769/871. The port implements the arp separately
  (`carp.c`, bit-exact 7/7) and correctly does not apply the host-only transforms
  on preset recall.

**★★ (2026-07-27, Opus 5) — RENDER_LOOP_SCOPE EXECUTED; THE RENDER LOOP IS
EXONERATED. Read `docs/RENDER_LOOP_LOG.md` (probes in `probes/render_loop/`).**
The real per-block render was derived from the binary and every hand-written
assumption was checked by execution. Findings, all PROVEN unless noted:
- Real structure = `0x3C7400` (per-block) + work item `0x3C6F00`; item i base =
  `ENGINE+1152+128*i`, `item+24 == state[i]`. Voices render whole-block via pool
  items → barrier → master runs PER SAMPLE from `*(ENGINE+592)` **== state[8]**.
  That IS what `e2e_emu.render()` does. `sub_7FF91DFB5AB0` really is just
  `*(assign+168) += n` (the oracle's hand-written bump is exact).
- The ONE extra thing the plugin does — a **voice-0-only per-sample call**
  (engine vtable slot13, rva `0x3C7230`) — is a **front-panel LED meter**: zero
  writes inside any of the 9 unit states (4096+256 executed calls, write hooks
  over all 9×12 MB), read path pure-load by construction, and its accumulator
  (`ENGINE+1040..1060`) is touched by exactly 2 functions in the whole binary,
  neither in the audio path. Correctly omitted.
- `*(ENGINE+56)` (numVoices) is **always 8** (sole engine factory `0x3C6790`);
  the only other writer needs a paramID occurring exactly once in the binary (its
  own compare immediate) → unreachable. Rendering all 8 voices is correct.
- Master ABI: `a2[2i]=MAIN_i`, `a2[2i+1]=SUB_i`, voice order 0..7; the master
  reads **only even slots** — forcing all SUB buffers to 1e20 leaves output
  bit-identical, which validates the port's `a2[odd]=&scratch`. Ordering
  controls prove the null result is non-vacuous.
- **Noise policy EXONERATED** (the "more noise oscillator" suspect): the 164-byte
  block at `state+84272` is byte-identical across units 0..7 at 6 checkpoints ×
  5 scenarios (0/1/4 notes, CONDITION 40/220) while a note plays; the LFSR is
  closed and autonomous; `master_render.c` reads NO cell in [84272,84436). The
  port's snapshot/restore is provably equivalent to 9 isolated units.
- **Block size is irrelevant**: bit-exact at 600/512/256/128/64/**1**.
- Also closed this scope: the **Chillwave (user's own) bank decode** PROVEN via
  the plugin's own record parser (64/64 verbatim, 0 leaf mismatches — a hole no
  gate could see); the **position map** validated non-circularly against the
  plugin's declared ranges (14335/14336, the one outlier is a signed leaf the
  port already handles); the port's **BINDINGS table 31/31 correct** vs the
  plugin's own name table; **full-state recall identical over the WHOLE
  0xA83010 × 9 units** for BS Solid (the earlier diff covered only unit-0's
  first 10512 bytes — FX/master was never compared until now); the **webapp's
  real lifecycle** (idle → apply-on-running-engine → idle → note) bit-exact;
  and **task #134 CLOSED** — the EFFECT-TYPE activation second stage changes
  ZERO cells after recall (no gap).
- **NEW REQUIRED GATE** `tools/verify/renderstruct_ab.py` in `make verify`:
  locks block-size invariance + the warm apply-on-a-running-engine lifecycle
  (22/22 bit-exact). Those two surfaces were previously ungated.
- **Webapp fidelity fix:** the velocity default was reverted to the plugin's own
  (Kbd Vel SW **OFF** → every note forced to velocity 100). It had been set to
  SW ON + 127 "for A/B testing", which guarantees a mismatch against a DAW
  instance on any velocity-sensitive patch.
- **Independent confirmation the port recalls the right values:** reading the
  plugin's own name table, BS Solid decodes to `DCO SUB LEVEL = 83` and
  `VCF CUTOFF FREQ = 15` — exactly the two numbers the user read off their real
  plugin's front panel. (Also corrects long-standing label errors in this repo's
  notes: 770 is DCO PWM LEVEL, not SAW; VCF ENV MOD is 783, not 780.)
- **The single remaining unexecuted link in the entire chain** is the
  record-byte ↔ parameter POSITION MAP (Script.xml document order). It is
  validated but not executed; executing it needs the controller preset path,
  which is walled by the CRT/thread-pool issue (`docs/FINAL_SCOPE_LOG.md`). The
  engine-side value getter is a `return 0;` stub (`0x3B6C30`), so the recall
  enumerator cannot be used to read values back.

**★ NEWEST (2026-07-27) — RECALL COMPLETENESS PROVEN; BS Solid hunt narrowed to
the RENDER LOOP STRUCTURE. Read `docs/ENUM_HUNT_STATUS.md` first (probes in
`probes/enum_hunt/`, full 5-lane reports in LANE_REPORTS.md).** Headlines: the
plugin's recall enumerator (0x3B48A0) fires 165 indices vs the port's 129, BUT a
full-state A/B (enum-order 165-idx recall vs port recall, identical per-patch
values) = **0 differing cells** on 15 factory + 4 Chillwave patches incl. BS
Solid; every dropped index is a SYSTEM/live-runtime param (Note/Gate/Mute
per-voice bus 433-474, MIDI CCs 493/495/498, MASTER TUNE 20, scale 128-141,
PERFORM 614+, GUI switches 553-555, redundant H float twins 878/1029 — proven
bit-identical to the byte setters) that is identity at its descriptor default,
and Script.xml only produces dispatch >= 748 so preset load feeds them defaults.
The connect path (0x320420) pushes ONLY Keyboard-Velocity-SW + transport; Boost
Mode/Output Gain write ZERO engine cells; CONDITION = per-patch idx 856, already
applied. → **Recall/preset/settings are EXONERATED for the BS Solid mid-band
deficit.** One real generalization gap found (not the bug — identity in all 128
known patches, BS Solid is TYPE 0): DELAY TAP TIME 1178 is DELAY-TYPE-1-gated,
writes 4297792 = f32(trunc(255*byte/100)/255), record byte 3056 (INFERRED);
port freezes tap=50 in delay_recall.c DLY1_B — wire when convenient. **PRIME
SUSPECT NOW: the hand-written render loop structure** — e2e_emu.render() and
juno_driver.c agree with each other by construction (shared blind spot): the
real per-block DSP under the pool (0x3C7400) — voice order, host block sizes
(64-512 vs oracle's 600), and the shared analog-noise block (84272..84436)
snapshot/restore policy — was never derived from the binary. User's ear ("more
noise oscillator" in the real plugin) matches a noise-block-policy difference.
NEXT: derive the real per-block structure from 0x3C7400 + pool work items,
re-express the oracle to match, re-run render A/B. **THE BINDING PLAN FOR THIS
IS `docs/RENDER_LOOP_SCOPE.md` (STEP 0-6 + Exit Test, written for Opus 5 to
execute to the letter) — it supersedes the NEXT sentence above and is the live
work order.**

**Read `GOAL.md` first — it is the user's own statement of the goal and is binding.**
Short form: a bit-exact C99 port of the Roland Cloud JUNO-60 (JU-06A) VST3 DSP that
sounds EXACTLY like the original, playable in the browser (WASM), portable to a
Teensy 4.1 later. The shipped engine is plain portable C99 — emulation is an
analysis tool only; nothing emulated may be required at runtime. Recall must be
correct for ANY preset value, not just the factory bank's ("this byte is 0 in every
factory patch" is not an excuse to skip it).

**LIVE WORK ORDER: `AIRTIGHT_PLAN.md` § "WORK ORDER — Fable 5 → Opus 4.8"**
(W0→W6, binding). Execute in order. **W0 DONE (2026-07-22):** the fine-FX proof
was single-context; `finefx_multictx_probe.py` + `finefx_fullctx_audit.py` (sweep
every leaf × DELAY TYPE 0..5 / REVERB TYPE / EFFECT TYPE) found the DELAY fine-FX
are slot-1-routing-dependent — TYPE 1 → 2nd instance 4297xxx, TYPE 5 → slot-1-
reverb 6497xxx (delay) + 10693xxx (chorus), TYPE 4 → no cells; chorus DT2≡DT3,
reverb RT/ET context-independent. All wired (`juno_apply_delay_finefx_2nd` /
`_slot1rev`, `juno_apply_chorus_finefx_slot1rev`), identity at default (factory
unchanged), and the Pillar-3 gate is now CONTEXT-AWARE. **W1 DONE (2026-07-22):**
REVERB PRE DELAY (1323) shifts the reverb tap array (33 ints 11022212..340)
uniformly by predelay(byte)-predelay(20) + writes master predelay cell 10759360,
predelay = max((byte·Hr)/1000-2, 0) — executed per byte × 4 rates × 3 REVERB TYPE
classes (idx 876=TYPE, not 877=TIME), wired in `reverb_recall.c`
(`juno_write_reverb_taps_pd`), identity at default byte 20. Pillar-3 now
**192512 comparisons over 9 contexts × 14 leaves × 4 rates, 0 mismatch**;
COVERAGE 1323 GAP→APPLIED. **W2 DONE:** EFFECT TYPE modes 2/3 proven no-gap;
mode-4 (FLANGER) structural block wired. **W3-STRUCT + GATE DONE:** the
synthetic-ET-mode A/B gate (`etmode_ab.py`, in make verify) proves the port's
EFFECT TYPE 0..5 recall == plugin (864 cells 0 mismatch); also fixed a real
stale-libjuno hole (make verify now has libjuno.so as a prerequisite). **Every
engine-dispatchable gap is closed → GAP=0** (see the SEAL CLOSED note directly
below). The 8 remaining rows (7 FLANGER param leaves 1242-1248 + Patch Tempo 1118)
are NOT GAPs but `DEFERRED-CONTROLLER`: they are controller-path only (engine
value-tree 0x3B9A30 is a proven no-op for them — 0→200 full-state sweep +
leaf-table absence + the executed `deferred_noop_gate.py`), so reaching them needs
the **#112 controller lifecycle (W4)**, the documented hard problem (the work order
says do NOT fight the threaded process() loop). #112 is OPTIONAL — the binding
finish line is already met (SEAL note below); W4/W5/W6 are CLOSED.

**★ SEAL CLOSED / STAGE-D SEALED (2026-07-23, Fable-5-directed truth-up).** The
8 residual rows are NOT GAPs — a GAP is an *engine-reachable* param the port fails
to apply, and these are not engine-reachable (dispatch is a proven no-op; FLANGER
needs the effect mode-4 *activation* recall never performs; Patch Tempo is a true
no-op). Reclassified `DEFERRED-CONTROLLER` in COVERAGE.tsv (named, bounded, listed
by the gate every run — the charter's honest-residual standard). **GAP=0**;
`completeness_gate.py` is folded INTO `make verify` and GREEN (APPLIED 129 |
INERT-PROVEN 132 | DEFERRED-CONTROLLER 8). **SEAL conditions 1-6 are GREEN in
`make verify`;** condition 7 (user-bounce anchor) is covenant-diagnostic-only and
host-lifecycle-pinned (#112/#124, measured this session: BIT-EXACT vs the plugin's
own recall+render yet ~12% off the DAW bounce → host-lifecycle, not an engine
defect). **The binding definition of done — `make verify` green + PROVENANCE zero
non-PROVEN — is MET.** The sole remaining work is the OPTIONAL #112 VST3 lifecycle
(fully specified in `docs/P112_ROADMAP.md`): it would flip the 8
DEFERRED-CONTROLLER rows to APPLIED (also needs a flanger DSP render the port
lacks — zero factory-patch benefit) and enable condition-3-primary + condition-7.
Not required for completion. W4/W5/W6 are CLOSED (fallback sealed); only the
optional #112 refinement remains. **#112 progress this session** (all committed):
both VST3 components construct under Unicorn (proc_create.py / ctrl_create.py); the
FLANGER param law is derived + validated via the plugin's own effect-type activation
setter + FlSt setters (scratchpad/flanger_*.py) — the piece prior attempts never
reached — but wiring it needs the flanger DSP render (P112_ROADMAP.md).

**W5 FALLBACK + W6-item-2 DONE (2026-07-23):** the **differential fuzz is now
SEALED into `make verify`** (`fuzz_diff.py`, SEAL condition 4 / Pillar-2b). It is
rebuilt into a two-process `--ref`/`--port` gate (it previously violated the
two-process rule by building a Unicorn E2E instance AND ctypes-loading libjuno in
one process) that drives seeded RANDOM polyphonic sequences into both the plugin
(Unicorn) and the port: **24 seeds × 3 rates × 20 patches, ~500k samples, 0
diverged** — the synthesis whole (8-voice alloc+steal, note lifecycle, release
tails, per-patch FX, block-boundary renders) is bit-exact over random sequences,
a surface no other gate exercises. Two harness fixes it forced: the oracle now
starts from the proven-complete recall (`recall_render_ab.prepare_recall`, factored
out; the old enumerator-only recall omitted velocity-sens/FX/fine-FX so every seed
diverged for a non-port reason), and arp patches are drawn out (their tempo-sync
stepping has dedicated gates). Scope: live param-edits are excluded — a fresh edit
of every param at every byte is bit-exact and the per-byte value laws are proven by
recall_exhaustive + finefx_pillar3; the only residual is a live edit landing on an
in-flight smoother (the documented ~1-ULP Phase-4 warm class), not a value defect
(`scratchpad/param_probe_*`). This completes the Pillar-2 fallback; the setState
primary (W5) + GAP=0 (W6-item-4) + bounce anchor stay #112-gated.

**★ #112 EXECUTED (2026-07-24) — the VST3 host path is now mapped, gated, and
partly ported. Full detail in `docs/P112_FINDINGS.md`; it SUPERSEDES the mapping
half of `docs/P112_ROADMAP.md`.** Headlines:
- **The roadmap's VST3 vtable map was MISALIGNED** (it labelled the IAudioProcessor
  vtable with IComponent names and ran off its end into the RTTI pointer). Resolved
  at runtime via the object's own `queryInterface`: IComponent = class+48 (vt rva
  0x967af0), IAudioProcessor = class+272 (vt 0x967b68), `createInstance` returns the
  IAudioProcessor pointer so class base = p-272. **RETRACTED: "IComponent::setState
  is a bare-ret no-op"** — that read the wrong vtable; the real setState is 0x34aaa0
  and is a full IBStream implementation (getState 0x349ea0 is its inverse).
- **RETRACTED: "process() spins in the thread pool".** `process()` = 0x34A380 does
  the entire event->MIDI and param->queue intake ON THE CALLING THREAD and calls the
  queue consumer 0x320B20 directly; it never calls 0x3C7400 at all. The pool is only
  under the DSP render, which `e2e_emu.render()` already replaces. **The param/MIDI
  half of the host lifecycle never needed the pool.**
- **The host param entry is the ENGINE vtable +112 = 0x3C7AE0.** It maps VST3
  paramID -> internal index, applies per-index value transforms, range-checks against
  the descriptor table (rva 0x98c040 + 16*idx) and dispatches
  `0x3B9A30(proc[u], idx, flag=0, v)` on all 9 units. The plugin's OWN recall
  enumerator 0x3B48A0 dispatches the same function with **flag=1** — which is exactly
  what the port and every existing gate drive, so **the recall path is confirmed
  faithful a second time, from the host side.**
- **The flag is a ROLE selector, not ramp-vs-immediate** (0x3B9A30 forwards it to
  each leaf setter as that setter's own 2nd argument).
- **NEW SURFACE FOUND AND PORTED — the live MODULATION layer.** Indices 312..317 are
  no-ops under recall and, under the host role, lay a signed percentage offset over a
  front-panel parameter's recalled base: VCF CUTOFF (779), HPF CUTOFF (782), VCF
  RESONANCE (781), DCO PWM DEPTH (758), PORTAMENTO (798), EFFECT DEPTH (794). Law
  `out = base + off*(off>0 ? 255-base : base)/100` (trunc toward 0; paramDB range
  {-100,100}). `src/juno_mod.c` + `juno_gui_set_mod`; **PROVEN exhaustively** —
  308736 comparisons (6 slots x every base byte x every offset), 0 mismatch. Identity
  at off==0, so no factory patch or existing gate is affected.
- **Two new gates in `make verify`:** `hostpath_roles.py` re-derives from the binary
  every run WHICH indices differ between the two roles and locks it to exactly those
  six; `hostmod_gate.py` proves the port's law against the plugin's own setters.
- **The 8 DEFERRED-CONTROLLER rows survive the host path too** (EFFECT TYPE=4 leaves
  every effect object's mode at 0 and never calls 0x3B93E0 under either role), so the
  seal's honest-residual accounting is unchanged.
- **Still open (honest):** the wrapper's own engine is not constructible under
  emulation — `IComponent::initialize` reaches the engine factory, which trips a CRT
  invalid-parameter inside a magic-static string parse (a TEB/TLS emulation artefact);
  neutralising that lets it continue but it faults at rva 0x284c04. The paramID->index
  map (rva 0xCB0E18) is NULL after build/proc-create/ctrl-create, so host param IDs
  cannot be enumerated yet. Neither blocks the above, because the wrapper's entire
  contribution to engine state is the enumerated engine-vtable calls, all of which are
  the plugin's own code and directly callable.
- **METHODOLOGY WARNING (read before any new differential over this engine):** four
  separate protocol errors each produced a large, tidy-looking set of false
  divergences — partial state restore (proc/assign caches leak between probes),
  dispatching without writing the descriptor DB[idx].value, probing outside the
  index's own paramDB range, and baselining on a pristine engine instead of a
  recalled patch. See `docs/P112_FINDINGS.md` §8.

## The one rule everything else serves

**The original `.vst3` is the ONLY ground truth.** The port must be SELF-PROVING:
every coefficient proven bit-exact against the plugin's own machine code, executed
under Unicorn. Never validate by ear, never ask the user to A/B — that is a
"capture" and is forbidden. "Done" = `make verify` green, i.e. zero non-PROVEN rows
in `PROVENANCE.tsv` (the status authority; it supersedes GOAL.md's pointer to
`docs/AUDIBLE_RECALL_PLAN.md` and every prose doc).

## Hard rules (violating any of these corrupts the project)

- **THE DIAGNOSTIC-CAPTURE COVENANT (user-granted 2026-07-17, THE MOST IMPORTANT
  RULE).** The user provided DAW bounces of the real plugin (Ableton Live 12.0,
  120 BPM, 44100 Hz, first 8 presets of bank 1, one note vel 100, 0.5 s silence +
  2 s note + 1.5 s tail; session copies in `scratchpad/diag_bounces/presetN.wav`).
  These are **DIAGNOSTIC USE ONLY** — the only captures this project will ever
  receive, granted under that explicit condition:
  - NEVER derive, copy, fit, or tune ANY coefficient, table, or constant from them.
  - NEVER use them as a gate reference or as ledger provenance. PROVEN continues to
    mean "the plugin's machine code executed under Unicorn" — nothing else.
  - Their ONLY permitted roles: (1) locating WHERE the harness's driving of the
    plugin diverges from a real host's, and (2) the completion test for that
    harness investigation. Every fact they point to must then be re-derived by
    executing the binary (e.g., controller defaults read from the controller's own
    init code) before it may enter the port or the ledger.
  - Never commit them to git. If they leak into a coefficient's history, that
    coefficient is CAPTURED and must be replaced.

- **Ground truth = the plugin binary executed under Unicorn.** Running its machine
  code is allowed and is NOT a capture. Reading the plugin's own `Script.xml`
  (in `truth/`) is allowed plugin data.
- **NEVER open, read, or reference files named `user_patch5_ableton.json` or
  `captured_coeffs.json`** — anywhere, ever, including in subagent/workflow prompts.
  They are runtime captures; reading one risks contaminating a coefficient with a
  value not derived from the plugin. If such a file appears, delete it by name
  without reading it. (The rule stands even while no such file exists.)
- **No captures as data.** No Frida dumps or runtime snapshots feeding the port.
  A constant whose provenance is a capture is a bug to be replaced (ledger status
  CAPTURED).
- **Two-process rule:** never build a Unicorn E2E instance AND ctypes-load
  `libjuno.so` in the same Python process. Oracle and port runs are separate
  processes; they meet only through pickles.
- **Harness = plumbing only.** Emulation harnesses may set up memory, stub
  Win32/COM/CRT/ABI, hook istream reads, wire registers, and observe. They may
  NEVER reimplement plugin logic (no hand blob→param map, no hand value transform,
  no reconstructed recall table used as ground truth).
- **Label every claim** PROVEN(executed) / READ(static decomp or Script.xml) /
  INFERRED. No over-claiming, ever.

## Ground truth & paths

`truth/` holds `JUNO60.vst3`, `Script.xml`, `presetbankog1.bin`, `SHA256SUMS`
(checksum-verified). Resolve paths ONLY through `tools/verify/truth.py`
(`truth.VST3 / .SCRIPT_XML / .BANK`, `$JUNO_TRUTH` override, `verify()`/`require()`).
Never hardcode an uploads/absolute path — those die with the container.
`refs/allcode_decomp.tgz` is the full IDA decompile (provenance for RECONSTRUCTED
rows). Git history was rewritten 2026-07 to purge RE dumps — never restore them
from an old clone.

## Build & verify

- `make libjuno.so` — the engine (GUI + ctypes gates load this).
- `make test` — functional suite (unit battery: self-consistency + frozen-recording
  checks; it does NOT compare against the live plugin).
- `make verify` — the finish line: `test` + the LIVE plugin comparisons (recall_gate
  67-cell diff + full render A/B, both actually executed every run; reference
  pickles auto-regenerate from truth/ when the scratchpad is fresh) + the
  provenance ledger check + the completeness scan (every constant-bearing source
  file must be claimed by a ledger row's `sources` column — the net that catches
  MISSING rows, which is how the delay-feedback capture survived). RED while any
  gate fails or any CAPTURED/RECONSTRUCTED/UNVERIFIED row remains.
- `bash gui/web/build.sh` — WASM rebuild (emsdk); `node tools/verify/wasm_golden.mjs`
  proves WASM == native.
- `-ffp-contract=off` is load-bearing (reference is x86 SSE2, no FMA); the FMA
  canary test fails loudly if contraction slips in.

## Canonical gates (tools/verify/)

`truth.py` (paths/checksums) · `e2e_emu.py` (the Unicorn oracle) ·
`real_bank_parse.py`/`real_recall.py` (plugin's own parser + recall) ·
`plugin_recall_set.py` (plugin's own recall enumerator, rva 0x3B48A0) ·
`plugin_recall_ref.py` (self-proven recall reference) · `recall_gate.py`
(port vs plugin recall, 67/67 voice cells, 64 patches) · `recall_exhaustive_ref.py`
+ `recall_exhaustive_gate.py` (recall EXHAUSTED: every single-input front-panel cell
vs the plugin's setter over all 256 byte values x 3 rates; multi-input product/joint
cells deferred to recall_gate + formula tests) · `recall_render_ab.py`
(render A/B vs the plugin's own recall+render — the ONLY reliable FX gate, because
FX state is prepare/render-populated and cannot be gated from a cold apply_bank) ·
`gen_teensy_golden.py`/`wasm_golden.mjs` (Teensy/WASM reproducibility) ·
`provenance_check.py` (ledger linter) · `completeness_scan.py` (constants→ledger
attribution net; also audit-trails positive "captur*" comment mentions).

## Known open work (live list = PROVENANCE.tsv)

- **Render A/B: ALL 64 factory patches BIT-EXACT.** 57 non-arp (recall_render_ab)
  + 7 arp via two dedicated gates in `make verify` (recall_render_ab's oracle can't
  arpeggiate — no transport clock):
  - **arp SCHEDULE: PROVEN 7/7** — `arp_sched_ab.py` drives the plugin's OWN arp under
    emulation (recall + controller-method enable + transport ticks, assigner hooked)
    and diffs vs carp.c. Closed #96: the plugin's per-beat re-latch re-quantizes the
    step grid to the beat once per enable (commit 527398e).
  - **arp RENDER: PROVEN 7/7** — `arp_render_ab.py` replays the proven schedule into
    the plugin's render. The former [1,33,41] divergence's root cause (PROVEN,
    b2_statediff/b2_bcast2: the plugin's note events broadcast the "any key held"
    flag — cell 1856, = held-count>0 — to ALL 8 voices; the port set it only on the
    allocated voice, so an idle voice's free-run state diverged and the arp gating it
    inherited the seed) is FIXED by `juno_note_broadcast_held()` called from the
    assigner-level note paths (synth_note_on/off + bank-apply flush). Layout note:
    plugin voice v renders at state[v]+v*10512, NOT state[v]+0.
- **init/prepare constants: PROVEN** (`coldstate_ab.py`, LIVE GATE 6/7). The port's
  power-on state (init + prepare + chorus_init) is bit-identical to the plugin's own
  constructor + setSampleRate under Unicorn at 44100/48000/88200/96000/192000 — only
  the benign C++ header (<176, audio-inert) + 6 FX-recall-default cells (self-proved
  inert) differ. Retired the live-state-dump cross-check (the last capture). Caught +
  fixed 5 real 44100-only reconstruction bugs (102656 spurious rate-case; 4 Rev Ecf
  DPF Fc missing the 44100 arm) the single-rate live dump never exercised.
- **other host sample rates: PROVEN.** cold-state bit-exact at 88200/192000;
  recall PROVEN (exhaustive 624 + HPF 10240 exact multiply-first law — audit
  re-derived it independently and confirmed bit-exact at 60000 Hz too, 6144
  comparisons 0 mismatch); render is rate-agnostic (grep-verified: no state[16]
  read in voice/master render) and LIVE GATE 7/7 runs the full 57-patch render
  A/B at BOTH 44100 and 88200 — both BIT-EXACT 57/57 (44.1k added post-audit:
  it closed the one coverage gap, no render gate at the most common host rate).
- **PROVENANCE.tsv is 20/20 PROVEN** — zero RECONSTRUCTED/CAPTURED/UNVERIFIED
  (grew from 17 with the fine-FX + REVERB PRE DELAY rows). The binding finish line
  (`make verify` green = zero non-PROVEN rows) is met.
- **WARM (DAW-idled) parity: PROVEN for the driving tested.** Warm A/B = build →
  72000 idle samples → recall → note → 24000 render, BIT-EXACT (chillwave patch 3
  "BS Solid", the user-reported case; scratchpad warm_ab_p3.py). Root causes (both
  invisible to every cold gate):
  1. **Power-on slot-2 routing**: the plugin boots with EFFECT routing v551=2
     (chorus I) — read from its own params chase AND its state cell 11022052
     (= Prog_ID_EFX, the cell its EFFECT TYPE setter writes clamp(v,≤5) into,
     proven all 256 values). Its master therefore FREE-RUNS the v551∈2..4 chorus
     arm (LFO 90624.., BBD ring 95824..) from power-on. The port seeded 0 (Pan
     arm, silent-input = frozen state) → every chorus patch diverged warm. Fixed:
     JUNO_PROG_EFX moved 11022060→11022052 (the plugin's own cell), power-on
     default 2 written by juno_engine_prepare, 11022052 REMOVED from
     coldstate_ab's exclusion (gate strengthened).
  2. **Warm apply clobbered per-voice runtime**: patch LOAD did a full
     seed_voices block copy; the plugin's recall writes coefficient cells only.
     After idle, per-voice smoother runtime (rel 3344/3360/4640/4752/5296/5312 —
     outputs converged onto the per-voice CONDITION targets) is voice-distinct;
     the copy falsified voices 1..7, and a warm note lands on a rotation voice
     (not voice 0 — cold gates never see this). Fixed: ctx_recall LOADs now use
     the same changed-bytes delta replication as live edits.
  **Unit-mapping facts (per-unit diff harness = scratchpad idle_units.py):** the
  oracle renders voice v from unit v and the MASTER from unit 8 (e2e_emu.render);
  unit-0's master region is idle-dead. The aux one-shot array 101504+v*32 is
  per-VOICE state (compare vs unit v; unit 8's copies are dead 1.0s). Post-fix
  the idle-72000 per-unit diff is: voices 0/8 + noise + aux EXACT; master vs
  unit 8 differs ONLY in the 5 still-excluded FX-recall-default cells (known
  inert) — and warm note allocation lands on the same voice both sides.
- WASM artifacts REBUILT + verified: `gui/web/build.sh` (now with `-ffp-contract=off`)
  regenerates `gui/web` + `docs` from current source; `wasm_golden.mjs` proves the
  delivered WASM is bit-exact to native (8/8) on the 44.1 kHz golden corpus. emsdk
  lives at `scratchpad/emsdk` (source `emsdk_env.sh` before building).

## Host-lifecycle fidelity (user "still sounds wrong" arc, 2026-07-20)

- **THE GATES' STRUCTURAL BLIND SPOT (the lesson of this arc):** every gate
  compares port vs the plugin driven by OUR harness entries (recall dispatch +
  engine NOTEON). A real host enters through the VST3 wrapper (events→MIDI→
  queue→engine), and that layer TRANSFORMS the input. Port==oracle can be green
  while both differ from the real thing. Treat any user ear report that
  survives green gates as evidence against the gates.
- **Wrapper velocity policy (Stage 1, FIXED in port):** the wrapper's MIDI layer
  applies SYSTEM "fm.SYSTEM.COM.Keyboard Velocity SW" (flag byte queue+572,
  refreshed from the settings object in the connect path rva 0x320420). READ —
  three decomp sites with the identical rule (0x31F4E0 queue push, 0x3208E0
  all-sound-off injector, 0x320A30 connect forwarder): note-on vel 0 → becomes
  note-off(64); SW OFF → every note-on vel := 100, note-off vel := 64; SW ON →
  raw. So the real plugin by default IGNORES played velocity (JUNO-60-faithful)
  while the port passed it raw — audible on EVERY patch when playing live
  (velocity scales VCF+VCA). Port now mirrors the layering: engine entry
  juno_gui_note_on stays RAW (gates drive it, = oracle NOTEON); new wrapper
  entries juno_gui_midi_note_on/off + juno_gui_set_kbd_velocity carry the
  policy; webapp keys + Web MIDI use the wrapper path with a Kbd Vel SW toggle
  (default OFF = force 100). Default OFF is INFERRED (settings-object default
  needs the full wrapper lifecycle, #112); the policy itself is READ.
  Event→MIDI vel byte = trunc(velF*127.0)&0x7F (wrapper preamble 0x34A380).
- **Bounce locator (covenant role 1; scratchpad bounce_locator.py + session
  diag_bounces/):** port vs the user's 8 factory-preset Ableton bounces at the
  session's exact driving (44.1k/120BPM/vel100/0.5+2+1.5s). Pitch, onset,
  sustain RMS match. Brightness delta is PER-PATCH and BIDIRECTIONAL (centroid:
  p5 +2%, p1 +1%, p0 −9%, p3 −7%, p4 −10%, p6 −21%, p2 −24%, p7 −27%), levels
  move both ways — NOT a global tilt, NOT velocity (rules out any single
  controller-global setting). Signature of PER-PATCH recalled coefficients.
  - **RE-MEASURED 2026-07-23 (W5 diagnostic, fine-FX now live; `scratchpad/
    bounce_relocate.py`, role 1 ONLY — nothing tuned):** centroid Δ now p0 +2%,
    p1 +1%, p2 −22%, p3 −12%, p4 −16%, p5 +6%, p6 −15%, p7 −23% (mean |Δ| 12.6%
    →12.0%). The DELAY HIGH-CUT fine-FX fix moved individual patches (p0 −9→+2,
    p6 −21→−15, p7 −27→−23) but did NOT systematically close the gap. KEY: the
    port is now BIT-EXACT vs the plugin's own recall+render (57/57 sealed) on
    these very patches, yet still ~12% off the DAW bounce — so the residual is
    NOT an engine-recall defect; it is host-lifecycle-pinned (#112/#124), exactly
    the structural blind spot below. Closing it needs the wrapper lifecycle, not
    another coefficient.
- **STAGE 2 ROOT CAUSE — FOUND (2026-07-21), the fine-FX filter blind spot:**
  the fine delay/chorus/reverb FILTER params (HIGH CUT, LOW CUT, PRE DELAY,
  LF/HF DAMP — dispatch idx 1180/1182/1184/1210/1211/1212/1323..1326) are
  **NOT in the recall reference's leaf table** (real_recall.leaf_table →
  in_recall=False for all of them). So the ORACLE never applies them either →
  port==oracle (render A/B stays GREEN) while BOTH leave these wet-signal
  high-cut/low-cut coefficient cells at chorus_init's power-on ZERO. The REAL
  plugin driven by a host DOES apply them (they are real, dispatchable setter
  leaves that move FX-filter cells — proven by ext_sweeps sweeps). A wet-path
  HIGH CUT stuck at 0 vs the patch's real value shifts brightness per-patch in
  either direction — exactly the bounce pattern (worst on p2/p6, both DELAY
  HIGH CUT=3; darkest p7 = the lone EFFECT TYPE 5). This is #116 promoted from
  "nice to have" to THE Stage-2 fix. The setter laws are already largely
  derived in scratchpad/ext_sweeps.pkl: DELAY HIGH CUT (cells 6497184..6497312),
  CHORUS HIGH CUT (10693072..10693200), CHORUS LOW CUT (10693216/232), CHORUS
  PRE DELAY (10693008), DELAY LF/HF DAMP (+FREQ) (6497424..6497488), REVERB PRE
  DELAY. REVERB LOW/HIGH CUT/DENSITY setters returned no cells in the patch-5
  context — need re-derivation in a reverb-active context. FIX PLAN: derive the
  remaining laws by executing each leaf's setter, apply them in recall
  (new fine-FX applier), and EXTEND the recall reference + render A/B to include
  these leaves so the gate itself catches the darkness (closes the blind spot
  permanently). Covenant-clean throughout (plugin's own setters under Unicorn).
- **FINE-FX COMPLETE + PILLAR 3 SEALED (2026-07-22).** The full fine-FX family —
  DELAY (1180-1185), slot-1 CHORUS (1210-1212), REVERB (1324-1327) — is wired
  (`src/finefx_recall.c` + `delay_recall.c`) AND exhaustively proven.
  `tools/verify/finefx_pillar3_gate.py` (in `make verify`) diffs the port applier
  vs the plugin's OWN value-tree setter over EVERY byte × 4 rates: **32768
  comparisons, 0 mismatch**, with correct out-of-range saturation (int1x7 clamps
  tightened to the plugin's param ranges — the gate found the reverb setter reads
  state-dependent garbage past range, unreachable via a real controller). Reference
  = `finefx_cellsweep.py` (authoritative full-byte UNION sweep; supersedes the
  0-vs-127 diff, which could miss an intermediate-only cell); port side =
  `finefx_port_dump.c` (shipping `src/*.c`). Render A/B 57/57 @48k+44.1k+88.2k.
  Teensy-golden truncation the fine-FX exposed (blob stopped at record 3077,
  before CHORUS 3286-3288 + REVERB 3948-3952) FIXED: TG_BLOB_LEN 3062→3968.
  Pillar-1 ledger (`COVERAGE.tsv`) reconciled with authoritative cell sets
  (`finefx_authcells.py`): **GAP 25→10** → W1 flipped REVERB PRE DELAY (1323) →
  **W2/W3-struct flipped EFFECT TYPE (873): GAP now 8, APPLIED 129.** The 8
  remaining GAPs are ALL controller-path (engine value-tree dispatch is a no-op —
  they need the #112 controller lifecycle, W4): Patch Tempo (1118) + the 7 FLANGER
  param leaves (1242-1248 MANUAL/RESONANCE/SEPARATION/LOW CUT/LFO SOURCE/LFO EXT
  GAIN/LFO EXT OFFSET). **Every ENGINE-DISPATCHABLE GAP is now closed.** W2/W3
  findings: EFFECT TYPE modes 2/3 have no secondary-cell gap (proven); mode 4
  (FLANGER) re-shapes block-A structural cells 91120/91152/91168/91184 (rate-armed,
  DEPTH/TONE-indep — the old "2/3/4 write bit-identical block A" note was wrong for
  mode 4), now wired in chorus_recall.c (test_delay_recall case 11). Still owed for
  a full ET-mode proof: a synthetic-ET-mode oracle-vs-port state A/B in make verify
  (no factory patch reaches EFFECT TYPE 2-5). chorus-LFO (1213-1215) proven INERT.
  The per-family detail below is retained for history.
- **STAGE-2 PROGRESS — DELAY fine-FX WIRED (#116, first closure).** The DELAY
  TYPE-0 fine-FX filter leaves are now applied by `src/finefx_recall.c`
  (`juno_apply_delay_finefx`, called from `juno_apply_delay`'s TYPE-0 arm):
  HIGH CUT (1180 → 102368/384/400/416/432/464/496), LF/HF DAMP (1182/1184 →
  102640/102672), LF/HF DAMP FREQ (1183/1185 → 102608/102656, rate-armed). The
  law is the plugin's OWN per-byte setter output, executed under Unicorn at all
  four host rates (`scratchpad/finefx_delay_rates.py` → `finefx_tables.h`); at
  the default byte every row EQUALS delay_recall.c's frozen FILT[]/put_rate
  constant (HIGH CUT byte 7, DAMP byte 0, LF/HF DAMP FREQ arms == ARM_LFX2/
  ARM_HFDMP) — a strict generalization, identity at the default. The render-A/B
  ORACLE now DISPATCHES these leaves for TYPE-0 patches (recall_render_ab.py
  `DELAY_FILT_LEAVES`, gated on DELAY TYPE == 0), so the gate covers them: render
  A/B stays BIT-EXACT 57/57 at 48k AND 44.1k WITH the fine-FX in the loop (DELAY
  blind spot closed). Corrected 18 factory TYPE-0 patches (p2 Delicate Keys, p6
  Ouch Bass, p12/13/20/29/30/32/37/43/45/46/50/52/53/54/59/60 — all HIGH CUT=3,
  HF DAMP=12, HF DAMP FREQ=3) whose delay filter was frozen too-bright. Guarded
  by test_delay_recall case 7. NOTE (scope + honesty): this is DELAY TYPE-0
  only — TYPE-1/4 delay + the CHORUS/REVERB/EFFECT-DEPTH fine-FX are the same
  mechanism, still GAP (follow-up). It closes ONE enumerated sub-class; the
  GLOBAL bounce brightness gap (#124) is separate and larger and this does NOT
  close it (the crude locator still shows a per-patch offset dominated by the
  host-lifecycle path, not the delay filter).
- **Process-lifecycle harness (real_process_run.py) — DEFERRED, not needed.**
  Attempted plugin-via-process() as candidate. It FIGHTS emulation (spins 28min
  in the thread-pool wait loop, single-thread drive won't converge — killed).
  Ruled OUT as the darkness source on static grounds anyway: process()'s master
  output stage IS rva 0x398EC0 == e2e_emu MASTER_WRAP, the SAME function our
  render() already calls, and render A/B proves port==oracle bit-exact — the
  preamble cannot introduce different DSP. The divergence is per-patch RECALL
  (fine-FX above), not the per-block process path.
- **System tree map (for #112):** "fm.SYSTEM.COM.*" (Keyboard Velocity
  SW/Fixed Velocity/Curve/Offset, Local SW, MASTER TUNE, Boost Mode, Output
  Gain, ...): name table rva 0x9a0030 (SW = index 12), param DB {min,max,..}
  rva 0x5EC040 + 16*id (4966 ids, formatter 0x3ABB40), engine iface vtable rva
  0x9df1d8 (BUILD slot1, setSR slot3, process slot7, noteOff 15, noteOn 16).
  Old real-process harness: scratchpad/oracle/real_process_run.py (per-block
  render callback 0x3C7400 — BELOW the event layer; events enter via the
  wrapper process preamble 0x34A380 → queue → consumer).

## Standing audit caveats (Phase-E confirmation audit, 2026-07-17)

- Commit be3f1db's "these only affected 44.1 kHz reverb" OVERSTATES audible impact:
  recall unconditionally rewrites all 5 fixed prepare cells per patch
  (juno_apply_reverb writes the 4 DPF Fc with its own independently-derived
  REV_FC44/REV_FC tables — audit-verified == the plugin's setter; delay_recall
  writes 102656), so the old bugs were recall-masked for every patch render. Their
  only reachable surface was the pre-recall power-on state at 44.1k (reverb send 0).
  The cold-state fix is still required — the plugin's cold state is the ground truth.
- coldstate_ab now excludes 5 cells (was 6): 11022052 was NOT inert plumbing — it
  is the plugin's slot-2 EFFECT-routing int (power-on 2), and its exclusion hid
  the warm chorus-arm divergence (see WARM parity above). The old "none read in
  any render source" claim was wrong for it (master reads it through the
  params+112 chase every sample). The remaining 5 (102544, 10759360/472/840,
  11022344) keep their audited inert status; 11022344 is the warmup-mute latch
  the port never needs.
- coldstate_ab.py hardcodes the main-tree libjuno.so + pickle paths — run from a
  git worktree it silently gates the MAIN tree's library (project-wide convention,
  but a sharp edge for worktree-based testing).
- HPF 10240 law precision (audit re-trace): the divisor is cvtdq2ps of an INTEGER
  rate dword (== f32(H) for every integer host rate; port mirrors the int
  semantics), and the plugin SKIPS the mul/div at exactly 96000 (port does too via
  the table arm). T96 fetch lives in helper rva 0x3563BE.., store via 0x3C2763.

## Standing audit caveats (B1 confirmation audit, 2026-07-16)

- `delay_fb_sweep.py` is one-shot EVIDENCE, not a recurring gate: it always exits 0
  and is not in `make verify`. Ongoing enforcement of the delay law = exhaustive
  recall + render A/B + test_delay_recall (mutation-tested: both catch a wrong
  constant at exact coordinates).
- Commit 603f927's "no previously-passing patch changed" was argued too broadly:
  12 other TYPE-0 delay patches DID get new feedback coefficients; the gates
  confirm they still pass, but the diff alone didn't prove it.
- The feedback OFF-gate (102560 → 0 when DELAY LEVEL < 2) rests on captured OFF
  states; render-equivalent either way (wet=0), but re-prove via emulation when
  convenient.
- `gui/web/build.sh` now passes `-ffp-contract=off` (matches the native build); the
  wasm_golden WASM==native gate remains the standing safety net (8/8 bit-exact).

## Git

- Branch `claude/c99-gui-fable5-yfhak1`. `git push -u origin <branch>`, retry on
  network errors (2s/4s/8s/16s backoff). No PRs unless explicitly asked. Never put
  a model ID in commits, code, or any pushed artifact.
- Commit trailer (verbatim, every commit):
  `Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>`
  `Claude-Session: https://claude.ai/code/session_012SxLAY1bDPn2jACwFDPupA`

## Working style

Simplest fix that holds; reuse proven `juno_curve` tables and existing gates before
adding machinery. One reversible commit per fix; a change isn't done until its gate
is green. Proceed autonomously on reversible work; stop only for destructive or
scope-changing decisions.

## ★ WORK ORDER — Fable 5 → Opus 4.8 (2026-07-23, SUPERSEDES ALL "OPTIONAL" LANGUAGE)

**REDEFINITION OF DONE (user-binding): if the port sounds different from the
user's DAW instance, it is NOT correct.** #112 is MANDATORY. The seal's
conditions 1-6 remain necessary but are NOT sufficient. Bounces stay
covenant-diagnostic (locate + completion-test only — never reference/tuning).

**STATUS 2026-07-24: H1 IS ANSWERED — see the "#112 EXECUTED" block at the top.**
The host-state differential was built and run: the host's parameter path and the
plugin's own recall path converge on the SAME dispatch (0x3B9A30) and differ in
exactly one place, the six-index live MODULATION family, which is the identity at
its default and is now ported + exhaustively gated. So a real host does NOT put the
engine's recalled coefficients in a different state than our recall dispatch does;
the remaining candidates for #124 are the wrapper's note/velocity lifecycle and the
DAW's own render chain (the spectral evidence below already points at the latter).
H2/H3 below stay as written for the note-path half.

**The known fact chain (as originally stated):** port == plugin's own recall+render
(bit-exact 57/57) yet ~12-24% centroid off the DAW bounces ⇒ a REAL HOST puts the
plugin in a DIFFERENT state than our recall dispatch does. The bug surface is exactly
that delta. So:

- **H1 — host-state differential (the whole plan).** Single-threaded, no
  process()-loop fight: construct BOTH VST3 components under Unicorn (already
  works: proc_create/ctrl_create), drive `setComponentState`/`setState` with the
  real preset blob for preset N (the blob the plugin's own bank/preset path
  produces), flush controller→processor param sync (the connect path 0x320420 /
  queue consumer called directly, not via the pool), then FULL-STATE DIFF vs our
  recall-driven engine state for the same preset. Every differing cell is a bug,
  by definition.
- **H2 — re-derive each divergent cell's law** by executing the wrapper/
  controller code that wrote it (PROVEN standard, per-byte where param-driven);
  wire into the port; extend recall refs + render A/B so the gate covers it.
- **H3 — completion test:** bounce_relocate.py centroid deltas → ≈0 on all 8
  presets (covenant role 2). Iterate H1→H3 until so. Then re-run make verify +
  WASM rebuild + artifact republish.
- **Guardrails:** two-process rule; no thread-pool spin (kill any run >5 min in
  the wait loop — call consumers directly); no hand value maps; label
  PROVEN/READ/INFERRED; one reversible commit per closed cell-family.
