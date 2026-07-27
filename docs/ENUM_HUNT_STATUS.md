# Recall-enumerator completeness hunt — RESOLVED (2026-07-27)

Investigating the BS Solid (Chillwave patch 3) mid-band deficit (user: real
plugin has ~5-24 dB more energy in harmonics 6-17, 780-2200 Hz, host-independent,
"sounds like more noise oscillator"). This hunt tested the hypothesis that the
plugin's recall applies parameters the port drops. Probes in `probes/enum_hunt/`;
full agent reports in `probes/enum_hunt/LANE_REPORTS.md`. Everything below is
derived by executing the plugin binary under Unicorn (PROVEN) or reading its
decompile/name tables (READ). Zero capture data used anywhere (covenant intact).

## The finding chain

1. **PROVEN:** the plugin's recall enumerator (rva 0x3B48A0) fires **165**
   indices; the port + every gate applies **129**. (probes: enum_vs_applied.py,
   enum_order2.py; confirmed twice — executed AND read from the decomp's literal
   dispatch list.)
2. **PROVEN:** full-state diff (unit-0 voice region, 10512 B) between the
   plugin's own 165-index enumerator-order recall and the port's applied recall:
   **0 differing cells** on 15 factory patches (0,2,3,4,5,6,7,10,12,20,29,37,
   45,53,62) AND Chillwave 3 (BS Solid), 0, 2, 4. Dispatch order also
   irrelevant. (fullstate_diff2.py)
3. **READ (name table rva 0x9a0030, stride-8 char* array, 4966 entries):** every
   dropped index is a SYSTEM/SETUP/PERFORM/live-runtime param, NOT a patch
   coefficient: 20=MASTER TUNE; 128-141=scale select/user scale; 312-318=SCATTER
   CONTROL (312-317 already ported as live MODULATION); 373=VOLUME, 375=TEMPO;
   **433-440=Note(voice1-8), 450-457=Gate(voice1-8), 467-474=Mute(voice1-8)** —
   a live per-voice NOTE/GATE/MUTE bus; 493=Pitch Bend, 495=Mod CC#1,
   498=Expression; 553-555=GUI feedback switches; 614/657-711=PERFORM parts;
   878/1029=redundant float twins of byte LFO-rate/VCF-cutoff (verified
   bit-identical to the byte setters); 1178=DELAY TAP TIME.
4. **PROVEN:** all dropped indices are identity at their descriptor defaults
   (Note def 36 == prepare's cell-304 value; Gate/Mute/bend/CC defaults 0;
   MASTER TUNE def 0 = center). The Script.xml value tree only produces dispatch
   indices >= 748, so a real preset load feeds every dropped index its default.
5. **PROVEN (settings lane):** the controller->processor connect path (rva
   0x320420) pushes ONLY the Keyboard Velocity SW flag (already ported) +
   transport tempo/samplerate. Boost Mode/Output Gain dispatch **zero** engine
   cells. CONDITION is per-patch idx 856 and ALREADY in the applied leaf table.
   The IComponent INI parse is licensing plumbing, not synth params.
   **The persistent-settings hypothesis is REFUTED.**
6. **READ (cells lane):** the audio noise mix is
   `voice_render.c:1127: JF(6544) = (noiseSVF)*JF(6528) + (DCOmix)*JF(6512)`;
   cell 6528 = DCO NOISE LEVEL (juno_apply.c:221, blob 29, curve 54) is the ONLY
   patch-dependent noise gain and it IS applied. No dropped-index cell is in the
   noise multiply chain.

## Conclusion

**The port's recall is COMPLETE.** There is no dropped patch-dependent
coefficient; the recall/preset path is exonerated as the source of the BS Solid
deficit. The only audio-touching dropped indices are the live note/gate/CC bus —
i.e. the host NOTE/VELOCITY LIFECYCLE, consistent with #124's framing.

## One real (non-BS-Solid) gap found and worth wiring: DELAY TAP TIME (1178)

- **PROVEN:** context-gated. DELAY TYPE 1 (PAN DELAY) only: writes one f32 per
  unit at offset **4297792** = f32(trunc(255*byte/100)/255); byte cached at
  proc+1508 (ctor default 50), replayed by the TYPE activation 0x3B93E0 via
  vtbl+2616 (0x3B91E0) -> subobj vtbl+128 (rva 0x362FB0). Types 0/2/3/4/5: no
  cells.
- **READ:** the port freezes 4297792 = 0x3efefeff (tap 50) in
  `src/delay_recall.c` (DLY1_B) while `src/master_render.c:947` multiplies by
  it — an engine-reachable recall gap for any preset with tap != 50.
- **INFERRED:** record byte = 3056 (blob 3040, int1x7 raw&0x7F), anchored by
  validated neighbors 3057/3059/3060/3068. All 64 factory + 64 Chillwave
  patches decode tap=50 (identity), so no factory render changes — but GOAL.md
  requires correct recall for ANY value. BS Solid is DELAY TYPE 0 → ruled out
  for the user bug.

## Where the bug must live now (updated fact chain)

port == plugin recall+render bit-exact (57/57) AND the recall index set is now
proven complete AND settings/connect push nothing — yet the real instance
differs, host-independently. The remaining hand-written shared-blind-spot code:

- **The render LOOP STRUCTURE (prime suspect).** `e2e_emu.render()` (oracle) and
  `juno_driver.c`/WASM driver (port) are BOTH hand-written and structurally
  agree with each other, so render A/B can never see an error in the loop
  structure itself. Never derived from the binary: the real per-block DSP
  under the thread pool (0x3C7400) — its voice dispatch order, its block-size
  handling (a real host renders 64-512-sample buffers; the oracle uses
  block=600), and above all the **shared analog-noise block policy**
  (84272..84436): juno_driver snapshots/restores so all 8 voices step from the
  same state and the block advances once — a convention chosen to match the
  hand-written oracle, not proven from the binary. If the real loop lets voices
  consume the LFSR sequentially (or advances it per-voice), the real noise
  differs in exactly the way the user describes ("more noise oscillator") while
  every gate stays green.
- The live note/gate bus (450-457) writes VCF gate 6864 + VCA 9680 on note
  events — the real host note path may drive these differently than
  juno_note.c.

**Next step:** derive the real per-block render structure from the binary
(0x3C7400 and the pool work items): what function(s) run per block, in what
order, and who steps the noise block. Then re-express e2e_emu.render() to match
it, re-run render A/B — any divergence vs the port is then a REAL bug with a
derivable law.
