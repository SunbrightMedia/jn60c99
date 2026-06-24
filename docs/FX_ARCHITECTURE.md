# FX/arp architecture — data unblocked, and the real shape of the work

The data-section dump (`extract_data_sections.py`) **worked**: vtables now resolve,
and every coefficient/tempo table is in hand (`refs/data/`). The earlier blocker is
gone. What it revealed is the *shape* of the remaining work, which is worth stating
plainly.

## Win: the reverb is a recovered, standard algorithmic reverb
`CDSPRev` loads four tables (selected by sample rate, then by hall type via `idx<<6`):
- `unk_63A350` — **delay-line lengths** in samples (246, 738, 1910, 196, 586, 1516, …),
  grouped per comb/allpass stage.
- `unk_639F20` — **allpass feedback coefficients** (1.0, 0.9986, −0.9986, 0.9972, …).
- `unk_63A130` — **damping biquads**: (b0,b1,b2,a1,a2) sets, e.g.
  (0.0004, 0.0008, 0.0004, 1.9417, −0.9434) — lowpass dampers in the tank.
- `unk_63A600` — a scalar (≈0.065, wet/level).
So HALL2 is a Schroeder/FDN tank: delay lines + allpasses + per-stage damping. Fully
transcribable now that the coefficients exist.

## The shape: controller/worker split, several layers deep
Each "effect" is **not** one DSP function. It's a tree of *controller* objects whose
vtables are mostly parameter setters (verified: `refs/data/vtable_*.txt`), with the
actual audio worker reached through more indirection:
- `CDSPRev`: ctor → SR table-select (`sub_1803C17C0`) → **buffer setup**
  (`sub_1803C1AC0`, sums the delay lengths to size the tank, binds them to params
  0x44A/0x454/0x457/…) → a per-sample **worker** that runs the tank (separate fn,
  reached via the FX-chain dispatch — the same indirect-call boundary that originally
  hid the chorus).
- `CDSPSystem8DlyDly`: a composite (DlyDly + DlyCh + DlyPan + DlyMfx1 + DlyFlSt);
  the vtable is 24 control slots, delay time via tempo table `unk_910DC8`.
- `CKbdArp`: clocks a precomputed pattern table; note-getter + note-on are vtable/
  fn-ptr indirect (now resolvable via `refs/data/`).

## Honest scope
This is no longer *blocked*, but it is *large*: each of the three is a multi-layer
subsystem (controller → setup → worker), comparable in effort to a sizable slice of
the synth voice, and the per-sample workers sit behind the FX-chain dispatch that has
to be traced (as the chorus once was). Realistically this is **one subsystem per
work-session**, not a single pass.

Recommended order (clearest first): **reverb** (coefficients fully recovered) →
**delay** (needs the `unk_910DC8` tempo table re-cut from the right offset) →
**arpeggiator** (logic + pattern builder). Each lands as an exact transcription like
the voice/master/chorus, validated as it goes.

## Provenance committed
`refs/data/`: the resolved FX/arp vtables, the six FX/arp/gate tables (raw bytes),
and the segment map. Full 5.4 MB dump (raw `.rdata`/`.data`/`.pdata`) kept locally,
gitignored. Resolver: `tools/resolve_vtable.py`.

## Arp finding (closes the loop)
The arp scanner (`sub_1803C0260`) and note-output (`sub_1803C35A0`: velocity-sens
scaling → synth note-on via `*(synth_vtable+24)`) are transcribable, and the
note-ordering (mode/range via `obj+3472`) is visible in the scanner. BUT the
rhythm/gate **pattern table** (`obj+610`, 6 bytes/step) is **patch data** — it's
what makes "SQ Dynamic **ARPG**" a specific sequenced groove. So reproducing *this*
arp needs the preset parser too. The arp *engine* is doable; the *pattern* is data.

## Net scope to reproduce "SQ Dynamic ARPG"
Four large, partly-interdependent subsystems:
1. **Preset parser** (`KoaBankFile00003` schema) — supplies the patch values AND the
   arp pattern. Largest single sub-project; mostly generic Roland-framework plumbing.
2. **Arp engine** — scanner + key buffer + clock; transcribable, drives note events.
3. **Delay worker** — behind the threading/task dispatch; needs the dispatch traced.
4. **Reverb worker** — Schroeder/FDN tank (coefficients recovered); also behind the
   task dispatch.
The data is fully unblocked for all four; the remaining cost is transcription +
tracing the FX task dispatch, realistically multiple dedicated sessions.

