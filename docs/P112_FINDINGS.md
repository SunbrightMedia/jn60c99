# #112 — VST3 host-lifecycle oracle: EXECUTED FINDINGS (2026-07-24)

Supersedes the mapping section of `docs/P112_ROADMAP.md`. Everything below labelled
**PROVEN** was obtained by executing the plugin's own machine code under Unicorn in
this session; **READ** means static decompile only. No capture was used anywhere.

Investigation scripts (scratchpad, one-shot): `p112_probe{1,2,3}.py`,
`p112_lifecycle{,2}.py`, `p112_initdiag{,2}.py`, `p112_flag_ab{,2}.py`,
`p112_flagsweep.py`, `p112_flagvalue{,2}.py`, `p112_sanity.py`,
`p112_firstcall.py`, `p112_endpoint.py`, `p112_modlaw.py`, `p112_maptree.py`,
`dc.py` (decompile lookup by rva).
Standing gates (in `make verify`): `tools/verify/hostpath_roles.py`,
`tools/verify/hostmod_gate.py`. Ported code: `src/juno_mod.{c,h}` +
`juno_gui_mod_*` / `juno_gui_set_mod` in `gui/juno_bridge.c`.

**Address convention note:** IDA names globals `qword_<VA>`, so a name like
`qword_7FF91E910E18` is VA 0x7FF91E910E18 = **rva 0xCB0E18**, not 0x910E18. Two
separate dead ends in this session came from reading the name's tail as an rva
(the paramID map and the param descriptor table, whose real rva is 0x98C040).

---

## 1. The roadmap's VST3 vtable map was MISALIGNED — corrected (PROVEN)

`proc_create.py` dumped 14 slots from the pointer `createInstance` returns and
labelled them with **IComponent** names. That pointer's vtable is **IAudioProcessor**
(11 slots), so slots 11+ of the dump had already run past the end of the vtable into
the RTTI complete-object-locator and the *next* vtable. Every conclusion drawn from
slots ≥ 11 was therefore wrong.

Resolved at runtime with the object's OWN `queryInterface` (`p112_probe3.py`):

| interface | sub-object | vtable rva |
|---|---|---|
| FUnknown | class+0 | 0x967a08 |
| IPluginBase | class+16 | 0x967a88 |
| **IComponent** | class+48 | **0x967af0** |
| **IAudioProcessor** | class+272 | **0x967b68** |

`createInstance` (`IB+0x349CA0`) returns the **IAudioProcessor** pointer, so the
class base is `p - 272`.

**IAudioProcessor** (0x967b68): setupProcessing=7 (0x3cb150), setProcessing=8
(0x3cb140), **process=9 (0x34a380)**, getTailSamples=10 (0x34a030).

**IComponent** (0x967af0): initialize=3 (0x34a110), terminate=4 (0x34acb8),
activateBus=10 (0x3cba80), setActive=11 (0x34aa50), **setState=12 (0x34aaa0)**,
getState=13 (0x349ea0).

### Consequence: the roadmap's headline claim is RETRACTED
> "the processor's IComponent::setState is a bare-ret no-op (bridge_vecC), so the
> engine does NOT get presets via setState."

That read slot 12 of the **IAudioProcessor** vtable — which is not setState at all,
it is `0x34a904`, a `queryInterface` thunk (`return QI(this-280, …)`). The real
`IComponent::setState` is **0x34aaa0** and it is a full implementation: it seeks the
IBStream to the end for the size, seeks back, reads a big-endian int32 length prefix
plus payload, and hands the payload to the wrapper queue's own deserializer
(`queue vtable +48`). `getState` (0x349ea0) is its exact inverse and serialises via
`0x31FD90`. So the setState path exists; the "presets can only arrive as controller
param changes" inference built on top of it does not hold.

The controller vtable in the roadmap (0x967468) *was* correct — IEditController has
18 slots and the dump's slots 18/19 were the same RTTI-overrun artefact.

## 2. `process()` is single-threaded up to and including the param/MIDI apply (PROVEN)

