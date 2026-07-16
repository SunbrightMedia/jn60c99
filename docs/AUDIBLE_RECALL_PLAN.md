# Audible patch recall — feasibility, plan, and progress


> **SUPERSEDED (2026-07): this document is historical.** Live status is
> `PROVENANCE.tsv` (checked by `make verify`); the claims ledger is
> `docs/CLAIMS.md`. Where this file conflicts with those, they win. In
> particular, the "not recalled / held constant" conclusions about the DCO
> RANGE / LFO / PWM cluster were REFUTED by the plugin's own recall enumerator
> (rva 0x3B48A0, executed) — see CLAIMS §E11–E13; and recall is NOT complete:
> the FX path has known open divergences (delay feedback 102560, patches
> 50/6/45). Kept as a record of how the earlier conclusions were reached.

Goal: load a JU60 bank patch and hear it, by **porting the original code** (no
runtime captures). This records what was proven with the plugin binary +
decompile in hand, and the concrete plan.

## Session update — note-on, polyphony done; chorus-mode/extended params blocked

Newest, honest state (supersedes the older "Approximate/Next steps" notes below):

- **Note-on / gate / pitch — FAITHFUL now (was a hack).** Pitch is the per-voice
  slot `state[voiceBase+304] = note/12` and the gate ramps `state[voiceBase+320]`,
  both DERIVED from `voice_render`'s algebra + the live-plugin state dump (the
  frozen glide/gate conditioners `v28==state[304]`, `v29==state[320]` because
  `state[240]*state[272]==0`); `state[4448]=-4.75` is the fixed tune. Rendered
  check: MIDI 48/60/72/84 → 130.81/261.63/523.25/1046.50 Hz, 0.00-cent error. The
  fitted `PITCH_C4=-6.4192` and the `state[320]=0.01` poke are gone.
  (`src/juno_note.c`.) NOT folded in, stated plainly: the ~+2.2-cent master tune
  (analog table `sub_1803BD180`) and velocity→amp (gate-on param 1090 descriptor
  indirection).
- **8-voice polyphony — FAITHFUL now (was voice 0 only).** The per-voice state
  layout is DERIVED by diffing the 8 compiled voice functions (main +v*10512,
  shared +0, aux +v*32); a self-consistency test proves all 8 voices render
  bit-identically. Chords now sound (native 8-voice; browser via the rebuilt
  WASM). See **docs/POLYPHONY.md**.
- **Extended engine params NOW RECALLED (was blocked on record positions).** The
  extended-region byte positions were cracked from the binary: the in-binary
  leaf-order table (VA 0x180C46000) + deterministic value-tree serialization give
  `raw = 490 + 8*(leaf-113)` for the NAME1/2/3 block (the external XML only packs
  the compact blob, NOT this region — the prior "external schema" blocker is
  debunked for the extended region). Bound and verified bit-for-bit vs the Unicorn
  oracle across all 64 patches (0/448 mismatches): **VCA MODE** (rec 490 → ENV1/
  ENV2/Gate at 10176/10192/10208; 12/45/7 — GATE is audibly organ-like),
  **LFO TRIG ENV** (rec 554 → 2560/3040), **VCF/VCA VELOCITY SENS** (rec 1862/2102
  → 7424/9600, v/255). MASTER TUNE is a SYSTEM/global leaf (absent from the per-
  patch record), so correctly not recalled. MOD SENS / CONDITION recall to 0/
  constant in this path (inert) — not bound. HPF TYPE deferred (its offsets are
  already front-panel-bound — needs ordering care).
- **HPF TYPE NOW RECALLED (was a latent bug).** The HPF's 4 engine coefficients
  (10240/10256/10272/10288) are a JOINT function of HPF CUTOFF FREQ (blob 38) and
  HPF TYPE (record 618); the value tree applies HPF TYPE last. The front-panel-only
  binding was correct for the 54 TYPE=0 patches but wrong for the 10 TYPE=1 patches.
  Fixed: `hpf_type_lut.c` captures the plugin's TYPE=1 output over all 256 cutoff
  bytes (baked LUT, same principle as juno_curve); all 64 patches' HPF now matches
  the oracle full recall (0/256). 
- **Effect-mode selector mapping — NOW PROVEN (was "unprovable").** By
  disassembling the value-tree dispatch (sub_7FF91E019A30) case 875 = DELAY TYPE:
  it does `mov edx,5; call setProgID` — index 5 → Prog_ID vector entry 5 =
  Prog_ID_DLY = cell 11022056 = **v39** (confirmed by building the vector in the
  oracle: entry 5's valuePtr = engine+11022056). So **DELAY TYPE → v39** (the
  chorus/delay/flanger stage; identity 0-5) and by symmetry **EFFECT TYPE → v551**
  (Prog_ID_EFX = 11022052). The earlier ambiguity is resolved from the code, not
  guessed. Consumers are the ported master_render. The delay mode even RENDERS:
  setting v39=0 + the "Mute" selected-mask 102592=1.0 + delay coeffs produces
  echoes (verified).
