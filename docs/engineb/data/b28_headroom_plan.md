# b28 — the headroom plan after silicon (2026-08-27)

O4 (worst-case headroom) has two independent deficits. Both are now measured on
the board, and the levers are sorted.

## The two deficits
1. **STEADY STATE** — a quiet block runs ~197 µs / ~259 cyc over its period
   (b12/b15). This is core 0's per-sample voice cost. It exists at rest, so
   chunking cannot touch it; only removing or moving per-sample work does.
2. **WORST CASE** — the four DELAY TYPE 5 patches (5,16,21,49) spend +835..+1480
   extra cyc in the delay stage (b16 confirmed on silicon, b27). This is a
   burst-shaped spike on top of the steady state.

## The levers, sorted by what silicon showed

### For the steady-state deficit
- **VCA move (subset of voices)** — the main lever. b27 measured vca/vcf = 0.542
  on silicon (QEMU's 0.352 was wrong by 54 %), so VCA-only overshoots the
  306–426 window. The subset-of-voices version (b26 branch, recommended) sizes
  the moved set to 0.542. Board-free to build + prove bit-exact; one flash to
  confirm the cycle benefit. Cost: +2.9 ms latency.
- **The small EXACTLY-0 levers** — L-B (LFO tail, `EB_LFO_TAIL_CR`), P3 (dead
  stores), L-A (`EB_DCO_WT_LIVE_CR`). All three are IMPLEMENTED and OFF, from
  b24, ~125–364 cyc combined, EXACTLY-0. Board-free to validate + enable. Every
  cycle these save is a cycle the VCA move does not have to carry.
- **New levers** — the b28 lever-hunt workflow is auditing every hot voice
  module (vcf 610, vca 330, dco_wt, lfo, decim, prologue) for further bit-exact
  savings, each adversarially verified to keep the null EXACTLY 0.

### For the worst-case deficit (the four t5 patches)
- b21 closed the obvious t5 reductions: the 101 persistent state writes ARE the
  algorithm and bit-exactness forbids dropping any; restrict/aliasing and ring
  placement were refuted; EB_ZEROCOEF found only 4 of 65 coeffs always zero.
- b21's fallback (master-chain split across cores) was RE-PRICED in b22 as NOT
  bit-exact (feedback delivered a chunk late is a sonic change) on top of 5.8 ms.
- So the worst-case lever is genuinely hard. But it matters only for 4 of 64
  patches, and the steady-state levers plus chunking may bring even those under
  budget once core 0 is lighter. Re-measure the four t5 patches AFTER the
  steady-state levers land, before re-opening the split.

## Order of work (board-free first)
1. Lever hunt (running) → ranked bit-exact savings list.
2. Validate + enable L-B, P3, L-A; prove null EXACTLY 0 via make engineb.
3. Implement the subset VCA move; prove null EXACTLY 0 on host.
4. ONE flash: measure the combined steady-state relief + re-measure the four
   t5 patches.
5. Only if the four t5 patches still miss: re-open the worst-case lever with
   fresh numbers.

The invariant is unchanged throughout: audio never breaks; latency may grow.
