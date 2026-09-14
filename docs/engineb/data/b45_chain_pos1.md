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

## THE DMA FIX IS PROVEN ON SILICON (12th flash, all four boards)

The `dma frame num ... limited to 255` warning is GONE, and the numbers move
with it: `rx=1700` per 10 s (one chunk per block, where the broken build got
~15), `part=0`, and **`lock=YES`** -- the training pattern locks for the first
time on a chain hop. Board 1 stayed green throughout: miss 0/10k, drift frozen
-16, un=0, deficit frozen 130.

STILL OPEN on the hop: `ok=0` with `bad=` climbing (~10/s) and `mix=closed` --
the CRC adverts never redeem, so the mix gate correctly refuses to open.
`pat_disc` also keeps climbing while locked, which means the lock is being
LOST and re-taken. The audio now arrives; what fails is agreeing on WHICH
chunk it is. Next probe target: the advert/redeem path (lock_off alignment
after a relock, and whether the upstream is still sending pattern words after
peer_alock is set).

## FIRST CARRIER-MAP RUN ON WIRES (2026-09-13): THE PACER STOLE THE CONTROL PINS

Bench rewired all three hops old map -> carrier map (audio 10/11/12 -> 9/10/11,
ctl 8/14+9/13 -> 5/47+6/46). Pos 1 alone stayed GREEN (cyc 4,935-5,279 vs
5,442; drift -20 and deficit 116, both frozen; un=0; miss 0/10k; CRC MATCH),
but every UP port on the chain read `rx=0, hs=no peer yet`.

Board 2's console named the cause on first read (playbook 85):
`i2s_common: GPIO 5 is not usable, maybe conflict with others`.
`i2s_start()` opens the DAC pacer (BCLK 5 / LRCK 6 / DOUT 7) on EVERY
position -- positions 2-4 pace on its blocking write while `pace=freerun` --
and the carrier map moved DOWN ctl UART onto IO5/IO6. The I2S driver took
the pins; every upstream chip transmitted into nothing. One advert leaked
through the contention and latched `hs=PATCH INDEX DIFFERS` on board 2's
down port -- read that state as DOWNSTREAM of the pin theft until proven
otherwise after the fix. The old bench map (ctl on 8/9/13/14) never
conflicted, which is why the b45 12th flash had hs=OK both ways.

Fix: chain positions != 1 keep the pacer channel but route every pin to
I2S_GPIO_UNUSED (internal clock + DMA pacing identical, B5 counters live,
zero audio-path change on pos 1 -- its build keeps the original gpio_cfg
verbatim). Full write-up: playbook 91. BENCH SIGNAL for the next flash:
the `GPIO 5 is not usable` warning MUST BE GONE on boards 2-4.

## THE RATE PROBE CONVICTS THE PACER (2026-09-13, same bench day)

Probe flash (rate counters only): board 2 DN fed 634,880 B/s of the
lawful 705,600 (90%); board 1 UP read 543,459 B/s (77%); board 2's
longest DN write wait was 39 us against a nominal 20 ms timeout. A
"blocking" pacer that never blocks named the defect: the LINKED write
passed pdMS_TO_TICKS(20) to an API that takes MILLISECONDS (playbook
92) -- 0 ticks at 100 Hz, non-blocking forever, on the chain AND on the
two-board link it was copied from. Second defect, same probe: the RX
discard path read once per block and starved recovery. Both fixed
(ms units; bounded full drain). Expected next flash: wmax in the
milliseconds, timeouts ~0, realign settles, ok= counts, mix=OPEN.

## AFTER THE UNITS FIX: FIRST CRC REDEMPTIONS; THE CUSHION IS THE RESIDUAL
## (2026-09-13, one-shot log, all four boards)

