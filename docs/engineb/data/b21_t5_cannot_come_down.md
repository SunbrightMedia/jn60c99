# b21 — t5's cost is the ALGORITHM, not the compilation, so the split returns

b20 named O4's lever as "the arithmetic in eb_delay_t5.c". This is the attempt,
and it FAILED. The failure is informative and it settles O4's direction.

## 1. Two compiler-level attempts, both worth nothing

The hypothesis from b20: `eb_dly5_tick` is 992 target instructions of which
**481 (48 %) are loads and stores** against 252 (25 %) of float arithmetic. The
transcription writes an intermediate into the state struct and reads it back
(`s->s10691968 = RINGR0(...); v62 = s->s10691968;`), and `-fno-strict-aliasing`
forbids forwarding unless the compiler knows a ring write cannot alias a state
member. The rings are separate heap allocations, so the promise is TRUE.

| attempt | insns | mul.s | add/sub.s | ld | st |
|---|---|---|---|---|---|
| baseline | 992 | 134 | 118 | 279 | 202 |
| `float *__restrict ring0;` (struct member) | **992** | 134 | 118 | 279 | 202 |
| `float *const __restrict R0 = s->ring0;` (local) | **991** | 137 | 128 | **287** | **207** |

The struct-member form changed **literally nothing** -- GCC largely ignores
`restrict` on struct members. The local form, which is the way a restrict
promise actually reaches the optimiser, moved the count by one instruction and
made loads and stores slightly WORSE.

Both reverted. An unproven promise carried for no gain is a liability.

## 2. WHY there was nothing to win, and this is the real finding

The store traffic is not redundancy the compiler could remove. It is state:

| module | distinct state fields written per sample |
|---|---|
| `eb_delay_t5` | **101** |
| `eb_delay_t23` | 41 |
| `eb_delay_t1` | 33 |

**101 / 41 = 2.46x, against the MEASURED cost ratio of 2.53x** (b20 §2). The
instruction count tracks the state count almost exactly.

Type 5 is not a badly compiled version of the other delay arms. It is a bigger
algorithm -- four rings, four delay lines, each with its own multi-pole filter
chain -- and it updates roughly three times the persistent state every sample.
Those 101 writes are the algorithm's memory, and the port is BIT-EXACT, so not
one of them may be dropped, merged or deferred.

## 3. So t5 CANNOT come down, and b19's condition is met

b19 and b20 both stated the condition in advance:

> the master-chain split across cores ... returns only if type 5 cannot come
> down far enough.

Four candidates are now dead, every decision rule written before its
measurement:

| candidate | verdict | evidence |
|---|---|---|
| `EB_ZEROCOEF` on t5 | dead | 4 of 65 coefficients always zero vs a >=20 rule (host, all 64 patches) |
| ring placement in SRAM | dead | four moving taps read 15.1 cyc/tap vs one at 29.8, so 12 reads = 181 cyc = 15 % of the excess vs a >=70 % rule |
| restrict / aliasing | dead | 992 -> 992 and 992 -> 991 insns, this document |
| cutting t5's arithmetic | **dead** | the work is 101 persistent state updates; bit-exactness forbids removing any |

**THE MASTER-CHAIN SPLIT ACROSS CORES IS NOW O4's ONLY REMAINING LEVER.**

It is affordable for exactly the reason b6 measured and b20 restated:
`wait=5` on every run in this session -- core 1 is the bottleneck and **core 0
spins**. The split gives core 0 half of the master chain. Its cost is one block,
5.8 ms, of added latency on all 64 patches, which THE INVARIANT permits (audio
never breaks; changes may land late).

## 4. What is owed before it is built

* The 5.8 ms is a USER-VISIBLE cost on every patch, not only the four. b6
  costed it; the user has not been asked to accept it. **Ask.**
* b6 measured SPLIT 8 (2 voices core 0, FX alone core 1) as compliant on
  NOTHING. The master-chain split is a DIFFERENT proposal -- the FX chain
  itself divided, not moved -- and its balance point
  ((5,610+fx)/2 = 4,105/4,830) is b6's arithmetic, not a measurement.
* Nothing here is quotable as a cost from an MSPROF build.
