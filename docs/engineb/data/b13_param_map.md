# b13 — O3 step 1: the parameter map, and a false negative in the repo's own scan

Host measurements, 2026-08-19. Harnesses `tools/engineb/devboot/parammap.c`
and `tools/engineb/devboot/paramwarm.c`. Every number PROVEN(executed).

## 1. How much one knob moves

Decision rule stated in the harness header BEFORE the run (playbook 11b):
F = median (coefficient bytes moved) / (struct bytes). F<10% build the map;
F>50% reuse O2's chunked rebuild; 10-50% split.

    eb_render_coefs 10,564 B + eb_master_coef 1,712 B = 12,276 B
    parameters that move any coefficient   59
    median moved     32 B    0.261%
    worst  moved    471 B    3.837%   (record 650, DELAY TYPE)
    buckets     <1%: 58    1-10%: 1    >10%: 0

**F = 0.26%: BUILD THE MAP**, with 38x margin on the rule's own threshold.

FINAL, from the exhaustive re-run: 13 bases, all 256 pair values and all 256
values of each byte alone, over the 114 positions the fixed discovery scan
names. It supersedes the first run (57 parameters, worst 2.11%), which
under-reported for the three reasons in §3. **The median did not move at all**
and the worst rose to 3.84% -- still under half the threshold, so the decision
never depended on the correction.

### The structure -- AND A CLAIM THE RE-RUN OVERTURNED

| voice mask | n | meaning |
|---|---|---|
| all eight | 36 | per-voice parameters |
| none | 22 | shared / FX / master only |
| **voices 1-7** | **1** | **ASSIGN MODE (record 128/129)** |

The first run said "**no** parameter touches a SUBSET of voices", and that was
an artefact of the parameter it had missed. ASSIGN MODE is the exception:
`juno_apply_unison_spread` writes all eight voices, but `UNISON_3968[0]` is
zero and so is the non-unison value, so voice 0 never moves. One parameter of
59, and it is precisely the one the old probe could not see.

The design consequence is unchanged. 58 of 59 parameters are all-voices or
no-voices, so narrowing by VOICE is still worthless and narrowing by FIELD is
still everything. But the flat statement was wrong and is corrected here rather
than quietly dropped.

### ⚠ BYTES ARE NOT CYCLES — the inference NOT made here

Scaling 1.25 M cycles by 32/12,276 gives "~3,300 cycles". **That arithmetic is
wrong.** 1.25 M over ~3,000 floats is ~400 cycles each, which no load-store
pair costs, so the build is not a copy: `eb_coefs.c` has 127 arithmetic sites
and `eb_env_set_rate_consts`, `eb_modcv_set` and the VCF cutoff CV's derived
form all COMPUTE. The cost of refreshing a field is the cost of the sub-builder
that produces it, and one sub-builder may produce many fields for one price.
**The cycle cost of a mapped refresh is UNMEASURED.** The byte fraction proves
the map is worth deriving; it says nothing yet about what the refresh costs.

## 2. Is an incremental edit legal? (paramwarm.c)

This outranks §1: a cheap refresh that computes the wrong coefficients is not a
cheap refresh. The doubt is the repo's own, in `engine_b/dev/eb_devseq.h` —
cold recall is "wrong for one that must imitate a DAW's live parameter edits...
this decision has to be REVISITED, NOT INHERITED." O3 is that arrival.

