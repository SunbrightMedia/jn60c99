# Random full-state A/B — first findings (2026-08-13)

`tools/verify/random_state_ab.py`, 12 seeds, every recall leaf randomised,
port vs the plugin under Unicorn, whole render-visible state compared.

## Result: 40 cells differ, and none of them is inert

The control matters more than the number. `recall_fullstate_diff.py` was run on
FACTORY PATCH 0, which is render-bit-exact, and produced its own 32-cell
"differs anyway" set (the C++ object header and audited-inert FX defaults).

    random-gate differing cells                     40
    of those, also differ on a bit-exact patch       0
    REAL candidates                                 40

Zero overlap. Every one of the 40 is a genuine disagreement.

## Where they are

| region | cells | note |
|---|---|---|
| 6497168..6497488 | 18 | DELAY TYPE 5 / reverb-hosted time + fine-FX |
| 10692016..10693280 | 15 | CHORUS |
| 102528/102544/102592 | 3 | TYPE-0 delay: wet, block const, **mute/enable** |
| 91232 | 1 | chorus LFO / BBD ring |
| 101744 | 1 | aux one-shot |
| 10759488 | 1 | reverb |
| 11022052 | 1 | effect routing |

## What this confirms and what it adds

**Confirms issue 2 independently.** Cell 102592 (delay mute/enable) is in the
list, found from random parameters with no bank involved — the same cell the
user-bank hunt reached from the other direction.

**Adds two blocks that no bank had implicated:** the CHORUS (15 cells) and the
DELAY TYPE 5 / fine-FX block (18 cells). Both are FX recall — the derived layer,
not the transcribed DSP, exactly as predicted.

## Status of each

NOT ATTRIBUTED. Proven: the cells, that they are recall and not render, and that
they are not inert. The parameter combination that drives each is owed, and must
be DERIVED from the plugin's own dispatch — never fitted to these seeds.

## Method note worth keeping

12 seeds were enough to find 40 cells. The single-parameter exhaustive gate had
run every parameter at every value and found none of them, because each needs
two or more parameters set together. That is the whole argument for this gate.

## ATTRIBUTED (2026-08-13): DELAY TYPE is 39 of the 42 cells

Hold-out, seed 0. Coarse pass over 16 groups of 7: pinning group 15 to factory
values took the differing cells from 42 to ZERO; every other group left all 42.
Refine pass, each of those seven held alone:

| held at factory | cells still differing | so it causes |
|---|---|---|
| **DELAY TYPE (875)** | **3** | **39** |
| EFFECT TYPE (873) | 40 | 2 |
| REVERB TYPE (876) | 41 | 1 |
| HPF TYPE, FILTER TYPE, EFFECT TONE, REVERB TIME | 42 | 0 |

**One parameter causes 93 % of the disagreement.** DELAY TYPE selects WHICH
delay block the recall writes; for TYPE values the factory bank never uses, the
port writes a different block from the plugin. That is the same class as the
already-fixed fine-FX defect (fine-FX wrote to different cells depending on
DELAY TYPE) -- the class was known, one more instance was not.

It also explains the user-bank issue 2 exactly: cell 102592, the TYPE-0 delay
mute/enable, is set by the port for a patch where the plugin routes elsewhere.

### Confidence

- Holding ONE parameter fixes 39 of 42; holding four others fixes none.
- The gate returns 0 when 0 is correct (factory-value self-control).
- Two independent hunts -- the user's 768 patches and random seeds -- land on
  the same block.

### Owed

1. Derive the DELAY TYPE routing law from the plugin's own dispatch. NOT fitted
   to these seeds.
2. Fix `delay_recall.c` routing; re-run the random gate; expect 3 cells left.
3. Then attribute the residual 3, plus EFFECT TYPE (2) and REVERB TYPE (1).

## CORRECTION + the reachable defect (2026-08-13)

The DELAY TYPE sweep (`delaytype_sweep.py`, plugin dispatch, every other
parameter at a factory value) splits the finding in two:

| DELAY TYPE | cells wrong | occurrences in 832 REAL patches |
|---|---|---|
| 0 | **0** | 447 |
| 1 | 3 (102512, 102560, 4297808) | 188 |
| 2 | 4 (102528, 102544, 102576, 102592) | 45 |
| 3 | 4 (same) | 38 |
| 4 | 2 (102512, 102560) | 18 |
| 5 | 5 (+6497376) | 96 |
| 6..15 | 39 | **0 -- never occurs** |

