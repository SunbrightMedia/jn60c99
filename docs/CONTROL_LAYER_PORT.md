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

## Status
- Binary-derived the full param routing table (1121 params). ✓
- Confirmed the ramp engine (`juno_ramp.c`) is already bit-exact. ✓
- Mapped the note path to params 1/2/73/98 and confirmed the envelope is
  gate-driven (no reset param). ✓
- Established that the current envelope-reset + arp are approximations to be
  replaced. ✓
- Remaining: transcribe the voice allocator + note handler, the smoother advance,
  CArpeggio, and retire the capture. In progress.
