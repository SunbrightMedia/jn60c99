# JX-3P — S3 MECHANICAL TRANSCRIPTION (started)

The IDA dump is complete (S3_DUMP_RECEIPT.md). This is the transcription kickoff:
the render inventory located, the first render classified, and the honest
critical path stated. No JX C99 is claimed PROVEN yet — the null gate needs the
oracle, and that is the next build.

## The render inventory (READ from the dump)

Topology mirrors the JUNO one-to-one:

| role | JX function(s) | JUNO analog |
|---|---|---|
| voice render (8 variants, `(a1, _DWORD **a2)`) | 0x3A22C0, 0x3A99B0, 0x3B1040, 0x3B86D0, 0x3BFD60, 0x3C73F0, 0x3CEA80, 0x3D6110 | sub_180369070 (1 fn) |
| voice dispatch / wrapper | sub_180377080 | VOICE_WRAP 0x398F30 |
| voice driver | sub_1803F8C60 | — |
| master render | 0x39A2B0 | master arm |
| master dispatch / wrapper | sub_180377010 | MASTER_WRAP 0x398EC0 |
| master driver | sub_1803F9220 | — |
| render orchestrator (calls both drivers) | sub_1803F8610 | host process |
| parameter DISPATCH (Plugin slot 11) | 0x3EBB00 | 0x3B9A30 |
| param processor vtable | 0x9F9A90 | 0x9C3018 |

Eight voice variants (vs the JUNO's one) is the expected cost of two DCOs +
cross-mod: the engine has more render arms selected by patch config. Each variant
has the SAME signature and flat-state shape as the JUNO voice render, so the
method transfers unchanged — one arm at a time, each nulled EXACTLY 0.

## First classification — voice variant 0x3A22C0

Run of the arm_xform classifier (COEF/STATE/WONLY) on the dump function:

    total distinct cells   912
    COEF  (read, ¬written)  431   -> c->kN
    STATE (read + written)  397   -> s->sN
    WONLY (written only)     84   -> s->sN, null decides if needed
    judgement helper calls    6   (JUNO had ~30 across its single render)
    SIMD idioms               8   (arm_xform carrier/reinterpret handling)
    LODWORD/HIDWORD copies   153   (the bit-copy trap; memcpy, not assign)
    a1+ references          2668

⚠ **Max cell offset 0x41F80 (270208).** That is far past a single voice's state
— this variant almost certainly indexes a VOICE ARRAY (`a1 + voice*stride + N`),
not one flat voice like the JUNO render. The transcription must model that (a
stride, not a fixed base) and the null gate is what confirms it. Flagged before
transcribing, not discovered mid-null.

## The critical path — why the oracle comes before any PROVEN transcription

The ONE RULE: every constant proven against machine code under Unicorn; "done" =
null EXACTLY 0, never by ear. So no transcribed arm is finished until it nulls
against a JX oracle. The oracle (S2's execution half) is therefore the next
build, not the transcription itself:

1. **JX oracle harness** — port tools/verify/e2e_emu.py to JX. Entry points
   resolved so far (synth/jx3p.json `entries`): DISPATCH, proc vtable, both
   render wrappers + drivers, the 8 voice variants, master render. Still to
   resolve (construction/host path, largely OUTSIDE the DSP band — may need a
   targeted follow-up): BUILD, NOTEON/NOTEOFF, SETSR, the assigner notify, and
   the ALLOC/FATAL stub addresses.
2. **Voice arm 0x3A22C0** — transcribe with arm_xform, model the voice-array
   stride, null EXACTLY 0.
3. **Remaining 7 voice arms + master + effects** — fan out; each nulled.
4. **S4** — recall in C, `make verify SYNTH=jx3p`.

Order is fixed by the mantras: rewrite, then confirm. Step 2 cannot be called
complete before step 1 exists.
