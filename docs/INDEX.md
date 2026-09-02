# DOCS INDEX — phase-3 triage (2026-09-02)

Classes: **LIVING** = binding law/spec/work order in force. **REFERENCE** =
proven finding or measurement record; true, cited, no longer the live edge.
**ARCHIVED** = historical; superseded, with its successor named in a banner.
Rule: nothing is silently deleted. Ten uncited historical docs moved to
`docs/archive/` (banners name successors); code-cited historical docs STAY at
their old paths so no comment pointer dangles. Live project state:
`CLAUDE.md` -> `FINAL_GUIDE.md`. Full dated log: `HISTORY.md`.

## docs/ (top level)

| file | class | what it answers |
|---|---|---|
| ARCHITECTURE.md | REFERENCE | Cloud 60 DSP architecture (derived from the IDA dump) |
| ARM_MEASURED.md | REFERENCE | ARM bring-up, measured — correcting the Teensy/Daisy record |
| ARP_FINDINGS.md | REFERENCE | Arpeggiator (CKbdArp / CArpeggio) — binary findings & port status |
| ARP_PROVENANCE.md | REFERENCE | CKbdArp / CArpeggio — binary provenance for `carp.c` / `carp.h` |
| ASSIGNER_MODE_FINDING.md | REFERENCE | The assigner-mode blind spot — KEY ASSIGN / LEGATO never reached the allocator |
| ASSIGN_MODE_3_FINDING.md | REFERENCE | ASSIGN MODE 3 — found by the user's banks, never reachable from the factory bank |
| ATTACK_TRANSIENT_FINDING.md | REFERENCE | BS Solid — the divergence is an ATTACK-TRANSIENT difference (2026-07-27) |
| AUDIBLE_RECALL_PLAN.md | ARCHIVED | Audible patch recall — feasibility, plan, and progress — *superseded banner in-file; stays (cited by src comments)* |
| BANK_FORMAT.md | REFERENCE | JUNO-60 preset bank format (KoaBankFile00003 / PG-JU60) |
| BEND_MOD_SENS.md | REFERENCE | BEND SENS / MOD SENS (DCO + VCF) — derived bit-exact, deferred to the wheel path |
| BITEXACT_AUDIT.md | REFERENCE | Bit-exact audit: the timbre + arp bugs, and how they were fixed |
| BITEXACT_RENDER_AB.md | REFERENCE | Tier B render — bit-exact vs the plugin, all 64 patches (identical-state A/B) |
| BSSOLID_DIAGNOSIS.md | REFERENCE | "BS Solid does not have enough noise" — diagnosis |
| CARP_LATENT_FINDING.md | REFERENCE | carp.c — one LATENT state-cell divergence (2026-08-26) |
| CHORUS_RECALL.md | REFERENCE | FX per-patch recall — findings (JUNO-60 / JU-06A VST3) |
| CHORUS_STRUCTURAL.md | REFERENCE | Chorus STRUCTURAL constants — per-mode derivation (JUNO-60 / JU-06A VST3) |
| CLAIMS.md | LIVING | CLAIMS — JUNO-60 (JU-06A) C99 port: what is proven, how, and to what bound |
| CLASSIC_PANEL.md | LIVING | CLASSIC panel derivation — VCA TONE and ENV2 (2026-09-02) |
| COEFF_PARAM_MAP.md | REFERENCE | Coefficient → parameter map (from sub_180388170 registry) |
| COLDLOAD_AB.md | ARCHIVED | Cold-load A/B — matching the plugin's post-recall engine state (Phase 3) — *superseded banner; stays (cited by src comments)* |
| COLDSTART_UNISON_FINDING.md | REFERENCE | Cold-start DCO phase alignment — why unison patches played hot AND dark |
| CONTROL_AUDIT_CANDIDATES.md | REFERENCE | JUNO control-layer audit — ADJUDICATED (2026-08-26) |
| CONTROL_LAYER.md | REFERENCE | Control layer — parameter system, note handling, voice allocation |
| CONTROL_LAYER_PORT.md | REFERENCE | Bit-exact control-layer port — plan, findings, and status |
| DAISY_FEASIBILITY.md | ARCHIVED | Daisy Seed feasibility report — JUNO-60 C99 port on the Electrosmith Daisy — *partly superseded by ARM_MEASURED.md* |
| DATA_PROVENANCE.md | REFERENCE | Data provenance & trust verdict |
| DELAY_LEVEL_CELL_102560.md | REFERENCE | RETRACTED — cell 102560 was NOT a port defect (my oracle was incomplete) — *a RETRACTION record; kept so it is not rediscovered* |
| EFFECT_MODES.md | REFERENCE | EFFECT TYPE modes 1 & 5 — distortion+pan and the 2nd chorus/ensemble |
| FINAL_GATE.md | REFERENCE | Phase 7 — final gate |
| FX_COLDLOAD_TODO.md | REFERENCE | FX cold-load recall — RESOLVED: 64/64 bit-exact |
| H7_VS_S3_MEASURED.md | REFERENCE | H7 vs ESP32-S3 — measured, not estimated |
| HISTORY.md | LIVING | PROJECT HISTORY — the full dated log that used to be CLAUDE.md |
| HOSTPATH_PARITY_SCOPE.md | LIVING | HOSTPATH PARITY SCOPE — close every remaining gap between the port and a REAL host instance. Opus 5: execute t — *PARKED live work order (DAW-parity track)* |
| JX3P_PLAN.md | LIVING | THE JX-3P PLAN — port-level C99, no hiccups, as fast as the method allows — *jx3p/docs/S3_STATUS.md holds live state* |
| MASTER_RENDER_MAP.md | REFERENCE | master_render (sub_180363380) — transcription map & dropped-arg resolutions |
| NAN_SEMANTICS_SCOPE.md | LIVING | NaN semantics: what is a defect, and what is only an inaccuracy |
| P112_FINDINGS.md | REFERENCE | #112 — VST3 host-lifecycle oracle: EXECUTED FINDINGS (2026-07-24) |
| P112_ROADMAP.md | ARCHIVED | #112 VST3-lifecycle oracle — concrete roadmap (mapped 2026-07-23) — *partly retracted; read P112_FINDINGS.md first* |
| PARAM_SETTER.md | REFERENCE | Per-parameter setter — "raw 0..255 byte → parameter" |
| PHASE1_WARM_RECALL.md | REFERENCE | Phase 1 — the "Rip Lead first-note filter swell" investigated |
| PHASE2_MATRIX_PROGRESS.md | REFERENCE | Phase-2 scenario matrix — results + fixes (VERIFIED) |
| PHASE3_COVERAGE_CERTIFICATE.md | REFERENCE | Phase 3 — Coverage Certificate (Gate G3, port + plugin sides) |
| PHASE4_ALLOCATOR.md | REFERENCE | Phase 4 — Allocator sub-modes (finding + disposition) |
| PHASE4_ARP_AUDIO_CERT.md | REFERENCE | Phase 4 — Arp audio certification |
| PIPELINE.md | LIVING | THE PIPELINE — .vst3 in → two ESP32-S3 boards out (E3, END_GOAL item 7) |
| PLAN_5_STEPS.md | REFERENCE | THE 5-STEP PLAN TO THE END GOAL (written 2026-08-26, user-approved scope) — *PARKED scope of 2026-08-26; FINAL_GUIDE rules sequencing* |
| PLAN_FINAL_STRETCH.md | REFERENCE | THE FINAL STRETCH — EXECUTION PLAN (binding, 2026-08-28) — *PARKED; its cycle budgets predate the voice-5 defect and are 2-voice numbers* |
| POLYPHONY.md | REFERENCE | Polyphony — deriving the per-voice state layout from the binary |
| PORTING_TOOLKIT.md | REFERENCE | Porting toolkit — what carries to the next soft synth, and what does not |
| PORT_COMPLETENESS_CHARTER.md | LIVING | PORT COMPLETENESS CHARTER — binding for EVERY .vst3 → C port |
| PORT_STATUS.md | ARCHIVED | Port status & the chorus/driver boundary — *superseded banner; stays (cited by gui)* |
| PROJECT_SSX_CHARTER.md | LIVING | PROJECT-SSX — the repeatable process, and the portability target |
| RAMP_AB_FINDINGS.md | REFERENCE | JUNO ramp A/B — four real defects, found the day the gate was written |
| RANDOM_STATE_FINDINGS.md | REFERENCE | Random full-state A/B — first findings (2026-08-13) |
| RECALL_COMPLETE.md | ARCHIVED | Preset recall: complete bit-exact map (and what "79 parameters" really is) — *superseded banner; stays (cited by src/tools)* |
| RENDER_LOOP_LOG.md | REFERENCE | RENDER_LOOP_SCOPE execution log — *the exoneration record of the render loop* |
| RENDER_LOOP_SCOPE.md | REFERENCE | RENDER LOOP SCOPE — derive the REAL per-block render structure. Opus 5: follow this to the letter, in order. — *executed scope; kept, cited by renderstruct_ab.py* |
| ROADMAP_EMBEDDED.md | REFERENCE | EMBEDDED ROADMAP — the honest big picture (2026-07-31) — *P1 closed; sequencing moved to FINAL_GUIDE.md* |
| RUN_GUIDE_GUI.md | REFERENCE | Test GUI — full parameter control + patch recall |
| RUN_GUIDE_TABLES.md | REFERENCE | How to run `extract_tables.py` (final voice-engine data dump) — *regeneration guide for juno_tables.h; extraction folders purged* |
| TRACKB_CHARTER.md | LIVING | --- — *PARKED track; gates live in tools/trackb/* |
| VELOCITY_COEFFS.md | REFERENCE | Velocity coefficients 6864 / 9680 — binary-derived resolution |
| VOICE_MODES.md | REFERENCE | Voice-assign modes (ASSIGN MODE / LEGATO) — bit-exact port |
| VOICE_RENDER_MAP.md | REFERENCE | voice_render (0x180369070) — full stage map |

## docs/archive/ (moved 2026-09-02, banners name successors)

| file | was | successor note |
|---|---|---|
| ENUM_HUNT_STATUS.md | docs/ | RESOLVED 2026-07-27. Successors: docs/RENDER_LOOP_LOG.md, docs/ASSIGNER_MODE_FINDING.md. |
| FINAL_SCOPE.md | docs/ | Executed to completion (2026-07). Successor for live status: FINAL_GUIDE.md + CLAUDE.md. |
| FINAL_SCOPE_LOG.md | docs/ | Execution log of FINAL_SCOPE.md (2026-07). Closed. |
| RESUME_2026-08-26.md | docs/ | Dead session handoff. Live state: CLAUDE.md. |
| RESUME_2026-08-27.md | docs/ | Dead session handoff. Live state: CLAUDE.md. |
| RUN_GUIDE.md | docs/ | Extraction-era guide; the cited extraction folders were purged from history (2026-07). Kept for method provenance only. |
| RUN_GUIDE_DBG_CAPTURE.md | docs/ | CAPTURE-ERA guide. Forbidden by the covenant; historical record only. |
| RUN_GUIDE_EXTRACT_ALL.md | docs/ | Extraction-era guide; folders purged. Method provenance only. |
| RUN_GUIDE_RUNTIME_CAPTURE.md | docs/ | CAPTURE-ERA guide. The capture covenant (CLAUDE.md HARD RULES) forbids this method; every capture-derived constant was replaced. Historical record onl |
| VALIDATION.md | docs/ | CAPTURE-ERA validation (live-plugin memory snapshot). Superseded by the Unicorn-oracle gates (make verify); the covenant forbids the method. Historica |

## docs/engineb/ — the engine-B era (fork + S3 fit)

`METHOD_PLAYBOOK.md` is LIVING BY RULE (defects added the day they are paid).
Also LIVING: DEVICE_RECALL.md, TWO_CHIP_WIRING.md, SCOPE.md,
AUDIBLE_STANDARD.md, M5_SONIC_FRAME.md. Everything else is REFERENCE — module
results (M-*, F-*), superseded plans (each names what replaced it), audits.
`docs/engineb/data/` (92 files, b4..b43 + module data): REFERENCE wholesale —
every file is one dated measurement; the filename is the claim's address.

| file | class | what it answers |
|---|---|---|
| ASM_KERNEL_PLAN.md | REFERENCE | THE CLOSING WORK ORDER — the fused ladder+VCA kernel (2026-08-09, Fable 5) |
| ASM_KERNEL_WORKORDER.md | REFERENCE | WORK ORDER — the hand-written ladder kernel (EB_VCF_ASM), for Opus 5 |
| AUDIBLE_STANDARD.md | LIVING | THE ONE CHANGE — sonically accurate -> audibly accurate (USER-ORDERED) |
| BUDGET_STATUS.md | REFERENCE | ENGINE B — BUDGET STATUS (first real numbers) |
| CAMPAIGN_8H.md | REFERENCE | Autonomous optimization campaign (2026-08-08, 8h AFK) |
| COMPACT_FORMAT_FINDING.md | REFERENCE | THE 118-BYTE COMPACT PRESET FORMAT IS INSUFFICIENT — MEASURED 2026-08-02 |
| COST_MEASURED.md | REFERENCE | Engine B's cost, with the harness subtracted |
| COST_RIG.md | REFERENCE | THE ENGINE B COST RIG — `tools/engineb/cost.py` |
| DCO_PROFILE.md | REFERENCE | DCO profile — where the DCO's work actually is |
| DELAY_PITCHMOD_FINDING.md | REFERENCE | The delay pitch-hoist defect, and what the blind battery hid |
| DEVICE_RECALL.md | LIVING | DEVICE-SIDE RECALL — the design, the three defects, and their fix |
| DOUBT_AUDIT.md | REFERENCE | DOUBT AUDIT — every load-bearing claim re-examined, and the plan that survives it |
| DOUBT_OPUS.md | REFERENCE | The doubt review (Fable, 2026-08-08): errors found in this session's verdicts |
| F3_S3_FORK_DESIGN.md | REFERENCE | F3 — the S3 fork numeric design: what passed, what died, and the number |
| F5_HALFOS_DESIGN.md | REFERENCE | F5 — half-oversampling design: DCO path and VCF path (the spec O8 executes) |
| FINAL_MILE.md | REFERENCE | FINAL MILE — from 1.42x to real time, for Opus 5, TIME-BOXED |
| FOUNDATION.md | REFERENCE | ENGINE B — THE FOUNDATION |
| FX_CHORUS.md | REFERENCE | ENGINE B — THE CHORUS: behavioural specification (MEASURED, 2026-08-02) |
| FX_DELAY.md | REFERENCE | ENGINE B — THE DELAY, MEASURED |
| FX_REVERB.md | REFERENCE | ENGINE B — THE REVERB: behavioural specification (MEASURED, 2026-08-02) |
| FX_VERDICT.md | REFERENCE | ENGINE B — FX VERDICT |
| HARNESS_AUDIT.md | REFERENCE | Harness audit — engine B gates |
| HEADROOM_PLAN.md | REFERENCE | HEADROOM — the plan, and the space we must make |
| HOME_STRETCH.md | REFERENCE | THE HOME STRETCH — real time on TWO chips, 44.1 kHz, 6 voices + FX |
| LAST_MILE.md | REFERENCE | LAST MILE — the plan that ends this (2026-08-10) |
| LEVERS.md | REFERENCE | The levers, measured — can engine B fit the ESP32-S3? |
| M-DELAY_RESULT.md | REFERENCE | ENGINE B — MODULE M-DELAY (DELAY TYPE 0): EXACT, AND CHEAP UNTIL THE LINE MOVES |
| M-REVERB_RESULT.md | REFERENCE | ENGINE B — MODULE M-REVERB: EXACT, AND IT FITS THE CYCLE BUDGET BUT NOT THE MEMORY BUDGET |
| M2_WORST_CASE.md | REFERENCE | M2 — the worst case, and the number that was wrong |
| M3_RING_DERIVATION.md | REFERENCE | M3 — the rings, derived from the parameter, and what it does to L1 |
| M4_ROUTE_DECISION.md | REFERENCE | M4 — the B3 route, decided at the worst patch instead of patch 0 |
| M5_SONIC_FRAME.md | LIVING | M5 — the sonic frame every lever is screened by |
| M7_ENV_RESULT.md | REFERENCE | MODULE M7 — the two ADSR envelopes. Measured on both axes. |
| MCHORUS_RESULT.md | REFERENCE | ENGINE B — M-CHORUS: implemented, nulled EXACTLY 0, and costed (2026-08-02) |
| METHOD_PLAYBOOK.md | LIVING | THE METHOD PLAYBOOK — how to lift a synth engine out of a binary, and how to |
| MVCA_RESULT.md | REFERENCE | MODULE M-VCA — the VCA + HPF output stage. RESULT. |
| MVCFCV_RESULT.md | REFERENCE | MODULE M-VCFCV — the VCF cutoff CV summing (src/voice_render.c:1150-1229) |
| MVCF_LADDER_RESULT.md | REFERENCE | MODULE M-VCF — the 4-pole ladder CORE. Measured on both axes. |
| P8_PLAN.md | REFERENCE | P8 — the restructure track. The plan, from the corrected numbers. |
| PHASE1_ORDERS.md | REFERENCE | PHASE 1 ORDERS — finish and certify engine B, the splitting point |
| PLAN_REALTIME.md | REFERENCE | The no-nonsense plan to real time (2026-08-08) |
| PLAN_TRUNK_FORK_DELAY.md | REFERENCE | PLAN: close the trunk DELAY null, propagate to the fork, push both |
| PLUGIN_BASELINE.md | REFERENCE | PLUGIN BASELINE — every written module, checked against the authority |
| REALTIME_PATH.md | REFERENCE | The path to 6 voices + full FX, real time, on ONE ESP32-S3 |
| REAL_TIME.md | REFERENCE | IT FITS — 6 voices, full FX, 44.1 kHz, on one ESP32-S3 |
| S3_ASSESSMENT.md | REFERENCE | ESP32-S3 FEASIBILITY — THE CORRECTED ASSESSMENT (2026-08-03) |
| S3_PLAN_THAT_FITS.md | REFERENCE | THE PLAN THAT FITS — 6 voices + full FX on the ESP32-S3 |
| S3_PLAN_V2.md | REFERENCE | THE PLAN THAT FITS, VERSION 2 — 6 voices + full FX at 44.1 kHz |
| S3_STRATEGY_6VOICE.md | REFERENCE | STRATEGY: 6 VOICES + FX ON THE ESP32-S3 |
| S3_TOOLCHAIN.md | REFERENCE | ESP32-S3 TOOLCHAIN — installed, and the first real S3 number |
| SCOPE.md | LIVING | ENGINE B — SCOPE AND TARGET (user-set, 2026-08-02) |
| SONIC_BOUND_SETTLED.md | REFERENCE | The fork's sonic bound, settled by measurement |
| STANDALONE.md | REFERENCE | The standalone engine — scope, and why the measurements force it |
| STEP1_ATTRIBUTION.md | REFERENCE | Step 1: per-module CYCLE attribution on silicon (ablation method) |
| TWO_CHIP_WIRING.md | LIVING | TWO-CHIP WIRING — O6/D1, what to connect and why |
| VCF_ZDF1X_PLAN.md | REFERENCE | WORK ORDER — the 1x ladder refit (EB_VCF_ZDF1X), written for Opus 5 |
| VERDICT_ONE_CORE.md | REFERENCE | IT DOES NOT FIT ONE CORE — and the fix costs nothing sonically |
| VOICE_BUDGET.md | REFERENCE | Engine B — VOICE PATH BUDGET |
| VOICE_INTERLEAVE_PLAN.md | REFERENCE | Voice interleaving — the design, ready to execute |
| ZERO_PROOF.md | REFERENCE | Structurally-zero coefficients: the evidence, and what it is not |

## docs/trackb/ — PARKED track (Daisy sonic-identity fork)

All PARKED-REFERENCE. Entry point when resumed: PLAN.md + RESUME.md;
TRACKB_CHARTER.md (top level) holds the gates. The standing warning (no module
rewrite behind a blind gate) is in CLAUDE.md HISTORY pointers.

## docs/preset/

COMPACT_FORMAT.md: REFERENCE — ⚠ its 118-byte set was measured INSUFFICIENT;
engine_b/eb_patch.h (134 bytes) is the corrected authority.

## docs/hardware/ — LIVING (the MasterAudio carrier board)

BOARD.md (design reference), PCB_PLACEMENT.md (layout notes + open items),
MasterAudio_reference.kicad_sch (generated reference netlist).

## Elsewhere (not docs/, listed for completeness)

jx3p/docs/ — the JX-3P port's own docs; S3_STATUS.md rules its state.
docs is indexed; AIRTIGHT_PLAN.md, GOAL.md, END_GOAL.md, FINAL_GUIDE.md,
COVERAGE.tsv, PROVENANCE.tsv live at repo root and outrank this index.
