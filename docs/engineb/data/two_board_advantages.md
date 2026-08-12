# What the SECOND board buys, beyond cycles (2026-08-12)

Asked by the user. Worth writing down because the second chip has been framed
throughout this project as a cost -- "we need it because one is not enough" --
and three of the six items below are assets nobody had counted.

All arithmetic is from `layout_sweep.md`'s measured constants: voice 2,518,
FX 2,608, loop overhead 352, prologue+LFO ~921, budget 5,442.

## 1. Chip A's core 0 has ~1,600 spare cycles/sample. MEASURED.

Chip A at 3 voices, no FX, 1/2 split (layout sweep row 5, whole loop 5,388):

    core 1   2 voices                2 x 2,518 = 5,036   <- the critical core
    core 0   prologue + 1 voice        921 + 2,518 = 3,439
             SPARE                                  1,597 cycles/sample

1,597 x 44,100 = **70.4 million cycles a second of free compute**, on a core
that is already in the design.

**That is where the whole instrument goes**: MIDI parsing, encoder scanning,
the LCD, preset storage, USB. Every one of those is bursty and
interrupt-driven, which is exactly what hurts an audio core -- and on one board
they would land on top of a full one.

Consequence for FINAL_GUIDE: **C6 and C7 are close to free in cycle terms.**
That had not been established and it changes their risk, not their order.

## 2. The second board buys back ACCURACY, not only speed

    one board    8 voices / 2 cores = 4.0 voices per core
    two boards   6 voices / 4 cores = 1.5 voices per core   -> 2.7x per voice

Every approximation in the fork exists because ONE chip could not fit. The
three that cost accuracy rather than only instructions are `EB_HALF_OS_VCF`
and `EB_DCO_WT` (both REPOSITION ALIASES -- the relaxation the user approved in
F5) and `EB_CR_N=4` (control-rate decimation).

At 2.7x the compute per voice, some of them can be switched back OFF. Each
already has a measured cost and a sonic-gate number, so this is a measurable
question and not an argument.

**This reframes the second board: it is not only how the fork FITS, it is how
the fork stops being an approximation.** END_GOAL item 1, not item 4.

## 3. Chip A's 8 MB of PSRAM is entirely unused

The 6.16 MB of delay rings exist only on the FX chip (`delay_recall.c:397-408`
writes nine ring lengths as literal constants; `rings.c` proved the set is
identical over the whole bank and over a randomised bank). Chip A allocates
none of them.

Free for preset banks, a performance recorder, or sample storage. Competes
with nothing.

## 4. Smaller hot code per chip -- HYPOTHESIS, not a saving

Chip A never links the FX chain. The S3 executes flash-resident code through a
small instruction cache, so a smaller hot loop should behave better.

**Untested.** Flagged because it is the right shape to explain part of the
352-cycle loop overhead that no model contains, and because a hypothesis
recorded as a hypothesis is the rule here.

## 5. A supervisor

Chip A receives chip B's audio. If it stops, or its coefficient CRC disagrees,
chip A can **mute cleanly and print why**. One chip has nobody to check it.

## 6. The slave clock is a free sample-accurate tick

From the D1 decision: chip B needs no timer, no scheduler and no sync
protocol. Its I2S slave clock IS its "next sample" signal, delivered by
hardware from chip A.

---

## THE TENSION THIS CREATES, recorded so it stays a decision

Item 4 pulls against D4: **one firmware image flashed twice, role by strap
pin.** One image makes the two chips' arithmetic identical BY CONSTRUCTION --
equality becomes a hash comparison rather than an argument. Two specialised
images would need that equality PROVEN, and cross-binary float determinism on
two separately-compiled Xtensa images is untested here (it is risk R4 of
`DEVICE_RECALL.md`).

**Keep one image** until there is a measured reason not to. The icache
hypothesis is not yet that reason.
