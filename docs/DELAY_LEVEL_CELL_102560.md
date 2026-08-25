# RETRACTED — cell 102560 was NOT a port defect (my oracle was incomplete)

Claimed 2026-08-25, **retracted the same day**, by measurement.

## The claim (wrong)
`census_exhaustive_gate.py` reported that the plugin holds cell 102560 at a
constant 0x3ed8d8d9 while the port writes a varying value, on 18 of 64 factory
patches. I checked it under "the plugin's own recall path" and called it a real
defect.

## Why it was wrong
My oracle drove recall with `real_recall.leaf_table()` only — the 112 value-tree
leaves. The plugin's ACTUAL recall also fires EXTENDED leaves the enumerator
omits from that table: FX feedback/direct level, VCF/VCA velocity sens, and the
DELAY/CHORUS/REVERB fine-FX leaves. `recall_render_ab.prepare_recall` exists
precisely to drive that COMPLETE recall.

DELAY FEEDBACK is dispatch index 1179 — outside leaf_table. Without it the
plugin's descriptor for that cell stayed at its DEFAULT byte 120, and
0x3ed8d8d9 is exactly f32(120/255)*f32(0.9): the law evaluated at the default.
So the "constant" I saw was my own omission, and `src/delay_recall.c` line 134
warns about this exact trap — "one capture cannot tell a constant from a law".

## The measurement that settles it
Re-run through `recall_render_ab.prepare_recall` (complete recall, same rate,
same patches): cells 102528 / 102560 / 102576 match the plugin BIT-EXACTLY on
patches 2, 13, 20, 30, 50, 53. No difference. The port is correct here.

## The lesson (playbook)
An INCOMPLETE ORACLE is the mirror image of an incomplete gate scope, and it is
more dangerous: a narrow gate hides a defect, a narrow oracle INVENTS one. Both
come from the same root — driving the plugin through a hand-picked subset and
treating it as "the plugin".

**Rule: a gate must drive the plugin through its OWN complete entry point, not
through a leaf list the harness assembled.** Where such an entry point already
exists in the repo (`prepare_recall`), use it; never re-implement recall in a
new gate. `census_exhaustive_ref.py`'s single-leaf isolation is legitimate ONLY
for cells whose law depends on that leaf alone, which is why mode selectors are
excluded there — and FX cells that depend on extended leaves belong in the same
excluded class until driven through the complete recall.

## Status
CLOSED, no defect. The census gate's FX reach must be rebuilt on
`prepare_recall` rather than on single-leaf dispatch.
