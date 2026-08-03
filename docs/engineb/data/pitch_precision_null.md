# eb_pitch precision null — THE DECISION MEASUREMENT (2026-08-03)

## Question

Can we remove the double-precision arithmetic from the pitch polynomial
(`engine_b/eb_pitch.c`) and stay under the sonic gate
(docs/trackb/ACCURACY_STANDARD.md: global <= -100 dB, worst-1024-block
<= -80 dB, sample-domain null vs the sealed port)?

This decides the removal of ~28,000 Xtensa instructions/sample of soft-double
on the ESP32-S3 (`eb_pitch` runs 8x/sample; each call makes ~23 `__muldf3` +
13 `__adddf3`; `__muldf3` = 105 static instructions, `__adddf3` = 116).

## Answer (MEASURED, full 30-scenario set, gate = the truth)

| Variant | Global gate (-100 dB) | Block gate (-80 dB) | Verdict |
|---|---|---|---|
| control (unchanged module) | EXACTLY 0, 30/30 | EXACTLY 0 | PASS (non-vacuity control) |
| A `float32` (all-float) | FAIL 30/30, worst **+4.8 dB** | FAIL, worst **+24.6 dB** | **FAIL — catastrophic** |
| B `dekker` (double-float, ~49 bit) | FAIL 2/30, worst **-95.8 dB** | PASS 30/30, worst -90.0 dB | **FAIL — marginal** |
| B2 `dekker_drow` (dekker eval + the port's double clamp/row) | FAIL 2/30, worst -95.8 dB | PASS 30/30 | FAIL — identical to B |

- **Plain float32 is dead.** The pitch output feeds the DCO phase accumulator,
  so a per-sample rounding difference is a constant frequency offset on a held
  note. The phase error integrates. The two renders decorrelate fully: the
  residual reaches the signal level (+4.8 dB rel) and every scenario fails.
- **Double-float (~49 bit) is close but does not pass.** 22/30 scenarios are
  BIT-EXACT. All 30 pass the block gate. Two fail the global gate only:
  `DCO neg pitch sweep` at -95.8 dB (4.2 dB short) and `idle chorus 44100`
  at -98.1 dB (1.9 dB short).
- **The residual is in the EVAL precision, not in the float clamp/row.**
  Variant B2 keeps the port's own double `fmin/fmax` clamp and double row
  select and changes only the polynomial evaluation to double-float. Its
  per-scenario residuals are identical to variant B in all 30 scenarios
  (MEASURED, same values to 0.1 dB). INFERRED from that: the float row select
  never flipped on any executed sample; the ~4 remaining mantissa bits of the
  evaluation are the whole gap.

So the gate says: the soft-double CANNOT be removed with plain float, and a
simple ~49-bit double-float rewrite of the same term order is 2-4 dB short of
the -100 dB standard in 2 of 30 scenarios. Any passing rewrite must give the
evaluation more effective precision than simple Dekker double-float (or must
change the evaluation structure, which is a new measurement).

## Method

Harness: `tools/engineb/null_b.py`, UNMODIFIED, full 30-scenario set (not
`--quick`), default gates (-100 global / -80 block), SR 44100, oracle =
`src/` built fresh, two-process rule kept (null_b's own worker subprocesses).
The probe overrides `null_b._plant` to copy a variant file over
`engine_b/eb_pitch.c` in the COPIED candidate tree only; the candidate is
built with `--module pitch` (`engine_b/shim/pitch/`). `src/` was not touched.

Files (all in `docs/engineb/data/`):

- `pitch_precision_probe.py` — the probe (run from this directory)
- `pitch_var_float32.c` — variant A: every intermediate float; `fminf/fmaxf`;
  float literals; `(float)tab[i]` at use; SAME term order as the port
- `pitch_var_dekker.c` — variant B: FMA-free Dekker double-float. Products via
  TwoProd (4097 split), sums via Knuth TwoSum, coefficients split at use into
  `hi = (float)tab[i]`, `lo = (float)(tab[i] - hi)`; same term order
- `pitch_var_dekker_drow.c` — variant B2: B's evaluation + the port's verbatim
  double clamp and row select (attribution only)

Commands (each PROVEN by execution, exit 0):

    cc -std=c99 -O2 -ffp-contract=off -fno-strict-aliasing \
       -I engine_b -c <variant>.c            # C99 compile check, each variant
    python3 pitch_precision_probe.py control float32
    python3 pitch_precision_probe.py dekker
    python3 pitch_precision_probe.py dekker_drow

## Per-scenario residuals (MEASURED)

Control (`--module pitch`, unmutated): residual EXACTLY 0 in all 30 scenarios.
This proves every number below is the variant's own effect.

### Variant A — float32 (FAIL 30/30)

| Scenario | sig dBFS | global dB rel | worst block dB rel | gate |
|---|---|---|---|---|
| pluck POLY | -29.2 | -64.9 | -61.5 | FAIL |
| MONO retrigger | -20.6 | +3.2 | +7.7 | FAIL |
| UNISON pile-up | -28.6 | +2.9 | +7.7 | FAIL |
| chorus pad | -23.1 | -1.0 | +1.6 | FAIL |
| delay keys | -23.6 | -75.9 | -52.3 | FAIL |
| MONO glide | -30.2 | +1.0 | +4.2 | FAIL |
| long LFO+tail | -29.7 | +0.3 | +5.7 | FAIL |
| DCO noise | -32.4 | -1.4 | +3.9 | FAIL |
| DCO reset arm | -13.1 | -14.1 | -2.3 | FAIL |
| ENV trig arm warm | -11.7 | +1.1 | +24.6 | FAIL |
| idle chorus 1 | -26.5 | +1.5 | +3.7 | FAIL |
| idle chorus 48 | -26.3 | +1.3 | +3.0 | FAIL |
| idle chorus 441 | -26.3 | +1.7 | +3.8 | FAIL |
| idle chorus 4410 | -26.1 | +1.8 | +4.0 | FAIL |
| idle chorus 44100 | -28.8 | +3.3 | +4.8 | FAIL |
| idle unison 1 | -23.4 | +0.1 | +9.2 | FAIL |
| idle unison 48 | -23.4 | +0.1 | +9.2 | FAIL |
| idle unison 441 | -23.6 | +0.1 | +9.1 | FAIL |
| idle unison 4410 | -26.5 | +1.8 | +9.3 | FAIL |
| idle unison 44100 | -32.3 | +3.4 | +7.3 | FAIL |
| idle noise 1 | -31.1 | -1.4 | +3.4 | FAIL |
| idle noise 48 | -31.1 | -1.2 | +3.5 | FAIL |
| idle noise 441 | -30.8 | -1.4 | +3.4 | FAIL |
| idle noise 4410 | -31.4 | +0.6 | +3.2 | FAIL |
| idle noise 44100 | -35.4 | +4.8 | +6.0 | FAIL |
| realloc unison | -27.2 | -0.5 | +6.4 | FAIL |
| realloc chorus | -28.1 | -0.6 | +2.2 | FAIL |
| DCO neg pitch sweep | -30.5 | +2.5 | +5.1 | FAIL |
| DCO neg wrap + PWM clamp | -31.7 | +2.8 | +5.4 | FAIL |
| DCO neg warm chorus | -30.5 | -0.3 | +6.3 | FAIL |

Worst global +4.8 dB rel. 30/30 FAIL.

### Variant B — dekker (FAIL 2/30) and B2 — dekker_drow (identical)

Variant B2 gave the SAME residual as variant B in every scenario (to the
harness's 0.1 dB print precision). One table serves both.

| Scenario | sig dBFS | global dB rel | worst block dB rel | gate |
|---|---|---|---|---|
| pluck POLY | -29.2 | EXACTLY 0 | -- | PASS |
| MONO retrigger | -20.6 | EXACTLY 0 | -- | PASS |
| UNISON pile-up | -28.6 | EXACTLY 0 | -- | PASS |
| chorus pad | -23.1 | -105.3 | -98.6 | PASS |
| delay keys | -23.6 | EXACTLY 0 | -- | PASS |
| MONO glide | -30.2 | EXACTLY 0 | -- | PASS |
| long LFO+tail | -29.7 | -142.4 | -120.6 | PASS |
| DCO noise | -32.4 | EXACTLY 0 | -- | PASS |
| DCO reset arm | -13.1 | EXACTLY 0 | -- | PASS |
| ENV trig arm warm | -11.7 | EXACTLY 0 | -- | PASS |
| idle chorus 1 | -26.5 | -104.7 | -100.6 | PASS |
| idle chorus 48 | -26.3 | -105.5 | -100.1 | PASS |
| idle chorus 441 | -26.3 | -100.4 | -91.9 | PASS |
| idle chorus 4410 | -26.1 | -120.9 | -108.0 | PASS |
| idle chorus 44100 | -28.8 | **-98.1** | -90.8 | **FAIL (global)** |
| idle unison 1 | -23.4 | EXACTLY 0 | -- | PASS |
| idle unison 48 | -23.4 | EXACTLY 0 | -- | PASS |
| idle unison 441 | -23.6 | EXACTLY 0 | -- | PASS |
| idle unison 4410 | -26.5 | EXACTLY 0 | -- | PASS |
| idle unison 44100 | -32.3 | EXACTLY 0 | -- | PASS |
| idle noise 1 | -31.1 | EXACTLY 0 | -- | PASS |
| idle noise 48 | -31.1 | EXACTLY 0 | -- | PASS |
| idle noise 441 | -30.8 | EXACTLY 0 | -- | PASS |
| idle noise 4410 | -31.4 | EXACTLY 0 | -- | PASS |
| idle noise 44100 | -35.4 | EXACTLY 0 | -- | PASS |
| realloc unison | -27.2 | EXACTLY 0 | -- | PASS |
| realloc chorus | -28.1 | EXACTLY 0 | -- | PASS |
| DCO neg pitch sweep | -30.5 | **-95.8** | -90.0 | **FAIL (global)** |
| DCO neg wrap + PWM clamp | -31.7 | -153.1 | -130.7 | PASS |
| DCO neg warm chorus | -30.5 | EXACTLY 0 | -- | PASS |

Worst global -95.8 dB rel. 22/30 BIT-EXACT. Block gate 30/30 PASS
(worst -90.0 dB against a -80 dB line).

## Reading the failure pattern

- The two global failures are the two scenarios that hold the pitch CV in
  motion or hold a chorus voice for the longest time. The residual grows with
  integration time, which is the signature of a rare last-bit frequency
  difference on a held CV, not of a broadband error. The block gate passes
  with >=10 dB of margin everywhere, so no single second of audio is worse
  than -90 dB.
- The `DCO neg pitch sweep` scenario drives the CV negative and large. There
  the polynomial's high-order terms are huge and cancel. Cancellation costs
  the double-float its effective bits; IEEE double keeps 53 and wins. That is
  the measured 4.2 dB gap.
- INFERRED (from B == B2): the float clamp and the float row select
  contributed nothing over this scenario set; both may stay float in a future
  candidate. The precision work is only in the 13-term sum.

## S3 relocation census of the variants (STATIC, xtensa-esp32s3-elf-gcc -O2 -mlongcalls)

    eb_pitch.c (current, double):  46 __muldf3, 26 __adddf3, 4 __extendsfdf2,
                                   2 __fixdfsi, 2 __truncdfsf2, 4 fmin/fmax(d);
                                   text 939 B
    pitch_var_float32.c:           26 __truncdfsf2 (all are (float)tab[i] at
                                   use -- a pre-converted float table removes
                                   every one); text 651 B
    pitch_var_dekker.c:            26 __extendsfdf2, 26 __subdf3,
                                   52 __truncdfsf2 (ALL from df_coef's split of
                                   the double table at use -- a pre-split
                                   static float-pair table removes every one);
                                   runtime arithmetic is pure single-float FPU;
                                   text 2466 B

So a passing double-float-class variant would remove the entire per-sample
soft-double load; the probe builds keep table conversions at use only because
the header's `const double *tab` ABI must stand for the harness.

## Verdict

The sonic gate REFUSES both measured variants:

1. float32 intermediates: FAIL, 30/30, catastrophic. Not a candidate at any
   budget.
2. Simple Dekker double-float (~49 bit), same term order: FAIL, 2/30 on the
   global gate only (-95.8 and -98.1 dB vs -100.0), block gate clean, 22/30
   bit-exact.

The decision the numbers support: the soft-double is NOT removable by the two
straightforward rewrites. The gap is small (<= 4.2 dB) and is attributed by
measurement to evaluation precision alone, so a next candidate needs more
effective mantissa in the 13-term sum (for example triple-float for the sum,
or double-float with an error-free final accumulation), and it must be
measured the same way. No such candidate is claimed here.

Labels: all residual tables MEASURED (harness executed, commands above);
census STATIC; "row never flipped" INFERRED from B == B2; nothing here is
PROVEN against the plugin binary — the null is vs the sealed port, per the
Engine B accuracy standard.
