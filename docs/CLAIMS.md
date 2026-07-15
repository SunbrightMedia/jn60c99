# CLAIMS — JUNO-60 (JU-06A) C99 port: what is proven, how, and to what bound

Ground truth for every row: the plugin's own machine code run under Unicorn
emulation (tools/verify/e2e_emu.py). "Bit-exact" = every rendered float sample
identical (both channels) to the plugin. This file is the acceptance record: no
claim is made elsewhere that is not a row here, with its proof script.

Reproduce any row: run the script named in it. Rebuild first: `make libjuno.so`.

## A. PROVEN BIT-EXACT (direct A/B vs the running plugin)

| # | Claim | Proof script | Result |
|---|-------|--------------|--------|
| A1 | **Patch recall** — all 79 params → engine cells, 64 factory patches | tools/verify/param_exhaust.py; tests/test_apply_golden.c | bit-exact; 57,600-combo (param×256×{cold,warm,mid-note}) exhaustion identical |
| A2 | **Cold render** — random patch/note/param/arp-toggle scripts | tools/verify/fuzz_diff.py (seeds 0–202) | **203/203 seeds bit-exact**, 0 divergences |
| A3 | **Notes × velocities** — every note×velocity | tools/verify/notevel_exhaust.py | 16,256 combos bit-exact |
| A4 | **Live param edits** — each of 25 front-panel params, all bytes | tools/verify/param_exhaust2.py; tests/test_param_setter.c | 25×256 live edits bit-exact at 3 rates |
| A5 | **Live TEMPO SYNC** engage+disengage, note held across flip, all patches | tools/verify/temposync_engage_ab.py | **64/64 patches bit-exact** |
| A6 | **Discrete DCO/LFO modes** (out-of-factory: OSC range/waveform, sub/noise type, LFO variation/routing, octave shift, VCA mode) | tools/verify/synth_dco_ab.py | all 13 discrete params × notes 24–96 bit-exact, 0 divergences |
| A7 | **Arp audio (render + dispatch)** — port arp schedule rendered by port == by plugin | tools/verify/arp_audio_ab.py | **63/63 scenarios** (7 arp patches × 3 modes × 3 octaves) bit-exact; see §D1 for the schedule caveat |
| A8 | **FX per-patch** (chorus I/II, delay, reverb) at 44.1/48/96 kHz | tools/verify/rate_audio_final.py; cold_regress.py | bit-exact; rate arms measured at 44100/48000/88200/96000 (see B4) |
| A9 | **State-transplant step-equivalence** — plugin warm state → port, both step identically | Phase-2/3 transplant (docs/PHASE2_MATRIX_PROGRESS.md) | proven "equal state + equal steps ⇒ equal forever"; adversarially confirmed |
| A10 | **Voice allocation** (POLY LRU: reuse/free/release/steal, persistent binding) | tools/verify/fuzz_diff.py; tests/test_voice_alloc.c | bit-exact within corpus; allocator matches CAssignJu60 |

## B. LEDGERED — accepted differences with a measured bound (user-approved)

| # | Item | Bound / disposition |
|---|------|---------------------|
| B1 | **Warm re-recall not bit-exact-able** | Free-running oscillator/LFO phase makes a warm re-recall unmatchable in absolute phase. Measured envelope 1.6–3.7% diff-RMS across 64 patches, all within the plugin's own warm-vs-warm envelope. Cold recall IS bit-exact (A1/A2). The correctness basis for warm is A9 (step-equivalence), not phase-matching. |
| B2 | **≥9-SOUNDING-voice steal ~1–2 ULP** | The plugin's arp/steal path splices a worker-thread render; only reachable with ≥9 simultaneously-sounding voices. Bound: 1–2 ULP. Audio-inert in the corpus. |
| B3 | **Broadcast flags 1856/1488/1840** | Plugin writes all 8 voices; port writes the gated voice. Audio-inert in every test. |
| B4 | **Rate arms cover 4 rates** | FX config cells measured at 44100/48000/88200/96000. Other host rates out of contract. Teensy target is 44100 (measured ✓). |

## C. VERIFICATION INFRASTRUCTURE (proves the above are trustworthy)

