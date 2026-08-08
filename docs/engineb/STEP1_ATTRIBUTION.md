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
