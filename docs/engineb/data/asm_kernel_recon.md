# ASM KERNEL — RECON AND THE c/i DECISION (2026-08-10, Opus 5, ultracode)

Written at a session limit. Everything here is a MEASURED result or an
explicitly labelled gap. The kernel itself is NOT written; this is the
evidence that says whether to write it, plus two tools and one bit-exact
lever that were built on the way.

## 1. THE CONTRADICTION IS RESOLVED, AND THE OPTIMISTIC NUMBER WAS THE WRONG PROGRAM

CLAUDE.md records `c/i = 0.95` ("instruction counts ARE cycle counts on this
chip") from F4 first silicon. STEP1_ATTRIBUTION records c/i 1.56 and ~1.9 for
the ladder. Both are real; they describe DIFFERENT PROGRAMS.

**The 0.95 was measured on the F4 measurement firmware only** — `juno_s3_main.c`
+ `tools/engineb/qemu/harness.c`, whose module set is fixed at
`tools/engineb/qemu/build.sh:25-31`. It contains the **4x ladder**, `eb_dco`
(4x step4), and **none** of `eb_dco_wt`, `EB_VCF_RES_LUT`, `EB_HALF_OS_VCF`,
`EB_ATREST_*`, `EB_ZEROCOEF`, `EB_EXP_MEMO` — **and it never calls
eb_render.c's voice loop at all**. Numerator 38,209 silicon cycles/sample,
denominator 40,275 QEMU executed instructions, same ELF. Honest, and
inapplicable to the shipping fork.

**So `c/i = 0.95` may not be quoted about the fork voice loop again.**

## 2. THE FORK VOICE LOOP, PRICED TWICE, INDEPENDENTLY

Two agents priced one SOUNDING voice of the shipping fork by compiling every
`eb_*.c` with the shipping flags and disassembling with Xtensa objdump. The
second was given the first's answer and told to refute it.

    first pass    2,321 instructions/voice
    refutation    2,275 instructions/voice     (2 % apart)
    cycles/voice  3,068  (AUDIBLE build slope, STEP1_ATTRIBUTION:341-344)
    **c/i = 1.35   ->  STALL POOL ~= 790 cycles/voice**

Both verdicts: STALL_POOL. **The gap is ~620/voice and the measured pool is
~790.** The kernel remains correctly sized — but at c/i 1.35, not the 1.9 the
work order assumed, so the pool is smaller than the order's 735-per-module
figure implied and the required capture fraction is ~78 %, not ~85 %.

### THREE INPUT ERRORS THE REFUTATION CAUGHT, ALL FLATTERING "no stalls"
1. **I gave the agents the wrong build's cycles.** The 1,130/3,710/6,716/...
   sweep is LASTMILE2 (control-rate levers ON); the flag set being priced was
   the AUDIBLE build, whose own slope is 3,068. Pricing CR-off instructions
   against CR-on cycles understates c/i.
2. **The at-rest voice is 93 instructions, not ~10** — a 78-instruction loop
   latch where GCC spills ~26 induction pointers, per voice per sample. 3,017
   is a SLOPE, so that must be subtracted; comparing a full-voice count to a
   slope is the same class of error as the repo's other four.
3. **The map row "res shaper (residual) 36 cycles" is impossible.** With the
   LUT hit `eb_vcf_res_tick` still executes ~319 instructions. The 36 is
   1,045 (ablation) minus 1,009 (LUT delta) — two differently-baselined
   measurements subtracted. Recorded so the map is not trusted at that row.

## 3. THE LADDER'S OWN STALL STRUCTURE (MEASURED, from the disassembly)
One half-OS sub-step: **42 FP ops, of which 30 read the result of the
immediately preceding op** — critical path 23 dependent ops. Only 12 ops are
independent of their neighbour, and 8 of those 12 are the trivial `A*y` terms.
Live set: **5 values across the two sub-steps, 42 within one**.
That is the physical basis for the stall pool: a chain 23 deep on an in-order
FPU whose results are not available to the next instruction.

## 4. THE CHEAP TEST OF THE SAME HYPOTHESIS — ILV UNDER HALF-OS
`EB_VCF_ILV` (two voices' ladders woven together) had a hard `#error` against
`EB_HALF_OS_VCF` and so had **never been tried** on the 2-sub-step ladder.
It is now implemented and **PROVEN BIT-EXACT: 750,000 random (input, G, k)
vectors with evolving state over the measured domain, returned floats compared
by memcmp of BIT PATTERNS and both 168-byte `eb_vcf_state` structs compared
bytewise — ZERO mismatches.** Endpoints forced (G at both extremes and 0, k=0
and k=3.981).

**BUT IT SPILLS.** Xtensa objdump, shipping flags:

    eb_vcf_tick        411 instr/voice,  9 stack stores
    eb_vcf_tick2       389 instr/voice, 40 stack stores   <- 4.4x the spills

By the work order's own rule ("if a draft spills to the stack inside the
sub-step loop, it has already lost — count stores before counting cycles")
this draft has lost on registers. Only the board can say whether the stall
removal pays for the spills anyway. **22 instructions saved, 31 extra stores.**

### AND THE THING THAT MATTERS MOST FOR THE NEXT SESSION
**ILV HAS NEVER BEEN MEASURED ON SILICON IN ANY CONFIGURATION.**
`esp32s3/flash/juno_s3_ILV.bin` and its control `juno_s3_BEST_noILV.bin`
(both 2026-08-08) were "built, gated EXACTLY 0, sent — and never measured"
(DOUBT_OPUS.md). A grep of the whole repo finds no cycle number for ILV.
**The lever is UNDECIDED, not dead**, and a flash of those two existing
binaries would settle the interleave hypothesis for the 4x ladder for free.

## 5. TOOLING BUILT
`tools/engineb/asm_diff.py` — work order step A1. Operation-multiset
comparison of a hand .S against the compiler's -S reference. **Teeth run and
PASSED:** a CONTROL (body shuffled AND float registers permuted) PASSES, so
the checker is not merely testing file equality; deleting an `add.s`,
substituting `madd.s`, changing an immediate and changing a load offset are
each CAUGHT and named. The fused-multiply-add rule is ABSOLUTE — a file
compared against ITSELF still FAILS if it contains `madd.s`. Its own limits
are written into the file: **it cannot prove in-chain ORDER**, and order
changes within an FP dependency chain change rounding. Only the on-silicon
vector test (S2a) can prove that.

## 6. A TRAP FOR WHOEVER BUILDS THE KERNEL
`tools/engineb/qemu/build.sh` has **none of the shipping fork flags wired in**
(only `EB_PITCH_FAST` and `EB_FORK`). With `EB_HALF_OS_VCF=1` the ladder is a
DIFFERENT FUNCTION BODY (`eb_vcf_ladder.c:519`). **A reference generated
without that flag is the wrong ladder**, and the multiset diff would then lie
in the most convincing possible way.

## 7. UNRELATED BUT BANKED THE SAME NIGHT — THE FX RINGS ARE 23x OVER-ALLOCATED
`JUNO_EB_RING_PROBE=1`, all 36 scenarios, deepest read behind each write
pointer:

    t1    31,007 used / 524,288 allocated      t23    536 / 8,192
    t5_0  15,503 / 524,288                     t5_2   741 / 8,192
    t5_1  15,503 / 524,288                     t5_3   705 / 8,192
    e5       205 / 1,024                       t4_0/1  71 / 8,192

Rounded to powers of two the whole ring set needs **~270 KB, not 6.10 MB** —
and 270 KB may fit in the S3's 512 KB of INTERNAL SRAM, which after tonight's
+700-cycle PSRAM lesson is a placement question worth measuring.
CAVEAT, stated: 31,007 is the deepest read THIS BANK produces. A correct
allocation must be derived from the delay-time parameter's MAXIMUM, not from
observed lag. That derivation is not done.

## 8. THE HEAD POINTER
1. **Flash the two ILV binaries that already exist** (`juno_s3_ILV.bin` vs
   `juno_s3_BEST_noILV.bin`) — zero build cost, and it decides the interleave
   hypothesis on silicon, which is the hypothesis the whole kernel rests on.
2. Build a half-OS ILV firmware (bit-exact, above) and sweep it. 22 fewer
   instructions against 31 more stores is a question only the board answers.
3. Only then the hand kernel, per ASM_KERNEL_WORKORDER.md, with the QEMU flag
   trap in §6 fixed FIRST.
Required capture: ~620 of a measured ~790-cycle pool.
