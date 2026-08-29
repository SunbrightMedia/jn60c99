# b39 — REV-PIPE: reverb+out is a feed-forward tail; split it to core 0, bit-exact

## The finding that unlocks it
b22 killed the master-chain split because the chain is a closed per-sample
feedback loop. READ from eb_master.c, then PROVEN by execution: the loop is
ONLY in -> delay -> effect. The feedback pair fb84672/fb84704 is written by
the EFFECT stage alone; the reverb consumes v176/v177 (delay outputs) and the
out stage consumes the reverb. Neither writes anything the loop reads. So
reverb+out is a FEED-FORWARD TAIL and can run one chunk late with NO sonic
change — the identical bit stream, one chunk later. b22 stands for the loop;
it never applied to the tail.

## Why it is the right lever (measured, not argued)
b18 (MSPROF, ratios): reverb 951–1,228 + out 142 cyc/sample. b6: the type-5
overage is 6,526–6,821 against 5,442. The tail is the size of the overage,
and core 0 was measured spinning (wait=5, b6). Moving the tail to core 0
attacks the WHOLE measured gap without touching t5's un-reducible arithmetic
(b21).

## The proof (executed)
1. eb_master.c refactored into eb_master_render_front (in+delay+effect) and
   eb_master_render_back (reverb+out); eb_master_render = front-then-back.
   Judged by the foundation gate (trunk null EXACTLY 0), not assumed.
2. tools/engineb/revpipe_gate.c: two full instances over one voice stream,
   serial monolith vs chunk-batched front-then-back. **0 differing values of
   88,064** on patches 0/5/16/21 (t5 arms included), chunk 256 AND 128,
   chord 3. Tooth (one ULP into one buffered v176): SEEN TO BITE on every
   patch (1–3,636 differing). Layout guard SEEN TO REFUSE a stale blob.
   Scope: patch 49's blob generator fails in its mask probe (slow attack,
   pre-existing, unrelated); 49 shares the t5 arm with 5/21.

## Firmware (flag S3L_REV_PIPE, default 0 = shipping build verbatim)
Worker (core 1) runs front only into a two-bank v176/v177 buffer (w_cur
discipline, same as w_vbb); core 0 runs back over the previous bank right
after its voices — the measured spin slot — and writes the PCM. back uses the
SAME mc pointer front used (rp_mc), so a recall cannot split one chunk across
two patches. Excluded by #error: S3L_LAYOUT, S3L_OFFLINE (both serial-render
the master elsewhere). EB_MSPROF must stay OFF with REV_PIPE (its
accumulators would be written from two cores).

## Cost
One more chunk of output latency (5.8 ms at CHUNK=256, 2.9 at 128) and one
more priming chunk of silence. Class: identical to S3L_FX_PIPE, already
shipped. Latency budget impact goes in the b37 table before any ship claim.

## OWED before enabling in LISTEN.md
- foundation gate green on the refactor (in flight at commit time).
- ONE verdict flash: FXP fx= must DROP by ~back= on patches 5/16/21/49 and
  the whole-loop worst case must land under the period. The report prints
  `FXP: back=` (core 0, per sample) for exactly this comparison.
