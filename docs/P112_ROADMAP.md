# #112 VST3-lifecycle oracle — concrete roadmap (mapped 2026-07-23)

The remaining 8 COVERAGE GAPs (7 FLANGER param leaves 1242-1248 + Patch Tempo 1118)
and SEAL conditions 1/3/7 all require driving the plugin's own VST3 process/param
lifecycle under Unicorn. This session mapped the EXACT path at the instruction level
(all facts below PROVEN by executing the binary). It is buildable; it is large.

## Why the engine value-tree can't do it
- Dispatching flanger idx 1242-1248 through the engine value-tree `0x3B9A30` (the
  setter that applies every OTHER coefficient) writes **zero** engine cells
  (full-state diff, confirmed). Patch Tempo 1118 has **no engine thunk at all**.
- The flanger param handlers are standalone thunks `sub_...0195C0..019700`
  (1242->0x19660, 1243->0x196b0, 1244->0x19700, 1245->0x195c0, 1246->0x19650,
  1248->0x19640). Each: `call helper; cmp [rbx+0x5c8], 4; jne skip;
  lea rcx,[rbx+0x1dc0]; mov rax,[rcx]; call [rax+0xb8]` — i.e. when the effect-mode
  field `[obj+0x5c8]==4` it calls the FLANGER effect object's (at obj+0x1dc0) vtable
  method +0xb8 with the param value. `xrefs_to=0` (called only via an indirect
  dispatch table), and the runtime engine dispatch `0x3B9A30` does NOT reach them
  (even the WORKING fine-FX 1180's static thunk 0x19150 is not reached by
  e.dispatch — those static thunks are the wrapper/param-apply path, not the engine
  value tree). Forcing EFFECT TYPE 873=4 sets routing 11022052=4 + the mode-4
  STRUCTURAL cells but leaves `[obj+0x5c8]==0` everywhere and does NOT construct the
  mode-4 flanger; re-`setSampleRate` doesn't either.

## Why process() alone spins
- `process()` = `IB+0x3C7400`. Bounded run (mode 4, wait-stub) → it never runs DSP;
  it enters the MSVC concurrency-runtime thread-pool drain loop at **`0x3c8120`**
  (`call 0x34b2a0` lock; `cmp [rdi+0x30],0`; task-queue walk `[rdi+0x18..0x20]`,
  `cmp byte [task+0x14],0`, `lock inc [task+0x10]`) and calls
  `WaitForMultipleObjectsEx`/`WaitForSingleObjectEx` ~91k× each. Returning
  WAIT_OBJECT_0 does NOT help — it re-checks a task-done flag that never sets because
  no worker thread ran the pooled DSP. Emulating that scheduler is infeasible; but
  it is NOT needed (see below) — the voice/master DSP it schedules is already called
  directly by e.render() via VOICE_WRAP 0x398F30 / MASTER_WRAP 0x398EC0 (that is why
  render A/B is bit-exact).

## The path that works (param-apply is single-threaded, BEFORE the pool)
The VST3 processor's `process(ProcessData&)` wrapper = **`IB+0x34A380`**. Its
param-processing section runs on the calling thread, before it calls the internal
`0x3C7400`/pool:
- `0x34a485 mov rcx,[r14+0x28]` (ProcessData.inputParameterChanges) ; `call [rax+0x18]`
  = IParameterChanges::getParameterCount.
- `0x34a500 mov rcx,[r14+0x28]` ; `0x34a50a call [rax+0x20]` = getParameterData(i) -> IParamValueQueue.
- `0x34a527 call [rbx+0x20]` = queue getPointCount ; `0x34a538 call [rbx+0x28]` = queue getPoint(&off,&val).
- `0x34a549 call [rax+0x18]` = apply the param (reaches the flanger thunk -> writes the coefficient).
(The FIRST section 0x34a3d5.. reads ProcessData.inputEvents at +0x38 = MIDI notes.)

ProcessData offsets the wrapper checks: +0x08 numSamples (>=1), +0x10 numOutputs
(>=1), +0x20 outputs* (each AudioBusBuffers, [bus]=numChannels>=2, stride 0x18),
+0x28 inputParameterChanges, +0x38 inputEvents.

## Progress (executed 2026-07-23) — BOTH components construct cleanly
The piece this roadmap flagged as "the hard, uncertain piece" is DONE for both
components (proc_create.py / ctrl_create.py, PROVEN under Unicorn, 0 faults, no
unhandled imports):
- **Processor** `CVstProcessor::createInstance` = `IB+0x349CA0` → object with
  IComponent iface vtable **rva 0x967b68** (runtime; the static 0x967A08 is the
  class vtable). Slots: setState=12 (0x34a904), setActive=11, activateBus=10,
  getRoutingInfo=9 (0x34a380 — NB this is getRoutingInfo, NOT process(); process
  lives on the IAudioProcessor sub-object, reached via queryInterface).
- **Controller** `CVstEditController::createInstance` = `IB+0x3473D0` → IEditController
  iface vtable **rva 0x967468**. Slots: setComponentState=5 (0x347f20),
  setState=6, getState=7, getParameterCount=8, getParameterInfo=9,
  getParamNormalized=14, setParamNormalized=15 (0x3486f0), setComponentHandler=16.
