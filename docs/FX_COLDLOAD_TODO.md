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

## Remaining (4 patches, bit-diff only — all inaudible, RMS ≥ 0.993)

The 4 non-bit-exact patches (8, 34, 41, 62) diverge only late (the delay tail) at
RMS ~1.000, from two items:

1. **Tempo-synced DELAY TIME (cells 102352 / 6497168)** — Phase 4. Sync-on patches hold a
   fixed synced value (e.g. 0x3f83d200 = 351.5625 ms @48k, dispatch idx 803) instead of the
   manual per-byte time. TODO: find the DELAY SYNC record byte (correlate the sync-on
   patches), derive synced_ms = f(host BPM, division) (mirror `juno_apply_lfo_tempo`), and
   set the cold-load default. Affects patches 8/34/62.
2. **DELAY-TYPE-1 second delay instance (block 4297584..)** — patch 41. For v39==1 the
   plugin writes a second delay coefficient set (mirroring the 102xxx block + a few
   instance-2 constants) that our recall leaves at 0. Inaudible here (RMS 1.000).

Both are captured-at-48kHz where they involve filter constants; the slot-1 blocks note the
rate caveat. Also inaudible/inert and not chased: the aux DCO-retrigger latches
(101504+, re-phase silent voices only) and the reverb structural constants at 10759360+
(never read by the output — 60 bit-exact patches carry them as 0).

## Gate
`id_coldmaster_ab` should reach 64/64 once (1) and (2) land. Voice gate
(`id_coldab_batch`) stays 64/64; random-patch voice gate (`id_random_ab 100`) 0 diffs.
