# P2 — the pitch cost study, round two: two hypotheses killed by measurement,
# the real lever isolated

Date 2026-08-03 (Fable 5). Continues `pitch_precision_null.md` (the v1–v7
ladder) after the hoist (`pitch_hoist_result.md`).

## 1. The phase-accumulator hypothesis is DEAD, by argument from the gate's
## own definition

The recorded idea was: carry the DCO phase in double-float and the polynomial
in plain float, "one compensated add per sub-sample instead of a compensated
polynomial per sample."

It cannot work, and no build is needed to know it. The gate compares engine B
against the PORT. The port's own increment is a FLOAT — the double polynomial's
result truncated once. Engine B must reproduce the port's increment VALUES.
A plain-float polynomial produces increments that differ from the port's by a
~1-ULP carpet, and the port's float phase accumulator integrates whatever
increment it is given — there is no downstream place where extra precision can
cancel an upstream value difference. The precision must live in the polynomial.
The hypothesis is struck from the plan.

## 2. Recentering (and every "compute it more accurately" scheme) is DEAD,
## by a conditioning measurement

Measured from `juno_pitch_table` itself (exact rational arithmetic over an
x-grid per row): the port's sum structure carries a worst-case term-to-result
ratio of ~2^37 near the polynomial's zero crossings. There, the port's own
DOUBLE output is dominated by its own rounding pattern.

Consequence: an evaluation that computes the TRUE polynomial value more
accurately — recentered coefficients, fixed-point, higher precision — diverges
from the port exactly where the conditioning is bad, because the port's output
there is not the true value. **Only structural mimicry of the port's term
order at sufficient working precision can match it.** That is what v7 is, and
why the v-series kept failing until it mimicked harder.

## 3. What was still open: WHICH of v7's two upgrades carries the margin?

v7 = error-free product lo-paths + compensated (hi,lo,c) accumulator, and the
plain-Dekker variant (simple products + simple add) failed 2/30. The record
never established which upgrade was necessary. Two single-change variants
answer it:

| variant | products | accumulator | 44.1 kHz worst global | static instr/call* |
|---|---|---|---|---|
| dekker | simple | simple | **FAIL 2/30** | (smallest) |
| **v8** | error-free (v7) | simple df_add | **PASS −110.2 dB** | 2,224 (−16 %) |
| **v9** | simple Dekker | compensated (v7) | see below | 1,792 (−32 %) |
| v7 (shipping) | error-free | compensated | PASS −123.6 dB | 2,640 |

*same counting method for all rows: `objdump` bodies × call counts, wrapper
included; this differs from `pitch_hoist_result.md`'s 3,126 only in method,
not in substance.

v8's PASS already proves the error-free products alone are enough to clear the
gate. The v9 run (and a 48 kHz run of each candidate) decides whether the
accumulator alone is also enough, i.e. which cost cut is available at which
margin. Results recorded below when the runs complete.

## 4. Results and the decision — BOTH cheaper variants are REJECTED

Full 30-scenario nulls, both rates, probe reproducible
(`pitch_precision_probe.py`, cases `v8` / `v9`; 48 kHz via `null_b.SR`):

| variant | 44,100 Hz | 48,000 Hz | static instr/call |
|---|---|---|---|
| v8 (error-free products + simple add) | PASS −110.2 dB | **FAIL −95.4 dB**, 'DCO neg pitch sweep' | 2,224 |
| v9 (simple products + compensated acc) | PASS −106.0 dB | **FAIL −95.4 dB**, 'DCO neg pitch sweep' | 1,792 |
| v7 (shipping) | PASS −123.6 dB | PASS **−148.4 dB** | 2,640 |

**Both cheaper variants pass 44.1 kHz and fail the SHIPPING rate.** This is
precisely the trap DOUBT_AUDIT.md's hole H1 described — a 44.1k-only result
quoted as if it covered the S3 configuration — and it was caught only because
P1 gave the null harness a `--rate`. Before this session these variants would
have measured PASS on the only rate the gate could run, and one of them might
have shipped.

Worth noting: the two variants fail at the SAME −95.4 dB on the SAME scenario
despite sharing no changed component. The dominant residual under either
single downgrade is the same event class — the same behaviour the v4–v6
threshold variants showed (bit-identical residual carpets), and further
evidence this polynomial punishes any weakening uniformly.

**Decision: v7 stays. EB_PITCH_FAST levels above 1 are a COMPILE ERROR**
(`eb_pitch.c` `#error`), so the rejected variants cannot be re-adopted without
finding this study. The pitch block's remaining ~21,300 instr/sample is the
price of matching the port at the gate, on current evidence: the three exits
that could have been cheaper (less precision, truer values, downstream
precision) are all measured or argued dead above. Any further pitch saving
must come from structural work covered by plan steps P7/P8 (call structure,
blockwise evaluation), not from thinner arithmetic.

## 5. Also confirmed in this study

* The v9-versus-v8 comparison answers the open question from the v-series:
  NEITHER upgrade alone suffices at the shipping rate; v7 needs both.
* 48 kHz is the HARDER rate for weakened pitch arithmetic (−95.4 vs −110/−106)
  even though it is the EASIER rate for v7 (−148.4 vs −123.6). Rate coverage
  is not a formality; neither rate dominates the other in general.


## 6. C1 (control-rate pitch) — CLOSED, NEGATIVE, and the law it uncovered

Date 2026-08-03, same session, P8 candidate C1 executed to its end.

