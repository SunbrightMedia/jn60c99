# FX architecture — reverb / delay / arp

Ground truth, after tracing the effects chain to the bottom. (Earlier drafts of
this file recorded the search as a series of "blockers"; those are superseded —
the resolved picture below is what holds.)

## The FX are sub-graphs of CJu60Sim, not standalone DSP functions

The whole DSP object is `CPrmDSPRev<CPrmDSPSystem8Dly<CPrmDSPJu60>>`
(ctor `sub_1803B3010`): synth base at +0, delay sub-objects at +6784 (DlyDly),
+6976 (Pan), +7184/+7400 (Ch), +7616 (FlSt), +7824 (Mfx1), reverb at +8176.

Each "effect" object (`CDSPRev`, `CDSPSystem8DlyDly`, `CKbdArp`) is a thin
front-end over a shared engine pointer. Its vtable methods are parameter setters
that issue **graph-build calls** into the engine:
- `engine.vtable+16` = define buffer/tap `idx` of length `N`
- `engine.vtable+24` = reset
- `sub_1803C22920(engine,id,val)` = set node coefficient/connection by id

So e.g. the reverb's setup (`sub_1803C1AC0`) walks the recovered delay-length
table and emits ~30+ define-tap calls plus coefficient binds (param ids 0x44A,
0x454–0x45F). **The reverb is graph DATA, not a DSP routine.**

The engine class is **`CJu60Sim`** (JUNO-60 circuit/signal-graph simulator),
vtable @0x98AE98, ~10.7 MB per-instance workspace (9 instances allocated in
`sub_1803C68D0`). Its solver methods are large unrolled evaluators:
- slot 9  `sub_1803A66B0`  ~20 KB
- slot 10 `sub_1803F90C0`  ~33 KB
- slot 11 `sub_1803A1300`  ~21 KB
- slot 14 `sub_1803E8170`  ~67 KB  ← Hex-Rays emitted `// None` (could not lift)

The per-sample synth/FX process `sub_1803C7400` (→ `sub_180398EC0` = voice mix +
master/chorus) is dispatched through the threading task queue (`sub_1803C6F00`,
mutex/condvar), which is why no FX worker has a static caller — it is assembled at
runtime, not reachable by a static call-graph walk.

## Recovered coefficient data (committed)

`refs/data/` and the FX JSONs hold everything the graphs read:
- `unk_63A350` — delay-line lengths in samples (246, 738, 1910, 196, 586, 1516, …)
- `unk_639F20` — allpass feedback coefficients (1.0, 0.9986, −0.9986, …)
- `unk_63A130` — damping biquads (b0,b1,b2,a1,a2 sets — lowpass dampers in the tank)
- `unk_63A600` — wet/level scalar (≈0.065)
- `unk_910DC8` — delay tempo table
- `refs/reverb_tables.json`, `refs/delay_tables.json`, `refs/fx_coeff_recipe.json`
  (69 FX coeffs, bit-exact), `refs/arp_patterns.json`

The reverb's topology (delay lines + allpasses + per-stage damping, hall type via
`idx<<6`, SR-selected) is a recognizable Schroeder/FDN tank.

## Two transcription paths (a decision still open)

A. **Faithful** — reconstruct the CJu60Sim node model from the solver slots
   (9/10/11) and rebuild the reverb/delay sub-graphs from their setup data. Large
   and uncertain (33 KB of unrolled math to read; slot 14 didn't lift), but
   bit-faithful in principle.
B. **Approximate** — a standard FDN/plate reverb + BBD delay seeded with the
   already-recovered coefficients. Musically close, NOT bit-identical to the
   circuit sim.

The recovered coefficients make path B immediately actionable; path A is the
honest "bit-exact" route and is a project in itself.

## Arp

The arp scanner (`sub_1803C0260`) and note-output (`sub_1803C35A0`: velocity-sens
scaling → synth note-on via `*(synth_vtable+24)`) are transcribable; note ordering
(mode/range via `obj+3472`) is visible in the scanner. The rhythm/gate **pattern
table** (`obj+610`, 6 bytes/step) is **patch data** — what makes "SQ Dynamic ARPG"
its specific groove — so reproducing this arp needs the preset parser too. The arp
*engine* is doable; the *pattern* is data. See `docs/ARP_DSP.md`.