- **Per-patch DELAY recall — NOW DONE (was blocked on the EFX blob permutation).**
  Script.xml (the value-tree schema the plugin's parser reads) + the Unicorn oracle
  resolved both open pieces for the delay slot:
  (a) EFX blob permutation: the schema's declaration order + the proven
  address-order serialization fix the four front-panel EFX leaves at blob
  {50,51,40,49} = {EFFECT DEPTH, REVERB LEVEL, DELAY LEVEL, DELAY TIME}. Confirmed
  by the oracle: recalling DELAY LEVEL (dispatch idx 796) writes Wet(102528) =
  level/255 **bit-exact for every delay-active patch (0 mismatches)**, which only
  holds if blob40 = DELAY LEVEL — so the earlier "not proven" ambiguity is closed.
  (b) Delay coefficients: running the real value-tree dispatch for the delay leaves
  gives every 102xxx coefficient the plugin writes — Wet = DELAY LEVEL/255,
  Feedback = DELAY FEEDBACK/255·0.9, On/Off + Mute = (level>0), Dry = DELAY DIRECT
  LEVEL/255, Time = a 256-entry LUT (idx 797), and a high-cut+damp filter block that
  is **constant across all 64 bank patches** (all use the default filter). These
  ship in `src/delay_recall.c` (the LUT + apply fn) and are applied per-patch by
  `juno_bank_apply`. The driver points the master's v39 chase at the engine cell
  `state[11022056]` so slot 1 follows DELAY TYPE. Verified: v39=0 + these coeffs
  renders the expected regenerating echoes; all 64 patches render finite; the ~15
  DELAY-TYPE-0 patches with level>0 now audibly echo (`tests/test_delay_recall.c`).
  This also **fixes the double-chorus bug**: slot 1 was forced to chorus for every
  patch; it now plays its real per-patch DELAY TYPE (delay / passthrough / chorus).
- **Slot-2 CHORUS — now shown to be COMPLETE, not a gap (verified this session).**
  Deep dive into `master_render`: modes 2 and 3 both fall into the same `if (v39<=3)`
  / `if (v551<=3)` branch with **no `==3` sub-branch anywhere** — so "Chorus I" and
  "Chorus II" run byte-identical code on byte-identical coefficients (an empirical
  A/B render confirmed 2 and 3 produce identical output). The chorus LFO rate cell
  `6395648` is written **only** by `engine_init` (grep of the full decompile: exactly
  one writer, `sub_1803990C0`), never per-mode — so there is no per-mode chorus coeff
  to recall. And the PATCH2 chorus params (PRE DELAY, LOW/HIGH CUT, LFO GAIN/OFFSET)
  are **constant across all 64 bank patches** (all default). Net: **the 55 chorus
  patches (EFFECT TYPE 1/2/3) are already served correctly** by engine_init + the
  master; the earlier "chorus I/II" worry was a non-issue in this engine.
- **Residual: slot-2 EFFECT TYPE modes 1 & 5 (9 patches) — at the verifiability
  limit under binary-only/no-captures.** The two insert slots are v39 (DELAY TYPE)
  and v551 (EFFECT TYPE). EFFECT TYPE is {1:1, 2:33, 3:22, 5:8}; the master routes
  v551: 0->distortion(DS), 1->86xxx, 2/3/4->chorus (byte-identical), 5->95888. So
  v551=2 is correct for the 55 chorus patches. The remaining 9 (modes 1 & 5) were
  investigated fully with the master-object oracle:
    - The slot-2 effect blocks' params (mode-1 ids 0x37c-0x37f -> 86288..86336;
      mode-5 ids 0x396-0x39a -> 96352..96416) are **NOT recalled by any value-tree
      leaf** (scanned dispatch 742..1400) — they are fixed, not per-patch.
    - The mode-1 block is all-zero in our state (unconfigured -> routing v551=1 is
      SILENT); the mode-5 block is configured only from the capture (96400/96416=1.0)
      and routing v551=5 attenuates ~2x.
    - The param-smoother defaults read 0 and the param DB (`&unk_7FF91E5EC040+16*id`)
      does not encode a readable default — so the *correct* fixed value for these
      blocks depends on the effect-object **smoother subsystem's** runtime behavior
      (a per-sample ramp path we do not port), and cannot be pinned from static data.
  Because their correctness can't be verified without the original plugin's audio
  (a capture, which is forbidden), v551 is kept at 2 (chorus) — a known-clean
  stand-in, no regression. This is the one place where "sounds exactly the same"
  and "binary-only, no captures" genuinely conflict for a subset of patches.
