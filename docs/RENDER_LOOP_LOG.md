# RENDER_LOOP_SCOPE execution log

Executing `docs/RENDER_LOOP_SCOPE.md` STEP 0-6. Every claim labelled
PROVEN(executed under Unicorn) / READ(static decomp) / INFERRED.
Covenant intact throughout: no capture data enters any derivation.

---

## STEP 0 — Baseline — **DONE, GREEN**

- HEAD sha at scope start: **22be50c6a7cb86ade338fa5fcc712dd710b032fd**
  (branch `claude/c99-gui-fable5-yfhak1`, clean tree).
- `make verify` → **exit 0**. Highlights from the run:
  - DIFFERENTIAL FUZZ (SEAL 4 / Pillar-2b): 24 seeds, 0 diverged — GATE PASS
  - HOST-MODULATION: PROVEN (13416 comparisons, 0 mismatch)
  - completeness gate: GREEN — 0 GAP, 0 UNRESOLVED
  - all 8 DEFERRED-CONTROLLER rows proven not engine-reachable
  - provenance ledger: all rows PROVEN
  - completeness scan: OK (only pre-existing benign `captur*` comment warnings)
- Baseline log kept at `scratchpad/step0_verify.log` (session scratchpad).

---

## STEP 1 — Static map of the real per-block path — **IN PROGRESS**

### Confirmed entry points (PROVEN by dumping the engine vtable at rva 0x9df1d8)

| slot | offset | rva | role |
|---|---|---|---|
| 1 | +8 | 0x3C68D0 | BUILD |
| 3 | +24 | 0x3C7A20 | setSampleRate |
| **7** | **+56** | **0x3C7400** | **per-block render (pool dispatch)** |
| 10 | +80 | 0x3C7180 | (unidentified) |
| **13** | **+104** | **0x3C7230** | **called ONCE PER SAMPLE by voice 0 only** |
| 14 | +112 | 0x3C7AE0 | host param entry |
| 15 | +120 | 0x3C72D0 | noteOff |
| 16 | +128 | 0x3C7330 | noteOn |

### The real per-block structure (READ, decomp `sub_7FF91E027400` @ 0x3C7400)

1. lock(ENGINE+64)
2. for i in 0..7: resize the voice's 2 buffers to blockSize; publish buffer ptrs +
   blockSize into work item i; sync the assigner's voice count to `*(ENGINE+56)`;
   call `sub_7FF91DFB5AB0(assign[i], blockSize)`; then **if `i >= *(ENGINE+56)`
   → ZERO both buffers and DO NOT RENDER**, else signal the pool worker.
3. BARRIER — wait until all dispatched voices report done.
4. **MASTER per sample**: for each sample s, build a 16-entry ptr array from
   ENGINE+680 (stride 48, taking `(p-3)` and `(p)`) each advanced by 4·s, plus
   `{outL+4s, outR+4s}`, and call MASTER_WRAP `sub_7FF91DFF8EC0` (0x398EC0).
5. peak metering into ENGINE+32/+36 (audio-inert).

### The work item (READ, `sub_7FF91E026F00` @ 0x3C6F00; PROVEN layout)

Work item i base = **ENGINE + 1152 + 128·i** — PROVEN by
`probes/render_loop/workitem_map.py`: `item+24 == state[i]` for all i=0..7,
`item+8 == ENGINE`, `item+16` = shared completion counter.

```
for (i = 0; i < item[+48] /*blockSize*/; ++i) {
    VOICE_WRAP(item[+24] /*state*/, voiceIdx, &item[+32] /*main,sub*/);  // ONE sample
    item[+32] += 4;  item[+40] += 4;
    if (!voiceIdx) (*(ENGINE->vt + 104))(ENGINE);   // rva 0x3C7230 — VOICE 0 ONLY
}
```

### Equivalences already PROVEN

- `sub_7FF91DFB5AB0(assign, n)` body is exactly `*(assign+168) += n` — the
  oracle's hand-written counter bump (`e2e_emu.render` line ~345) is **exact**.
- Work-item state binding: voice i renders from unit i (`item+24 == state[i]`).

### Structural deltas found vs the hand-written oracle/port (under test in STEP 2)

1. **Voice-0-only per-sample call to 0x3C7230** — the oracle never calls it, the
   port has no equivalent. Body (READ): reads a value via
   `sub_7FF91E0210B0(*(ENGINE+88), 0, 29)` and pushes it into `ENGINE+1040`
   via `sub_7FF91DF84A30`. No unit-state write is visible in the decomp, so it
   is *probably* a meter feed — **being proven by execution (lane A)**.
2. **The `i >= *(ENGINE+56)` skip/zero gate** — the oracle always renders all 8
   voices; a probe read `*(ENGINE+56) == 0` after `build(48000)`, so the field
   must be set elsewhere in a real host lifecycle (lane B).
