# b19 — O4's lever is PROVEN: the delay stage carries 97 % of the excess

Per-patch MSPP run, ~343 s, 84 patch reports. The measurement b16 predicted and
b18 could not make.

## 1. The result

84 `MSPP:` lines split cleanly in two, with **no overlap** — a gap between
1,210 and 2,045:

| | n | delay | reverb | sum |
|---|---|---|---|---|
| hot set | 5 | **2,045-2,097** (mean 2,079) | 1,070-1,191 | 4,021-4,185 |
| the rest | 79 | 657-1,210 (mean 848) | 939-1,255 | 2,533-3,245 |

    delay ratio                 2.45x
    reverb ratio                1.02x        <- FLAT
    excess in sum               1,264 cyc/sample
    excess in the delay stage   1,231 cyc/sample
    DELAY'S SHARE OF THE EXCESS    97 %

## 2. The hot set is the DELAY TYPE 5 set

Five hot reports in 84. The bank holds 4 type-5 patches of 64, so the expected
count is 84 x 4/64 = **5.25**. Observed **5**.

Pairing each hot line with the status line beside it gives `pat=` 21, 49, 5, 16
and one where the following status reads `pat=6` (so the patch that ended was
5). **All five are DELAY TYPE 5 patches** — 5, 16, 21, 49, the same four b6 and
b16 named from different instruments.

### ⚠ The MSPP `pat=` FIELD IS UNRELIABLE, and the attribution does not rest on it

Three of the five hot lines print a `pat=` that disagrees with the status line
beside them (48 vs 21, 32 vs 49, 49 vs 5). The offsets are not consistent, so
this is not an off-by-one: `dev_patch` is driven from more than one place
(`S3L_STRESS` also issues program changes), and the value latched at the
boundary print is not always the patch whose samples were counted.

The attribution above therefore rests on the **status line's** `pat=` and on the
**count** (5 observed against 5.25 expected), not on the MSPP label. The label
is a defect and is recorded as one; it does not weaken the finding, but it must
be fixed before any future run quotes it.

## 3. Judging the predictions, both of which were written down first

| prediction | source | verdict |
|---|---|---|
| the excess is the DELAY stage on 5/16/21/49 | b16 §4 | **CONFIRMED** — 97 % of it |
| ratio 1.7-2.0x | b16 §5 | **UNDER-PREDICTED** — measured 2.45x |
| reverb might carry it | b18 §3 | **REFUTED** — reverb ratio 1.02x |

b18 §3 leaned toward reverb on two observations and said plainly that its
one-second window could not settle it. It could not: both pointers were window
artefacts. **The lean was wrong and the caveat that carried it was right.** That
is the caveat earning its keep, and it is the reason no lever was pulled then.

b16's op-count arithmetic (§5) reasoned that 1.8x module weight could not
produce a large absolute gap. The module ratio was a whole-file proxy and the
document said so; the hot-loop ratio is higher than the file ratio.

## 4. THE LEVER, CHOSEN

**Optimise `eb_delay_t5.c`.** The master-chain split across cores is OFF the
table for this deficit:

* the excess is 97 % one stage of one module,
* that module runs on 4 patches of 64,
* splitting buys headroom for all 64 at a cost of one block (5.8 ms) of
  latency, to fix four.

Optimising type 5 fixes exactly the patches that miss, at no latency cost.
b6's split option is not deleted — it returns only if type 5 cannot be brought
down far enough.

## 5. ⚠ WHAT MAY NOT BE QUOTED FROM THIS RUN

This build carries six cycle-counter reads per sample INSIDE the region it
measures. So `sum`, `fx`, `cyc`, `B4dur` and drift are all inflated and none of
them is a cost. In particular **`sum` is not `fx`**, and the observation that
some ordinary patches read above b16's 2,842 ceiling is an artefact of the
profiler, not evidence that 60 patches now miss.

What survives is what the profiler exists to give: the **ratio between stages**,
and the **identity of the hot set**. Both are in §1 and §2.

## 6. Next

1. Fix the MSPP `pat=` label (§2) — cheap, and required before the next run.
2. Optimise `eb_delay_t5.c` against the trunk gate: null must stay EXACTLY 0.
3. Re-measure on silicon with a profiler-free build and read `FXP: fx` on
   5/16/21/49 against the 2,842 ceiling.

O4 is DECIDED. It is not DONE until step 3 reads compliant.
