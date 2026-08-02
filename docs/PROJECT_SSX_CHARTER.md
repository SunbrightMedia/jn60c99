# PROJECT-SSX — the repeatable process, and the portability target

**User, 2026-08-02, verbatim:**

> "i want this process to be very easy and repeatable with just a master IDA
> capture and the compiled .vst3 of another project-ssx plugin."

That is the deliverable this project is really producing. The JUNO-60 is the
first instance, not the point.

## The two inputs, and nothing else

For any future plugin the process must start from exactly:

1. the compiled `.vst3`
2. a master IDA capture of it

Everything else must be derived. No hand-written parameter maps, no
reconstructed tables used as ground truth, no captures — the rules in
`CLAUDE.md` are what make the output trustworthy and they carry over unchanged.

## What made the JUNO-60 slow, so the next one is not

Ranked by time actually lost, from the retrospective:

1. **Gates that were green and wrong.** Not one bug — a recurring class. The
   assigner never learned KEY ASSIGN, so oracle and port were wrong *together*
   and every render A/B compared two copies of the same mistake. The fine-FX
   filters were absent from the recall leaf table, so the oracle never applied
   them either. The MONO retrigger latch was invisible to every cold gate by
   construction. Stale artifacts produced false greens twice in one day.
   **Mitigation for the next plugin: `sxgate`'s ordering — reached, then
   observable, then identical — is not optional, and the teeth test runs before
   any acceptance claim.**
2. **Measuring on the target far too late.** Every performance decision for
   weeks was made against models later shown to be optimistic by 6x, and one
   afternoon with real hardware redirected all of it.
   **Mitigation: get the golden corpus running on target hardware in week one,
   before any optimisation thinking at all.**
3. **A harness bug that invalidated a day.** A 32-bit cycle counter with no wrap
   check made everything measured on silicon wrong by 7x.
   **Mitigation: every measurement harness carries an independent cross-check
   clock, and the platform prints a pre-flight block before any result.**
4. **One experiment per flash.** Hardware iteration is expensive in human effort.
   **Mitigation: the firmware is an experiment PLATFORM. One boot returns a
   table. It parks itself in DFU so the next flash needs no buttons.**

## The portability target: Daisy Seed AND ESP32-S3

Engine B must not be written to the Cortex-M7. Design to the TIGHTER of the two
targets so the looser one is comfortable:

| | Daisy Seed (STM32H750) | ESP32-S3 |
|---|---|---|
| clock | 400 MHz (480 boostable) | 240 MHz |
| cycles/sample @48 kHz | 8,333 | **5,000** |
| cores usable for audio | 1 | 2 |
| FP | FPv5-D16 hardware single | hardware single (LX7) |
| internal SRAM | ~1 MB across ITCM/DTCM/AXI/D2/D3 | 512 KB |
| bulk RAM | 64 MB SDRAM | PSRAM, octal SPI, slower |
| code execution | XIP QSPI + 16 KB I-cache, or ITCM | XIP flash + cache |

Binding design rules that follow:

* **Per-voice hot state must fit in a few hundred bytes**, not kilobytes. This
  is the single decision that separates engine B from the 80x-too-slow port.
* **Total hot working set target < 200 KB**, so it is internal-SRAM resident on
  the S3, not merely on the Daisy.
* **FX delay-line lengths must be a compile-time budget**, so reverb/delay can
  shrink or move to PSRAM without touching the DSP.
* **No M7-specific intrinsics, no assumption of dual-issue, no assumption of a
  16 KB I-cache.** Plain C99 with a small measured hot loop.
* **Assume single-core**, and treat the S3's second core as headroom rather than
  as part of the budget.

Label discipline: the Daisy column is SILICON (measured on the user's board).
The ESP32-S3 column is READ from published specification and is **not measured**.
Nothing about the S3 should be treated as proven until the golden corpus has run
on one — which, per lesson 2 above, should happen EARLY rather than at the end.
