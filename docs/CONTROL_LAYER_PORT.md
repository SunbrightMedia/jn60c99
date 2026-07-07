# Bit-exact control-layer port — plan, findings, and status

## Why this exists

The DSP half of the port (`voice_render`, `master_render`, `juno_curve`, the
init/chorus tables, `juno_ramp`) is a bit-exact transcription of the plugin's
functions. The **control layer** — how a MIDI note becomes engine coefficient
writes, voice allocation, the envelope gate/retrigger, velocity, and the
arpeggiator — was NOT ported; it was hand-written approximation (`juno_note.c`
calls itself a "calibrated driver"; the arp in `juno_bridge.c` is bespoke). Every
audible bug the user has reported (attack not snappy, arp wrong, earlier pitch
perception) lives in that hand-written layer, not in the bit-exact DSP. This
document tracks replacing the hand-written control layer with a bit-exact
transcription of the plugin's own control code, so the port "does it properly
every time".

## How the plugin's parameter system works (transcribed / derived)

- Each parameter has a 40-byte **descriptor**. `descriptor[param]+32` is a pointer
  straight into the engine's flat coefficient array; `+12` is an enabled flag,
  `+20` a smoother slot index. The descriptor table (1121 params) is BUILT by the
  plugin's own `sub_7FF91E022550`/`…225B0`; we run that under the Unicorn oracle
  and dump the full `param -> {engine offset, slot, name}` map — this is
  binary-DERIVED (running the plugin's build code), not captured. See
  `scratchpad/unit2/descmap.json` (1121 params, all resolve to a valid offset).
- **Immediate set** (`sub_7FF91E0210F0`): `*descriptor[param].target = value` —
  writes the coefficient directly.
- **Smoothed set** (`sub_7FF91E0210D0` → voice-trigger `sub_7FF91E022920`): arms
  the smoother for `descriptor[param].slot` to ramp toward the target over N
  steps, and tracks the active smoothers in a vector.
- The **ramp engine** (`sub_1803C2E80` start / `…2E00` step / `…2E60` reset) is
  already a verified bit-exact transcription in `src/juno_ramp.c`. Per-step
  increment = `(target - current) * (1000/time_ms) / (rate/steps)`.

## The note path — exact param routing (binary-derived)

| what        | plugin param        | engine offset | notes |
|-------------|---------------------|---------------|-------|
| note pitch  | param 1 `M.CV`      | 304           | keyboard CV |
| note gate   | param 2 `M.Gate`    | 320           | drives both ADSRs in the DSP |
| VCF velocity| param 73 `Velocity` | 6864          | |
| VCA velocity| param 98 `Velocity` | 9680          | |
| note-off notify | param 927 `Voice0 Note Off Notify` | 101504 | the per-voice edge `voice_render` consumes |

Crucial finding: the ADSR integrator/level slots (ENV1 2592/2720, ENV2 3072/3200)
are targeted by **NO** parameter. The envelope is pure DSP state; it attacks and
re-attacks purely from the **M.Gate** signal (offset 320). So the correct,
faithful note-on is: set M.CV, ramp M.Gate 0→1, set Velocity — and the DSP
envelope does the rest. The snappy attack on a replayed note comes from the
plugin's **voice allocator** handing each note a voice whose gate/envelope is
fresh, NOT from resetting the envelope.

Therefore `juno_note.c`'s current envelope-reset (zeroing 2592..3248 on note-on)
is a hand-written APPROXIMATION — it is not what the plugin does and must be
replaced by the faithful voice-allocation + M.Gate driving.

## To-do (all must be bit-exact from the binary — see task list #20-#24)

1. **Note/voice control layer (largest).** Transcribe the note-on/off handler and
   the poly **voice allocator** (which voice a note gets, stealing, and whether a
   stolen voice's state is reset), driving M.CV / M.Gate / Velocity through the
   descriptor+smoother path. Replaces `juno_note.c` + the allocation glue in
   `juno_driver.c`. Fixes attack/retrigger/velocity at the source.
2. **Parameter-smoother subsystem.** Model the descriptor table (binary-derived,
   above) + the smoother array + the per-control-tick advance of all active
   smoothers. Ramp engine already done (`juno_ramp.c`).
3. **CArpeggio / CKbdArp** (`sub_7FF91E01D270` ctor, `…22F20` CKbdArp): transcribe
   the real arpeggiator and recall its per-preset on/mode/rate, driving notes
   through the ported note handler. Replaces the hand-written arp.
4. **Retire the capture**: derive `runtime_coeffs_data.c` from the binary via the
   ported prepare/smoother path.
5. **hpf_type_lut / juno_ftz** provenance: confirm transcription; use hardware FTZ
   where available, explicit flush only as the WASM fallback.

## Verified against the decompile (the note handler is now bit-exact)

The full Hex-Rays decompilation is committed at `refs/allcode_decomp.tgz` (unpack to
inspect; RVA-named `decomp_XXXXXX.c` + `refs/manifest.tsv`). Using it we confirmed
the note control surface directly against the plugin's own code:

- **Immediate set** `sub_7FF91E0210F0(obj,0,param,value)` = `*descriptor[param].target
  = value`. Verbatim.
- **Smoothed set** `sub_7FF91E0210D0 → sub_7FF91E022920` only acts `if
  descriptor[param].flag == 1` (en=1); it arms `smoother[descriptor.slot]` via
  `sub_7FF91E022E80(...,target,time,subdiv=10)`. So **en=0 params (M.CV, M.Gate) are
  never smoothed — they are written immediately.** The smoother arm/step
  (`sub_7FF91E022E80` / `sub_7FF91E022E00`) is the exact math already in
  `src/juno_ramp.c`; the run/reap loop is `sub_7FF91E0224A0`. The gate ramp target
  constant is `unk_1809DEB50 = 4.0` (used only for smoothed trigger params).

The note handler `src/juno_note.c` was therefore rewritten to write M.CV
(off 304) = note/12, M.Gate (off 320) = 1.0 on note-on / 0.0 on note-off, and the
aux DCO-retrigger latch (off 101504+v*32) — ALL immediate, matching the descriptor
flags. The earlier hand-written gate RAMP + envelope-integrator RESET were removed:
measured against the bit-exact DSP they produced an onset click + slow swell even
for fast-attack patches ("attack never snappy", "clicking"); the immediate-gate
mechanism reaches full level immediately with a clean gate-edge re-attack. Guarded
by `tests/test_note_path.c`.

## Status
- Binary-derived the full param routing table (1121 params). ✓
- Confirmed the ramp engine (`juno_ramp.c`) is already bit-exact (== sub_7FF91E022E80/
  E00), and the smoother run loop is sub_7FF91E0224A0. ✓
- **Note handler rewritten to the bit-exact immediate-gate mechanism** and verified
  against sub_7FF91E0210F0 / sub_7FF91E022920 + measured on the DSP. ✓
- Hardware SSE FTZ/DAZ enabled on x86 (juno_ftz.c) to match the plugin's FP mode;
  explicit per-sample flush kept as the WASM fallback. ✓
- Full decompile recovered (`refs/allcode_decomp.tgz`) — unblocks the remaining
  transcriptions.
- Voice allocator ported to the plugin's policy (below). ✓
- Remaining: velocity curve fold-in (below), and retiring the capture.

## Voice allocator (transcribed: CAssignJu60 / CAssignB)

ctor `sub_7FF91DFB59D0` → base `sub_7FF91DFB4E50` (voice count = min(req,8), init with
8; LRU queue at +120 = identity `[0..7]`), poly alloc `sub_7FF91DFB3150`. The engine
is **8-voice** (JUNO-60 hardware is 6; this JU-06A model allocates 8 — matched). Poly
note-on picks a voice in strict priority, then moves it to the LRU front:
  1. a voice already playing this MIDI note (re-strike);
  2. the OLDEST FREE voice (envelope finished);
  3. the OLDEST voice in RELEASE (gate off, still ringing);
  4. STEAL the oldest voice (LRU tail).
On steal/reuse it issues **gate-off → set-note → gate-on** (a gate 1→0→1 re-strike)
with **NO envelope-integrator reset** — re-attack is purely the M.Gate edge + the
DCO latch. This is exactly the mechanism the note handler already implements; it
independently confirms removing the hand-written envelope reset was correct.
`gui/juno_bridge.c` now implements this policy (same-note → oldest-free → oldest-
release → steal-oldest, LRU age, env-decay reaping of released voices).

## Velocity (identified, not yet integrated — honest)

Per-voice modules CDSPJu60FltVoice (VCF, ctor `sub_7FF91DFB8AF0`) and CDSPJu60AmpVoice
(VCA, ctor `sub_7FF91DFB5B20`) each build a 256-entry **cubic velocity curve**
`curve[i] = ((i+1)/129.0)^3`, i=0..255 (clamped [0,255]), feeding the immediate
params **VCF Velocity (73 / off 6864)** and **VCA Velocity (98 / off 9680)**, with
companion params Velocity Sens/Offset (84/85, 96/97). The exact fold-in of Sens/Offset
around the cubic curve into the final coefficient is structurally located but NOT yet
reduced to an equation, so velocity is left un-written (notes sound at the patch's own
level) rather than shipped as a partial approximation. The on-screen/computer keyboard
sends fixed velocity, so this is inaudible in the current preview.

CORRECTION (provenance hygiene): an earlier note said `sub_7FF91E021720` was the
velocity handler. It is NOT — it is a CDSPRev (reverb) method that writes param 1090
"Rev Dpm PreDly" (pre-delay ms→samples). It never touches velocity or M.CV/M.Gate and
must not be in the note path.
