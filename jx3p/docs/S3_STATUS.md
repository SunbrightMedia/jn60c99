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

## PROVEN — the master render (added this session)

- **The master render** — `jx3p/src/jx_master_render.c`. Nulls EXACTLY 0 against
  the oracle on the default note state: L/R output 0/32 mismatches AND the full
  11 MB state 0 bytes differ. Harness: null_master_emu/_c (a2 = 8 voice-main
  outputs byte-addressed; note-object chain at st+136 relocated; SNAP = full
  STATE_SZ). The whole core DSP signal path (voice + master) is now bit-exact.
  Caveat: the 11 argless helper sites are DCO-mode/effect-gated (v31<=3 via the
  note object) and NOT reached by a sustained note, so they are placeholdered and
  unproven until a mode-selecting patch (recall) exercises them.

## (superseded note) master render — earlier blocker

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

  DEEPER FINDINGS (this session):
  * The master render is `sub_18039A2B0(a1, a2, a3)`: a1=state8, a2=array of 16
    ptrs (8 voices x {main,sub} outputs, read at decompile 1015-1022), a3=L/R
    out (written at the tail). MASTER_WRAP passes a2/a3 through rdx/r8. Confirmed
    by direct call (entry executes, returns L/R ptr).
  * MASTER_WRAP 0x377010 gates on `*(a1+20)` (enable) and a warmup latch
    `*(a1+11191048)` (>0 => skip render, decrement) -- clear both to run it, or
    call 0x39A2B0 directly.
  * The 11 argless sites are NOT reachable from a default single-note state:
    they sit under DCO-mode guards (`if (v31 <= 3)` + waveform selector
    `*(a1+11191052)`), i.e. they are the effect/oscillator-mode paths. Exercising
    them needs a patch that selects those modes -> depends on recall (task 9).
  * Partial resolution proven from decompile+asm:
      - 3A2210 arg is CLEAR: the immediately preceding 3A21E0 result (v235 etc.)
        -> `*(float*)&vN = jx_h_3A2210(v_prev_result);`
      - 3A2010 arg = (double)(*(float*)(a1+A) + *(float*)(a1+B)), A/B the
        movss/addss cells before `cvtps2pd` (rsi=a1, so direct).
      - 3A21E0 arg = phase-accumulator wrap: xmm0=[cell] + a conditional
        wrap of (clamped-2010-result * [cell]); needs full asm reconstruction of
        the comiss/addss wrap chain (the one genuinely intricate sub-task).
  * Recommended order: do RECALL first (task 9) so a mode-selecting patch can
    drive the master's argless branches under the oracle; then the emu arg-capture
    resolves 3A21E0 mechanically instead of by hand, and the master nulls.

## REMAINING

- **Recall in C** (next). SCOPED: the dispatch 0x3EBB00 is a binary-search router
  on param index that DELEGATES to ~149 virtual param-setter methods
  (`(*(*a1 + vtoff))(a1,a3,a4)`), not a self-contained applier. So recall follows
  the JUNO's proven method: run the dispatch under the oracle per parameter to
  recover {blob_pos -> (curve/offset)}, port a curve evaluator + binding map in C,
  prove the post-recall coefficient state matches the oracle's bit-for-bit. This
  also supplies the mode-selecting patches that exercise the master's 11 argless
  branches (closing that gap).
- **Effects** modules (EfxCh chorus, EfxPh phaser, EfxCr, EfxDs/Od/Fz) — each a
  CDSPJx3p class in the dump; transcribe + null like the voice/master. Some are
  invoked inside the master chain (the master already nulls, so those paths that
  run are covered; standalone effect entries still need their own null).
- **make verify SYNTH=jx3p** — the finish line: null EXACTLY 0 across all 64
  factory patches x rates x block sizes, tying recall + render together.

## The method is proven; the remainder is volume

The voice render proves the whole pipeline end to end (dump -> transcribe ->
oracle -> null 0). Every remaining module follows the same path. The master's
argless resolution is the only novel sub-task; after it, effects and recall are
repetitions of proven steps, and make verify is the gate that ties them together.
