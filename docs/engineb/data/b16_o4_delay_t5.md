# b16 — O4: the deficit is DELAY TYPE 5, named from the board's own numbers

Host analysis of b15's 425 s board run. No new hardware run was needed.

Trunk gate with the profiler present and OFF: **`make engineb` GREEN (full
tier), RC=0**, and the compiled assembly of `eb_master.c` is **byte-identical**
to the same file without the probes. "Free when off" is proven twice over.

## 1. The deficit is one stage of one pass

    FXP: fx=2432..4374   v1=2570..2652   wait=5   cyc/sample

* `v1` — core 1's VOICE pass — flat within ~80 cycles across every patch.
* `wait=5` — core 0 is never the constraint; core 1 is, as b6 found.
* `fx` — core 1's MASTER pass — swings **~1,900 cyc/sample**.

The whole deficit is 259 cyc/sample (b15 §2), so the swing inside ONE pass is
seven times the entire problem. With `v1` at ~2,600 against the 5,442 budget,
`fx` must stay under ~2,842. Non-delay patches sit at 2,4xx-2,9xx and comply.

## 2. WHICH patches, and what they have in common

Pairing each `FXP:` line with the `pat=` on the following status line:

| fx (cyc/sample) | patch |
|---|---|
| 4,374 | 51 |
| 4,340 | 5 |
| 4,144 | 49 |
| 4,088 | 16 |
| 4,070 | 21 |
| 3,934 | 5 |

Reading DELAY TYPE (record 650) out of the factory bank for all 64 patches:

    DELAY TYPE 0 : 29 patches      DELAY TYPE 3 :  4
    DELAY TYPE 1 : 17 patches      DELAY TYPE 5 :  4
    DELAY TYPE 2 : 10 patches

    the four DELAY TYPE 5 patches are:  5, 16, 21, 49

**Every DELAY TYPE 5 patch is in the hot set, and the hot set is the type-5
set.** b6 independently named its over-budget patches as 5/16/21/49 — the same
four, from a different run and a different instrument.

### Patch 51 is probably contamination, and is NOT claimed

51 is DELAY TYPE 2, and the other type-2 patches are cheap (57, type 2, reads
2,892). `fx` is a ONE-SECOND average while the robot steps patches every ~4 s,
so a report line near a boundary blends two patches — and the step order is
sequential, so `pat=51` follows the type-5 patch 49. The simplest reading is
residue, not a second cause. It is recorded and left unclaimed.

## 3. Why type 5 costs what it does — and it is NOT the PSRAM rings

    engine_b/eb_delay_t1.c    245 lines     6 ring-access sites
    engine_b/eb_delay_t23.c   269 lines     6 ring-access sites
    engine_b/eb_delay_t5.c    553 lines    12 ring-access sites

The type-5 module is **2.2x the code and 2x the ring accesses** of the modules
the other 60 patches use. A pass that does twice the taps and twice the
arithmetic costing ~1,500 cyc/sample more needs no exotic explanation.

This is consistent with — and independently supports — b6's WITHDRAWAL of the
PSRAM attribution. The boot probe reads **29.8 cyc/tap** for the moving-tap
pattern a delay actually uses (this run reprints it), against 228.8 for
scattered reads, and a ring-placement test made the engine 94 cycles WORSE. The
cost is tap COUNT and arithmetic, not memory latency per tap.

## 4. What this changes about O4

The step was framed as "worst-case headroom" across the engine. It is not:

* **60 of 64 patches already comply.** Their `fx` never approaches the ceiling.
* **4 patches miss, and they share one module.**

So the lever list narrows before any lever is pulled. Splitting the master
chain across cores (b6's option, costing one block = 5.8 ms of latency) would
buy headroom for every patch in order to fix four. Optimising `eb_delay_t5.c`
buys it for exactly the four that need it, at no latency cost.

⚠ **NOT YET PROVEN, and the profiler exists to prove it.** This attribution is
from patch metadata and source size, which is circumstantial. The five-stage
profiler added to `eb_master.c` (0 input, 1 DELAY dispatch, 2 reverb, 3 output,
4 EFFECT dispatch) settles it on hardware: if stage 1 carries the 1,900 on
patches 5/16/21/49 and not elsewhere, the attribution holds. If it lands in
stage 2 or is spread, this section is wrong and the split-across-cores option
comes back.

**The prediction is stated before the measurement, and it is falsifiable: stage
1, on those four patches, ~1,500 cyc/sample above the other sixty.**
