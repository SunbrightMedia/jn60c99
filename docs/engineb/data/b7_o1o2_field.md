# B7 — O1 field-proven, O2 close but not closed, three new open questions
2026-08-18, build aaefa87-dirty, board e8:f6:0a:a7:d7:0c, ~362 s, all 64
patches ~1.4 passes, THE FIRST KEYS EVER PRESSED through the event boundary
(313 key events, human). PROVEN (executed) unless marked.

## 1. O1 IS FIELD-PROVEN. The queue lost nothing under a real mashing.
    EVQ: sub=314 ref=0 del=314 dep=0 hi=3 par=0 torn=0
Every submitted event was delivered: sub == del, depth drained to 0, ZERO
refusals, ZERO torn publishes, high-water mark 3 of 63 slots. The old path
would have DROPPED a note whenever two keys landed inside one block; the user
mashed five keys at once repeatedly (nb ~1.06 M shows note bursts running
back to back) and nothing was lost. The 64-slot queue is generously sized:
hi=3 under deliberate abuse.

## 2. O2 CUT THE MISSES ~20x AND IS NOT DONE. burst=17, not 0.
Old behavior: 1-4 missed blocks EVERY program change (b4). This run:
    B4: miss burst=17 quiet=153        over ~180 patch/gate builds
about one miss per ten builds instead of two or three per one. The chunked
machine works — blk=15 every time, restarts counted (rst=5), CRC still
matching, notes waiting politely on live builds. But the acceptance is
burst=0 and 17 is not 0. WHICH STEP overruns is not yet attributed — the
next build records miss-by-step so the guilty state names itself.

## 3. THREE OPEN QUESTIONS THE RUN RAISED, recorded before they are forgotten
  a. THE STEPPED BUILD COSTS MORE TOTAL CYCLES THAN THE MONOLITH: bst reads
     2.2-3.5 M against the monolith's 2.1 M. Some is cache cold-start per
     step, some is dev_burst_verify's CRC in BST_CHECK. Spread beats lump for
     deadlines, but the overhead should be known, not guessed.
  b. bst ALTERNATES ~2.26 M / ~3.3 M every second. The demo loop re-requests
     the SAME patch on every hold/release (dev_request(dev_patch, gate) at
     each 1.5 s / 0.7 s edge), so ~2 builds run per chord cycle — the two
     values are the gate-on and gate-off builds. That is pre-existing
     behavior now made visible; a same-patch gate flip probably does not need
     a full rebuild (it is a note-path event), which would remove ~2 builds/s
     of background load. NOT changed yet — measured first.
  c. gap_max reads ~8.4-9.0 k µs on nearly EVERY second (before: ~5.9 k on
     quiet seconds). Something lengthens one block per second by ~2.7 ms.
     PRIME SUSPECT: the report itself — this session added three printf
     lines (~120 chars, ~10 ms of UART at 115200) to the once-per-second
     report. A measurement that delays the thing it measures is playbook 12's
     oldest shape. INFERRED, not proven; the miss threshold (11.6 k) is not
     crossed by it, so it inflates `late`, not `miss`.

## 4. WHAT THE NEXT BUILD CARRIES (the user asked the right question)
A human mashing keys is a poor stimulus generator: unrepeatable, unlogged,
and it cannot hit a patch boundary on purpose. S3L_STRESS=1 compiles a
scripted driver that submits through the SAME boundary (source KEYBED), in
five repeating ~2 s phases: baseline silence, single notes, TWO KEYS IN ONE
BLOCK (the old drop case), an event every block, and notes aimed exactly at
live patch builds. Plus two health latches that should always have existed:
a refused submit and a torn publish now redden HEALTH (rule 4).
