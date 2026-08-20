# b22 — the master chain is a CLOSED PER-SAMPLE LOOP, and that re-prices the split

Found while designing the measured split b21 called for. Verified in the
source, not inferred.

## 1. The finding

`eb_master_render` is not a pipeline. It is a cycle:

    input(n)  <-- fb84672/fb84704 --  effect(n-1)
      |
    delay(n) --> reverb(n) --> out(n) --> effect(n) --> feeds input(n+1)

`eb_master_in.c:28-29` reads `v19 = fb84704; v29 = fb84672;` and
`eb_master.c:215-235` writes them from the EFFECT stage. Every effect arm
(e0, e1, e5, chorus) writes them. The feedback is ONE SAMPLE deep.

## 2. What this kills, and what it re-prices

**A sample-lockstep split buys NOTHING.** Within one sample the five stages are
strictly serial (delay needs input's output, effect needs delay's v56/v58 and
out's timing), and input(n) needs effect(n-1). There is no independent work
inside the chain for a second core to do. Splitting it across cores in lockstep
only adds two handshakes per sample to an unchanged critical path.

**A chunk-pipelined split IS NOT BIT-EXACT.** Running half the chain on core 0
for chunk N-1 while core 1 renders chunk N delivers the feedback pair one CHUNK
late instead of one SAMPLE late. That is different arithmetic and different
audio -- most audibly through the chorus/effect feedback path. b6's costing
("one block, 5.8 ms") priced the LATENCY and never priced this: the 5.8 ms
version is a SONIC CHANGE, adjudicable only by the fork's sonic gate (like
EB_VCF_RES_LUT's 0.40 dB), never by the trunk's EXACTLY-0.

Note the distinction that already exists in the tree: the CURRENT S3L_FX_PIPE
runs the WHOLE chain on core 1, one chunk behind the voices. The feedback stays
sample-deep INSIDE the chain; only chain-vs-voices alignment shifts, which the
recall path already compensates (EB_RECALL_FX_PIPE). That is why today's
pipeline is legitimate and a mid-chain split is not.

## 3. Where O4 actually stands now

| lever | status |
|---|---|
| EB_ZEROCOEF on t5 | dead (b20: 4 of 65 vs >=20) |
| ring placement | dead (b20: 15 % vs >=70 %) |
| restrict/aliasing | dead (b21: 992->992, 992->991) |
| cut t5's arithmetic | dead (b21: 101 persistent states, bit-exact) |
| split, lockstep | dead (this doc: serial chain, nothing to parallelise) |
| split, chunk-pipelined | ALIVE but RE-PRICED: 5.8 ms latency AND a sonic
  deviation through the feedback pair, fork-gated, on all 64 patches |
| leave 4 patches over budget | ALIVE: 60/64 comply, audio never breaks,
  the 4 miss deadlines and accrue drift while selected |
| two-chip layout absorbs it | UNMEASURED: the shipping design gives each S3
  3 voices, not 8. Core 1 today carries voice 7 + FX; with 3 voices per chip
  the voice pass shrinks and the FX headroom grows. O4's deficit was measured
  on the INTERIM single-chip 2-voice build. |

## 4. The judgement this leaves

The honest next question is not "how to split" but WHETHER O4's deficit
survives the shipping two-chip layout at all. The final chip B owns ~3 voices
plus FX; its voice pass is ~3 x 2,805 = ~8,400 across two cores, not today's
shape. The deficit should be re-derived on the two-chip layout (O6's link
work) before any sonic-deviation lever is spent on it.

That ordering also matches the user's standing priorities: the two-chip link
is required regardless (END_GOAL: EXACTLY two ESP32-S3s), while the split is
a cost paid only if the final layout still misses.
