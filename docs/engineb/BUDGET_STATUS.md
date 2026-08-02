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

1. **`eb_env_atrest` — already written.** An envelope at its fixed point with the
   gate low does not change when ticked, so skipping it is EXACT, not an
   approximation, and lockstep is preserved by definition rather than by
   argument. This removes the cost of every silent voice. It does not help the
   worst case of eight sounding voices, which is what a budget must cover.
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
