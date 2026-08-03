# DOUBT AUDIT — every load-bearing claim re-examined, and the plan that survives it

Date 2026-08-03 (Fable 5). Written on the user's instruction: "assess the work
with doubt and come up with a better plan, one that is actually confident."
This page supersedes the ranking in `S3_ASSESSMENT.md` §5. Confidence here
means: every number carries its pedigree, every doubt found is either retired
by a measurement in this page or named as an open hole with the measurement
that will retire it. Labels as always: PROVEN / MEASURED / STATIC / MODELED /
INFERRED.

---

## 1. Claims that were attacked and HELD

| claim | attack | result |
|---|---|---|
| capacity 5,000 cyc/sample/core; ~9,500 two-core working | re-derived | arithmetic exact; the 500-cycle service allowance stays MODELED and is stated as such |
| QEMU ×25 CCOUNT scale | 4 branch-light functions vs static counts | holds; the residual check (a counted 3M-instruction loop) stays listed in `qemu_instr_counts.md` |
| `sample_total` 71,051 | span length vs the 25-unit quantisation | a ~70,000-instruction span carries ~0.04% quantisation error; sound |
| per-call QEMU figures | two builds differing only in EB_PITCH_FAST | UNTRUSTWORTHY (fixed 500k/1M offsets on unchanged functions); already recorded; nothing in this page uses them |
| pitch v7 fast: −123.6 dB, table split 0/377, zero soft-double on the hot path | re-read the gate records + relocation census | holds — **but only at 44,100 Hz** (see hole H1) |
| "fail-only" teeth for pitch/pwm_cv | is that a blind spot? | no: those modules are gated finer than one ULP of 1.0f, so no representable PASS-perturbation exists; documented in `null_b.py` with the measured reason |
| composite freshness | `merge_shims.py --check` | in the gate set; the stale-composite lesson is enforced, not just remembered |

## 2. NEW MEASUREMENTS made for this audit (all STATIC, Xtensa cross-compile, this session)

**M1 — there is no second pitch-class soft-double bomb anywhere.**
Census of every `engine_b/eb_*.c` object (`xtensa-esp32s3-elf-gcc -O2
-ffp-contract=off`, `objdump -r`): the ONLY object with soft-double
relocations is `eb_pitch.o` (its default double arm, 40 relocs — known).
All twelve other modules: ZERO.

**M2 — the port-side remainder is also clean.**
`src/voice_render.c` cross-compiled: all 13 `__adddf3` and 23 of 28
`__muldf3` sites are the pitch polynomial (lines 1641–1661, already
replaced). The 5 remaining `__muldf3` sites (lines 640, 744, 765, 826) are
power-of-two scales (2^-24, 2^-32, 2^-16) — a float multiply by a power of
two is exact, which is WHY engine B's float-only transcriptions of those
blocks null EXACTLY 0. Two of the four lines are rare guard arms besides.
`src/juno_driver.c`: 0 df3. `src/juno_note.c`: 0 df3. `src/master_render.c`:
15 df3 sites, all once-per-sample master/FX code — 14 are the
fraction-extraction idiom `(float)x − (double)(int)(float)x` in delay/chorus
tap code engine B has already replaced with exact float, 1 is the warmup-mute
ramp add. Worst case if every site ran every sample: ~1,800 instr/sample;
the real figure is far lower and most of it is already replaced.
**Consequence: the 8 unclaimed blocks contain no hidden soft-double cost.
The pitch polynomial was the only one, and it is handled.**

## 2a. STATUS OF THE HOLES (updated 2026-08-03 evening, Opus 5)

| hole | status |
|---|---|
| **H1** no null at 48 kHz | **CLOSED** — `null_b.py --rate`; the S3 shipping build (fast pitch + reciprocal, whole engine) passes at **−121.5 dB at 48 kHz**. `data/null_48k.md` |
| **H2** composite never run with fast pitch | **CLOSED** — passes both rates, and its residual equals the pitch-alone residual, confirming the other twelve modules are still EXACTLY 0. |
| **H3** ~69,000 is an estimate of an engine that does not exist | OPEN — needs P5 then P6. Revised down by P3, see below. |
| **H4** DCO cost unknown | **CLOSED** — MEASURED×STATIC, no QEMU: **~11,610 instr/sample**, not 17,581. `data/dco_real_cost.md` |
| **H5** instructions ≠ cycles | OPEN — silicon only (P10). |

