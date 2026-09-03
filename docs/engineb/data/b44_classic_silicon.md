# b44 — CLASSIC on silicon: fork (CLASSIC6) and exact (CLASSIC-EXACT3)

Date: 2026-09-03. Both runs flashed by the user, three-bin set, COM3.
All numbers PROVEN(executed) on the S3 unless marked. Known contamination:
the single-board LINK BAD-PAIR churn ran in BOTH sessions (see "Open").

## Run 1 — CLASSIC6 (fork engine, 6 voices, one chip)
Build: fork b43 lever set + EB_DCO_WT + CR levers + EB_CLASSIC, CHUNK=64.
App sha e42dfc8a.

- Byte law PROVEN on-chip: boot banner ENV2==ENV1, TONE=128, EFFECT=2,
  DELAY=0, zero FX rings.
- Master collapse: delay=22, reverb=4 cyc/sample (from 1,741–3,237 in b43).
  Chorus (effect) ≈619.
- 6 fork voices ≈15,300 cyc/sample total → ONE chip (10,000) starves (B5
  deficit real, HEALTH red). Two chips ≈70–77% — INFERRED, not yet run split.

## Run 2 — CLASSIC-EXACT3 (trunk + exact-only levers, 3 voices, two cores)
Build: b43 exact recipe (EB_ZEROCOEF, ATREST_BLOCK/O1, VCF_DEADCOEF,
EXP_MEMO, FUSE_VCA, NOLIBM, S3_EXACT_ONLY=1 — NO WT/half-OS/CR/fast-math)
+ EB_CLASSIC, CHUNK=256, SPLIT=7, VOICE_LO=5. App sha 2bce5eba, 572,640 B.

- Byte law PROVEN on the EXACT engine: ENV1=[53 120 90 113] == ENV2 MATCH,
  TONE=128, EFFECT=2, DELAY=0, no FX rings. rc struct 10,564 (exact size
  tooth passed); CRC MATCH vs chord-3 answer key.
- Master collapse holds on exact: in=104 delay=22 reverb=4 out=138
  effect≈435–636.
- FXP: fx=668, v1≈9,841–9,862, wait≈4,805 per sample.
- Totals cyc≈11,526–11,723 vs 5,804 µs period → HEALTH red at 3 voices on
  one board. EXPECTED — exact 3 voices never fit one board.

## The reconciliation (why cyc≈11.5k is NOT a regression vs b43's 7.4–8.6k)
`v1` INCLUDES the per-sample spin waiting on core 0 (juno_s3_listen.c
~line 2709: "v1 INCLUDES this spin"). Honest core-1 voice work:
v1 − wait ≈ 9,850 − 4,805 = **5,045 cyc per exact voice** — inside b43's
measured exact-voice band 5,191–5,670 (slightly under: classic removes some
per-voice mod work). The exact-voice cost is CONFIRMED, not regressed.
The cyc headline sums fx + v1 with the spin embedded; do not quote it as
load. NB/EVQ counters at zero: the demo chord drives voices directly, not
through the note queue — instrumentation gap, not silence; audio played.

## Sizing the ORIGINAL-port classic (the user's directive)
Per exact-classic voice ≈5,045–5,670. Six voices ≈30,300–34,000.
Plus chorus fx 668 + in/out/master ≈260 → **≈31,200–35,000 cyc/sample**.
The 4-slot MasterAudio board: 8 cores × 5,000 = 40,000 →
**78–88% load. The board is the machine for the ORIGINAL-port CLASSIC.**
One chip and two chips remain ruled out for exact; the FORK classic fits
two chips (≈70–77%, INFERRED).

## Open
- LINK BAD-PAIR churn on a single board (PEER ANSWERED / hs=BAD PAIR, LKA
  drops in the thousands) steals cycles in every measurement. Owed: a
  runtime or build gate to silence it before the next budget number.
- Fork-classic two-chip split not yet run on silicon.
- 4-slot build cannot be proven until the carrier board exists.
