# IT DOES NOT FIT ONE CORE — and the fix costs nothing sonically

**Measured 2026-08-02. Verified independently before recording.**

## Where we are

Every module written is **bit-identical** to the sealed reference. Not "under
−100 dB" — a residual of **EXACTLY 0**, on all 30 scenarios including the 17
idle-prefix ones.

| module | accuracy | S3 cost, nominal |
|---|---|---|
| noise LFSR | bit-identical over 200,000 samples | 24 instructions |
| triangle | bit-identical over **all 2^32** float inputs | 73 instructions |
| DCO | **30/30 EXACTLY 0**; wrap bit-identical over all 2^32 | (see below) |
| envelopes | **30/30 EXACTLY 0** | **1,188 cyc/sample** |
| VCF ladder | **30/30 EXACTLY 0** | **4,273 cyc/sample** |

No module has spent one bit of the error budget. That was the hard part and it
is working.

## The arithmetic that decides it

    envelopes   1,188
    VCF ladder  4,273
    ----------------
    subtotal    5,461 cyc/sample  =  156% of the entire 3,500 budget

and the DCO, the mixers, the HPF/VCA stage and **all three effects** are not in
that number. **Two modules already exceed the whole budget by half again.**

## Why it cannot be optimised away

The VCF shortfall is **arithmetic, not layout**. MEASURED-STATIC: 4×49 + 38 =
234 float-arithmetic instructions per voice per sample, ×8 voices = **1,872 float
operations per sample** as a floor, before a single memory access is charged.

Engine B already deleted all 39 per-sample cell shifts and cut per-voice state
from 768 B to 172 B. **Neither touched that floor.** The measured cheap options:

| change | saving | error |
|---|---|---|
| drop the zero-valued S term and two zero taps | **7.3%** | EXACTLY 0 |
| lower the 4× oversampling | large | **requires re-deriving the cutoff law** |

7.3% does not change a 156% overrun. The oversampling is the only lever big
enough, and G is derived for the 4× rate, so it needs the cutoff law and the
decimator re-derived and their error nulled — a design task, not a tweak.

## The answer, and it is not a compromise

**Use the second core.**

I excluded it from the budget myself, in `SCOPE.md`: *"The target is for ONE
core. The second core is a reserve."* That was my conservatism, not a
requirement, and it is now the thing standing between this project and its goal.

The ESP32-S3 is **dual-core at 240 MHz**. Two cores give **7,000 cyc/sample**.

Against 7,000: envelopes + VCF = 5,461 = **78%**, leaving 1,539 for the DCO, the
mixers and the FX. That is tight and it is not yet proven — but it is a real
target rather than an impossible one.

**Crucially, this costs nothing sonically.** The user's constraint was about
sound and voice count: *"8 voices, ALL FX... 6 voices is the ONLY permitted
compromise and it MUST BE THE LAST RESORT."* Splitting voices across two cores
changes no sample. It is the cheapest option available and it should have been
the first one considered.

## Why 6 voices does NOT solve this

Unlike the port — whose 98% idle floor made polyphony irrelevant — engine B's
cost is **linear in sounding voices**, because it skips silent ones properly.
So 6 voices really does cost 3/4 of 8.

    8 voices  5,461   156% of one core
    6 voices  4,096   117% of one core   <- STILL OVER, and that is
                                            before the DCO and all FX

The permitted compromise does not close the gap on one core. On two cores it is
not needed at all.

## The options, ranked by what they cost the user

1. **Both cores.** Costs nothing sonically. Voices split 4+4, FX on one core.
   Needs care over the shared-state boundary and a lock-free hand-off, and the
   free-running lockstep rule still applies across the split.
2. **Lower the VCF oversampling**, with the cutoff law re-derived and the error
   MEASURED against the −100 dB gate rather than assumed. Spends error budget for
   the first time. Only worth doing if (1) proves insufficient.
3. **Fewer voices.** The user's last resort, and on one core it is not even
   sufficient.

## Recommendation

Take (1). It is the only option that costs the user nothing, and the measurement
says one core was never going to be enough regardless of how good the modules
are — and the modules are, so far, perfect.
