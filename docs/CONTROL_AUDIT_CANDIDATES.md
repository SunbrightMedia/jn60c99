# JUNO control-layer audit — ADJUDICATED (2026-08-26)

**VERDICT: no live defect. Six of seven candidates REFUTED. One is LATENT.
NOTHING in `src/` is to be changed from this file today.**

Two passes ran. The first (12 file agents) produced seven candidates and then
died at a session limit with every refutation agent unrun. The second put each
candidate through THREE INDEPENDENT LENSES — machine code, C source,
reachability — each defaulting to REFUTED. 28 agents, 0 errors. A candidate
survived only if two lenses failed to refute it AND every lens could read its
dump.

That second pass is why `src/` was not edited on seven claims, five of which
asserted they were reachable in ordinary operation. **They were not.**

## Adjudicated results

| # | candidate | verdict | why |
|---|---|---|---|
| 1 | BEND enable gate (`juno_apply.c:522`) | **SURVIVES — but LATENT, not a defect** | asm and C lenses confirm the plugin gates the curve-4 factor on `obj+0x24` (`cmp dword [rbx+0x24],0 ; je -> xorps`) and the port never reads it. The REACH lens refutes it as unreachable: **the port has no live pitch-bend path at all**, so no input makes audio differ today |
| 2 | MOD enable factor | **REFUTED** 2 of 3 | |
| 3 | missing 7th note-on store | **REFUTED** 3 of 3 | |
| 4 | comment offset 101520 vs 101488 | **REFUTED** 3 of 3, one dump unusable | |
| 5 | rate rounding vs truncation | **REFUTED** 3 of 3 | |
| 6 | mul/div order in the rate law | **REFUTED** 2 of 3, two dumps unusable | |
| 7 | NaN rate early-out | **REFUTED** 2 of 3 | |

## The correction I owe this file
The earlier version carried a column asserting five candidates were
"NaN-INDEPENDENT", i.e. reachable in ordinary operation. **That column was
unsupported and is withdrawn.** It came from single agents with no challenger.
Playbook 80 in miniature: a claim that defines its own scope cannot be wrong
until something independent tests it.

## Candidate 1 — what is actually owed, and when
It is a STATE-CELL mismatch, not an audio defect, and the honest sequence is:

1. **Do not edit `src/` now.** `juno_apply.c` is frozen bit-exact code, and the
   tree must be frozen while gates run — a speculative edit can invalidate a
   multi-hour run. Zero audible change is bought.
2. **The blocking unknown is a MAPPING, not a fix.** `obj+0x24` is not written
   by any param-dispatch index; only live bend/mod-wheel handlers set it
   (`tools/oracle/bendmod_setter_findings.md`). Until that is mapped to a
   record byte or leaf, no correct fix can be written.
3. **Pay it with the MIDI pitch-bend work**, and write the gate RED first:
   `bend_enable_gate.py` — ctypes only, no Unicorn, no `make verify`. Drive
   recall at rest over 64 factory + 12 user banks; assert offsets 4128 and 7472
   are bit-exact `0x00000000`. It FAILS today (the port writes
   `curve(22,bsd) * curve(4,brng) * mode`, non-zero for any non-zero sens byte).
   Add the mandatory seen-to-fail tooth: force the enable to 1 in a test-only
   path and confirm it goes red again, so it is not vacuously green.

## Files audited CLEAN
| file | evidence |
|---|---|
| `src/finefx_recall.c` | no float comparison, no float clamp. Store audit PROVEN(executed) by hooking the plugin's own dispatch; the port's write set is a strict subset and every omitted cell is byte-constant and already written identically by `delay_recall.c` |
| `src/effect_modes.c` | all 16 comparisons INTEGER; the plugin's own SR path is integer too (`0x3BC980` forwards SR in EDX) |

## Never audited — still owed
`reverb_recall.c`, `delay_recall.c`, `chorus_recall.c`, `juno_dsp.c`,
`juno_mod.c`, `juno_hostparams.c`, `carp.c`. Six files, no coverage. Run the
first workflow again with the TEXT-DUMP rule (`docs/asmdumps/`, playbook 82b)
so it costs no emulator memory.
