# Cold-load A/B — matching the plugin's post-recall engine state (Phase 3)


> **SUPERSEDED (2026-07): this document is historical.** Live status is
> `PROVENANCE.tsv` (checked by `make verify`); the claims ledger is
> `docs/CLAIMS.md`. Where this file conflicts with those, they win. In
> particular, the "not recalled / held constant" conclusions about the DCO
> RANGE / LFO / PWM cluster were REFUTED by the plugin's own recall enumerator
> (rva 0x3B48A0, executed) — see CLAIMS §E11–E13; and recall is NOT complete:
> the FX path has known open divergences (delay feedback 102560, patches
> 50/6/45). Kept as a record of how the earlier conclusions were reached.

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

### P3d — the last per-patch cells (now 64/64 bit-exact)
- **6736 (VCF cutoff)**: removed the `record_befloat(1870)` "high-res override" — the
  engine holds the coarse `juno_curve(22, byte 35)` value for all 64 (0/64 mismatches);
  the override was a value-tree artifact diverging on 11 patches (incl. patch 47, 0.14 vs 0.21).
- **10240 (HPF TYPE≠0 cutoff)**: rate-scaled the 96k boost LUT by 96000/SR (see below).
- **608 (porta mode)**: LEGATO==1 AND ASSIGN==1 only (was `as != 0`, wrong for ASSIGN==2).
- **3968 (unison detune)**: ASSIGN==2 carries a fixed −0.0025 DCO pitch offset.

**Result: 64/64 factory patches render bit-exact at cold-load** (0 slot-7 state-cell
diffs across the whole bank; 0 audibly off; RMS ratio [0.999, 1.000]).

## Beyond the factory bank — random-patch verification

Recall is per-parameter (each knob → its own curve → its own cell), so the factory 64
(which span the full 0–255 range of every knob) verify the curves; the handful of
cross-parameter interactions (HPF cutoff×type, bend×range, legato×assign, assign==2) are
identified and handled. To prove this directly rather than argue it,
`id_random_capture.py` generates random parameter combinations, runs the **plugin's own
recall** on each under Unicorn, and `id_random_ab.c` compares our applier's slot-7 block
cell-for-cell.

First run (40 random patches, seed 1234): bit-identical except a 1-ULP HPF-boost rounding
on 3 of 256 cutoff values at 48 kHz — the plugin computes the boost cutoff coefficient
independently at each rate, and `96k_value × 2` rounds 1 ULP away from the direct 48 kHz
value for those three cutoffs. Sub-audible, but closed by capturing the boost LUT directly
at 44.1/48/96 kHz and selecting by rate (`hpf_sweep_*.json` → `HPF_T1_10240_{44,48,96}k`).

After the fix, a fresh run of **100 random patches (seed 98765): 0 cell diffs — our
applier is bit-identical to the plugin's own recall on every one.** Reproduce:
`python3 id_random_capture.py --n 100 --seed 98765 && ./id_random_ab 100`.