| # | Claim | Proof |
|---|-------|-------|
| C0 | **Bank byte→record decode is the plugin's own code** (Phase-0 redo) | tools/verify/real_bank_parse.py --verify. Drives the PG-JU60 per-record parser sub_7FF91DF90ED0 (rva 0x330ED0) under Unicorn on all 64 patches: the record body is read VERBATIM into programmer state (istream::read/memcpy, no nibble transform), name written at byte 140. Plugin record == input body byte-for-byte 64/64; every leaf real_recall.py reads matches its dec() with 0 mismatches (112 leaves × 64). So `((b0&0xF)<<4)|(b1&0xF)` IS the plugin's decode. The transform-heavy sub_7FF91DFB1710 is the JU-06A "PG-BTQJA" import parser, gated off for PG-JU60 (also driven, to confirm it's the wrong path). Residual: the record-byte POSITION MAP (value-tree replaceState leaf order) is still Script.xml-derived + cross-validated (ASCII names land at record 140..170 — executed-confirmed; DCO-RANGE enum {2,3,4,5}), not executed via the value tree. |
| C1 | **Coverage certificate** — every port branch exercised or dispositioned; plugin engine blocks traced | docs/PHASE3_COVERAGE_CERTIFICATE.md (cov_replay.py + plugin_blocktrace.py). Uncovered = defensive/unreachable-at-audio-rate (plugin-corroborated), dead code, or dormant-by-design |
| C2 | **Float determinism** — no reliance on FMA contraction | -ffp-contract=off (Makefile) + tests/test_fma_canary.c. Verified: 0 FMA in libjuno.so; guard build byte-identical to default; canary fails under forced FMA |
| C3 | **Allocator sub-modes scoped** — MONO/UNISON unreachable via the parameter interface | docs/PHASE4_ALLOCATOR.md: value-tree ASSIGN dispatch is a no-op on the allocator; MONO patches play POLY on cold recall; hardwired POLY correct for all 64 patches |

## D. RESIDUALS — proven by transcription, not yet by independent execution diff

| # | Item | Status |
|---|------|--------|
| D1 | **Arp note SELECTION** (which notes each step picks + step timing) | Verified by binary transcription with cited provenance: tasks #36 (carp vs CArpeggio), #50 (24-PPQN tick accumulator), #52 (STEP×SLOT grid) — docs/ARP_PROVENANCE.md. The arp RENDER+DISPATCH is directly proven (A7); the SELECTION rests on transcription. The plugin pattern-grid was execution-validated for enable/latch/start/clock/selector but its grid-population (nslots) was not fired under emulation for an independent schedule diff. docs/PHASE4_ARP_AUDIO_CERT.md. |

## E. RECALL PATH — building the reconstruction-free reference (current work)

A1/A4 validated the port's `juno_bank_apply` (itself a reconstruction of the plugin's
byte→parameter transform) against `real_recall.py`, which shares one reconstruction with
it: the record-byte → value-tree POSITION MAP (Script.xml-derived — the C0 residual).
Removing that shared blind spot means executing the plugin's OWN patch-load. Doing so
(this session, `scratchpad/oracle/bridge_vec{A,B,C}.py`, all read-only under Unicorn)
proved the architecture below — and why no processor-side "bridge" from a bank record to
the engine was ever found: there is none.

