# The assigner-mode blind spot — KEY ASSIGN / LEGATO never reached the allocator

**Status: ROOT CAUSE FOUND AND PROVEN BY EXECUTION (2026-07-27).** This is the
defect behind the user's long-standing "it still sounds wrong" report, including
the BS Solid attack/sub-band divergence that survived the recall-completeness hunt
(`ENUM_HUNT_STATUS.md`) and the render-loop scope (`RENDER_LOOP_LOG.md`).

## One paragraph

The plugin's voice allocator `CAssignJu60` does **not** read KEY ASSIGN from the
parameter store when it needs it. It caches it: **ASSIGN MODE (param 800) at
`assigner+16`** and **LEGATO (param 799) at `assigner+20`**. The only writer of
those two fields is `sub_7FF91DFB49B0(assigner, 4)`, and the only caller of *that*
is the engine's **host parameter entry** `sub_7FF91E027AE0` (engine vtable +112),
which — after every single parameter write — does exactly two things per unit:

```c
(*(vtbl(proc[u])   + 88))(proc[u], idx, 0, value);   /* 0x3B9A30, the dispatch */
(*(vtbl(assign[u]) +  8))(assign[u], 4);             /* the assigner refresh   */
```

Our recall path makes the first call and never the second. So under the oracle the
plugin's own allocator stayed in **POLY for every patch**, forever. A previous
investigation measured the port against that oracle, concluded "all three KEY
ASSIGN values are polyphonic", and hard-forced `assign_mode = 0` and `legato = 0`
in `gui/juno_bridge.c`. Oracle and port were then wrong *together*, which is why
no gate could see it: **every render A/B was comparing two copies of the same
mistake.** This is exactly the failure mode the user predicted with "perhaps if the
issue is truly invisible, there is something wrong with our tests."

## The chain, each link labelled

| # | Fact | Label |
|---|------|-------|
| 1 | `sub_7FF91DFB5820(asg, note, gate)` dispatches on `asg[4]`: `1` → MONO `sub_7FF91DFB38F0`, `2` → UNISON `sub_7FF91DFB3B00`/`3B60`, else POLY `sub_7FF91DFB3870` | READ (decomp_340000.c:16295) |
| 2 | `sub_7FF91DFB49B0(asg, g)`: `if (g == 4) { sub_7FF91DFB49F0(asg); getter(asg,4,799,&v); asg[5] = v; }`; `49F0` reads param **800** into `*(asg+16)`, flushing (`4C70`+`30B0`) when it changes | READ (decomp_340000.c:15451–15500) |
| 3 | The assigner's real vptr is rva `0x969740`; **slot 1 (+8) is `0x3549B0`**, slot 2 (+16) noteOff `0x355780`, slot 3 (+24) note gate `0x355820` | **PROVEN** (`probes/assigner/laneX_slot8.py`) |
| 4 | The host parameter entry `0x3C7AE0` calls `proc[u]->+88(idx,0,v)` then `assign[u]->+8(4)`, for all 9 units, on every write (`v11 = a1+136`; `v11-5` = `HOST+96+64u` = proc, `v11-4` = `HOST+104+64u` = assigner) | READ (decomp_3C0000.c:5781+) |
| 5 | After our recall the fields are `(0,0)` on all 9 units for **every** patch; after running the plugin's own `0x3549B0(asg,4)` they become the patch's real values — BS Solid `mode=2`, LD Classic Lead `mode=1`, LD Porta `mode=2 legato=1` | **PROVEN** (`probes/assigner/laneX_mode_field.py`) |
| 6 | Notifying once after the recall writes is identical to the host's notify-after-every-write: same assigner fields, same audio, **0 differing cells over all 9 × 0xA83010 bytes** | **PROVEN** (`probes/assigner/laneX_notify_placement.py`) |

## The audio impact — plugin vs itself

