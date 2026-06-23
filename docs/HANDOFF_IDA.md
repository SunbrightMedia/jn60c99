# HANDOFF — JUNO-60 DSP → C99, EXACT-PORT RESTART (read this first)

This is a **fresh start** for a project that previously went off the rails. Read
this whole file before doing anything. It is deliberately short and contains only
information that is **true and useful** — none of the earlier project's
approximations, fitted coefficients, or false validation metrics are carried over.

---

## 1. THE MISSION (and the one rule)

Produce a C99 port of a VST synthesizer's **DSP audio engine** that is an **exact,
structural transcription of the plugin's actual algorithm** — same operations, same
signal flow, same coefficients — just written in C99 instead of compiled x86-64.

**THE RULE:** the decompiled plugin code is the spec. You transcribe it. You do
**not** fit curves, tune constants to match audio, or approximate a DSP block
because the decompile is hard to read. If a block is hard to read, you read it more
carefully — you never replace it with an easier stand-in.

The plugin is the **Roland Cloud "Cloud 60"** (a JUNO-60 emulation). x86-64 PE.
**ImageBase 0x180000000.**

---

## 2. WHY THIS IS A RESTART (the hard lesson — do not repeat it)

A previous multi-week effort produced a C99 synth that **sounds wrong** — bad VCF,
broken voice mixing, a chorus that amplifies and distorts. Root cause, stated
plainly so it is not repeated:

- Instead of transcribing the decompiled DSP, the previous work **built a different
  synth (fitted SVF filter, approximated chorus, "derived default" mix scalars) and
  calibrated it to match six sustained test tones in broadband RMS.**
- It then declared success because a **single RMS "fingerprint" number** and an
  **RMS-on-6-patches scorecard** were passing. Those metrics cannot see a wrong
  filter topology, wrong voice mix, or a broken chorus. They were the wrong score.
- Every time it hit a hard-to-read DSP block, it substituted a fitted approximation
  and moved on. That is the entire failure.

**New validation philosophy:** the decompile defines every intermediate signal.
Validate **per-function / per-stage**, comparing the port's intermediate values to
the algorithm in the decompile — not end-to-end RMS on a few notes. RMS/NaN checks
survive only as crash smoke-tests, never as a definition of "correct."

---

## 3. TOOLCHAIN DECISION (made — use this)

**IDA Pro 9.3 SP2 (build 260421), x86-64 decompiler, IDAPython.** SDK not required.

Why IDA Hex-Rays, not Ghidra: the parts that sank the last attempt (VCF, chorus)
are SIMD-vectorized DSP. Ghidra renders that as `undefined4` offset math and raw
`vfmadd…` intrinsics — unreadable enough that the last effort gave up and fitted.
Hex-Rays recovers float types and FMA semantics far more often (shows `a*b+c`,
coherent locals, propagated structure), which is the difference between *reading*
the filter topology and *guessing* it. 9.3's value-range/conditional improvements
further clean up the branchy clamp/LFO logic. The whole point of the restart is to
not approximate the hard functions, so pick the tool that makes them readable.

License note: ensure the **x86-64 decompiler** is assigned to your bundle (Ultimate
has all; Expert-N must list it). IDAPython ships with IDA. SP level is irrelevant to
us (SP1/SP2 were V850 + security fixes, nothing touching x86-64 or the API) — SP2 is
just the current, recommended build.

---

## 4. THE EXTRACTION PLAN (one script, run once)

`extract_dsp.py` (in this handoff) is an IDAPython script for IDA 9.3. It pulls the
**entire DSP call-tree** so you never extract again:

1. Seeds from the known per-voice render, **climbs up a few caller levels** to find
   the audio roots (the process/master-mix function that calls both the render and
   the chorus), then **walks down the full call graph** to the leaves.
2. For every function in that closure it dumps: **Hex-Rays pseudocode (.c)**, the
   prototype, the callee list, and **every constant/global it reads** (with float
   values — the real coefficients live here).
3. Emits `MANIFEST.md` (index), `callgraph.txt` (edges), and `constants.txt`
   (consolidated coefficient table).

**Run it:** GUI `File > Script file…` on the auto-analyzed database, or headless
`idat64 -A -S"extract_dsp.py" -L"extract.log" <plugin>`. Output lands in `dsp_dump/`.

