# JX-3P — SCOPE AUDIT (what the gates actually prove)

Written 2026-08-24 after playbook 80: a green gate proved less than its
headline claimed. The user asked the right follow-up — "could the scope be
wrong in any OTHER way?" — so this enumerates EVERY dimension along which a
gate's scope can be narrower than its claim, and states the MEASURED status of
each. No dimension is marked OK unless a measurement says so.

"The port is bit-exact" is meaningless without this table.

### STATUS AS OF 2026-08-25 (end of the audit session)
Three REAL defects were found and fixed by the work this table drove:
1. **JUNO** EFFECT DEPTH 1..63 wrote a ramp where the plugin saturates
   (`EFFECT_SW_LUT`). No factory patch uses 1..63, so nothing could see it.
2. **JX** unordered-compare: the plugin CLAMPS on NaN (`comiss; ja`), the port
   did not (`x <= 0.0`), so the master emitted NaN. A/B 0/5 -> 5/5 EXACTLY 0.
3. **JX** cell 1088: the widened census added LFO RATE H, which shares the cell
   with LFO RATE and RESETS it last. Derived keep-clean; recall 64/64 EXACT.

Rows 1 and 14 below are CLOSED. Row 2 was closed and then RE-OPENED the same
day after a measurement contradicted the closure — recorded rather than
quietly amended. The rest stand as written.

