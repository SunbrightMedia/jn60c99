# B4's first run on silicon — the counter works, the burst is guilty, the key is stale
2026-08-18, MEASURE build (app 5087e7d), the user's SECOND board
(MAC e8:f6:0a:a7:d7:0c — the first board, a8:3c:04, also carries this build but
its console is the native USB port, which the USB-MIDI known-non-enumeration
defect takes down; console was found on the second board's UART, COM5).

## 1. THE B4 COUNTER WORKS, AND WAS SEEN TO FIRE ON REAL EVENTS
`B4: ovr=<late>/<miss>` printed and counted from the first second. HEALTH went
red. No tooth build was needed: real deadline misses fired the detector, which
is stronger evidence than a plant. The tooth flag stays in the tree for future
re-verification.

## 2. THE PATCH-CHANGE BURST VIOLATES THE INVARIANT — now COUNTED
While patches stepped every 4 s: 2–3 misses per step, gap 12,637–17,051 µs
against the 11,608 µs two-period limit, burst ~2.06–2.25 M cycles. `un=0`
throughout (the DMA carried it), but THE INVARIANT IS ABOUT THE DEADLINE and
the counter now proves each violation. C10 — SPREAD THE BURST — is the binding
fix and has a numeric acceptance test at last: miss must not increment across
a program change.

## 3. REGRESSION LINE: RECALL CRC MISMATCH AT PATCH 5 — CAUSE IDENTIFIED
    chip rc=8fea9e5c mc=f670052f | host key rc=9f4ab9ea mc=2ac4eb7a
The firmware muted and forbade quoting cycle figures. CAUSE (established from
git, not guessed): the baked answer key `esp32s3/main/s3_listen_meta.h` is from
3a48b11, 2026-08-11 — FIVE DAYS BEFORE the four-cell delay-recall fix (77db6d0,
2026-08-16). Patch 5 is the first stepped patch that reads the fixed cells
(DELAY TYPE 5: 6497392, 10693312, 102560). The chip computed the CORRECTED
values; the key holds the stale ones. **The mismatch is the fix arriving on
silicon against a key nobody regenerated.** Patches 0–4 (types 0/1) passed for
the same reason.
NOT fully excluded until the key is regenerated: the EBDEV_S→PSRAM move — the
firmware's own placement print (`cells=0`) notes the publish contract assumes
internal-only. If a fresh key still mismatches, that is the suspect.
FIRST STEP NEXT SESSION: regenerate the key + boot image
(gen_listen_coefs.py / gen_devcells.py) from the fixed tree, rebuild, reflash.

## 4. WHAT MAY AND MAY NOT BE QUOTED
QUOTABLE (before the mismatch, patches 0–4, coefficients verified at boot):
  cyc 5,104–5,514 at 2v+FX, un=0 — under or at budget 5,442.
  The memory probe: PSRAM scattered read 228.6 cyc (this print IS the source
  of the ~244 figure CLAUDE.md carried; the "no source" note is corrected).
  Burst ~2.1 M cyc; burst split: voice coefs 1,121,654 + master 130,809 +
  reseed 439,984 + install 166,101 + port recall 230,938 + notes 15,198.
NOT QUOTABLE: every figure from patch 5 on (mute + wrong coefficients),
  including the tantalising ~5,35x–5,55x on TYPE 5/2/3 patches. If real, the
  IRAM work closed G2 — but that sentence may not be asserted until a fresh
  key lets the run pass CRC unmuted.

## 5. TWO ANOMALIES FOR THE NEXT SESSION, recorded not resolved
  * miss increments ~1/s even in steady state while the same second's gap_max
    reads ~5,93x µs — under the 11,608 threshold. A miss with no matching gap
    is inconsistent; suspect the once-per-second report path (vTaskDelay(1)
    delays one block; the racy reset of gap_max at the snapshot could hide it).
  * ovr_late counts ~60 % of blocks with block spacing ~5,93x µs against a
    5,804 µs period, and drift climbs ~+10 ms/s after the mute. Both may be
    esp_timer-vs-I2S clock disagreement rather than real lateness. The late
    counter is the EARLY WARNING, not the verdict; the verdict (miss) is what
    must read 0.