**THE "39 OF 42 CELLS" HEADLINE WAS MISLEADING AND IS WITHDRAWN.** Those 39 come
from DELAY TYPE 6..15. The UI has six positions; 832 real patches (12 user banks
+ factory) contain only 0..5. That is a port/plugin difference on an input no
patch can carry -- worth recording, not worth prioritising.

**The reachable defect is smaller and worse.** EVERY DELAY TYPE except 0 writes
wrong cells: **385 of 832 real patches, 46 %**. TYPE 0 is exactly right, which
is why every earlier gate passed -- the factory bank is 70 % TYPE 0 and the
render A/B patches skew further that way.

Cell 102592 appears for TYPE 2/3/5, which is user-bank issue 2, from a second
direction.

### Method note
The random gate found the block; the SWEEP separated reachable from
unreachable. A random-parameter gate must always be followed by a reachability
check, or it will rank an impossible input above a defect half the patches hit.

### Fix attempt 1: FAILED (recorded, not hidden)

Hypothesis: `delay_recall.c`'s `if (dtype != 0) return;` suppressed the base
delay block for non-zero types.

Removed it, rebuilt, re-ran the sweep: **the differing-cell counts were
IDENTICAL** (TYPE 1:3, 2:4, 3:4, 4:2, 5:5). So that line is not the cause, and
the edit was reverted rather than left in the frozen port.

What this rules out: the base block is already reached for non-zero types by
another path. The wrong values therefore come from a LATER write that
overwrites it, or from the type-specific arms writing the same cells.

Next probe: find every writer of 102512/102528/102544/102560/102576/102592 in
the non-zero-type path, in order.

### DELAY TYPE 2/3/5: cause LOCATED (not yet fixed)

`delay_recall.c` returns EARLY for these types:

    if (dtype == 2 || dtype == 3) { apply_slot1_chorus(...); return; }
    if (dtype == 5)               { apply_slot1_reverb(...); return; }

so the base delay block (102512..102688, the `FILT[]` write) is NEVER reached.
The port leaves those cells at 0, except 102592, which keeps `FILT[]`'s 1.0 from
an earlier write.

The plugin DOES write a base block for these types. MEASURED by sweeping DELAY
TYPE with every other parameter at a factory value:

| cell | plugin (type 2/3/5) | port |
|---|---|---|
| 102528 | 0.0784313753 (= level/255) | 0 |
| 102544 | 1.30727255 | 0 |
| 102576 | 1 | 0 |
| 102592 | **0** | **1** |

102592 inverted is the audible one: the port MUTES the block the plugin leaves
enabled, and vice versa.

This also explains why removing `if (dtype != 0) return;` (fix attempt 1)
changed nothing: types 2/3/5 return long before that line.

⚠ NOT FIXED. 1.30727255 comes from ONE sweep point (all other parameters at
factory). Whether it is a constant or a function of another parameter is
UNKNOWN. Writing it as a constant now would be fitting to a measurement -- the
exact defect class this project forbids. The law must be derived by sweeping the
delay parameters AT type 2, the way the TYPE-0 laws were derived.

---

# 2026-08-14 — four laws derived, one applied, three still open

Four candidate laws were derived from the plugin's own dispatch and each was then
attacked by an independent agent. **Only one survived.** This section records what
landed, what did not, and the experiments that decide it. Nothing here is fitted
to a seed or a capture.

| block | verdict | action |
|---|---|---|
| `delay_14` (DELAY TYPE 1 / 4) | **SURVIVES** | APPLIED, see below |
| `delay_base_235` (DELAY TYPE 2/3/5 base block) | **REFUTED** | not applied, still open |
| `finefx` (out-of-range TYPE routing) | **REFUTED** | not applied, still open |
| `chorus` (EFFECT TYPE 1 / 5 wet+noise) | **no verdict returned** | not applied, unadjudicated |

## APPLIED: DELAY TYPE 1 and 4 — the two instances were inverted

The port applied the per-patch FEEDBACK and DRY laws to the **first** delay
instance, which the plugin never writes at TYPE 1/4, and gave the **second**
instance the captured constant `0x3ed8d8d9`, which the plugin drives per patch.

