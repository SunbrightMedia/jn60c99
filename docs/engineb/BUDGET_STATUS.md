# ENGINE B — BUDGET STATUS (first real numbers)

## Memory: the architecture works

| structure | bytes | note |
|---|---|---|
| `eb_env` | 16 | |
| **`eb_voice`** | **204** | the port uses **10,512** — a **51x** reduction |
| 8 voices | 1,632 | the port uses 86 KB |
| `eb_params` | 59 | |
| `eb_fx` | 137,012 | delay and reverb lines, the only large item |
| **`eb_engine`** | **138,748** | ~135 KB |

Target was under 1 KB for each voice and under 200 KB in total. **Both met.**
The port's state is 12 MB; engine B's is 135 KB, a **89x** reduction. This is the
change that makes hardware possible, and it is now measured rather than planned.

## Accuracy: exact so far

| module | proof |
|---|---|
| noise LFSR | 200,000 samples, bit-identical |
| triangle | **all 2^32 float inputs**, bit-identical |
| envelopes (M7) | **26/26 scenarios, residual EXACTLY 0**, verified independently |

No module has spent any of the error budget. Nothing is an approximation.

## Cycles: the first problem

`eb_env_tick` is 81 instructions on the ESP32-S3, ~74 cycles. No divide, no
library call, no transcendental — it is already lean and it is bit-exact.

But it runs **twice for each voice for each sample**, so at full polyphony:

    16 calls x 74 cycles = 1,188 cyc/sample = 34% of the 3,500 budget
    band [MODELED] 739 .. 3,098   i.e. up to 89% at the pessimistic end

The first plan allowed **200** cycles for all control-rate work. Envelopes alone
are six times that. The plan was a guess; this is a measurement, so the plan is
what changes.

### Three ways out, in order of preference

1. **`eb_env_atrest` — WRITTEN, AND NOT SAFE AS IT STANDS. Correction, tested.**
   I recorded this as "exact, lockstep preserved by definition". **That was
   wrong.** The reset state is a fixed point only for particular coefficient
   sets. Swept over 162 plausible combinations of `k_susbase`, `k_peak`,
   `k_peakthr` and `k_slew`, ticking 64 times with the gate low:

       9 of 162 combinations hold the rest state

   For the other 153 the state MOVES while the envelope looks "at rest", so
   skipping the tick silently desynchronises the voice — precisely the lockstep
   failure the new idle-prefix scenarios were built to catch, introduced by the
   optimisation that was supposed to be free.

   The mechanism: with `k_susbase != 0` the sustain target is non-zero, the
   upward-slew branch fires, and `t` climbs away from zero even with the gate
   low. `eb_env_atrest` tests `y`, `h`, `t`, `r` but the tick also rewrites `p`
   unconditionally, so `p` is not preserved by a skip either.

   **The correct form** is to decide rest-stability from the COEFFICIENTS, once,
   when a patch is recalled — not from the state, every sample. If a coefficient
   set is rest-stable, cache a flag and the skip is exact for that patch; if it
   is not, that patch does not get the optimisation. The test is O(1) per patch
   change rather than per sample, so it costs nothing.

   **Still unmeasured, and it decides how much this is worth:** the sweep used
   synthetic coefficients. Whether REAL JUNO-60 patches land in the stable region
   has not been checked. Extract the coefficient sets for all 64 factory patches
   from the oracle and count. If most real patches are rest-stable this recovers
   most silent-voice cost; if few are, it recovers almost nothing and option 3
   carries the weight.
2. **Fewer invocations.** Confirm both envelopes are genuinely needed for each
   voice for each sample, rather than computed and discarded when unrouted.
3. **Control-rate decimation.** Envelopes move slowly, so ticking at 1/8 or 1/16
   with interpolation would cut this by that factor. This DOES spend error
   budget — and unlike every earlier project, we can now MEASURE what it spends:
   `null_b.py --module env` reports dB against the −100 dB gate. Decide with the
   number, not by argument.

### The honest statement

Envelopes are bit-exact and cost a third of the budget at full polyphony. Nothing
is wrong yet: seven modules remain and the total is unknown. But if every module
lands at this density, engine B does not fit, and that would be visible long
before the engine is finished — which is the whole reason for measuring each
module as it lands.
