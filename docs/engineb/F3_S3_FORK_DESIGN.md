# F3 — the S3 fork numeric design: what passed, what died, and the number

Date 2026-08-05 (Fable 5). Every figure below is measured; the gates are
runnable; nothing is judged by ear.

## The sentence that goes first

**With both fork evaluators adopted and 6 voices at 48 kHz, the fork prices at
**28,626** instructions per sample against the 6,300–9,500 two-core budget:
still **3.0×–4.5× OVER** on instruction count. (That figure is O6's MEASURED
one; §4 below estimated 25,850 and §6 records the two corrections.) The
reserve dials (44.1 kHz, half-oversampling) reach ≈24,300 ≈ 2.6×–3.9× over;
the global LFO — now PROVEN EXACTLY 0, §7 — takes it to 24,686 = 2.6×–3.9×
alone, ≈20,400 ≈ 2.1×–3.2× with the reserves. F3 delivers the two
largest levers that exist and the fork still does not fit by arithmetic
alone; the decision moves to silicon (F4), where cycles-per-instruction and
the remaining structural options (global LFO, half-oversampling adoption,
voice count, or the Teensy path) settle it. This is the same verdict shape
the trunk pricing predicted, now with the levers measured instead of modeled.

## 1. Fork pitch — PASS, exhaustive

`engine_b/eb_pitch_fork.c` + generated `eb_pitch_fork_tab.h`. Recentered
per-row evaluation: row r at t = x − (r − 19.5), |t| ≤ 0.5, coefficients
transformed from the plugin's own table in EXACT rational arithmetic
(`gen_fork_tab.py`; the transform is proven as a rational identity before any
float exists — 29 rows × 11 sample points, exact equality). The one rounding
in the pipeline is the final float cast, emitted as hex literals.

**Gate: `tools/engineb/pitch_cents_gate.py` — EXHAUSTIVE, all 2^32 float
inputs**, reference = the port's own `juno_pitch_poly` (itself bit-exact to
the plugin). Result:

| |P| band | worst cents | bound |
|---|---|---|
| ≥ 1 | 0.000415 | 0.05 |
| 0.3–1 | 0.000210 | 0.05 |
| 0.1–0.3 | 0.000191 | 0.05 |
| 1e-2–0.1 | 0.000268 | 0.05 |
| 1e-3–1e-2 | 0.000741 | 0.05 |
| < 1e-3 | abs 3.9e-9 | 2e-6 |

**PASS with 67× margin.** For scale: the plugin's own double evaluation
carries ≈0.02 cents of amplified rounding, and the instrument's own UNISON
voice scatter is 18.2 cents.

Two findings only exhaustiveness could produce:
- **The signaling-NaN class failed the first run.** IEEE maxNum returns the
  number for a quiet NaN but a quieted NaN for a signaling one, so the
  `fminf(fmaxf(...))` clamp sent sNaN inputs to the +8.9 end while the port's
  double conversion quiets every NaN to the −20 end. No sweep visits a NaN
  payload class. Fixed with an explicit `x != x` test; re-proven over 2^32.
- **Row selection is exact by argument, not luck**: the port's
  `(int)(v1 + 20.0)` is exact in double for any float-valued v1, so
  `floorf(x) + 20` is the same function. A first draft used
  `(int)(x + 20.0f)` — the FLOAT add can round across an integer boundary and
  select the wrong row.

Cost: 64 Xtensa instructions + one floorf call per evaluation ≈ 640/sample
for 8 voices, against v7's 21,792 (**−21,150/sample**). O6 note: floorf and
the exp fork's floorf can become the two-instruction int-cast idiom on the
clamped domain.

## 2. Fork exponential — PASS, exhaustive

`engine_b/eb_exp_fork.c`: Cody–Waite reduction, degree-5 polynomial, bit-built
2^n scale; the tails (|x| outside [−87, 88]) DELEGATE to libm so overflow,
underflow and NaN are the port's own by construction.

**Gate: `tools/engineb/exp_ppm_gate.py` — EXHAUSTIVE, all 2^32 float inputs**
against the port's expf: tails 0 mismatches (bit-identical), main region
worst **0.119 ppm** against the 2-ppm bound, sub-1e-30 region worst 1 ULP.
For scale, the pitch bound of 0.05 cents is 29 ppm.

Cost: 82 instructions + floorf, against expf's 184 → ≈ −700/sample on the
LFO's eight calls (more when other expf sites adopt it in O6).

## 3. C4 fixed-point SIMD — CLOSED NEGATIVE for every recursive module

The ×2–3 lever required 16-bit lanes (the S3's PIE has no float and no 32-bit
multiply lanes; eight voices across eight Q15 lanes was the plan). The
one-filter prototype (`docs/engineb/data/c4_ladder_probe.c`) runs the trunk
ladder byte-for-byte in float against the same structure in QN fixed point,
under a hard but plausible drive (−12 dBFS sweep, cutoff swept, resonance to
3.8):

