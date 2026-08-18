# B4 second run — the fresh key passes CRC, the delay number is finally quotable
2026-08-18, MEASURE build (boot app version c2be14d-dirty = the regenerated
devcrc.h before its commit 7479ea3; the source bytes are identical), board
e8:f6:0a:a7:d7:0c, COM5.

## 1. THE MUTE IS GONE — the stale-key diagnosis was correct
`RECALL: CRC vs host answer key: 1 checked, 0 bad -- MATCH` at boot, and the
board stepped through patch 44+ with ZERO CRC mismatches — including patch 5,
the one that muted the first run. The regenerated `gen/devcrc.h` was the whole
fix; no code changed. The EBDEV_S→PSRAM suspect is EXCLUDED: the fresh key
matches with cells=0 (PSRAM placement) live.

## 2. THE DELAY NUMBER — G2 IS NOT CLOSED (PROVEN, executed)
Steady-state cyc per patch class, 2v+FX, un=0 throughout:

    non-delay patches (0-4, 6-15, 17-20, 22-44...)  5,069-5,682
    DELAY TYPE 2/3/5 patches (5, 16, 21)            6,526-6,772

Budget is 5,442. The delay patches are ~1,100-1,330 OVER, even with every
per-sample arm in IRAM (iram_check PASS on this ELF, 57 symbols).

⚠ THE PARAGRAPH THAT STOOD HERE IS WITHDRAWN. It read the remaining cost as
PSRAM ring latency, citing the boot probe's scattered-read row (229.4 cyc vs
internal 19.9). That row strides one cache line so every read misses, while a
delay tap walks the ring roughly in order -- it measured a pattern the delay
never runs. b5_fx_attribution.md adds the MOVING-TAP row (the delay's own
pattern): 29.9 cyc/tap, 7.7x cheaper, and locates the whole delta in core 1's
FX pass, where the real lever is LOAD BALANCE. See that file. Nothing here
below this line depended on the withdrawn claim.

## 3. THE B4 COUNTERS — the burst is still guilty, and the timer anomaly stands
- gap 12,5xx-17,1xx µs on patch-step seconds vs the 11,608 µs two-period
  limit; gap ~5,8xx-5,9xx µs on quiet seconds. miss advances 1-4 per
  patch step. C10 (spread the burst) remains the binding invariant fix.
- ovr_late still counts on ~60 % of blocks, and drift climbs (+4,8xx by
  t=178) — the esp-timer-vs-I2S disagreement recorded in b4_first_run.md §5
  is unchanged and still owed a resolution before `late` means anything.
- burst 2.02-2.26 M cycles, unchanged.

## 4. WHAT THIS DECIDES
The IRAM work alone did NOT close G2 for the delay patches. Non-delay patches
have 160-370 cyc of margin at 2 voices; delay patches have negative margin
~1,200. The next target was written here as "the PSRAM ring latency" and that
was wrong -- b5_fx_attribution.md measured it and the target is the LOAD
BALANCE between the two cores.
