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
