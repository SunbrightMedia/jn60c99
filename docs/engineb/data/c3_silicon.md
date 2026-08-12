# C3 ON SILICON: recall is CORRECT on the chip, and the burst is 23x the plan
(2026-08-12, `juno_s3_PLAY1.bin`, the user's board)

## THE RESULT THAT MATTERS

    RECALL: CRC vs host answer key: 13 checked, 0 bad -- MATCH
    BURST:  unmapped total 0 (last offset 0)   map complete, chip agrees with host
            builds 23  publishes 22 (refused 0)

**The chip's own recall reproduces the host's coefficients BIT FOR BIT, over 13
patches, with zero unmapped cell accesses and zero refused publishes.** That is
C3's entire claim and it is now PROVEN on Xtensa rather than on a host gate
comparing two host builds. The 1.69 MB frozen blob is gone; 134 patch bytes and
a 30,260-byte cell array replace it.

The publish contract executed 22 times in the field, not once at boot, and cost
**19,143-20,967 cycles** -- 0.36 % of a block. Publishing was never the problem.

## THE BURST IS 2.1 MILLION CYCLES. THE PLAN SAID 90,000.

    build  1965638 / 2136312 / 2115889 cyc  (min/max/last)
    plan                          90,000
    ratio                            23x

**8.9 ms. A chunk is 5.8 ms.** One recall does not fit in one audio block; it
does not fit in two.

This is the ELEVENTH estimate in this project and the NINTH to flatter itself,
and it is by far the worst miss. The 90,000 was already 2x the measured
instruction count as a safety factor, and it was still 23x low. Two causes are
known and neither was in the model:

1. **`ebdev_at` does not fold.** C3's own scout measured 900 out-of-line
   `call8 ebdev_at$part$0` sites in the real recall translation units, 667 in
   `eb_master_coefs.c` alone. `DEVICE_RECALL.md`'s "the map is FREE at a
   constant offset" is true in a small test file and false in the code that
   ships.
2. **The 30 KB cold reseed** runs inside the burst by design, plus a 20 KB
   record install, plus `juno_bank_apply` over the whole cell set.

Neither was measured before the flash. **The lesson is playbook 12's, again: a
cost model that has never executed on the target is a hypothesis.**

## AND THE ENGINE GOT SLOWER

    M1     (no recall code)   whole loop 5,410   budget 5,442   drift NEGATIVE
    PLAY1  (recall linked)    whole loop 5,611-5,861            drift +40..80 ms/s

**+180 to +430 cycles/sample, and it is now OVER budget.** The bursts alone
cannot explain it: at ~1.5 builds/s, 2.1 M cycles is 1.3 % of the chip, while
the loop is 3-8 % slower even between bursts.

**LEADING HYPOTHESIS, NOT A CONCLUSION: instruction cache.** The image gained
about 220 KB of recall code (`juno_curve.c` alone is 126 KB) and the S3 runs
flash-resident code through a small I-cache. This is the same effect predicted
in `two_board_advantages.md` as a REASON the two-board split might help, and
here it appears as a cost. It is testable -- build with recall linked but never
called, and compare -- and that test has not been run. Do not quote it as
established.

## WHAT IS GOOD NEWS AND SHOULD NOT BE LOST

    underruns 0    (M1, with the 29 KB memcpy in the audio loop: 105)

**The burst is genuinely off the audio path.** It is 23x bigger than planned
and it still causes zero incomplete writes, because it no longer runs inside a
sample's slot. C3's structural claim holds even though its cost estimate did
not.

## WHAT THIS CHANGES

The burst must be SPREAD, not merely moved. `eb_recall`'s own design carries a
pump for exactly this and the firmware does the whole build in one call. At
2.1 M cycles the spread is not optional and not a refinement.

And B4 -- real headroom -- is now the binding item for the whole track, not a
later nicety: this build is over budget with two voices.
