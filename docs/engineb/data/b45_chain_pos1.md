# b45 — CHAIN4 position 1 alone on silicon: the drive to green

Date: 2026-09-03. One board, no wires, four flashes. All PROVEN(executed).
Goal: the ORIGINAL-port classic (trunk + EXACTLY-0 levers + EB_CLASSIC),
chip 1 of the 4-board chain (voice slot 7 + chorus + master + DAC).

## The four flashes, and what each one taught

| build | cyc | verdict | defect found |
|---|---|---|---|
| 1 (sha 3e...? first chain img) | 6,343 | starve (~30 desc/s) | RX ran the BITWISE CRC over 4 KB/block on the audio path (~960 cyc/sample) AND pattern-scanned a floating wire. Playbook lesson re-paid: the pairwise link's table-CRC twin existed for exactly this. |
| 2 (crc fix) | 6,207 | still starve | the CRC was the SMALL half. Core 0 carried voice (~5,045) + prologue (~717) + reverb-out (250) while core 1 idled (wait ≈5,000). |
| 3 (+S3L_PROLOGUE_C1) | 5,474 | zero misses 4 min, but 32 cyc OVER budget; drift +11.5 µs/s, deficit +2/s | prologue moved to core 1; reverb-out still on core 0. |
| 4 (−S3L_REV_PIPE: FULL master on core 1) | **5,217** | **PASS** | none new. |

## The passing state (build 4, app sha 75ec3bd7f)

- cyc=5,217 vs 5,442 budget (96%). drift FROZEN −21. B5 deficit FROZEN
  at 123 (boot offset). un=0. gap = period.
- Core 1: full master (fx 913–1,073) + prologue batch (~808) ≈ 1,900 —
  wide margin for the future RX/inject work when a peer exists.
- CLASSIC byte law + chord-6 CRC MATCH on every flash.
- No-peer fast path proven: rx=0, pat_disc=0, zero chain cost, single
  board runs as a normal instrument.

## The honest core-0 budget arithmetic this run settles

One exact voice (5,045) + prologue (717) does NOT fit one core (5,442).
The chain windows only work with S3L_PROLOGUE_C1 + full-master-on-core-1.
This carries to positions 2-4 (their builds already have both) and to any
future exact-voice layout: BUDGET PER CORE = voice + ~350 overhead, so
ONE exact voice per core is the maximum, with the prologue and master
hidden on a core that has fewer voices.

## The ~21/10k "misses" -- ATTRIBUTED AND CLOSED (5th build)

Read from the code, not guessed: the miss detector measures block-START
spacing (d = t0 - t_prev), and fires at d > 2x period. Build 4 runs
FASTER than the DAC, so the loop PARKS inside the blocking DAC write;
CHUNK=256 against the driver's 255-frame DMA descriptors makes that park
occasionally span two descriptor completions -> spacing > 2 periods with
the queue FULL. That is the writer being AHEAD -- the opposite of
starvation -- which is why B5 deficit stayed flat and un=0 throughout.
Fix: the miss test now subtracts the previous block's measured park
(wrote_blocked_us, already measured); a real stall has park ~0 and still
fires, and the 't' tooth stalls outside the write and still fires.
late= stays RAW (documented early warning). Fixed build: app sha
a65f1b86f. NOTE for the bench: positions 2-4 pace on the slave-TX write
(20 ms timeout) -- if their park shows the same artifact, the same
subtraction applies there; measure first.

## The park attribution was REFUTED (6th flash, robot build)

The robot run (app sha 85dad3c51, park fix active) still shows quiet
misses at ~25/10k, with REAL gaps of 8-22 ms roughly every 4 s -- the
patch-step period. The park subtraction was correct for the AHEAD case
but was NOT the miss cause; the earlier "closed" claim is withdrawn.
Throughout: drift and deficit FROZEN, un=0 -- the 6-deep DMA queue (35 ms)
absorbs every stall, the INVARIANT holds. The robot run also proved the
note path and the event tap (CHAINev sent counting, allocator busy).
Next: the G4 worst-gap probe (7th build, sha 3e79c3662) splits the worst
block into eng/tail/park/UNSEEN each second -- the attribution is read
from silicon, not argued.

## G4 ATTRIBUTION (8th flash, probe run): THE REPORTER, AGAIN

The probe run shows a ~1 Hz blocker up to 17 ms whose phase slides
~1.54 ms/s (the linear unseen staircase 911->2452->3994->5531->7077->
8619, then wrap). The only 1 Hz machinery in the build is the REPORTER's
serial flood -- and CLAUDE.md ALREADY lists "reporter UART
(S3L_REPORT_SECS)" among the CLOSED CHUNK=64 stall causes. The stall was
re-derived instead of grepped (playbook 84 rule 1, violated by its own
author on the day it was written). Mostly the stall lands outside the
stamped regions (unseen); every ~5 s it lands inside the e0 region
(eng 12-17 ms) -- both faces of the same reporter cycle, largest when the
MSPP per-patch flood prints.