`IAudioProcessor::process` = **0x34A380**. Contrary to the roadmap's "process() spins
in the thread pool", the whole parameter and event intake runs on the calling thread,
and `0x34A380` never calls `0x3C7400` at all. Its structure:

* `ProcessData` offsets checked: +8 numSamples ≥ 1, +16 numOutputs ≥ 1, +32 outputs
  (AudioBusBuffers, stride 24, numChannels ≥ 2), +40 inputParameterChanges,
  +56 inputEvents, +72 processContext.
* **Events** (+56): `getEventCount` (vt+24), `getEvent` (vt+32). Event layout is the
  stock VST3 one with the union at offset 24 (8-aligned because of `DataEvent`):
  type at +18, NoteOn {channel+24, pitch+26, tuning+28, velocity+32},
  NoteOff {channel+24, pitch+26, velocity+28}. Converted to a 3-byte MIDI message
  (`status = channel | 0x90/0x80`, `data2 = (int)(velF*127.0) & 0x7F`) and pushed by
  **0x31F4E0** — the same function CLAUDE.md already documents for the Kbd-Velocity
  policy.
* **Params** (+40): `getParameterCount` (vt+24), `getParameterData` (vt+32); per queue
  `getPointCount` (vt+32) and `getPoint(last, &offset, &value)` (vt+40), then
  `getParameterId` (vt+24). IDs below `[proc+104]` go to **0x31F2C0** (push a 24-byte
  {kind=1, sampleOffset, paramID@+12, f32 value@+16} record under the mutex at
  queue+280 into the vector at queue+440); IDs at or above it are re-encoded as MIDI
  CC/pitch-bend/aftertouch.
* Finally it calls the **queue consumer 0x320B20** directly, with
  `(queue, 0, 0, outPtrs, 2*numOutputBuses, numSamples, &transport)`.

`0x320B20` swaps the pending record vector under the mutex, sorts it, then walks the
records, splitting the block at each event's sample offset and calling the engine's
own vtable: **+48** render sub-block, **+112 param apply**, **+120 noteOff**,
**+128 noteOn**, +136 CC, +144 program, +152 bend, +160/+168 aftertouch, +176 tempo,
+184 beat, +200/+208/+240 transport, +248 setup(sampleRate, blockSize).

The thread pool the roadmap hit lives *below* this, inside the DSP render — which
`e2e_emu.render()` already replaces with direct VOICE_WRAP/MASTER_WRAP calls. **The
param/MIDI half of the host lifecycle never needed the pool.**

## 3. The host param entry, and what the "flag" actually is (PROVEN)

Engine vtable **+112 = 0x3C7AE0** is where a host's `IParameterChanges` land:

```
if (paramID == 268419086) { engine[56] = value; signal worker; }   // unit-count control
else {
  idx = std::map<paramID,int> @ qword_7FF91E910E18 (rva 0xCB0E18) . at(paramID)
  for u in 0..8:
     v = value
     if (idx==20 || idx==665 || idx==707) v -= 100
     if (idx==22)  v -= 12
     if (idx==769) v -= 11
     if (idx==871) v  = (v != 0)
     if (idx==756) sub_7FF91E024ED0(unit[u], value)
     if (idx in 831..835) { dedicated setter; NO dispatch }
     if (v within paramDB[idx] = {min,max} @ rva 0x98C040 + 16*idx)
        proc[u]->vt[11](proc[u], idx, /*flag*/ 0, v)      // == 0x3B9A30
        assign[u]->vt[1](assign[u], 4)
}
```

The plugin's own recall enumerator `0x3B48A0(proc, a2)` — the function
`plugin_recall_set.py` already drives — dispatches the very same `0x3B9A30` but with
**flag = 1** (its `a2 == 0` branch instead uses proc vt+80 = 0x3BB800).

`0x3B9A30(proc, idx, flag, value)` forwards `(flag, value)` to the leaf setter as
that setter's own `(a2, a3)` and caches the value. **The flag is therefore not a
ramp/immediate switch — it selects a ROLE inside each leaf setter.**

