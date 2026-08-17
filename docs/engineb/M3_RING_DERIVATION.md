# M3 — the rings, derived from the parameter, and what it does to L1
2026-08-17. MEASURED here by execution (tools/engineb/ring_derive.py), on the
host, through the engine's own code. No board was involved and none is needed:
a ring length is a count of samples, not a cycle count.

## THE PRECONDITION, AND WHY IT WAS NOT A FOOTNOTE
`data/fx_chain_price.md:38-41` said it plainly and was right:

> "31,007 samples is the deepest read THIS BANK produces. A shipping
>  allocation must be derived from the DELAY TIME parameter's MAXIMUM, not
>  from observed lag, or a patch outside the battery reads past the end."

Done now. The answer is 5.3x the observed figure, and it removes L1 as scoped.

## MEASURED: factory bank vs the parameter's range
`ring_derive.py`, DELAY TIME (blob 53) swept 0..255 in 17 steps x SYNC off/on,
one factory patch per DELAY TYPE, 1 s of settle per point at 44,100:

| ring | factory bank | parameter range | required (pow2) |
|---|---|---|---|
| t1 | 15,503 | **82,687** | 131,072 |
| t23 | 536 | 572 | 1,024 |
| t5_0 | 15,503 | **82,687** | 131,072 |
| t5_1 | 15,503 | **82,687** | 131,072 |
| t5_2 | 741 | 741 | 1,024 |
| t5_3 | 442 | 442 | 512 |

82,687 samples at 44,100 is 1.87 s, which is a plausible maximum delay for
this instrument, and it sits comfortably inside the plugin's own allocation of
0x80000 = 524,288 (written at `src/delay_recall.c:649`). So the plugin was not
being wasteful by 45x for no reason; it was covering a range the factory bank
never visits.

## WHAT THIS DOES TO L1 — IT DOES NOT FIT
`fx_chain_price.md:26-33` sized the lever from the FACTORY figures and
concluded "**137 KB fits in 163 KB**". Re-derived from the parameter, EXACTLY
ONE arm runs per patch, so the worst ACTIVE set is:

| active arm | rings | samples | bytes |
|---|---|---|---|
| DELAY TYPE 5 | t5_0 + t5_1 + t5_2 + t5_3 | 263,680 | **1,030 KB** |
| DELAY TYPE 1 | t1 | 131,072 | 512 KB |
| DELAY TYPE 2/3 | t23 | 1,024 | 4 KB |

Against **163 KB** of free internal SRAM (the listen firmware's own print).
The worst arm is **6.3x too big**. L1 as written -- "allocate the ACTIVE arm's
rings in internal SRAM" -- cannot be done at the size the parameter requires.

## WHAT SURVIVES, AND IT IS THE INTERESTING PART
Allocation size and WORKING SET are different quantities, and only the second
one costs cycles. A delay reads at ONE depth -- the current delay time -- not
across the whole ring. At the factory patches' 15,503 samples the live window
is about 62 KB, which does fit. So:

- The **allocation** must cover 131,072 samples per long ring, and therefore
  must live in PSRAM.
- The **working set** for any given patch is that patch's delay time, and for
  every factory patch it is small enough to sit in internal SRAM.

That splits L1 into a lever that is still available and one that is not:

- **DEAD as scoped**: move the rings wholesale into internal SRAM.
- **ALIVE, and unmeasured**: keep the allocation in PSRAM and make the LIVE
  WINDOW internal -- the write head and the read head are two small moving
  regions in a large array, which is the shape a cache or an explicit
  staging buffer handles well. Nobody has measured what that is worth. It is
  NOT the same lever and must not inherit L1's 2,634-cycle ceiling estimate.

Note also that the ceiling estimate is unaffected in the other direction:
M2's 2,634 was computed from c/i, not from ring size, so it remains the upper
bound on what ANY ring-placement work can return. It was already short of G2
by ~2,624 cycles.

## THE TOOL, AND THE TWO DEFECTS IT SHIPPED WITH FIRST
Recorded because both are the classes this project keeps paying for.

1. **It read the probe's log inside the process that wrote it.**
   `eb_master.c`'s reporter is an `__attribute__((destructor))`, so
   `/tmp/eb_ring.log` appears at process EXIT. The first run printed an empty
   table. Fixed by forking a worker per pass and reading only after it exits.
   An empty table was loud; a partial flush would not have been.

2. **The plant did not land, and the teeth blessed it.** `BLOB_OFF` was 662
   (the `rec[650]` area the DTYPE decode uses) instead of `juno_apply.c`'s
   **16**, so every doctored byte went somewhere the engine does not read. The
   swept column came back byte-identical to the factory column -- and the
   teeth ASKED WHETHER THE SWEPT DEPTH STAYED UNDER THE FACTORY DEPTH, which a
   no-op satisfies perfectly. A tooth a broken tool passes is worse than no
   tooth. Both are fixed: `verify_doctor()` now reads the value back through
   `juno_bank_delay_modes` and refuses to run if it did not land, and the
   teeth now sweep the parameter's LIMIT and REQUIRE a deeper read.

## LIMITS OF THIS NUMBER, STATED
- 17 values x 2 sync states is a FLOOR on the parameter maximum, not a proof.
  The tap is a smoothed, LFO-modulated product (`eb_delay_t1.c:184`), so a
  value between steps can read deeper. Size with margin and KEEP
  `eb_delay.h`'s `overrun` counter -- it is what catches a wrong answer here.
- Samples at 44,100. A 96 kHz host needs 2.18x these.
- The e5 and t4 rings never reported: no swept configuration exercised them.
  They are not proven small, they are unmeasured.
