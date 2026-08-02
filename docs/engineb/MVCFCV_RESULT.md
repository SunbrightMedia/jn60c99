# MODULE M-VCFCV — the VCF cutoff CV summing (src/voice_render.c:1150-1229)

Files: `engine_b/eb_vcf_cv.{h,c}`, shim `engine_b/shim/vcf_cv/voice_render.c`.

## Accuracy — PROVEN

`python3 tools/engineb/null_b.py --module vcf_cv` → **30 / 30 scenarios,
residual EXACTLY 0**, including all 17 idle-prefix scenarios (idle chorus /
unison / noise at 1, 48, 441, 4410, 44100 samples), both realloc scenarios and
the three DCO-negative scenarios. Self-test (`--module none`) EXACTLY 0 first.
There is no approximation in this module and therefore no error budget.

## Non-vacuity — MEASURED, two probes

1. The "free" smoother regrouping `(in-s)*rate + s` → `in*rate + s*(1-rate)`,
   planted on two of the three smoothers: **14 / 30 scenarios move**, best
   −127.2 dB, worst block −117.7 dB. It PASSES the −100 dB gate, which is the
   already-documented ULP-class blind spot of this gate, not a licence — the
   shipped code does not take the regrouping.
2. A 1 % error on one leg's weight (`k7392`): **23 / 30 scenarios FAIL**, worst
   global −21.5 dB, worst block −18.4 dB. The module is live in the audio path
   and the gate can see it. (The 7 that stay EXACTLY 0 are noise-only
   scenarios in which that leg's input is zero.)

## The blueprint was WRONG — it is NOT control-rate

`docs/trackb/VCF.md` presents the cutoff CV path as a control-rate sum. The
oracle says otherwise and the oracle wins: four of the block's six live inputs
are per-sample envelope outputs ([752]/[880], [1792]/[1808]) and three one-pole
smoothers ([6896]/[7088]/[7168]) are driven at audio rate.

MEASURED, not assumed: a variant shim that recomputes the whole network only
every **8th** sample (6 kHz control rate at 48 kHz) and holds `cv`, [6704] and
[6848] in between fails **29 / 30** scenarios — worst global **−23.1 dB**,
worst 1024-block **−6.3 dB**. That is 77 dB above the standard. Even the mildest
case (`DCO neg pitch sweep`) is −90.0 dB global. **This module must run per
sample.** The variant shim was deleted after measurement.

## Cost — MODELED on MEASURED counts (`tools/engineb/cost.py measure`)

`--calls eb_vcf_cv_tick=8` (per-voice, 8 voices); `eb_vcf_cv_prepare` is
recall-time and is charged 0 per sample.

| target | cyc/invocation (nom) | cyc/sample (nom) | band |
|---|---|---|---|
| host x86-64 | 18 | **145** | 95 .. 490 |
| M7 (Daisy)  | 89 | **712** | 372 .. 2,264 |
| **S3 (target)** | 86 | **686** | 418 .. 1,855 |

Against the **~2,300 cyc/sample that remain after the two ADSR envelopes**:
**29.8 % nominal** (band 18 % .. 81 %). Against the whole 3,500 budget: 19.6 %.

### Where the saving came from — a bit-exact hoist, MEASURED
First working version: S3 **970** cyc/sample. `eb_vcf_cv_prepare()` moves every
sub-expression whose operands are all recall-constant out of the sample path —
the entire quartic spline leg and its clamp (its input reads no live signal at
all), the [6848] copy, the first term of the final sum, `k7312*x6672` and
`k7024*x6640`. Same operations, same operands, same order, same rounding, once
per recall instead of 8× per sample: **970 → 686 (−29 %)**, null still EXACTLY 0.

## State size

`eb_vcf_cv_state` = **12 bytes** (three smoother floats). The port spends 21
cells × 16 B = 336 B on the same block, of which **16 cells are stores that
nothing anywhere in `src/` or `gui/` ever loads** — enumerated in eb_vcf_cv.c
and simply not performed. Only [6704] and [6848] escape the block (read at
:1230, :1231 and :1570).
