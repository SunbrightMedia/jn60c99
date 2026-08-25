# OPEN DEFECT — cell 102560 (delay send) differs on 18/64 factory patches

Found 2026-08-25 by `tools/verify/census_exhaustive_gate.py`, the gate written
to close the reach hole that mutation testing exposed (playbook 80). This is
the FIRST genuine port defect the mutation-driven work has uncovered, and it
sat behind a fully green `make verify`.

## The finding
Under the plugin's OWN recall path (all 9 units, `real_recall.leaf_table()`
order, trailing `snap_all()` — i.e. `real_recall.recall`'s exact protocol):

    the plugin writes cell 102560 = 0x3ed8d8d9 on EVERY patch (a constant)
    the port writes a VALUE THAT VARIES

18 of the 64 factory patches differ. Examples:

| patch | plugin | port | DELAY LEVEL | DELAY TYPE |
|---|---|---|---|---|
| 2  | 0x3ed8d8d9 | 0x3eababac | 44  | 0 |
| 13 | 0x3ed8d8d9 | 0x3f095623 | 69  | 0 |
| 30 | 0x3ed8d8d9 | 0x3f095623 | 0   | 0 |
| 50 | 0x3ed8d8d9 | 0x00000000 | 69  | 0 |
| 53 | 0x3ed8d8d9 | 0x3f666666 | 85  | 0 |

All 18 are DELAY TYPE 0. The port's value does not track DELAY LEVEL either
(patch 30 has LEVEL 0 and patch 13 LEVEL 69, both -> 0x3f095623), so the port
is writing this cell from some other law while the plugin holds it fixed.

## Why every existing gate missed it
`recall_exhaustive_gate.py` sweeps every byte 0..255 but reads only the
VOICE-0 block (10512 bytes). Cell 102560 is in the master/FX region beyond
VOICE_END (84096), so it was never compared. `recall_render_ab.py` compares
OUTPUT AUDIO, and this cell is evidently not read on the render path these
patches take — bit-exact audio therefore proves nothing about it.

## Ruled out (each measured, not argued)
- **Isolation artifact**: no. Reproduced under the plugin's own full recall
  protocol, not a single-byte dispatch from defaults.
- **Dispatch order / ramp settling**: no. Reproduced with all 9 units, true
  leaf order, and the trailing `snap_all()` that settles ramp records.
- **A mode selector's cross-byte dependence** (the DELAY TYPE 875 / REVERB
  TYPE 876 class, which ARE isolation artifacts and are proven so in
  census_exhaustive_gate.py's MODE_SELECTORS comment): no — this is a plain
  parameter cell and the whole factory bank agrees on the plugin side.

## Status
OPEN. Not yet attributed to a specific line in `src/delay_recall.c`. The next
step is to find which port law writes 102560 and why it is not the constant
the plugin holds. Audio impact is UNKNOWN and must not be assumed zero just
because the render A/B is green — that gate never reads this cell.
