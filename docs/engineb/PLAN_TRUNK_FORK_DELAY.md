# PLAN: close the trunk DELAY null, propagate to the fork, push both
(for the next session; written 2026-08-17, after the 100k-seed campaign)

## Facts this plan stands on (all measured this session)
- `make verify` (src/) is GREEN, rc=0, 21/21 PROVEN. The 4 delay-cell fix
  (77db6d0) is in and proven; 100,000 random full states, 0 differing cells.
- `make engineb` is RED at the CLEAN CONTROL `[engine_all]`: DELAY type 2
  (residual -4.6 dB rel), DELAY type 3 (-0.9 dB rel), 6 scenarios, worst
  global 2.1 dB rel. Log: scratchpad/engineb2.log (dies with the container —
  re-run to regenerate; do not trust the path to persist).
- ATTRIBUTED: identical failure with 77db6d0 reverted (scratchpad/
  nb_prefix.log, same numbers). The null break PRE-DATES the delay fix.
- The `voiceidleskip` tooth is repaired (3ad0b12). It asserted, so the whole
  teeth battery after it NEVER RAN before this fix — the DELAY null break
  could be as old as 61e3a2c or older. Do not assume it is recent.
- engine_b does NOT duplicate the fixed constants: eb_master_coefs.c reads
  them per patch via `CF(base, cell)` (cells 6396432, 6497392, 10693312,
  102560). The src/ fix flows into the trunk through the state blob. The
  same must be CONFIRMED for the fork's device recall path, not assumed.

## Step 1 — isolate the module (minutes, read-only)
`python3 tools/engineb/null_b.py --module delay_t23 --quick`, then
`--module delay_t5`, then `--module none` (self-test, must be EXACTLY 0).
If delay_t23 alone reproduces the -4.6/-0.9 dB residuals, the defect is in
eb_delay_t23.c or its coefs. If only `engine_all` fails, suspect a
cross-module interaction (master coefs publish order — see eb_recall.c
comment on MC publish applying the new patch's delay).

## Step 2 — find when it broke (bisect, gate = the Step-1 command)
The teeth were blind, so git history is unlabelled. Bisect engine_b/ commits
with the Step-1 reproducer as the gate. Candidate first: 61e3a2c
(EB_LFO_FREERUN, touched eb_render.c voice-gating) — the same commit that
broke the tooth. FREEZE the tree during every run (defect 2026-08-13).

## Step 3 — fix in engine_b, trunk rules
Trunk never approximates: the fix must restore null EXACTLY 0 at the gate
thresholds, all 64 patches. One reversible commit. Re-derive from src/ (the
proven side), never from captures.

## Step 4 — full gates, in order
1. `make verify` (src/ must stay GREEN — the fix must not touch src/).
2. `make engineb` full (not --quick). The repaired voiceidleskip tooth must
   be SEEN TO BITE (caught >= 1) — it has never bitten since the anchor
   broke.
3. Device recall on the fork: tools/engineb/devrecall_gate.py — confirms the
   four fixed cells reach the S3 fork's recall path (CONFIRM, not assume).
4. Fork sonic gate per FINAL_GUIDE track rules.

## Step 5 — push
All on `push -u origin <current claude/* branch>` (retry 2s/4s/8s/16s).
No PRs unless asked. Update FINAL_GUIDE health lines: regressions first.

## Step 6 — then, and only then
Headroom for fork worst cases (B3/B4 per FINAL_GUIDE): DELAY TYPE 2/3/5
patches ~6,800 cyc vs 5,442 budget is the standing invariant violation.
Fixing the trunk null FIRST matters because worst-case cost must be measured
on a bit-exact fork — a wrong delay is a wrong cost.

## Session hygiene (paid for today, twice)
- The container is reclaimed on inactivity; long gates die silently. Monitor
  the PROCESS (pgrep) not the log; check `uptime` when a log goes stale.
- `fresh` ref pickles in scratchpad/ survive restarts — relaunch, it resumes.
- Monitor in short steps (<= 5 min) so user messages are seen promptly.
