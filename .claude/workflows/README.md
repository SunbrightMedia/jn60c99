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
| `exactly0-audit.js` | Audit of the EXACTLY-0 null claims — what each gate really proves. |
| `asm-kernel-recon-and-decision.js` | Recon on the hand-written Xtensa kernel, and the decision not to build it. |
| `cycle-attribution-design.js` | Designing where the cycles actually go, before optimising any of them. |
| `engineb-s3-assessment.js` | The original ESP32-S3 feasibility assessment. |
| `engineb-pitch-v3-and-qemu.js` | The pitch evaluator work and the QEMU instruction-count harness. |
| `ssx-portable-harness.js` | The portable-harness work — the piece most directly reusable for another synth. |
| `trackb-cost-attribution.js` | Cost attribution across the Track B fork. |

Ten scripts, ~140 KB. Every multi-agent run this project has made, kept whole
rather than summarised, because a summary of a workflow cannot be re-run.

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
