# b29 — the headroom lever hunt: 14 bit-exact survivors, ranked (2026-08-27)

A 21-agent adversarial workflow hunted every hot voice module for bit-exact
cycle savings. Each candidate was attacked by an independent refuter whose
default was "this breaks EXACTLY 0". 14 survived, ~323 cyc/voice before
de-duping (several entries overlap). Raw journal:
`docs/headroom_hunt_journal_2026-08-27.jsonl`.

## The distinct levers, by value and by how they must be PROVEN

| lever | ~cyc/voice | proof needed | status |
|---|---|---|---|
| **A/R/Rk dead in half-OS VCF** | 30 | COMPILE-dead (the 4x arm's `(void)A/R/Rk`); make engineb trunk byte-id | **LANDING (b29)** |
| L-B LFO tail (`EB_LFO_TAIL_CR`) | 90 | fork-vs-fork bit + `EB_LFO_TAIL_TOOTH` red + CR-coupling `#error` | queued |
| wt_live CR-gate (L-A parts 3/4) | 85 | fork-vs-fork bit + NEW mid-note program-change scenario + `EB_CR_LERP_PITCH` `#error` | queued |
| dco_live `.g/.pw/.pwm1/.pwp1` dead under EB_DCO_WT | 30 | fork-vs-fork bit OR poison-NaN tooth (runtime deadness) | queued |
| `eb_lfo_wrap`→`eb_dco_wrap` (proven-equivalent) | 25 | prove the two functions are bit-identical, then swap | queued |
| smaller dead stores (nsvf s04_out, vcf_res s7568, dco_wt pd_no, decim copy) | ~10 total | fork-vs-fork bit | queued |
| reuse hp_in subtraction (eb_vca_hpf) | 0.5 | fork-vs-fork bit | low priority |

## The one killed
`L-B call-site validation` — the call site is not exact "by construction of
this module"; the validate-existing survivor supersedes it with the real
argument (SHIP CR flags make the consumers read only on even cr_ph).

## The tool the queue needs: a FORK-vs-FORK BIT runner
b24 flagged it missing and it still is. Every queued lever changes FORK output
(or provably does not), and the fork sonic gate is SPECTRAL — it cannot prove
EXACTLY 0. The runner: build the ship fork twice (lever off via
`EB_HEADROOM_KEEP_DEAD=1`, lever on by default), render the same scenarios,
compare sample streams byte-for-byte, expect 0 differ; seen-to-fail by breaking
one lever. The `EB_HEADROOM_KEEP_DEAD` toggle is already wired on the A/R/Rk
site for this. Building it is the next headroom step and unblocks the whole
queue at once — plus the mid-note program-change scenario null_b lacks.

## Why A/R/Rk ships now without that runner
It is COMPILE-dead, not runtime-dead: the half-OS arm already `(void)`-casts
A/R/Rk, so the compiled object has zero consumers for them. Removing the
computation of a value nothing reads cannot change any output float — no
runtime measurement can disagree. `make engineb` proves the trunk (half-OS off)
keeps the lines and stays byte-identical. That is the complete proof for this
one; the others are runtime claims and wait for the runner.

## What this buys
If the queue lands in full, ~250–300 cyc/voice of bit-exact core-0 relief.
Across 3 core-0 voices that approaches the measured ~259 cyc/sample steady-state
deficit (b12) on its own — which would shrink, and possibly remove, how much
the VCA move (b26/b27) must carry. Re-measure on the board after the queue
lands, before sizing the VCA cut.
