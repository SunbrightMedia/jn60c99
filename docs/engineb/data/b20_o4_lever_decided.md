# b20 — O4's lever is the ARITHMETIC, and both rivals are dead by measurement

Corrected MSPP window (closed inside `dev_request`, so every program change
closes it) plus the new four-tap boot probe. ~295 s.

## 1. RING PLACEMENT IS REFUTED — and the surprise is the direction

    MEM: 2048 MOVING-TAP reads PSRAM  61101 cyc = 29.8 cyc/tap   <- ONE stream
    MEM: 4096 FOUR-TAP    reads PSRAM 62004 cyc = 15.1 cyc/tap   <- FOUR streams

**Four interleaved moving taps are CHEAPER PER TAP than one.** The expectation
was the opposite: four rings far apart, evicting each other, amortising no
burst. Instead the four independent streams give the PSRAM controller
overlappable work, and per-tap cost halves.

At type 5's 12 reads per sample:

    12 x 15.1 = 181 cyc/sample = 15 % of the 1,231 cyc/sample excess

The decision rule was written into the firmware before it ran: >=70 % -> ring
placement is the lever; <40 % -> the arithmetic is. **15 %.**

b6 withdrew the PSRAM attribution on a ONE-stream probe. That withdrawal now
survives the four-stream case it had never been tested on. The rings are
innocent, and this time the case that actually describes type 5 was measured.

## 2. THE TYPE-5 ATTRIBUTION IS NOW AIRTIGHT

b19 claimed it and could not support it: the window still spanned patches,
because `S3L_STRESS` and the console keys change patches without passing the
periodic stepper. Closed now inside `dev_request`, which every program change
calls.

Counting only FULL-LENGTH windows -- n >= 150,000 samples, one complete 4 s
patch dwell, so no window straddles a change:

| | n | delay (cyc/sample) |
|---|---|---|
| hot | 4 | **2,073 - 2,089** |
| the rest | 37 | 657 - 1,012 |

    every hot window is patch 5, 21 or 49          -- all DELAY TYPE 5
    no non-type-5 window exceeds 1,500             -- zero exceptions
    no type-5 window falls below 1,500             -- zero exceptions
    population gap 1,012 -> 2,073, no overlap
    ratio 2,082 / 823 = 2.53x

### ⚠ What is NOT claimed

Patch 16 -- the fourth type-5 patch -- was never captured in a full-length
window this run; the stress robot stepped away from it every time. Its PARTIAL
windows read 1,474-2,086, consistent with the other three, but a partial window
is what b18 and b19 were wrong about and it is not offered as evidence here.
The claim rests on 5, 21 and 49.

## 3. O4's LEVER, and the three that are dead

**Optimise the ARITHMETIC in `eb_delay_t5.c`.** 175 multiplies and 91 adds of
generated bit-exact DSP, against t23's 101 and 44.

Eliminated by measurement, not by argument:

| candidate | killed by | number |
|---|---|---|
| `EB_ZEROCOEF` on t5 | host audit, all 64 patches | 4 of 65 coefficients always zero, against a >=20 rule written first |
| ring placement in SRAM | this run's four-tap probe | 15 % of the excess, against a >=70 % rule written first |
| master-chain split across cores | b19 | 5.8 ms latency on all 64 patches to fix 4 |

Each rule was written down before its measurement. None was adjusted afterwards.

`EB_ZEROCOEF` is worth recording as a structural finding beyond t5: it is
applied to **seven voice modules and no delay module**. The voice chain got the
EXACTLY-0 treatment; the master chain never did, and the master chain is now
the entire deficit.

## 4. ⚠ Still not quotable from this build

Six cycle-counter reads per sample sit inside the measured region. `sum`, `fx`,
`cyc`, `B4dur` and drift are inflated and none is a cost. The ratio between
stages and the identity of the hot set are what this build gives.

## 5. Next

Cut t5's arithmetic with the trunk null EXACTLY 0, then re-measure
profiler-free and read `FXP: fx` on 5/16/21/49 against the 2,842 ceiling.
O4 is DECIDED. It is not DONE until that reads compliant.
