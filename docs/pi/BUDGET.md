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
