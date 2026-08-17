# HEADROOM — the plan, and the space we must make
2026-08-17, Fable 5. Every number cited here was MEASURED and lives in the
named source file. No new number is projected; the iron rule of LAST_MILE.md
governs: no cycle claim before the board prints it, no sonic claim before the
gate prints it.

## THE STANDARD THIS SERVES
THE INVARIANT (FINAL_GUIDE): audio never breaks, for any input. Its proof is
the B4 stress gate: all 64 patches x worst-case polyphony x a program change
on every boundary x every parameter changing every block, hard block-overrun
counter reading EXACTLY 0, and the gate SEEN TO FAIL before it is believed.
Headroom is not a percentage; it is that counter reading zero on the worst
patch while everything else happens at once.

## WHERE WE STAND (measured, with sources)

| item | number | source |
|---|---|---|
| budget, 240 MHz / 44,100 Hz | 5,442 cyc/sample | data/chip_layout.md |
| B1 chip A, 3v no FX | 5,388 — FITS | FINAL_GUIDE B1 |
| B2 chip B, 2v + FX (M1) | 5,410 — FITS | FINAL_GUIDE B2, c3_silicon.md |
| playable build, quiet (PLAY3) | 5,229–5,273 | c3_silicon.md |
| playable build, worst spike (PLAY3) | 6,220 | c3_silicon.md |
| DELAY TYPE 2/3/5 patches, 2v + FX | ~6,600–6,900 — VIOLATES | FINAL_GUIDE, CLAUDE.md live state |
| B3 chip B, 3v + FX | over by 691 | FINAL_GUIDE B3 |
| chip A at 4v (route B) | over by 820 | FINAL_GUIDE B3 |
| FX chain alone | 7,745 cyc, c/i 2.36 | fx_chain_price.md §1 |
| voices only, c/i | 1.56 | fx_chain_price.md §1 |
| FX-free threshold | 3,068 cyc | fx_chain_price.md §3 |
| worst active ring set | 137 KB; 163 KB internal free | fx_chain_price.md §2 |
| PSRAM scattered read | ~244 cyc | CLAUDE.md live state |
| patch-change burst | ~1.89 M cyc, c/i ~68 = WAITING, not code | c3_silicon.md PLAY3 |
| ASM stall pool | 735/voice | LAST_MILE.md Phase B |

## HOW MUCH SPACE WE ACTUALLY NEED

Three gaps, in rising order of what they demand. They must NOT be summed:
the combined worst case (3 voices + a TYPE 2/3/5 patch + program change) has
NEVER been measured, and producing that one number is step M2 below.

| gap | size | what closes it |
|---|---|---|
| G1 spike: worst block on the playable build | 6,220 − 5,442 = **778** | transient; acceptable only if the overrun counter still reads 0 — B4 gate decides, not this table |
| G2 the invariant violation: DELAY 2/3/5 at 2v+FX | 10,700 − 5,442 = **~5,258** | L1 can reach at most 2,634 of it — see below |
| G3 the sixth voice: B3 | **~700** on chip B, or ~850 on chip A | whichever of the two routes the post-L1 measurement favors |

⚑ **G2 WAS WRONG IN THE FIRST VERSION OF THIS FILE, by 3.6x.** It read
"6,900 − 5,442 = ~1,460", taking the 6,600–6,900 range from FINAL_GUIDE.md:97.
That range is the TWO-VOICE CORE figure (2 × 3,394 = 6,788, the 0xd0 gap) and
has nothing to do with the delay patches; four other files use it with that
meaning. The delay-patch cost is board-measured in
data/patch_dependent_fx.md: TYPE 0 = 5,159, **TYPE 5 ≈ 10,700**. Corrected
with its cross-check and its consequences in **M2_WORST_CASE.md**, which is
the file to read before acting on this table.

The single most useful reframe in the repo (fx_chain_price.md §3): the FX is
FREE below 3,068 cycles — it hides behind the two-voice core entirely. The FX
measures 7,745 at c/i 2.36 while the voice chain runs c/i 1.56. **The target
is not "make the FX faster", it is "get the FX under 3,068".**

