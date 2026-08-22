# JX-3P — S3 STATUS (honest, dated by commit)

What is PROVEN, what is transcribed-not-proven, and the exact next steps. "Done"
means null EXACTLY 0; nothing below is called done that is not.

## PROVEN (null EXACTLY 0 under Unicorn, FTZ|DAZ)

- **The IDA dump is complete** — 305/305 concrete DSP methods (S3_DUMP_RECEIPT).
- **The JX oracle** (`tools/verify/jx_emu.py`) — BUILD 0x3F8610 constructs 9 units
  (STATE_SZ 0xAAC310, HOST layout = JUNO's), render path via VOICE_WRAP 0x377080
  / MASTER_WRAP 0x377010, ALLOC 0x6AB63C, DISPATCH 0x3EBB00. Runs FTZ|DAZ (0x9FC0)
  to match the plugin FP env. Proven by execution, zero faults.
- **The voice render** — `jx3p/src/jx_voice_render.c`, one function covering all
  8 per-voice arms (0x3A22C0..0x3D6110) via the 16128*v stride. Null EXACTLY 0:
  8 voices x 32 samples, 0 output + 0 state bytes. This is the largest/hardest
  DSP module.
- **All 6 voice helpers** — `jx3p/src/jx_voice_helpers.c` (39A250, 3A2010, 3A2180,
  3A2210, 3A9950, 3A21E0). Null 0/54638 over dense full-domain sweeps.

The reusable win: the null caught the reinterpret trap (helper 3A2210 fed a bare
`double` carrier -> numeric convert instead of lane-0 bit reinterpret). Baked
into both translate tools now.

## TRANSCRIBED, NOT YET PROVEN

- **The master render** — `jx3p/src/jx_master_render.c` from
  `translate_jx_master.py`. Single unit, plain offsets (rsi=a1 confirmed).
  Blocker: **11 argless helper call sites** (Hex-Rays lost xmm0). They sit behind
  `ucomiss xmm1, 0; jnz` guards and were not exercised by the sustained-note test
  state, so the emu arg-capture returned nothing. They MUST be resolved from asm
  (01_closure.asm) to compile and null. The sites and their asm patterns:
    * 3A2010 x4 (rva 39AF01, 39B845, 39C193, 39EA39): arg =
      (double)(*(float*)(st+A) + *(float*)(st+B)), A/B = the movss/addss cells
      right before `cvtps2pd xmm0, xmm1; call`.
    * 3A21E0 x3 (39AF7B, 39B8B4, 39C202): arg = xmm0_acc + *(float*)(st+cell),
      cell = the `movss xmm1,[rsi+cell]; addss xmm0,xmm1` before the call.
    * 3A2210 x4 (39AF83, 39B8BC, 39C20A, 39EAF0): arg = the immediately preceding
      3A21E0 result (movaps xmm6,xmm0); at 39EAF0 arg = the fmodf/subss chain.
  Once resolved: build a null_master harness (MASTER_WRAP, 16 voice-input ptrs +
  L/R out) and null EXACTLY 0.

## NOT STARTED

- **Effects** modules (EfxCh chorus, EfxPh phaser, EfxCr, EfxDs/Od/Fz) — each a
  CDSPJx3p class in the dump; transcribe + null like the voice arm. Some may be
  invoked inside the master chain; scope confirmed when the master nulls.
- **Recall in C** — derive patch-byte -> coefficient by perturb-and-diff under
  the oracle (the JUNO method), implement, prove warm==cold.
- **make verify SYNTH=jx3p** — the finish line: null EXACTLY 0 across all 64
  factory patches x rates x block sizes.

## The method is proven; the remainder is volume

The voice render proves the whole pipeline end to end (dump -> transcribe ->
oracle -> null 0). Every remaining module follows the same path. The master's
argless resolution is the only novel sub-task; after it, effects and recall are
repetitions of proven steps, and make verify is the gate that ties them together.