With the ms-units fix: every sender feeds ~99.5% of the wire (was 90%),
timeouts 0 everywhere, and hop 3<-4 redeems its FIRST CRCs (ok=43->110
over 70 s) -- pos 4 is the cleanest sender because it has no UP port.
Hops 1<-2 and 2<-3 still churned. The probe named the residual: write
waits of 42-677 us mean the TX ring runs near-EMPTY (just-in-time
writer, no cushion), so any loop stall still underruns; and the RX
realign still paid a discard (receivers read ~90% of the wire).
Fixes: (1) i2s_channel_preload_data fills the slave-TX ring BEFORE
enable -- the blocking write becomes the true pacer and must be SEEN TO
BLOCK (wmax ~ms is the next flash's tooth); (2) realign heals by
memmove of the already-read tail (the next chunk's own start) instead
of discarding two chunks' worth with extra reads.

## CUSHION RUN: RECEIVERS AT FULL RATE; PATCH 48 CONVICTS THE BUDGET
## (2026-09-13, second one-shot log)

The memmove heal works: every receiver now reads at full chunk rate
(rx +172/s) with part=0. The preload cushion was consumed during the
8 s recall boot (the wire drains 23 ms of cushion long before the loop
starts) -- wmax stayed sub-ms, so the ring self-fills only where the
loop outruns the wire. The log's real verdict is CAPACITY: the robot
froze all four chips on patch 48, and on that patch cyc = 5,156 (pos1)
/ 5,412 (pos2, gap 5,866 us > period) / 6,014 (pos3) / 5,757 (pos4)
against the 5,442 budget. Positions 3-4 run their loops at 152-161
blocks/s against the wire's 172.3: they CANNOT feed their hops, locks
cycle, and no CRC can redeem. Patch follow itself is PROVEN (all four
chips agree on 48). Hop 3<-4 still redeemed ok=50->110 in the gaps.
Action: bring-up set holds patch 0 (S3L_STRESS off on pos 1); the
patch-cost budget question moves to the capacity arc with this first
real number: AN EXPENSIVE PATCH ON A MIDDLE CHIP IS A CHAIN FAULT, not
only a local overrun.

## IN-BAND CRC ON SILICON: THE LAW WORKS; THE SEAMS REMAIN (2026-09-13)

Host gate first (sum law EXACTLY 0 x64, in-band law round-trips, three
teeth bite), then the flash. Verdict: in-band redemption is PROVEN on
silicon -- hop 3<-4 redeems ~46/s. Hops 1<-2 and 2<-3 stay at ok=0, and
the new forensics say exactly why: the same sealed chunk (marker seq 3,
aligned, in-band crc 8deddcfd on the wire) computes a DIFFERENT crc at
the receiver on different arrivals. One sealed chunk has one crc;
varying results = COMPOSITE chunks, frames of two chunks around an
underrun seam. POS3 also caught an ALL-ZERO chunk (no markers): raw
underrun output. The churn state itself costs cycles (scan + realign +
relock), keeping loops over period, which makes the seams that sustain
the churn -- two self-sustaining states, and boot always lands in the
bad one because the marked stream starts on a near-empty ring. Fix
aimed at the landing: rings 8->16 descriptors (46 ms armor both
directions) and a cushion of 4 sealed SILENT marked chunks stuffed at
the peer_alock 0->1 transition -- silence is free while the mix gate is
still closed, and those chunks redeem instantly.

## THE LOCK SURVIVES SEAMS (2026-09-13, after the first mix=OPEN)

The rings+cushion flash produced the project's FIRST mix=OPEN (hop 3<-4,
transient) and redemptions on 2 of 3 hops. The residual is the CASCADE:
a chip churning on its UP hop (scan + relock load) stalls its DOWN
sender, seaming the hop below -- the chain heals only top-down. The
amplifier is the relock trigger: 8 missed chunks threw away a good lock
and restarted pattern training, though under in-band CRC a miss convicts
one seamed chunk, never the alignment (the marker realign holds that per
chunk). Change: the lock now survives seams and drops only after 256
consecutive misses (~1.5 s dead stream = rebooted/unwired peer). With
relocking near-zero, the unlocked pattern-scan cost leaves the steady
state and the storm loses its fuel.

## ROOT CAUSE, PROVEN: THE JUDGE TORE ITS OWN EVIDENCE (2026-09-13)

The discriminator flash split the verdict by hop. Hops 2<-3 and 3<-4:
auto-clear turned the invisible descriptor replays into counted zero
chunks (z ~25/s) -- their 2-voice senders underrun even idle on patch 0
(loops 6.4-6.8 ms vs the 5.8 ms wire): the CAPACITY item, now measured
clean. Hop 1<-2: z=0, a never-underrunning sender, heals verified ok
(hv 6.7:1) -- and the CHAINmf frame dump convicted the receiver itself:
every bad chunk read [frames 0..127 of seq S][frames 128..255 of seq
S-1] -- the NEW chunk's head over the OLD chunk's tail, cut at the
boot-constant arrival phase (97 one boot, 98 the next). Only one
mechanism writes that: the drain-to-latest loop kept reading INTO THE
SAME BUFFER after completing a chunk, partially overwriting it BEFORE
the CRC judged it. Present since the first chain build; every earlier
"seam" statistic on this hop was this artifact. Fix: judge-on-completion
-- each completed chunk is verified the moment it completes, before any
further read; up to 4 judge per block; the last good one feeds the mix.

## HOP 1<-2 GREEN: FIRST SUSTAINED mix=OPEN (2026-09-13, gate-hold flash)

The flagship hop holds: mix=OPEN at every report, ok ~82/s, bad ~6/s,
pat_disc=0 for the whole run. THE LINK LAW IS PROVEN END TO END ON
SILICON on the one hop whose sender keeps up. Hop 3<-4 opens and
re-opens (ok ~154/s, bad ~50/s from pos4's real underruns); hop 2<-3
still closed (pos3 underruns worst). The blocker is now ONLY capacity,
and the storm-free numbers are finally honest: pos3 e0=6,132-6,167 us
and pos4 e0=6,115-6,170 us PER BLOCK, IDLE, PATCH 0, against the
5,804 us period -- while pos1 (one voice + chorus + master + DAC +
MIDI) runs ~5,15x cyc. A 2-voice chip with its second voice on core 1
must not out-cost pos1 on core 0; something specific is wrong and is
NOT yet attributed. Next session: core-0 attribution on pos4 (the
lightest failing case: 1 voice + DN port, no UP), then the re-balance
or the fix the attribution names. Do not guess ahead of it (playbook
84/46).

## THE IDLE-COST "DEFECT" REFUTED BY PROVENANCE (2026-09-13, research pass)

Idle voice cost == active voice cost is THE PLUGIN'S OWN LAW, not a
defect: the binary renders all 8 voices every sample unconditionally
(RENDER_LOOP_LOG.md 43-68; numVoices pinned at 8, PROVEN), the port
reproduces it (juno_driver.c 117-122), and the one state-derived idle
predicate ever written (eb_env_atrest) was MEASURED unsafe in 153/162
coefficient sets (BUDGET_STATUS.md 43-60) and is uncalled. atrest is a
fork lever, legal ONLY as the chain's WINDOW selector. Therefore the
2-voice chips' shortfall is permanent load, not a sleeping bug:
core 1 = windowed voice + prologue runs ~600-900 cyc/sample over the
5,442 budget at all times. One suspicious number remains before any
hunt: a CORE-1 voice measures ~5.7k cyc/sample where core 0's measures
~5.05-5.3k -- same code. Attribute core 1 (voice vs prologue vs
overhead) BEFORE shaving anything (playbook 46).

## C1AT ATTRIBUTION LANDS: THE STRUCTURAL LAW IN NUMBERS (2026-09-13)

MEASURED on silicon (C1AT, per-block stamps): prologue = 714-734
cyc/sample on every chip (b45's 717 CONFIRMED); one core-1 voice at
patch 0 = ~4,832; empty voice window = 77. A 2-voice chip's core 1 =
4,832 + 720 + 77 = ~5,630 vs the 5,442 budget on the CHEAPEST patch;
with b44's average exact voice (5,045) the sum is 5,765. THE LAW:
VOICE + PROLOGUE NEVER FITS ONE CORE, on any patch, and every possible
window assignment gives two chips exactly that pairing. Required shave:
~320-350 cyc/sample from voice+prologue, EXACTLY-0 levers only
(user-binding). Note for the method log: the split-probe keys stayed
in capture.py one run too long and polluted their own follow-up run
(pos3/4 at 11-12 ms after t=45/60) -- a probe is REMOVED the day its
answer lands. mix=OPEN reproduced 11 times even so.

## SCOPE DIRECTIVE: THE FULL PANEL (2026-09-13, user-binding)

The user redirected the machine's scope mid-shave: the four boards run
the FULL ORIGINAL PORT -- delay and reverb included, NO 1982 byte law.
"By nailing the ORIGINAL port, the CLASSIC port falls into line." Every
budget number above stands (voice costs are panel-independent); what
changes is chip 1, which now carries the full master chain with the
nine PSRAM rings (the pre-classic rings_alloc path).

Done the same hour: EB_CLASSIC dropped from chain_gate.sh +
build_chain4.sh (kept identical); chain_gate.c gives the REF and CHAIN
masters PRIVATE zeroed rings (shared rings would corrupt both delay
tails and fail the sum law for a non-chain reason); boot triple +
answer key regenerated at full flags -- map complete, SUM LAW EXACTLY 0
on 64/64 patches WITH delay/reverb/e5 ticking, all three teeth bite.

SHELVED BY THIS DIRECTIVE: the classic-constant shave hunt.
tools/engineb/classic_scan.c (committed d981fe0) measured 343
byte-law-constant coefficient words (80 zero) as deletion candidates --
valid ONLY under EB_CLASSIC, so none of it may be spent on the full
panel. ⚠ KNOWN DEFECT recorded before shelving: that scan derives
coefficients WITHOUT PLAYING NOTES, so note-path smoother targets
(cv.k6864, lfo.k1856 -- the documented species) appear as false
constants in its report. If the tool is ever revived, the note axis
(devrecall gate.c notes() battery, silent-vs-noted diff) must be added
and toothed on those two cells FIRST. Do not consume the d981fe0
report as it stands.

NEXT LOG MUST ANSWER (one flash, run_test.bat): chip 1's full-master
cost on silicon (FXP fx= line + rings_alloc PSRAM print + un=), hop 1<-2
still green under full panel, and fresh pos3/4 numbers (C1AT v=/pro=,
spin_min/max attribute core 0 for free: spin~0 = core 0 critical,
spin large = core 1 critical).

## FULL-PANEL SILICON VERDICT + THE HUNT'S FIRST HONEST FINDING (2026-09-13)

Log c2415e52 (one bat run, four boards, full panel). MEASURED:
- pos1 (DAC): FULL FX chain fits. FXP fx=2608 v1=823 wait=0; the whole
  master (chorus+delay+reverb+e5) = ~2,608 cyc/sample on core 1, ~2,834
  cyc SPARE on that core. Audio un=0, no NaN. THE FULL ORIGINAL PORT IS
  PROVEN ON CHIP 1.
- pos3/pos4 (2-voice chips): C1AT v=5,044 pro=727. core 1 = 5,044+727
  = 5,771 vs 5,442 budget -> ~329 over, drift +11,970 and climbing.
  They starve the wire (B5 deficit 1,600), so pos2 then pos1 close the
  mix gate. The KNOWN gap, nothing new broke.
- Hop 1<-2 opens (mix=OPEN seen) but closes under the starvation from
  above -- not a link fault, a feed fault.

HUNT PASS 1 (module read, EXACTLY-0 only): the well is DRY.
- VCF ladder eb_vcf_tick (610 cyc, the fattest): the default path is the
  4x-collapsed exact recurrence; every coef (c9520/c9184/c9104/c9152)
  live, every term load-bearing. NO dead arithmetic. The one lever
  (EB_VCF_ZDF1X==2) DROPS THE NYQUIST ZERO = approximation, FORBIDDEN.
- VCA 330, decim 85, nsvf 54, noisemix 38: proven transcriptions, no
  structural zero.
- Already-spent exact levers: EB_ZEROCOEF (13 lfo + vcf-cv coefs),
  EB_VCF_DEADCOEF, EB_ATREST_BLOCK, EB_FUSE_VCA.
- Prologue 727 = notecv+cvgate+glide+LFO for voice 0; the LFO delay
  env chains through glide, so it cannot be split; EB_LFO_FREERUN
  mandates it every sample. IRREDUCIBLE by exact means.

THE ARITHMETIC THAT REMAINS: 6 voices x 5,044 + one 727 prologue PER
CHIP + one 2,608 master, on 4 chips x 2 cores where the master eats a
whole core. Any chip that renders 2 voices has BOTH cores at 5,044 and
the 727 prologue has no home. At least two chips MUST render 2 voices
(6 voices > 4 chips). So the gap is STRUCTURAL, not a missing micro-opt.

THREE EXACT-OR-NOT PATHS (a scope/risk decision, owed to the user):
 1. SHIP THE SHARED LFO DOWN THE WIRE. Chip 1 computes the 3 LFO floats;
    the 2-voice chips receive them instead of running the 727 prologue
    -> 5,044 < 5,442, gap CLOSED, bit-exact (shipped value == computed).
    COST: a per-sample wire dependency on a value that today every chip
    derives independently; a dropped packet corrupts pitch/PWM/filter mod
    rather than muting. New link machinery. Touches THE INVARIANT.
 2. CONTROL-RATE the CV chain (EB_CR_*): ~330 cyc recoverable, but it is
    an APPROXIMATION (lerp between computed samples). Forbidden by the
    ZERO-approximation rule unless the user reopens it.
 3. Accept 6 voices need a different split; re-derive whether a
    5-voice-max panel or a heavier per-chip balance exists. (Does not
    fit 6 exact voices; needs a scope change.)

NONE is a silent per-module tweak. The honest state: the FULL PORT works
per chip; the 4-chip SUM is blocked by 329 structural cyc with no exact
micro-shave available.

## THE TRIM LANDS + THE PIPE'S ARITHMETIC + THE DECISION RULE (2026-09-13)

LANDED (f1c3948, EXACTLY-0, teeth bite): the LFO's dead output tail
hand-deleted under EB_ZEROCOEF -- three wrap calls, eb_triangle, and
~15 float ops per prologue sample that fed only already-zeroed sums.
GCC could not remove them (fmodf is errno-opaque; objdump showed all
four wrap calls in the b45 image). Proof: REFCRC 64/64 identical with
the LFO ALIVE over 16,384 samples; fabs tooth 25/64 moved, wrap-skip
tooth 26/64. On the way, playbook 93 was paid: the chain gate had
rendered every green with a SILENT LFO (fixed, 79e8aaa).

THE PIPE'S ARITHMETIC (why the next flash measures before it builds).
Under EB_FUSE_VCA the movable one-chunk-late atoms are the VCF (~610)
and the VCA audio half (~240). Best split on a 2-voice chip:
  core 1 = voiceB front + vcfB + prologue(trimmed) ~= 5,434
  core 0 = voiceA full + vcaA + vcaB + LINK(X)     ~= 5,284 + X
Green at patch 0 REQUIRES X <= ~150 cyc/sample of link work -- and X
has NEVER been measured (the SLACK print never ran on a chain build;
fixed, 35c8138). DECISION RULE, stated before the flash: SLACK shows
core-0 own load; if X <= ~150 the vca/vcf pipe is built next (with a
revpipe-class host gate); if X > 150 the link path slims first (our
own code, no bit-exactness bar). The trim's own silicon verdict rides
the same log: C1AT pro= must drop vs 727.

## SEEDS BUILT; THE PATCH-48 WAR GETS ITS PLAN (2026-09-13, user-directed)

User order: seeds now, and the heavy-patch overage MUST be fixed. Done
and planned:
- SEEDS: stress_step phase 7 (CHAIN4_SOAK layer 2) BUILT and committed;
  compile-proven under S3L_STRESS=1. Rides the fix flash, runtime-gated.
- PATCH-48 CLASS (~570-970 cyc/voice over patch 0, MEASURED b45 robot
  freeze): the delta is DATA-DEPENDENT cost -- paths patch 0 never pays.
  Suspects, in order: flash-cache misses on wavetable mips under moving
  pitch (host/QEMU CANNOT see these -- the recorded measurement failure
  class), exp/slow-arm rates, set_pitch exponent recomputes. VERDICT
  INSTRUMENT: silicon, flash +1 (robot ON steps patches; per-patch cyc
  lines, b42 idiom). No host number will be quoted for this delta.
  Honest size at patch 48: a 2-voice chip is ~1,800 cyc/sample over its
  10,884 total -- the fix class must be memo/cache-shaped (bit-exact by
  construction) and is UNPROVEN until attributed. "Room somewhere" is
  a hypothesis, not yet evidence.

## LOG 6c1756c1: THE TRIM CONFIRMED, X MEASURED -- THE LINK IS THE ROOM
## (2026-09-14)

MEASURED on silicon, all four chips:
- THE TRIM: pro 727 -> 574-582 (-146 to -153 cyc/sample). Better than
  the 80-150 estimate. POS3 core 1 = 5,046 + 574 = 5,620 (was 5,771).
  Remaining core-1 gap: ~178.
- SLACK (first ever on a chain log): POS3/4 core 0 spins ~486-496
  cyc/sample at the barrier. With block cyc 6,072 (POS3): core 0 =
  voice 5,046 + ~84 pre-barrier + ~452 POST-barrier link/DAC work =
  ~5,582. POS2 (one voice, spin~0): cyc 5,459 = 5,044 + ~415 link.
  SO: THE LINK PATH COSTS ~415-536 CYC/SAMPLE ON CORE 0 -- that is
  ~110-137k cyc per block to move ~8 KB, ~15-30+ cyc/byte: CRC-AND-COPY
  BOUND. POS1 = 5,382, under budget, mix=OPEN sustained again.
- Starvation persists on POS3/4 (deficit 1,790/1,295) -> bad= downstream.
  Same causal chain, now fully attributed.

THE PLAN THE NUMBERS PICK (X=84 pre-barrier beat the <=150 rule, but the
post-barrier 452 is the true hoard):
 1. LINK SLIM: CRC32 slicing-by-4/8 (same VALUES, ~3 cyc/B vs byte-wise
    table walk), tables+hot path in IRAM/DRAM, drain/copy tuning.
    Target: link 536 -> ~150-200. Gate: value-equivalence tooth (fast
    twin == byte twin over a corpus + all in-band teeth re-bite). Not
    bit-exactness-bound -- protocol code, same protocol values.
 2. VCA PIPE: move the core-1 voice's fused-VCA audio half (~240) to
    core 0, one chunk late (chip output uniformly late = the accepted
    skew class). Gate: serial-vs-piped bit compare + tooth (b39 idiom).
 Predicted after both, patch 0: core1 ~5,380, core0 ~5,330-5,430. THIN
 but green-able; the seeded robot rides the same flash.

## THE FIX BUILD: WHAT LANDED AND THE HONEST PREDICTION (2026-09-14)

Landed, each gated (commits on the branch):
 1. FAST CRC (slicing-by-4, s3_chain.h, pure): equal to eb_devseq_crc32
    on 2,408 host cases + on-chip re-proof before streaming; tooth
    (corrupted slice entry) SEEN TO FAIL. Predicted ~-170 cyc/sample on
    the middle chips' core 0.
 2. VCA PIPE (EB_VCA_DEFER engine law + S3L_VCA_PIPE on pos3/4):
    deferred == serial BIT-IDENTICAL (chain_gate step 7, 2 patches x
    4096 samples, prologue live; one-ULP tooth bites). Moves ~240
    cyc/sample off the critical core; the chip ships one chunk later,
    uniformly (accepted skew class).
 3. Already aboard: the -150 LFO trim, the seeded robot (phase 7,
    runtime-gated), SLACK/C1AT/SEED reporting.

PREDICTION, stated BEFORE the flash (playbook 11b): pos2 ~5,289 GREEN;
pos1 GREEN (unchanged); pos3/4 core 1 ~5,244-5,330... but the AGGREGATE
(2 voices + prologue + link) still reads ~11,032 vs 10,884 at patch 0
-- ~148 over -- so pos3/4 may land JUST over, at ~5,5xx-5,6xx block. If
red: the same log's SLACK + cyc split names the remaining link segment
(i2s driver copies are the suspect) and that is the next, last shave.
This flash is honestly expected to be GREEN-OR-NAME-THE-REST, not
guaranteed green.

## LOG dd7c3cb0: THE PIPE WORKS, THE FAST CRC DOES NOT (2026-09-14)

MEASURED:
- VCA PIPE (pos3/4): core 1 v 5,046 -> 4,931 (-115; the fused audio
  half is ~115 cyc, not b27's 330 -- that number was the UN-fused whole
  module). pro steady 576-579. Core 1 total 5,507 (was 5,620).
- FAST CRC: REFUTED ON SILICON. POS2 -- whose ONLY change was the crc
  swap -- read cyc 5,459 -> 5,636 (+177). The four dependent table
  looks stall the in-order core worse than the byte walk. All buffers
  and tables verified INTERNAL (map + nm), so placement is not the
  story. Reverted on-device (ece9d86); the pure law + host gate stay
  as the record. CRCBENCH now prints byte/slice4/rom cyc/KB at boot.
- Net: pos3 6,183 (worse -- crc regression ate the pipe's win), pos1/2
  up ~100-180 for the same reason. un=0 everywhere throughout.

ROUND 3 (staged): byte crc back + CRCBENCH + the MIRROR pipe
(S3L_VCA_PIPE0) on pos2 (its voice rides core 0; near-idle core 1
batches). PREDICTION: pos1 ~5,38x GREEN, pos2 ~5,34x GREEN (first
time), pos3/4 ~5,95x-6,00x RED by ~300 aggregate -- the remaining
reservoir is the i2s driver copies + non-crc tail, which this log's
CRCBENCH + counters will size. The exact-engine arithmetic on a
2-voice chip (2 voices + prologue + link vs 10,884) remains the wall;
every remaining lever is in OUR link/driver code, not the engine.
