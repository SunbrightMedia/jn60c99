# THE FX RINGS USE 4 % OF WHAT THEY ALLOCATE — measured

Date 2026-08-06 (Opus 5). Row 1 of `S3_PLAN_THAT_FITS.md` needs the FX rings
in internal RAM. This measures whether they can go there.

## Why it had to be measured and not read

The nine rings are allocated at the port's own length cells. `eb_master.h`
records the total as 6.10 MB, three rings of 2 MB each. 2 MB of floats at
44,100 Hz is **11.9 seconds** of delay. No JUNO-60 delay is 11.9 seconds
long, so the allocated length and the used depth are different numbers.

The used depth is **not readable from a coefficient**. The read index is a
smoothed, modulated value: `eb_delay_t1.c:184` reads at
`write - (int)(v433 * -16384)`, and `v433` is the output of a one-pole chased
toward the recalled time, clamped and modulated. So every read records its lag
behind its own ring's write pointer, and the maximum survives.

`engine_b/eb_ring_probe.h`, `-DEB_RING_PROBE=1`, reported to
`/tmp/eb_ring.log`. It is write-only instrumentation. The same build nulls
**EXACTLY 0 on all 36 scenarios** with the probe off, which is the evidence
that the macro rewrite changed no arithmetic.

**One trap, and it is recorded because it is easy to fall into.** The rings run
BACKWARD — the write pointer DECREMENTS (`eb_delay_t1.c:236`). So the lag is
`(read - write) & (len-1)`. Computing it the other way round reports `len - k`
for every read and makes every ring look completely full.

## The result

Full standalone scenario set, 36 scenarios, both rates.

| ring | allocated | max lag | used | power of two needed |
|---|---|---|---|---|
| t1 | 524,288 | 31,007 | 5.91 % | 32,768 |
| t23 | 8,192 | 536 | 6.54 % | 1,024 |
| t5_0 | 524,288 | 15,503 | 2.96 % | 16,384 |
| t5_1 | 524,288 | 15,503 | 2.96 % | 16,384 |
| t5_2 | 8,192 | 741 | 9.05 % | 1,024 |
| t5_3 | 8,192 | 705 | 8.61 % | 1,024 |
| e5 | 1,024 | 205 | 20.02 % | 256 |
| t4_0 | 8,192 | 71 | 0.87 % | 128 |
| t4_1 | 8,192 | 71 | 0.87 % | 128 |

**Allocated 6.16 MB. Needed 0.26 MB.**

The deepest read in the whole engine is 31,007 samples = **0.70 seconds**.

## What this means for row 1

The S3 has 512 KB of internal SRAM. 266 KB of rings fits, with the engine
state and ESP-IDF sharing the rest. Row 1 is therefore **possible**, not
merely estimated. The FX chain measures c/i 2.36 against the voice chain's
1.56 because it waits for PSRAM; moving the rings removes that wait.

The cycle saving is still an estimate. This measurement removes the memory
objection to row 1. It does not measure the speed gain.

## THE LIMIT OF THIS MEASUREMENT, stated

The 31,007 is the deepest read **over these 36 scenarios**, not over every
value the DELAY TIME parameter can take. A user preset with a longer delay
time reads deeper. Before any ring is shortened in shipping code, the bound
must come from the **parameter maximum**, derived by executing the recall
setter over all 256 byte values, the way every other law in this project is
derived. Sizing from a scenario maximum is exactly the "this byte is 0 in
every factory patch" mistake `GOAL.md` forbids.

The number above is enough to decide that row 1 is worth building. It is not
enough to choose the shipping ring lengths.