| # | Scope dimension | Status | Evidence |
|---|---|---|---|
| 1 | Parameter coverage | **CLOSED** — census 57, gate uses all 57, recall 64/64 EXACT | probe found 57 active pools, gate used 32. Now 51 discovered + toothed; 6 master-only pools still uncovered |
| 2 | Voice compare window | **CLOSED (2026-10-10)** | the voice high windows [0xA60000, 0xAAC320) -- the ramp targets (+0xA6BFD0 among them) and the start-mute word -- are compared after every 256-sample chunk on all 64 patches + 9 mode variants (jx_master_bisect.py --gate, GATE 3b: job jx_vhigh2 on 6495ac0d, EXIT 0, its tooth bites). Since JX-11 the port's memory IS the plugin's heap, and GATE 1 compares every voice state with its object pointer |
| 3 | Master compare window | OK | measured: 0 changing words above 0xAAD000 |
| 4 | Render duration | PARTIAL (2026-10-10) | the full chain renders 16,096 samples per patch (4,096 idle + 12,000 after a note) on patches 0/5/20/49, EXACTLY 0 on the factory-HOST oracle; the A/B stays 64 samples. GATE 3b (2026-10-10): all 64 patches + 9 mode variants, every unit's whole state, the control objects and L/R per 256-sample chunk over the same 16,096 samples (DSP mode: every unit renders, no gain stage). FX tails past 0.37 s and long notes are not graded |
| 5 | Note events | **PARTIAL (2026-10-10)** -- was WEAK | the CONTROL plane under seeded polyphonic sequences: up to 10 keys held, velocities 1..127, re-triggers, note-offs, runs of clock ticks (jx_tick_gate.py, GATE 3c: 34 runs, every control object after every event, every unit's state at checkpoints). Through process(): one note-on / note-off per run, at a block start or inside a block (jx_product_gate.py, GATE 3d). Not graded: the AUDIO under polyphony and chords, bend/mod. JUNO has fuzz_diff (24 seeds x 3 rates, random polyphonic); JX has no audio equivalent yet |
| 6 | Block size | PARTIAL (2026-10-10) | the oracle renders blocks of 256 (jx_emu.render), the C engine one sample at a time: the full chain is EXACTLY 0, so 256 == 1 there. Through process() (GATE 3d): host blocks of 512, which the render driver splits at every clock tick and record (pieces of every length). Other host block sizes not graded (JUNO gates 1/64/128/512/600) |
| 7 | Sample rates | **PARTIAL (2026-10-10)** | through the plugin's own process() (GATE 3d): host rates 44100 / 48000 / 96000 and 88200 / 192000 (the render object's table: the 96 kHz engine and its converter) EQUAL; 32000 (outside the table) silent in both. Not graded: the engine-rate SETTINGS other than the automatic one (the JUNO's A30 path) |
| 8 | Cold start | PARTIAL (2026-10-10) | the C engine now starts from the plugin's own boot (the factory HOST; ramps and latch live, no snap) and the full chain compares from sample 0 -- at 44100; through process() (GATE 3d) the product path compares from the first host sample at 44100 / 48000 / 96000 (the engine at 96000, the start mute, the render object). The engine-rate settings other than the automatic one are not graded |
| 9 | Warm recall (patch change on a running engine) | **PARTIAL (2026-10-10): ported and graded on its first cases** | jx3p_recall runs the patch's records through the plugin's own parameter system (lifted, JX-11) on the RUNNING engine, as the plugin's patch browser and render driver do; the port's memory is the plugin's heap, so every state a patch does not carry stays as the plugin keeps it. Graded through the plugin's own process() (GATE 3d --recall): a key held across a change from patch 0 or 34 to 20, and to the arpeggiator patch 61 -- EQUAL at 48 / 96 kHz; tooth: the wrong patch must differ. The lift itself: EXACTLY 0 on warm loads onto 0 and 34 and on every patch at every effect type (GATE 3e). Not yet graded: changes in fast succession, a change inside a block with keys at the same offset, user banks (the patch browser's bank decode is not ported: the records come from the factory bank's recorded loads) |
| 10 | Voice count | **CLOSED (2026-10-10)** | the port renders the HOST's count (six by default: the render's preamble syncs every assigner to HOST+0x38 and renders only units below it). Graded through process() with seeded polyphonic sequences -- up to 10 keys held, steals, re-strikes -- 24 of 24 runs EQUAL at three host rates (GATE 3d --poly); tooth: all eight units playing must differ, BITES 2 of 2 (job jx_poly1, EXIT 0) |
| 11 | `quality` toggle | **CLOSED (2026-10-10): no effect on the engine** | the host setting 0x0FFFC00F reaches the engine's host entry, which changes nothing: one call at 0 and at 1 through the lifted entry changes 0 words of the 102 MB heap (the voice count's changes exactly HOST+0x38), and the lifted entry equals the plugin's over every host setting 0x0FFFC000..0x0FFFC01F at 7 values (jx_lift_gate.py --loads settings, EXACTLY 0). No transcribed code reads it |
| 12 | Host-role vs recall-role params | **PARTIAL (2026-10-10)** -- the recall protocol is the plugin's own (records through its host entry, its patch browser's order); host edits are the plugin's own code | every one of the host entry's 744 ids at 13 values, the host settings 0x0FFFC000..1F at 7 values, every effect type on every patch: the lifted entry EXACTLY 0 against the plugin's (jx_lift_gate.py --loads sweep / settings / modes). In the product: jx3p_param(id, value) and type-2 records in the render driver's block list. Not yet graded through process(): single host edits as a DAW or the editor sends them (the VST3 parameter path and the editor's queue) |
| 13 | Note allocator | **CLOSED** (2026-09-04, re-run on the factory HOST 2026-10-10) | transcribed: jx_alloc.c, jx_nstore.c, jx_ktrack.c, jx_dispatch_note.c, each with its two-process gate and tooth (4,000 mixed events, 22,008 seam events EXACTLY 0); the full chain plays through the C allocator end to end |
| 14 | Master effect branches | **CLOSED 2026-10-10** (the August closure was wrong: the 11 argless sites stayed placeholders, 0 as argument) | the arguments written from the asm (every register's writer found on the control-flow graph); with them two more defect classes of the decompile: rounded decimal constants and three dropped phase wraps (playbook 198). Every legal value of the two effect-mode cells (records 67 and 65, 0..5) is driven through the plugin's own host entry -- the factory values by the 64 patches, the rest by variant patches -- and every state word is equal over 16,096 samples (jx_master_bisect.py --gate, GATE 3b; its tooth, the lost argument back, is seen) |
| 15 | Clock tick and arpeggiator | **PORTED + GRADED (2026-10-10, JX-7)**; GATE 3c GREEN in make verify-jx3p on 743dfb16 (36 of 36 runs, tooth 3 of 3) | jx3p/src/jx_seq.c from the instructions (the engine's tick, the note manager's and note store's ticks and their graph, the 19 step functions, the random numbers, the mode setter) + the JUNO-60's render driver (jx3p_product_block). GATE 3c (jx_tick_gate.py): factory patches, variants for every step mode the product reaches (0, 3, 6) and the engine's entry reaches with SCATTER (2, 5, 8, 10) -- a REFUSE when one is missing, seen on the first full run --, all 19 modes through the plugin's own setter, tooth. GATE 3d (jx_product_gate.py): process() at 3 host rates, notes at block starts and inside blocks, two teeth (no render object; the first key not restarting the clock). Not graded: a host tempo other than 120 (the port's driver has no tempo input yet), the arpeggiator switched while keys are held through process() |

## What IS solidly proven (unchanged by all of the above)
- The **voice render**: with all 57 pools exercised, N=64, seam 0/64 and voice
  state 0 words differ, on every patch tested, at 3 rates, on two banks.
- The **helpers** and the binary's own `expf`/`tanf`: dense full-domain sweeps.
- ~~**Recall** for the voice unit: 64/64 patches EXACTLY 0 on two banks.~~ WITHDRAWN 2026-10-10: that
  was the C LUT against the pool MODEL of the recall, not against the plugin's patch load (row 12).

## The rule this audit exists to enforce
A gate proves a POINT IN A SPACE, not the space. Before calling anything
"proven", state the space: which parameters, which state, how long, which
events, which rates, which block sizes, which start conditions. Any dimension
not enumerated is a dimension where the claim is unverified — and, as #1 and
#14 showed, that is exactly where the defects live.
