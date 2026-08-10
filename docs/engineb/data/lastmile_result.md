# LAST MILE, PHASE A — the measured result (2026-08-10)

STANDARD: AUDIBLE (docs/engineb/AUDIBLE_STANDARD.md).
CONTROL: the build already on the user's board reads **3.17 dB** worst
third-octave band. Every number below is against that, on the same 36
scenarios, at 44,100 Hz, with `tools/engineb/lastmile_run.sh`.

The control was re-run first and read 3.17 dB to the hundredth. That is what
makes the rest of the table mean anything: a harness that cannot reproduce the
recorded number is not measuring the recorded quantity.

## THE TABLE

  lever                                        stepped   interpolated
  ---------------------------------------------------------------------
  pitch + modcv, hold 2                          3.21        --
  pitch + modcv, hold 4                          4.09        --
  VCF cutoff CV, hold 2                          6.74       4.18
  VCF cutoff CV, hold 4                           --       10.93
  envelopes, hold 2                              40.43      22.47
  envelopes, hold 2, rate compensated            41.89       5.51
  2-tap decimator instead of the 16-tap FIR      10.07        --
  ---------------------------------------------------------------------
  pitch+modcv 4, cutoff CV 2                                 4.23
  ALL FOUR (pitch+modcv 4, CV 2, envelopes 2)                5.79

**SHIPPED: the last row, 5.79 dB.** It is 1.83x the control, inside the
"within ~2x" rule the work order set before any of this was measured.

## THE TWO THINGS THE GATE TAUGHT, both of which turned a dead lever live

**1. A HELD CONTROL IS A STAIRCASE, and staircases are the whole problem.**
Every plain hold failed in the SAME band -- 10,240 Hz, the top one -- and by
amounts no slow control signal can explain. The VCA and the filter MULTIPLY by
these signals, so a step at half the sample rate amplitude-modulates the audio
at fs/2, which lands exactly there. The error was never the control's accuracy.
It was the shape of its edges. Filling the held samples by interpolation puts
the signal one sample late and takes the edges out: envelopes 40.43 -> 22.47,
cutoff CV 6.74 -> 4.18.

**2. INTERPOLATION IS PER GROUP, because on the pitch chain it is HARMFUL.**
Interpolating the pitch chain measured 17.96 dB against the stepped form's
3.21. The reason is arithmetic, not taste: `eb_dcoprep` emits the increment
AND the edge gain g = 0.00390625/inc, an exact reciprocal pair, and
interpolating the two independently breaks that identity -- the midpoint of a
reciprocal is not the reciprocal of a midpoint -- so the DCO's edge is the
wrong width for its own increment. **Interpolate what MULTIPLIES the audio;
step what DESCRIBES it.**

**The envelope needed BOTH corrections and neither alone.** 40.43 plain,
41.89 with the rate compensation, 22.47 with interpolation, 5.51 with the two
together. Reported in that order because the compensation ALONE reads as a
failed idea, and it is not one -- it is half of a fix.

The compensation is the two-step pole square: two steps of `y += a(target-y)`
equal one step of `a' = a(2-a)`, so the state at the computed samples is where
it would have been. It is exact where the envelope is linear. The sustain slew
is a linear ramp, so its step doubles instead.

## A DEFECT IN THE FIRST MEASUREMENT, found by its own numbers

The first per-group run reported 17.69 dB for THREE different flag sets. Three
different builds cannot agree to the hundredth; the flags were not reaching
the arithmetic. They were not: the interpolation ran at every site whether or
not that site's module was being held, so a module running every sample had
its output low-passed against the previous sample. Gating the interpolation on
the module's own flag is what produced the table above. **Identical numbers
from builds that should differ is a defect report, not a robustness result.**

## WHY THESE WERE OPEN AT ALL, after being closed twice

C1 closed control-rate pitch at -89.5 dB and C2 closed control-rate CV at
-39.3 dB. Both are NULL numbers, taken against the trunk's -100 dB gate, and a
null asks whether the waveform is the same. The fork's standard is
third-octave BAND ENERGY, which asks whether it sounds the same. Nothing in
this repo had ever put these levers to the second question. The old results
are not wrong; they answer a question the fork no longer asks.

## WHAT IS NOT CLAIMED

No cycle number appears in this file. The gate measures sound. The board
measures cycles, and until the board has printed `0xd0` for this build there
is nothing to say about real time -- that is the iron rule the work order
opens with, and five prior projection failures are why.

Nor does 5.79 dB mean inaudible. The gate's own header says it cannot prove
inaudibility and that the judgement stays with the user. The worst four
scenarios are rendered as WAVs by `tools/engineb/lastmile_wav.py`, trunk and
audible-build and this build at a common gain, for exactly that judgement.

## REPRODUCING

  sh tools/engineb/lastmile_run.sh CONTROL
  sh tools/engineb/lastmile_run.sh ALL \
     -DEB_CR_PITCH=1 -DEB_CR_MODCV=1 -DEB_CR_VCFCV=1 -DEB_CR_ENV=1 \
     -DEB_CR_N=4 -DEB_CR_NP=4 -DEB_CR_NC=2 -DEB_CR_NE=2 -DEB_ENV_CR=2

The firmware carries the same flags plus the board's own set; the state blob
must be regenerated with them too (`JUNO_EB_DEFS=...
tools/engineb/gen_listen_coefs.py 0`), because the blob is a SNAPSHOT of
engine B's state and a snapshot taken under different flags is a
discontinuity. The struct-size assert in `juno_s3_listen.c` catches the
grosser half of that mistake at compile time.

## POSTSCRIPT — SILICON (2026-08-10, same night)
The board closed Phase A: **0xd0 = 6,681 vs 5,442, 1.23x over** — the holds
deliver ~60 cycles/voice, not the priced hundreds, because the voice loop is
stall-bound and the removed arithmetic was hiding inside stalls. Full table
and the PSRAM placement defect the first firmware caught are in
STEP1_ATTRIBUTION.md. The CR flags stay in the tree, gated and documented,
and ship OFF. The sound standard remains the AUDIBLE build's 3.17 dB.
