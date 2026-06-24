# Parameter → coefficient APPLY path (JUNO-60 VST3)

How a parameter VALUE (host-normalized 0..1, or a preset's stored step) becomes the
DSP COEFFICIENT written into an engine-state slot. This is the layer between
`docs/PARAM_MAP.tsv` (id→offset) and `src/runtime_coeffs_data.c` (the captured
post-apply coefficients). RVAs are IDA-style (image base `0x180000000`; runtime base
`0x7FF91DC60000` is the same offset). Decompile in `allcode/decomp_*.c`, asm in
`allcode/asm_*.asm`.

## TL;DR verdict  — CORRECTED BY LEAD (the "wall" below was an address error)

> **IMPORTANT CORRECTION (verified):** the original draft of this doc concluded the
> transform *data* was "missing / below the dumped `.rdata` (0x935650)" and that a
> bit-exact port was therefore blocked. **That was wrong.** It came from treating the
> low digits of a *runtime* address as an RVA. The data symbols are named by runtime
> address (e.g. `dword_7FF91E7450B4`); the RVA is `runtime − 0x7FF91DC60000`. So:
> - the denormalize LUTs at runtime `0x7FF91E5C97D0` → **rva `0x9697D0`** (NOT `0x5C97D0`)
> - the scale/offset consts at runtime `0x7FF91E7450B4` → **rva `0xAE50B4`** (NOT `0x745xxx`)
>
> Both are **inside the dumped `.rdata`** (0x935650..0xC43000) and were read back
> successfully (LUT floats `-0.3255,-0.3205,…`; consts `1.0, 89128.96, 1.035, 1.1…`).
> The RangeParameter min/max are **constructor args** (`sub_1803D50E0`: min→+824, max→+832)
> in the decompiled controller param-list build, and the param→class/curve assignment is
> likewise in that decompiled construction code. **Nothing is missing.**

- **The host VST3 boundary does NOT transform the value.** Both `setParamNormalized`
  and `process()` keep the value normalized; the raw float setters are never reached
  directly from the boundary.
- **Denormalization is deferred into the engine apply path**, and it is **non-identity**
  (three mechanisms, below). Both the transform *code* and *data* are present.
- **Bit-exact port from the decompile alone: YES — it's a (large) transcription job,
  not a data wall.** Required pieces, all in hand: (1) the apply logic (decompiled +
  asm-confirmed for the hidden xmm arg); (2) the denormalize LUTs (rva 0x9697D0,
  dumped); (3) the scale/offset consts (rva 0xAE50B4, dumped); (4) per-param
  min/max/stepCount/curve-class from the decompiled controller param-list build. The
  capture `src/runtime_coeffs_data.c` remains a convenient oracle to validate against.

## 1. Apply entry points and call path

### Host → normalized value (NO transform at the boundary)

| stage | rva | behaviour |
|---|---|---|
| `IEditController::setParamNormalized` | controller `CVstEditController` (rtti `sub_347670`) | SDK path → `Parameter::setNormalized` |
| `Parameter::setNormalized` | **0x3D6FA0** | `v = clamp(value,0,1); param[+808] = v;` stores **normalized**, notifies. **Dead-ends in the controller — does not touch engine slots.** |
| `IAudioProcessor::process` | **0x34A380** | param-change loop (decomp_340000.c:7944-7975) |
| getPoint consume | `sub_34A380` line 7973 | `getPoint(... &v55)` (normalized double) → `sub_31F2C0(engine+56, paramID, v55, sampleOffset)` **verbatim, no transform** |
| enqueue | **0x31F2C0** | pushes a 24-byte event into a mutex-guarded queue at `engine+440` |

**24-byte param-change event layout** (from `sub_31F2C0`):
`+0` dword = type (`1` = param-change); `+4` = sampleOffset; `+8` = paramID;
`+16` (low dword) = **the normalized value as float bits**. (Note-on `0x90`/note-off
`0x80` MIDI events share the same 24-byte slot, distinguished by `+0`/`+8`.)

### Queue drain → engine apply (transform happens HERE)

| stage | rva | behaviour |
|---|---|---|
| drain + sort | **0x320B20** (`sub_320B20`) | locks mutex, swaps queues, sorts events by sample offset, splits MIDI vs param-change (LABEL_28 = param-change). Dispatches per-block **via the Parameter object's vtable** (no static C callee). |
| denormalize (host family) | **0x3D70D0** `RangeParameter::toPlain` | see §3 |
| denormalize (preset/engine family) | **0x356380** `sub_356380(engine,tableId,step)` | per-param float LUT, see §3 |
| per-param apply | **0x356150 / 0x3561A0** (and the `sub_3B6xxx`/`sub_3B9xxx` cluster) | `value*scale[idx] + offset` → raw store, see §3 |
| **raw store** | **0x3C1090** (`sub_3C1090`), twin **0x3C10F0** | `**(float**)(*(*(engine)+56) + 40*idx + 32) = a4;` — identity store of the already-transformed float into the descriptor slot. |

The vtable dispatch in the drain (`sub_320B20` → Parameter vtable) is the one
statically-unresolvable hop: `toPlain` (0x3D70D0) and the apply-virtuals have **no C
callers** (reached only through vtables), so the exact wiring "which paramID → which
apply-virtual → which tableId/scale" cannot be read inline. It is recoverable by
resolving the per-parameter object vtables, but that is asm/RTTI work, not in the
decompile as a flat call graph.

### Preset / bank load path (parallel entry; same engine apply)

| stage | rva | behaviour |
|---|---|---|
| format detect | **0x33CF30** | extension dispatch: `.s8p`→0x33C330, `.PRM`/`PLUGOUT_PATCH`→0x33BD30, etc. No scaling. |
| deserialize / bank walk | **0x33C330** | matches tokens, builds a bitset of patch slots, calls per-record reader. |
| per-record field reader | **0x33BFC0** | reads int `v34` from stream, forms a step `v33` per field opcode `*a3`, calls the param object's **vtable+120 setter with the INTEGER step**. |
| +120 setter family | **0x358640, 0x3586C0, …** | store raw step at `obj+0x24/0x28`, call `sub_356380` (LUT) to get the float, push to slot via 0x3C10D0/0x3C1090. |
| SysEx `.PRM` byte transcode | **0x351710** | JUNO-60 hardware SysEx ↔ internal byte-buffer (nibble packing); operates in the 0-255 byte domain, embeds the closed-form transfer curves (decoded in `refs/param_curves.json`). Not the float-slot path. |

## 2. The descriptor (40-byte) and where range info lives

`sub_388170` (asm-only, Hex-Rays None; asm at `asm_380000.asm:6153`) registers the
~1121 engine descriptors. Verified by disassembly: it push_backs `{name, type-flag, &slot}`
and contains **only 6 `movss`** in its entire 12k-line body — i.e. it carries **NO
per-parameter min/max/curve floats**.

**40-byte engine descriptor** (vector at `engine+0x38`, stride 40):

| off | field |
|----|----|
| +0  | parameter-name string ptr |
| +12 | type/enabled flag dword (`==1` = active numeric slot) |
| +16..31 | 16-byte block (shared flag const `xmmword_18098C030 = {1,0,0,0}` for most) |
| +20 | env/voice index |
| +32 | **pointer to the coefficient slot** = `&engine_state[offset]` |

So **param-ID → state offset** is the `lea`-target sequence in `sub_388170` (already
parsed → `docs/PARAM_MAP.tsv` / `docs/COEFF_PARAM_MAP.md`). The **range/curve info is
NOT in this descriptor**.

Range/curve data lives in three other places, none in the dumps:
- **RangeParameter objects** (controller side): `min @ +824`, `max @ +832`,
  `stepCount @ +788/+197` — constructor args, set in the EditController parameter-list
  build (separate from `sub_388170`).
- **Engine apply scale arrays**: per-object `+0x2C` float arrays + the constant
  `dword_7FF91E7450B4`, read by `sub_356150`/`sub_3561A0`.
- **Denormalize LUTs**: `dword_7FF91E5C97D0 … 0x5CE6E0`, read by `sub_356380`.
- (`unk_7FF91E5EC040`, 4966×16-byte int min/max/default/flag via `sub_3ABAF0`, is
  **host-registration + display only**, NOT the audio apply.)

## 3. Transform types and formulas

1. **Identity store** — `sub_3C1090`: `slot = float`. The final write; all transforms
   above produce its input.

2. **RangeParameter::toPlain** (`sub_3D70D0`, host-automation family):
   - `stepCount ≤ 1` (continuous): `plain = min + (max − min)·norm`
   - `stepCount > 1` (discrete): `plain = min + min( floor((stepCount+1)·norm), stepCount )`
   - Base `Parameter::toPlain` (`sub_3D70C0`) and `sub_3D7000` = **identity** (`return a2`).
   - Inverse `toNormalized` = `sub_3D7010`: `(value − min)/(max − min)`.

3. **Per-param scale+offset apply** (`sub_356150`, verified in asm `asm_340000.asm:22509-22512`):
   `slot = value · scale[idx] + offset` where `idx = obj[+0x28]`, `scale[] @ obj[+0x2C]`,
   `offset = dword_7FF91E7450B4`. Stepped variant `sub_3561A0`:
   `slot = scale[clamp(idx,0,255)] · storedValue`. (Hex-Rays drops the implicit xmm
   float arg to `sub_3C1090`, so this is only visible in asm.)

4. **Per-param denormalize LUT** (`sub_356380`, preset/engine-unit family):
   `slot = TABLE[tableId][clamp(step, 0, N_tableId)]`. 66 cases (tableId 0..65);
   time-domain params pick `tableId` by **samplerate** (e.g. `sub_356E30`:
   44100→39, 48000→40, 96000→41 — so coefficients are samplerate-specific; the oracle
   is 96 kHz). 27 contiguous float tables, rva `0x5C97D0..0x5CE6E0` (20240 bytes),
   inventoried in `refs/param_curves.json`.

5. **MIDI-CC denorm** (`sub_353E80`): fixed-point `(const·cc) >> 32 >> 6 / 2`; the
   process() CC branch also does `value = cc·255/127`-style via `sub_52050`.

6. **Switch/boolean**: stored as exactly `0.0` or `1.0` (the type-flag default-1.0
   params).

### Decoded closed-form curves (from SysEx transcoder `sub_351710`, no external data)

These are recoverable entirely from code (saved in `refs/param_curves.json`). They
map the JUNO hardware 0-255 byte to a value; they are the SysEx/display domain, useful
as reference and bounds but **not** identical to the engine slot coefficients:

- **ENV time** (case 30/32): `n≤128 → n/256`; `n>128 →
  ((0.00058500306 − n·9.5199505e-7)·n − 0.099640459)·n + 5.6657672`.
- **dB level** (case 70): `j==128 → 1.0`; else `(10^(j/255) − 1)/9 · 4.1349`.
- **LFO ms** (case 104): `((10^(v/255) − 1)/9)·790 + 10`.

## 4. Voice propagation

The apply writes the coefficient **once, to the base slot (voice 0)** — confirmed
empirically: in `src/runtime_coeffs_data.c` every coefficient is at a voice-0 base
offset; none is replicated at `base + v·10512`. The DSP reads/broadcasts per-voice from
that base (voice_render indexes `base + v·10512` but the control coefficients are shared).
The factory-default writer `sub_3A66B0` likewise writes each descriptor's single slot
(`descriptor[k].slot`, 5-qword stride, slot at index 4) — raw float constants
(`0x3F800000`=1.0 or 0), no per-voice fan-out.

The large oracle offsets (`4297584`, `6395312`, `10692016`, …) are **separate engine
instances** (dual/stereo/chorus-layer engine objects), each a near-copy of the param
block — not voices. Apply is therefore per-engine-instance, written to the base slot.

## 5. Transcribability assessment (blunt)

| component | rva | from decompile? | verdict |
|---|---|---|---|
| raw store | 0x3C1090 | yes | **tractable** (5 lines, already in `juno_runtime_coeffs_apply`) |
| host boundary identity | 0x34A380, 0x31F2C0, 0x3D6FA0 | yes | **tractable** — confirms value is normalized, untransformed |
| event queue + drain/sort | 0x320B20, 0x31F2C0 | mostly | **tractable** structurally; the per-param dispatch is **vtable-resolved** (needs RTTI) |
| RangeParameter::toPlain | 0x3D70D0 | yes | **tractable** formula; needs min/max/stepCount **data** |
| scale+offset apply | 0x356150/0x3561A0 | asm-only (Hex-Rays drops xmm arg) | **tractable from asm**; needs scale[] + offset **data** |
| denormalize LUT fn | 0x356380 | yes | **tractable** (table lookup); needs table **data** |
| param→offset map | 0x388170 | asm-only | **already extracted** → PARAM_MAP.tsv |
| param→tableId / param→scale wiring | per-param vtables | asm/RTTI | **needs-asm** (which apply-virtual each param uses) |

### Data blobs — ALL PRESENT (corrected; addresses were misread as RVAs)

The addresses below were originally written as RVAs but are **runtime** addresses;
the true RVA is `runtime − 0x7FF91DC60000`. All land in the dumped `.rdata`
(`0x935650..0xC43000`) and have been read back:

1. **Denormalize LUTs** runtime `0x7FF91E5C97D0..0x7FF91E5CE6E0` → **rva `0x9697D0..0x96E6E0`**
   (20240 bytes float[]), used by `sub_356380`. ✓ present (`-0.3255,-0.3205,…`).
2. **Scale/offset constants** runtime `0x7FF91E7450B4` → **rva `0xAE50B4`** + per-object
   `+0x2C` scale arrays, used by `sub_356150`. ✓ present (`1.0, 89128.96, 1.035, 1.1…`).
3. **RangeParameter min/max/stepCount** — constructor args to `sub_1803D50E0`
   (min→a1+824, max→a1+832), supplied by the **decompiled** controller param-list build.
   ✓ recoverable from code (read the construction call sites for the ~1121 params).
4. (SysEx field schema / `.PRM`-import LUTs — lower priority; same correction applies.)

No data is missing. This is a transcription job over decompiled code + dumped `.rdata`.

### Concrete transcription plan (order)

1. **Port the raw store + param→offset map** (done): `juno_runtime_coeffs_apply` +
   PARAM_MAP. This is the verified, bit-exact sink.
2. **Dump the data blobs from the dumped `.rdata`** (already in `data_sections/`): the
   LUTs at rva `0x9697D0..0x96E6E0`, the consts at rva `0xAE50B4`, → `refs/param_curves.json`.
   No new binary extraction needed.
3. **Transcribe `sub_356380`** (66-case LUT lookup) + the samplerate dispatch
   (`sub_356E30` rule) — trivial with the tables in hand.
4. **Transcribe `sub_3D70D0` toPlain** + `sub_356150` scale+offset (from asm) for the
   host-automation family.
5. **Extract the per-param wiring from the decompiled controller param-list build**
   (paramID → class/curve → tableId/scale, + min/max/stepCount): read the ~1121
   `sub_1803D50E0`/sibling construction call sites. Large but mechanical; this is what
   enables a *general* "load arbitrary preset" path. (The runtime drain dispatches via
   vtable, but the *assignment* is static in the construction code — recoverable.)

**Blocker summary:** the apply *algorithm* is fully understood and portable; what blocks
bit-exact arbitrary-preset loading is (a) ~20 KB + a few KB of float **data** not in the
dumps, and (b) the **param→curve assignment table** hidden behind per-parameter vtables.

## 6. Ten-parameter validation spot-check (against `src/runtime_coeffs_data.c`, PD Juno Pad, 96 kHz)

Every captured value is consistent with the inferred transform *form* for its type:

| off | name | type | captured | consistent? |
|---|---|---|---|---|
| 1872 | LFO Trig | switch | 1.000000 | exact 1.0 ✓ (boolean) |
| 1888 | Reset Sw | switch | 1.000000 | exact 1.0 ✓ |
| 2848 | Q24C Initialize | switch | 1.000000 | exact 1.0 ✓ |
| 9824 | Mute (amp enable) | switch | 1.000000 | exact 1.0 ✓ |
| 1088 | LFO Rate | rate-LUT (SR) | 0.364706 | in LUT range ✓ |
| 2784 | ENV1 Attack | time-LUT (SR) | 0.002971 | tiny per-sample rate ✓ (DSP further ×1/256) |
| 2832 | ENV1 Release | time-LUT (SR) | 0.003337 | tiny per-sample rate ✓ |
| 2800 | ENV1 Sustain | level-LUT | 0.694629 | in 0..1 ✓ |
| 6736 | LPF Cutoff | cutoff-LUT | 0.415686 | in 0..1 ✓ |
| 6864 | Velocity | level-LUT | 0.842520 | in 0..1 ✓ |

Notes: switch slots read **exactly** `0x3F800000` (1.0) — matches the boolean/type-flag
apply. ENV times read as small per-sample increments (the DSP applies an additional
`×0.00390625` in `voice_render.c:970`), consistent with a samplerate-specific time LUT
at 96 kHz and explaining why they fall below the SysEx ENV-time curve's minimum step —
the slot coefficient is a *rate*, not the SysEx display value. Levels/cutoff land in
`[0,1]`. No captured value contradicts its inferred transform type. (A strict
`min ≤ value ≤ max` check is not possible without the RangeParameter min/max data,
which is missing per §5.)
