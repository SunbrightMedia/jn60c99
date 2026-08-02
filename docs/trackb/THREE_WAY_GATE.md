# THE THREE-WAY GATE — engine B is never validated against the port alone

**User, 2026-08-02:**

> "when you say we compare against our port, that sounds dangerous if there are
> ANY holes in the port. so we better make sure its airtight or do a hybrid
> check of both the original ground truth and our rewrite"

Correct, and this project has already made exactly that mistake once. The
assigner never learned KEY ASSIGN, so the Unicorn oracle and the port were in
the SAME wrong state, and every render A/B was comparing two copies of one
mistake for weeks. Gating engine B against `src/` alone would rebuild that trap
on purpose.

## The rule

**`src/` is a fast PROXY for the plugin. It is never the authority.**

| comparison | run how often | what a divergence MEANS |
|---|---|---|
| **B vs `src/`** | constantly — it is fast (ctypes, no emulation) | a bug in B **or** a hole in the port. Do not assume the first. |
| **B vs plugin** (Unicorn) | at every acceptance point, and on any B-vs-src divergence | authoritative. This is the only comparison that can retire a claim. |
| **`src/` vs plugin** | whenever B and src disagree, and periodically | a divergence here is a **NEW PORT BUG** and is a valuable finding in its own right |

Any disagreement is triaged against the plugin before anyone touches B.

## Why this makes the rewrite an audit of the port

Engine B will drive parameter combinations and note sequences the port's own
gates never exercised. Every B-vs-src divergence is therefore a free probe into
the port's blind spots. Some of them will turn out to be port bugs — and finding
those is a benefit of doing B, not a cost.

## What `src/` has actually earned

It is not blind trust; it is the most heavily verified artifact in the project.
Against the plugin executed under Unicorn:

* render A/B **64/64 factory patches bit-exact**, at 44.1k and 88.2k
* recall EXHAUSTED — every single-input front-panel cell, all 256 byte values,
  3 rates
* cold state bit-identical at 44100/48000/88200/96000/192000
* differential fuzz: 24 seeds x 3 rates x 20 patches, ~500k samples, 0 diverged
* arp schedule and render 7/7
* `PROVENANCE.tsv` 20/20 PROVEN, zero RECONSTRUCTED/CAPTURED/UNVERIFIED

## And the named holes, which are exactly where B must not trust it

* **8 DEFERRED-CONTROLLER rows** — 7 FLANGER leaves (1242-1248) and Patch Tempo
  (1118). Engine-unreachable, so no gate covers them. If engine B implements a
  flanger, it CANNOT be validated against `src/` there.
* **DELAY TAP TIME 1178** — TYPE-1-gated, INFERRED record byte, frozen at 50 in
  the port.
* **The record-byte to parameter POSITION MAP** — validated but never executed;
  the one unexecuted link in the whole chain.
* **Anything the gates are structurally blind to.** The historical list is long
  and every entry was invisible until something outside the gates found it:
  KEY ASSIGN, the fine-FX leaf table, the MONO retrigger latch. There is no
  reason to believe that list is closed.

## Consequence for the behavioural extraction now in flight

Module specs are being derived by driving `src/`. That inherits any hole in
`src/` silently. So each extracted law carries a mandatory second step:
**spot-check it against the plugin under Unicorn before it is implemented.**
Exhaustive per-byte sweeps stay on the fast proxy; the plugin confirms the law's
SHAPE and its endpoints. A law that only ever agreed with the port is INFERRED,
not PROVEN, and must be labelled that way.
