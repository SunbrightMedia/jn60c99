# Autonomous optimization campaign (2026-08-08, 8h AFK)

GOAL (fixed, non-negotiable): 6 voices + full FX, ONE ESP32-S3, real time,
1.0 dB/band. Only EXACTLY-0 changes (or 1.0 dB-passing) count. No hardware,
no bound relaxation.

MEASURED START: 15,036 cyc/sample, 6 voices, 2 cores, per-sample barrier, no
FX = 2.76x over the 5,442-cyc budget. With FX ~3.0x.

BUILT since, UNMEASURED on silicon: block barrier, dead-coef, VCF interleave.

KEY INSIGHT DRIVING THIS CAMPAIGN: the board measures c/i 1.56 with a FLAT
slope -- ~36 % of cycles are dependency-chain stalls. Interleaving attacks
CYCLES, which host instruction counts understate. So full-chain voice
interleaving is the largest EXACTLY-0 CYCLE lever even though callgrind shows
little instruction change. Silicon settles it; the gate proves it EXACTLY 0.

HOST COST PROFILE (6 voices, full fork, instr/sample):
  eb_vcf_tick 1909 + substep 1896            VCF ladder    3805
  eb_engine_render_range                     plumbing      1723
  eb_dco_wt_tick                             DCO           1153
  eb_vca_tick                                VCA/HPF       1114
  eb_vcf_res_tick                            resonance     1042
  eb_env_tick                                envelopes      952
  eb_pitch_fork_eval                         pitch          649
  eb_glide_tick                              glide          485
  eb_vcf_cv_tick                             cutoff CV      438
  (reverb 475, chorus 432, delay 311 -- once, not per voice)

PLAN:
  1. Exhaustive per-module audit (workflow): provably-zero coefficients, dead
     stores, redundant recompute, strength reduction, interleave dependency
     map. Every coefficient-zero claim verified against all 128 patch sets.
  2. Build full-chain voice interleaving: 2-wide variants of every hot
     per-voice module, woven into render_range's pairwise pass. Gate EXACTLY 0
     per module and composite.
  3. Any dead-arithmetic wins the audit finds, verified and gated.
  4. Firmware built per milestone for the user to measure on return.

LOG (appended as work completes):

## CAUTION recorded early (zero-coefficient scan)

A general scanner (/tmp/zeroscan.c) found 60+ float coefficient slots that are
0.0 in all 128 factory (note,gate,voice) sets, across modcv, vcf_cv, vca, dco,
lfo, glide and others. THEY MUST NOT BE BLINDLY DELETED. GOAL.md is binding:
"this byte is 0 in every factory patch is not an excuse to skip it" -- recall
must be correct for ANY preset. A factory-bank zero is only deletable if it is
STRUCTURALLY zero (zero for every possible preset by construction, like the
12/18 dB VCF taps on an always-4-pole filter). Each candidate needs a
structural proof, not a bank measurement. The audit workflow's verify stage is
tasked with exactly this distinction. Coincidental zeros are left alone.

## Strategy lock

The safe-for-any-preset levers, in priority:
  1. Voice interleaving -- BIT-EXACT BY CONSTRUCTION regardless of coefficient
     values; it only reorders independent voices' identical arithmetic. Safe
     for any preset. Each 2-wide module carries a bit-exact unit test as its
     safety net (as eb_vcf_tick2 does), and the composite is gated EXACTLY 0.
  2. Block processing -- bit-exact, any preset.
  3. STRUCTURALLY-zero coefficient deletions only, each with a structural proof.
Everything ships only after the standalone gate is re-proven EXACTLY 0.
