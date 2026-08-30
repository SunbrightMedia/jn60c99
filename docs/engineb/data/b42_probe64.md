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