**And L1 cannot get there, which M2 settles by arithmetic on measured c/i.**
A PERFECT L1 — the whole FX chain moved from c/i 2.36 to the voice chain's
1.56 — is worth 7,745 − 5,111 = **2,634 cycles**, and lands the FX at 5,111,
still above 3,068. Against a G2 of 5,258 that leaves **~2,624 still to find**.
Only 34 % of the expensive delay arm is memory at all (1,327 of its 3,915
cycles); the other two thirds are arithmetic that placement cannot touch.
**So L2 is not a fallback — on these numbers L1 lands short by construction
and something of L2's size is required.** See M2_WORST_CASE.md.

## THE LEVERS, each with its measured basis

**L1 — rings out of PSRAM into internal SRAM.** The active arm's worst ring
set is 137 KB against 163 KB free internal (MEASURED, ring probe, all 36
scenarios). PSRAM scattered read is ~244 cyc. The 6.1 MB PSRAM allocation is
45x the working set, inherited from the plugin's own length cells.
PRECONDITION, not footnote (fx_chain_price.md §2): the shipping ring length
must be derived from the DELAY TIME parameter's MAXIMUM, never from observed
lag, or a patch outside the battery reads past the end. Gate: trunk null
EXACTLY 0 (placement must change no arithmetic), then cycles re-measured on
the board.

**L2 — FX arms on the spare core (structural fallback if L1 lands short of
3,068).** The port already forms its output BEFORE dispatching the effect
arms; an arm reaches the audio on the NEXT sample through cells 84672/84704
(fx_chain_price.md §5). The one-sample delay the split needs already exists
in the plugin's own topology. UNEXPLORED — treat as design work with its own
gate, not a flag flip.

**L3 — the ASM stall pool, 735/voice (Phase B, ASM_KERNEL_WORKORDER).** Only
if G3 survives L1/L2. Its gate discipline is already written.

**L4 — TYPE 4 pitch hoist.** The TYPE 2/3/5 hoist is DONE and proven
(eb_delay_pitchmod.h, null EXACTLY 0, all 30 modules). eb_dly_t4.c:112 still
calls eb_pitch_poly per sample. If hoisted it MUST use the shared helper —
DELAY_PITCHMOD_FINDING.md records why (playbook 53). Small, proven pattern,
bounded win.

**DEAD, do not re-litigate** (LAST_MILE.md, CAMPAIGN_8H.md): voice
interleave (register-spill wall), extending interleave, the resonance-table
cache as a burst fix (measured 1 %), estimating instead of measuring — five
projection failures are named in this repo; a sixth disqualifies the session.

## ORDER OF WORK

**M1 — build the B4 stress gate FIRST.** It does not exist. It is the
acceptance instrument for every lever below, and it must be seen to FAIL
(plant an overrun) before any green from it is believed. Without it, every
"fits" in this file is a one-patch, one-chord number — FINAL_GUIDE says
exactly this.

**M2 — measure the true worst case, once.** On the board: worst patch (TYPE
2/3/5) x 3 voices x program change x parameter storm, via the B4 gate. This
produces THE number G1–G3 must not be summed to guess. Also attribute the
~6,800: how much is the delay arm's memory traffic vs its arithmetic
(per-arm CCOUNT, the b/n patch-step path already on the console).

**M3 — L1** (ring derivation, then placement, then re-measure M2's number).

**M4 — decide the B3 route** with M3's number in hand: ~700 on chip B vs
~850 on chip A stops being a guess once the FX's real post-L1 cost is known.
Then L2/L3/L4 as the remaining gap dictates.

**M5 — the sonic frame around all of it** (SONIC_BOUND_SETTLED.md): every
lever is screened at EB_SONIC_BAND_DB = 1.0 per band at SHIP flags; the
instrument-level acceptance number is the USER's, by ear, on worst-case WAVs
(A4) — the one listening judgement the project permits. The shipping fork
measures 5.79 dB worst band today; that reference must be fixed by the user
before any lever is allowed to move it.

## WHAT DONE LOOKS LIKE
The B4 counter reads 0 over all 64 patches at 6 voices across both chips,
program changes and parameter storms included; the sonic gate reads within
the user-fixed bound at SHIP flags; A4 signed by ear. Then B3/B4 flip to
DONE and the invariant claim stands on a gate that was seen to fail.
