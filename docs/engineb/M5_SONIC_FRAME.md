# M5 — the sonic frame every lever is screened by
2026-08-17. The frame around M1–M4: what a candidate optimisation must pass
before it may be kept, and the one judgement that is not a gate's to make.

## THE DIVISION, which ab_wavs.py states best
> the gates decide whether the fork is CORRECT;
> the user decides whether it is ACCEPTABLE.

Nothing may be tuned from what anyone hears. The trunk is proven bit-exact by
execution (null EXACTLY 0, 64/64) and that is not an ear question. A4 asks a
different question — whether the FORK's deliberate divergence is acceptable —
and only listening answers it.

## THE PER-LEVER SCREEN (a gate, runs on any host)
Every candidate lever from here on is screened the same way, at the SHIPPING
flags and the DEVICE's rate:

    EB_FORK_FLAGS="$(python3 -c "import sys;sys.path.insert(0,'tools/engineb');
                     import ab_wavs;print(' '.join(ab_wavs.SHIP))")" \
      python3 tools/engineb/sonic_gate.py

Three things about that command are load-bearing:
- **SHIP flags, not the default.** `sonic_gate.py`'s default `EB_FORK_FLAGS` is
  a two-flag subset nobody ships; at that default the gate says PASS 0.40 dB
  and means almost nothing (SONIC_BOUND_SETTLED.md).
- **44,100, not 48,000.** The firmware's only rate define is
  `juno_s3_listen.c:214`, `#define SR 44100`. Brackets in the tree recorded
  "MEASURED at 48 kHz" are calibrated at a rate the device never runs, and at
  48 kHz the same build measures 14.51 dB instead of 5.79.
- **Prove the gate bites first.** `EB_SONIC_TEETH=lp8000` must give FAIL —
  MEASURED today at FAIL (36), 81.16 dB.

The screening bound is `EB_SONIC_BAND_DB = 1.0` per band. That is a
PER-LEVER bound: it asks whether ONE change moved anything. It is NOT the
instrument's acceptance bound, and conflating the two is what made the
shipping fork's FAIL look like a regression when it is not.

## WHERE THE INSTRUMENT STANDS, MEASURED
The shipping fork at SHIP flags, 44,100: **FAIL (28), worst band 5.79 dB.**
The whole 3.17 → 5.79 delta is the control-rate flags; removing them gives
exactly 3.17 dB. Neither `EB_VCF_MAPFAST` nor `EB_HALF_OS_VCF` accounts for it,
despite two documents attributing the 3.17 figure to them.

And a distinction worth holding onto, MEASURED today by `ab_wavs.py` across all
36 scenarios: the RMS level difference between trunk and fork never exceeds
**+0.26 dB**, while third-octave BAND differences reach 5.79 dB. The fork is
not louder or quieter; it redistributes energy inside narrow bands. That is why
a level meter would call this fork identical and the band gate does not, and it
is also why only listening settles acceptability.

## THE A4 MATERIAL IS RENDERED
`ab_wavs.py` produced 36 trunk/fork pairs, 24-bit, both scaled by the SAME gain
from the trunk's peak so a level difference stays audible. The worst by band
delta, which are the ones worth hearing:

| scenario | worst band | why it is on this list |
|---|---|---|
| idle noise 441 | 5.79 dB | the overall worst |
| long LFO+tail | 4.99 dB | 6.8 s, the longest tail |
| DCO neg warm chorus | 4.10 dB | worst of the DCO cases |
| MONO retrigger | 3.50 dB | |
| DELAY type 3 | 1.92 dB | an expensive arm, the M2–M4 subject |

## ⚑ THE DECISION THAT IS OWED, AND IT IS NOT A MEASUREMENT
`LAST_MILE.md:26` sets the KEEP rule as "within ~2x of the AUDIBLE build's own
3.17 dB". Two problems, both now measured rather than suspected:

1. **3.17 dB is no longer the audible build's figure.** It is SHIP minus the
   control-rate flags. Today's audible build is 5.79 dB.
2. **"Within 2x of current" is a ratchet.** Re-pointing the rule at 5.79 makes
   it 11.58; the next re-baseline makes it 23. A rule phrased relative to the
   present value licenses unbounded drift one defensible step at a time.

So the reference must become a FIXED number, agreed once, and it cannot come
from a gate. The concrete ask:

> Listen to the trunk/fork pairs above. Decide the worst-band figure this
> instrument may carry — as a NUMBER, fixed, not "2x whatever it is now".
> Every future lever is then screened at 1.0 dB per band and the instrument is
> accepted against that fixed figure.

Until that number exists, "the fork passes its sonic gate" must not be
asserted. What may be asserted, and is: **the shipping fork measures 5.79 dB
worst band at the device's own rate, the control-rate flags own the entire
delta from the previously banked 3.17, and nothing changed today moved it.**

## WHAT M5 CHANGES ABOUT M1–M4
Nothing in the cycle arithmetic — but it fixes the standard the remaining work
is held to. The gap with no owner after M4 (+2,658 of FX on chip B, mostly
ARITHMETIC in `eb_delay_t23`/`eb_delay_t5`) will have to be closed by changes
that alter the sound, because the memory third is gone and the arithmetic two
thirds cannot be made free. Those changes get screened at 1.0 dB per band and
accepted against the user's fixed number — which is exactly why that number is
now on the critical path rather than at the end of it.
