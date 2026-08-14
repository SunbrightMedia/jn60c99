# ASSIGN MODE 3 — found by the user's banks, never reachable from the factory bank

## The evidence

12 user banks, 768 patches, against `src/` (the frozen bit-exact port):

    recall_gate        768/768 PASS
    render A/B         637/691 bit-exact, 54 differ

Correlation with ASSIGN MODE, over every rendered patch:

| ASSIGN MODE | fail | pass |
|---|---|---|
| 0 | 15 | 481 |
| 1 | 8 | 99 |
| 2 | 6 | 49 |
| **3** | **22** | **0** |

**Mode 3 fails 22 of 22. It never passes.**

## Why no gate caught it

The 64 factory patches contain modes 0, 1 and 2 only — stated in
`src/juno_apply.c:921` from the per-leaf variance audit ("ASSIGN MODE 1 in 14
and 2 in 2 patches"). **Mode 3 has never been executed by any gate**, because no
input that reaches it existed until the user supplied one.

## Where the divergence is — and where it is NOT

`recall_fullstate_diff.py` on Deep_House patch 1 (mode 3, fails) versus patch 0
(mode 0, passes): both differ from the plugin only in the C++ header (< 176) and
in reverb/routing cells already audited inert. **The recall state is identical.**

The audio diverges at **sample 2**. So the disagreement begins at NOTE-ON: the
port and the plugin put the note on a DIFFERENT VOICE. Per-voice CONDITION
scatter then makes the timbre differ from the first sample — exactly the
observed signature.

## What the port does

`gui/juno_bridge.c:664` `synth_note_on`:

    case 1: mono_note_on
    case 2: unison_note_on
    case 3: poly_note_on(..., 1)     <- a POLY variant
    default: poly_note_on(..., 0)

So mode 3 is implemented, is not a crash, and is WRONG in a way only a mode-3
patch can show.

`juno_apply_unison_spread` also tests `assign == 2` exactly, so mode 3 gets no
detune. Whether that is correct is unknown and must be derived, not assumed.

## What is owed

1. Drive the plugin's own allocator (`CAssignJu60`) under Unicorn with ASSIGN
   MODE 3 and record which voice it picks, over a note sequence. `eb_alloc` is
   already proven 270/270 over nine configurations — check whether those nine
   include mode 3, or whether it shares this blind spot.
2. Fix `poly_note_on(..., 1)` to whatever the plugin does.
3. Add a mode-3 case to the allocator gate, and SEE IT FAIL first.

## The general lesson (playbook)

A parameter value that no factory patch uses has never been tested, however
green the gates are. "64/64 bit-exact" is a statement about 64 patches, not
about the parameter space. The user's banks reached mode 3 on the first try.

## Still open

32 of the 54 failures are in modes 0/1/2 — a SECOND cause, not yet identified.

---

# ISSUE 2 (2026-08-13): the DELAY is switched ON when the plugin has it MUTED

The 32 failures in ASSIGN MODE 0/1/2 are a different fault, and unlike issue 1
this one IS a recall difference.

`recall_fullstate_diff.py` on 2_Preset patch 11 (fails):

| cell | plugin | port | what it is (delay_recall.c) |
|---|---|---|---|
| 102592 | 0 | **1** | delay mute/enable gate |
| 102560 | 0 | **0.423529416** | delay FEEDBACK |
| 102544 | 1.30727255 | 0 | TYPE-0/1 block constant |

The port enables the TYPE-0 delay block and gives it feedback; the plugin leaves
that block muted. Audible from the first samples, which matches the measured
divergence at sample 2.

`delay_recall.c` derives these as:

    On/Off (102576)      = 1 if DELAY LEVEL > 0 else 0
    Mute/enable (102592) = same as On/Off

so the port reaches "on" from DELAY LEVEL alone. The plugin evidently does not,
for this patch — meaning some OTHER parameter (DELAY TYPE, EFFECT TYPE, or the
routing that selects which delay instance is live) gates it, and that
combination does not occur in the 64 factory patches.

⚠ NOT YET ATTRIBUTED to the specific parameter combination. What is proven: the
cells, the direction, and that it is recall rather than the render.

## Owed
1. Find which parameter mutes that block in the plugin. Derive it by driving the
   plugin's own dispatch, never by fitting to these patches.
2. Fix the law in `delay_recall.c`.
3. Gate it, seen to fail first.
