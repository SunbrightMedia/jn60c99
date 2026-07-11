# FX cold-load recall — remaining work (handoff)

Phase 3 made the **voice** block bit-exact at cold-load (64/64 factory + 100/100 random,
see docs/COLDLOAD_AB.md). The **master/FX** block is not yet: the full-pipeline cold-load
master A/B (`scratchpad/oracle/id_coldmaster_ab.c` — our production render vs the plugin's
captured stereo stream) reads **27/64 patches stereo-bit-exact**; the other 37 diverge in
the delay/chorus recall, a few audibly (RMS ratio 2.2–2.5× on patches 27/56/58).

This is per-patch FX recall that was only ever validated for level/type, not cell-complete
against the plugin's MASTER-unit engine state. Ground truth = `idstate64/state_pN_master.bin`
(the plugin's own post-recall master unit). Method (per docs/COLDLOAD_AB.md): drive the
plugin's own value-tree dispatch under Unicorn (`e2e_emu.py`), diff our
`coldstate/our_pN.bin` vs the captured master state, derive each byte→cell law bit-exact,
validate over all 64 + a ≥32-value synthetic sweep.

## The six clusters (cells, evidence, routing correlation)

Routing selectors: **v39** = DELAY TYPE (slot-1), **v551** = EFFECT TYPE (slot-2), per
`idstate64/batch_summary.json`.

1. **Delay tempo-sync — cell 102352 (Phase 4).** 41 patches differ. Sync-on v39=0 patches
   hold `0x3f83d200` = 1.0298462 @48k (the 351.5625 ms synced value = dispatch idx 803,
   byte≥1; idx 797 is the *manual* per-byte curve `delay_recall.c` already does). TODO: find
   the DELAY-SYNC record byte; derive synced_ms = f(host BPM, division) (mirror
   `juno_apply_lfo_tempo`); decide cold-load default (no transport) value. See
   `scratchpad/oracle/delaytime_rate_spec.md`.

2. **Per-patch delay high-cut / LF-HF damp — 102368/102384/102400/102416/102432/102464/
   102544/102608/102656.** 29 patches, ALL v39=0. Our `FILT[]` in `delay_recall.c` is a
   WRONG constant — these are per-patch (e.g. p0 102368 ours 0.515128 vs plugin 0.151557).
   Dispatch idx 1180 (high cut) + 1182..1185 (LF/HF damp); find driving record bytes near
   3057/3060; may be a joint transform like `hpf_type_lut`.

3. **Second delay instance — 4297584..4297984 (= 102352-block + 4195232).** 17 patches,
   ALL v39==1. Ours=0 everywhere; plugin holds a full delay set (synced time, wet, feedback,
   plus instance-2 constants 4297712=1.41443, 4297888=2, several 1.0 enables). `delay_recall.c`
   early-returns when `dtype!=0` — must instead write instance 2 for DELAY TYPE==1.
   Cross-check `master_render.c` reads at 4195232-offset (audible: v39=1 selects it).

4. **Slot-1-hosted chorus — 6395312..6396224+.** 14 patches, v39∈{2,3} (DELAY TYPE 2/3 host
   chorus I/II in slot 1). Ours=0; plugin recalls a full chorus set (6395312=-5.41176,
   6396128=0.0291748, and 6396192/6396208/6396224 = 0.515128/1.03026/0.515128 — the same
   filter triplet as cluster 2). Diff a v39=2 master state vs v39=0 over 6390000..6400000.

5. **Chorus mode-3 / mode-5 rate + level cells.** (a) 91152 — 22 patches, all v551==3:
   ours 2e-05 (96k-frozen) vs plugin 3.41667e-05 @48k (rate-reference + numerator wrong).
   (b) 96336 — 8 patches v551==5: ours 0.00944426 vs plugin 0.00466109 (~/2.026, investigate).
   (c) 96352 — same 8: ours 2.75e-05 vs plugin 5.50e-05 (exactly 2×, 96k-frozen rate ref).
   (d) 91200/91216/91232 — 9 patches (8 v551=5 + p9 v551=1): plugin writes block-A levels
   (0.0025098 / 1.3 dry / 1.17) that `chorus_recall.c` skips when etype==5.

6. **Aux DCO-retrigger latches — 101504,101536,...,101696,101712.** All =1.0 in EVERY
   captured state; ours sets only the sounding voice. **Likely inaudible** (a latch on a
   silent, ungated voice just re-phases its DCO once). Low priority; confirm the exact cell
   set (note 101712 = +208 is off the voice*32 stride — probably a second interleaved latch
   at base+16) and whether recall or note-on broadcast sets them.

## Priority
Clusters 2, 3, 4, 5 carry audible level/filter errors → do first. Cluster 1 is the Phase-4
host-BPM item (its cold-load default is what matters for a static A/B). Cluster 6 is
state-completeness, almost certainly inaudible.

## Gate
`scratchpad/oracle/id_coldmaster_ab.c` (built against src/*.c) must read **64/64** stereo
bit-exact. Re-run after each cluster fix; also keep the voice gate (`id_coldab_batch`) at
64/64 and the random-patch gate (`id_random_ab 100`) at 0 diffs.
