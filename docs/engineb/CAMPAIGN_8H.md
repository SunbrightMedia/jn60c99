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