Same engine, same recall, same note (60 @ vel 100), same render. The **only**
difference between the two arms is whether the plugin's own refresh ran
(`probes/assigner/laneX_audio_impact.py`, 22050 samples @ 44.1 kHz):

| patch | ASSIGN | RMS off → on | Δ | samples differing |
|---|:--:|---|---|---|
| Chillwave 3 **BS Solid** | 2 | 0.09585 → 0.65162 | **+16.65 dB** | 22047/22050 |
| Chillwave 4 **BS Glide** | 2 | 0.15148 → 1.12641 | **+17.43 dB** | 22048/22050 |
| Chillwave 30 LD Porta | 2 | 0.06969 → 0.16745 | +7.61 dB | 22048/22050 |
| Factory 61 LD Perc Lead | 2 | 0.02405 → 0.10803 | +13.05 dB | 22048/22050 |
| Factory 5 LD Classic Lead | **1** | 0.03275 → 0.03268 | −0.02 dB | 22048/22050 |
| Factory 0 SY Poly Synth | **0** | 0.07770 → 0.07770 | 0.00 dB | **0/22050** |

The ASSIGN=0 row is the non-vacuity control: the refresh is a provable no-op for
poly patches, so the other rows are the mode taking effect and nothing else.

Note the MONO row: the *level* is unchanged but **every sample differs**. A mono
patch allocates voice 0 while the port's POLY allocator takes voice 7, and the
per-voice CONDITION analog scatter makes those two voices deliberately different
in tuning and level. So mono patches were rendering with the wrong voice's
component tolerances — a subtle, per-patch timbre shift with no level clue.
That is the signature the bounce locator kept reporting as "per-patch and
bidirectional" (#124).

## Scope — how much of the bank was affected

Reading blob bytes 54/55/56 through the plugin's own parser:

* **Factory bank**: 48 patches ASSIGN 0, **14 ASSIGN 1 (MONO)**, **2 ASSIGN 2
  (UNISON)** — 16/64 played in the wrong mode.
* **Chillwave bank**: PORTAMENTO up to 89 (factory maxes at 54) and many
  ASSIGN 1/2 patches, including **BS Solid (3) = ASSIGN 2** and
  **BS Glide (4) = ASSIGN 2 + PORTAMENTO 65**.

## The fix

1. **`tools/verify/e2e_emu.py`** — `E2E.assigner_notify()` runs the plugin's own
   `0x3549B0(assign[u], 4)` on all 9 units, exactly as the host entry does.
2. **`tools/verify/recall_render_ab.py`** — `prepare_recall()` calls it, so every
   gate built on it (render A/B, `fuzz_diff`, `renderstruct_ab`) now drives a
   plugin whose allocator is in the patch's real mode.
3. **`gui/juno_bridge.c`** — the `assign_mode = 0` / `legato = 0` overrides are
   removed; the patch's real values drive the allocator again. The MONO/UNISON
   implementations transcribed in `docs/VOICE_MODES.md` (from `sub_7FF91DFB38F0`
   / `sub_7FF91DFB3B60`) are live once more.
4. **`tools/verify/assigner_ab.py`** — a new gate in `make verify`. It drives
   NOTE SEQUENCES (a single note cannot tell POLY from MONO — which is why the
   old single-note A/B "proved" the wrong thing) through the plugin's allocator
   and the port's, over patches spanning ASSIGN 0/1/2 × LEGATO × PORTAMENTO at
   44.1 and 48 kHz, and requires bit-exact audio.

## Methodology note — add to `docs/P112_FINDINGS.md` §8's list

A fifth protocol error, and the most expensive one so far: **validating a
hand-written component against an oracle that never exercises the plugin
component it replaces.** The old A/B drove the plugin through the engine note
entry after a dispatch-only recall; that path reaches `CAssignJu60`, but with its
mode cache never initialised. The measurement was real, the conclusion was
backwards. The general guard: before concluding "the plugin does X", check that
the plugin's own code for *not*-X was reachable in the harness at all.
