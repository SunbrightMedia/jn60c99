# THE REAL SILICON NUMBER — 2026-08-01, second full run

## 93,288 was an artefact. The true cost is ~670,000 cyc/sample.

The first silicon run timed each measurement with a SINGLE 32-bit DWT delta.
At 400 MHz that counter wraps every 10.74 s. The measured workloads run far
longer than that, so every headline number in the first run was an **aliased
residue**, not a duration.

The new firmware times one block at a time and accumulates in 64 bits. Feeding
the true cost back through the old arithmetic reproduces the old numbers:

| old measurement | samples | true total | wraps | predicted residue | **old reported** |
|---|---|---|---|---|---|
| E2, 8 voices | 22,050 | 1.477e10 | 3 | 85,333 | **93,288** |
| E3, 8 voices | 11,025 | 7.383e9 | 1 | 280,116 | **287,075** |

Both land within 9%. And E3's "unreconciled 3× discrepancy" against E2 — which
this project carried as an open anomaly for a day — is now fully explained: it
is precisely the ratio of a 1-wrap residue to a 3-wrap residue over different
sample counts. Nothing was inconsistent. Both were aliased, by different amounts.

**Every performance conclusion drawn before this run is void.**

## What the board actually costs

SILICON, this board, 8 voices + FX, scored against the 8,333 cyc/sample budget
at 48 kHz:

| placement | I-cache | D-cache | cyc/sample | over budget |
|---|---|---|---|---|
| QSPI | on | on | **669,682** | **80.4×** |
| QSPI | on | off | 691,513 | 83.0× |
| QSPI | off | on | 1,468,600 | 176.2× |
| voice in ITCM | on | on | 529,343 | 63.5× |
| voice+master in ITCM | on | on | **525,921** | **63.1×** |

The requirement was never 11.19×. **It is 80×.**

## Where the cost is

* **Data access dominates.** 669,682 cyc/sample over the measured 9,850
  accesses/sample is **68 cycles per access** — squarely inside E7's measured
  SDRAM range (16-byte stride 138.10, 4-byte stride 78.74 cyc/access). The
  engine is memory-bound on SDRAM, and the D-cache cannot help (1.03×), exactly
  as the 16-byte-stride finding predicted: an 85.2 KB per-sample line set
  against a 16 KB L1 gives effective reuse of ~1.
* **Instruction fetch is real but secondary.** Moving both hot functions to ITCM
  buys 0.78× (669,682 → 525,921). Disabling the I-cache costs 2.19×, so the
  I-cache is load-bearing, but ITCM only recovers what QSPI+I-cache was already
  mostly hiding.
* **Polyphony is now completely irrelevant.** The idle floor is **98%** of the
  8-voice cost. Zero voices costs 662,277; eight cost 669,682.

## What the measured levers can reach, stacked

| lever | measured | source |
|---|---|---|
| both hot functions in ITCM | 1.27× | matrix |
| hot data SDRAM → AXI at the real 16 B stride | 7.25× | E7 |
| compaction 16 B → 4 B, in AXI | 1.31× | E7 |
| instruction reduction | unproven, ~2–3× at best | modelled only |

Even taking every one of these at face value and assuming they compose — which
they do not, since they attack overlapping terms — the arithmetic does not
approach 80×. The dominant term after relocation is still ~9,850 accesses/sample
at 14–19 cyc/access = **140k–190k cyc/sample against a 8,333 budget**.

## The honest conclusion

**8 voices with all FX, bit-exact or sonically identical, at 48 kHz on a Daisy
Seed is not reachable.** Not by placement, not by compaction, not by arithmetic
reduction, and not by dropping to 6 voices — the idle floor is 98%, so voice
count buys ~2%.

This is not a Track B failure. Track B was never given a chance to fail: the
target it was asked to hit was mis-measured by 7×.

## What is still true and worth keeping

* **E1: golden corpus 8/8 BIT-EXACT on real M7 silicon**, in both runs. The port
  is correct on ARM. That result never depended on the timer.
* The engine's memory pattern is now measured, and the 16-byte-stride waste is
  real and quantified.
* The experiment platform works: 41 matrix points, pre-flight checks, and a
  pattern replay in one boot, with a tick cross-check on every row that would
  have caught this bug on day one.

## The lesson to carry

A 32-bit cycle counter is a 10.7-second ruler. Every timed region must either be
shorter than the ruler or be measured in pieces — and every timing harness needs
an independent clock to cross-check against, which this one now has (`tick-check`
on every row). The first run's numbers were self-consistent, plausible, and
wrong, and nothing inside that run could have revealed it.
