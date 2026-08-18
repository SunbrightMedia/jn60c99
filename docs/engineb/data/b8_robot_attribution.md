# B8 — the robot keybed names the real deadline threat, and it is not O2
2026-08-18, build a4d5152-dirty, S3L_STRESS=1, board e8:f6:0a:a7:d7:0c,
~333 s, all 64 patches + ~33 stress cycles, 13,174 machine-generated events.
PROVEN (executed) unless marked.

## 1. O1 IS PROVEN AT SCALE. 13,174 events, nothing lost, nothing torn.
    EVQ: sub=13174 ref=0 del=13174 dep=0 hi=19 par=0 torn=0
Against the human run's 313 events this is 42x the traffic, including a phase
that submits one event EVERY BLOCK (172/s, far past any human), and:
  * sub == del exactly -- not one event dropped or duplicated;
  * ref = 0 -- the queue never filled;
  * torn = 0 -- no torn publish, over 13,174 chances, at ~172 submits/s
    against a lock-free consumer. The barrier argument stays INFERRED (a
    detector that never fires is evidence of absence, not proof), but it now
    has 13,174 opportunities behind it rather than 313;
  * hi = 19 of 63 slots at peak. The queue is correctly sized -- roughly 3x
    headroom over the worst burst the robot could produce.
O1 IS DONE.

## 2. THE ATTRIBUTION WORKED, AND IT CLEARED FOUR OF SIX STEPS
    O2m: rs=9 in=0 rc=0 nt=1 cf=8 ck=0      (sums to burst=18, as it must)
INSTALL, PORT RECALL and CHECK never overran -- not once in ~190 patch builds.
The misses are RESEED (9) and the COEFFICIENT steps (8). Reseed is the single
largest step (~440,000 cyc, the BURST line's own figure) so that is the shape
expected. Eight from the coefficient steps at ~140,000 cyc each is NOT, and
§3 explains why: those blocks were not carrying only a coefficient step.

## 3. ⚑ THE REAL FINDING: A NOTE BURST IS 1.06-1.27 M CYCLES, 7.9x ITS PLAN
FINAL_GUIDE C4 states the note path "now rebuilds ONLY the voices the
allocator names ... Expected ~135,000 cycles." MEASURED, every block that
carries one:

    t    cyc    gap_us   nb(cyc)    nb_ms   verdict   (period 5,804 us)
    284   5383     8917   1064438    4.44   late
    314   5271     8627   1064266    4.43   late
    288   8785    11513   1198204    4.99   late
    278   9359    12667   1248497    5.20   MISS
     67   9430    12730   1266349    5.28   MISS

A note burst is 4.4-5.3 ms of work inside a 5.8 ms block, and it runs
UNCHUNKED, in one lump, exactly where the patch burst used to. It is 1.6x
core 0's whole measured slack (~650,000 cyc, b6_split_sweep.md). So:
  * every block carrying a note burst runs LATE by construction;
  * a block carrying a note burst AND an O2 step is what pushes past 2
    periods -- which is why cf=8 exists. Those eight misses are not the
    coefficient step being too big; they are a 140,000-cycle step landing on
    a block already 1.06 M cycles over.

THE ORDER OF THREATS IS THEREFORE INVERTED FROM WHAT O2 ASSUMED. O2 chunked
the patch burst, which is now the SECOND largest single-block cost. The
largest is the note burst, which nothing chunks.

WHY THE 135,000 FIGURE WAS WRONG IS NOT YET ESTABLISHED -- it is a plan
number, not a measurement, and `nb` is the first measurement of it. Candidates
(all INFERRED): the shadow copy eb_recall_build_voices makes (18,788 + 1,712
bytes) before rebuilding; the allocator naming more voices than one; and
eb_devseq_events running the port's whole note path per event. The next build
should split `nb` the way BURST: is split, rather than guess.

## 4. WHAT THIS DOES NOT CHANGE
un = 0 for the entire run -- the DMA carried every late block, so none of this
was audible. THE INVARIANT IS ABOUT THE DEADLINE and 18 + 167 misses is a
violation whatever it sounded like. CRC matched throughout; rst counted 4
mid-build re-requests; blk read 15 on every completed build.

## 5. THE NEXT MOVE, and it reuses everything O2 built
Chunk the NOTE burst with the same machine: eb_recall_chunk_* already builds
one voice per step and is gated bit-identical over all 64 patches. A note
touches a few voices, so a chunked note burst is 2-4 steps, not 15. Do that
BEFORE tuning O2's reseed step -- fixing a 440,000-cycle step while a
1,060,000-cycle one runs unchunked is optimising the smaller half.
