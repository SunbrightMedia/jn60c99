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
| 2 | Voice compare window | **RE-OPENED 2026-08-25** — I closed this too fast. MEASURED: of 66 voice-0 cells the A/B chain changes, exactly ONE (+0xA6BFD0) lies ABOVE the compared window 0x60000. It is a RAMP TARGET, stepped by the per-voice tail sub_1803F40E0 -> sub_1803F4A40, which `jx_voice_render` does not implement. So the gate cannot see whether the port steps voice ramps at all. Audio impact UNKNOWN: the voice arm's own addressing tops out near 0x1F410, so the arm does not read this cell — but 'not read by the arm' is not 'not read' | window 0x60000, but a real f32 DSP cell at **+0xA6BFD0** changes during render (0.9637→1.0) and is NEVER compared |
| 3 | Master compare window | OK | measured: 0 changing words above 0xAAD000 |
| 4 | Render duration | PARTIAL (2026-10-10) | the full chain renders 16,096 samples per patch (4,096 idle + 12,000 after a note) on patches 0/5/20/49, EXACTLY 0 on the factory-HOST oracle; the A/B stays 64 samples. FX tails past 0.37 s and long notes are not graded |
| 5 | Note events | **WEAK** | exactly ONE note_on(60,100). No note-off/release, no polyphony, no chords, no velocity spread, no re-trigger, no bend/mod. JUNO has fuzz_diff (24 seeds x 3 rates, random polyphonic); JX has no equivalent |
| 6 | Block size | PARTIAL (2026-10-10) | the oracle renders blocks of 256 (jx_emu.render), the C engine one sample at a time: the full chain is EXACTLY 0, so 256 == 1 there. Other sizes not graded (JUNO gates 1/64/128/512/600) |
| 7 | Sample rates | PARTIAL | 44100/48000/96000. JUNO also gates 88200 + 192000 (non-standard rates catch rate-dependent constants) |
| 8 | Cold start | PARTIAL (2026-10-10) | the C engine now starts from the plugin's own boot (the factory HOST; ramps and latch live, no snap) and the full chain compares from sample 0 -- at 44100 only |
| 9 | Warm recall (patch change on a running engine) | **UNTESTED, and not done** | jx3p_recall resets every unit to the template and lays the patch's deltas on top: a cold restart per patch change. The plugin keeps the running voices and ramps the parameters (the JUNO's A17/B1b) |
| 10 | Voice count | **UNTESTED, and not done** | the plugin plays SIX by default (vm.vs.voiceCount 0x0FFFC00E default 6; its render syncs every assigner to it and renders only units below it -- jx3p/docs/HOST_LAYER.md). The port renders all 8 |
| 11 | `quality` toggle | **UNTESTED** | vs.quality = 0..1, default 0. Effect unknown; likely an oversampling/CPU trade (would matter for the S3) |
| 12 | Host-role vs recall-role params | **UNEXAMINED** | JUNO's #112 proved a host reaches parameters a preset load never touches. Never examined for JX. KEY ASSIGN / ARPEGGIO / KEY HOLD / OCTAVE SHIFT / MASTER TUNE reach the engine by some path and are ungated |
| 13 | Note allocator | **CLOSED** (2026-09-04, re-run on the factory HOST 2026-10-10) | transcribed: jx_alloc.c, jx_nstore.c, jx_ktrack.c, jx_dispatch_note.c, each with its two-process gate and tooth (4,000 mixed events, 22,008 seam events EXACTLY 0); the full chain plays through the C allocator end to end |
| 14 | Master effect branches | **CLOSED** — was the unordered-compare defect, fixed | the 11 argless sites are effect-gated placeholders. Now that FX params are recalled they are live and the C emits NaN. Found only after fixing #1 |

## What IS solidly proven (unchanged by all of the above)
- The **voice render**: with all 57 pools exercised, N=64, seam 0/64 and voice
  state 0 words differ, on every patch tested, at 3 rates, on two banks.
- The **helpers** and the binary's own `expf`/`tanf`: dense full-domain sweeps.
- **Recall** for the voice unit: 64/64 patches EXACTLY 0 on two banks.

## The rule this audit exists to enforce
A gate proves a POINT IN A SPACE, not the space. Before calling anything
"proven", state the space: which parameters, which state, how long, which
events, which rates, which block sizes, which start conditions. Any dimension
not enumerated is a dimension where the claim is unverified — and, as #1 and
#14 showed, that is exactly where the defects live.
