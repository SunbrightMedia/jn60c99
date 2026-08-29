# b41 — PIPE MERGE: the REV-PIPE latency chunk is deleted

b40's measurement showed the worker finishes its front pass ~1.9 ms into
the block while core 0 finishes voices at ~4.5 ms. So core 0's back pass
now consumes THIS block's front output (bank w_cur, released by the
volatile rp_valid store -- the w_go MEMW pattern), not last block's.
Expected spin at the handoff: ZERO. Output moves one chunk earlier:
REV-PIPE now costs NO latency at all. Same calls, same cores, identical
bits; the b39 host gate covers the arithmetic unchanged.

## The honest latency ruling (b37 redone, so nobody re-litigates it)
Key -> sound = MIDI ~1 + block quant 0..P + build 2P (KEYH=2) + fx pipe P
+ DMA lead (dma_n x P), P = block period.
- CHUNK=256, dma 6 (today):        ~40 ms.
- CHUNK=128, dma 2:                 ~17 ms.
- CHUNK=64,  dma 2:                 ~9.0 ms  <- THE ONLY <10 ms POINT.
CHUNK=64 stands ONLY if core 0's per-block FIXED cost (barrier, I2S call,
machine policy) is under ~15 us -- the margin left at 64. That is ONE
measurement (a C=64 probe build), not a debate. If it fails, the honest
floor of THIS architecture is ~13 ms (CHUNK=96) and the next lever is
cutting the 2-block key build, not the buffers.

## Verdict criteria for this flash
- FXP back= unchanged; no new spin (block times match b40's quiet=5,758).
- Audio identical; output one chunk earlier (not directly audible --
  proven by the unchanged counters, claimed from the code path).
- miss counters: no regression vs b40.

## VERDICT ON SILICON (2026-08-29, COM3, correct binary 1,486,128 B)
GREEN. back=1,044-1,260 and fx/v1 unchanged vs b40; whole loop
cyc=5,22x-5,48x unchanged; no new spin anywhere (the handoff cost is
invisible, as predicted). The REV-PIPE chunk of output latency is GONE:
5.8 ms deleted at CHUNK=256 for zero cycle cost. Miss profile matches
b40 (note misses from the step-vs-park margin, quiet ~2/1,000, un=0
throughout, deficit creeps only in patch storms). No regression.
NEXT: the C=64 probe -- measure core 0's per-block FIXED cost; <15 us
means CHUNK=64 + dma 2 stands and key->sound ~9 ms is reachable.