## Deep trace result (reverb worker hunt) — the real blocker
Traced the full effects-chain object and audio path:
- The whole DSP is one object `CPrmDSPRev<CPrmDSPSystem8Dly<CPrmDSPJu60>>`
  (ctor `sub_1803B3010`): synth base at +0, delay sub-objects at +6784 (DlyDly),
  +6976 (Pan), +7184/+7400 (Ch), +7616 (FlSt), +7824 (Mfx1), reverb at +8176.
- Chain vtables resolve (CPrmDSPSystem8Dly @0x9C19F8, CPrmDSPRev @0x9C2508); the
  per-layer overrides (slots 0/2/3/4/5) are all **lifecycle/param dispatchers**
  (no audio-buffer arg) — `sub_1803B86C0/8830/8560` just switch on the FX-type
  selector `obj+1480` and call a sub-object's control method.
- The **synth** audio process is `sub_1803C7400` (loops samples → `sub_180398EC0`
  = voice mix + master/chorus → level metering). It has **no static callers** and
  does **not** reference the FX sub-objects — it's a task dispatched through the
  threading worker (`sub_1803C6F00`, mutex/condvar queue).
- The CDSPRev sub-object's own vtable is all small param setters; its largest method
  is the buffer-setup `sub_1803C1AC0` (sums delay lengths to size the tank). No
  large per-sample tank-DSP function exists in the reverb's code region.

**Conclusion:** the per-sample FX DSP workers are reached only through the threading
task queue + indirect vtable dispatch, assembled at runtime; ~12 levels of static
tracing did not surface the actual reverb/delay sample loop. The structure is fully
mapped and the reverb coefficients are recovered, but the worker *functions* are not
statically locatable. This is the genuine blocker.

**Cleanest unblock (navigational only):** one runtime call-tree trace on the process
callback (`sub_1803C7400` / the chain process) logging the function addresses that
touch the audio buffer. That reveals the FX workers in one shot; the transcription
itself stays 100% static from the decompile. Alternatively, keep hunting statically
for the task-enqueue sites that reference the FX worker fn-ptrs (slower, uncertain).

## RESOLVED: the FX live inside CJu60Sim (a circuit/graph simulator)
Kept digging statically and reached ground truth. The reverb's `CDSPRev` object is a
thin front-end over a shared engine pointer at `CDSPRev+8`. Every reverb method just
issues graph-build calls into that engine:
- `engine.vtable+16` (sub_1803C00B560)  = define buffer/tap `idx` of length `N`
- `engine.vtable+24` (sub_1803E8160)     = reset (writes state[+10759872]=256)
- `sub_1803C22920(engine,id,val)`        = set node coefficient/connection by id
The reverb's setup (`sub_1803C1AC0`) walks the recovered delay-length table and emits
~30+ `define-tap` calls (offsets accumulate: +963, +2, ... = the tank taps) plus
coefficient binds (param ids 0x44A, 0x454–0x45F). So the reverb is **graph DATA**, not
a DSP function.

The engine class is **`CJu60Sim`** (JUNO-60 circuit/signal-graph simulator), vtable
@0x98AE98, with a ~10.7 MB per-instance state workspace (9 instances allocated in
`sub_1803C68D0`). Its solver methods are enormous:
- slot 9  `sub_1803A66B0`  ~20 KB
- slot 10 `sub_1803F90C0`  ~33 KB
- slot 11 `sub_1803A1300`  ~21 KB
- slot 14 `sub_1803E8170`  ~67 KB  ← **decompiler emitted `// None` (could not lift it)**

**Conclusion.** The delay and reverb are sub-graphs of CJu60Sim, evaluated by these
unrolled solvers (one of which is undecompilable). There is no compact, standalone
reverb/delay algorithm to transcribe. Two honest paths:
  A. Reconstruct the CJu60Sim node model from the decompiled solver slots (10/11/9) and
     rebuild the reverb/delay sub-graphs from their setup data — large, uncertain (33 KB
     of unrolled math to read), but bit-faithful in principle.
  B. Implement a standard algorithmic reverb/delay seeded with the ALREADY-RECOVERED
     coefficients (delay lengths 246/738/1910/…, allpass gains, damping biquads). This is
     a recognizable plate/FDN topology and will sound musically close, but is NOT
     bit-identical to the circuit sim.
The recovered coefficients make path B immediately actionable; path A is a project.
