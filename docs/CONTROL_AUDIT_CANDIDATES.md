# JUNO control-layer audit — UNVERIFIED CANDIDATES (2026-08-26)

**STATUS: NOT FINDINGS. NOT FIXES. DO NOT EDIT `src/` FROM THIS FILE.**

A 12-file audit workflow ran against the binary. It reached the session limit
partway: **5 of 19 agents completed, 14 died**, and *every one of the seven
refutation agents was among the dead*. So the candidates below have been
claimed once and challenged zero times.

That distinction is the whole point of playbook 78 and charter rule 4. Twice
today an audit claim of mine looked solid and was wrong:
* the "18 of 64 patches differ" claim (retracted — incomplete oracle);
* my first fix for the `jne` unordered case (wrong — the gate caught it).

So each row below needs the refutation pass re-run, and then a GATE THAT IS
SEEN TO FAIL, before one line of `src/` changes.

## Files audited CLEAN (both agents completed)
| file | evidence |
|---|---|
| `src/finefx_recall.c` | no float comparison and no float clamp exists in it. Store audit PROVEN(executed) by hooking the plugin's dispatch: the port's write set is a strict subset, and every omitted cell is byte-constant and already written with an identical value by `delay_recall.c` |
| `src/effect_modes.c` | all 16 comparisons are INTEGER. The plugin's own sample-rate path is integer too (`0x3BC980` forwards SR in EDX), so no float compare is being transcribed |

## Candidates — each needs REFUTE, then a gate, then a fix
| # | file | rva | claim | NaN-independent |
|---|---|---|---|---|
| 1 | `juno_apply.c:522` | `0x35C659`, `0x359C09` | BEND RANGE curve-4 factor is gated behind an enable field at obj+0x24; the port computes it unconditionally | **yes** |
| 2 | `juno_apply.c:526` | `0x35C73E`, `0x359D3E` | both MOD depths are multiplied by a 0/1 enable at obj+0x2c; the port omits it. Order matters: `mulss(sens,sw)` THEN `mulss(.,10.0f)` | **yes** |
| 3 | `juno_note.c:164` | `0x3AEC9A` → `0x35CC30` | note-on makes SEVEN engine writes; the port makes six. Missing: per-voice Gate Notify, param 926+2v, off `101488 + v*32`, set to 1.0f | **yes** |
| 4 | `juno_note.c:176` | `0x35C94B` | comment says the cell is at `101520 + v*32`; the binary says `101488 + v*32`. No code effect, but it is stated as measured fact in two places | n/a |
| 5 | `juno_prepare.c:65` | `0x3C7A43` | the plugin does NOT truncate the rate. It widens to double, ROUNDS half-away-from-zero via `0x3F2050`, then saturating-converts. Every rate law then uses `(float)Hr` | **yes** |
| 6 | `juno_prepare.c:108` | `0x356D4F`, `0x362D82` | the file claims "one divss then one mulss, exactly as the binary". The binary holds BOTH orders, and for the LF-Damp Fc cell it is the other one. `(a*b)/c != a*(b/c)` | **yes** |
| 7 | `juno_prepare.c:60` | `0x3C7A31` | `ucomiss; je` early-out is taken when unordered, so a NaN rate makes the plugin write NOTHING | no |

Five of seven claim to be NaN-INDEPENDENT. If even one survives refutation it
is a defect reachable in ordinary operation, like the `juno_ramp_reset`
`step_cnt` omission found and fixed today.

## Why no gate could see any of these
`make verify` drives recall and render through the shapes a preset load
produces. Candidates 1, 2 and 3 are all MISSING STORES or MISSING FACTORS
whose absent term is 0 or 1 for every factory patch — the same shape as
`EFFECT_SW_LUT[1..63]`, which no factory patch reached either.

## Re-run
    Workflow({scriptPath: '<...>/juno-control-layer-audit-wf_0376accd-905.js',
              resumeFromRunId: 'wf_0376accd-905'})
Completed agents replay from cache; only the 14 dead ones re-run. Six files
were never audited at all: `reverb_recall.c`, `delay_recall.c`,
`chorus_recall.c`, `juno_dsp.c`, `juno_mod.c`, `juno_hostparams.c`, `carp.c`.