**The port drives `flag = 1`, i.e. exactly the plugin's own recall role.** Confirmed
again here; nothing in the recall path changes.

## 4. NEW: the plugin has a live MODULATION layer the port did not model (PROVEN)

Dispatch indices **312–317** are no-ops in the recall role and, in the host role,
apply a signed percentage offset on top of the *recalled base value* of a front-panel
parameter, then re-drive that parameter's own setter:

| mod idx | drives | base idx | base cache |
|---|---|---|---|
| 312 | VCF CUTOFF FREQ | 779 | — |
| 313 | HPF CUTOFF FREQ | 782 | proc[320] |
| 314 | VCF RESONANCE | 781 | proc[319] |
| 315 | DCO PWM DEPTH | 758 | proc[311] |
| 316 | PORTAMENTO | 798 | proc[336] |
| 317 | EFFECT DEPTH | 794 | proc[332] |

Law (`sub_7FF91E010600` and siblings), with `paramDB[312..317] = {-100, 100}` read from
the descriptor table:

```
out_byte = base + (off * (off > 0 ? 255 - base : base)) / 100      /* trunc toward 0 */
```

then the base parameter's own setter is invoked with `out_byte`. At `off == 0` the law
is the identity, which is why every existing recall/render gate stayed green: no
factory patch and no default host state drives these.

**Ported and PROVEN.** `src/juno_mod.c` (`juno_mod_byte`) implements the law;
`tools/verify/hostmod_gate.py` proves it by *observing the byte the plugin itself
passes to the base setter* — it hooks each base parameter's own setter (address
resolved from the proc vtable) while driving the plugin's modulation setter, and
reads the third argument. Nothing is inverted or fitted.

* one-time EXHAUSTIVE run: **308 736 comparisons** — 6 slots x every base byte
  0..255 x every offset -100..100 — **0 mismatch**. Reproduce with
  `python3 tools/verify/hostmod_gate.py --ref --full && python3 tools/verify/hostmod_gate.py --port`
  (~45 min for the reference; `make verify` uses the grid below instead so the
  standing gate stays affordable);
* the standing `make verify` grid (52 bases x 43 offsets, including both range
  endpoints and ±1): 13 416 comparisons, 0 mismatch.

Bridge API: `juno_gui_mod_count/_name/_param_index` and
`juno_gui_set_mod(ctx, slot, base_byte, off)`. **Scope, stated plainly:** the law is
proven for all six slots but only five are wired end to end — slot 5 (EFFECT DEPTH)
has no row in `juno_apply.c`'s BINDINGS table (it is an FX leaf applied by the
chorus/effect recall path), so `juno_gui_mod_param_index(5)` returns -1 and
`juno_gui_set_mod` on it returns 0 without touching the engine. It is not
approximated; routing it needs an FX-leaf live applier.

## 5. The 8 DEFERRED-CONTROLLER rows survive the host path too (PROVEN)

`p112_flag_ab2.py`: dispatching EFFECT TYPE (873) = 4 under **either** role leaves
every one of the 9 effect objects' mode field `[eff+1480]` at 0, and the plugin's own
effect-type setter `0x3B93E0` is **never called** by the dispatch (0 hits). The 7
FLANGER leaves 1242–1248 write 0 cells under both roles. So the `DEFERRED-CONTROLLER`
classification is not an artefact of the recall role — it holds for the host role as
well, and the seal's honest-residual accounting is unchanged. (Closing them still
additionally requires the flanger DSP render the port does not have; see the cost
analysis in `P112_ROADMAP.md`, which remains valid.)

## 6. The paramID→index map is not built by any reachable entry point (PROVEN)

`p112_maptree.py` reads the container at rva 0xCB0E18 after `build()`, after
`CVstProcessor::createInstance`, and after `CVstEditController::createInstance`: it is
**NULL at every stage**. The map is populated elsewhere in the full DLL/controller
initialisation, which still faults under emulation (§7). This is why the host path is
driven in this work by *internal dispatch index* — which is what `0x3C7AE0` resolves
the paramID to anyway, so nothing about the engine-side result depends on it.