Fix (9th and final build, app sha deb8cea2d): S3L_REPORT_SECS=10 and
EB_MSPROF off (its collapse numbers are already recorded here and in
b44). Blocker 10x rarer and ~5x smaller. MSPROF is measurement-only --
the answer key never included it, so coefficients are unchanged.

## FINAL ATTRIBUTION (9th flash refuted the reporter too): THE DONATED TICK

The 10 s-report build kept the SAME miss rate -> the printing was not the
cause either. The cause, read from the code and matching every number:
the audio loop DONATES one 10 ms tick per second (vTaskDelay(1)) so
rpt_task can run on a saturated core. That donation was deliberately
re-anchored OUT of the gap meter -- but the B4 miss detector, added
later on a different anchor, was never taught, so every donation whose
tick-rounding exceeded ~5.8 ms counted as a missed deadline:
1/172 blocks x ~half = the observed 21-25/10k, and 10+5.8 ms = the
observed 13-17 ms "gaps"; the tick-vs-block beat = the 1.54 ms/s
staircase. THREE wrong attributions preceded this (park, reporter rate,
reporter volume) -- each was a real cost, none was THE counter's cause.
Fix (10th build, sha 5a326f29d): the donation adds itself to
wrote_blocked_us, riding the same subtraction the miss test already does
for the DAC park. Detector correction only; zero audio-path change.

## VERIFIED GREEN (10th flash, sha 5a326f29d, 160 s robot run)

B4 miss burst=0 note=0 quiet=0 at every report; B4rate 0/10k throughout.
The donation now rides park (G4 park up to 10,199 -- exactly the
subtraction design). drift FROZEN -17, deficit FROZEN 139, un=0.
CHAINev sent counting, byte law + chord-6 CRC MATCH. Position 1 is GREEN.

One red line remains and it is NOT a fault: "HEALTH: *** the event queue
REFUSED a submit". The ROBOT floods the 255-deep event queue faster than
the EV_DRAIN_MAX=8/block drain (EVQ dep pinned at 255, ref= climbing).
A refusal is the queue protecting itself -- correct behavior under a
deliberate flood. The rule-4 latch treats ANY refusal as a fault, so it
fires under stress by design. Press 'r' (robot off) and refusals stop.
No audio effect: the INVARIANT held the whole run. If the latch noise
bothers the bench, gate it on the robot flag in a future build -- not
worth a flash on its own.

## FIRST FOUR-BOARD RUN (11th flash owed): THE TDM4 CHUNK NEVER FIT A DESCRIPTOR

Wires on, hop 1<-2 per section 6, control proven both ways (hs=OK on board 1
and board 2). AUDIO dead: board 1 `ok=0 bad=92 lock=searching` with rx_chunks
crawling (~1.5/s where ~172/s is one per block); board 2 `pace=freerun
timeouts=5126`. Both boards printed, at every chain port and on every boot,
`i2s_common: dma frame num is out of dma buffer size, limited to 255`.

READ FROM THE CODE, and it matches every number: s3c_aud_start asked for
dma_frame_num = CHUNK = 256. TDM4 x 32 bit is 16 B a frame, so a chunk is
4096 B while the driver's descriptor cap is 4092 -- clamped to 255 frames =
4080 B. NO SINGLE DESCRIPTOR CAN EVER HOLD ONE CHUNK. The zero-timeout read
then returned a PART of a chunk and the drain loop's `g != want` test
DISCARDED it (`got` was only assigned on an exact full read), so ~99 % of the
received audio was thrown away and the pattern lock never had a whole chunk to
scan. The transmit side had the same hole: a part-written chunk was rebuilt
from scratch the next block, which loses slot alignment.

Why pos-1-alone never showed it: with no peer the RX takes the drain-only fast
path, and the earlier TWO-board link ran 2 slots (2048 B), which fits one
descriptor. The defect is specific to TDM4 -- i.e. to CHAIN4.

Fix (all four images rebuilt): dma_frame_num = CHUNK/2 (a count that DIVIDES
the chunk, desc_num 8), plus persistent part-transfer offsets rx_off/tx_off on
both sides -- a chunk that arrives in pieces is now completed across blocks
instead of dropped, and a part-written chunk is finished before a new one is
built. New counter `part=` on the CHAINup line prints partial reads.
BENCH SIGNAL: the `dma frame num ... limited to 255` warning MUST BE GONE.

## Open
- Note path + event tap: PROVEN by the robot run.
- Positions 2-4 and every hop remain silicon-unproven. Next: wire hop
  1<-2 (CHAIN4.md section 6); criterion hs=OK, mix=OPEN, CRC MATCH.
