# Saved workflows

Multi-agent workflows that earned their keep, kept in the repo so they survive
the container and can be re-run by name instead of re-written from memory.

**These are the reusable half of this project.** The JUNO DSP transcription does
not transfer to another synth; these do. Point `fork-adversarial-audit` at a
JX-3P fork and it hunts the same defect classes, because the classes are
properties of the METHOD, not of the JUNO.

| file | what it is for |
|---|---|
| `fork-adversarial-audit.js` | Loop-until-dry hunt for defects in a target fork. Seven lenses, each told to BREAK the build; every finding attacked by two independent skeptics before it survives. **This is the one that found the dead LFO.** |
| `find-cycles.js` | Find a named number of cycles on a named critical core, without losing audible accuracy. Four lenses (move work, remove work, cheaper arithmetic, build config), each lever refuted twice — once on cycles, once on sonic cost. |
| `next-phase-design.js` | Read the mechanisms that gate a next step, design against them, then have one agent try to REFUTE the design and another ask what nobody mentioned. |
| `ssx-portable-harness.js` | Earlier: the portable-harness work. |
| `trackb-cost-attribution.js` | Earlier: cost attribution across the Track B fork. |

## The thing that makes them work, if you write another

**Tell the agent to REFUTE, not to review.** A reviewer admires; a refuter
digs. The dead-LFO defect had survived every gate in the repo and was found
within minutes of an agent being told to break the design rather than assess it.

The second ingredient is **lens diversity**. Seven agents asked "find bugs"
return seven overlapping lists. Seven agents each given a different lens — gate
blind spots, shared state, shortcuts, flag combinations, index arithmetic,
approximations, concurrency — return seven disjoint ones.

The third is **an honest empty result**. Every prompt says an empty finding list
is a useful answer and a padded one is not. Without that, agents invent.

## What to give them, every time

The measured constants, the list of levers ALREADY CLOSED and why, the house
rules (label PROVEN / READ / INFERRED, cite file:line, a subtraction is not a
measurement), and **this project's own estimate record** — seven of eight
estimates wrong, six of them flattering. An agent told that its estimate is
probably optimistic writes a better estimate.