## 7. Remaining lifecycle blocker (honest status)

`IComponent::initialize` (0x34a110 → 0x34a040) reaches the engine factory
`sub_7FF91DFAD460`, whose construction chain hits a CRT
`_invalid_parameter_noinfo_noreturn` inside a magic-static string parse
(`0x3E49B0 → 0x3E4930 → 0x3E1330 → 0x3E16A0`) — a TEB/TLS artefact of emulation.
Neutralising that CRT abort (a plumbing stub of the same class as the existing
HeapAlloc/TlsGetValue stubs) lets it continue but it then faults at rva 0x284c04.
**The wrapper's engine is therefore not constructed under emulation today.**

This does not block the findings above, because the wrapper's entire contribution to
engine state is the enumerated set of engine-vtable calls in §2, every one of which is
the plugin's own code and is callable directly on the engine `e2e_emu` already builds.

## 8. Harness lessons — four traps, each of which faked a divergence

Getting an honest role comparison took four corrections. Every one of them first
presented as a large, plausible-looking set of "real" divergences. Any future
differential over this engine must do all four.

1. **Restore everything mutable, not just the state blocks.** The first run reported
   ~46/165 divergent indices. The snapshot covered only the two 12 MB unit state
   blocks, leaving the per-unit `proc`/`assign` objects — which hold the value caches
   the leaf setters read — dirty between probes. The symptom was a one-probe lag:
   each "recall" value equalled the *previous* iteration's "host" value.
2. **Write the descriptor, don't just pass the value.** The leaf setters read their
   input from `DB[idx].value` (rva 0x98c048 + 16*idx), not from the dispatch
   argument. A dispatch without a descriptor write applies whatever the descriptor
   already held — which is why a first dispatch from a cold engine appeared to be a
   no-op. `recall_render_ab.prepare_recall` has always done `wr_desc` then dispatch;
   the differential must too.
3. **Only probe inside the index's own paramDB range.** The host entry 0x3C7AE0
   range-checks `{min,max}` before dispatching, so no host can deliver an
   out-of-range value. Feeding raw 0..255 to a bipolar index made the host role
   decode 128..255 as negative and manufactured 17 "differences" (e.g. idx 753
   DCO LFO MOD at 128) that no host could produce.
4. **Baseline on a RECALLED patch, not a pristine engine.** This one is subtle and
   was the last to fall: after fixing 1–3, seventeen indices still differed at
   exactly one value each, and they reproduced in isolation, so they were not
   ordering noise. They are a *cold-engine* effect — several leaf setters behave
   differently on their very first dispatch after power-on, so a cold probe compares
   "recall's first touch" against "host's first touch" rather than comparing the two
   roles. A real host never does that: it loads the preset (full recall) and *then*
   sends parameter changes. `hostpath_roles.py` therefore takes its baseline
   snapshot after `recall_patch`, which is the only state a host parameter change
   ever arrives in.

Note also that the intermediate results looked *interesting* each time — plausible
per-parameter laws, tidy patterns like "exactly 2x", "only at the range endpoint",
and finally "each parameter differs at exactly its own power-on default byte" (which
is what trap 4 turned out to be). None survived a stricter protocol.

**Consequence for what the gate freezes.** After all four fixes, the bit-level
comparison of the two roles' settled values on the indices they *share* was still not
stable enough to freeze honestly: priming removes the default-byte class but exposes
a further dispatch-lag class. `hostpath_roles.py` therefore does **not** assert
value equality. It asserts the property that is robust and that answers the question
#112 exists to answer — **reachability**: the set of the plugin's own recall indices
for which the RECALL role writes no engine state at any in-range value while the HOST
role does. That is a property of the code path rather than of the state it started
from, it is stable under every protocol variant tried, and it is exactly how the
modulation family was found. Measured and frozen: **exactly {312,313,314,315,316,317}
out of 165, nothing else.** The value-level comparison is left as documented open
work, with this section as the warning label.