| # | Finding | Evidence (RVAs are the durable proof coordinates) |
|---|---------|------|
| E1 | **Two VST3 components.** PROCESSOR `CVstProcessor` (createInstance 0x349CA0, IComponent vtable 0x967A08) is the DSP and the only component `e2e_emu` builds / the port replicates; its `IComponent::setState` (slot 12 = 0x348770) is bytes `c2 00 00` = `ret 0` — restores nothing. CONTROLLER `CVstEditController` (createInstance 0x3473D0, IEditController vtable 0x967310) owns the 744-param model; `setComponentState` = slot 5 = 0x347650. Controller holds no engine, never calls the setter. | PROVEN(exec): drove processor setState on patch 62 → 0 setter calls, feet unchanged. |
| E2 | **One engine writer, reachable for recall only via the apply node.** Setter 0x3B9A30 (proc vtable slot 11) is the sole engine writer; case 760 → feet 3840 = 2^(v−3); no direct callers. Recall reaches it through apply node 0x3C7AE0 (CWaveGen vtable slot 14), gated on the param-id map at 0xcb0e18 (empty in a processor-only build) that static-init 0xAD5A0 populates. | PROVEN(exec): after 0xAD5A0, 744-entry map; internal index 760 ↔ VST3 tag 0x600014; `apply(tag 0x600014, v)` → setter ×9 all rdx==760 → feet 2^(v−3) {2:0.5, 3:1.0, 4:2.0, 5:4.0}; empty-map control → 0 calls. Durable proof: `tools/verify/real_apply_node_probe.py`. |
| E3 | **Bank load writes no engine cell.** Loader 0x331530 → parser 0x330ED0 copies each record verbatim into programmer container 0x9105B8; no engine write. A `.bin` patch-select changes sound only via a controller → host → processor param round-trip; the processor alone recalls nothing. | PROVEN(exec): real parser on patch 62 → 0 setter calls; feet stays at BUILD default 1.0. |
| E4 | **Recall is HOST-MEDIATED (PROVEN, 3 independent agents).** No self-contained plugin function recalls a bank patch to the engine. The controller (createInstance 0x3473D0, ctor 0x3CEAD0) instantiates + initializes cleanly but exposes only a **1-entry program-list** model (`getParameterCount`=1, rva 0x637B60) and a **stub** `getParamNormalized` (0x3CC600 = `xor eax,eax;ret`); it works in PLAIN integers and delegates value↔normalized to the VST3 host. The record→param_id→engine chain crosses the host boundary: controller emits param changes to the host (`performEdit`), the host relays them to the processor `process()` queue, which drives apply node 0x3C7AE0 → setter → engine. Apply node + setter are both 0-xref (vtable-only, host/value-tree driven). | PROVEN(exec): scratchpad/oracle/ctrl_{A,B,C}.py — controller vtable scan, count=1, stub getParamNormalized, apply-node call-graph. |
| E5 | **DCO-RANGE mechanism + data PROVEN; the record→param LINK is the last reconstruction.** Descriptor index 760 (param_id 6291476): min0/max5/default3 (executed accessor 0x3ABAF0). `apply(760,v)` → feet 2^(v−3) {0:.125, 2:.5, 3:1, 4:2, 5:4}; v≥6 no-op. Patch 62 record decodes to 2; records store PLAIN values (values 4,5 occur ⇒ full domain [0,5], no offset). **IF** record position 32 maps to param 760, feet(62)=0.5. That position→param_id link is the value-tree leaf map — the ONE remaining reconstruction (the Script.xml map real_recall/BINDINGS use, READ never executed). | PROVEN(exec) mechanism+data; LINK inferred, NOT proven. |
| E6 | **feet=0.5 is UNSAFE to assert — both candidate answers trace to reconstructions.** "0.5" comes via the reconstructed leaf map (E5). "1.0" (the port's P3b choice) rested on the CONTAMINATED recall dispatch — its leaf filter 19≤ml≤71 DROPPED DCO RANGE (ml=18), so feet was never written and merely *looked* like the 1.0 default. feet 3840 also interacts with M.CV pitch + level (juno_apply.c:208-216), so a cell-diff can false-positive; the true arbiter is AUDIO from the plugin's real (host-mediated) recall. | Neither 0.5 nor 1.0 is PROVEN for the real bank-select path. |

**The linchpin (next work):** execute the plugin's OWN value-tree leaf application — the
GUI/programmer path that reads the bank record and emits `performEdit(param_id, normalized)`
per param — to PROVE the record-position→param_id map (does position 32 reach feet 3840, or
not?). That requires a minimal VST3 host transport (IComponentHandler/IConnectionPoint) so
the plugin's OWN transforms run; the transport is host plumbing, not plugin logic. Only then
is the recall reference reconstruction-free and an AUDIO A/B possible.

This reframes A1/C0: cold-recall bit-exactness was measured against a reference sharing the
leaf-map reconstruction, so it is **pending re-validation**. The engine port is UNCHANGED
(baseline 6b8edee) — no recall code is edited until the plugin's real recall proves what is
wrong. Port side of the eventual diff is captured (tools/verify/port_state_dump.py); the
differ is ready (tools/verify/recall_ref_diff.py); both await the reconstruction-free reference.

## Verdict

Cold-load behavior — recall, notes, velocities, live param/FX edits, voice
allocation, discrete oscillator modes, arp render+dispatch — is **proven
bit-exact** against the running plugin across large exhaustions and a 203-seed
differential corpus, with a dual-sided coverage certificate and float-determinism
guards for the Teensy target. The accepted differences (B) are bounded and
audio-inert or phase-only; the one transcription-only residual (D1) is the arp's
per-step note selection, whose audio render is nonetheless directly proven exact.
