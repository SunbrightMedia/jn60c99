# NEXT — where Track B stands and what to do first

*Written 2026-07-31 at the end of the harness session. Supersedes nothing; it is
the resume note for `docs/trackb/PLAN.md`.*

## State

**Bit-exact engine: sealed and shipped.** `make verify` GREEN end to end
(EXIT=0), assigner 34/34 including the seed-15 warm MONO case, ARM proof folded
in. WASM rebuilt and republished, 8/8 bit-exact vs native — the published artifact
had predated the MONO retrigger fix.

**Track B: harness complete, ZERO voice code rewritten.** `native/voice_render.c`
is still a verbatim fork; the passthrough null is EXACTLY 0. Four gates exist
(`tools/trackb/`, see its README) and the EQUIVALENCE ledger has one row: M0, the
harness itself.

## Do this first — the module order is unresolved, and PLAN §3 is wrong about it

PLAN §3 orders modules by blueprint certainty, then carried-state fraction, then
blast radius, and puts **M1 first** on the grounds that its math is trivial so
"any failure is certainly the harness". Measurement contradicts that:

| range | what | canary observable |
|---|---|---|
| `:654-693` (M1a, in scope) | conditioner + gate | **6 / 25** |
| `:1129-1149` (M1b) | noise SVF + source mix | 14 / 18 *(after adding the patch-32 scenario; 3/18 before)* |

Most of M1a is not merely untested but **genuinely insensitive**: the gate cell
560 feeds a clamped path — multiplying it by 3 changes *nothing*, adding 1 changes
83 996 of 84 000 samples. A module whose null stays green whatever you write into
it is the worst place to start, not the best.

PLAN's M1a range `:623-693` also overlaps the shared noise LFSR at `:595-653`,
which the same document puts out of scope. The in-scope range is `:654-693`.

**So: survey canary observability across all seven module ranges and let that
pick the order.** The command per range is

    python3 tools/trackb/canary.py --lines A-B --max 14

Do **not** pipe it through `tail -2` — the summary line is third from the end, and
a throwaway wrapper that did exactly that produced a survey with no numbers in it.
Ranges to survey: `654-693`, `1129-1149`, `964-1021`, `1022-1075`, `1516-1640`,
`1076-1128`, `1150-1229`, `1298-1400`, `1718-1830`. Roughly 25 minutes total.

Start with the highest-observability module, not the simplest one.

## Open, and named rather than forgotten

* **Four blind lines in M1b are not a coverage hole:** `:1143/:1146/:1147` write
  cells 6464/6480/6496, which have **zero readers** anywhere in `voice_render.c`
  or `master_render.c`; `:1132`'s store to 4304 is overwritten at `:1134` before
  the next sample's read at `:1130`. Write-only shadows — droppable under a
  sonic-identity claim, **not** under the bit-exact one. They belong in the
  ledger's `state_parity` column.
* **UNEXPLAINED, do not paper over:** the `DCO noise` scenario (patch 32) does not
  catch the `nochorus` or `tailquiet` mutations. Patch 32 carries EFX routing 2 —
  the same as patch 5, which *does* catch `nochorus` — so the obvious explanation
  is wrong and no substitute has been established. Recorded in `null_ab.py`'s
  `EXPECT` table as a measured fact.
* **From PLAN §6, still open:** F4 spectral metric, F6 branch coverage, F9 teeth
  over the bulk gates, F10 per-module mutations, F12 silent-count baseline, F15
  ARM null, F16 optimization levels, F17 FTZ, F19 three-run determinism.
* **PLAN's stop rule S1 has not been evaluated** because it needs hardware: if the
  P1 silicon numbers show `F + 8V` fits the Teensy budget, or a bit-exact 4-voice
  Daisy is acceptable, Track B is abandoned in favour of fewer voices. **There is
  still no SILICON number**, and the standing rule is that no module may be
  written on a MODELED one.

## The five defects the harness found in itself

Kept because they are the transferable lessons, and because each was found by
*running* the tool rather than reading it.

1. A multiplicative-only perturbation cannot move a cell holding `0.0f`, so every
   at-rest-zero cell read "safe to hold in a register" whether it was or not —
   the dangerous direction. Cell 320 flipped to CARRIED once fixed.
2. The replacement additive term `1e-20f` does not survive the first multiply.
   The gate cell read NOT-CARRIED at every site with it, and changed 83 996 of
   84 000 samples with `+1.0f`. Classification now runs at `v*1.001 + 1e-6`.
3. `render()` leaked an ~11 MB engine context per call: invisible over ten
   renders, OOM at 11.6 GB over 1 415.
4. Five of seven scenarios never released a note, so nothing tested the release
   path where envelope tails, denormals and FTZ live.
5. Gate #3 was **over-claimed** — it cannot answer "would a wrong answer be
   noticed", because consumers read locals rather than reloading cells and some
   saturate. The claim is narrowed; `canary.py` answers module admissibility.

A sixth, in the same spirit: the teeth rule "every scenario must catch a
globally-relevant mutation" was unsound, and adding one scenario proved it. It is
now a measured catch-set per mutation that may never shrink.
