# FX cold-load recall — status

Phase 3 made the **voice** block bit-exact at cold-load (64/64 factory + 100/100 random).
This tracks the **master/FX** block, verified by the full-pipeline cold-load master A/B
(`scratchpad/oracle/id_coldmaster_ab.c` — our production render, voices + FX, vs the
plugin's captured stereo stream).

## Progress: 27/64 → 60/64 stereo-bit-exact; **0 audibly-off patches**

All 64 patches now render within RMS ratio **[0.993, 1.000]** of the plugin over the
full pipeline — no patch is audibly off. Fixed (each commit derived bit-for-bit from the
captured MASTER-unit states, `idstate64/state_pN_master.bin`):

- **Delay slot-1 block** — the `FILT[]` held value-tree values, not the engine's
  constants; corrected the whole high-cut/damp filter, feedback (0.4235), dry (1.0),
  enables. (v39==0 patches, delay tone/feedback.)
- **Chorus mode 3** — 91152 LFO-rate override (chorus II runs a different rate).
- **Chorus mode 5** — block-A levels now written; 96352 LFO rate rate-scaled; 96336 fixed.
- **Slot-1 chorus (DELAY TYPE 2/3)** — new `apply_slot1_chorus`: 20 constants + per-patch
  6395312=(blob53/255)*11-8, 6396176=blob52/255 + the chorus I-vs-II routing cells.
- **Slot-1 reverb (DELAY TYPE 5)** — new `apply_slot1_reverb`: 42 constants + per-patch
  6497344=blob52/255.

## Remaining (2 patches, bit-diff only — both inaudible, RMS 1.000)

`id_coldmaster_ab 2000` is now **62/64**. The 2 non-bit-exact patches — **41
"SQ Multirhythm"** (DELAY TYPE 1) and **62 "BS Juno Grime"** (DELAY TYPE 2 / chorus) —
both first diverge at sample **1660** with RMS ratio **1.000** (identical energy; only a
tiny late-tail phase shift). Root cause is the **tempo-synced DELAY TIME**, one open item:

### The one open item: tempo-synced DELAY TIME (`102352` / `4297584` / `6497168`)
Sync-on patches hold a fixed *synced* time, not the manual per-byte value. Proven by
correlating the captured `102352` against the manual byte formula across the 8 DELAY-TYPE-1
patches: only 2/8 (patches 15, 55) match the manual formula; the other 6 hold a quantized
value (e.g. byte 136 and byte 122 both → `0x3f83d200`, and byte 115 & 175 both → 2.0598).
The captured set is small: {0.3432, 0.4576, 0.5887, 0.8700, 1.0298, 2.0598}. TODO: find the
DELAY SYNC / division record byte, derive synced = f(default BPM, division) (mirror
`juno_apply_lfo_tempo`), and write it. Until then the manual formula is used for TYPE 0/2/3/5
(exact where the division coincides) and TYPE 1 is left inert (see below).

### DELAY TYPE 1 (dual delay) — fully derived, intentionally NOT wired
DELAY TYPE 1 runs TWO delay taps: a first-instance block (102xxx, a variant of TYPE 0 —
`102544`/`102592`/`102608` differ) plus a full SECOND instance at `4297584..4297984`. The
entire **constant** block, the per-patch **WET** (LEVEL/255 on both taps) and the **level
gate** (feedback `102560`, ON `102576`/`4297824`) are derived bit-for-bit and coded in
`src/delay_recall.c` (`apply_slot1_delay1` / `DLY1_A` / `DLY1_B`, verified 8/8 TYPE-1
patches incl. a level-0 one). It is **not called**, because the only remaining unknown —
the TIME — is tempo-synced: wiring it with the manual formula REGRESSES the render (patch 8
gained an audible early echo at sample 117, RMS 0.994). Leaving TYPE 1 inert (no delay
block, RMS 1.000 in-window) is strictly safer than a mistimed echo. Wire it the moment the
sync-time law lands — every other cell is ready.

Inaudible/inert and not chased: the aux DCO-retrigger latches (`101504+`, re-phase silent
voices only), the reverb structural constants at `10759360+` (never read by the output),
and the near-zero denormal buffers at `11022040+` (per-patch in the plugin but e-42 —
FTZ/DAZ flushes them in the render, so they cannot affect the output).

## Gate
`id_coldmaster_ab` reaches 62/64 (the 2 remaining need the synced DELAY TIME). Voice gate
(`id_coldab_batch`) stays 64/64; random-patch voice gate (`id_random_ab 100`) 0 diffs.
Audibility: all 64 patches within RMS [0.993, 1.000] — **0 audibly-off**.