3. Master per-sample pointer-array construction order (lane C) and the noise
   block policy while playing (lane D) and the note terminus (lane E).

### STEP 1 side-quests — questions answered PROVEN while the lanes run

**Q3 (block-size invariance) — ANSWERED: INVARIANT.**
`probes/render_loop/blocksize_invariance.py`: the plugin's own DSP, same recall
+ note, rendered at block sizes **600 / 512 / 256 / 128 / 64 / 1** →
**bit-exact at every size** (0 differing samples of 12000, L and R, 44.1 kHz).
So the oracle's `block=600` is harmless and the port's sample-at-a-time driver is
structurally equivalent to any real host buffer size. Scope Q3 CLOSED.

**Master unit binding — CONFIRMED.** `probes/render_loop/master_unit_check.py`:
the real render calls `MASTER_WRAP(*(ENGINE+592), ...)` and `*(ENGINE+592)`
**== state[8]** exactly, which is what the oracle uses. The 8 buffer descriptors
at ENGINE+680 (stride 48) are 8 distinct `(main, sub)` pairs in voice order 0..7.

**Bank decode for the USER'S bank — PROVEN, and it was never checked before.**
BS Solid lives in a *third-party* bank (Chillwave), and every gate feeds both
sides the same decode, so a non-factory decode error would have been invisible.
`probes/render_loop/chillwave_decode_proof.py` drives the plugin's OWN record
parser (`sub_7FF91DF90ED0`) over all 64 Chillwave patches:
- Chillwave header is byte-identical to the factory bank in magic AND model tag
  (`KoaBankFile00003` / `PG-JU60`) → provably the same verbatim parser path.
- record == input body **byte-for-byte 64/64**; **0** leaf mismatches vs our
  `dec()` over 112 leaves × 64 patches. Decode PROVEN for the user's bank.

**The port's parameter mapping — INDEPENDENTLY CONFIRMED BY THE USER'S OWN GUI.**
Reading the plugin's own name table (rva 0x9a0030) instead of our labels, BS
Solid decodes to `DCO SUB LEVEL (772) = 83` and `VCF CUTOFF FREQ (779) = 15` —
**exactly the two numbers the user read off the real plugin's front panel.** An
independent, non-capture confirmation that the port recalls the right values.
(Also corrects two long-standing *label* errors in this project's notes: 770 is
`DCO PWM LEVEL`, not SAW; and `VCF ENV MOD` is 783, not 780 — 780 is
`(FILTER LPF TYPE)`. Labels only; the port binds by index and binds correctly.)

**BS Solid's real shape (plugin-parsed):** CUTOFF 15 (nearly closed) with ENV MOD
**215** and RESONANCE 86, ENV1 A18/D121/S23/R30; DCO PWM LEVEL 217 / SAW 197 /
SUB 83 / NOISE 73; EFFECT TYPE 2 depth 92, REVERB TYPE 2 level 78 time 161,
DELAY LEVEL 0, CONDITION 128. Its entire mid-band is produced by the filter
envelope sweep, which is why mid-band is the sensitive band for this patch.

**The last reconstruction (record-byte ↔ dispatch-index POSITION MAP) —
VALIDATED NON-CIRCULARLY.** `probes/render_loop/leafmap_rangecheck.py` checks
every decoded value against the plugin's OWN declared descriptor range
(rva 0x98c040+16·idx) over BOTH banks: **14335 / 14336 in range**. A shifted map
would have produced mass violations (enums receiving 217 etc.). It did not.

**The one real bug this surfaced (NOT the BS Solid bug):** the single
out-of-range value is `OCTAVE SHIFT` (disp 836, declared range **[-3,3]**,
i.e. SIGNED) decoding to **254** on Chillwave patch 53 — 254 is −2 as a signed
byte. Our decode returns unsigned 0..255, so signed-range leaves are mis-fed.
BS Solid's OCTAVE SHIFT is 0 (identity), so this does not explain the user's
report, but GOAL.md requires correct recall for ANY value → fix owed.

**The port's hand-written BINDINGS table — AUDITED CLEAN.**
`probes/render_loop/bindings_audit.py` cross-checks every row of
`src/juno_apply.c`'s BINDINGS against the plugin's own name table
(`disp = blob + 744`, verified on 6 independent anchors): **31/31 rows bind to
the correct parameter**. The single flagged row is a cosmetic label shortening
("LFO DELAY" vs the plugin's "LFO DELAY TIME"), same index 751.

**Delivery freshness — CHECKED.** `gui/web/juno.wasm` is newer than every
`src/*.c` and `git log 5fc3918..HEAD -- src/` is empty: the shipped WASM is
current with the sources (the user is not hearing a stale engine).
