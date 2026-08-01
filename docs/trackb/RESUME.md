# RESUME — 2026-08-01, Track B start

## Live workflow runs (resume these; completed agents replay FREE from cache)

    Workflow({scriptPath: "/tmp/claude-0/-home-user-jn60c99/851980e2-931d-52da-bb74-16fb8562b242/scratchpad/mem_lever.js",
              resumeFromRunId: "wf_bb26ffa8-cb1"})   # memory lever  <- HIGHEST VALUE
    Workflow({scriptPath: ".../workflows/scripts/trackb-cost-attribution-wf_e520c39d-046.js",
              resumeFromRunId: "wf_2d260d91-659"})   # cost attribution
    Workflow({scriptPath: ".../workflows/scripts/ssx-portable-harness-wf_37c70714-d7d.js",
              resumeFromRunId: "wf_1e2ac6fe-eb1"})   # portable framework

Scripts also live under
`/root/.claude/projects/-home-user-jn60c99/851980e2-931d-52da-bb74-16fb8562b242/workflows/scripts/`.
If the container is gone, rebuild from docs/trackb/CONSTRAINTS.md + MODULE_ORDER.md.

An earlier pair of runs (wf_e520c39d-046, wf_37c70714-d7d) had all 25 agents
killed by turn interrupts. Their journals hold NULL results — do not try to
recover them, just re-run.

## State

**P1 CLOSED.** The port ran on real silicon. Numbers in CLAUDE.md and the box at
the top of docs/ROADMAP_EMBEDDED.md. Headline: 8 voices = 93,288 cyc/sample
against a 8,333 budget = **11.19x OVER**, SysClk 400 MHz not 480.

**Track B: still ZERO voice code rewritten.** native/voice_render.c is a verbatim
fork. What exists now that did not before:

* `docs/trackb/CONSTRAINTS.md` — the user's binding target. 8 voices, ALL FX,
  48 kHz. 6 voices is the ONLY permitted compromise and only as a last resort —
  and it buys ~5%, so it is never the plan.
* `docs/trackb/MODULE_ORDER.md` + `CANARY_SURVEY.txt` — all nine module ranges
  surveyed. Order is now decided by measurement, not by PLAN §3's guess.

## Do next, in this order

1. **Read the memory-lever verdict.** It tests the largest known lever: per-voice
   state is 10,512 B x 8 = 86 KB and fits AXI SRAM many times over, while E4
   measures scattered SDRAM at 6.26x the cost of AXI. A pure relocation changes
   NO float operation, so it stays bit-exact and needs no sonic gate. Cheapest
   possible win.
2. **Close the DCO blind gates.** M2 (964-1021) and M3 (1022-1075) are 5/12
   observable. Charter gate #4 forbids rewriting behind a blind gate, so the
   highest-value rewrites are BLOCKED until the scenario set reaches those lines.
3. Only then rewrite modules, in gate-quality order crossed with cost share.

## Standing corrections a future session must not undo

* "Memory placement is not a lever" was WRONG and is withdrawn. E3's 1.05x shows
  the CACHE cannot help (416 KB working set vs 16 KB L1), not that memory is not
  the bottleneck. See CONSTRAINTS.md.
* PLAN §3's module order is disproven. M1a is the worst-gated module at 2/13.
* E3's ABSOLUTE numbers (287k vs E2's 93k for the same workload) are a 3x
  discrepancy and UNRECONCILED. Quote the ratio only.
