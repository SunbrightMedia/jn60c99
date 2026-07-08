# Voice-assign modes (ASSIGN MODE / LEGATO) — bit-exact port

The JUNO-60's KEY ASSIGN selector and LEGATO switch are **voice-allocation** controls,
not DSP coefficients: they change *which* voices a key press sounds and whether an
overlapping note retriggers. They were the one audibly-open item in the recall (a
mono/unison patch played polyphonically in the preview). This ports the plugin's
allocator `CAssignJu60` field-for-field.

## Provenance
Every rule below is transcribed from the decompiled allocator in
`scratchpad/allcode/decomp_340000.c` (see the full derivation in
`scratchpad/oracle/assign_modes_findings.md`). Ground truth = the binary only.

- **ASSIGN MODE** (CTRL value-tree leaf 58, engine param 800) and **LEGATO** (leaf 57,
  param 799) are decoded from the patch record by `juno_bank_voice_modes()`
  (`src/juno_apply.c`) — front-panel blob positions 56 / 55. **PORTAMENTO** (leaf 56,
  blob 54) is decoded too, because the legato glide is gated on portamento being
  engaged (byte ≠ 0). The value-tree order PORTAMENTO(798)/LEGATO(799)/ASSIGN(800) is
  `verified_golden` in `resolved_table.json`.
- The note-on entry `sub_7FF91DFB5820` dispatches 4-way on the cached ASSIGN MODE:

| ASSIGN MODE | allocator (RVA)      | behaviour                                    | factory patches |
|:-----------:|----------------------|----------------------------------------------|:---------------:|
| 0           | `sub_7FF91DFB3150`   | **POLY** — 8-voice LRU, same-note reuse       | 48 |
| 1           | `sub_7FF91DFB38F0`   | **MONO** — one fixed voice (voice 0)          | 14 |
| 2           | `sub_7FF91DFB3B60`   | **UNISON** — all 8 voices on the held note    | 2  |
| 3           | `sub_7FF91DFB35C0`   | **POLY-variant** — linear-scan, no reuse      | 0 (unused) |

## The rules (as ported in `gui/juno_bridge.c`)

**POLY (0).** Voice pick order: same-note reuse (newest match) → oldest free → oldest
release-pending → **steal** (oldest, or the *newest* voice if portamento is engaged, so
a portamento line re-uses its own voice). The chosen voice always retriggers (gate
1→0→1).

**MONO (1).** One fixed voice (voice 0). Press = **last-note priority**. If voice 0 is
still gated the new note is a **legato** move (pitch only, envelopes keep running — no
retrigger); if idle/releasing it retriggers. Voices 1..7 are forced off. Note-off falls
back to the **lowest still-held note** (low-note priority) — gliding voice 0 to it — or
releases if nothing is held.

**UNISON (2).** All 8 voices sound the **same** note (identical pitch; the assigner
writes no detune — any unison spread is downstream analog per-voice tuning, present in
all modes). Same last-note / low-note-release priority as MONO, applied to the whole
stack; the stack retriggers together only when it was idle, otherwise it glides.

**POLY-variant (3).** First free/release voice by linear index, else steal; no same-note
reuse and no legato glide. Unused by the factory bank; ported for completeness.

**LEGATO.** Read in exactly one place in the binary (POLY, and only when PORTAMENTO ≠ 0):
a newly played note drags every currently-held voice's pitch to the new note
(poly-portamento-on-legato). It does **not** gate an envelope-retrigger latch and has no
effect in modes 1/2/3 or with portamento off. (The mono/unison "no-retrigger-on-overlap"
legato is hard-wired into those modes, keyed on whether the target voice is still gated —
not on the LEGATO param.)

## Verification
`gui/juno_bridge.c` gains `juno_gui_debug_voices()` (voice notes + gate state). Playing a
C-E-G chord then releasing top-down reproduces the spec exactly:
- POLY → 3 voices gated (60,64,67), each release frees one.
- MONO → 1 voice, follows 60→64→67 (last-note); releasing G4 glides voice 0 back to C4
  (lowest held); releasing all → silent.
- UNISON → all 8 voices on the last note, glide as a stack to the lowest held on release.

## Honest gaps (from the agent's analysis, not shipped as guesses)
- The category-2 per-voice param `450+v` / `433+v` → engine-offset routing wasn't traced
  through the parent-engine vtable; functionally it is the same M.CV/M.Gate write the
  port already performs via `juno_note_on`/`juno_note_glide`.
- Panel labels (POLY-1 / POLY-2 / MONO / UNISON for values 0/3/1/2) are not encoded in
  the binary.
- Sustain/HOLD (CC64) release-pending deferral exists in the allocator; the preview has
  no sustain pedal input, so it is not wired (would be a mechanical add).
