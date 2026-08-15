# H7 vs ESP32-S3 — measured, not estimated

*2026-08-15. Answering a HYPOTHETICAL question from the user: is the S3 the best
compute per dollar for the fork? `END_GOAL.md` rules out a third or different
chip FOREVER. Nothing here changes the plan. It exists so the question has a
measured answer instead of an opinion, and because item 7 (the process must
repeat for the next synth) will ask it again.*

## The correction this document owes

On being asked, the first answer given was "the STM32H7 is about 3x the S3, chip
about $15". Both halves were loose:

* **3x was an ESTIMATE spoken as a fact.** It had not been run.
* **$15 was the CHIP ALONE**, in volume, in USD — quoted in a sentence the user
  reasonably read as a board price.

Playbook 46 applies to this project's own advice, not only to its code: a number
quoted is not thereby measured. So it was measured.

## Method

`tools/engineb/cost.py measure src/voice_render.c src/master_render.c
src/juno_dsp.c -I src --calls juno_voice_render=8 --calls juno_master_render=1`

One run, one rig, the SAME SOURCE compiled for both targets with each vendor's
real toolchain (`arm-none-eabi-gcc` fpv5-d16 hard-float; `xtensa-esp32s3-elf-gcc`
esp-16.1.0). Instruction counts are MEASURED-STATIC from real objects.
Cycles are MODELED — the rig's M7 arm is anchored to the one real SILICON number
this project owns (Daisy, 669,682 cyc/sample, agreement 2.5%); its S3 arm is
**calibrated against nothing** and carries a +/- 2x band. Read the ratio, never
the third digit.

## Result

| | Cortex-M7 (H7) | ESP32-S3 LX7 |
|---|---|---|
| cycles/sample, nominal [MODELED] | **48,032** | **84,866** |
| band | 24,105 .. 152,515 | 41,573 .. 272,148 |
| memory accesses/invocation [MEASURED-STATIC] | **2,872** | **6,171** |
| soft-float helper calls/sample [MEASURED-STATIC] | **0** | **168** |
| libm calls/sample | 26 | 26 |
| clock | 480 MHz | 240 MHz |
| budget @ 44.1 kHz | 10,884 cyc/sample | 5,442 cyc/sample |
| sealed port vs budget | 4.4x over | 15.6x over |

    cycle ratio    84,866 / 48,032          = 1.77x
    clock ratio    480 / 240                = 2.00x
    WORK PER SECOND, one H7 vs one S3       = 3.53x

**So "3x" was close — but for reasons that were not known when it was said, and
the reasons matter more than the number.**

## WHY the H7 wins, and why it is not mostly the clock

Half the advantage is clock. The other half is two structural facts, both
MEASURED-STATIC:

1. **168 soft-float helper calls per sample on the S3, zero on the M7.**
   `__muldf3` x51, `__adddf3` x27, `__extendsfdf2` x26 … These are DOUBLES that
   leaked into the DSP. The M7's fpv5-d16 does double precision IN HARDWARE, so
   it pays nothing. The LX7 FPU is single-precision only and has no divider, so
   each call is 25..180 modelled cycles.
2. **2.15x the memory accesses** (6,171 vs 2,872). ARM `ldm/stm/vldm` move a
   register list in one instruction; Xtensa has no equivalent.

## THE CAVEAT THAT DECIDES THE ANSWER

Both figures are for **`src/`, the sealed bit-exact port** — the thing engine B
exists to replace. The doubles leak and much of the access count are exactly what
engine B removes (see `COST_RIG.md`: shrinking 10,512 B/voice to <1 KB/voice
removes the term that is ~95% of the Daisy cost).

**Therefore 3.53x is the gap on UNOPTIMISED code, and it is an upper bound on the
gap that would remain after the fork's work.** Once the doubles are gone the S3
stops paying its single largest S3-specific penalty, and the ratio must fall. By
how much is NOT MEASURED and must not be guessed.

Note also: on the sealed port **neither chip is close**. The H7 is 4.4x over its
own budget. A single H7 would not have avoided engine B; it would have needed
less of it.

## Price — stated properly this time

| item | USD, volume | note |
|---|---|---|
| STM32H750 / H743 | $8 .. $12 | CHIP ONLY |
| ESP32-S3 module | $2 .. $4 | includes flash + PSRAM + radio |

A working compute module is not a chip. Add regulators, crystal, decoupling,
flash, PSRAM, and the connector: a realistic small-run H7 M.2-style module is
**$35 .. $60 CAD**, against roughly **$12 .. $20 CAD** for an S3 one. Two S3s
therefore remain cheaper than one H7 module, and the two-S3 plan is already
proven to fit 2 voices + FX in real time.

## The M.2 compute-module idea — separate, and good

The user's second idea is independent of chip choice and survives this analysis
intact: put the core on a generic module with a fixed connector; keep codecs,
jacks and patch storage on a specialised main board. That is a direct servant of
**END_GOAL item 7** — the process must repeat for the next synth. It lets the
core change without redesigning the analogue board, and it makes the two-chip
link a board-level interface instead of a wiring decision.

Recording it here as a BOARD-PLAN candidate. It is not a chip change and does not
touch the END_GOAL exclusion.

## Labels

* instruction counts, access counts, soft-float and libm call counts: **MEASURED-STATIC**
* M7 cycles: **MODELED**, anchored to real Daisy silicon within 2.5%
* S3 cycles: **MODELED, UNCALIBRATED, +/- 2x**
* 3.53x work-per-second: **DERIVED** from the two above; valid for the sealed port only
* post-engine-B ratio: **NOT MEASURED**. Do not quote a number for it.
