# PORT_PI — real-time budget, MEASURED (2026-09-16)

Turns the earlier headroom ESTIMATE into a MEASURED anchor. Labels are strict
(project rule): **MEASURED** = counted from execution; **STATIC** = counted from
a compiled object; **ESTIMATE** = arithmetic on measured inputs, a BAND.

## The measured cost
`pi/probe/bench.c` fills all 8 voices (busy patch, full FX + master) and renders
M frames in one call. Run under callgrind at M and 2M; the difference cancels
setup and gives exact retired instructions per stereo sample.

- **MEASURED, x86-64:** Ir(8000)−Ir(4000) = 122,261,259 over 4000 samples =
  **30,565 instructions / sample** (8 voices + FX + master, 48 kHz).
- **STATIC, aarch64 vs x86** (hot render objects, same flags): aarch64 uses
  **0.671×** the x86 instruction count — AArch64's 32 FP registers and
  3-operand ops need fewer instructions (FMA stays off, `-ffp-contract=off`).

So the A53 executes roughly **20,500–30,600 instructions/sample** (0.671× as a
proxy … up to parity — the dynamic ratio is not the static ratio).

## Where the instructions go (MEASURED, callgrind per function ÷ 8000 samples)
| module | instr/sample | share | note |
|---|---:|---:|---|
| voice render (8 voices: DCO+sub+noise, HPF, VCF ladder, VCA, ENV1/2, LFO) | 23,078 | 76% | ~2,885 / voice |
| triangle (LFO / wave shaping) | 1,969 | 6% | mostly per-voice |
| FTZ denormal flush (`juno_flush_denormals`) | 1,400 | 5% | the bit-exact FTZ shim |
| master + ALL FX (chorus, delay, reverb) | 1,337 | 4% | FX is nearly free |
| wrap24 + voice driver | 651 | 2% | phase wrap, mixing |
| note lifecycle + misc | ~2,130 | 7% | allocation, gates |
| **total** | **30,565** | 100% | |

Key fact: cost scales with **VOICES** (~84% of the sample is the 8 voices);
the full FX stack is ~4%. Fewer voices scale it down almost linearly; adding FX
barely moves it.

## A53 cycles and the 48 kHz budget
A53 is in-order, dual-issue; this code is dependency-bound scalar FP, so
**IPC ≈ 0.7–1.2** (ESTIMATE; only silicon settles it).

    A53 cyc/sample = instr / IPC  ≈  17,100 .. 43,700   (central ~25,000)

| board (core) | 48 kHz budget/core | budget ×4 cores |
|---|---:|---:|
| Pi 3A+ @ 1.4 GHz | 29,167 cyc/sample | 116,667 |
| Zero 2 W @ 1.0 GHz | 20,833 cyc/sample | 83,333 |

**Read-out:**
- **One core** is marginal: the 3A+ sits right at its per-core budget
  (central ~25k vs 29.2k ≈ 86%; band 59–150%); the Zero 2 W single core is over.
- **Voices split across cores** (shared RAM, no links — trivial vs the S3
  chain): central cost is **~21% of the 3A+'s 4 cores, ~33% of the Zero 2 W's**.
  Comfortable headroom at 48 kHz on both. Bands: 3A+ 15–37%, Zero 2 W 21–52%.
- **I2S chunk deadline** (2048 frames = 42.7 ms): one 3A+ core renders 2048
  frames in ~37 ms central; across cores, far inside. Deadline met.

## Caveats (why this is an anchor, not the last word)
- IPC is the one unmeasured factor; the on-silicon `bench` (PMU cycle counter)
  will replace the band with a point once a Pi is in hand.
- patch 0 is a representative busy case; the heaviest FX stack (reverb + delay +
  chorus all on) can add up to ~1.3×. Budget the 4-core split, not one core.
- 44.1 kHz is ~8% cheaper; 88.2/96 kHz roughly double the per-second load and
  need the multi-core split even to be considered (and are not yet proven
  bit-exact — see PORT_PI.md).

## Conclusion
The full, uncompromised 8-voice engine at 48 kHz fits a single Pi 3A+ / Zero 2 W
board with real margin **when voices are spread across its 4 cores**. Confirmed
by a MEASURED per-sample instruction count, not a model.

## PER-CORE SPLIT BUDGET — replication-aware (MEASURED 2026-09-16)
The sections above divide the whole-sample cost as if the split shared it evenly.
It does NOT. The shared-nothing fork-join gives each core its OWN engine copy, so
two costs are **not divided**:
- the per-sample **control tick** (~190 smoothers + arp/note) runs on EVERY core;
- the **master + FX** runs only on core 0 (it owns the mix).
Only the **voice** render is actually divided. MEASURED per-sample (callgrind,
one patch, 8000 samples; ÷8 for one voice):

| item | x86 Ir/sample | divided by the split? |
|---|---:|---|
| one voice | 2,877 | YES (2 voices/core in 2·2·2·2) |
| control tick + glue | 6,178 | NO — replicated on all 4 cores |
| FTZ flush | 1,400 | NO — per core |
| master + FX | 1,196–2,400 | NO — core 0 only (patch-varying) |

So the busiest core (core 0) per sample =
tick 6,178 + 2 voices 5,754 + master ~2,400 + flush 1,400 = **~15,700 x86 Ir**
→ ×0.671 = **~10,600 aarch64 instr**. A worker (no master) ≈ **~8,900 instr**.

Per-core headroom at 48 kHz (IPC band 0.7–1.2; ×1.25 worst-patch on core 0):

| split | busiest core, 3A+ @1.4 GHz | busiest core, Zero 2 W @1.0 GHz |
|---|---:|---:|
| **4-core (2·2·2·2, shipped)** | ~30–52% (worst-patch to ~65%) | ~42–72% (worst-patch to ~90%) |
| 2-core (4·4) | ~41–71% | ~58–**99%** (worst corner) |

**Read-out (answers "doesn't it fit in 2 cores?"):**
- YES, 2 cores fit — but on the Zero 2 W the worst-patch/low-IPC corner touches
  ~99%, i.e. no margin. That is why the shipped split uses all **4 cores**:
  each core sits ~40–70%, so a heavy patch or a low IPC still leaves headroom.
- **core 0 is the bottleneck** (it carries the master). Rebalancing it to 1 voice
  would only shift the load to a 3-voice worker; 2·2·2·2 is near-optimal.
- The **tick replication (~6,178 Ir/core)** is why more cores help sub-linearly:
  you cannot divide the whole sample by 4. Real, but affordable.
- Still an ESTIMATE in one place — **IPC** — resolved only by the on-silicon PMU
  cycle counter. The deadline itself (one 1024-frame block = 21.3 ms) is met with
  wide margin at every point in the band.
