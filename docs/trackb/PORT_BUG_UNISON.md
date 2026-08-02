# CANDIDATE NEW PORT BUG — UNISON diverges from the plugin after any idle

**Found by `tools/engineb/plugin_check.py` on its first run, 2026-08-02.
Independently verified before recording.**

## The measurement

`plugin_check.py --check-port` compares `src/` against the **plugin binary under
Unicorn**, which is the authority. Same harness, same event scripts, same rate:

| scenario | patch | result |
|---|---|---|
| pluck POLY | 5 | **BIT-EXACT** |
| MONO retrig | 15 | **BIT-EXACT** |
| chorus pad | 20 | BIT-EXACT |
| delay keys | 2 | BIT-EXACT |
| DCO noise | 32 | BIT-EXACT |
| **UNISON pile** | **61** | **−34.6 dB global, −16.3 dB worst-block — FAIL** |

−16.3 dB in a 1024-sample block is not a rounding artefact. It is audible.

## Narrowed: one idle sample is enough

Varying **only** the frames rendered before note-on, patch 61, note 48:

| idle frames before the note | residual vs the plugin |
|---|---|
| 0 (cold) | **BIT-EXACT** |
| 1 | −58.1 dB |
| 48 | −57.2 dB |
| 441 | −33.4 dB |
| 3000 | −32.6 dB |

`src/` matches the plugin on UNISON **only when the note lands on the very first
sample**. A single free-running idle sample is enough to diverge, and the
divergence grows with idle length before flattening.

## Why no existing gate could see it

`recall_render_ab.py` proves 57 factory patches bit-exact against this same
oracle — and drives **every one of them COLD**. A defect that requires one idle
sample is structurally invisible to it. This is the same shape as the warm
chorus-arm divergence and the MONO retrigger latch, both of which were also
invisible to every cold gate until something outside the gates found them.

It is also exactly why the user required the three-way rule
(`docs/trackb/THREE_WAY_GATE.md`): *"that sounds dangerous if there are ANY holes
in the port."* There is one, and gating engine B against `src/` alone would have
propagated it into engine B with a green gate.

## What is and is not established

* **MEASURED:** the divergence, its idle-dependence, and that POLY and MONO are
  bit-exact through the identical harness path with idle prefixes.
* **NOT established:** the root cause. A harness defect is not fully excluded —
  but the POLY and MONO controls run the same code path and are bit-exact, which
  is evidence against it.
* The port's own `make verify` remains green, because nothing in it drives a
  warm UNISON patch.

## Consequence, and it is immediate

**No engine B result on a UNISON patch may be believed until this is triaged.**
`null_b.py` compares engine B against `src/`, so on UNISON it is currently
comparing against something that does not match the plugin. Engine B could null
perfectly and be wrong, which is the precise failure this project has made before.

## Next

1. Triage: is it the port, or the harness? Compare the two engine states cell by
   cell after the idle and before the note, as `idle_units.py` did for the warm
   chorus bug.
2. If it is the port, fix `src/` — it is sealed, not infallible, and the seal is
   defined by the gates, which did not cover this.
3. Add a warm-UNISON case to `make verify` so the hole cannot reopen.

---

# TRIAGE RESULT (2026-08-02) — ROOT CAUSE ESTABLISHED. IT IS THE PORT.

**Not a harness defect.** The port is wrong, in the allocator, in exactly one
place, and the correction makes every failing case BIT-EXACT again.

## Root cause, named

**UNISON note-on does not arm the per-voice DCO retrigger latch (aux Array A,
`state[101504 + 32*v]`). The plugin arms it on ALL EIGHT voices.**

This is the same defect class as the MONO retrigger latch fixed in e611f7d, in
the mode next door. `gui/juno_bridge.c:mono_note_on` calls `juno_note_retrig()`
in its retrigger branch; `unison_note_on` (gui/juno_bridge.c:610) never calls it.

Why COLD is bit-exact and ONE idle sample is not: `juno_init` arms Array A at
BUILD. Cold, the latch is already 1.0, so the port matches by accident. The
first rendered sample CONSUMES the one-shot, so from then on the port's UNISON
note-on leaves all eight DCOs un-rephased while the plugin re-phases all eight.
UNISON stacks eight detuned copies of one note, so eight wrong phases is a large
error; that is why it reads −16 dB in a block and not −100.

## Executed evidence

