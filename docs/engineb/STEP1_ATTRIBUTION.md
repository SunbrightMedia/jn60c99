# Step 1: per-module CYCLE attribution on silicon (ablation method)

## Why ablation, not CCOUNT probes
The per-voice chain is twelve calls in one hot loop. Bracketing each with a
cycle-counter read changes inlining, register allocation and scheduling around
every one of them. This project has been misled THREE times by measurements
that perturbed or mis-metered their subject (interleave judged on instruction
count; 903 KB of flash-resident wavetables never looked at; a cache fix that
measured zero). Ablation leaves the remaining code, its inlining and its cache
layout untouched and reads the delta off the number the board already prints.

## The baseline this must reconcile against (MEASURED, SRAM build)
  voices  mask   c0 c1   cycles   marginal
    0     0x00    0  0    1,927
    1     0x80    0  1    5,572    +3,645
    2     0xc0    0  2   10,031    +4,459
    3     0xe0    0  3   14,493    +4,462
    4     0xf0    1  3   14,220      -273   <- NOISE FLOOR ~300 cyc
    6     0xfc    3  3   14,441      +221

THREE STRUCTURAL FACTS:
 1. Six voices cost the SAME as three (14,441 vs 14,493). Both cores are
    saturated and balanced. PARALLELISM IS NOT A LEVER ANY MORE.
 2. Critical path = 3 voices + floor. (14,441-1,927)/3 = 4,171 cyc/voice.
    Real time allows (5,442-1,927)/3 = 1,172 without FX, 772 with FX.
    => per-voice arithmetic must fall 3.6x (no FX) to 5.4x (with FX).
 3. The 4-voice point measured 273 BELOW the 3-voice point with an identical
    critical path. Anything under ~300 cycles is inside the noise floor.

## The builds
Each replaces ONE module's work with a cheap constant; everything else is
untouched. The audio is deliberately wrong -- these measure COST ONLY and are
refused by the gates (#error against EB_GATED_BUILD). Ablation OFF is
re-verified EXACTLY 0 on all 36 scenarios.

  abl_vcf.bin     EB_ABL_VCF     vcfo = nmixo            (the 4x ladder)
  abl_vcfres.bin  EB_ABL_VCF_RES reso = cut              (resonance shaper)
  abl_vca.bin     EB_ABL_VCA     vout = vcfo*e1          (VCA+HPF stage)
  abl_env.bin     EB_ABL_ENV     e1,e2 = gate            (both envelopes)
  abl_dco.bin     EB_ABL_DCO     q[0] = 0                (wavetable DCO)
  abl_pitch.bin   EB_ABL_PITCH   cv = off+pit            (pitch evaluator)

CONFOUND, RECORDED: abl_dco.bin is 900 KB smaller than the others -- ablating
the DCO lets the linker drop the wavetables entirely. Its delta therefore
includes the tables' memory pressure, not just the tick's arithmetic. That is
useful (it bounds "DCO + its tables") but it is NOT the tick alone.

## Procedure
Flash each, run ~45 s, record ONE number: wake=0xfc at t=41s.
  delta = 14,441 - (that build's 0xfc)
Divide by 3 for cycles per critical-path voice. Reject anything under 300.

## What the answer decides
The largest delta names the module to redesign first, by the method that
already worked once: the wavetable DCO replaced the port's TOPOLOGY with a
cheaper structure whose RESPONSE passes the 1.0 dB sonic gate (2,864 -> 1,090
host instr, PASS at 0.40 dB). The VCF, VCA, envelope and CV chains have never
had that treatment and still run the plugin's desktop topology verbatim.

## RESULT (2026-08-09, MEASURED on the user's own S3, 240 MHz, 44,100 Hz)

Baseline: floor (wake=0x00) 1,927 · 6 voices (wake=0xfc) 14,441.
Per critical-path voice = (14,441 - 1,927) / 3 = **4,171 cycles**.
(6 voices occupy 3 slots on the longer core, so the divisor is 3, not 6.)

  module          floor    6v      voice cost   share
  ------------------------------------------------------
  VCF ladder      1,645   10,909     1,083      26.0 %
  VCF res shaper  1,804   11,182     1,045      25.1 %
  PITCH eval      1,935   13,257       397       9.5 %
  VCA + HPF       1,835   13,211       379       9.1 %
  DCO wavetable   1,927   13,456       328       7.9 %
  ENV x2          1,904   13,546       291       7.0 %
  ------------------------------------------------------
  attributed                          3,523      84.5 %
  unattributed                          648      15.5 %

Each cost = 4,171 - (that build's 6v - that build's floor) / 3.

**THE HEADLINE: the VCF complex (ladder + resonance shaper) is 2,128 cycles =
51 % of a voice.** Nothing else is above 10 %. Any plan that does not cut the
VCF complex cannot reach real time, and any plan that halves it gains more
than removing the DCO, the pitch evaluator and both envelopes together.

The unattributed 648 is notecv, glide, noisemix, dcoprep, the per-sample
wiring and the loop itself. It is real but it is not a target.

### Two facts the floors carry
1. **The floor MOVES with the ablation** (1,645 .. 1,935). At-rest voices
   still tick their filters, so ablating the ladder makes the 0-voice floor
   cheaper too. This is why the cost is a DIFFERENCE OF DIFFERENCES and not
   `baseline_6v - build_6v`; the naive form over-charges the VCF by ~94
   cycles/voice.
2. **THE FLASH-CONTENTION THEORY IS DEAD.** `abl_dco.bin` is 900 KB smaller
   (the linker drops the wavetables), yet its floor is 1,927 -- IDENTICAL to
   the baseline floor to the cycle. Flash-resident constant tables cost this
   engine nothing measurable. Do not re-open it.

### Distance to the goal
Target 5,442 cycles/sample wall clock. Present 14,441 = **2.65x over**.
Budget per critical-path voice: 1,172 without FX, 772 with FX.
Present 4,171. The VCF complex alone (2,128) is 2.75x the whole with-FX
per-voice budget.

### STEP 2, named by the measurement
Redesign `eb_vcf_res` (1,045 cycles, 25 %) by the wavetable DCO's method:
its input is slowly varying, its output is memorylessly consumed (the bias
law permits ~1e-5 there), and its cost is one `expf`, a 14-term polynomial
and two divides -- all tabulatable. The ladder itself (1,083) is NOT reopened
by this: 2x half-rate measured 3.17 dB and all three ADAA orders failed, both
recorded closed.
