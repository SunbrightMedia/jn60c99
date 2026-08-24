# PORT COMPLETENESS CHARTER — binding for EVERY .vst3 → C port

Written 2026-08-24, after the JX-3P port reported "64/64 patches EXACTLY 0" on
two banks at three rates while 25 of its 57 real parameters were never set and
11 documented placeholder branches returned NaN. No gate found it. A user
counted the knobs in a host and asked why the number disagreed.

This charter exists so that cannot happen again. It applies to the JUNO-60, the
JX-3P, and every synth after them. It is not advice; a port is NOT done until
every gate below is green **and** the scope statement in §5 is filled in.

---

## 0. The failure this charter prevents

**A differential gate cannot detect a dimension neither side exercises.**

Port-vs-oracle harnesses drive both sides through the SAME code. Whatever that
code does not set, neither side sets; they agree; the gate is green. Green then
gets reported as "the port is correct", when it only ever meant "these two
agree on the slice I chose".

Worse, the slice is usually chosen by *discovery* code — a probe that decides
which parameters "matter". A gate that defines its own scope shrinks silently
and can never fail. There is no input that turns it red.

Every rule below is a structural defence against that one shape.

---

## 1. CENSUS BEFORE GATES (mandatory)

Before any A/B gate is trusted, the port must have an **independent census**:
an enumeration, derived from the BINARY, of everything that exists.

- **Parameters.** Sweep every dispatch index over a full in-range value spread,
  watching FULL per-unit state of a voice unit AND the master unit, and record
  every index that moves state. Reference: `tools/verify/juno_scope_probe.py`,
  `jx3p/tools/probe_pools.py`.
  - The value spread must NOT come from a preset bank. A parameter constant
    across the shipped bank still exists. (This flaw hid 25 JX parameters.)
  - The watched window must NOT be a voice-sized slice. Master/FX parameters
    write the master unit. (This flaw hid the JX effects entirely.)
- **Leaves / cells.** Enumerate from the binary, not from a hand list. The
  JUNO's `COVERAGE.tsv` + `completeness_gate.py` is the reference shape.
- **Cross-check against the host.** The plugin's own UI or a DAW's parameter
  list is an INDEPENDENT witness of the user-facing count. If the census and
  the host disagree, the census is wrong until proven otherwise.

**Census is not discovery.** Discovery code may propose a set; only the census
may define scope, and the two must be compared by a tooth (§2).

## 2. A TOOTH ON THE SCOPE ITSELF (mandatory)

Every gate that consumes a parameter/leaf set must be paired with a check that
goes **RED when the gate's reach is smaller than the census**.

- The tooth compares the gate's own set against the census set.
- It must be SEEN TO FAIL: remove one element and confirm red.
- "Every gate must be seen to fail" applies to the gate's REACH, not only to
  its arithmetic. The JX gates were all seen to fail on wrong values, and all
  were blind to a missing parameter.

Never widen a scope tooth to make it pass. Fix the discovery instead.

## 3. NO TODO BEHIND A GREEN GATE (mandatory)

If code is placeholdered, stubbed, approximated, or "pending", there must be a
gate that **FAILS until it is resolved**.

The JX master render carried, in its own file header, the sentence "the 11
argless helper sites are ... placeholdered, pending a mode patch". It was true,
visible, and harmless-looking for weeks, because no gate could reach it. A
placeholder that no gate can reach is indistinguishable from finished code.

Acceptable: a red gate, or a compile-time failure, or a documented row in a
ledger whose count is asserted. Not acceptable: a comment.

## 4. MUTATION REACH (mandatory)

Reading gates tells you what they check. Only breaking the port tells you what
they MISS. Run `tools/verify/mutation_gate.py`:

- One deliberate fault is injected per dimension, the port is rebuilt, gates run.
- **KILLED** = that fault class is covered.
- **SURVIVED** = a blind spot: the port could be wrong that way today with every
  gate green. Each survivor is a gate that must be written.
- A mutation counts only if the built artifact's hash CHANGED. No-op mutations
  (dead code, a constant inside a comment) are reported SKIP, never SURVIVED.
- The harness must first be SEEN TO KILL a known-covered fault, or a "survived"
  result means the harness is broken, not the port.

Ship with the survivor list at zero, or with every survivor named and accepted
in writing.

## 5. STATE THE SPACE WITH EVERY CLAIM (mandatory)

"Bit-exact" alone is a meaningless claim. Every completeness statement must
name the space it covers. Minimum dimensions — see `jx3p/docs/SCOPE_AUDIT.md`
for a worked example:

| Dimension | Question it answers |
|---|---|
| Parameters | which of the census set were actually SET? |
| State window | which bytes were actually COMPARED? |
| Duration | long enough for delay/reverb tails, LFO cycles, envelope release? |
| Note events | note-off, polyphony, velocity spread, re-trigger, bend/mod? |
| Block sizes | is block-size invariance gated? |
| Sample rates | including a NON-standard rate (catches rate-dependent constants) |
| Start condition | cold init, and warm (patch change on a running engine)? |
| Voice count | every voice-count the plugin exposes? |
| Host vs recall role | parameters a host reaches that a preset load never touches |
| Smoothing / ramps | are parameter ramps ported, or only settled values compared? |

A dimension not listed is a dimension where the claim is unverified — and, as
the JX-3P showed twice, that is exactly where the defects live.

## 6. REPORTING RULES (binding on me)

- Never say "the port is complete/100%" from a green gate. Say it from a census
  plus a mutation-reach number plus a filled-in §5 table.
- A green gate is reported as: "X agrees with the plugin over SPACE S."
- When a user's independent count disagrees with mine, THEIR count is evidence
  and mine is a hypothesis until measured.

---

## The one-line version

**Green means "these two agree where I looked". Say where you looked, prove you
looked everywhere that exists, and prove that looking would have caught it.**