| format | global dB rel | worst 1024-block dB rel |
|---|---|---|
| Q14 | −54.1 | **+11.2** |
| Q15 (the SIMD lane) | −60.9 | **+3.9** |
| Q20 | −92.3 | −31.7 |
| Q24 | −116.4 | −55.3 |
| Q28 (scalar control) | −136.8 | −79.5 |

A resonant recursive filter RECYCLES its quantization error: at high
resonance the Q15 error is as loud as the signal. Even the Q28 scalar — which
has no SIMD carrier on this chip — sits AT the −80 block bound with no
margin. **16-bit SIMD is dead for the ladder and, by the same mechanism, for
every feedback module (VCF, HPF, envelopes, chorus/delay/reverb lines).**
What was thought to survive of C4: feed-forward spans — the FIR decimators
and mix stages. **§6 KILLS THAT TOO, by measurement.** Nothing of C4
survives.
`EB_C4_SIMD_RECURSIVE 0` in eb_fork_config.h records the closure.

## 4. The fork bill of accounts (instructions/sample, MEASURED×STATIC)

Start: S3 shipping trunk 56,967 (fast pitch v7 + DCO recip, 8 voices, the
master chain and worst arms included).

| step | delta | running |
|---|---|---|
| pitch v7 → fork | −21,150 | 35,800 |
| LFO expf → fork | −700 | 35,100 |
| 8 → 6 voices (per-voice portion ×0.75) | −7,750 | 27,350 |
| ~~C4 feed-forward~~ | ~~−1,500~~ **WITHDRAWN, §6** | — |
| reserve: 44.1 kHz | budget +8.8 % | — |
| reserve: half-oversampling (DCO+decim) | ≈−4,300 | ≈21,550 |

Against 6,300–9,500: this table's estimate was 2.9×–4.3×. **§6 supersedes it
with the measured 28,626 = 3.0×–4.5×.** Instructions are not cycles; silicon
(F4) decides, and the remaining structural options are in the first paragraph.

## 6. O6 EXECUTION RESULTS (2026-08-05, Opus 5) — what running it changed

**The measured fork price is 28,626 instr/sample, not the 25,850 §4 modelled
— 3.0x-4.5x over.** Two corrections, both against the estimate:

**C4 FEED-FORWARD IS ALSO DEAD.** §3 kept feed-forward spans alive on the
reasoning that a FIR does not recycle its quantization error. True, and
irrelevant: measured on the decimator's own 32-tap folded structure
(`docs/engineb/data/c4_fir_probe.c`, same shape as eb_vcf_ladder.c), Q15 gives **−49.6 dB
global / −33.7 dB worst block** and even Q20 gives −79.7/−63.8, both failing
the −100/−80 audio gate. Only Q24 passes (−103.7/−87.9), and Q24 has no SIMD
carrier on this chip. **C4 is CLOSED NEGATIVE ENTIRELY — recursive and
feed-forward alike.** The −1,500 credit §4 took for it is withdrawn. The
lesson: "no feedback" answers the ACCUMULATION question, not the RESOLUTION
question, and 15 fractional bits is short of a −100 dB standard before any
processing happens.

**The exponential saves more than estimated** (two sites, not one: the LFO
and the VCF-resonance shaper), which partly offsets the above.

### The gates, and what each is worth

| gate | result | what it proves |
|---|---|---|
| `pitch_cents_gate.py` (2^32, exhaustive) | worst **0.00074 cents** vs 0.05 | the pitch substitution, everywhere |
| `exp_ppm_gate.py` (2^32, exhaustive) | worst **0.119 ppm** vs 2 | the exponential, everywhere |
| `lfo_rate_gate.py` (16 bank coefficient sets) | worst **1.108 ppm** vs 2 | the INTEGRATED rate |
| `--module standalone`, `JUNO_EB_FORK=flagonly` | **EXACTLY 0** | the flag surface changes nothing |
| `JUNO_EB_FORK=exp` | EXACTLY 0 | **almost nothing — see below** |
| `JUNO_EB_FORK=pitch` / `both` | −46.4 dB, 17/36 | the expected cents-scale detune |

**THE LFO-RATE GATE EARNED ITS EXISTENCE.** expf's own error is 0.119 ppm,
but the cancelling expression between it and the phase accumulator
(`v83 = (v76 - v74*v77) + v77`) **amplifies it 9x to 1.108 ppm**. Inside the
bound, but at 1.8x margin rather than 17x. Quoting the exponential's own
figure for the integrated quantity would have overstated the case by an order
of magnitude — the pitch polynomial's 2^37 lesson, at small scale.