- **REVERB — NOW RECALLED per-patch (was the last gap). CRACKED via a 2nd oracle.**
  The reverb is NOT a slot-2 insert; it is a **global send** in the master output
  stage (`master_render` LABEL_105), always active, scaled per-patch by REVERB LEVEL.
  I built a second Unicorn harness that constructs the real `CJu60Sim` effect engine
  (`sub_7FF91DFE80F0`) and runs the descriptor + param-smoother build
  (`sub_7FF91E022550` -> `sub_7FF91E0225B0`), which binds each effect param to its
  engine coefficient from the plugin's `.rdata` tables. Reading those bindings gave
  the reverb param -> coeff map: **REVERB LEVEL (blob 51) -> 10759408** (send/wet),
  **REVERB TIME (rec 666) -> 10759680** (decay feedback). The per-value curves are
  the plugin's own value-tree outputs (captured from the effect param setter
  `sub_7FF91E022E80`). Shipped in `src/reverb_recall.c`, applied per-patch by
  `juno_bank_apply`. VALIDATED: patches with REVERB LEVEL=0 add exactly 0 reverb;
  patches with LEVEL>0 add a reverb tail proportional to level; all 64 render finite
  (no blow-up). `tests/test_reverb_recall.c` freezes the mapping. This also confirms
  the reverb tank coeffs are sample-rate constants written only by `engine_init`
  (never modulated), so only these two smoothed params are per-patch.
- (superseded) **Slot-2 REVERB — earlier mislabelled as the gap.** The stage-2
  block `95888..96928` I traced (below) is a *different*, mostly-inactive effect
  path; the audible reverb is the global send above. Kept for provenance.
  The stage-2 reverb is a full allpass-diffusion +
  comb tank at engine block `95888..96928` (distinct from the stage-1 reverb block
  `6497xxx/10692xxx`). `engine_init` writes its tank coeffs (comb feedback 0.999,
  allpass gains) and the capture sets the enable gates (`96400=96416=1.0`) — yet a
  2-second post-release render shows **no reverb tail** (v551=5 decays *faster* than
  chorus for every EFFECT-TYPE-5 patch; some go silent). The reason: the per-patch
  reverb configuration (REVERB TIME **varies 87–255 across patches**, DENSITY, the
  send/return level from REVERB LEVEL) is applied through the **master/effect object**,
  not the value-tree. Proof: recalling REVERB LEVEL (dispatch idx 795) **faults in the
  value-tree oracle** at VA `0x7FF91E022E86`, dereferencing a null effect-object
  pointer (`null+0x14`) — i.e. the setter targets the master effect object, which the
  voice-graph oracle never constructs. Deriving per-patch reverb therefore needs a
  **second emulation harness that constructs and runs the master/effect object** (its
  ctor + prepare + the REVERB LEVEL/TIME/DENSITY setters), then dumps the `95888..96928`
  block per reverb config. That is the last, hardest piece — large and not yet built.
  Until then reverb patches deliberately stay on the (safe, non-regressing) chorus,
  and routing v551 to the un-configured reverb/slot-2-delay is NOT done (it regresses).
  - **DSP-level trace (this session), narrowing the blocker further.** An impulse
    into the reverb (v551=5) shows the tank **does ring**: state `95936` decays from
    ~12 to ~0 over ~6000 samples (a short ~0.06 s room), and the reverb output
    register `84704` carries it (~0.01). Tracing both output channels: the reverb tail
    **is present but only in R** (`96320`→`84704`→v37→`84880`, R ≈ 0.0015 decaying to
    ~1e-4), while **L is silent** (`96304`→`84672`→v35→`84864` is input-derived and
    dies with the note). So a reverb tail renders, but quiet and hard-panned — exactly
    the signature of the per-patch WET/RETURN level (REVERB LEVEL) being **unset**: the
    (chorus-preset) capture leaves it at 0, and it is applied through the effect object. So the remaining unknowns are exactly two
    effect-object-supplied numbers — the reverb **wet/return gain** (from REVERB LEVEL)
    and the **decay/damping** (from REVERB TIME) — both requiring the master-object
    harness above; the tank algorithm itself is already correct in the port.
    Attempted extending the value-tree oracle: the effect object at `THIS+88` IS
    allocated by the ctor, but **its own param-smoother array (`obj+88`) is null** —
    the vtable-indirect sub-construction that would build it did not run under
    emulation, which is why the REVERB LEVEL setter derefs null. Building that array
    (or running the master ctor that builds it) is the concrete next step.