| cell | plugin | port before | port now |
|---|---|---|---|
| 102512 first DRY | never written — carries the previous patch | `direct/255` | no write |
| 4297808 second FEEDBACK | `f32(fb/255)*f32(0.9)`, ungated | constant `0x3ed8d8d9` | the law |

`0x3ed8d8d9` is `f32(120/255)*f32(0.9)` — the law evaluated at the engine's own
default feedback byte. **One capture cannot tell a constant from a law.** Sweeping
all 256 bytes can: the law is 256/256 bit-exact, the rival op chains score
180 / 203 / 209, and the divide in `f32(b)/f32(255)` beats the reciprocal
multiply 256 to 130.

**Gate numbers.** `delaytype_sweep.py`, all other parameters at factory:

| DELAY TYPE | 0 | 1 | 2 | 3 | 4 | 5 |
|---|---|---|---|---|---|---|
| before | 0 | **3** | 4 | 4 | **2** | 5 |
| after  | 0 | **0** | 4 | 4 | **0** | 5 |

TYPE 1 and TYPE 4 are **206 of the 832 real patches**. `make test` green,
`approx_audit` PASS, factory `recall_gate` PASS, render A/B **57/57 BIT-EXACT**.

## WHY EVERY EXISTING GATE WAS BLIND TO IT — the reusable lesson

Two measurements, both PROVEN(executed), and they matter more than the fix:

**1. The factory bank cannot see an FX law.** Histogram of the 64 factory records:

| DELAY TYPE | patches | DELAY FEEDBACK | DELAY DIRECT |
|---|---|---|---|
| 0 | 29 | 9 distinct values | 255 only |
| 1 | 17 | **120 only** | **255 only** |
| 2 | 10 | **120 only** | **255 only** |
| 3 | 4 | **120 only** | **255 only** |
| 5 | 4 | **120 only** | **255 only** |

Every non-TYPE-0 factory patch sits at fb=120 and direct=255 — *exactly* the two
bytes at which the wrong port agreed with the plugin. Render A/B was 57/57 before
the fix and 57/57 after it, and both are true. **A bank whose FX bytes are all at
the engine default is structurally incapable of separating a constant from a law.**

**2. `random_state_ab.py` cannot see it either, and its "44 cells" headline is
measuring something else.** `synth_bank` writes only the 112 value-tree leaves —
bank bytes 51..690. DELAY FEEDBACK (bank 3080/3081) and DELAY DIRECT (bank
3083/3084) are **never touched: both are 0 in all 60 seeds**. Worse, DELAY TYPE is
a random byte, so:

    seeds with DELAY TYPE 0..5 :  0
    seeds with DELAY TYPE >= 6 : 60

**All 60 seeds carry an out-of-range DELAY TYPE.** The 44 cells are therefore the
*unreachable* class (0 of 832 real patches), not a reachable defect count. The gate
number is unchanged at **44 -> 44**, and that is the correct, predicted result: the
edited code is never executed by any seed. It is not evidence the fix did nothing.

**Owed on the gate itself:** randomise the raw record bytes (fine-FX, feedback,
direct) and constrain switch leaves to their live ranges, or the gate will keep
ranking an impossible input above a defect that half the patches hit.

## THE GATE THAT DOES SEE IT: a warm patch-change chain

Cold gates cannot test a "the plugin does NOT write this cell" law — the claim is
about a *stale carry*, and a fresh engine has nothing to carry. So: ONE engine,
seven recalls, plugin (Unicorn) vs port (ctypes), two processes.
`scratchpad/wf_warm_{ref,port}.py`, pickle `wf_warm_chain.pkl`.

    step 0  TYPE 0  fb=37  dr=90   lvl=200   seeds the stale carry
    step 1  TYPE 1  fb=200 dr=10   lvl=200
    step 2  TYPE 4  fb=17  dr=240  lvl=200
    step 3  TYPE 1  fb=200 dr=10   lvl=1     below the level gate
    step 4  TYPE 4  fb=88  dr=3    lvl=0     below the level gate
    step 5  TYPE 1  fb=200 dr=10   lvl=200   back above the gate
    step 6  TYPE 0  fb=255 dr=0    lvl=200

Detector seen to fail first: flipping one bit of every expected value is caught
70/70 by the same comparison code.

| library | differing cell-steps of 70 |
|---|---|
| before the fix | **22** |
| after the fix | **10** |
| new regressions | **0** (the 10 are a strict subset of the 22) |

