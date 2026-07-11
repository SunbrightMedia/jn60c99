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

### LFO / PWM / mod cluster (cells constant in the engine, our applier wrote per-patch)
A cell-by-cell map of all 64 captured slot-7 blocks showed a large group of cells the
plugin holds **identical across every patch**, while our applier wrote per-patch
value-tree values into them: 1072 (LFO tempo rate), 1088/2064 (LFO rate coeff), 1920/1936
(LFO delay), 4032 (DCO LFO mod), 7344 (VCF LFO mod), 4144 (DCO PWM depth), 1872 (LFO key
trig), 3888/3904/3920/3936 (PWM source select), 9600 (VCA vel sens).

Proven these are genuine constants (not pre-smoother snapshots): (1) the smoother records
targeting them are **inactive** with target == the constant; (2) `init_baseline_findings.md`
finding B — running the plugin's own per-block smoother advance (sub_7FF91E0224A0) 2000×
leaves inactive cells unmoved; (3) overwriting all of them with the plugin constant makes
our cold-load render **bit-exact** for most patches and RMS-exact for all. The value tree
carries per-patch LFO/PWM values, but they never reach these DSP cells at recall — PWM
mod depth (4144) in particular is a near-zero denormal for every patch, so PWM modulation
is effectively off in the plugin's render.

Fix: removed the per-patch bindings; `juno_engine_prepare` already sets most constants,
and juno_bank_apply now sets the two it doesn't (1088/2064 = 0.5686275) plus the exact
denormals (4144/7344). 1072 keeps prepare's default (8.735357) at load — the bridge only
recomputes it when a real host tempo drives (juno_gui_arp_config, bpm > 0). VCA/VCF vel
sens forced to 0 (velocity inert).

### Impact (audio A/B, our cold-load render vs plugin captured stream, 64 patches)
- Before: 12 patches audibly off (RMS ratio outside [0.67, 1.5]); worst 0.076 / 2.20.
- After P3a+P3b (M.CV + feet): 5 patches off; p25–p75 ratio [0.99, 1.04].
- After P3c (LFO/PWM cluster): **0 patches off**; RMS ratio range **[0.984, 1.049]**,
  median 1.000; **47/64 patches bit-exact**.

## Remaining (Category B — inaudible bit residuals)

The 17 not-yet-bit-exact patches are RMS-exact (~1.000); the residual bit-diffs are in
genuinely per-patch cells with a small ULP/edge mismatch: 6736 (VCF cutoff high-res),
10240 (HPF, a few TYPE/rate edge patches), 608 (porta mode, 1 patch), 3968 (1 patch).
These are sub-audible; tracked as P3d.
