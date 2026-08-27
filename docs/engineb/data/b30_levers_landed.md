# b30 — three headroom levers landed and proven (2026-08-27)

All three top-ranked b29 levers are in, each proven EXACTLY 0 on the shipping
fork by the new `tools/engineb/forkbit.py`, each with the guard its exactness
depends on made a hard compile error.

| lever | ~cyc/voice | proof |
|---|---|---|
| A/R/Rk dead in half-OS VCF | 30 | COMPILE-dead (the 4x arm already `(void)`-casts them); `make engineb` trunk byte-identical |
| dco_live analog fields dead under EB_DCO_WT | 30 | forkbit: 36 scenarios, 4,299,840 samples, 0 differing |
| **L-B** LFO tail at control rate (`EB_LFO_TAIL_CR`) | **90** | forkbit with `EB_SPLIT_TEST=7`: 0 differing; TOOTH goes RED at 2,909,156 |
| **L-A pt4** `set_pitch` at control rate (`EB_DCO_WT_LIVE_CR`) | **85** | forkbit: 0 differing; never-call tooth RED at 3,304,074 |

Estimated total: **~235 cyc/voice**, against a measured steady-state deficit of
~259 cyc/sample (b12/b15). Close enough that the board must now say whether the
VCA move is still needed at all — which is exactly what the staged flash asks.

## The tool that made it possible
`forkbit.py` — build the ship fork twice (lever kept alive vs shipping),
render the same scenarios, compare BYTE FOR BYTE. No dB threshold: these levers
assert EXACT equality. Seen to fail first at 2,185,503 differing samples.

## TWO GATE-REACH DEFECTS FOUND WHILE PROVING, both playbook 80 again

1. **The prologue is unreachable without `EB_SPLIT_TEST`.** L-B's first tooth
   run reported GREEN — a VACUOUS pass. The host path calls
   `eb_engine_render_shared` ONLY under `EB_SPLIT_TEST`; with `sh = NULL` the
   voice loop takes its own `v==0` arm and bypasses L-B entirely. With
   `-DEB_SPLIT_TEST=7` the tooth goes RED as it must.
   **RULE: any PROLOGUE-side lever must be gated with `EB_SPLIT_TEST` set, or
   it is gated by nothing.**

2. **The scenario battery has no fast pitch motion.** A deliberately WRONG
   period (NP+4) on the `set_pitch` gate also read 0 differing. So the battery
   cannot separate period 4 from period 8. The never-call tooth DOES go red, so
   the gate reaches the code — but this lever's proof rests on the CR-held
   construction argument (inc is read back byte-identical from `cr_inc`), which
   is scenario-independent, NOT on the battery having exercised a glide.
   **OWED: a glide/portamento scenario in `null_b`.** Its absence is a real
   hole for every future pitch-path lever.

## Guards added, because each lever borrows its exactness
* `EB_LFO_TAIL_CR` → `#error` unless `EB_CR_VCFCV/MODCV/ENV` are ON with EVEN
  periods. Its skip is exact only because every consumer reads on even cr_ph.
* `EB_DCO_WT_LIVE_CR` → `#error` if `EB_CR_LERP_PITCH` is ON (interpolated inc
  makes a frozen `set_pitch` a signed phase bias — a silent detune) or if
  `EB_CR_PITCH` is OFF (inputs not CR-held at all).

## Still owed on L-A
The 9-field recall copy is NOT gated: a recall landing mid-group would apply up
to `EB_CR_NP-1` samples late (b24's `latecopy`). Moving it into the seed block
is the rest of L-A, worth a little more, and needs the latecopy counter.

## Next
Flash and read `VPROF`/`MSPROF`/`B4dur`. The question the board answers: does
`quiet` now fit its 5,804 µs period, and do the four delay-t5 patches still
miss? That decides whether the VCA move (b26/b27) is needed at all.