**AND THE `exp` AUDIO NULL IS NEARLY VACUOUS, WHICH ONLY A PROBE COULD SHOW.**
It reports EXACTLY 0. A tap on both call sites over six real scenarios
measured **2,016,000 calls each and ZERO differences — because the engine
presents only FOUR distinct arguments at the LFO site and EIGHT at the
VCF-res site.** The arguments are recall coefficients, not signal. So that
EXACTLY 0 means "these dozen values agree bitwise", not "the substitution is
safe"; the correctness claim rests on the exhaustive ppm gate and the rate
gate, and it would have been an over-claim to report the null as the proof.
(The probe itself first reported n=0 at both sites — its `EB_EXPF` macro was
redefined by the fork block that follows it. A probe that measures nothing
looks exactly like a site that is never called.)

**THE GLOBAL-LFO HARDWARE FACT IS NOW MEASURED, AND IT HOLDS.** Across all 64
factory patches with STAGGERED note-ons the LFO phase cell is identical in
all eight voices; forcing LFO TRIG ENV on (record byte 554, the
doctored-preset technique) leaves it identical in all 64. The per-voice LFOs
are redundant computation for every configuration reachable from a preset.
That satisfies F3's condition (a); condition (b), silicon need, is F4's.
Worth ~4,100 instr/sample and now the largest single lever left.

## 7. THE SHARED LFO IS PROVEN — EXACTLY 0 (2026-08-05, Fable 5)

`JUNO_EB_LFO_SHARED=1 null_b.py --module standalone`: **EXACTLY 0 on all 36
scenarios at BOTH 44,100 and 48,000 Hz, against the pure trunk oracle.** One
LFO computed once and broadcast is THE SAME NUMBERS as eight per-voice LFOs —
a removal of redundant computation, proven at the trunk's own certification
standard, not an approximation under a relaxed one.

The chain of evidence, in the order it was built:
1. Phase identity measured across all 64 patches, staggered notes.
2. The two parameters that could break it forced: LFO TRIG ENV on, LFO DELAY
   TIME at maximum (k1184 is nonzero in every patch, so the exp path is live
   in the rate — the identity is NOT a dead-gain artifact). Still 0 of 64.
3. The mechanism located: the LFO's key input is the any-key-held flag the
   plugin itself BROADCASTS to all voices (the b2_bcast2 finding). One LFO is
   the JUNO-60's hardware fact showing through the plugin's own structure.
4. The flagged build nulled EXACTLY 0, both rates.

**Price with the lever pulled: 24,686 instr/sample = 2.6×–3.9× over** (the
LFO line falls 4,728 → 788). With the reserve dials on top: ≈20,400 ≈
2.1×–3.2×.

Status: `EB_LFO_SHARED` default OFF. Charter condition (a) is met and gated;
condition (b) — silicon still needing it — is F4's. PROMOTION TO THE TRUNK is
open to the user: the proof is at the trunk's own standard, but the trunk's
identity as a structure-preserving transcription is a policy, and policy is
not this document's to change.

## 8. THE EXECUTED CHECK — QEMU, fork vs default (2026-08-05, Fable 5)

The QEMU harness (re-downloaded by its own recorded recipe; two updates to
compile against today's engine B — the k5456 argument promotion and an
EB_FORK build knob) ran the SAME workload both ways. Only `sample_total` is
quoted, per the standing warning about per-function spans; CCOUNT ticks once
per 25 instructions in this build.

| build | sample_total raw / 12,500 | executed instr/sample |
|---|---|---|
| default (double pitch) | 33,910,555 | **67,821** |
| EB_FORK (fork pitch linked) | 20,137,563 | **40,275** |

Every region sink nonzero in both runs, overruns 0. The default figure is
consistent with the 71,051 recorded before the decim contract changed. The
delta — **27,546 executed instructions/sample** — is the fork pitch lever as
EXECUTED on this harness's 13-module chain (its module set predates the LFO
and vcf_res modules, so the fork exp is linked but not exercised; the pitch
saving dominates regardless). The static model charged the same lever
34,408; executed is 20 % less, the usual band between the two methods, and
the direction is the safe one — the static model does not flatter the fork.

One incidental cross-check: the pitch region's SINK is bit-identical between
the two runs (0x4a3bd250). That is not evidence the evaluators agree — the
sink accumulates ~30-unit values into a ~3e6 float, whose ULP is 0.25, five
orders above the fork's cents-scale differences. It is evidence the sink
cannot detect them, noted so nobody quotes it as a null.

## 5. What O6 adopts, in order

1. `EB_FORK_S3` build wiring: eb_fork_config.h constants into the render
   loops; pitch and exp call-site switches.
2. A fork-side render A/B against the trunk at matched voices, verifying the
   gated deltas are the ONLY deltas (the composition lesson of task 1b-3:
   two exact pieces still need a whole-engine run).
3. The floorf → int-cast idiom in both fork evaluators, re-gated
   exhaustively (four minutes each; there is no excuse to skip).
4. Feed-forward C4 on the decimator FIRs, gated at −100/−80 like everything
   else.
5. The global-LFO investigation: BOTH conditions (hardware fact including
   CONDITION scatter's role, and silicon need) before any code.
