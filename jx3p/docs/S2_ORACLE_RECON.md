# JX-3P — S2 ORACLE RECON (in progress)

Locating the JX equivalents of the JUNO oracle harness's entry points
(`tools/verify/e2e_emu.py`). All read-only on the binary; no JX code executed
yet. The emulator (Unicorn 2.1.4) is present.

## The method: vtable-slot transfer

The JUNO harness pivots on functions reached through the plugin's control
vtable, `CPrmDSPJu60Plugin` (rva 0x9C3018). Its JX twin is
`CPrmDSPJx3pPlugin` (rva 0x9F9A90), located by RTTI (`tools/rtti_seeds.py`).
Because the two plugins are the same vendor's engine with `Ju60`->`Jx3p`, the
vtables are slot-for-slot equivalent, so any control function is transferred:

    confirm the JUNO function sits at Plugin-vtable slot N
    -> the JX function is that binary's Plugin-vtable slot N

Verified end to end on the anchor the whole harness turns on — the parameter
dispatch, which `e2e_emu.py` documents as "engine vtable +88":

    DISPATCH (param write)   JUNO 0x3b9a30 = Plugin slot 11 (+88)
                             JX   0x3ebb00 = Plugin slot 11 (+88)

The full 20-slot control surface maps with every slot landing in `.text` on
both binaries — no holes, no reordering. The recon table for the JX build:

| Plugin slot | JUNO rva | JX rva |
|---|---|---|
| 0 (+0)  | 0x3b7f30 | 0x3ea000 |
| 8 (+64) | 0x3b48a0 | 0x3e6d10 |
| 11 (+88) DISPATCH | 0x3b9a30 | 0x3ebb00 |
| 14 (+112) | 0x3bcc20 | 0x3eea10 |
| … | (all 20 contiguous, .text both) | |

## What transfers by table, and what still needs the decompile

| harness anchor | JUNO rva | JX status |
|---|---|---|
| param DISPATCH | 0x3b9a30 | **0x3ebb00 — derived, verified** |
| Plugin control vtable | 0x9c3018 | **0x9f9a90 — RTTI-located** |
| CPrmDSP base vtable | 0x9c0600 | **0x9f7230 — RTTI-located** |
| the 35 DSP class vtables | various | **all located (rtti_seeds)** |
| BUILD (engine constructor) | 0x3c68d0 | plain function — needs decompile xref or the IDA dump |
| NOTEON / NOTEOFF | 0x3c7330 / 0x3c72d0 | plain functions — reachable from the note vtable; xref pending |
| VOICE_WRAP / MASTER_WRAP | 0x398f30 / 0x398ec0 | per-sample DSP loops — reachable from the DSP vtables; slot to confirm |
| ASG_NOTIFY | 0x3549b0 | assigner vtable slot +8 — transferable once the assigner vtable is matched |

**The control plane transfers by table. The construction and per-sample entry
points are plain (non-virtual) functions the JUNO port found once in IDA.**
Two ways to close them, in preference order:

1. **The dsp_dump the IDA step produces** (PIPELINE phase 1). `extract_dsp.py`
   with the RTTI seeds pre-filled emits the full call graph; BUILD and the
   wrappers fall out as the callers of the vtable methods already located.
   This is the planned path and needs one IDA run on your machine.
2. **Static xref from the located vtables** (no IDA): find who stores the
   `CPrmDSPJx3pPlugin` vtable pointer — that store is inside BUILD. Feasible
   here, slower, and lower-confidence than the decompile. Held as a fallback.

## The static-xref fallback: demonstrated working, held in reserve

Proof the fallback path is real: searching `.text` for `lea reg,[rip+disp]`
targeting the `CPrmDSPJx3pPlugin` vtable found **exactly one site, rva
0x3e56a9** — the param-processor constructor. So "who builds this object" is
mechanically answerable here, IDA or not.

But the DSP-engine BUILD (JUNO 0x3c68d0) constructs the *nine DSP units*
(`CDSPJx3p*`), a different and larger object graph, and the per-sample
wrappers are non-virtual leaves. Hand-reconstructing those from static xref
across a 9.8 MB `.text` is low-confidence, high-effort RE — the kind that
introduces the hiccups this port is meant to avoid. The decompile produces
them cleanly as a byproduct. So the fallback is proven viable and deliberately
**not** pursued further: the disciplined path is the single IDA dependency
that S3 needs regardless.

## Status

* Phase 0 (freeze): DONE. `jx3p/truth/` checksummed — JX3P.vst3, Script.xml,
  preset_bank_1.bin, Code1.Dat, Code8_1.Dat.
* Oracle control plane: mapped and one anchor verified.
* Oracle construction + per-sample entries: pending the IDA dump (the same
  one S3's transcription needs), or the static-xref fallback.
* The `.Dat` question stays open until the oracle runs — recorded in S1_INTAKE.

**No blocker introduced.** S2's control-plane half is de-risked to a table
lookup; its execution half converges with S3's single IDA dependency. When
you run the IDA step, both unlock together — which is why the plan pairs them.