**PROVEN (state diff, two processes, patch 61, 48 idle frames then note 48;
probes in `docs/trackb/probes_unison/`, `uni_ref.py` / `uni_cand.py` /
`uni_cmp.py`):**

* AFTER THE IDLE, BEFORE THE NOTE: every per-voice region (v*10512, all 8 voices,
  compared against the unit that renders that voice), the shared analog-noise
  block (84272..84436) and every aux slot 101504+32v are **byte-identical**.
  The only difference is voice 0's C++ header at offsets 0..160, the known
  audio-inert exclusion. **So the idle free-run itself is correct — the port and
  the plugin are in the same state right up to the note.** The divergence is
  created BY the note-on, not by the idle.
* AFTER THE NOTE-ON, the diff is 15 dwords and nothing else:
  `101504+32v` (Array A) = **plugin 1.0f, port 0.0f, all 8 voices**, plus
  `101520+32v` (Array B, the DSP-inert twin) 1.0f vs 0.0f.
* No other engine cell in [0,110000) differs at note-on time.

**PROVEN (audio, correction tested WITHOUT editing `src/` — the latch is poked
through `juno_gui_poke` immediately before the note, which is exactly what the
proposed fix does inside the allocator; `uni_scr_ref.py` / `uni_scr_cand.py`):**

| scenario (patch 61 UNISON, 44100 Hz) | port as shipped | + Array A armed at the idle note-on |
|---|---|---|
| 3000 idle, note, 10000, off, 4000 | −34.6 dB / −16.3 block | **BIT-EXACT** |
| idle, note, 4000, SECOND overlapping note (glide branch, NOT armed), 6000, off, off, 4000 | −34.6 / −16.3 | **BIT-EXACT** |
| idle, note, render, off, render, RE-trigger same note, render | −35.0 / −11.3 | **BIT-EXACT** |
| cold (0 idle) | BIT-EXACT | **BIT-EXACT** (arming is a no-op cold) |
| patch **63**, the bank's other UNISON patch, 3000 idle | −65.8 / −28.4 | **BIT-EXACT** |

Two independent controls inside the same runs:
* Arming Array **B** as well changes nothing (BIT-EXACT either way) — B is inert,
  as `src/juno_note.c` already documents. Only A matters.
* The OVERLAPPING note is **not** armed on the candidate side and the result is
  still bit-exact, so the plugin does not arm on the glide/legato branch. The arm
  belongs in the `was_idle` branch only — the same conditional MONO uses.

## Proposed fix (NOT applied; `src/` is frozen and this is a review item)

`gui/juno_bridge.c`, `unison_note_on`:

```c
     for (v = 0; v < JUNO_NUM_VOICES; ++v) {
-        if (was_idle) voice_trigger(c, v, midi_note, velocity);
+        if (was_idle) { juno_note_retrig(c->st, v);      /* aux Array A, all 8 */
+                        voice_trigger(c, v, midi_note, velocity); }
         else { juno_note_glide(...); ... }
     }
```

Nothing in `src/` needs to change: `juno_note_retrig()` already exists and is
already the MONO path's arm. The comment block in `src/juno_note.c:166-184` that
says the arm "lives in the allocator ... mono_note_on" should be extended to name
UNISON too, since the measured rule is now: **POLY note-on does not arm; a MONO
retrigger arms voice 0; a UNISON retrigger arms all eight.**

Risk of regression is bounded and measured: the arm is a no-op cold (S3 above),
so no cold gate result can move, and only patches 61 and 63 in the factory bank
are ASSIGN=2 (census over `truth/presetbankog1.bin`, record byte 112/113).

## Consequence for engine B

`null_b.py` was gating engine B against a `src/`+bridge that mis-phases every
warm UNISON note. **Any engine B UNISON result recorded before this fix lands is
uninterpretable** — it was nulled against a known-wrong reference. Re-run the
UNISON scenarios after the fix.

## Gate hole to close (the reason this survived)

Every one of `recall_render_ab`'s 57 patches is driven COLD, and `null_ab`'s
UNISON scenario compares the port against ITSELF. Nothing in `make verify` drives
a warm UNISON note against the plugin. Add a warm UNISON case (patch 61, idle
prefix ≥ 1 frame, note, release, tail) to `make verify` via `plugin_check.py`,
and the same for patch 63.

**Labels:** everything above marked PROVEN is executed — the plugin's own recall
and render under Unicorn on one side, a fresh `libjuno.so` on the other, two
processes, meeting only through pickles.
