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
per-sample arm in IRAM (iram_check PASS on this ELF, 57 symbols). So the IRAM
move helped the instruction side but the remaining cost is the PSRAM ring
access itself — the boot probe's own line says it: scattered PSRAM read
229.4 cyc vs internal 19.9. DELAY TYPE 2/3/5 is LATENCY, not maths, exactly
as the probe predicted. Next lever per M4: ring access batching/prefetch or
internal-SRAM ring segments — not more IRAM.

## 3. THE B4 COUNTERS — the burst is still guilty, and the timer anomaly stands
- gap 12,5xx-17,1xx µs on patch-step seconds vs the 11,608 µs two-period
  limit; gap ~5,8xx-5,9xx µs on quiet seconds. miss advances 1-4 per
  patch step. C10 (spread the burst) remains the binding invariant fix.
- ovr_late still counts on ~60 % of blocks, and drift climbs (+4,8xx by
  t=178) — the esp-timer-vs-I2S disagreement recorded in b4_first_run.md §5
  is unchanged and still owed a resolution before `late` means anything.
- burst 2.02-2.26 M cycles, unchanged.

## 4. WHAT THIS DECIDES
The IRAM work alone did NOT close G2 for the three delay classes. Non-delay
patches have 160-370 cyc of margin at 2 voices; delay patches have negative
margin ~1,200. The headroom track's next target is the PSRAM ring latency.