- (superseded) The full FX DSP (delay/chorus/flanger/reverb/distortion) IS ported
  (`master_render.c`) and its per-mode static coeffs ARE in `juno_init.c`. But
  per-preset effect-MODE recall is not derivable from the binary: (a) the chorus
  selector is `v39 = *(int*)(S+11022056) = Prog_ID_DLY` (value 2/3 = chorus,
  proven), but the integer→OFF/I/II **labels are not in the binary** (enum strings
  live in a resource pool that isn't extractable, and no code proves the
  leaf→cell write — confirmed by two independent decompile investigations);
  (b) EFFECT TYPE's record position comes from the **external schema descriptor**
  (not in the `.vst3`); (c) the preset-dependent FX runtime coefficients for the
  non-chorus modes are **not in the binary** (only chorus-II was captured). So the
  port plays chorus II + always-on reverb faithfully and cannot switch modes per
  preset without guessing. Recoverable only by re-capturing the live plugin per
  mode, or obtaining the external descriptor.
- **VCA mode + tune switches (asked as "fix #3") — BLOCKED, same root cause.**
  VCA MODE, MASTER TUNE, OCTAVE SHIFT are extended params past the 222-byte blob;
  their record byte positions come from the same external schema. VCF CUTOFF H
  (record byte 1870) was recoverable only because it has a coarse front-panel
  counterpart to correlate against; VCA MODE / tune have none, so their positions
  can't be found by correlation and won't be fabricated.

## Baseline classification — what the captured `runtime_coeffs` table actually is