### Two things to confirm at the top of the script before running
- **SEED_EAS** — pre-filled with `0x180369070`, the per-voice render (this address
  is verified from prior work: ImageBase 0x180000000, so RVA 0x369070). The
  caller-climb should auto-find the master-mix and chorus entries from this alone;
  but if you already know those two addresses, add them to SEED_EAS for a cleaner,
  auto-discovery-free walk.
- **SCOPE** — leave at `"subtree"` (audio closure only; everything we need, stays
  ingestible). `"all"` dumps every function in the binary if you want the superset.

The database is **already auto-analyzed** (all prior captures came from an analyzed
DB), so the script can walk the call graph directly — no need to trigger analysis.

---

## 5. THE PORT WORKFLOW (after extraction)

1. Read `MANIFEST.md`, then the **root** functions, then their callees outward.
   Build a mental (and written) map: which function is osc, VCF, env, VCA, LFO,
   chorus, voice-mix, master.
2. Transcribe **function by function**, top of the tree down. As you go, turn raw
   struct offsets into **named struct fields** (this also permanently fixes the
   "thousands of magic offsets" maintainability problem the old code had).
3. Coefficients come from `constants.txt` (static `.rdata` floats) — use the real
   values, never invented ones.
4. Validate each ported function against the decompile's intermediate signals
   before moving on. A divergence is then a **findable transcription bug**, not a
   tuning problem.
5. Only assemble the full engine once the individual stages each match.

---

## 6. THE ONE THING STATIC EXTRACTION CAN'T GET: runtime constants

Some DSP state (notably the **chorus**) is heap-allocated at runtime, so a few
coefficient *values* don't appear in the static `.rdata` dump (the *code* extracts
fine; only the live values are absent). These were captured before with Frida from
the running plugin. So:

- **Code:** entirely from IDA (`extract_dsp.py`).
- **The handful of chorus/runtime coefficient values:** from existing Frida golden
  dumps in the *old* project (files named `frida_golden_dump.js`,
  `frida_chorus_coeffs.js`, and `captures/golden_dump_*.txt`). These are **real
  measurements from the live plugin — not fitted — so they are safe to reuse.**
  Pull ONLY these captured-value files when you reach the chorus. Cross-check which
  offsets the chorus code reads (from the IDA dump) against what the captures
  provide; if something's missing, ask the user for one more Frida run.

**Do NOT pull anything else from the old project** — not the C source (wrong
foundation), not the fitted coefficient curves, not the RMS fingerprint, not the
"production status" / A/B scorecard docs. Those are the poison. Start the C99 from
the IDA dump.

---

## 7. VERIFIED FACTS (safe to trust — binary-derived or researched)

- Plugin: Roland Cloud **Cloud 60** (JUNO-60 emulation), x86-64 PE.
- **ImageBase 0x180000000.**
- **Per-voice render function @ 0x180369070** (RVA 0x369070). This is the primary
  seed and the most-understood function.
- 6-voice polyphony, one DCO per voice. Architecture to expect from the JUNO-60:
  DCO (saw + variable-pulse + square sub + noise), non-resonant HPF, 24 dB/oct
  resonant LPF (the famous IR3109-style 4-pole — **this is the topology to
  transcribe, not approximate**), two ADSR envelopes (filter + amp), one delayed
  triangle LFO (→ pitch / filter / PWM), stereo BBD chorus (modes I / II / I+II).
  Cloud-60 extras: velocity sensitivity, VCA tone, bipolar LFO/key-follow.
- The plugin's filter is **not** transparent fully open (it rolls off the top
  octave) — this is a property of the real 4-pole, and transcribing the real
  topology will reproduce it for free (the old effort fought this by hand).
- Environment for whoever runs IDA/Frida: **Windows** (Frida, Ghidra/IDA, Ableton
  Live). The C-port build/test happens in a Linux sandbox.

---

## 8. OPEN QUESTIONS TO RESOLVE WITH THE USER (first turn)

1. Confirm **SCOPE** (`subtree` recommended) and whether they have the master-mix
   and chorus addresses to add to **SEED_EAS** (optional — the climb finds them).
2. Confirm the **x86-64 decompiler** is in their IDA license bundle.
3. After they run `extract_dsp.py`, have them upload `dsp_dump/` (or a tar of it).
   That dump + this handoff is everything needed to start the exact port.

---

## FILES IN THIS HANDOFF
- `HANDOFF_IDA.md` — this file.
- `extract_dsp.py` — the one-time IDA 9.3 extraction script.
