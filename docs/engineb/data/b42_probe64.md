# b42 — the C=64 probe: the ONE measurement that decides <10 ms

Build: CHUNK=64, S3L_DMA_N=12 (17.4 ms cushion so the probe itself cannot
click), REV-PIPE on, BSTEP-C1 OFF (a 215k step cannot fit core 1's ~90k
park at 64; note bumps ride the cushion during the probe), FXPROF on.
dma_desc_num is now the S3L_DMA_N knob (was hardcoded 6).

## THE DECISION RULE, written before the flash
Period at 64 = 1,451 us. Core 0's variable cost scales: 5,758/4 = 1,440 us.
So `B4dur quiet=` at 64 reads 1,440 + FIXED, where FIXED is the per-block
constant (barrier, I2S write call, machine policy).
- quiet <= 1,448 us AND `B4rate quiet` no worse than b41's ~2/1,000
  -> FIXED <= ~8 us -> CHUNK=64 STANDS. Step 4 final = CHUNK=64 + dma 2,
  key->sound ~9 ms worst. GO.
- quiet 1,449-1,458 -> marginal; CHUNK=96 (13 ms) is the honest floor.
- quiet > 1,458 or un>0 or B5 deficit slope up at idle -> C=64 DEAD;
  re-derive at 96/128.
Historical prior (the CHUNK comment, 2026-08-11): ~25 cyc/sample sat
outside the timed region at 128 -> FIXED ~3,200 cyc = 13 us -> predicts
quiet ~1,453: MARGINAL. The probe, not the prior, decides.
Also read: `fx=` and `back=` per sample must be ~unchanged (they are
per-sample costs); watch `wb_zero`/gap behavior with the deeper queue.

## VERDICT (2026-08-30 flash, no interaction needed -- the chord loop drove it)
C=64 FAILS in the bench configuration, per the pre-written rule:
quiet=1,466-1,497 us vs the 1,451 us period -- over on EVERY block; the B5
deficit climbed the whole run (~35/s); un=0 only because of the 17 ms
cushion. FIXED measures ~40-55 us/block, not the ~13 us prior.
ATTRIBUTION OWED: this build still ran the BAD-PAIR link poll, the 4 s
patch stepper (S3L_STRESS) and the reporter -- per-block load a real
instrument does not carry. b42b re-runs the identical probe with
S3L_LINK=0 and S3L_STRESS=0. If quiet drops under 1,448, the 50 us was
bench overhead and C=64 lives; if not, the architecture's floor is
CHUNK=192-256 and the <10 ms target is refused honestly.

## b42b VERDICT (2026-08-30 flash, S3L_LINK=0, S3L_STRESS=0)
GO. CHUNK=64 STANDS. quiet=1,432-1,443 us -- UNDER the 1,451 us period on
every report line. The 50 us of b42 was BENCH LOAD (BAD-PAIR link poll +
patch stepper + reporter), not the architecture: the true per-block FIXED
cost is ~7-13 us. un=0 the whole run.
CAVEATS, stated with the claim:
- Quiet miss tail ~31/10k blocks (spikes; absorbed by the cushion). Above
  the ~2/1,000 bar; UNATTRIBUTED at 64.
- b42b ran with NB idle (STRESS off removed the chord loop): notes and keys
  were NOT exercised. The final verdict flash needs real keys and ears.
- The two-chip LINK poll (~40 us/block) is COMPILED OUT of this build. It
  must be re-engineered before the two-chip <10 ms configuration.
- BSTEP-C1 OFF at 64 (step 215k > park ~90k); note steps run ~2.0 ms
  blocks against a 2.9 ms cushion at dma 2.

## FINAL64 -- the Step-4 candidate (built 2026-08-30 00:20)
Identical to b42b with S3L_DMA_N=2. Latency model (b41):
key->sound worst ~= 1 + 1.45 + 2x1.45 + 1.45 + 2x1.45 = ~9.0 ms.
juno_s3.bin = 1,472,528 bytes. Decision rule for the verdict flash,
written now: un=0 over a 5-minute KEY+PATCH soak WITH LISTENING; KEYH
key->sound <= 10 ms; no audible click on key or knob (patch-change click
is C10-bounded and expected). Any un>0 = dma 2 too shallow -> dma 3
(+1.45 ms, still <10 ms only if KEYH confirms margin).

