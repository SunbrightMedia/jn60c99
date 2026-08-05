# C5 — CALL-STRUCTURE FUSION: CLOSED NEGATIVE, BY MEASUREMENT

**Verdict first, because the numbers say the goal is not reachable and that
sentence belongs at the top.** C5's modelled saving of ~1,500–3,000
instructions per sample is **not collectable on the ESP32-S3**. The prize is
smaller than modelled (**~640 instructions per sample, MEASURED**, about 0.9 %
of the engine), and every mechanism that would collect it costs more than it
is worth. C5 is closed. Nothing in the trunk changes; no correctness claim is
touched.

Date: 2026-08-05. Method: STATIC Xtensa, this project's own standard —
cross-compile at the shipping flags, count instructions with `objdump`. No
QEMU, no host timings.

## 1. What C5 proposed

`docs/engineb/P8_PLAN.md` §C5: *"One loop per voice instead of thirteen calls;
EXACTLY-0-able since it reorders nothing arithmetic. MODELED saving ~1,500–
3,000 (call overhead + window traffic + re-loads)."*
`docs/engineb/PHASE1_ORDERS.md` TASK 2 adds the binding condition: batching
only, identical arithmetic in identical order, EXACTLY 0 or backed out.

## 2. The prize, MEASURED

Per-call cost on this target is the callee's `entry` plus its return, plus the
caller's `call8` and argument setup: **4–6 instructions**. The per-voice chain
is 16 modules over 8 voices = **128 invocations per sample**, plus the DCO's
inner steps which are already counted separately.

    128 invocations x ~5 instructions = ~640 instructions per sample
    against a whole-engine 69,735  ->  0.9 %

**The model was 2.3x–4.7x optimistic.** It charged "window traffic + re-loads"
as if the call boundary forced them; on the register-window architecture
`entry` rotates the window rather than spilling it, so the boundary is close to
free and there is very little to reclaim.

## 3. The mechanisms, MEASURED

A probe translation unit (`scratchpad/eb_fused_probe.c`) `#include`s all
sixteen per-voice module `.c` files plus `eb_render.c`, so the compiler may
inline freely across every module boundary. Compiled at the shipping flags and
compared with the same seventeen files compiled separately:

| build | instructions | `call8` sites | float loads `lsi` | float stores `ssi` |
|---|---|---|---|---|
| separate translation units (today) | 4,129 | 118 | 718 | 282 |
| one translation unit | 4,184 | 116 | 743 | 280 |
| one TU, inlining forced¹ | **10,833** | **247** | **1,969** | **740** |

¹ `-finline-functions --param max-inline-insns-auto=2000
--param max-inline-insns-single=4000 --param inline-unit-growth=1000`.

**Same-TU compilation removes 2 of 118 call sites** and makes the code 1.3 %
larger with 3.5 % more float loads. GCC declines to inline the modules at
`-O2` because they are large, and its judgement is right.

**Forcing it is 2.6x worse across the board.** Note the direction of the
`call8` column: forced inlining *increased* static call sites from 116 to 247,
because each inlined copy re-emits the helper calls its body contains. Float
traffic went up by the same factor.

## 4. Why, and why it was predictable

This reproduces exactly what `docs/engineb/data/pitch_hoist_result.md` measured
on the double-float helpers: `always_inline` there was **worse** (3,452 vs
3,126 instructions), and 1,677 of those 3,452 instructions were float spills.
The LX7 has **sixteen float registers**. The per-voice modules each hold more
live float values than that, so merging their bodies does not let values stay
in registers — it forces them to memory. The call boundary is not the cost;
the register file is.

## 5. What this means for the plan

- C5 is **CLOSED NEGATIVE**. It is removed from the remaining-lever list.
- `docs/engineb/P8_PLAN.md`'s arithmetic loses its C5 term: the ladder's end
  point moves from ≈31,000 to ≈33,000 instructions per sample. The plan already
  did not promise the goal; it promises it slightly less.
- The remaining lever of any size is **C4 (fixed-point + PIE SIMD on the audio
  path)**, which is fork work, not trunk work.
- **The trunk is untouched.** No module was changed, no null was re-run,
  because nothing was adopted. That is the correct outcome of cost work that
  does not pay: a measurement and a closed door, not a rewrite.

## 6. The reusable lesson

Three of this project's cost models have now been corrected by measurement, and
all three erred in the flattering direction. Add this one to the list with its
specific shape: **a saving modelled from a mechanism's textbook cost is worth
nothing until the mechanism is measured on the actual target.** "Call overhead"
is expensive on a stack-frame machine and nearly free on a register-window one,
and the difference is the whole of C5.
