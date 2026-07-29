# Porting toolkit — what carries to the next soft synth, and what does not

*2026-07-29. Written to answer: "everything so far transfers easily to another
project-SSX soft synth — will the Daisy port transfer the same way?"*

**Short answer: two of the three layers transfer almost completely. One does not,
and knowing which is which changes what you should build next.**

## The three layers and their reuse ratio

| Layer | What it is | Reuse across synths | Per-synth cost |
|---|---|---|---|
| **1. RE → bit-exact C99** | Unicorn oracle, differential A/B gates, provenance ledger, fuzz, coverage scan | **~95% generic** | find ~16 anchors + transcribe the DSP |
| **2. Embedded bring-up (Track A)** | Hardware bring-up, memory placement, on-device golden corpus, cycle profiling, the safe-cut ledger | **~100% generic** | re-measure two numbers |
| **3. Native rewrite (Track B)** | Rewriting the voice/FX kernels as idiomatic DSP | **0% generic** (harness ~100%) | 1–2 weeks *per synth*, forever |

### Grounding, not assertion

Measured over `tools/verify/*.py` — lines of machinery vs. hardcoded
JUNO/rva references:

```
e2e_emu.py           430 lines   14 juno/rva refs      <- the whole Unicorn oracle
recall_render_ab.py  255 lines   27 refs
fuzz_diff.py         234 lines   17 refs
hostpath_roles.py    326 lines   10 refs
assigner_ab.py       169 lines   17 refs
```

The tooling is overwhelmingly generic; the synth-specific part is a **small
constant table**, not scattered logic. That is why the JUNO work transferred so
readily in the first place.

## Layer 1 — the per-synth config surface (the whole of it)

Everything JUNO-specific in the oracle is these anchors. For a new plugin you find
these and the machinery runs:

| Anchor | JUNO value | How you find it in a new binary |
|---|---|---|
| `BUILD` (engine factory) | `0x3C68D0` | the only allocator of the big per-unit state |
| `SETSR` | `0x3C7A20` | takes `(this, float)`, compares against `*(this+8)` |
| `DISPATCH` (value-tree setter) | `0x3B9A30` | called in a long chain by the recall enumerator |
| recall enumerator | `0x3B48A0` | the huge straight-line run of `get(idx)` → `set(idx)` |
| `NOTEON` / `NOTEOFF` | `0x3C7330` / `0x3C72D0` | engine vtable slots 16 / 15 |
| host param entry | `0x3C7AE0` | engine vtable +112; maps paramID → index, range-checks |
| `VOICE_WRAP` / `MASTER_WRAP` | `0x398F30` / `0x398EC0` | the per-block pool callback's leaf calls |
| name table / descriptor DB | `0x9a0030` / `0x98c040 + 16*idx` | `{min,max,default,flags}` rows that match their own names |
| `PROC_VPTR`, `STATE_SZ` | `0x9C3018`, `0xA83010` | from the factory's allocation size |
| `ALLOC`, `FATAL` | CRT stubs | standard Win32/CRT shims |

**~16 numbers.** Everything else — the two-process rule, `wr_desc` before
dispatch, full-state diffing, the fuzz grammar, the ledger linter, the
completeness scan — is synth-agnostic and already written.

The genuinely per-synth labour in Layer 1 is **transcribing the DSP** from the
decompile. That is the months. It does not shrink; it is the product.

## Layer 2 — the Daisy work is the *most* reusable thing we could build

This is the important answer to your question. Track A contains **no synth
knowledge at all**:

- QSPI bootloader + libDaisy audio callback → `<engine>_render`
- Memory map: hot kernels → ITCM, per-voice state → DTCM, big FX buffers → SDRAM
- Hardware FTZ bit instead of the software denormal scan
- Golden-corpus-on-device harness (already self-contained: patch blob + events + hash, no bank file needed)
- DWT cycle-counter profiling per function
- The **safe-cut ledger**: which optimisations preserve bit-exactness and how each is gated

Every line of that applies unchanged to the JX-3P, to an SSX synth, to anything
that came out of Layer 1. The only per-synth inputs are **two measured numbers**:
state size, and cycles/sample — both produced by the same profiling script.

**So: yes. The Daisy port is more repeatable than the RE work, not less.** Build it
once as `daisy-common/` + a per-synth `config.h`, and every future port inherits a
hardware instrument.

## Layer 3 — the one that does not transfer

Rewriting `voice_render` and `master_render` as idiomatic DSP is irreducibly
per-synth: a JUNO DCO/BBD-chorus is not a JX-3P DCO, is not whatever SSX ships.
There is no shortcut and no shared code.

**But the harness that makes it safe is fully reusable**: render both engines,
compare with `|err| < ε` per patch and per module, ledger the tolerances. That is
`recall_render_ab` with the comparator relaxed from `==` — one generic tool that
serves every synth's Track B.

## The strategic consequence

If the goal is **a fleet of synth ports**, the polyphony question inverts:

- **Track A** — build the toolkit once; every future synth gets a **4–6 voice
  bit-exact hardware instrument for free.** (The real JU-06A is 4-voice. A 5-voice
  bit-exact unit already exceeds the hardware Roland sells.)
- **Track B** — 8 voices, but **1–2 weeks of bespoke DSP per synth, forever**, and
  the result is no longer bit-exact (tolerance-gated instead).

For one flagship instrument Track B is worth it. For a repeatable pipeline it is a
tax you pay again on every title. **Recommendation: make Track A the product;
treat Track B as a per-synth upgrade you buy deliberately, not the default.**

## Suggested repo shape for synth #2

```
ssx-common/                  # extracted from this repo, synth-agnostic
  oracle/                    # e2e_emu + differential gates + fuzz + ledger linter
  daisy/                     # bring-up, memory map, FTZ, golden runner, profiler
  toleranceab/               # Track B comparator (|err| < eps + module ledger)
juno60/  config.h + src/     # the 16 anchors + the transcribed DSP
jx3p/    config.h + src/     # ditto
```

The honest split: `ssx-common/` is written **once**. Each new synth costs the
anchors (hours), the DSP transcription (the real work), and two measurements.

## Order of operations for the next synth

1. Find the 16 anchors → oracle runs → recall gates green.
2. Transcribe the DSP → render A/B bit-exact. *(the long pole)*
3. Drop in `daisy/` → run the golden corpus on device → profile → apply the
   safe-cut ledger → ship 4–6 voices bit-exact.
4. Only if that specific instrument demands 8 voices, open Track B with the
   tolerance harness.

## Before any of this: one cheap check that is also reusable

Cross-compile the existing golden corpus for ARM and run it under `qemu-user` on a
dev box. It costs hours, needs no hardware, and answers *"is our arithmetic
bit-exact off x86 at all?"* — the single assumption every Daisy plan rests on. That
script belongs in `ssx-common/daisy/` too: it is the first thing you run for every
future synth.
