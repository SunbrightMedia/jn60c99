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

## Open

- ~21 blocks per 10,000 exceed the period slightly (HEALTH latch prints);
  the DMA queue absorbs them (deficit flat) so the INVARIANT holds, but
  the cause is UNATTRIBUTED. Suspects: block-tail UART/ctl jitter, report
  printf contention. Attribute before quoting any chain budget number.
- Note path + event tap not yet exercised (keys=0 in the pass run).
- Positions 2-4 and every hop remain silicon-unproven.