The one remaining non-binary piece is `src/runtime_coeffs_data.c`: 279 engine
coefficients memory-scanned from the live plugin (default preset "PD The Juno
Pad", 96 kHz) — the parameter-applied engine state that no static init writes.
"Retire the captured FX baseline if possible" (task #15) was pursued to its
tractability limit this session. Findings, cross-referenced against the
master-object descriptor oracle's param→engine-offset registry (1121 params):

- **36 / 279** offsets are FRONT-PANEL coefficients that per-patch recall
  (`juno_bank_apply` + `delay_recall` + `reverb_recall` + `hpf_type`) overwrites.
  The captured value is a placeholder there; the loaded patch's own value wins.
- **243 / 279** offsets are engine INTERNALS that **no front-panel patch parameter
  targets**. A JUNO-60 patch is *defined* by its front-panel controls, so anything
  not driven by them is **patch-invariant** — identical for every patch. This table
  therefore functions as the engine's fixed DEFAULTS table, not as one preset's data
  leaking into all patches. Split: **75** pure-structural (no param targets them at
  all) + **168** internal-param defaults (**127** effect/master-block algorithm
  coeffs — reverb allpass/comb tunings, chorus/delay/distortion internals — and
  **41** voice/synth internal switches/levels: M.CV, Osc1 Level/Mute, LFO Sw,
  Velocity constants, Effect SW, Voice Output On/Off, …).
- **Net per-patch error** introduced by keeping these fixed = exactly the already
  documented **slot-2 EFFECT-TYPE modes 1/5 residual** (9 patches; effect blocks
  84544 / 85152 / 91xxx stuck at the mode-2/chorus default). Every other one of the
  243 is a genuine invariant constant equal to the plugin's own value. So switching
  patches in the port changes ONLY recalled coefficients — verifiable by construction
  (`juno_bank_apply` writes only the recalled set; the 243 are never touched).

**Why it stays a capture (not binary-derived).** These constants are computed at
plugin init by loading the default patch and running the full effect/voice PREPARE
(filter-coeff math at 96 kHz + smoother snap-to-default). The master-object oracle
constructs the real `CJu60Sim` and builds all 1121 descriptors + 798 smoothers, but
the descriptors store only name/target/type — **no default value** — and the PREPARE
that would fill the coefficients (`sub_7FF91E01C980` @ rva 0x3BC980) faults early
under emulation (the effect param-holder vector is never built). So the values remain
honest MEASUREMENTS, not fits or guesses — and they are proven to be invariant engine
constants, which is the strongest honest statement available without re-running the
plugin's entire prepare. Retiring the capture fully is bounded (needs the master
PREPARE to run to completion under emulation) but not tractable with current tooling.

## STATUS — every engine-driving parameter is bit-exact; all 64 patches verified

The browser app (`gui/web/`, mirrored to `docs/`) does the full loop:
**import a `.bin` bank → pick a preset → Apply → press a key → hear it.**
Wiring: `juno_gui_apply_bank` (bridge) → `juno_bank_apply` (src/juno_apply.c) →
`juno_curve` (bit-exact vs the real machine code) writes the engine coefficient
slots; the piano triggers the ported note/gate/ADSR driver and plays the **dry
voice** signal.

### What "all 79 parameters" actually resolves to (probed, not assumed)

Probing **all 79 panel dispatch indices** (dispatch = panel + 749) through the
emulated value tree gives the definitive picture:

- **~34 panels drive the DSP engine.** Every one that is cleanly code-resolvable
  is now **bound and bit-exact** (30 distinct parameters, 40 coefficient slots).
- **~45 panels write NOTHING to the engine** — they are JU-06A-only controls
  absent from this JUNO-60 model (OSC2, cross-mod, ring, sync, coarse/fine tune),
  or inactive type / mod-matrix slots. For these, "recall" is a genuine no-op:
  there is no coefficient to set, so they are trivially correct.
- **LEGATO / ASSIGN MODE** write no DSP coefficient either — a fresh-tree probe
  shows they are note-allocation flags (mono/poly/legato voice behaviour) stored
  in the flat param array, not timbre. Nothing to apply for exact timbre recall.

### Bound & verified BIT-EXACT (30 params / 40 coefficients)

Verified END-TO-END: `unit2/golden_cmp.py` drives the real value tree at each
patch's **actual** blob values and compares against the compiled C applier —
**all 64 bank patches match every bound coefficient bit-for-bit.** Groups:
DCO (range, PWM depth/level/source-enum, saw/sub/noise level, LFO mod), VCF
(cutoff, resonance, HPF cutoff + 3 secondaries, env-mod, key-follow, LFO mod),
both ADSR envelopes (ENV1 & ENV2 A/D/S/R in full), VCA (tone, level), LFO (delay,
rate, key-trig, tempo-sync), and portamento / bend range. Oracle cross-check:
patch 5 VCF cutoff = `juno_curve(22,153)` = `0.600000`, the plugin's own float.

The blob→panel order is the plugin's own value-tree **leaf serialization order**
(`blob_pos = pool_index − 2` in declaration order, with 4 leaves displaced +4 by
address-sort: ENV1 ATTACK, VCF KEY FOLLOW, ENV2 RELEASE, VCA TONE — so ENV1
serializes D,S,R,A). Each panel's (curve, offset, transform) is recovered by RUNNING
the real dispatch under Unicorn and matching `juno_curve(curve, transform(value))`
bit-for-bit across a dense value grid.

**Independent, non-circular validation of the mapping:** the value tree stores the
16-char patch **name** as leaves pool 72..87 = blob_pos 70..85. Decoding the raw
`.bin` blob at blob_pos 70..85 with the same nibble formula spells each patch's name
**exactly** ("LD Classic Lead", "SY Poly Synth", "SY Pulsar Twinkl", …). Real ASCII
data landing precisely where the pool mapping predicts proves the decode formula and
`blob_pos = pool−2` mapping independently of the value tree — so the golden test is
not self-referential; the mapping framework it rests on is confirmed by real data.

### The `.bin` bank-select path applies ONLY the 222-byte blob (verified in code)

A decisive finding for scoping "all parameters": the KoaBankFile bank-select
loader `sub_7FF91DFB2380` loops 64× over `sub_7FF91DFB1710` (decomp_340000.c:13216),
which reads exactly a 16-char **name** + a `0xDE` = **222-byte blob** per patch, then
a fixed 31-entry transform table — it **never reads `record[238:]`**. The blob is
the value-tree leaves pool 2..112 (`blob_pos = pool_index − 2`; dispatch index =
`pool_index + 742`). The plugin's "extended" engine params — **VCA MODE, CONDITION,
MOD SENS DCO/VCF, LFO TRIG ENV, VCF/VCA VELOCITY SENS, VCF CUTOFF FREQ H** (pool
≥113, dispatch 855/856/860/861/863/1028/1029/1058, verified name-for-name against
the engine registry) — live *past* the blob, in a separate full-tree serialization
(VST3 setState / project restore) that the bank-select path does not consume. So on
**patch-select the plugin leaves those params at engine defaults** — which is exactly
what this applier does. The applier is therefore faithful to the bank-select recall
path, not missing coverage: every parameter the `.bin` bank-select actually applies
is bound (save the 4 EFX leaves below, whose ordering is external).

### Honestly not yet bound (documented, never guessed)

- **The 4 EFX leaves (EFFECT DEPTH, REVERB LEVEL, DELAY LEVEL, DELAY TIME).** These
  occupy blob {40,49,50,51}. Structure now understood: EFFECT DEPTH & REVERB sit at
  their *direct* slots blob {50,51} (addresses 100,102 = 2·(pool−2); confirmed in the
  parser transform table), while DELAY LEVEL & DELAY TIME are *displaced* to the two
  slots the envelope reorder vacates, blob {40,49} (addresses 80,98, direct-copy).
  But the residual intra-pair orderings — EFFECT DEPTH vs REVERB at {50,51}, and
  DELAY LEVEL vs DELAY TIME at {40,49} — are **not resolvable from this binary**: the
  per-leaf schema `address` values come from an EXTERNAL descriptor file (schema
  parser fed by a `std::ifstream`; the in-binary name tables are declaration-order
  only). Worse, the display-decode and the value-tree engine path *disagree* on what
  these slots even are (the decode treats blob-addr 100 as a discrete 0-3 effect
  mode, the value tree as a continuous "DS Drive" curve), so binding them would risk
  a wrong coefficient. They also route to the master/chorus FX section — the un-
  decompiled, silent path — so per the cardinal rule (only the binary is ground
  truth, never guess) they stay deferred at no cost to the audible port.
- **Exponential tempo-rate coefficients** (LFO Tempo Rate off1072, tempo-synced
  Delay Time off102352): no `juno_curve` matches; need the specific formula from
  the decompile. Both are tempo-synced, inaudible in the free-running dry preview.
- **Note-on pitch/gate: RESOLVED** — now a faithful port (see the Session update
  at the top); the earlier "calibration" note is superseded. **Preview is now the
  full 8-voice master path** (voice mix + stereo BBD chorus mode II + output
  stage), polyphonic; the dry-voice fallback remains only when the runtime chorus
  coefficients are absent.

## BREAKTHROUGH — the Koa value tree is CRACKED by emulation (binary-only)

The "wall" below (static analysis can't recover the binding) was TRUE for static
analysis but is now SUPERSEDED: the binding is recoverable by RUNNING the plugin's
own value tree under Unicorn — no captures, no external data, pure binary.

- Construct the DSP processor by running its real ctor `sub_7FF91E013320` under
  Unicorn with `operator new` -> a bump allocator (this is what got past the prior
  object-graph failures). Vtable slot 11 = `sub_7FF91E019A30` is the value-tree
  parameter dispatch: `setParamByIndex(processor, panel_index, flag, value)`, a
  giant switch that routes to the real voice setters (which apply the real curve
  and write the engine descriptor).
- Calling `dispatch(panel_index, value)` and hooking the engine writes yields, BY
  RUNNING THE REAL CODE, `panel_index -> engine_offset + curve + exact float`.
- Validated: all 12 original anchors reproduce exactly; `juno_curve(22,153)=0.600`
  at off 6736. The panel<->engine map is exact: `dispatch_index = panel_index+749`
  (verified at every anchor + the full enabled/disabled panel pattern).
- Harnesses: `scratchpad/unit2/emu_valuetree.py` (dispatch runner),
  `emu_ctor_probe.py` (ctor), `final_blob_engine.json` / `vt_index_map.json`.

Bindings now committed (bit-exact): the 12 filter/env anchors + DCO PWM LEVEL
(blob 26 -> off 4208 curve 54; an earlier commit misattributed it to off 4144 =
DCO PWM DEPTH — the value tree corrected it), LFO DELAY TIME (off 1920 c44),
VCA LEVEL (off 101072 c49), and DCO SAW LEVEL (blob 27 -> off 4192 c54). **16
params bit-exact.** Each added only where the blob position is a strict unique
value-match to patch 5 AND `juno_curve(curve, raw)` reproduces the value tree's
float.

The engine side (panel_index -> offset+curve) is now PROVEN for ALL panel params
via the value tree — that half is done. The remaining work is purely the
**blob_pos -> panel_index** source mapping, and it is an IRREGULAR PERMUTATION,
not a simple table:
- `blob == leaf-2` (leaf = the ordered name pool at 0x180c46000; panel = leaf-7)
  holds for 28 of the 57 in-blob params, but the envelope block is reordered
  (ENV1 is stored D,S,R,A not A,D,S,R, so ATTACK is leaf+2; KEY FOLLOW / ENV2
  RELEASE / VCA TONE are also +2). So it cannot be derived heuristically to a
  bit-exact standard.
- ~15 panel params (leaf index > 111: BEND/MOD SENS, HPF/EFFECT/DELAY/REVERB
  TYPE, VCF/VCA VELOCITY SENS, VCA MODE, CONDITION, DELAY FEEDBACK, ...) are NOT
  in the 222-byte blob at all — they live in OTHER value-tree chunks of the
  20223-byte record (there is non-zero data beyond byte 238, nibble/tree-encoded).
- The recall is a separate VST3 setState path (the dispatch sub_7FF91E019A30 is
  vtable slot 11, called virtually, never by name); the parser sub_7FF91DFB1710
  only fills a parallel programmer/display buffer, and the engine recall reads the
  RAW blob. Getting every source position bit-exactly requires emulating that
  setState recall and hooking the value SOURCE of each dispatch — in progress.

So: 16/79 committed bit-exact; the engine side of the other ~63 is proven; only
their record source positions remain, blocked on the setState recall emulation
(no fabrication until each is proven by running code).

### Second structural finding — some panel params are COMPOUND (multi-write)

Running the value-tree dispatch per param shows that a single panel parameter can
drive SEVERAL engine coefficients at once, not one:
- EFFECT DEPTH (dispatch 794) writes off 84544 (a saturating curve, clips at 1.0)
  AND off 85136 (a smooth 0..1) AND touches off 85152 — one knob, a drive+level
  macro.
- LFO RATE (dispatch 752) writes off 1072 as an exponential Hz rate (0.34..87 Hz)
  AND off 1088 / 2064 as normalized 0..1 values.
- DELAY LEVEL (dispatch 796) writes off 102528 (curve 22) AND a switch off 102576.

The current applier binds ONE {blob,curve,offset} per param, so it can only
represent the SINGLE-write params (filter, envelopes, DCO levels, etc.). The
clean way to make ALL 79 bit-exact — including the compound ones — is to PORT the
value-tree dispatch `sub_7FF91E019A30` itself to C (transcribe its ~312-case
switch, each case calling the real curve + its one-or-more raw stores), then feed
it `dispatch_c(panel_index, blob[blob_pos(panel)])`. That, plus the blob->panel
recall map, is the definitive route to full bit-exact recall. Both are bounded
transcription/emulation tasks from the binary (no captures); neither is guessed.

## The Koa binding wall — established conclusively (4-angle investigation)

A thorough investigation (parser trace, Koa-registration read, .rdata/.data scan,
and Unicorn emulation) settled WHY coverage cannot be extended past the 12 verified
params by static analysis alone:
- The bank-blob -> panel-state decode IS fully verified (parser sub_7FF91DFB1710 +
  the 31-entry table dword_7FF91E8A4290). blob_pos == parser src/2 (proven).
- The panel-state -> ENGINE-coefficient binding is a **runtime-constructed CKoaValue
  value tree**, not a static table. Its leaves hold only NAMES (a 4232-entry const
  char* pool at VA 0x180c46000, e.g. "fm.PATCH.FLT.VCF CUTOFF FREQ") with **no
  parallel param_id/offset/curve/setter array** anywhere in .rdata/.data.
- Decisive negatives: the only pointers to the 51 setter thunks live in the 23
  per-class C++ vtables (no auxiliary dispatch table); the distinctive prog_dest
  3041 appears exactly ONCE in the whole binary (inside the parser table), proving
  prog_dest indexes no static structure.
- The panel names ("VCF CUTOFF FREQ") differ from the engine registry names
  ("LPF Cutoff"), so there is no static string-join either.
- Emulating the value-tree construction+apply failed again on the
  CPrmDSPJu60Plugin object graph (operator new / std containers / atomics / RTTI) —
  a second independent attempt confirming the prior "not tractable" finding.

Result: **new_bindable_count = 0**; the 12 bindings were, however, re-validated by
multiple independent methods (VCF cutoff oracle-exact). Extending coverage requires
one of: (a) fully emulating the runtime value-tree object graph (hard, 2 failed
attempts); or (b) more ground-truth coefficient values (the plugin's "*_H" floats)
for the unbound params, letting each curve be IDENTIFIED (not fitted) against the
66 real curves — the same method that produced the 2 existing oracles.

## Verdict: BOTH remaining units are BOUNDED and portable from what we have

The earlier "disproportionate / needs data we don't have" conclusion
(`PARAM_SETTER_PLAN.md`) predated having the **bank file** (the preset data) and
the **plugin binary** (all the code + `.rdata` tables). With both in hand, two
independent deep traces (against `refs/` + the `.vst3`) find:

### Unit #1 — note-on / gate / ramp engine — BOUNDED (~450 lines Tier-1)
Small, fully-decompiled functions. Tier-1 (minimal audible note): descriptor
set/get/trigger, ramp ctor/start/step/reset, the active-voice vector, voice
trigger `sub_1803C2920`, pruner `sub_1803C24A0`, gate on/off
`sub_1803C1720/17A0`, + a per-block driver. Corrections found vs old docs:
- **Ramp target is 4.0** (`unk_…EB50` = `0x40800000`), not 1.0.
- Ramp is **stepped-linear**, advanced by the pruner once per control tick,
  incrementing every `subdiv`(=10) ticks; `rate` (engine+80) = sample rate.
- The note-on edge `state[101504]` is a **one-shot** (latches DCO phase, then
  self-zeros the same sample) — holding it high re-zeros the phase → silence
  (that was the earlier empirical test's bug).
- Note→pitch: the integer note stays integer through the whole keyboard/assign
  chain; the octave conversion happens in the CDSPJu60 engine
  (`sub_180413320` handler) reading a cents/1200 fine-tune table. **One function
  to trace — do NOT fabricate `(note-60)/12`.**

### Unit #2 — patch → engine coefficient applier — BOUNDED (~500–800 lines + data)
NOT the reflection framework that was feared. The actual math is **`clamp + LUT`**:
- `sub_1803B6380` — one curve evaluator: a 66-arm switch, each arm
  `clamp(value,0,N); return LUT[v]` over ~28 baked `.rdata` float tables
  (`dword_…5C97D0` … `…5CE2E0`), with sample-rate variants. ~100 C lines + the LUTs.
- ~130–188 per-parameter setter thunks collapse to a **~150-row data table**
  `(programmer_field → curve_id, engine_offset)` + one generic apply loop.
- ID→offset map: already `docs/COEFF_PARAM_MAP.md` (312/349).
- Factory-default patch `sub_1803A66B0`: ~1121 `(offset, const)` raw stores → a
  data table (gives the default patch entirely from original code, no capture).
- **~138 of the runtime coeffs are DIRECT** (raw-stored; the perceptual curve is
  in the DSP we already have — e.g. `voice_render` maps normalized cutoff to
  frequency itself). The **57 "computed" biquad taps are all in the post-voice FX
  chain** (delay/chorus/reverb), recomputed by each effect's own setup — a JUNO
  panel patch never touches them.
- Residual wiring (which field drives which setter) lives in `.rdata` vtable
  dispatch tables **present in the `.vst3`** → extract statically. No capture.

## Progress this session
- ✅ **Ramp engine ported** — `src/juno_ramp.c/.h`, exact transcription of
  `sub_1803C2E80/2E00/2E60` (incl. the `0x1F800000/0x9F800000` direction nudges).
- ✅ **Blocker pinpointed empirically.** With the captured PD-Juno-Pad coeffs +
  the ramp engine: the **DCO oscillator runs** (saw `state[1792]≈-0.99`) and the
  **VCA path is open**, but the **filter envelope gate `state[2576]` stays 0**
  (VCF output `state[10544]=0`) because the ADSR gate `state[560]` never leaves 0.
  So the exact missing wiring is: **what the note-on trigger ramps to make
  `state[560]` open the filter/amp ADSRs.** `state[560]` is computed from a
  DCO-path signal, so the gate is not a naive `state[544]=4` (confirmed silent).

## MILESTONE — the port makes its first audible note (unit #1 Tier-1)

`src/juno_note.c/.h` — an offline note driver over the ported ramp engine.
Verified: with the captured PD-Juno-Pad patch loaded, `juno_note_on(st,0,60,100)`
+ per-sample `juno_note_tick` + `juno_voice_render` produces a **non-silent,
ADSR-enveloped tone** (peak |out| ≈ 0.022; attack rise → sustain → release on
`juno_note_off`). `make test` still green. This is the first time the port
sounds — from ported control-layer code, no captures.

**What is correctly traced (real code):** the shared ADSR gate is `state[560]`
(both filter and amp envelopes: `attack ⇔ state[560] ≥ 0.5`, since the fixed
thresholds `state[2864]=state[3344]=-0.5` from init). `state[560]` is the output
of the DCO gate-conditioner `v29 = s272·s240·(s208−s320) + s320`; with the patch
DCO-coeff slots 208/240/272 at 0, `v29 = state[320]`, so ramping `state[320]`
opens the gate. This corrected the earlier misread (`state[560]` is derived, not
directly writable; and `v125=1` is *idle*, not attack).

**Honest caveats — the DSP is fine; both gaps are un-ported CONTROL-LAYER inputs:**
0. **The DSP layer is NOT the problem.** Measured: `state[4416]` doubles per
   octave of `state[4448]` exactly (clean frequency scaling); the ADSR gate
   `state[560]` and thresholds are read exactly. An earlier note here claimed a
   "DSP scaling discrepancy" — that was wrong and is retracted. The DSP plays
   whatever inputs it's given, correctly. The two issues below are inputs the
   note-on (control layer) must supply and that we haven't traced.
1. **Gate opener is a HACK, not the faithful write.** `state[560]` opens when the
   conditioner `v29 = s272·s240·(s208−s320)+s320 > 0`. The real note-on loads
   pitch-derived DCO coefficients into 208/240/272/320 so v29>0 falls out; we
   instead poke `state[320]` — the DCO **phase accumulator** — which works but is
   the wrong mechanism. The faithful write needs the descriptor-1090 ramp
   out-pointer binding (unresolved init gap).
2. **Pitch VALUE is an unverified calibration.** The DSP plays `state[4448]`
   exactly; we just don't have the control-layer integer-note→octave formula, so
   the constant in `juno_note_pitch` is a guess (currently ~an octave off). Trace
   `sub_180413320` for the real note→pitch map → in tune.
3. **Velocity is accepted but unused** (amp comes from the ADSR).

## Next steps (in order)
1. Trace the descriptor→ramp-object→slot binding for the gate param (the init
   that sets each ramp object's out-pointer) → the exact slot the trigger ramps,
   and how it makes `state[560]` open. Then Tier-1 unit #1 → **first audible note**
   (with the already-captured patch).
2. Trace `sub_180413320` note→octave → correct pitch.
3. Port unit #2 (curve evaluator + LUTs + 150-row binding table + factory
   default) + extract the `.rdata` dispatch tables from the `.vst3` → **any bank
   patch audible**.
4. Verify: factory-default patch (from `sub_1803A66B0`, no capture) is a
   ground-truth cross-check for the applier; per-note A/B once a note sounds.
