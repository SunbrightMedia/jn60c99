# Velocity coefficients 6864 / 9680 — binary-derived resolution

Ground truth: the VST3 binary executed under Unicorn + the decompile. No capture
of the running commercial plugin was used. Addresses use decompile base
0x7FF91DC60000 (RVA = symbolVA − 0x7FF91DC60000); PE ImageBase is 0x180000000.

## TL;DR

Offsets **6864** (VCF Velocity, param 73) and **9680** (VCA Velocity, param 98)
are **velocity-dependent**, NOT a fixed constant. On note-on the plugin writes,
immediately (no smoother arming — voice_render does the smoothing from these as
targets):

```
JF(st, voiceBase + 6864) = juno_curve(56, velocity);   /* VCF Velocity, param 73 */
JF(st, voiceBase + 9680) = juno_curve(57, velocity);   /* VCA Velocity, param 98 */
```

where `velocity` is the **raw MIDI note-on velocity byte (1..127)** passed straight
through — no scaling, no cubic table, no sens/offset fold-in at this point.
`voiceBase = voice * 10512`.

The captured "PD The Juno Pad" values (6864 = 0.842520, 9680 = 1.154360) are simply
`juno_curve(56,107)` / `juno_curve(57,107)` — i.e. that note was struck at **MIDI
velocity 107**. 107 is the note's velocity, not an internal constant.

The recall oracle's `resolved_table.json` attribution "CONST(100)" for these rows is
**wrong** (an emulation artifact from driving the dispatch with a fixed default). The
true transform is `juno_curve(56/57, rawVelocity)`.

## The writer chain (all binary-derived)

1. **MIDI note-on → poly allocator.** `sub_7FF91DFB3870(assign, note, velocity)`
   (RVA 0x353870) → `sub_7FF91DFB3150(assign, note, velocity, mode)` (RVA 0x353150,
   CAssignJu60/CAssignB poly allocator). `a2`=note, `a3`=velocity are `unsigned __int8`.

2. **Allocator fires the gate-notify with the velocity.** At decomp_340000.c:14480
   (inside sub_7FF91DFB3150), for the chosen voice `v13`:
   ```c
   (*(...)(*(_QWORD*)a1 + 72LL))(a1, 2, v13 + v31 + 450, v6);   // v6 = a3 = velocity
   ```
   `v31 = 0` in the normal assign mode, so the dispatch index is **450 + voice**
   ("Voice0 Gate Notify" .. "Voice7 Gate Notify") and the value payload is the raw
   MIDI velocity `v6`.

3. **Param-manager dispatch.** `sub_7FF91E019A30(pmgr, index, flag, value)`
   (RVA 0x3B9A30). `case 450` (decomp_380000.c:25028) calls pmgr vtable slot at
   +1784, caches `a1[273]=value`. That slot resolves (pmgr vtable RVA 0x9C3018,
   +1784) to **`sub_7FF91E00EC60`** (RVA 0x3AEC60), the Voice0 Gate-Notify handler.

4. **Gate-notify handler.** `sub_7FF91E00EC60(pmgr, a2, value)` (0x3AEC60): if
   `value != 0` (note-on) it broadcasts gate-on, then calls
   **`sub_7FF91E011BB0(pmgr, idx, value, voice=0)`** (RVA 0x3B1BB0).

5. **Per-voice write dispatch.** `sub_7FF91E011BB0` (0x3B1BB0), with `a3 = velocity`,
   `a4 = voice`, invokes the two voice DSP modules directly:
   - decomp_380000.c:18894 `(*(v9_vt + 16))(v9, _, velocity)` — v9 = CDSPJu60AmpVoice
     for the voice; **AmpVoice vtable slot 2** = `sub_7FF91DFB7160` (RVA 0x357160).
   - decomp_380000.c:18898 `(*(v10_vt + 208))(v10, _, velocity)` — v10 =
     CDSPJu60FltVoice; **FltVoice vtable slot 26** = `sub_7FF91DFB9F30` (RVA 0x359F30).

6. **The setters (curve applied to the velocity, immediate write).**
   - `sub_7FF91DFB9F30(this, mode, a3)` (0x359F30, FltVoice::SetVelocity):
     `sub_7FF91DFB6380(&curveTable, 56, a3)` → `sub_7FF91E0210F0(...)` (IMMEDIATE set)
     of param 73 → engine offset **6864**.
   - `sub_7FF91DFB7160(this, mode, a3)` (0x357160, AmpVoice::SetVelocity):
     `sub_7FF91DFB6380(&curveTable, 57, a3)` → immediate set of param 98 → **9680**.
   `sub_7FF91DFB6380` (RVA 0x356380) is the plugin's curve evaluator = the port's
   `juno_curve(curve_id, value)`. `a3` (the velocity) is the curve INPUT, unmodified.

## Proof it is velocity-dependent (live emulation of the real dispatch)

Built the full instance (`full_oracle.py`: BUILD sub_7FF91E0268D0), located the
param-manager (vtable 0x9C3018), and drove the real dispatch
`sub_7FF91E019A30(pmgr, 450, 1, velocity)` over a velocity sweep, hooking 4-byte
writes into the 11 MB engine block. Voice-0 offsets 6864 / 9680 tracked
`juno_curve(56/57, velocity)` **exactly (bit-for-bit) at every velocity**:

