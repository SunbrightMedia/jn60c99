# ARE WE REAL TIME? (2026-08-10 night)

**UNKNOWN, AND THAT IS THE ONLY HONEST ANSWER.** The board is the sole
instrument that measures cycles, and it has not run `juno_s3_FAST3.bin`. Five
projections in this project's history were made by answering this question
from arithmetic instead, and all five failed.

## THE REQUIREMENT, MEASURED
`0xd0` decomposes by core:  core 0 = head 693 + 1 voice = 3,761;
core 1 = 2 voices = 6,136; the loop is the max. So the prologue is NOT on the
critical core and the binding constraint is TWO SOUNDING VOICES ON ONE CORE.

    budget 5,442  ->  voice must reach 2,721
    today  3,068  ->  **-347 cycles/voice**

## WHAT CAME OFF TONIGHT, all by disassembly of real Xtensa objects
    EB_NOLIBM       14 fminf/fmaxf CALLS -> 0 on the voice modules  ~434 instr
                    (one picolibc fminf is 62 executed instructions: a 30-instr
                     body plus 2x __issignalingf and 2x __isnanf. The ternary
                     is `olt.s` + `movf`. Two instructions against sixty-two.)
    EB_VCF_MAPFAST  ladder cutoff map 3 divisions -> 1                ~76 instr
    EB_FPDIV        __divsf3 calls 12 -> 6 across four modules,
                    stack stores 26 -> 16                          ~60-70 instr
    ------------------------------------------------------------------------
    ~570 instructions/voice off a 2,275 baseline

## WHY I WILL NOT CONVERT THAT TO CYCLES
Two facts bound the conversion and they point opposite ways:
  * c/i is ~1.35, so instructions are NOT cycles here;
  * but a windowed ABI CALL occupies issue slots rather than waiting in them,
    so removing calls should convert closer to 1:1 than the control-rate
    experiment did -- that one removed several hundred instructions of
    ARITHMETIC and returned ~60 cycles, because the pipeline was stalled, not
    busy.
The removal (~570) exceeds the requirement (347). **That is arithmetic, not a
prediction.** Three of the five failed projections had exactly this shape.

## THE STANDARD DID NOT MOVE
    trunk null, EB_NOLIBM + EB_FPDIV, all 36 scenarios   EXACTLY 0
    fork sonic gate, all three levers                    3.17 dB
3.17 dB is the control's own number -- the build the user approved BY EAR.
Two of the three levers are BIT-EXACT and cost nothing sonically at all;
only MAPFAST is an approximation, and it did not move the number.

## A LATENT TRAP CLOSED THE SAME NIGHT
`eb_vcf_tick2` (the two-voice interleaved ladder) carried a SECOND COPY of the
cutoff map that MAPFAST had not converted. With both EB_VCF_ILV and
EB_VCF_MAPFAST on, one engine would have run TWO DIFFERENT CUTOFF MAPS across
its voices -- a silent divergence of exactly the class this repo catalogues.
Both lanes are converted, all four flag combinations build, and the comment
at the site says the two copies must stay identical and why.

## WHAT IS LEFT, ranked, and none of it is guesswork
1. **Flash FAST3.** Everything above is unmeasured on silicon.
2. **The ILV pair** (`juno_s3_ILV.bin` / `juno_s3_BEST_noILV.bin`) still
   settles the asm kernel's premise for two flashes and no build.
3. Remaining helper calls, by static relocation count at the shipping flags:
   `eb_dco_wt` 8 __divsf3 + 60 fmodf, `eb_lfo` 22 fmodf, `eb_pitch` 2 floorf,
   `eb_vcf_res`/`eb_dcoprep` 2 each. MOST ARE ON UNTAKEN ARMS -- the earlier
   census puts eb_dco_wt at 207 EXECUTED instructions per voice against 696
   static -- so the static counts are an upper bound and must be walked on the
   executed path before any of them is called a lever.
4. The master/FX chain has never been priced since the fork changed. It is the
   SECOND CHIP's budget and it carries the same easy fminf/fmodf class.
5. The FX rings are allocated at 6.10 MB and never read deeper than ~270 KB
   rounded; 270 KB may fit in internal SRAM.
