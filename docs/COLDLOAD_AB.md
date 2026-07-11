# Cold-load A/B — matching the plugin's post-recall engine state (Phase 3)

The render (Tier B) is bit-exact **given identical state** (docs/BITEXACT_RENDER_AB.md,
64/64). Cold-load additionally requires our *state setup* — recall + note-on — to
reproduce the plugin's own post-recall engine state. This documents the audit of
that setup against the plugin's ground truth.

## Method

Ground truth is the plugin's engine state captured under Unicorn (the binary's own
recall dispatch + note-on; NOT a plugin audio capture):
`scratchpad/oracle/idstate64/state_pN_unit.bin` — unit 7, slot 7, patch N, note 60,
vel 105, 48 kHz, right after note-on.

Our side dumps the equivalent state through the real bridge
(`juno_gui_create → juno_gui_apply_bank → juno_note_on(slot 7)`,
`scratchpad/oracle/id_coldstate_batch.c`) and diffs cell-by-cell. Because the render
is proven bit-exact, any differing cell that the render reads is a real cold-load
setup bug, and its correct value is the captured engine cell.

## Value tree ≠ engine state (the root confusion)

The applier was originally validated against the plugin's **value tree** (the CKoa
parameter tree, `test_apply_golden.c`). But several engine cells are NOT the value-tree
value — the plugin does more work between the tree and the DSP cell. Comparing the
value tree to the captured engine state (patches 0/5/40) shows:

- **Envelope/porta/HPF times** (2784/2816/2832 ENV1, 3264/3296/3312 ENV2, 624 porta,
  10240 HPF): engine = **2× value tree** at 48 kHz — the rate scaling (×96000/SR).
  The bridge already applies this (SR-VARIANT bindings), so these are correct in the
  real cold-load path; only the golden froze the pre-scaling value.
- **feet 3840**: value tree = 1.0/1.0/2.0 per patch, but engine = **1.0 for all 64** —
  recall never writes 3840 (it stays at prepare's default). See below.
- **PWM depth 4144, VCF-LFO 7344, DCO-LFO 4032, LFO routing 3888/3904/3920/3936**, etc.:
  value tree carries a value, engine holds ~0 or a gated value. (Under investigation.)

The **engine state is ground truth**; where they diverge the value-tree-matching
applier is wrong.

## Fixed

### Note pitch M.CV (cell 304) — one octave too high
The plugin's note-on writes `state[304] = (note-12)/12 + analog_tune(note)`, captured
exactly for all 128 notes (`juno_mcv_bits[]` in `src/juno_note.c`; probe
`id_feet_mcv_probe.py`). We wrote `note/12` — one octave high. Bit-exact now.

### DCO RANGE → feet (cell 3840) — spurious write
Proven under Unicorn: cell 3840 = 1.0 through prepare → recall → snap for **every**
patch regardless of the raw DCO-RANGE byte (0..169). Recall never touches it. Our
`{16,5,T_ID,3840,"DCO RANGE"}` binding wrote `juno_curve(5,byte)` (e.g. 0.5 for patch
4), which — combined with the note/12 octave bug — cancelled on pitch but left every
patch ~1.3× off in level. Binding removed; 3840 keeps prepare's 1.0.

### Impact (audio A/B, our cold-load render vs plugin captured stream, 64 patches)
Before: 12 patches audibly off (RMS ratio outside [0.67, 1.5]); worst 0.076/2.20.
After P3a+P3b: **5 patches** off; p25–p75 RMS ratio tightened [0.92,1.10] → [0.99,1.04].

## Remaining (in progress)

The 5 still-audible patches (1, 13, 28, 41, 43) and residual bit-diffs are in the LFO
recall cluster and a few DCO/VCF/VCA cells:
- LFO: 1072 (tempo rate), 1088/2064 (rate), 1920/1936 (delay), 4032 (DCO mod),
  7344 (VCF mod), 3888/3904/3920/3936/3968 (routing), 1872 (key trig).
- DCO/VCF/VCA: 4144 (PWM depth), 9600 (VCA velo), 6736 (cutoff 1-ULP), 10240 (HPF edge).

Each is being derived against the captured engine state (not the value tree).