- **Consequence for #124/preset-load:** the processor's IComponent::setState is a
  bare-ret no-op (bridge_vecC), so the engine does NOT get presets via setState.
  The engine must receive them as PARAM CHANGES the controller emits on load
  (setComponentState → the controller's param cache → param changes → the
  processor's param-apply). Our recall enumerator fires only a subset of those
  params; the COMPLEMENT (controller-path-only params) is exactly where the ~12%
  bounce residual lives (bounce_relocate.py, 2026-07-23). So the setState oracle
  and #124 are the SAME investigation: enumerate the controller's full param set
  on preset-load and apply it via the processor, then diff engine state vs recall.

## Build spec (the remaining work = task #112)
1. Construct the VST3 components — DONE (above). Remaining: wire IHostApplication /
   a minimal component-handler so setComponentState + the controller→processor param
   relay run (the controller populates a param cache; bridging it to the processor's
   engine is the next milestone).
2. Fabricate 3 COM objects in Unicorn memory (vtables -> small x86 stubs, like
   e2e_emu.build_voice_stub): IParamValueQueue (getParameterId->flangerID,
   getPointCount->1, getPoint->(0,normValue)); IParameterChanges
   (getParameterCount->1, getParameterData->queue); ProcessData (fields above).
   Need the flanger param's VST3 ID (from param DB rva 0x5EC040 / resolved tables).
3. Drive `0x34A380(rcx=processor-this, rdx=ProcessData)`, hooking a STOP at 0x3C7400
   (or the pool loop 0x3c8120) so it halts AFTER param-apply, BEFORE the pool.
4. Hook the flanger thunk + engine writes; read the coefficient cell; sweep the
   normalized value 0..1 to derive the byte->cell law. Then wire into effect_modes.c
   / a flanger applier + a synthetic gate (like etmode_ab). Repeat for Patch Tempo.
5. Pillar-2 (SEAL #3): the same wrapper drive with a full mode-4 patch's param set
   proves load order/interactions. #124 (SEAL #7): the host-lifecycle note+param
   path (this wrapper) is where CLAUDE.md pins the darkness residual.

## FLANGER derivation UNBLOCKED (executed 2026-07-23)
The flanger param laws (leaves 1242-1248, EFFECT TYPE 4) are now derivable WITHOUT
the threaded process() pool — via the plugin's own effect machine code:
- The flanger sub-object `sCDSPSystem8DlyFlSt` (effect+7616, vtable rva 0x9c17c0) is
  constructed for all 9 units during `build()` (FlSt ctor 0x35EAD0). Mode field is
  effect+1480.
- Activate flanger: call the plugin's OWN effect-type setter `sub_7FF91E0193E0`
  (0x3B93E0) with (effect, 0, mode=4). It sets [+1480]=4 AND runs the activation
  `sub_7FF91E018180` — 0 faults, FlSt vtable valid after (scratchpad/flanger_vtbl.py).
- Apply a param: call the FlSt setter directly (vtable method). The VALUE is the 3rd
  arg a3 (a2 is a flag). e.g. MANUAL = vtable+0xB8 (0x35F690): stores a3 at FlSt+72
  and computes 2 float coefficients (scratchpad/flanger_derive4.py, a3=0→200 gave
  0.026→0.0019 and 0.5→0.036 at per-instance cells). RESONANCE=+0x78 (0x35EE60),
  LOW CUT=+0x68 (0x35F320); each also registers a slot in the coeff table via
  sub_7FF91DFB6380(&tbl, slot, val) (MANUAL slot 19 val 255-a3; RESON slot 22 val a3;
  LOWCUT slot 65 val a3).
- VALIDATED (scratchpad/flanger_validate.py): FLANGER MANUAL's coefficient at
  eff+137560 is a CLEAN strictly-monotonic law of a3 (a3=0 -> 0.026042 decreasing
  smoothly to a3=255 -> 0), confirming the derivation produces real coefficients,
  not garbage from a half-ready object. eff = master effect obj = proc[8]; the coeff
  lands at eff+137560 / eff+137572 (two cells) + the raw a3 at FlSt+72.
- REMAINING for a full flanger closure: sweep a3 0..255 x 4 rates for each of the 7
  leaves; MAP eff+137560-relative offsets to the port's master-render cell numbering
  (the hard part: oracle proc[8] effect-object offset -> port single-block master
  offset); confirm the port's master_render.c actually READS those cells for
  EFFECT TYPE 4 (it routes on JUNO_PROG_EFX but has no flanger-specific DSP today, so
  this likely ALSO needs the flanger render ported — a much larger task than the
  param law); then wire an applier + synthetic gate. Zero factory benefit (no factory
  patch is EFFECT TYPE 4), so this is pure SEAL-1 ledger completion, and its true cost
  is the flanger DSP port, not the (now-solved) param derivation.

## Honest status
This is genuinely research-grade. The construction blocker prior attempts (#69-72/
#112) hit is now PAST: both VST3 components construct cleanly under Unicorn
(2026-07-23). What remains is the HOST BRIDGE — a minimal IHostApplication +
component-handler so the controller's preset-load param set reaches the processor's
engine (and, for the flanger, so the mode-4 effect object gets constructed). That
bridge is the next milestone and is where the setState oracle (SEAL #3-primary), the
8 controller-path GAPs (SEAL #1), and the #124 residual (SEAL #7) all converge.
Every EARLIER piece — the entire engine-dispatchable coefficient surface — is proven
bit-exact and sealed (make verify green, incl. the differential-fuzz Pillar-2
fallback). This roadmap is what remains between "engine port complete" and "all 7
SEAL conditions green".