## FINAL64 dma 2 VERDICT (2026-08-30 flash, user LISTENED): FAIL -- POPS
The user heard many pops and clicks. The log agrees: B5 deficit climbed
~10/s the whole run (sent 22,247 vs written 21,359 at t=31) = TRUE
STARVATION; un=0 stayed blind, as B5 was built to show. quiet=1,453-1,465
us, OVER the 1,451 period -- but b42b (dma 12, same code) read 1,432-1,443.
ATTRIBUTION: the +20 us is the I2S write path at queue depth 2 (blocking
descriptor churn), not the engine. Also learned: the 4 s patch stepper is
gated by w_step_on (runtime), NOT S3L_STRESS -- it ran in b42b AND here,
so the stepper is not the variable. Per the pre-written rule: dma 3 next
(FINAL64-D3, compile stamp 05:42:19, same 1,472,528 bytes -- verify by the
boot log stamp, not size). Watch: B5 slope must be FLAT and quiet < 1,451.

## FINAL64-D3 VERDICT: FAIL -- same pops. THE REAL CAUSE FOUND.
dma 3 changed nothing: quiet 1,454-1,458, B5 deficit +10/s, user heard many
pops. Attribution error paid twice: (1) b42b was gated on quiet alone; its
B5 slope was never read (the slope was already there at dma 12 -- b42 showed
35/s). (2) "S3L_STRESS=0 removes the stimulus" was WRONG: the chord loop
(1.5s/0.7s gate, a note burst each transition) and the 4 s patch stepper
(w_step_on, default ON) are gated by S3L_PLAY, not S3L_STRESS. So every
"musician" probe still ran the bench demo: self-driven bursts every 2.2 s
and 4 s, each punching through the ~4 ms cushion at C=64. The pops were the
DEMO, not the keys. LESSON (playbook-class): a stimulus believed OFF must be
SEEN to be off in the log (pat= froze, nb= froze) -- pat= was climbing in
every one of these logs and I did not read it as a violation of my own
build's claim.
FINAL64-PLAY (compile 05:48:46, 1,472,480 B): S3L_PLAY=1 -- silent until a
key, no stepper, no chord loop. Gate: B5 slope FLAT at idle AND under keys;
no pops while playing; KEYH populated <= 7 blocks (10 ms at C=64).

## T5PROBE VERDICT (2026-08-30 flash, patch 5 pinned, C=64, chord loop)
THE C=64 DELAY COST IS MEASURED AND ATTRIBUTED TO CHUNK GRANULARITY.
fx=2,699-2,865 cyc/sample on patch 5 at CHUNK=64 vs ~1,800 at 256 (b39).
Whole loop cyc=5,466-5,644 vs the 5,442 budget: over on EVERY line, B5
deficit +~20/s, quiet=1,484 us vs 1,451. The extra ~1,000 cyc/sample
scales as per-chunk work / CHUNK: ~63,000 cyc of t5 work runs ONCE PER
CHUNK (invisible at 256: ~250 cyc/sample; fatal at 64). NEXT: find that
per-chunk block in eb_delay_t5/master front on the host (QEMU icount at
chunk 64 vs 256) -- no silicon needed for the hunt. NOT the per-sample
arithmetic (b21 stands): this is prep/control work per chunk.

## T5PROBE-128 VERDICT (2026-08-30): THE PER-CHUNK MODEL IS DEAD
fx on patch 5 at CHUNK=128 = 2,711-2,867 -- IDENTICAL to CHUNK=64. There
is NO per-chunk t5 cost. The "63k/chunk" attribution is RETRACTED: it
compared patch 5's fx at C=64 against b39's fx=1,800, which was a
DIFFERENT patch's report window (the stepper was running in b39; t5
patches were never pinned). Playbook-class defect: a scaling law fitted
through two points measured on DIFFERENT workloads.
TRUE STATE: patch 5's fx = 2,700-2,870 cyc/sample AT EVERY CHUNK; core 1
= fx + v1 = 5,330-5,490 vs the 5,442 budget = 98-101 % everywhere. b39's
"all 64 fit" stands only as measured -- whole loop under period at 256 by
a razor margin; the chunk shrink's small fixed overhead tips t5 over.
GAP TO CLOSE: ~50-150 cyc/sample on core 1, t5 patches only.
NEXT LEVER (b20's standing structural note): EXACTLY-0 zero-coefficient
deletion in the master chain -- t5 has 4/65 coefficients always zero and
NO delay module ever got the EB_ZEROCOEF treatment. Bit-exact, host-gated.

## T5PROBE-ZC VERDICT (2026-08-30): PARTIAL -- real, not enough
EB_ZEROCOEF_T5 (legal set G1+G3+G5) on silicon, patch 5, C=64:
fx 2,700-2,867 -> 2,625-2,640 (spikes 2,787); quiet 1,484 -> 1,466 us.
STILL OVER the 1,451 period by ~15 us (~55 cyc/sample); B5 deficit still
climbs ~12/s. The flag EARNS its place (it is exact and it pays) but does
not close the gap alone. NEXT: the reverb (~1,165 cyc/sample in back=)
has never had a zero-coefficient audit -- extend mc_zero_proof to the
whole master coef struct.