COLD (reseed, install P', recall) vs WARM (reseed, install P, recall, then
install P' WITHOUT reseeding), P' being P with one parameter moved:

    parameters probed              2,040
    parameters where WARM != COLD      4

| record | what | cells differing | settles on repeat? |
|---|---|---|---|
| 116 | chorus-region latch (cell 91232) | 1 | YES |
| 120 | delay-region latch (cell 102528) | 1 | YES |
| 634 | **EFFECT TYPE** → `JUNO_PREV_EFX` | 1 | YES |
| 650 | **DELAY TYPE** → `JUNO_PREV_DLY` | 46 | YES |

`src/juno_apply.c:821-822` stores EFFECT/DELAY TYPE as PREVIOUS values;
`src/chorus_recall.c:54` and `src/delay_recall.c:594` read them to detect a
TYPE TRANSITION. The divergence is the plugin's intended behaviour.

**All four are LATCHES** — proven by applying the same edit twice and finding
zero cells still moving. None is an ACCUMULATION, the class that would have
made an incremental path impossible.

**Verdict: the incremental path is legal.** For 2,036 of 2,040 parameters a
live edit lands exactly where a cold recall would. For the four, WARM is the
CORRECT answer for a live knob move — the plugin never reseeds either — and
COLD is correct only for a program change, which is what the device does.

## 3. ⚠ THE FALSE NEGATIVE IN `--patch-scan`, AND THE TRAP IT SET

Corroborating parammap against the proven `EB_RECALL_POS[]` showed a
disagreement, so the repo's own scan was re-run. It reported:

    RECORD SCAN: 108 of 4080 positions change the recalled coefficients
    *** EB_RECALL_POS[] IS STALE: measured 108, listed 112 ***
        only listed:   [3092, 3286, 3287, 3288]

**The scan was wrong, and the table was right.** Records 3286-3288 are CHORUS
PRE DELAY / LOW CUT / HIGH CUT. Perturbed on FACTORY patches over all 256
values they move `eb_master_coef` by:

| record | patches 21, 28, 35, 49, 56 |
|---|---|
| 3286 | 4 bytes |
| 3287 | 5 bytes |
| 3288 | 24 bytes |

### The mechanism, and it is the cruel part

Those parameters reach the coefficients only when EFFECT TYPE selects their
block — true on factory patches 21, 28, 35, 49, 56. The scan's six bases were
factory 0, 7, 14 plus **randomised copies of 21, 28, 35**. It randomised
precisely the three bases that would have shown it, destroying on them the one
condition that mattered; the surviving factory bases do not select that effect.

**The randomisation added to broaden coverage is what blinded it.**

### The trap

The gate is RED right now and its verdict is a false alarm. Acting on it —
deleting four bytes from the compact patch format — would silently drop three
real parameters. That is precisely the failure `eb_patch.h` exists to prevent:
"a byte set derived by probing is only as complete as the probe."

### The fix, applied

`scan_section()` now uses THIRTEEN bases: ten UNTOUCHED factory patches
(0, 7, ... 63) covering the bank's effect and delay types, plus three
randomised copies of patches 3, 10, 17 — chosen so randomisation never lands
on a factory base the scan relies on. Randomised bases are now ADDITIONAL,
never substitutes. The patch index is carried in `bpat[]` rather than
recomputed as `b*7` at the call sites.

### The fixed scan's verdict — AND NO FORMAT DEFECT

    RECORD SCAN: 114 of 4080 positions change the recalled coefficients
    *** EB_RECALL_POS[] IS STALE: measured 114, listed 112 ***
        only measured: [128, 129, 134]
        only listed:   [3092]

3286-3288 are now found, so the fix works. The three NEWLY measured positions
are records 128, 129 (ASSIGN MODE — `juno_bank_assign` reads blob 112/113) and
134.

**All three are already CARRIED by the compact format** (`eb_patch_offsets`
holds blob 112, 113, 118), so the format is NOT short and no parameter is being
dropped. Only `EB_RECALL_POS[]`, the assertion list, is out of date. That is
bookkeeping, not a lost parameter — the distinction that decides whether this
is urgent, and it is not.

### ⚠ A THIRD PROBE DEFECT, in this harness, of the same family

`parammap.c` did NOT find ASSIGN MODE either. `juno_apply_unison_spread` acts
only when `assign == 2`, so that parameter is live at **one value out of 256**,
and a 12-value sampled list that omits 2 cannot see it. The three defects in
order:

1. both nibbles written from one probe value — 4 reachable values of 256.
2. randomised bases destroying the effect-type condition (playbook 65).
3. a sampled value list missing the single value a parameter responds to.

All three under-report, which is the dangerous direction, and all three were
found by CORROBORATION rather than by reading code. The answer to the third is
to stop sampling: a nibble-packed parameter's value is 8 bits, so 256 is the
whole space. `parammap.c` now sweeps all 256 pair values AND all 256 values of
each byte alone (a direct-copy byte would otherwise only ever see 0..15), over
the same 13 bases, and takes the position list FROM the discovery scan rather
than rediscovering it — two answers to one question is how they drift apart.

### Still open: record 3092

3092 moves no coefficient on any of the ten factory patches at any of 256
values, and neither scan's randomised bases moved it either. It is
NOT yet demonstrated dead — a parameter can be one factor of a product no
probe has set (the BEND GAIN trap, `eb_patch.h`). It is recorded as
UNRESOLVED and nothing has been removed from the format on its account.

## 4. What O3 becomes

**Full apply + mapped gather.** Re-run `juno_bank_apply` over the edited
record, then gather only the mapped fields. §2 validates exactly this shape,
because that is literally what its WARM path executed.

**The open cost question, with Fable 5's constraint attached.** The apply half
is ~0.24 M cycles (the burst split, measured on silicon) ≈ 1 ms at 240 MHz.
Run every block during a knob sweep, that adds ~1 ms to a block b12 measured
already 197 µs over period — five times what a note step costs, and not
acceptable while O4 is open. So O3 phase 2 must narrow the apply with a second
derived map (parameter → cells) or rate-limit the refresh, and that choice
needs the apply measured on its own, not inferred from a burst split.

**The playbook-62 obligation.** Two state machines exist and both had the same
hand-over defect. A third must be built to the same contract from the first
line: `step()` returns 0 to ASK for a publish and does NOT advance; the caller
calls `published()` only when the publish really happened. The interlock
becomes one-shadow-one-owner across THREE machines.

## 5. The cell map — how much of the apply an edit actually needs (cellmap.c)

b13 §1 measured the GATHER half and found it tiny. This measures the APPLY
half, which dominates it: ~0.24 M cycles on silicon, ~1 ms at 240 MHz, on a
block b12 measured already 197 µs over period. Narrowing the gather buys
nothing while the apply costs that.

    FULL RECALL writes            2,807 cells
    one parameter writes    min 1   median 8   max 113
    58 of 59 parameters write under 50 cells

    REDUNDANCY  R = full / per-parameter
      median R = 351x
      worst  R = 24.8x   (record 650, DELAY TYPE)

**The apply is almost entirely recomputation the edit did not need.** Even the
worst parameter needs 4% of it; the median needs 0.3%.

### ⚠ THE PRIZE IS LARGE AND SO IS THE PRICE — a cost b13 §4 failed to state

b13 §4 offered "narrow the apply with a second derived map" as one option
beside rate-limiting, as though the two were comparable in risk. **They are
not, and that should have been written down when the option was.**

`src/` is the FROZEN bit-exact port. `juno_bank_apply` is transcribed plugin
code, `make verify` is its finish line, and `approx_audit.py` enforces ZERO
approximations in it every run. Decomposing it per parameter means rewriting
the one part of this repo that is proven.

So the measurement says the prize is 351x and the constraint says the price is
the port's proof. **That is a scope decision for the user, not an engineering
preference to be settled here.** It is recorded and not acted on.

### What ships without that decision

**Full apply + mapped gather, rate-limited.** Touches nothing in `src/`.
Refresh rate = 172/N Hz for one refresh every N blocks. The mapped gather is
already justified by §1 and costs almost nothing; the apply sets N.

The alternative that needs no new machinery at all is to drive the existing
note machine (`eb_notestep.h`) with `touched` = all voices and `voiced` = the
SOUNDING voices, so the knob reaches what the player hears in 2 blocks via the
proven split publish. That is one note build per refresh: ~11 blocks, ~16 Hz.

### ⚠ THE RATE CANNOT BE JUDGED THE USUAL WAY

16 Hz is audibly stepped on a filter sweep; 172 Hz is smooth; 43-86 Hz is the
interesting middle. **END_GOAL forbids validating by ear and forbids asking the
user to A/B**, so "is 43 Hz smooth enough" cannot be settled by listening.

What CAN settle it: render the same knob sweep through the PLUGIN and through
the port at each N and compare. The plugin re-reads its cells every sample, so
the residual against it IS the zipper — measured, not heard. **That gate does
not exist yet, and it is what O3 phase 2 needs before any N is chosen.**

## 6. The zipper, measured (zipper_gate.c)

END_GOAL forbids picking N by ear. The gate renders the SAME knob sweep twice
through the trunk's proven render path (src/ port + standalone shim, the pair
`make engineb` nulls EXACTLY 0): reference = re-applied every block (N=1, the
finest update the O1 queue can deliver), candidate = re-applied every N blocks
with the value HELD between — exactly the rate-limited refresh. The residual
IS the zipper.

