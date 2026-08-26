# carp.c — one LATENT state-cell divergence (2026-08-26)

**No live defect. No `src/` change today.** Recorded so it is not rediscovered
from scratch, and so it is paid at the right moment.

## Coverage this closes
The second audit pass covered the seven files the first pass never reached.
All agents completed (19/19, 0 errors), all reading TEXT dumps only.

| file | comparisons checked | candidates |
|---|---|---|
| `src/reverb_recall.c` | 7 | 0 |
| `src/delay_recall.c` | 3 | 0 |
| `src/chorus_recall.c` | 9 | 0 |
| `src/juno_mod.c` | 7 | 0 |
| `src/juno_dsp.c` | 14 | 0 |
| `src/juno_hostparams.c` | 0 (no float compares exist) | 0 |
| `src/carp.c` | 33 | 4, of which **3 killed, 1 survived** |

Together with the first pass (`finefx_recall.c`, `effect_modes.c` clean;
`juno_apply.c`, `juno_note.c`, `juno_prepare.c` candidates all refuted except
one latent), **every JUNO source file has now been audited for the
unordered-compare and missing-store classes.**

## The survivor: `carp_remove_key` does not clear the vacated slot

`src/carp.c:96`, plugin `sub_1803BF2A0`, non-poly branch.

The plugin's shift walks `sorted[]` DOWNWARD from the old top, writing each
slot's previously-read value into it. `r10d` is seeded `0xFFFFFFFF` at
`0x3BF2C2`, so the FIRST store (`0x3BF2F3`) puts **-1 into
`sorted[old_count-1]`**. The port performs the same shift and never writes that
vacated top slot, so it keeps a stale duplicate of its former neighbour.

Same class as `juno_ramp_reset`'s unwritten `step_cnt` — a store the plugin
makes and the port does not.

The fix, when it is paid:
```c
e->sorted[e->count - 1] = -1;   /* 0x3BF2C2 seeds 0xFF; index evaluated BEFORE the decrement */
e->count--;
```
`sorted[]` is `int8_t` and `carp_reset` already fills all 129 slots with -1, so
-1 is the port's established empty sentinel. It must go INSIDE the existing
`if (idx >= 0)` block (see below).

## Why it is LATENT, not a defect — measured, not assumed
The divergent cell sits at index `== new count`, which is **strictly above
every read**. All five readers (`carp_add_key:64`, and the four selectors at
:121, :143, :166, :198) index `< count`, or take the `sorted[count-1]`
fallback. The next `carp_add_key` unconditionally overwrites that slot. So no
emitted note, gate value, or state read can differ.

Two of three refutation lenses let the claim stand on the machine code; the
REACHABILITY lens refuted it as unobservable. That split is the finding.

## A second leg of the claim is DEAD, not merely latent
The claim also said the plugin decrements `count` unconditionally
(`0x3BF2CC`) while the port decrements only when `idx >= 0`. True of the asm,
unreachable in fact: entry is gated at `0x3BF2A3` on `note_active[note] != 0`,
and `note_active` is only set when `carp_add_key` inserts. So `idx >= 0` is an
invariant and the two forms cannot differ. Not a divergence at all.

## Existing coverage
`tools/verify/arp_sched_ab.py` already diffs the plugin's own `CKbdArp`
schedule under Unicorn against `carp.c`'s, across held-note add/remove — the
behaviour layer this cell feeds. That gate is green, which is consistent with
the cell being unobservable.

## Owed
Pay it with the next `carp.c` change, with a state-cell tooth that asserts
`sorted[count]` is -1 after a removal, seen to fail first. Do not open frozen
bit-exact code for it on its own.