The plugin holds `102512 = 0.352941185` and `102560 = 0.130588233` from step 0
across a TYPE-1 *and* a TYPE-4 recall, then re-carries the next pair at step 6.
The port now reproduces that exactly.

## STILL OPEN 1 — the level gate at TYPE 1/4 is NOT derived (found by the chain above)

The `delay_14` write-up also claimed `102560 = 0` and `102576 = 0` below the level
gate (DELAY LEVEL < 2). **My warm chain refutes that half**, and it is the reason
the 10 residual cell-steps remain:

| step | cell | plugin | port |
|---|---|---|---|
| 3 (TYPE 1, lvl 1) | 102560 | **0.130588233** (stale from step 0) | 0 |
| 3 | 102576 | **1.0** | 0 |
| 4 (TYPE 4, lvl 0) | 102560 | **0.130588233** (stale) | 0 |
| 5 (TYPE 1, lvl 200) | 102560 | **0.130588233** (still stale) | 0 (self-poisoned) |

So the plugin does **not** write 102560 or 102576 at TYPE 1/4 in either gate
direction. The `= 0` seen on a **cold** engine is an ORDER artefact: `prepare_recall`
dispatches DELAY LEVEL (796) before DELAY TYPE (875), so on a fresh engine the level
leaf fires while the routing int still holds 0, and the **TYPE-0** arm writes the
zero. Once the routing is already 1 or 4 from a previous patch, no zero appears.

This zero write is **pre-existing** — it was in the port before this change and all
10 residual cell-steps are also in the old library's 22. It was NOT introduced here
and is NOT removed here, because removing it is a new law and no sweep has derived
it. Status: **NOT DERIVED.** Deriving it needs the dispatch-order question answered,
not another cold sweep.

**New cell, also not derived:** at step 4 (TYPE 4, LEVEL 0) the plugin writes
`4297808 = 0` — a second-instance cell that the TYPE-4 arm otherwise never touches.
One point. Not a law. Recorded so it is not lost.

## STILL OPEN 2 — DELAY TYPE 2/3/5 base block (`delay_base_235`): REFUTED

Claimed: at TYPE 2/3/5 the plugin writes `102528 = LEVEL/255`,
`102560 = LEVEL>=2 ? 0x3ed8d8d9 : 0`, `102576 = LEVEL>=2`, `102592 = 0`, plus the
TYPE-1 rate arm at 102544.

**Refuting experiment (PROVEN):** the 530 runs behind the law all used a fresh
engine and one leaf order, and both are load-bearing. On one engine, TYPE 2,
LEVEL 255, 44.1 kHz:

| dispatch order | 102528 | 102560 | 102576 |
|---|---|---|---|
| post-build, no recall at all | 0 | **0.423529416** | 0 |
| normal order (= `prepare_recall`) | 1 | 0.423529416 | 1 |
| FEEDBACK leaf dispatched **first** | 1 | **0.899999976** | 1 |
| DELAY TYPE leaf dispatched **first** | **0** | 0.423529416 | **0** |

`0x3ed8d8d9` is the engine's pre-recall default, not a gated constant, and a
patch-change chain leaves it **stale** (T0 fb=76 -> T5 gives 0.268235296). Only
`102544` (rate arm) and `102592 = 0` were written in every order and history.
Writing the claimed constant would make the cold gate green while encoding a number
the plugin produces only from a fresh engine in one leaf order — the CAPTURED
defect class, one level deeper.

Also refuted: "one law, no difference between the three". TYPE 5 needs
`6497376 = f32(fb/255)*f32(0.9)` (**not** level-gated) and `6497392 = LEVEL>=2`;
TYPE 2/3 need `6396432 = min(LEVEL*32,255)/255`, which lies in a hole in
`recall_fullstate_diff.REGIONS` (6396128..6396620 is skipped) so **no gate can see
it**. Surviving and reusable: `102528 = f32(v)/f32(255)` (division, 130/256 for the
reciprocal multiply), and the general rule that **the active slot-1 instance carries
the feedback law while the base block does not** — the same rule the applied fix
encodes at TYPE 1.

## STILL OPEN 3 — out-of-range TYPE routing (`finefx`): REFUTED

Claimed: for DELAY TYPE >= 6 the plugin does not dispatch the routing at all, so the
whole 6497xxx / 10692xxx / 10693xxx block keeps its previous values.