**P2 is CLOSED with a negative result (2026-08-03 night, Fable 5) —
`data/pitch_p2_study.md`.** The phase-accumulator hypothesis is dead by
argument (the port's increment is itself a float; a value difference cannot be
repaired downstream), recentering is dead by measurement (the port's sum
structure amplifies its own double rounding by up to 2^37 near the
polynomial's zeros — only structural mimicry can match it), and the two
single-downgrade variants of v7 (v8: simple accumulator, −16 %; v9: simple
products, −32 %) both **pass 44.1 kHz and FAIL 48 kHz at −95.4 dB** — the
exact H1 trap, caught because P1 exists. v7 stays; levels above 1 are now a
compile error. The pitch block's ~21,300 instr/sample is the measured price of
matching the port; the §4 best-case row "phase-accumulator pitch lands
(−~19,000)" is struck, which moves the honest best case to **~54,000–61,000**
before P7/P8 structural work — strengthening, not weakening, §4's conclusion
that the restructure track is mandatory.

**P3 also changed the arithmetic in §4.** The DCO was carried there at its QEMU
worst case; its real cost is 5,971 instructions per sample lower, and the
reciprocal takes off 1,408 more. Both corrections land inside the "DCO real-mix"
row of that table, which is now MEASURED rather than a guessed band.

**A harness defect P1 found, recorded because the class matters:** the first
teeth battery ever run at 48 kHz showed the `dcopitch` mutation planting into
`juno_init.c`'s 44,100-only constant arm — at any other rate it modified dead
code and the case measured nothing. Fixed. Same class as everything else here:
a verification that had never been seen to fail.

## 3. HOLES the doubt found (each with its retiring measurement)

**H1 — no −100 dB null has EVER run at 48,000 Hz.**
`null_b.py` renders every scenario at `null_ab.SR` = 44,100 (null_b.py:111,
:578 — checked this session). The S3 ships at 48,000. Therefore the fast
pitch −123.6 dB and the EB_DCO_RECIP −121.1 dB are 44.1k-only results.
`plugin_check.py --rate` covers 48k but only proves the BIT-EXACT default
build. The shipping S3 configuration (EB_PITCH_FAST=1 at 48 kHz) has no
sonic-gate measurement at all.
Retire: give null_b a rate parameter; re-run the fast-pitch null, the RECIP
null, and the composite at 48,000. Until then every fast-path result must be
quoted "44.1 kHz only".

**H2 — the whole-engine composite never ran with EB_PITCH_FAST=1.**
Only `--module pitch` did. Same retirement as H1, one extra run per rate.

**H3 — "~65,000 instr/sample" describes an engine that does not exist, in
both directions.** It contains ~6,800 of harness scaffolding (not engine),
and it omits the 8 unclaimed port blocks (host-MEASURED 10,267 instr/sample;
Xtensa nominal ~×1.10 ≈ ~11,300, soft-double-free per M2). Corrected
complete-engine estimate, fast pitch, MODELED:
71,051 − 6,800 (scaffold) − ~6,000 (pitch hoist) + ~11,300 (missing blocks)
≈ **~69,000 nominal instr/sample**.
Retire: finish the blocks (P5), then one QEMU `sample_total` of the COMPLETE
engine (P6).

**H4 — the DCO figure is the largest single uncertainty.** 17,581/sample is
worst-case-ish: the harness's synthetic levels defeat the saturator shortcut
that fires on 98.7% of calls on real patches, and the per-call QEMU number is
untrustworthy anyway. The real-mix cost could be 8,000–12,000.
Retire WITHOUT trusting QEMU per-call: count branch rates on host replaying
REAL scenarios (instrument the branches), multiply by static Xtensa per-path
counts. MEASURED × STATIC, no icount involved.

**H5 — instructions are not cycles, and the only precedent erred optimistic
by 2.2× (M7).** c/i ≥ 1 on an in-order single-issue LX7; FPU latency and
window overflows sit on top. The instruction budget equivalent to 9,500
cycles is therefore **6,300–9,500 instructions/sample** (c/i 1.0–1.5), and
the low end of that band is the honest planning figure.
Retire: silicon, one function first (pins c/i), when the board arrives.

## 4. The honest sum, after the doubts

| stage | instr/sample (nominal) | label |
|---|---|---|
| complete engine today, fast pitch | ~69,000 | MODELED (H3) |
| + phase-accumulator pitch lands (P2) | −~19,000 → ~50,000 | MODELED-INFERRED |
| + DCO real-mix instead of worst case (H4) | −5,000..9,500 → ~40,500..45,000 | MODELED |
| + RECIP, VCF reciprocal, clamp inlining | −~1,500 → ~39,000..43,500 | STATIC×MEASURED |
| + blockwise call-overhead reduction | −2,000..5,000 → **~35,000..42,000** | MODELED |

Against 6,300–9,500 instructions/sample: **best case ~4–7× over, and every
staged lever is already spent in that number.**

**The conclusion the plan must face:** per-module tuning cannot close this
gap. The only lever classes with the right magnitude are restructures of the
oversampled voice path (DCO+ladder+decimator+VCA ≈ 26,000–31,000 of the
best-case mass) that pass the −100 dB gate. That is not a constraint
violation: the gate DEFINES sonic identity for track B; a candidate that
nulls at −100/−80 is the instrument, by the project's own standard. The
constraints forbid degrading the SOUND and dropping FX/48k, and they order
6 voices last; they do not forbid changing the arithmetic under the gate.

## 5. THE PLAN (supersedes S3_ASSESSMENT §5)

Order: confidence repairs first (cheap), then the two biggest unknowns, then
the levers, then the restructure track that the arithmetic says will be
needed. Every step names the measurement that retires it. No step ships
without its gate.

* **P1 — close H1/H2.** Add a rate parameter to null_b (SR is a function
  argument already; plumb it). Re-run: fast-pitch null at 48k, RECIP null at
  48k, composite default + composite fast at both rates. Hours of work.
  Retired by: the runs. Until green, no fast-path result may be quoted
  without "44.1k only".
* **P2 — the phase-accumulator pitch candidate.** Plain-float polynomial +
  compensated (double-float) DCO phase accumulate. Motivation is MEASURED:
  plain-float pitch failed ONLY through phase integration; v7's cost is
  ~21,300/sample and a compensated add per sub-sample is ~500. Expected
  saving ~19,000 — the largest single lever left.
  Gate: full null, BOTH rates (P1 first). Fallback if it fails: v7 stays,
  nothing is lost.
* **P3 — retire H4.** Host branch-rate counters on real scenarios × static
  Xtensa per-path counts → the DCO's real-mix cost as MEASURED×STATIC.
  Re-rank after; if the real figure is near worst case, the DCO becomes the
  next restructure target ahead of schedule.
* **P4 — cash the small measured levers.** EB_DCO_RECIP=1 as the S3 default
  (after its 48k null); VCF ladder reciprocal (same treatment, drop if it
  fails); inline the non-pitch clamps (gate: EXACTLY 0, NaN semantics
  preserved). ~1,000–1,800 total.
* **P5 — transcribe the 8 remaining blocks** (LFO, glide, key follow,
  velocity, gate ramp, drive, held, CONDITION scatter feed). M2 says they
  hide no soft-double. Each block: EXACTLY-0 null + teeth + a zero-df3
  census of its object (the standard the pitch fix set). Ends with
  `eb_render_needs` empty and `eb_engine_render`'s guard earned off —
  null_b all 30 both rates, plugin_check both rates.
* **P6 — the first honest whole-engine number.** QEMU `sample_total` of the
  COMPLETE engine, both pitch builds, real recalled patch, real levels.
  TRIPWIRE: if > 19,000 instr/sample (2× the top of the instruction budget),
  start P8 immediately — do not wait for P7/P9 to finish.
* **P7 — blockwise / call-overhead.** Measure `entry`/`retw` + window
  traffic first (static + QEMU sample_total delta); restructure only if it
  pays. Gate: EXACTLY 0 (batching only; any rounding change is a −100 dB
  candidate instead).
* **P8 — the restructure track (expect to need it; see §4).** Candidates to
  build AND GATE, in rising order of audacity:
  1. fuse DCO→decimator→ladder inner loops (EXACTLY-0-able: same arithmetic,
     fewer calls/spills);
  2. control-rate decimation of the CV blocks with interpolation (−100 dB
     candidate, ~3,000–4,000 potential);
  3. reduced oversampling with a redesigned matched decimator (−100 dB
     candidate; the measured no-oversampling floor ~11,000 says the class
     has decisive magnitude);
  4. fixed-point inner loops using the S3's PIE 128-bit integer SIMD
     (−100 dB candidate; the only ×4-class lever on this part; esp-dsp
     precedent exists).
  Rule unchanged: a candidate that cannot null at −100/−80 does not ship,
  no matter what it saves.
* **P9 — two-core split** (4+4 or voices/FX). No arithmetic change → gate
  EXACTLY 0; lockstep free-run law holds across the boundary; hand-off
  lock-free. Retired by silicon CCOUNT under load.
* **P10 — silicon, when the board arrives.** One function first — it pins
  c/i and retires H5 — then the engine. Standing rule: re-rank this whole
  list on the first silicon number.
* **P11 — memory plan** (parallel): 256 KB delay ring vs 512 KB SRAM;
  measure PSRAM streaming cost; delay/reverb stream sequentially, voices
  and hot state stay internal.
* **P12 — LAST RESORT: 6 voices** (`docs/trackb/CONSTRAINTS.md`). Saves
  ~25% of the voice mass; on today's model it does not close the gap alone;
  it is only meaningful after P8 lands. It stays last.

## 6. What this audit did NOT re-verify (stated, not hidden)

* The ×25 scale beyond its four cross-checks (the counted-loop check remains
  the listed decisive test).
* The port-side gate suite (`make verify`) — untouched this session; last
  green 2026-07-31, and engine B work does not modify `src/`.
* Anything about cycles. Nothing here is a cycle count until silicon exists.
