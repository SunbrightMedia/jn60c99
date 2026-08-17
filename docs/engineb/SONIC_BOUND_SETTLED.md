# The fork's sonic bound, settled by measurement
2026-08-17. Every number here was executed today, on this tree.

## The question
`sonic_gate.py` reports FAIL for the shipping fork. Is that a regression, a
wrong bound, or the accepted state described in the wrong words? Worst-case
cost cannot be judged until this is settled, because a cost measured against an
unsettled sonic bound is not actionable.

## The three things that must be pinned before any number means anything

**1. The rate is 44100, and one annotation in the tree says otherwise.**
The firmware's only sample-rate define is `esp32s3/main/juno_s3_listen.c:214`,
`#define SR 44100`. That is the device. But `tools/engineb/null_b.py:1521`
prints "(the ESP32-S3 shipping rate)" when SR == **48000**. That annotation
contradicts the firmware and should be corrected -- it is the same class of
error as the 48 kHz bracket calibrations noted in DELAY_PITCHMOD_FINDING.md.
The gate's default rate (44100, from `null_ab.SR`) is right; the label is wrong.

**2. The flags are `ab_wavs.SHIP`, not the gate's default.**
`sonic_gate.py`'s default `EB_FORK_FLAGS` is `-DEB_FORK_S3 -DEB_DCO_WT=1`: a
two-flag subset nobody ships. Run at that default the gate says PASS, worst
band 0.40 dB. That PASS is near-meaningless and taking it would repeat playbook
53 -- proving on a configuration that does not ship. The shipping set is the 22
flags in `tools/engineb/ab_wavs.py:54-63`.

**3. The gate can still fail.** MEASURED: `EB_SONIC_TEETH=lp8000` (an 8 kHz
low-pass planted in the candidate) -> FAIL (36), worst band 81.16 dB. The
numbers below are from a gate seen to bite.

## What the shipping fork actually measures

| flag set (rate 44100) | verdict | worst band |
|---|---|---|
| gate default, 2 flags | PASS | 0.40 dB |
| **SHIP, 22 flags** | **FAIL (28)** | **5.79 dB** |
| SHIP minus the control-rate flags | FAIL (12) | **3.17 dB** |
| SHIP minus `EB_HALF_OS_VCF` | FAIL (20) | 5.81 dB |
| SHIP minus `EB_VCF_MAPFAST` | FAIL (28) | 5.79 dB |
| SHIP at rate **48000** | FAIL (27) | 14.51 dB |

The control-rate flags are `EB_CR_PITCH/MODCV/VCFCV/ENV`, `EB_CR_N=4`,
`EB_CR_NP=4`, `EB_CR_NC=2`, `EB_CR_NE=2`, `EB_ENV_CR=2`.

## The settlement

**The banked 3.17 dB is SHIP MINUS THE CONTROL-RATE FLAGS.** Removing them
takes 5.79 dB -> 3.17 dB and 28 failing scenarios -> 12. The figure recorded in
LAST_MILE.md:36 as "sound gated 3.17 dB worst band" and in CAMPAIGN_8H.md:92
therefore describes a build from BEFORE control-rate decimation joined the
shipping set. It is not today's audible build.

**Both existing attributions of 3.17 dB are wrong.** HISTORY.md:99 attributes
it to `EB_VCF_MAPFAST`; removing that flag changes the worst band by 0.00 dB.
CAMPAIGN_8H.md:92 attributes it to the 2x VCF ladder; removing `EB_HALF_OS_VCF`
moves it to 5.81 dB, i.e. slightly WORSE, not better. The whole 3.17 -> 5.79
delta is control-rate decimation, and neither document says so.

**The FAIL is not a regression, and it is not the acceptance bound.** Two
different bounds were being conflated:

- `EB_SONIC_BAND_DB` defaults to **1.0 dB**. That is a PER-LEVER SCREENING
  bound -- it is what you hold a single candidate optimisation to.
- The ACCEPTANCE rule is LAST_MILE.md:26: "if worst band is within ~2x of the
  AUDIBLE build's own 3.17 dB, KEEP" -- i.e. about **6.34 dB**.

At 5.79 dB the shipping fork is INSIDE the acceptance rule and outside the
screening bound. Both statements are true, and saying only "the sonic gate
FAILS" is misleading.

Also PROVEN today: the `pitchmod_pre` refactor is inert here. SHIP flags with
the change reverted gives the identical FAIL (28) / 5.79 dB.

## ⚑ The trap in re-baselining, which must not be walked into
The acceptance rule is phrased relative to "the AUDIBLE build's own" worst
band. If that reference is simply updated to today's 5.79 dB, the rule becomes
"within 2x of 5.79" = 11.58 dB, and the next re-baseline permits 23 dB. **A
rule of the form "within 2x of current" is a ratchet: re-pointing it at a moved
current value licenses unbounded drift, one defensible step at a time.**

The reference must be a FIXED number the user has agreed to, not "current".
What is owed is a decision, not a measurement:

1. State the shipping fork's worst band as **5.79 dB at 44100 with the SHIP
   flags** -- measured, not inherited.
2. Decide the fixed acceptance bound for the instrument once, by ear on the
   user's worst-case WAVs (LAST_MILE already requires user-held WAVs alongside
   the gate). This is the ONE place the project permits a listening judgement,
   and it is the user's call, not a gate's.
3. Correct the three stale records: LAST_MILE.md:36, CAMPAIGN_8H.md:92,
   HISTORY.md:99, and the FINAL_GUIDE A2/A3 rows that read DONE against 3.17.
4. Correct `null_b.py:1521`'s "shipping rate" annotation to 44100.

Until step 2, "the fork passes its sonic gate" must not be asserted. What may
be asserted is exactly this: the shipping fork measures 5.79 dB worst band at
the device's own rate, the control-rate flags own the entire delta from the
previously banked 3.17 dB, and no change made today moved it.
