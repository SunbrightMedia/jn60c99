# THE ONE THING TO SETTLE NEXT — two workflows disagree about where the cycles go

Both ran to completion with 0 errors. Both are internally rigorous. **They cannot
both be right**, because each claims roughly the same 50–70k cyc/sample.

| | claims | mechanism | how it was reached |
|---|---|---|---|
| `MEMORY_LEVER.md` | data stall = **54–77%**, best 70% | scattered SDRAM **data** access, 16-byte cell stride wasting 75.6% of every line | host access trace (MEASURED) + E4 SILICON cost/access |
| `COST_ATTRIBUTION.md` | pipeline w/ perfect memory = 42,546 cyc (45.6%); residual **50,742 (54.4%)** is **INSTRUCTION FETCH** | XIP from QSPI flash; ~32.8 KB hot `.text` against a 16 KB L1 I-cache | gcov-weighted in-order scoreboard model (MODELED) |

## Why the I-fetch hypothesis is currently the stronger one

It explains **E3**, which the data hypothesis strains to explain:

* To close the gap with *data* latency, the model needs **+14 cycles on every
  load**. If loads really cost that, disabling the D-cache would multiply the
  cost — it added **5%**.
* **E3 toggled the D-cache only.** An instruction-side cost is precisely the
  cost E3 is structurally blind to.
* The arithmetic is self-consistent: hot `.text` is voice_render 13,728 B +
  master_render 18,368 B + juno_dsp 568 + juno_ftz 112 = **~32.8 KB**, every byte
  touched every sample, over **2×** the 16 KB I-cache. That is ~1,024 line fills
  per sample; 50,742 / 1,024 = **49.6 cycles per fill**, a normal QSPI XIP refill.
* It also explains E3's unreconciled 3× absolute discrepancy (287k vs 93k) — a
  measurement whose code is being re-fetched in a different cache state.

`daisy/juno60_daisy.cpp` is `APP_TYPE = BOOT_QSPI`, so the firmware **executes
from external QSPI flash**. This has been true for every number we have.

## Why it matters more than either verdict

If it is instruction fetch, the fix is **placement, not rewriting**: the
STM32H750 has **64 KB of ITCM**, which holds the whole 32.8 KB hot set. That is
worth up to **2.19×**, changes **not one arithmetic operation**, and therefore
stays **bit-exact** and needs no sonic gate at all.

It would also mean a large part of the effort now aimed at cutting arithmetic is
aimed at the wrong target.

## The decisive experiment — cheap, and it must run before more rewriting

Add to the Daisy firmware and re-flash:

* **E6a** — re-run the E2 8-voice measurement with the **I-cache disabled**.
  If the cost barely moves, the I-cache is already not helping and QSPI fetch
  dominates.
* **E6b** — place `voice_render` and `master_render` in **ITCM** and re-run E2.
  If most of the 50,742 disappears, the residual is instruction fetch and the
  cheapest large win in this project is a linker-script change.
* **E6c** — instrument with the M7's own event counters if reachable, so the
  answer is counted rather than inferred.

## The sobering number, which holds under EITHER hypothesis

With **perfect memory AND perfect scheduling** (the width-2 issue floor), this
instruction stream still costs **~17,200 cyc/sample = 2.06× over the 8,333
budget**.

So placement alone can never be enough. Instruction count must come down too —
but how much, and from where, depends entirely on which hypothesis is true.

**Do not schedule further arithmetic rewrites until E6 has run.**