**Refuting experiment (PROVEN):** one engine, identical leaf set, only blob 634
changes. `634=5 -> 634=5` moves 0 cells (null-step control); `634=5 -> 634=189`
moves **5**: 101744, **6497360**, **6497408**, **10693280**, **10693328** — four of
them inside the blocks claimed untouched, three of them read by `master_render.c`.
The behaviour is state-dependent (cold 189 gives 6497360 = 0; warm-after-5 gives the
ARM_LFX1 rate arm), so no single-value law covers it. A "skip instead of clamp" fix
would therefore be wrong. Also missed: `10759840` differs for **every DELAY TYPE
except 5** (736 of 832 real patches), 16 bytes past the end of the sweep's own
window; it is render-inert today.

Sub-claims that survived the attack and are cheap to pick up later, each PROVEN:
`6497376 = f32(fb/255)*f32(0.9)` (CAPTURED constant in the port, real and
reachable — this is the TYPE-5 cell in the sweep table above); REVERB TYPE >= 6
**aliases to TYPE 4**, so `reverb_recall.c`'s `type > 5 -> 5` must be `-> 4`;
EFFECT TYPE >= 6 is not written; `101744 = (DELAY TYPE <= 5)`, not level-gated.

## STILL OPEN 4 — chorus: no refutation verdict was returned

The chorus block (EFFECT TYPE 1 gets no Wet write; EFFECT TYPE 5 must not write
Noise) was **never adjudicated**. It is not applied. An unrefuted law is not a
surviving law — the whole point of the two-agent method is that three of the four
derivations here were wrong in a way their own author could not see.

## Method note worth keeping

Every one of the three refutations turned on the **same** axis: the derivation
tested a cold engine in one dispatch order, and the plugin's real behaviour depends
on history and order. A recall law of the form "cell X = f(params)" is not proven
until it has been driven from a **warm** engine whose previous patch left a
different value in X. Cold sweeps prove what is written; only a patch-change chain
proves what is *not*.

# 2026-08-15 — FIRST RUN WITH PROVEN SEEDS (plugin-derived ranges)

The generator was rebuilt (commit 88d4c0f): each recall byte's legal range is
derived FROM THE PLUGIN by `tools/verify/leaf_ranges.py` (full-state hash,
binary-searched clamp point, boundary verified per byte), and the two non-leaf
recall bytes 3057 (DELAY FEEDBACK) / 3060 (DELAY DIRECT) are now randomised too.
Coverage proven over 100 seeds before running. 30 seeds (100..129), all
reachable by construction.

RESULT: **42 differing cells**, cleanly attributed by per-seed correlation
(every failing seed decoded, classes vs FX-type bytes — no hold-out needed):

| class | cells | correlates with | status |
|---|---|---|---|
| base block 102528/44/76/92 | 4 | DELAY TYPE ∈ {2,3,5,6}, all 19 such seeds, none other | KNOWN cause: early return in delay_recall.c (~line 435). UNFIXED |
| fine-FX 6496480.. (18 cells) + chorus 10691936.. (15) + aux 101744 + route | 35 | DELAY TYPE = 6 EXACTLY (4/4 seeds, no others) | **NEW DEFECT: the plugin has SEVEN delay-type classes (0..6). leaf_ranges proved state(6) != state(5). The port clamps >5 to 5.** |
| finefx single cell 6497376 | 1 | DELAY TYPE = 5 | known CAPTURED-constant cell (fb law at type 5) |
| BBD ring 91200/91232 | 1–2 | NOT yet attributed (crosses delay types; suspect chorus LFO phase vs a leaf) | OPEN |
| route 11022040.. | 1 | EFFECT TYPE = 6 and DELAY TYPE = 6 seeds | matches "REVERB/EFFECT TYPE >= 6" class above |

The dtype=6 finding is exactly what the proven seeds were for: the old
generator hid it inside the unreachable-corner noise; the patch-pool picker
would NEVER have drawn 6 (no factory or user patch uses it); the plugin's own
clamp point says 6 is a distinct, reachable class.

Labels: DELAY TYPE 7-classes = PROVEN(executed, leaf_ranges boundary probe +
4/4 seed correlation). Base-block cause = PROVEN located, law not yet derived.
BBD = INFERRED, open.

# 2026-08-16 — THE SEED CLASSES ARE CLOSED EXCEPT ONE

Scoreboard, 30 legal seeds (200..229), `random_state_ab.py --port 30 --start 200`:

