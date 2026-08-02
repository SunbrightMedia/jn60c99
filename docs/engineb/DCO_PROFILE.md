# DCO profile — where the DCO's work actually is

Date 2026-08-02. MEASURED by execution counters planted in `eb_dco.c` and run
through the full 30-scenario set. Nothing on this page is from reading the code.

## The counts

Over **60,989,440** DCO steps (8 voices x 4 sub-samples x every scenario):

| what | count | share of steps |
|---|---|---|
| steps | 60,989,440 | 100 % |
| **pulse arm executed** | **60,989,440** | **100 %** |
| saw arm executed | 32,541,440 | 53.4 % |
| sub arm executed | 23,523,200 | 38.6 % |
| saturator: **clamp shortcut** taken | 115,524,709 | **98.7 %** of 117,054,080 |
| saturator: full 5th-order polynomial | 1,529,371 | **1.3 %** |
| `fmodf` fallback arms | **0** | **0 %** |

## What that rules out

* **The saturator polynomial is not the target.** The clamp shortcut already
  removes it from 98.7 % of calls. Making the polynomial cheaper would move
  about one percent of one block.
* **`fmodf` is not the target.** It never executes. This was already recorded as
  audit finding F5; the profile confirms it from a second direction.
* **The level gates already pay for themselves.** The saw arm is skipped on
  46.6 % of steps and the sub arm on 61.4 %, exactly and for free.

## What it points at

**The pulse arm runs on every single step, and it contains the one division.**
So the DCO performs 32 float divides per audio sample at full polyphony, and
there is no patch-dependent gate that ever skips them — the pulse arm's own
level gate did not fire once in 60,989,440 steps across 30 scenarios.

On the host this costs almost nothing: x86-64 has a hardware divider. **On the
ESP32-S3 it is a call to `__divsf3`**, because the LX7 FPU has no divider at
all. The cost model puts that at 25..180 cycles each, which is 800..5,760
cyc/sample for one operation — plausibly the largest single line in the module,
and plausibly noise. The band is 7x wide and that width is the honest answer.

## Why I am not removing it yet

An exact removal is possible in principle — the divisor is constant across a
sample, and the quotient is discarded 98.7 % of the time because the clamp
saturates — but it needs a conservative saturation test built on a reciprocal,
with an error bound that must be right. That is precisely the class of change
this project has been burned by twice: `eb_triangle`'s `fmodf` replacement was
mathematically identical and disagreed on 8,388,608 inputs, and
`eb_triangle_saw`'s first form was algebraically identical and disagreed on
104,857,600.

The deciding argument is not the risk, though. It is that **the saving is
invisible on every machine this project can currently measure.** The host has a
hardware divide, so a host measurement would show nothing; the only evidence
would be a MODELED number with a 7x band, and this project's standing rule is
that no optimisation is worth doing before a silicon number exists. That rule
was written after a 32-bit counter made every hardware figure wrong by 7x.

**The next measurement, not the next optimisation:** run engine B on the
ESP32-S3 board and measure the DCO with and without the divide. The board is in
hand. Until that number exists, the divide is a suspect, not a defendant.

## What was done instead

The one exact saving available without silicon: `eb_dco_step4()` hoists the
coefficient loads out of the four sub-samples. MEASURED by callgrind on the
host, 5,000 samples x 8 voices:

| version | executed instructions | vs before |
|---|---|---|
| before | 12,842,632 | — |
| four calls + a local struct copy | 13,879,430 | **+8.1 %, worse** |
| loop + forced inline + `restrict` | 12,200,780 | **−5.0 %** |

The middle row is the reason this was measured rather than reasoned about.
`null_b --module dco`: EXACTLY 0 on all 30 scenarios.
