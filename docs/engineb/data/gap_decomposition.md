# THE GAP IS SMALLER THAN WE HAVE BEEN QUOTING (2026-08-10, Opus 5)

All inputs MEASURED on the user's S3: floor 1,020 · voice slope 3,068 ·
head 693 · 0xd0 = 6,681 · budget 5,442.

## THE DECOMPOSITION NOBODY WROTE DOWN
`0xd0` wakes voice 4 (core 0, S3L_SPLIT=5) and voices 6,7 (core 1):

    core 0 = head 693 + 1 voice          = 3,761
    core 1 = 2 voices, NO prologue       = 6,136
    loop   = max(core0, core1)           = 6,136     (board reads 6,681)

**THE PROLOGUE IS NOT ON THE CRITICAL CORE.** The binding constraint is
simply TWO SOUNDING VOICES ON ONE CORE, because six voices across two chips
and four cores is 1.5 voices per core, and the best integer split is 2/1.

    budget 5,442  ->  voice must be <= 2,721
    today  3,068  ->  **-347 per voice, not -620**

The -620 figure came from `(6,681 - 5,442)/2`, which charges the gap against
two voices while ALSO carrying the measurement's own head and sync overhead.
The requirement on the VOICE is the smaller number.

## WHY THIS MATTERS FOR WHAT IS ALREADY BUILT
Tonight removed, by MEASURED Xtensa instruction count:
  * EB_NOLIBM   14 fminf/fmaxf CALLS -> 0. Seven per voice at 62 instructions
    = ~434 instructions/voice. Trunk nulls EXACTLY 0; fork sonic gate 3.17 dB.
  * EB_VCF_MAPFAST  __divsf3 in the ladder 8 -> 4, tick 265 -> 251 inline.
    ~76 instructions/voice. Sonic gate 3.17 dB.
Together roughly **500 instructions/voice** off a 2,275 baseline.

WHAT THAT IS IN CYCLES IS NOT CLAIMED HERE. Two facts bound it and they
point opposite ways: measured c/i is ~1.35, so instructions are not cycles;
but a windowed ABI call OCCUPIES issue slots rather than waiting in them, so
call removal should convert closer to 1:1 than the control-rate experiment's
arithmetic removal did (which returned ~60 cycles for several hundred
instructions). **The board decides. No landing number appears in this file.**

## WHAT THE AT-REST PATH IS AND IS NOT WORTH
A prior pass reported the at-rest voice at 93 instructions with "~26 spilled
induction pointers". DISASSEMBLY OF THE SHIPPING BUILD SAYS OTHERWISE: the
voice loop addresses its arrays by INDEX (`slli a5,6` + `add` off one base),
not by strength-reduced pointers. And on the critical core under 0xd0 there
is exactly ONE at-rest voice, so the whole path is worth ~127 cycles there,
not ~465. EB_ATREST_O1 already took the floor 1,904 -> 1,020. **Not the next
lever.**

## THE SPLIT IS A SHIPPING DECISION, NOT A DETAIL
With `S3L_SPLIT=5` the allocator's fill-from-7-downward puts a 3-note chord
on voices 5,6,7 -- ALL THREE on core 1. That is 9,204 cycles and it fails by
70 %. A shipping two-chip build MUST map voices to cores so three sounding
voices split 2/1. `0xd0` exists precisely to measure the balanced case, and
the balanced case is the only one that can fit.

## HEAD POINTER
1. Flash `juno_s3_NOLIBM.bin` (built, sent) -- reads the two changes above.
2. The remaining four `__divsf3`: the S3 FPU HAS hardware divide
   (`__XCHAL_HAVE_FP_DIV` is 1; div0.s/divn.s/recip0.s/nexp01.s/maddn.s/
   mkdadj.s/addexpm.s all assemble for this target) yet GCC still emits the
   ROM call and no tested flag changes it. Inline asm is the open route and
   the sequence is specified to be correctly rounded, so it may even be
   trunk-legal. UNMEASURED.
3. The ILV pair still unmeasured -- it settles the asm kernel's premise free.
