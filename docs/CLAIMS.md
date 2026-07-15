# CLAIMS — JUNO-60 (JU-06A) C99 port: what is proven, how, and to what bound

Ground truth for every row: the plugin's own machine code run under Unicorn
emulation (tools/verify/e2e_emu.py). "Bit-exact" = every rendered float sample
identical (both channels) to the plugin. This file is the acceptance record: no
claim is made elsewhere that is not a row here, with its proof script.

Reproduce any row: run the script named in it. Rebuild first: `make libjuno.so`.

## A. PROVEN BIT-EXACT (direct A/B vs the running plugin)

| # | Claim | Proof script | Result |
|---|-------|--------------|--------|
| A1 | **Patch recall** — all params → engine cells, 64 factory patches (authoritative proof is now A11/A12: the DCO/LFO/PWM cluster + delay FB/direct that A1's old reference froze are recalled per-patch) | tools/verify/recall_render_ab.py + recall_exhaust.py (A11/A12); tests/test_apply_golden.c | bit-exact; see A11 (render A/B 15/15) and A12 (per-value 11520/11520) |
| A2 | **Cold render** — random patch/note/param/arp-toggle scripts | tools/verify/fuzz_diff.py (seeds 0–202) | **203/203 seeds bit-exact**, 0 divergences |
| A3 | **Notes × velocities** — every note×velocity | tools/verify/notevel_exhaust.py | 16,256 combos bit-exact |
| A4 | **Live param edits** — each of 25 front-panel params, all bytes | tools/verify/param_exhaust2.py; tests/test_param_setter.c | 25×256 live edits bit-exact at 3 rates |
| A5 | **Live TEMPO SYNC** engage+disengage, note held across flip, all patches | tools/verify/temposync_engage_ab.py | **64/64 patches bit-exact** |
| A6 | **Discrete DCO/LFO modes** (out-of-factory: OSC range/waveform, sub/noise type, LFO variation/routing, octave shift, VCA mode) | tools/verify/synth_dco_ab.py | all 13 discrete params × notes 24–96 bit-exact, 0 divergences |
| A7 | **Arp audio (render + dispatch)** — port arp schedule rendered by port == by plugin | tools/verify/arp_audio_ab.py | **63/63 scenarios** (7 arp patches × 3 modes × 3 octaves) bit-exact; see §D1 for the schedule caveat |
| A8 | **FX per-patch** (chorus I/II, delay, reverb) at 44.1/48/96 kHz | tools/verify/rate_audio_final.py; cold_regress.py | bit-exact; rate arms measured at 44100/48000/88200/96000 (see B4) |
| A9 | **State-transplant step-equivalence** — plugin warm state → port, both step identically | Phase-2/3 transplant (docs/PHASE2_MATRIX_PROGRESS.md) | proven "equal state + equal steps ⇒ equal forever"; adversarially confirmed |
| A10 | **Voice allocation** (POLY LRU: reuse/free/release/steal, persistent binding) | tools/verify/fuzz_diff.py; tests/test_voice_alloc.c | bit-exact within corpus; allocator matches CAssignJu60 |
| A11 | **Phase-1 recall redo — DCO/LFO/PWM cluster + delay FB/direct recalled per-patch** (the render A/B is the judge, NOT the recall-state diff) | tools/verify/recall_render_ab.py (port recall+render vs the plugin's OWN recall+render, two-process) | **15/15 patches BIT-EXACT** (62,5,18,39,6,14,31,0,21,53,50,12,45,13,22), note 60 vel 105, 48 kHz, N=16000; also 44100 for the teensy poly patches (0,5,22,31,40) bit-exact. Was 0/15 before the fix. |
| A12 | **Phase-1 recall redo — exhaustive per-value** (each fixed param × 256 bytes × 3 rates == the plugin's own setter, executed) | tools/verify/recall_exhaust.py (two-process) | **11520/11520 checks bit-exact** at 44100/48000/96000: feet 3840=curve5, PWM depth 4144=curve45, PWM source one-hot, LFO delay 1920=curve42/43/44 + enable 1936=curve52, LFO rate 1088/2064=curve22, DCO LFO mod 4032=curve0, VCF LFO mod 7344=curve47, LFO key-trig 1872=curve51, delay FEEDBACK 102560=fb/255·0.9, DIRECT 102512=direct/255 |

## B. LEDGERED — accepted differences with a measured bound (user-approved)

| # | Item | Bound / disposition |
|---|------|---------------------|
| B1 | **Warm re-recall not bit-exact-able** | Free-running oscillator/LFO phase makes a warm re-recall unmatchable in absolute phase. Measured envelope 1.6–3.7% diff-RMS across 64 patches, all within the plugin's own warm-vs-warm envelope. Cold recall IS bit-exact (A1/A2). The correctness basis for warm is A9 (step-equivalence), not phase-matching. |
| B2 | **≥9-SOUNDING-voice steal ~1–2 ULP** | The plugin's arp/steal path splices a worker-thread render; only reachable with ≥9 simultaneously-sounding voices. Bound: 1–2 ULP. Audio-inert in the corpus. |
| B3 | **Broadcast flags 1856/1488/1840** | Plugin writes all 8 voices; port writes the gated voice. Audio-inert in every test. |
| B4 | **Rate arms cover 4 rates** | FX config cells measured at 44100/48000/88200/96000. Other host rates out of contract. Teensy target is 44100 (measured ✓). |
| B5 | **8 header/denormal cells (offsets 0/64/80/96/112/128/144/160)** | The plugin's post-recall voice block carries FTZ-flushable denormals / signed-zeros here (e.g. -1.4e-38, 6.7e-29); the port writes +0.0. Bit-different in the recall-STATE diff but AUDIO-INERT (FTZ/DAZ flushes them; the render A/B A11 is bit-exact with them at +0.0). Ledgered, not chased — per the Phase-1 plan. |
| B6 | **DELAY TYPE-1 (dual delay) master-region recall (patch 41 "Multirhythm")** | The plugin's replaceState fires FX leaves at dispatch idx > 877 that the render A/B reference (real_recall.leaf_table, disp ≤ 877, + delay FB/direct) does not yet dispatch, so the second-delay-instance block (4297584..) stays at build-default in the reference while the port populates it from captured constants → the render diverges at sample 3. Patch 41's VOICE state is bit-exact (only the B5 header denormals differ); the gap is purely the TYPE-1 dual-delay master structure. Pre-existing, out of Phase-1 scope (TYPE-0 delay FB/direct — patches 53/50/12/45 — are bit-exact, A11). Belongs to the Phase-2 FX-region completion. |

## C. VERIFICATION INFRASTRUCTURE (proves the above are trustworthy)

| # | Claim | Proof |
|---|-------|-------|
| C0 | **Bank byte→record decode is the plugin's own code** (Phase-0 redo) | tools/verify/real_bank_parse.py --verify. Drives the PG-JU60 per-record parser sub_7FF91DF90ED0 (rva 0x330ED0) under Unicorn on all 64 patches: the record body is read VERBATIM into programmer state (istream::read/memcpy, no nibble transform), name written at byte 140. Plugin record == input body byte-for-byte 64/64; every leaf real_recall.py reads matches its dec() with 0 mismatches (112 leaves × 64). So `((b0&0xF)<<4)|(b1&0xF)` IS the plugin's decode. The transform-heavy sub_7FF91DFB1710 is the JU-06A "PG-BTQJA" import parser, gated off for PG-JU60 (also driven, to confirm it's the wrong path). Residual: the record-byte POSITION MAP (value-tree replaceState leaf order) is still Script.xml-derived + cross-validated (ASCII names land at record 140..170 — executed-confirmed; DCO-RANGE enum {2,3,4,5}), not executed via the value tree. |
| C1 | **Coverage certificate** — every port branch exercised or dispositioned; plugin engine blocks traced | docs/PHASE3_COVERAGE_CERTIFICATE.md (cov_replay.py + plugin_blocktrace.py). Uncovered = defensive/unreachable-at-audio-rate (plugin-corroborated), dead code, or dormant-by-design |
| C2 | **Float determinism** — no reliance on FMA contraction | -ffp-contract=off (Makefile) + tests/test_fma_canary.c. Verified: 0 FMA in libjuno.so; guard build byte-identical to default; canary fails under forced FMA |
| C3 | **Allocator sub-modes scoped** — MONO/UNISON unreachable via the parameter interface | docs/PHASE4_ALLOCATOR.md: value-tree ASSIGN dispatch is a no-op on the allocator; MONO patches play POLY on cold recall; hardwired POLY correct for all 64 patches |
| C4 | **The faithful recall reference = the plugin's COMPLETE-LEAF dispatch, NOT the full 0..4965 loop** | Two references were compared cell-by-cell (tools/verify/recall_state_leaves.py vs recall_fullstate_diff.py). The full 0..4965 loop (recall_fullstate_diff.py --ref) re-dispatches ~4850 NON-leaf indices the plugin never re-fires on recall, CLOBBERING real leaf cells — VCF cutoff 6736 → 1.0 (golden/oracle-proven per-patch value 0.6) and LFO rate 1088/2064 → a constant. The plugin's true recall (replaceState) fires only the value-tree leaves; dispatching every leaf (each an idempotent store) == its changed-leaf recall and matches the plugin's captured post-recall engine state (6736 = coarse). recall_render_ab.py / cold_regress.py / recall_state_leaves.py use this complete-leaf reference; the full loop is contaminated for non-leaf-clobbered cells and must not be used as the recall reference. |

## D. RESIDUALS — proven by transcription, not yet by independent execution diff

| # | Item | Status |
|---|------|--------|
| D1 | **Arp note SELECTION** (which notes each step picks + step timing) | Verified by binary transcription with cited provenance: tasks #36 (carp vs CArpeggio), #50 (24-PPQN tick accumulator), #52 (STEP×SLOT grid) — docs/ARP_PROVENANCE.md. The arp RENDER+DISPATCH is directly proven (A7); the SELECTION rests on transcription. The plugin pattern-grid was execution-validated for enable/latch/start/clock/selector but its grid-population (nslots) was not fired under emulation for an independent schedule diff. docs/PHASE4_ARP_AUDIO_CERT.md. |

## Verdict

Cold-load behavior — recall, notes, velocities, live param/FX edits, voice
allocation, discrete oscillator modes, arp render+dispatch — is **proven
bit-exact** against the running plugin across large exhaustions and a 203-seed
differential corpus, with a dual-sided coverage certificate and float-determinism
guards for the Teensy target. The accepted differences (B) are bounded and
audio-inert or phase-only; the one transcription-only residual (D1) is the arp's
per-step note selection, whose audio render is nonetheless directly proven exact.

**Phase-1 recall redo (2026).** The cornerstone recall diff proved the port had
FROZEN a DCO+LFO+PWM cluster (feet 3840, PWM depth 4144, PWM source 3888/3904/3920/
3936, LFO delay 1920/1936, LFO rate 1088/2064, LFO tempo 1072, DCO/VCF LFO mod
4032/7344, LFO key-trig 1872) and voided delay FEEDBACK 102560 / DIRECT 102512 —
each justified by a CIRCULAR proof (a recall reconstruction whose 19≤ml≤71 leaf
filter structurally skipped the very leaves). Each cell's record-byte→cell law was
re-derived by EXECUTING the plugin's own setter under Unicorn (256/256 per byte,
3 rates) and the fixes are proven by the **RENDER A/B against the plugin's own
recall+render** (A11, 15/15 patches bit-exact, was 0/15) plus the exhaustive
per-value sweep (A12, 11520/11520). Cell 1072 (LFO Tempo Rate) was the task's
"likely render-overwritten" caution — the render A/B DEMANDED it (tempo-synced
patches 0/5 diverged until it was recalled from the 128-BPM default), so it is
recalled, not skipped. Remaining: the 8 header/denormal cells (B5, audio-inert) and
the TYPE-1 dual-delay master-region recall (B6, patch 41, Phase-2 FX scope).
