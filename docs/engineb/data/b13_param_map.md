# b13 — O3 step 1: the parameter map, and a false negative in the repo's own scan

Host measurements, 2026-08-19. Harnesses `tools/engineb/devboot/parammap.c`
and `tools/engineb/devboot/paramwarm.c`. Every number PROVEN(executed).

## 1. How much one knob moves

Decision rule stated in the harness header BEFORE the run (playbook 11b):
F = median (coefficient bytes moved) / (struct bytes). F<10% build the map;
F>50% reuse O2's chunked rebuild; 10-50% split.

    eb_render_coefs 10,564 B + eb_master_coef 1,712 B = 12,276 B
    parameters that move any coefficient   57
    median moved     32 B    0.261%
    worst  moved    259 B    2.110%   (record 650, DELAY TYPE)
    buckets     <1%: 56    1-10%: 1    >10%: 0

**F = 0.26%: BUILD THE MAP**, with 38x margin on the rule's own threshold.

⚠ **THESE COUNTS ARE A FLOOR, NOT THE FINAL MAP.** They come from the first
`parammap` run, whose base set and value list were later found to under-report
(§3). The re-run is exhaustive — all 256 pair values, all 256 values of each
byte alone, 13 bases — and takes its position list from the fixed discovery
scan. It can only ADD parameters and bytes, never remove them.

**The DECISION does not depend on the correction.** The rule's threshold is
10%; the worst parameter measured is 2.11% and the median 0.26%. The additions
are ASSIGN MODE and three CHORUS records, whose moved-byte counts are 4-24
bytes of master coefficients — an order of magnitude below the threshold. No
plausible correction moves F to 10%, so "build the map" stands on the floor
alone. The exact per-parameter table is what the re-run settles.

### The structure is binary, with nothing in between

| class | n | moved bytes min/median/max |
|---|---|---|
| per-voice | 37 | 16 / 32 / 104 — all eight voices |
| shared / FX / master | 20 | 4 / 12 / 259 — no per-voice byte |

**No parameter touches a SUBSET of voices.** O2's per-voice lever therefore
buys a parameter refresh nothing; field narrowing buys it everything. That is
why O3 is a different mechanism and not a reuse of O2.

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