The curve, patch 5, record 92, 2-second full-range sweep over a held chord:

| N | rate | residual vs N=1 |
|---|---|---|
| 1 | 172 Hz | EXACTLY 0 (the self-null) |
| 2 | 86 Hz | −54.4 dB rel |
| 4 | 43 Hz | −40.6 dB rel |
| 8 | 22 Hz | −38.0 dB rel |
| 11 | 16 Hz | −35.8 dB rel |
| 22 | 8 Hz | −30.0 dB rel |

Monotonic, as the structural check requires. **The gate does not pick N** —
the acceptable point on this curve is the user's number (F2 is the only
remaining judge). What the curve already shows: N=2 is 19 dB cleaner than
N=11, so a rate limit of every-2-blocks (86 Hz) — which the apply can afford
where every-block cannot — buys most of what per-block would.

### The gate was seen to fail, three times, for real

No planted teeth were needed — the structural checks caught three genuine
defects during bring-up, which is a stronger demonstration than a plant:

1. **Self-null failed at +2.4 dB**: engine B's static render state carried
   from one sweep into the next. Fix: `ebsh_new_context()` per sweep.
2. **Self-null failed at −6.8 dB**: the sweep mutated the bank and never
   restored it, so each sweep booted from the previous sweep's final knob
   position — a cold recall at value 255 followed by a block-0 step to 0.
   Fix: the sweep writes its own starting value before the boot recall.
3. **Three of four parameters were INAUDIBLE** — zero differing samples at
   every N, because this driving never renders what they move (an envelope
   rate after the attack has passed). A −999 dB curve is not "no zipper", it
   is "the measurement cannot see its subject". The gate now FAILS on it
   (exit 1) instead of reassuring. Per-parameter drivings are owed before the
   curve is claimed for any parameter but the ones measured audible.
