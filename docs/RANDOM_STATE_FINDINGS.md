# Random full-state A/B — first findings (2026-08-13)

`tools/verify/random_state_ab.py`, 12 seeds, every recall leaf randomised,
port vs the plugin under Unicorn, whole render-visible state compared.

## Result: 40 cells differ, and none of them is inert

The control matters more than the number. `recall_fullstate_diff.py` was run on
FACTORY PATCH 0, which is render-bit-exact, and produced its own 32-cell
"differs anyway" set (the C++ object header and audited-inert FX defaults).

    random-gate differing cells                     40
    of those, also differ on a bit-exact patch       0
    REAL candidates                                 40

Zero overlap. Every one of the 40 is a genuine disagreement.

## Where they are

| region | cells | note |
|---|---|---|
| 6497168..6497488 | 18 | DELAY TYPE 5 / reverb-hosted time + fine-FX |
| 10692016..10693280 | 15 | CHORUS |
| 102528/102544/102592 | 3 | TYPE-0 delay: wet, block const, **mute/enable** |
| 91232 | 1 | chorus LFO / BBD ring |
| 101744 | 1 | aux one-shot |
| 10759488 | 1 | reverb |
| 11022052 | 1 | effect routing |

## What this confirms and what it adds

**Confirms issue 2 independently.** Cell 102592 (delay mute/enable) is in the
list, found from random parameters with no bank involved — the same cell the
user-bank hunt reached from the other direction.

**Adds two blocks that no bank had implicated:** the CHORUS (15 cells) and the
DELAY TYPE 5 / fine-FX block (18 cells). Both are FX recall — the derived layer,
not the transcribed DSP, exactly as predicted.

## Status of each

NOT ATTRIBUTED. Proven: the cells, that they are recall and not render, and that
they are not inert. The parameter combination that drives each is owed, and must
be DERIVED from the plugin's own dispatch — never fitted to these seeds.

## Method note worth keeping

12 seeds were enough to find 40 cells. The single-parameter exhaustive gate had
run every parameter at every value and found none of them, because each needs
two or more parameters set together. That is the whole argument for this gate.
