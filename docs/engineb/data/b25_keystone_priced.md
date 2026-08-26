# b25 — the keystone is priced: VCA-only is the cut

`docs/engineb/data/b25_keystone_priced.md` — 2026-08-26

b24 left the keystone (a chunk-pipelined voice back half on core 1) as the only
surviving path to parity, and explicitly UNPRICED: *"nobody has priced those on
this silicon… Call it a coin-flip, not a plan."* This prices it.

## The decision rule, stated BEFORE the run (playbook 11b)

> A cut is VIABLE only if it moves **306–426 cycles/sample** off core 0. Less
> misses parity; more makes core 1 critical (b24 §2: M = (976 − S)/2).
> PREDICTED: `vcf` alone OVERSHOOTS. `vca` alone UNDERSHOOTS.

## What was measured

MEASURED (QEMU-executed Xtensa instructions), harness rebuilt against current
`engine_b`, real recalled coefficients, 12,500 samples x 8 voices:

| module | instr/voice/sample | ratio to vcf |
|---|---|---|
| `eb_vcf_tick` | 1,105.2 | 1.000 |
| `eb_vca_tick` | 389.0 | **0.352** |
| `eb_nsvf_tick` | 33.0 | 0.030 |
| `eb_decim_tick` | 288.0 | 0.261 |

Scaled by b24's own ladder anchor (1,083 cyc):

| candidate cut | cycles | verdict |
|---|---|---|
| `vcf` alone | 1,083 | **OVERSHOOTS** — predicted, confirmed |
| **`vca` alone** | **381** | **INSIDE the window** |
| `vca` + `nsvf` | 414 | INSIDE, at the top |
| `nsvf` alone | 32 | far short |

## The prediction was HALF WRONG, and that is the finding

`vcf` overshooting was predicted and held. **`vca` undershooting did NOT hold** —
it lands at 381, squarely inside 306–426. Recorded because the whole reason the
rule is written before the run is to stop a wrong prediction from being quietly
reshaped into a right one afterwards.

b24 reasoned "moving one voice's ladder overshoots" and stopped there. It never
priced the VCA separately, so it could not see that the smaller module lands in
the window almost exactly.

## What this number IS and IS NOT

**IS:** a MEASURED instruction ratio (0.352, dynamic, real coefficients, no
noise floor) applied to a READ cycle anchor.

**IS NOT** a silicon cycle count. Three limits, stated:
1. QEMU counts **instructions, not cycles**. Scaling assumes `vcf` and `vca`
   have comparable CPI. Both are FP-heavy straight-line DSP so it is plausible —
   it is NOT proven, and it is the load-bearing assumption of this whole page.
2. The 1,083 anchor is itself **READ** (516 static instructions x an assumed
   c/i 2.1), not measured on silicon. If the anchor is wrong, every row scales
   with it — but the RANKING and the ratios do not change.
3. `pitch_dbl` measured 3,636 instr/voice, which says this harness build does
   not use the shipping `EB_PITCH_FAST` path. That does not touch the vcf:vca
   ratio, but it does mean the roll-up total (64,085 instr/sample) is NOT the
   shipping engine and must not be quoted as such.

## Verdict

**The keystone is viable, and the cut is VCA-only.** It is no longer a
coin-flip: the module that has to move exists, and its size lands in the
window rather than overshooting it.

## Owed before anything is built

1. **Confirm on silicon.** The CPI assumption is the risk. `S3L_TIME_PROLOGUE`'s
   batched-probe shape resolves ~2.4 cycles/sample — 125x finer than the
   whole-loop noise floor — and is the right instrument.
2. **Carry the cut set correctly** (b24 §6): the chunk-late pass must also carry
   `st->glide[v].s560` (7 floats, not 6), and `eb_modcv_latch` must STAY on
   core 0 — `decim → modcv → dco` closes a one-sample loop inside the voice.
3. **The price is one more chunk of latency** (5.8 ms) on top of the FX pipe's.
   The invariant permits it; the user has approved measuring, not building.
4. Fix the rig's trailing CHECK step: it needs `xtensa-esp32s3-elf-objdump` on
   PATH (source `export.sh`). The measurement itself is unaffected — the CHECK
   is a scale self-test, and it should be made to run again before the next use.