| velocity | off 6864 | juno_curve(56,v) | off 9680 | juno_curve(57,v) |
|---------:|---------:|-----------------:|---------:|-----------------:|
|   0 | (not written — note-off path) | | (not written) | |
|   1 | 0.007874 | 0.007874 | 0.001989 | 0.001989 |
|  20 | 0.157480 | 0.157480 | 0.028046 | 0.028046 |
|  64 | 0.503937 | 0.503937 | 0.235015 | 0.235015 |
| 100 | 0.787402 | 0.787402 | 0.930000 | 0.930000 |
| **107** | **0.842520** | **0.842520** | **1.154360** | **1.154360** |
| 127 | 1.000000 | 1.000000 | 2.000000 | 2.000000 |

At velocity 0 the handler takes the note-off branch (`if (a3)` false) and does NOT
write 6864/9680 (they hold their prior value); gate 320 goes to 0. So on note-on the
velocity range that reaches the curve is 1..127. `juno_curve` internally clamps its
input to [0,255], so no extra clamp is needed.

This is the decisive point the single capture could not settle: the values move with
velocity, and velocity 107 reproduces the captured pair exactly.

## Exact C to add to `src/juno_note.c`

In `juno_note_on(st, voice, midi_note, velocity)`, after the existing M.CV / M.Gate /
aux-latch writes (velocity is already guaranteed `> 0` by the early `velocity <= 0`
guard). Requires `#include "juno_curve.h"`.

```c
/* Velocity (immediate, en=0). The plugin's poly allocator fires the per-voice
 * "Gate Notify" (dispatch 450+voice) with the raw MIDI velocity; the FltVoice/
 * AmpVoice SetVelocity methods apply curve 56 / 57 to it and write these targets
 * directly. voice_render already smooths 6896/9712 toward them and folds in the
 * Velocity Sens/Offset params in the per-sample DSP, so nothing else is needed here. */
JF(st, base + 6864) = juno_curve(56, velocity);   /* VCF Velocity (param 73) */
JF(st, base + 9680) = juno_curve(57, velocity);   /* VCA Velocity (param 98) */
```

Remove the `(void)velocity;` line and the "velocity->coeff curve not transcribed"
disclaimer in the header. On note-off, leave 6864/9680 as-is (the plugin does the
same — gate closes via offset 320, which `juno_note_off` already does).

Note on the docs' earlier worry: the 256-entry cubic table `((i+1)/129)^3` that
CDSPJu60FltVoice/AmpVoice build in their ctors (obj+56 / obj+44) is **NOT** on this
path — SetVelocity uses the global `juno_curve` table (56/57) on the raw velocity.
The "Velocity Sens/Offset" fold-in the docs flagged as un-reduced is already inside
the bit-exact `voice_render`; the note handler only needs the two curve writes above.

## Adjacent finding (same gate-notify, for a fully faithful note-on)

Driving dispatch 450 at velocity > 0 writes five voice-0 offsets, all confirmed:

| offset | name | value on note-on |
|-------:|------|------------------|
| 320  | M.Gate (param 2)        | 1.0  (already written by juno_note.c) |
| 1856 | Gate (curve 52 LIN(1,1))| 1.0 |
| 6864 | VCF Velocity (curve 56) | `juno_curve(56, velocity)` |
| 9680 | VCA Velocity (curve 57) | `juno_curve(57, velocity)` |
| 9824 | Mute (curve 51)         | 1.0 |

`juno_note.c` currently writes only 320. For an exact match it should also set
1856 = 1.0 and 9824 = 1.0 on note-on (both velocity-independent, per-voice at
`+voice*10512`). This is slightly beyond the asked scope but is the rest of the same
atomic gate-notify and is included for completeness. (Their note-off values were not
swept here; the OFF branch of sub_7FF91E00EC60 handles them.)

## Q4 — smoother-init constants 2848 / 3328 / 6448

`param_descriptor_map.json` names them 2848 = "Q24C Initialize" (param idx 36,
ENV1), 3328 = "Q24C Initialize" (idx 42, ENV2), 6448 = "Osc1 Mute" (idx 67); the
recall table (`full_recall_table.json`) classifies all three **`internal_nonrecall`**
with `blob_pos = record_pos = curve = null` — i.e. they carry NO patch data and are
never written by a preset recall.

Emulated the plugin's own prepare and read them back:

- After `BUILD` + `setSampleRate(0x3C7A20, 96000)`: still 0.0 (smoother targets armed,
  coefficient not yet snapped).
- After snap-all `sub_7FF91E0229B0(ST)` (RVA 0x3C29B0): **2848 = 3328 = 6448 =
  1.000000**, identically for every voice (checked voices 0/1/2).

`sub_7FF91E0229B0` just snaps every active smoother in the vector to its target; the
1.0 targets are fixed engine constants installed by `setSampleRate`/prepare, with no
dependence on the loaded patch. **Conclusion: invariant defaults — safe to set once
in `prepare` (per voice, `+voice*10512`).** They are not per-patch. (By contrast
6864/9680 stay 0 through the entire prepare and only move on note-on, consistent with
the velocity finding.)

## Residual uncertainty

- The velocity result is airtight: the value written equals `juno_curve(56/57,
  velocity)` bit-for-bit across the whole sweep, driven through the plugin's real
  dispatch, and velocity 107 reproduces the captured pair. The only thing the binary
  cannot tell us is what velocity the original capture used — but that no longer
  matters, because the mechanism (raw MIDI velocity → curve) is proven, so the port
  reproduces whatever velocity the host sends.
- The poly-allocator → dispatch hop (CAssignB vtable slot 9 forwarder) was not opened
  byte-by-byte, but it is not load-bearing: I drove the real param-manager dispatch
  that this forwarder targets, with value = velocity, and observed the exact curve
  outputs. The allocator demonstrably passes the raw `a3` velocity as that value
  (decomp_340000.c:14480).
- 1856 / 9824 note-OFF values were not swept (out of the asked scope); only their
  note-on value (1.0) is confirmed here.