| class | cells | seeds | state |
|---|---|---|---|
| chorus WET 91232 / NOISE 91200 | 2 | — | FIXED (warm, prev effect type) |
| delay base block 102528/44/76/92 | 4 | 19/30 | FIXED (written for every type) |
| feedback capture 6497376 | 1 | 11/30 | FIXED (the law, not the capture) |
| EFFECT TYPE >5 routing 11022052 | 1 | 7/30 | FIXED (no store) |
| **DELAY TYPE >= 6** | **39** | **3/30** | **OPEN — see below** |

40 -> 39 cells, and every remaining cell now appears on EXACTLY the three seeds
that carry DELAY TYPE >= 6 (214, 219, 221). One class remains.

## Why the factory bank could never have found two of these

* All FOUR factory DELAY TYPE 5 patches carry DELAY FEEDBACK **120**, and the
  frozen constant `0x3ed8d8d9` in `S1REVERB[]` IS the law evaluated at 120.
  Every factory patch agreed with the capture by construction.
* **No factory patch has EFFECT TYPE above 5** — histogram {1:1, 2:33, 3:22, 5:8}.
  The clamped store could never diverge there.

Neither is a gap in the render A/B. Both are the same lesson as the warm
defects: a sample cannot test a law it never varies.

## DELAY TYPE >= 6 — DEFERRED, DELIBERATELY, WITH THE REASON WRITTEN DOWN

**Mechanism (derived 2026-08-15, largely survived refutation).** The plugin
treats 6/7/15/255 as ONE SEVENTH CLASS whose whole state differs from type 5.
The slot-1 type setter always turns the LIVE block off (its LFX1 cell <- the
rate arm 0x3fa754b5/0x3f9bd7ca/0x3f2493b7, its ENABLE <- 0.0f); for type <= 5
it then builds the new block and writes the routing int; at type >= 6 it
instead writes 101744 (DLY Mute) <- 0.0f and **does not write the routing int
at all**, so that cell keeps the previous patch's type. The port clamps 6 to 5
and builds a reverb.

**The clause that was REFUTED, and must not be re-inherited.** "Nothing else
happens at type >= 6" is FALSE. DELAY LEVEL (blob 104) and DELAY TIME (106)
dispatch BEFORE the type leaf (875), so they land on the still-live block and
the recall REWRITES the previous block's per-patch cells with the NEW patch's
bytes before tearing it down. Any fix must be a BRANCH, never an early
`return` before the common writes.

**FIXED 2026-08-16, and the reachability argument was answered by an artifact
we already had.** `tools/verify/leaf_ranges.py` derives each recall byte's range
by sweeping it through the plugin under Unicorn: blob 634 (DELAY TYPE) has
top = 6, meaning `state(5) != state(6)` and every value >= 6 equals
`state(255)`, each edge checked by the tool's own tooth. So the seventh class
is the PLUGIN's own, not an artifact of the generator, and the random gate
draws it legitimately. The earlier sessions treated reachability as an open
research question while the answer sat in the range pickle.

**The law, measured against the plugin's post-recall states** (reference
pickles, seeds 214/219/221 — three INDEPENDENT random states drawing type 6).
All three give the IDENTICAL 39-cell set and the plugin's value is ZERO in
every cell:

| cells | what | plugin |
|---|---|---|
| 6496480..6497500 (20) | reverb block | never built |
| 10691936..10693360 (17) | reverb 2nd block | never built |
| 101744 | DLY Mute | 0.0f — slot 1 SILENT |
| 11022056 | routing int | NOT WRITTEN, keeps previous type |

The port clamped 6 to 5 and built a whole reverb. It now branches.

**The branch is two-sided, and that was proven, not assumed.** The plugin DOES
still write 102352 (delay time) at type 6, with a per-seed value
(3e215fc1 / 3e93659a / 3ff23ba0 across the three seeds). Level and time
dispatch BEFORE the type leaf, so they land on the still-live block whatever
the type. An early `return` ahead of the common writes would have traded 39
wrong cells for a different wrong cell. The ring-geometry ints stay on the
common path for the same reason.

**Seed gate: 0 differing cells at 30 seeds, and the sample was then widened.**

**Also still open, unrelated to the seeds:** ASSIGN MODE 3 (22 user-bank
patches, proven reachable, `docs/ASSIGN_MODE_3_FINDING.md`).