**The ladder of designs, each killed by measurement:**

| design | worst null @48k | killed by |
|---|---|---|
| linear extrapolation of the output | −54.8 dB (N=2) | sample-rate content in the CV (env attacks, S&H/noise LFO) |
| + first-order Taylor in the true per-sample CV | −50.8 dB | float derivative: WRONG SIGN (−0.104 vs +0.022) — the 2^37 cancellation applied to P′ |
| + df/double derivatives, second order, knot re-anchor, clamped-domain δ, pre-gain anchors, radius 0.005 | **−89.5 dB, 4 scenarios** | see below |

**The closing measurement, and it is the finding.** Replaying the REAL
pluck-POLY trajectory (336,000 logged (voice, cv, gain) calls) through the
final evaluator against the exact one: worst pointwise error 1.03e-7
relative, RMS 4.2e-8 — pointwise −134 dB. The audio null still fails at
−89.5 dB. The pitch values were never the problem: **a smooth deterministic
error is a BIAS, and the DCO phase integrates a bias.** 5e-8 sustained over a
voice's 42,000 samples at increment ~0.01 is ~2e-5 of phase — −89 dB. v7
passes not because it is merely accurate but because its ±1-ULP errors DITHER
around zero.

**THE LAW, for every future P8 candidate:** classify the target by its
consumer.
* **Phase-integrated quantities** (the pitch increment → DCO phase; the LFO
  rate → LFO phase) require BIAS below ~1e-9. No causal approximation —
  interpolation, Taylor, incremental exp, control-rate anything — delivers
  that. Only exact-to-dither evaluation passes. Pitch's 21,792 instr/sample
  is the price of the gate, now proven from two independent directions.
* **Memorylessly-consumed quantities** (VCF cutoff/resonance coefficients,
  VCA gains, mix levels) tolerate ~1e-5–1e-6 bias — the −100 dB gate applied
  directly, with no integrator behind it. Control-rate evaluation remains a
  live candidate THERE and only there.

Consequences recorded in P8_PLAN.md: C1 dead; C3 (incremental LFO expf) dead
by the same law (the LFO rate feeds the LFO phase); C2 narrowed to the
non-integrating CV blocks. The code stays behind `EB_PITCH_CR` with a
compile-time refusal above N=1, N=1 being bit-exact and kept as the harness
self-test.

## 7. C1 RE-OPENED FOR THE FORK (2026-08-06) — and it is worth NOTHING there

The fork's standard is indistinguishability, not bit-exactness, so §6's −100 dB
verdict does not bind it. C1 was re-opened on that reasoning and MEASURED on
the full 36-scenario battery (§6's number was 4 scenarios):

| N | worst global | worst block | failing scenarios |
|---|---|---|---|
| 2 | **−76.4 dB** | −71.1 dB | 9 |
| 4 | −80.0 dB | — | 11 |
| 8 | −80.7 dB | — | 12 |

**More decimation measured BETTER, not worse**, which no error model here
predicts and which is recorded rather than explained: N=8 is 4.3 dB quieter
than N=2 while failing more scenarios. The likely reading is that the
re-anchor radius (EB_PITCH_CR_RADIUS) dominates over N -- a larger N spends
longer inside one anchor but re-anchors on the same CV excursions -- but
nothing was measured to confirm it, and since the lever is worthless in the
fork (below) nothing was.

**The integrating-bias fear is MEASURED FALSE.** §6 predicted the error would
grow with note length, so long notes would be worst. They are not: `long
LFO+tail` is **−99.2 dB**, among the BEST scenarios, while the worst is `DCO
neg wrap + PWM clamp` at −76.4 dB — a fast pitch sweep. The error is largest
where the CV MOVES, i.e. where the evaluator re-anchors, not where the phase
has had time to accumulate. §6's law is right about the mechanism and wrong
about which scenarios expose it.

And −76.4 dB would have been acceptable: the signal sits at −31.7 dBFS, so the
error is at −108 dBFS absolute, and it is 28 dB quieter than the alias
relaxation already accepted for half-oversampling.

**BUT THE SAVING IS GONE, because the fork already solved pitch another way.**
C1's ~15,300 instructions/sample was measured against the TRUNK's v7
double-float evaluator (4,281 instructions per call). The fork does not use
it. F3's recentered evaluator, `eb_pitch_fork_eval`, costs **60 instructions
per call — 360 per sample at 6 voices**, and is exhaustively gated to 0.00074
cents over all 2^32 float inputs. There is nothing left for a control-rate
scheme to save.

**C1 IS CLOSED FOR THE FORK, for a reason that has nothing to do with §6.**
The lever was real, the bias law is real, and both are irrelevant: the fork
retired the expensive evaluator before this question was ever asked.

**Where the fork's 24,686 instructions/sample actually go at 6 voices:**

| line | instr/sample | share |
|---|---|---|
| **dco** | **7,652** | 31 % |
| vcf_res | 3,174 | 13 % |
| the DELAY + EFFECT arms | 3,135 | 13 % |
| vca_hpf | 1,380 | 6 % |
| vcf_ladder | 1,380 | 6 % |
| glide | 1,188 | 5 % |
| envgen | 972 | 4 % |
| decim | 912 | 4 % |
| pitch (fork) | **360** | **1.5 %** |

Pitch is 1.5 % of the fork. Any further work belongs on the DCO, which is a
third of everything and has never been restructured.
