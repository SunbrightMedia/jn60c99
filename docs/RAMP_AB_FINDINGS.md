# JUNO ramp A/B — four real defects, found the day the gate was written

Written 2026-08-26. `src/juno_ramp.c` was transcribed months ago and had **no
differential gate**. That was not a suspicion — it was measured: `ramp_const`
was a **mutation SURVIVOR**. The mutation harness changed a ramp constant,
rebuilt the port, ran the whole of `make verify`, and everything stayed green.
Charter rule 4 says a survivor is a gate that must be written. This is it.

Gate: `sh tools/verify/ramp_ab_gate.sh`. It drives the plugin's own
`sub_1803C2E80` / `sub_1803C2E00` / `sub_1803C2E60` under Unicorn over random
seeded ramp configurations and compares **every intermediate state**, not the
endpoint — a ramp that reaches the right target by the wrong path is still
wrong, and only the per-step record shows it.

## Result
0/300 → 178 → 253 → 289 → **300/300 EXACTLY 0**, across 3 seeds × 24 steps.

## The four defects

### 1. `juno_ramp_reset` never cleared `step_cnt` (NOT a NaN case — a plain bug)
The plugin's reset writes `mov dword ptr [rcx+0x24], eax` with `eax = 0`. The
port cleared `accum` and `active` and left `step_cnt` at whatever the
interrupted ramp had reached. The next ramp armed on that record therefore
fired its **first increment up to `subdiv-1` control ticks early**.

This is the one that matters musically, and it is the one that has been in the
port the whole time. **Seen to fail:** removing this fix alone drops the gate
from 300/300 to 215/300.

### 2, 3, 4. Unordered-compare mistranscriptions (playbook 81)
| Site | Plugin | Port had | Behaviour on NaN |
|---|---|---|---|
| `3C2E86` | `ucomiss target, r->target ; jne` | `target == r->target` | plugin early-outs and arms nothing; port armed the ramp |
| `3C2EDF` | `ucomiss incr, 0.0 ; jne` | `incr == 0.0f` | plugin ENTERS the nudge block; port skipped it |
| `3C2EE9` | `comiss start, target ; jae` | `start < target` | plugin takes the UP-nudge path; port took neither |
| `3C2E46` | `comiss out, target ; jae` | `out < target` | plugin KEEPS RAMPING; port clamped and deactivated |

## A mistake worth recording: my first NaN fix was also wrong
`ucomiss` sets **ZF=1 when unordered**, so `jne` is not taken for a NaN operand
*just as* it is not taken for equal operands. C's `a != b` is TRUE on NaN, so
**neither** `a != b` **nor** `!(a != b)` reproduces the jump. Only
"ordered AND unequal" does:

```c
#define JR_NE(a, b) ((a) < (b) || (a) > (b))
```

The gate caught my wrong fix on the next run. That is the argument for building
the gate before trusting the fix, not after.

## Two harness bugs the gate caught in itself (charter rule 7)
Both would have been reported as port defects by a gate without a control:
1. **The oracle did not set FTZ/DAZ.** Every other JUNO gate calls
   `e.set_ftz()`; this one did not, so the plugin produced denormal increments
   the port had already flushed. 253/300 → 289/300 on fixing the *harness*.
2. **The `out` pointer was compared.** It is an emulator address on one side
   and a host address on the other: 300/300 failures for no reason at all.

## What this says about the JUNO more widely
`unordered_audit.py` counts **57 at-risk `ja`/`jae` sites in the JUNO master
alone**, and `docs/NAN_SEMANTICS_SCOPE.md` recorded the decision not to
mass-rewrite them because no *measured* state reached a NaN. That decision
stands for the DSP chain. But it was made about the **render** path, and the
ramp engine is the **control** path, where the port had four errors of which
**one fires with no NaN anywhere**. The control layer was never audited.

**Owed:** the same treatment for the rest of the control layer —
`juno_note.c`, `juno_apply.c`, the smoother arming sites.
