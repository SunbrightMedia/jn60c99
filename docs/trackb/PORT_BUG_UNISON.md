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
