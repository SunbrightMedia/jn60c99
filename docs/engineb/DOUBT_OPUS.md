# The doubt review (Fable, 2026-08-08): errors found in this session's verdicts

MEASURED baseline this review starts from: 6v, 2 cores, no FX = 14,497
cyc/sample (2.66x of 5,442). Floor 1,871. Two-core slope 4,290/voice.

## ERROR 1 -- interleaving was killed on the WRONG METRIC
The verdict "432 insns + 27 spills vs 320 + 0" is an INSTRUCTION count. The
entire thesis of interleaving was that cycles != instructions on an in-order
FPU (c/i 1.56, flat slope). 432 insns at c/i ~1.05 (stalls filled, spills to
1-cycle SRAM) is ~454 cycles vs 320 x 1.56 = 499. The envelope precedent it
leaned on was ALSO a static count, not cycles. juno_s3_ILV.bin was built,
gated EXACTLY 0, sent -- and never measured. The lever is UNDECIDED, not dead.
Verdict: rebuild ILV on current HEAD, A/B on silicon. Expected small (~1-3%),
but the method error matters.

## ERROR 2 -- the wavetable's 4 MB of tables sit in FLASH, and nobody looked
linker.lf places CODE in IRAM and its comment says "constants were never the
measured cost" -- MEASURED BEFORE THE WAVETABLE EXISTED (trunk DCO has no
tables). The wavetable reads residual rows from 4 MB of flash rodata through
the SHARED data cache, from BOTH cores, every edge. THIS LOG measures the
smoking gun: one-core slope 3,775, two-core slope 4,290 -- +515 cycles/voice
of cross-core cache contention.
FIX (EXACTLY 0, any preset): copy the PER-NOTE hot table rows to internal
SRAM at coefficient-load time. Per note: saw 4 KB (pitch-shared) + one sub
mip ~4 KB + pulse slices ~8 KB per voice ~= 40-60 KB for 6 voices; 190 KB is
free. Same values, different address -- bit-exact by construction.
Expected: up to ~515/voice x 3 critical voices ~= 1,500 cyc, plus whatever
single-core misses cost on top.

## ERROR 3 -- the prologue SERIALIZES ahead of core 1 in the block design
render_block computes ALL 128 prologues, THEN releases core 1. The prologue
(~400-600 cyc/sample: notecv + voice-0 cvgate/glide + LFO) sits fully on the
critical path. A rolling per-sample ready index (producer-consumer, no
barrier) overlaps it with core 1's rendering. Expected: several hundred
cyc/sample.

## THE BOUND that survives all of it -- and points at the only road
Even a FREE VCF (0 cycles) removes only ~1,000 cyc/voice x 3 = ~3,000:
14,497 -> ~11,500 = 2.1x. No single module is the wall. The wall is the SUM:
~4,300 cycles/voice of port-topology arithmetic where the budget affords
~1,400. Placement + pipelining + 6-slot + ILV lands ~1.8-2.0x WITH FX.

## THE WAY FORWARD (the road Opus never named)
The fork standard is the 1.0 dB sonic gate -- the goal's own definition of
accurate. The wavetable DCO used it: replace the port's TOPOLOGY with a
cheaper structure whose RESPONSE passes the gate (2,864 -> 1,090, PASS 0.40
dB). That move was made ONCE, on one module, and then abandoned as a method.
Applied to the remaining chain -- VCA's two-stage smoothers and tone
crossfade (~290 host insns), envelope (~250), vcf_cv 14-op summing (~110),
glide, res -- each redesigned for equivalent response and gated on all 36:
a further ~1.5-2x on the voice is PLAUSIBLE, NOT PROVEN, and it is the only
candidate anywhere in the evidence with enough size to close the last gap.
Order: measure per-module CYCLES on silicon first (host instructions have
misled twice); redesign the most cycle-expensive module first; gate; repeat.

## Execution order
  1. Hot-table SRAM copies (ERROR 2)          -- EXACTLY 0, largest certain win
  2. Prologue pipelining (ERROR 3)            -- EXACTLY 0
  3. Six-slot build + ILV silicon A/B          -- EXACTLY 0
  4. Per-module cycle attribution ON SILICON   -- the map for step 5
  5. Module-response redesigns under the gate  -- the only road to 1.0x

## MEASURED VERDICT on this review's own fixes (SRAM build, 2026-08-08)

  phase        BEST2    SRAM+pipeline   delta
  0x00 floor   1,871    1,927           +56
  0x80 1v      5,572    5,572           0     (marginal v1: 3,645)
  0xc0 2v      9,862    10,031          +169  (marginal v2: 4,459)
  0xe0 3v      14,154   14,493          +339  (marginal v3: 4,462)
  0xfc 6v      14,497   14,441          -56

BOTH FIXES MEASURED ~ZERO, and the review's own standard applies to itself:
  - ERROR 2's mechanism was MISDIAGNOSED. saw (4 KB) and pulse_b (33 KB) were
    small enough to be cache-resident all along -- moving them changed
    nothing. If the flash-miss theory is right at all, the misses are in the
    tables NOT moved: sub/pulse_a (866 KB), whose PITCH-DISTINCT 4,160-byte
    slices differ per voice. The decisive test is a per-note slice copy at
    load_coefs, which needs the slice base reintroduced as a per-voice
    pointer. Note the new slope SHAPE is evidence: v1 costs 3,645 but v2/v3
    cost ~4,460 each -- each additional voice adds a DISTINCT working set,
    which is a cache-capacity signature, not cross-core contention as this
    review first claimed.
  - ERROR 3's fix is a WASH: per-sample w_ready spins cost about what the
    serialized prologue cost. -56 at 6v, +170..340 in core-1-heavy phases.

STANDING TOTAL: 14,441 cyc at 6v no FX = 2.65x. The cache slice-copy is worth
at most ~1,600 (if v2/v3 fall back to ~3,650) -> ~12,850 = 2.36x. The
module-response redesign road (the wavetable's method applied to VCA, env,
CV chains under the 1.0 dB gate) remains the only lever with the magnitude
to reach 1.0x, and per-module CYCLE attribution on silicon is its first step.
