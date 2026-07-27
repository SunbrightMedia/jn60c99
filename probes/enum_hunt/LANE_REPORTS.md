# Workflow wf_72846058-7b1 lane reports (2026-07-27)

Five parallel lanes hunting the real-host recall delta for the BS Solid
mid-band deficit. All provenance is the plugin binary executed under
Unicorn (PROVEN) or its decompile/name tables (READ). No captures used.



## LANE factory

### Key facts

- PROVEN: plugin recall enumerator (rva 0x3B48A0) fires 165 unique indices; captured via setter hook 0x3B9A30 under Unicorn (printed 'enum order length: 165' in all 4 runs)
- PROVEN: full-state diff (unit-0 voice region, 10512 bytes, post-snap_all, 48 kHz, factory bank) between the 165-index enumerator-order recall and the port's 116-index applied recall = 0 differing cells on ALL 15 patches tested: 0,2,3,4,5,6,7,10,12,20,29,37,45,53,62 (TOTAL differing cells: 0 in every chunk)
- PROVEN: enumeration order is state-irrelevant for these patches (side A enumerator order vs side B port order, identical result)
- PROVEN (corollary): the 49 enumerator-only 'dropped' indices, dispatched at build-default descriptor values on all 9 units, are inert on unit-0 voice state for every factory patch tested — including their known target cells 368/304/320/1856/6864/9680/9824/4112/7456/4000/7376/1088/2064/6736, all inside the diff window
- READ: both sides received identical per-patch descriptor population (leaf_table + 1179/1181 + 1028/1058 + H twins 878<-byte752, 1029<-byte779); the 49 dropped indices' descriptors were NOT patch-populated (factory blob has no bytes for them) — they carried build defaults on both... on side A only, side B never dispatches them
- INFERRED: the hypothesis 'a real host dispatches dropped indices with NON-default controller values' is NOT falsified by this lane — only default-value dispatch was proven inert; non-default values need the controller/settings source (#112)
- READ: probe scope limitation — fullstate_diff2 compares ONLY unit-0's first 10512 bytes; master/FX-region cells (6497xxx delay, 1069xxxx chorus, 11022052 routing) and units 1-8 are uncompared, so a dropped index with master/FX-only effect (e.g. 1178 DELAY TAP TIME) would be invisible here
- No diffs -> attribution extension not triggered; ready-to-run probe written at /home/user/jn60c99/scratchpad/factory_statediff_attrib.py (UC_HOOK_MEM_WRITE last-writer attribution per differing cell, JUNO_BANK override supported)

### Full report

LANE factory-statediff — RESULT: ZERO state divergence on every tested factory patch.

WHAT WAS RUN (both spreads requested, executed in 4 parallel single-process chunks, all exit 0):
  python3 scratchpad/fullstate_diff2.py 0 2 3 4   (log: fsd_chunk1.log)
  python3 scratchpad/fullstate_diff2.py 5 6 7 10  (log: fsd_chunk2.log)
  python3 scratchpad/fullstate_diff2.py 12 20 29 37 (log: fsd_chunk3.log)
  python3 scratchpad/fullstate_diff2.py 45 53 62  (log: fsd_chunk4.log)
Logs in /tmp/claude-0/-home-user-jn60c99/89f5fa0d-6fc0-55d6-a056-fe6fb14fdde6/scratchpad/fsd_chunk[1-4].log

PER-PATCH DIFF TABLE (verbatim probe output, concatenated; patch names added from E.patch_name):
  enum order length: 165          [printed identically by all 4 chunks]
  patch  0: 0 diffs               (SY Poly Synth)
  patch  2: 0 diffs               (KY Delicate Keys)
  patch  3: 0 diffs               (BR 60 Soft Brass)
  patch  4: 0 diffs               (PD Classic Pad)
  TOTAL differing cells: 0
  patch  5: 0 diffs               (LD Classic Lead)
  patch  6: 0 diffs               (BS Ouch Bass)
  patch  7: 0 diffs               (BL Bell Tower)
  patch 10: 0 diffs               (PL The Square)
  TOTAL differing cells: 0
  patch 12: 0 diffs               (PD Ripple Pad)
  patch 20: 0 diffs               (PD Saturate Pad)
  patch 29: 0 diffs               (LD Soul Icon)
  patch 37: 0 diffs               (LD Echolocator)
  TOTAL differing cells: 0
  patch 45: 0 diffs               (LD Silo Lead)
  patch 53: 0 diffs               (LD Echo Chamber)
  patch 62: 0 diffs               (BS Juno Grime)
  TOTAL differing cells: 0
GRAND TOTAL: 15 patches x 2 Unicorn builds each (+1 enum-order build per chunk), 0 differing cells anywhere.

ATTRIBUTION EXTENSION: not triggered (its precondition "ANY patch shows diffs" never occurred). It was pre-written and is ready at /home/user/jn60c99/scratchpad/factory_statediff_attrib.py (same A/B construction + UC_HOOK_MEM_WRITE over unit-0 voice region attributing every write to the active (unit, dispatch-idx); prints last-writer per differing cell on both sides). Usable as-is for any future bank/patch that does diff (accepts JUNO_BANK env override).

EXACT SEMANTICS OF WHAT WAS PROVEN (from probe source, READ: /home/user/jn60c99/scratchpad/fullstate_diff2.py):
- Side A = plugin's OWN recall enumerator index set (165 unique indices captured by hooking engine setter rva 0x3B9A30 during enumerator rva 0x3B48A0, in the enumerator's own first-dispatch ORDER), dispatched flag=1 on all 9 units with values read from the descriptor table (rva 0x98c048+16i).
- Side B = the port's applied set: 116 indices (112 leaf_table entries incl. 750-760 + 1179, 1181, 1028, 1058) in port order, all 9 units, flag=1.
- Both sides get IDENTICAL per-patch descriptor population: leaf_table bytes + FX_REC (1179<-blob 3041, 1181<-blob 3044) + EXTRA (1028<-1852, 1058<-2086) + H twins (878<-f32(byte752/255), 1029<-f32(byte779/255)).
- Diff window = unit-0 VOICE region only: bytes [state[0], state[0]+10512), compared 4-byte-wise after snap_all, sr=48000, factory bank truth/presetbankog1.bin.
- Therefore the 49 enumerator-only ("dropped") indices were dispatched in A with their BUILD-DEFAULT descriptor values (the factory blob carries no bytes for them; populate() never writes their descriptors).

INTERPRETATION (for the orchestrator):
1. PROVEN: For the factory bank, dispatching all 49 dropped enumerator indices at their build-default descriptor values, in the plugin's own enumeration order, on all 9 units, produces a unit-0 voice state BIT-IDENTICAL to the port's 116-index recall for all 15 patches tested (spread covers all voice/FX families: bass/lead/pad/keys/bell/brass/square). The previously-mapped dropped-index target cells (368, 304, 320, 1856, 6864, 9680, 9824, 4112, 7456, 4000, 7376, 1088, 2064, 6736) all lie inside the compared 10512-byte window, so their inertness-at-default is covered by this diff.
2. PROVEN (corollary): enumeration ORDER is also state-irrelevant here — A used enumerator order, B used port order, 0 diffs.
3. INFERRED (limitation, not tested by this lane): this does NOT falsify the half of the hypothesis where a REAL HOST populates the dropped indices' descriptors with NON-default values from the controller/settings object before recall fires — both sides here used identical (default) descriptor values for those 49 indices. Ruling that in/out requires the controller-side default/state source (#112 lifecycle), or dispatching dropped indices with swept non-default values.
4. READ (scope caveat): despite its name, fullstate_diff2 diffs ONLY unit-0's first 10512 bytes (the voice region). Master/FX-region cells (e.g. 6497xxx delay, 1069xxxx chorus, 11022052 routing) and units 1-8 are outside the compared window; a dropped index whose only effect is master/FX-region (e.g. 1178 DELAY TAP TIME, previously "no cells cold, maybe context-gated") would not be caught by this probe.
5. INFERRED: combined with (1), the factory-bank mid-band deficit on "BS Solid" (a CHILLWAVE bank patch, not tested in this lane — chillwave_statediff.py is the sibling lane) is unlikely to come from the dropped-index set at default values; the remaining candidate surfaces are non-default controller-pushed values (see 3), master/FX-region effects (see 4), or context-gated setter behavior under a differently-configured engine.

FILES: probe /home/user/jn60c99/scratchpad/fullstate_diff2.py (pre-existing, unmodified); new ready-to-run attribution probe /home/user/jn60c99/scratchpad/factory_statediff_attrib.py; raw logs fsd_chunk1..4.log in the session scratchpad. No captures opened; no libjuno loaded in any Unicorn process (two-process rule respected — each chunk is Unicorn-only).

## LANE chillwave

### Key facts

- PROVEN: fullstate_diff2 (Chillwave bank) patches 3,0,2,4: 0 differing cells in unit-0 bytes 0..10512 between plugin-enumerator-order 165-index recall and port's 129-index applied set (scope: voice region only)
- PROVEN: idx 1178 (DELAY TAP TIME) on cold engine and in BS Solid (DELAY TYPE 0) context writes NO state cells at values 0/25/50/75/100, flag 0 and 1, all 9 units; it writes only cache proc[u]+1508 = value verbatim
- PROVEN: 1178 IS context-gated: with delay mode 1 (PAN DELAY) it writes exactly one f32 state cell per unit, offset 4297792, value-dependent: 0->0x0, 25->0x3E7EFEFD, 50->0x3EFEFEFF, 75->0x3F3FBFC0, 100->0x3F800000 = f32((255*byte/100 trunc)/255); modes 0/2/3/4/5 write nothing
- PROVEN: the DELAY TYPE selector is dispatch idx 875 (not 873=EFFECT TYPE); recall-role dispatch of 875 calls activation 0x3B93E0 under both flags, which sets mode cache proc+1480 and replays cached tap via vtbl+2616 (0x3B91E0)
- PROVEN: plugin recall enumerator fires 875 at position 132 BEFORE 1178 at position 139 (165 unique), so the plugin's own recall lands the tap byte in cell 4297792 for every TYPE-1 patch
- READ: causal chain in decomp_380000.c: 1178 leaf setter 0x3B0980 caches proc+1508 (ctor default 50); 0x3B93E0 replays it; 0x3B91E0 forwards 255*v/100 to subobj proc+6976 vtbl+128 (rva 0x362FB0) only when mode==1
- READ: port gap — src/delay_recall.c DLY1_B freezes 4297792 = 0x3efefeff (default tap 50) while src/master_render.c:947 multiplies by that cell in the TYPE-1 render; engine-reachable recall gap for any preset with tap != 50 (identity at default)
- INFERRED: DELAY TAP TIME record byte = 3056 (blob index 3040, int1x7 raw &0x7F), derived from PAT2_DLY layout anchored by validated neighbors 3057/3059/3060/3068; BS Solid decodes tap=50 and all 128 factory+Chillwave patches decode tap=50 (17 factory + 28 Chillwave TYPE-1 patches, none non-default)
- PROVEN+READ: DELAY TAP TIME is RULED OUT as the BS Solid mid-band deficit cause (BS Solid DELAY TYPE=0 makes 1178 inert; tap byte is default); probe 1 never diffed FX/master cells beyond unit-0 offset 10512 — full unit-8 state diff is the recommended next lane

### Full report

LANE chillwave-statediff — both probes executed. Bank file verified at /root/.claude/uploads/89f5fa0d-6fc0-55d6-a056-fe6fb14fdde6/0e8b9cb5-Chillwave.bin (1294295 bytes, parses as 64-patch bank; patch 3 name = 'BS Solid').

== PROBE 1: full-state diff (scratchpad/fullstate_diff2.py, JUNO_BANK=Chillwave, patches 3 0 2 4) ==
enum order length: 165
| patch | name (READ) | diffs (unit-0 bytes 0..10512) |
| 3 | BS Solid | 0 |
| 0 | BR Eighties | 0 |
| 2 | (chillwave p2) | 0 |
| 4 | (chillwave p4) | 0 |
TOTAL differing cells: 0  [PROVEN — Unicorn, plugin's own enumerator-order 165-index dispatch vs port's 129-applied-index dispatch]
SCOPE CAVEAT: fullstate_diff2 diffs ONLY unit-0 state bytes 0..10512 (voice region). FX/master cells (e.g. 4297792 below, 102xxx, 10759xxx) are OUTSIDE its diff window, so this 0-diff does NOT clear the FX region. The dropped-enumerator-index hypothesis produces no voice-region state delta for these 4 patches.

== PROBE 2: DELAY TAP TIME (idx 1178) — IT IS CONTEXT-GATED. Full causal chain established ==
New probes: /home/user/jn60c99/scratchpad/chillwave_taptime_probe.py, chillwave_tap_activate.py, chillwave_tap_order.py.

(a) In BS Solid context (DELAY TYPE=0) and on a cold engine, dispatch(u,1178,v) for v in {0,25,50,75,100}, flag=1 AND flag=0, on all 9 units writes ZERO state cells. It writes exactly ONE proc-object cell: proc[u]+1508 = v (verbatim 4-byte store, value-dependent, all 9 units). [PROVEN]

(b) Wrong-selector control: sweeping idx 873 (= EFFECT TYPE, NOT delay type) 0..5 never enables 1178 and never calls 0x3B93E0. The true DELAY TYPE selector is idx 875 (Script.xml valindex 135, rec 650/blob 634 — note CLAUDE.md's "EFFECT TYPE (873)" and DELAY TYPE 875 are DIFFERENT leaves). [PROVEN]

(c) With DELAY TYPE mode = 1 (PAN DELAY) — set either by recall-role dispatch of 875=1 or by directly calling activation rva 0x3B93E0 — dispatch of 1178 writes exactly ONE f32 state cell per unit, offset 4297792 rel. state[u] (named "Tap Time" in gui/web/params.json, 2nd-delay-instance block), in ALL 9 unit states, VALUE-DEPENDENT [PROVEN]:
| tap byte | int arg 255*v/100 (trunc) | cell 4297792 bits | f32 |
| 0   | 0   | 0x00000000 | 0.0 |
| 25  | 63  | 0x3E7EFEFD | 0.247058824 = f32(63/255) |
| 50  | 127 | 0x3EFEFEFF | 0.498039216 = f32(127/255) |
| 75  | 191 | 0x3F3FBFC0 | 0.749019623 = f32(191/255) |
| 100 | 255 | 0x3F800000 | 1.0 |
Law: cell4297792 = f32((255*byte/100, C integer trunc)/255). In modes 0,2,3,4,5: 1178 writes NO state cells (proven for t in {0,5} via direct activation sweep and t in {0,2,3,4,5} via 875-recall sweep; ONLY t=1 is live).

(d) Causal chain (READ, decomp_380000.c): idx-1178 leaf setter = sub_7FF91E010980 @rva 0x3B0980 → cache store *(proc+1508)=v only. Constructor default *(proc+1508)=50 (line 13962). Reader = activation sub_7FF91E0193E0 @0x3B93E0 (proc vtbl+2560; also in vtables at rva 0x9C23F8, 0x9C2F08): sets mode *(proc+1480)=t, calls sub_7FF91E021010(*(proc+8),5,t), then replays ~20 cached params through vtable leaf setters incl. vtbl+2616 = sub_7FF91E0191E0 @0x3B91E0(proc, flag, cache[1508]). 0x3B91E0: `if (*(proc+1480)==1) call (subobj proc+6976)->vtbl+128 (rva 0x362FB0) with 255*v/100`. So tap time reaches DSP state ONLY through mode-1 activation.

(e) KEY EXECUTED FACT: recall-role dispatch of 875 (DELAY TYPE) CALLS 0x3B93E0 (exactly once, under flag=1 AND flag=0, for every value tried 0/1/5) and updates mode cache proc+1480. [PROVEN] (Contrast: idx 873 EFFECT TYPE never calls it — 0 times at v=0 and v=4 — consistent with the existing CLAUDE.md claim, which is about 873, not 875.)

(f) Enumerator order (0x3B48A0, executed): 165 unique dispatches; idx 875 at position 132, idx 1178 at position 139 → 875 BEFORE 1178. Therefore the plugin's OWN recall lands the patch's tap byte in cell 4297792 for every DELAY-TYPE-1 patch (mode set at pos 132, tap dispatched at pos 139; additionally 875's activation replays the cache, making it order-robust). [PROVEN]

(g) PORT GAP (engine-reachable, NOT controller-path): src/delay_recall.c DLY1_B freezes 4297792 = 0x3efefeff (= tap 50, the default) as a constant; src/master_render.c:947 reads it per-sample in the TYPE-1 render (`v437 = v433 * *(float *)(a1 + 4297792);` == plugin decomp_340000.c:25732) — an audible tap-position coefficient. The port never applies the patch byte → recall is wrong for ANY preset with tap != 50 on a TYPE-1 patch. Unlike the 8 DEFERRED-CONTROLLER rows, 1178 IS engine-dispatchable at recall (via 875-then-1178, both fired by the plugin's own enumerator). Identity at default, so no existing gate or factory/Chillwave patch is affected today, but per GOAL.md ("correct for ANY preset value") this is an applier gap: for dtype==1, write 4297792 = f32((255*b/100)/255) from record byte 3056.

(h) BS Solid's own DELAY TAP TIME record byte: PAT2_DLY struct order (READ, Script.xml lines 3412-3463): TAP TIME int1x7(1 rec byte), FEEDBACK int2x4(2), HIGH CUT int1x7(1), DIRECT LEVEL int2x4(2), then 4x int8x4(8 rec bytes each, dec read at field+6). Anchored on validated neighbors (1179→rec 3057, 1180→3059 raw, 1181→3060, 1182→3068, 1183→3076, 1184→3084, 1185→3092; reverb 3947-3951 confirm int1x7=1/int2x4=2 sizing) ⇒ TAP TIME = record byte 3056 = blob index 3040, raw &0x7F. [INFERRED — derived layout, not executed through the value tree; flagged per instructions rather than guessed silently. Consistency checks: BS Solid blob[3040]&0x7F = 50 (exactly the Script.xml default); neighbors decode FEEDBACK=120, HIGH CUT=7, DIRECT=255; the same map yields the known non-default HIGH CUT=3 on factory p2/p6.]

(i) Bank scans under that byte map [INFERRED via (h), decode itself executed on file bytes]:
FACTORY: DELAY TYPE histogram {0:29, 1:17, 2:10, 3:4, 4:0, 5:4}; 17 TYPE-1 patches, ALL tap=50; zero patches (of 64) with tap != 50.
CHILLWAVE: {0:11, 1:28, 2:8, 3:2, 4:7, 5:8}; 28 TYPE-1 patches, ALL tap=50; zero with tap != 50. BS Solid (patch 3): DELAY TYPE=0, tap=50.

== Relevance to the user-audible BS Solid bug ==
DELAY TAP TIME is RULED OUT for BS Solid: TYPE 0 makes 1178 fully inert (cache-only), and its tap byte is the default anyway. Probe 1 also shows the dropped-index set produces no voice-region (first 10512 bytes, unit 0) state delta at descriptor-default values for Chillwave 3/0/2/4. The mid-band deficit must lie elsewhere; note probe 1 never diffed the FX/master region (offsets > 10512 and unit 8) — a full-state (0..0xA83010) unit-8 diff of enumerator-set vs applied-set is the natural next lane.

Files: /home/user/jn60c99/scratchpad/chillwave_taptime_probe.py, /home/user/jn60c99/scratchpad/chillwave_tap_activate.py, /home/user/jn60c99/scratchpad/chillwave_tap_order.py (new probes); /home/user/jn60c99/scratchpad/fullstate_diff2.py (reused); /home/user/jn60c99/src/delay_recall.c:140,554; /home/user/jn60c99/src/master_render.c:947; /home/user/jn60c99/scratchpad/allcode/decomp_380000.c:13962,17404,24099-24240. No capture files were opened; all execution was single-process Unicorn oracle (libjuno never loaded).

## LANE names

### Key facts

- 165-index recall-enumerator set is confirmed two ways: READ from decomp sub_7FF91E0148A0 @ rva 0x3B48A0 (literal dispatch list) and PROVEN by executing it under Unicorn — identical sets
- READ: names come from the binary name table at rva 0x9a0030 stride 8 (ptr=*(u64*)(0x9a0030+8*idx), string at ptr-IB); fully populated idx 0..4965; anchor idx 12='Keyboard Velocity SW' matches recorded fact
- READ: descriptor DB rva 0x98c040+16*idx = [i32 min,max,default,tag] (= real_recall DESCVAL 0x98c048 minus 8)
- idx 20=MASTER TUNE; 128-141=Scale Select/Root + 12 'User Scale for <note>' offsets (SYSTEM); 189=MODEL(RO); 196=PATCH or PERFORM; 254=INPUT JACK USING
- idx 312-318=SCATTER CONTROL 1..7 (SETUP<SCAT>); 312-317 already ported as live MODULATION offsets (juno_mod.c), 318=SCATTER CONTROL 7
- idx 373=VOLUME, 375=TEMPO (SYN_COM synth-common)
- PRIORITY: idx 433-440='Note (voice 1..8)' def36, 450-457='Gate (voice 1..8)' def0, 467-474='Mute (voice 1..8)' def0, 484='ModuleCvOutVoice' — a 16-voice+CV live NOTE/GATE/MUTE runtime bus, NOT recall coefficients (table has voices 1..16 + CV/GATE, enumerator dispatches only 1..8)
- PROVEN(Unicorn): idx 450 'Gate (voice 1)' writes cells {320,1856(key-held broadcast),6864(VCF gate),9680(VCA)}; idx 467 'Mute (voice 1)' writes 9824 — i.e. the voice-1 note-on lifecycle cells; inert at recall because default gate=0/note=36
- idx 493=Pitch Bend(writes 4112/7456), 495=Modulation CC#1(writes 4000/7376), 498=Expression CC#11 — MIDI live controllers
- idx 553-555 = LFO RATE / VCF CUTOFF / BENDER 'GRF SW' = graphical GUI-feedback enable switches, not DSP
- idx 614=PERFORM MODE; 657/665/668/669 and 699/707/710/711 = PART SW/FINE TUNE/BEND/MOD for two PERFORM part slots (A and B)
- idx 878='LFO RATE H' (float twin of byte 752, writes 1088/2064) and 1029='VCF CUTOFF FREQ H' (float twin of byte 779, writes 6736) — redundant normalized-float mirrors; max 0x3F800000=1.0
- idx 1178='DELAY TAP TIME' (def50, no cells cold — context-gated by DELAY TYPE)
- STRUCTURAL: every dropped index <740 is a SYSTEM/SETUP/PERFORM/live-runtime param fed its DESCRIPTOR DEFAULT by the enumerator (Script.xml value-tree only produces dispatch>=748), so it is identity/no-op at recall on a matching cold engine
- The dropped set contains NO noise-level / filter-cutoff / per-patch synth coefficient (773 DCO NOISE, 779 VCF CUTOFF, 782 HPF, 1028/1058 vel-sens are all APPLIED) — so the 'BS Solid' mid-band deficit is not a dropped recall coefficient; the only audio-touching dropped indices are the live note/gate/velocity bus, consistent with a host note-path (#124) cause

### Full report

# LANE enum-names — identity of all 80 dropped recall-enumerator indices

## Provenance of the mapping (three independent sources agree)
- **165-index enumerator set**: READ from decomp `sub_7FF91E0148A0` @ rva 0x3B48A0 (extracted the 165 literal `setter(a1, IDX, 1, vN)` dispatches in document order) AND PROVEN by executing that enumerator under Unicorn (`enum_order2.py`, `plugin_recall_set.py`). The two sets are identical.
- **Names**: READ from the binary's full param name table at **rva 0x9a0030, stride 8 (`ptr = *(u64*)(0x9a0030 + 8*idx)`, string at `ptr-IB`)**. Anchors verified: idx 12 -> "Keyboard Velocity SW" (matches CLAUDE.md's recorded fact), 752 -> "LFO RATE", 873 -> "EFFECT TYPE", 1242 -> "FLANGER MANUAL". Table is fully populated for idx 0..4965 (4966 non-null entries, no out-of-image pointer). Static PE read only — no Unicorn, no libjuno.
- **min/max/default/groupTag**: READ from the engine descriptor DB at **rva 0x98c040 + 16*idx** (= `real_recall.DESCVAL 0x98c048` minus 8; layout `[i32 min, i32 max, i32 default, i32 tag]`). Anchors verified (760 DCO RANGE -> min0/max5/def3; 873 EFFECT TYPE -> 0/5/2).
- **Cell writes** (idx 450 etc.): PROVEN by executing `dispatch(0, idx, val)` under Unicorn with a MEM_WRITE hook (`map_all_dropped.py` -> `dropped_out.txt`, this session).

## The decisive structural fact
The recall enumerator dispatches indices spanning the engine's **entire global param index space**, not just the per-patch value tree. The Script.xml PATCH value-tree (the port's `leaf_table`) maps `dispatch = docpos + 740` and only produces indices **>=748**. Every dropped index **< 740 is therefore NOT a per-patch synth leaf** — it is a SYSTEM / SETUP / PERFORM / live-runtime param, and the enumerator feeds it its **descriptor DEFAULT** (`desc[i].value`), not a byte from the patch blob. On a port that boots to a matching cold state, dispatching them is identity/no-op (confirmed: most write no voice cells; those that do write default-valued cells).

## Semantic buckets for the 80 dropped indices (name = READ from 0x9a0030)

### 1. SYSTEM globals (groupTag byte2 = 0x00/0x0A/0x0C/0x0D)
| idx | name | min | max | default |
|----|------|----|----|----|
| 20 | MASTER TUNE | -100 | 100 | 0 |
| 128 | Scale Select | -1 | 7 | 0 |
| 129 | Scale Root | 0 | 11 | 0 |
| 130-141 | User Scale for C / C# / D / Eb / E / F / F# / G / G# / A / Bb / B (12 leaves) | -64 | 63 | 0 |
| 189 | MODEL (Read Only) | 2 | 2 | 2 |
| 196 | PATCH or PERFORM | 0 | 1 | 0 |
| 254 | INPUT JACK USING (SYSTEM1m) | 0 | 65535 | 0 |

### 2. SETUP / SCATTER (groupTag 0x0F0100) — SETUP<SCAT> document
| idx | name | min | max | default |
|----|------|----|----|----|
| 312-317 | SCATTER CONTROL 1..6 | -100 | 100 | 0 | (already ported = live MODULATION offsets, `juno_mod.c`) |
| 318 | SCATTER CONTROL 7 | -100 | 100 | 0 |

### 3. SYNTH-common (groupTag 0x130200) — SYN_COM
| idx | name | min | max | default |
|----|------|----|----|----|
| 373 | VOLUME | 0 | 255 | 128 |
| 375 | TEMPO | 400 | 3000 | 1280 |

### 4. Per-voice live NOTE/GATE/MUTE bus — the note-lifecycle runtime (groupTag 0x140200) — **PRIORITY**
This is a 16-voice + CV/GATE performance bus, NOT recall coefficients. The port sees only voices 1..8 in the enumerator's dispatched slice.
| idx | name | min | max | default |
|----|------|----|----|----|
| 433-440 | Note (voice 1..8) | 0 | 127 | 36 | (441-448 = Note voice 9..16, 449 = Note (CV/GATE) — not dispatched) |
| 450-457 | Gate (voice 1..8) | 0 | 127 | 0 |
| 467-474 | Mute (voice 1..8) | 0 | 1 | 0 |
| 484 | ModuleCvOutVoice | 0 | 15 | 0 |

**idx 450 "Gate (voice 1)"** cell writes (PROVEN, Unicorn): {320, **1856** key-held-broadcast, **6864** VCF gate, **9680** VCA} + idx 467 "Mute (voice 1)" -> 9824. These are exactly the note-on lifecycle cells for voice 1 — confirming this block is the **live note/gate path**, the same cells a NOTEON sets. Default gate=0 / note=36 makes it inert at recall on a cold engine.

### 5. MIDI live controllers (groupTag 0x150200)
| idx | name | min | max | default |
|----|------|----|----|----|
| 493 | Pitch Bend | -8192 | 8191 | 0 | writes {4112, 7456} |
| 495 | Modulation (CC#1) | 0 | 127 | 0 | writes {4000, 7376} |
| 498 | Expression (CC#11) | 0 | 127 | 127 |
(494 Pitch Bend (CV/GATE), 496 Volume CC#7, 497 Pan CC#10, 499 Hold Pedal CC#64 exist in the table but are NOT dispatched.)

### 6. Display / graphical-feedback switches (groupTag 0x160200)
| idx | name | min | max | default |
|----|------|----|----|----|
| 553 | LFO RATE GRF SW | 0 | 1 | 0 |
| 554 | VCF CUTOFF GRF SW | 0 | 1 | 0 |
| 555 | BENDER GRF SW | 0 | 1 | 0 |
("GRF SW" = graphical/GUI-feedback enable switches, not DSP.)

### 7. PERFORM / PART (groupTag 0x18/0x19/0x1A 0300) — two PART slots
| idx | name | min | max | default |
|----|------|----|----|----|
| 614 | PERFORM MODE | 0 | 1 | 0 |
| 657 | PART SW (part A) | 0 | 1 | 1 |
| 665 | PART FINE TUNE (part A) | -100 | 100 | 0 |
| 668 | PART BEND (part A) | 0 | 1 | 1 |
| 669 | PART MOD (part A) | 0 | 1 | 1 |
| 699 | PART SW (part B) | 0 | 1 | 1 |
| 707 | PART FINE TUNE (part B) | -100 | 100 | 0 |
| 710 | PART BEND (part B) | 0 | 1 | 1 |
| 711 | PART MOD (part B) | 0 | 1 | 1 |
(The two 657.. / 699.. runs are the identical PART parameter block for perform slot A and slot B; full block is PART SW/Slot/Model/Memory/LEVEL/PAN/OCTAVE/TRANSPOSE/FINE TUNE/KEY RANGE Bottom+Top/BEND/MOD/PEDAL HOLD/PEDAL EXPRESSION/SEQ MUTE, but only SW/FINE TUNE/BEND/MOD are dispatched by the enumerator.)

### 8. Float "H" twins + DELAY TAP (groupTag 0x2F/0x34/0x39)
| idx | name | min | max | default | note |
|----|------|----|----|----|----|
| 878 | LFO RATE H | 0 | 1065353216 | 1058115986 | float mirror of byte idx 752 LFO RATE; writes {1088, 2064}; redundant per CLAUDE.md |
| 1029 | VCF CUTOFF FREQ H | 0 | 1065353216 | 1065353216 | float mirror of byte idx 779 VCF CUTOFF; writes {6736}; byte-identical twin |
| 1178 | DELAY TAP TIME | 0 | 100 | 50 | no cells cold (context-gated by DELAY TYPE) |

(max 1065353216 = 0x3F800000 = float 1.0; default 1058115986 = 0x3F160E92 ~= 0.5865 for LFO RATE H — these carry a normalized float, hence the "H" = "high-res/host float" mirror.)

## Bearing on the "BS Solid" mid-band / "more noise oscillator" hypothesis
The dropped set contains **no noise-level, filter-cutoff, or per-patch synth coefficient leaf**. DCO NOISE LEVEL (773), VCF CUTOFF (779), HPF CUTOFF (782), VCF ENV MOD (783), VCF VEL SENS (1028), VCA VEL SENS (1058) are all in the **applied** set (per `enum_vs_applied.py`: EXTRA_LEAVES {1028,1058}, and 773/779/782/783 are value-tree leaves). So the mid-band deficit is **not** attributable to a dropped per-patch recall coefficient. The only dropped indices that touch audio at all are the **live note/gate/CC runtime bus** (bucket 4/5), whose descriptor defaults are inert at recall. This is consistent with the standing #124 conclusion that the residual is host-lifecycle (note/velocity path), not a missing recalled coefficient — the "more noise oscillator" character would have to come from the host driving the note/gate/velocity path differently, not from any coefficient in this dropped set.

## Files written (all in /home/user/jn60c99/scratchpad/)
- `enumnames_xmldump.py` -> `enumnames_xmldump.txt` (Script.xml value order + structType owners; confirms dispatch<748 are not PATCH-doc leaves)
- `enumnames_nametable.py`, `enumnames_nametable_full.py` -> `enumnames_windows.txt` (name-table windows around every dropped region)
- `enumnames_paramdb.py` (paramDB 0x5EC040 vs descriptor DB 0x98c040 decode)
- `enumnames_final_table.py` -> `enumnames_final_table.tsv` (the full 165-index authoritative table: idx / name / min / max / default / groupTag / applied|dropped)


## LANE settings

### Key facts

- PROVEN: There is ONE param descriptor table at PE rva 0x98c040 (16 bytes/row = int32 [min,max,default,flags]); accessor sub_7FF91E00BAF0 (rva 0x3ABAF0) returns &unk_7FF91E5EC040+16*i and 0x7FF91E5EC040-IDAbase(0x7FF91DC60000)=0x98C040, so the task's '0x5EC040 SYSTEM DB' and '0x98c040 engine descriptor' are the same table.
- READ: SYSTEM name table @ rva 0x9a0030 is a 4966-entry char* array (pairs 1:1 with the descriptor DB). fm.SYSTEM.COM.* = name indices 0..63; idx 12=Keyboard Velocity SW, 19=Master Tune(SYSTEM-1), 20=MASTER TUNE, 21=Boost Mode, 22=Output Gain, 49=Input Gain, 50=Patch Tempo Switch.
- READ: the engine's assignable-param list (builder sub_7FF91DF79D70 rva 0x319D70, strings sub_7FF91E03D990 rva 0x3DD990) has 95 entries; exactly ONE is fm.SYSTEM.COM.* = 'fm.SYSTEM.COM.MASTER TUNE' (entry 78) -> engine index 20. All other 94 are fm.PATCH.* front-panel or fm.PATCH2.* fine-FX or view-state.
- PROVEN: dispatch 0x3B9A30(proc,20,0,v) writes per-voice+master cell 368+v*10512; descriptor[20]=(-100,100,default 0). SYSTEM MASTER TUNE default == descriptor default == 0 (center) -> identity on a fresh host; only a user-tuned DAW would diverge.
- PROVEN: Boost Mode (idx 21, def 0) and Output Gain (idx 22, def 0) have transform-cases in the host param entry 0x3C7AE0 (Output Gain v13=a3-12) but dispatch writes ZERO engine cells on BOTH per-voice and master units -> they act on the output/boost stage, not synthesis; cannot change brightness via engine state.
- READ: connect path sub_7FF91DF80420 (rva 0x320420) refreshes only the Keyboard Velocity SW flag into byte a1+572 (*(a1+572)=ring-settings-getter!=0) plus transport tempo/samplerate; it pushes NO other SYSTEM value into the engine. Velocity SW policy is already ported (juno_gui_set_kbd_velocity).
- PROVEN: CONDITION (the JU-06A analog-aging/noise control the user's ear references) is idx 856, a PER-PATCH param (fm.PATCH.NAME2.CONDITION), descriptor default 128; it is ALREADY in the port's applied leaf_table (real_recall.leaf_table contains 856) and dispatch writes a large per-voice detune/character cell set. It is NOT a settings/connect gap.
- READ: IComponent::initialize's INI parse (key 'BufferObject/Value', sub_7FF91DEE4880 rva 0x284880) is the plugin activation/licensing buffer, NOT synth parameters; there is no separate SYSTEM-defaults block differing from the descriptor DB. Fresh-install engine-relevant SYSTEM defaults (20/21/22) are all center/off.
- CONCLUSION: the connect/sync + persistent SETTINGS hypothesis is REFUTED as the source of the patch-independent BS Solid mid-band deficit; the only SYSTEM->engine mapping is MASTER TUNE (identity at default). Remaining candidates are the note/velocity lifecycle lane and recall completeness of the 36 dropped enumerator indices (checked with BS Solid's actual blob values), not the settings object.
- PROVEN: descriptor defaults for the other dropped/controller indices are all neutral (identity when undriven): 493 PitchBend def0, 495 Mod(CC1) def0, 496 Volume(CC7) def127, 497 Pan(CC10) def64, 498 Expression(CC11) def127, 499 Hold def0, 433 Note def36, 450 Gate def0, 467 Mute def0, 373 VOLUME def128, 249 OCTAVE def3, 374 TRANSPOSE def0.

### Full report

LANE connect-settings — findings. Goal: determine what a REAL host's controller->processor connect/sync path and the persistent SETTINGS object push into the ENGINE that our recall does not, as a candidate for the patch-independent, host-independent "BS Solid mid-band deficit / more noise oscillator" bug.

VERDICT: REFUTED. The connect/settings path pushes NOTHING into the per-unit engine value tree that our recall+build does not already establish at its correct default. Exactly ONE SYSTEM param (MASTER TUNE, engine idx 20) reaches the engine value-tree dispatch, and it is the identity at its descriptor default 0 (center). Boost Mode (21) and Output Gain (22) have transform-cases in the host param entry but dispatch to ZERO engine cells (output/boost stage, not synthesis). The connect path (0x320420) refreshes only the Keyboard Velocity SW flag (byte +572) from the settings object — already ported. So a fresh real host does NOT put the engine's per-voice/master coefficients in a different base state via settings.

=== KEY STRUCTURAL FACT (resolves an apparent two-table confusion) ===
There is only ONE param descriptor table. The task's "SYSTEM param DB @ rva 0x5EC040" and "engine descriptor @ rva 0x98c040" are the SAME table. PROVEN by reading the accessor: sub_7FF91E00BAF0(i) (rva 0x3ABAF0) returns `&unk_7FF91E5EC040 + 16*i`; IDA VA 0x7FF91E5EC040 minus IDA base 0x7FF91DC60000 = PE rva 0x98C040. Row layout = 4x int32 [min, max, value/default, flags]; the recall enumerator reads field[2] (offset +8) as the dispatch value (matches tools/verify/real_recall.py DESCVAL=0x98c048). My earlier "table A @0x5EC040" dump was reading code bytes and is discarded; the "table B @0x98c040" dump is authoritative.

=== Q1: SYSTEM name table @ rva 0x9a0030 (READ, pefile qword-ptr array; IDA base 0x7FF91DC60000) ===
Array of 4966 char* pointers (same cardinality as the descriptor DB — name[i] pairs with DB[i]). The fm.SYSTEM.COM.* block is indices 0..63 (rest of 0..255 are mostly _reserve_/_NULL_):
0 LCD Contrast; 1 LED Brightness; 2 KNOB INDICATOR; 3 Auto Power Off; 4 Startup; 5 Startup PATCH Model; 6 Startup PATCH Memory; 7 Startup PERFORM; 8 Knob Mode; 9 LED Demo; 10 Shop Mode; 11 USB Driver; 12 Keyboard Velocity SW; 13 Keyboard Fixed Velocity; 14 Keyboard Velocity Curve; 15 Keyboard Velocity Offset; 16 HOLD PEDAL Polarity; 17 EXPRESSION PEDAL Polarity; 18 Local SW; 19 Master Tune (SYSTEM-1); 20 MASTER TUNE; 21 Boost Mode; 22 Output Gain; 23 Tempo Sync; 24 Start/Stop; 25 Sync Output; 26-28 Click(Metronome) Mode/Level/Type; 29 MIDI Device ID; 30 Remote Keyboard; 31 MIDI Omni Mode; 32-35 MIDI Channel PATCH/PERFORM/Upper/Lower; 36-43 MIDI Tx/Rx Program/Bank/Edit + USB-MIDI/MIDI Thru; 44-46 CLOCK(CV) IN Fine Tune/Key Follow/Assign; 48 Realtime Rec Mode; 49 Input Gain; 50 Patch Tempo Switch; 60-63 PLUG-OUT Model 0-3. (128-141 Scale Select/Root/User Scale C..B; 189 MODEL; 196 PATCH or PERFORM; 249 OCTAVE; 250 KEY HOLD; 252 TEMPO; 253 INPUT; 254 INPUT JACK USING; 310-319 SCATTER; 373 VOLUME; 374 TRANSPOSE; 375 TEMPO — these are runtime/global, not SYSTEM.COM.) Front-panel patch params are 750-877; extended 1028-1327.

=== Q2: which SYSTEM params reach ENGINE dispatch ===
The engine's assignable-param name list is built by sub_7FF91DF79D70 (rva 0x319D70), fed from the 95-entry string table sub_7FF91E03D990 (rva 0x3DD990). PROVEN by resolving every off_* string (scratchpad/cs_resolve_offs.py): entries 0-54 are fm.PATCH.* front-panel (LFO/OSC/MIX/FLT/AMP/EFX/CTRL/EXTEND/NAME1-3), 55-77 are fm.PATCH2.* (VELOCITY SENS, fine-FX DELAY/CHORUS/FLANGER/REVERB), and entry 78 is the ONLY fm.SYSTEM.COM.* member: "fm.SYSTEM.COM.MASTER TUNE" -> engine index 20. 79-94 are NAME chars + vm.vs.* view state. Host param automation flows paramID -> host entry 0x3C7AE0 (engine vtable+112) -> 0x3B9A30 on all 9 units, gated by this list. So the sole SYSTEM->engine mapping is MASTER TUNE -> idx 20. Index 20 IS in the task's dropped set — but see Q3, it is identity at default. MIDI CC/bend/note events take a DIFFERENT path (queue consumer 0x320B20 -> note-object vtable slots +112/120/128/136/152/160, not the SYSTEM param DB), so they are the note-path lane's concern, not settings.

=== Q3: defaults vs descriptor defaults for the mapped/dropped indices (PROVEN under Unicorn; scratchpad/cs_dispatch_probe.py + cs_master_probe.py) ===
Dispatching 0x3B9A30(proc, idx, 0, v) and hooking engine writes:
- idx 20 MASTER TUNE: descriptor row (-100,100, def=0). Writes per-voice+master cell 368+v*10512 (368,10880,...73952). SYSTEM default == descriptor default == 0 (center). Since the value the recall enumerator / build applies is 0 and the port's cold state already holds cell 368 at that value, applying-or-dropping idx 20 is IDENTITY on a fresh host. Only a non-default MASTER TUNE (user tuned the DAW) would diverge — not a fresh/patch-independent state.
- idx 21 Boost Mode (def 0) and idx 22 Output Gain (def 0): 0x3C7AE0 has transform cases (Boost generic; Output Gain v13=a3-12) BUT dispatch writes ZERO engine cells on both per-voice AND master units. They are applied by the output/boost stage (the a1+96 gain object set up in 0x320420 / master out 0x398EC0), NOT the per-unit synthesis engine. Cannot cause brightness/mid-band change via engine state.
- Other dropped-set indices are runtime MIDI/controller, all neutral at default: 433 Note def36, 450 Gate def0, 467 Mute def0, 484 ModuleCvOut def0, 493 Pitch Bend def0, 495 Mod(CC1) def0, 496 Volume(CC7) def127, 497 Pan(CC10) def64, 498 Expression(CC11) def127, 499 Hold def0; 249 OCTAVE def3, 373 VOLUME def128, 374 TRANSPOSE def0, 375 TEMPO def1280. At their defaults these are identity (no bend, no mod, full expression/volume). They are driven only by live MIDI (note-path lane), not by the settings object.

=== Q4: named-param hunt (Boost/Output/MasterTune/CONDITION/Local/KbdVel/Bend/Mod/Octave/Transpose/Noise) ===
- MASTER TUNE (20): engine idx 20, default 0 = descriptor default. Pitch, not brightness.
- Boost Mode (21) / Output Gain (22): output stage, no engine cells (above).
- Keyboard Velocity SW (12, def 0): loaded by the connect path 0x320420 into byte a1+572 (READ: `*(a1+572) = (ring-settings getter)!=0`), consumed by the MIDI vel policy (SW OFF -> force note-on vel 100) — ALREADY ported (juno_gui_set_kbd_velocity). Not an engine base-state cell.
- Local SW (18), Bend Range lives per-patch (idx 801, recalled), Mod depth/Octave/Transpose here are SYSTEM/global runtime, all default-neutral, none map into the engine value tree via the connect list.
- CONDITION — this is the JU-06A analog-aging/noise control the user's ear references. It is idx 856, a PER-PATCH param (fm.PATCH.NAME2.CONDITION, connect-list entry 42), descriptor default 128 (center = no aging). It is ALREADY in the port's applied leaf_table (real_recall.leaf_table contains 856 -> the port recalls it per patch). PROVEN dispatch(856) writes a large detune/character cell set (3968,5520,7600,10320,... per voice). So CONDITION is NOT a settings/connect gap; if BS Solid's "more noise oscillator" is a CONDITION mismatch it is a RECALL-value/position issue (does the port read BS Solid's CONDITION byte at the right blob offset?), which is the recall-completeness lane, not connect-settings.

=== SETTINGS OBJECT / CIniProfile ===
IComponent::initialize's INI parse targets key "BufferObject/Value" (sub_7FF91DEE4880 @ rva 0x284880, two sites) — this is the plugin ACTIVATION/licensing buffer (a {name,value} list), NOT synth parameters. sub_7FF91E0416A0 (0x3E16A0) is a generic CSV/whitespace token trimmer, not a defaults table. There is no separate SYSTEM-defaults constant block that differs from the descriptor DB (0x98c040): the DB field[2] IS the fresh-install default for each SYSTEM param, and every engine-relevant one (20/21/22) defaults to center/off. So "fresh install with no settings file" leaves the engine at descriptor defaults = the port's build state.

=== CONCLUSION for this lane ===
The connect/sync path and persistent SETTINGS object are NOT the source of the patch-independent audible deficit. The only SYSTEM value that reaches engine synthesis is MASTER TUNE, identity at its default 0. The bug surface therefore lies elsewhere: (a) the note-path/velocity lifecycle lane (live MIDI-driven indices 493/495/498 etc.), or (b) recall completeness — the 36 dropped enumerator indices whose PER-PATCH value for BS Solid may be non-default (esp. CONDITION 856 already-applied-but-check-position, and the voice-region writers idx 450->{320,1856,6864,9680,9824}, 493->{4112,7456}, 495->{4000,7376} noted in the task). Those must be checked with BS Solid's actual blob value, not the settings object.

Provenance: SYSTEM name table + descriptor DB rows = READ (pefile static read of truth/JUNO60.vst3, scratchpad/cs_dump_systable2.py, cs_dump_paramdb.py, cs_dump_full.py); connect-list resolution = READ (scratchpad/cs_resolve_offs.py + decomp sub_7FF91E03D990); 0x320420/0x320B20/0x3C7AE0 control flow = READ (refs decomp). Engine-cell writes per dispatched index + descriptor default values read live = PROVEN(executed under Unicorn, e2e_emu only, scratchpad/cs_dispatch_probe.py, cs_master_probe.py). Two-process rule honored (no libjuno import in any probe).

## LANE cells

### Key facts

- READ: all 14 candidate cells are read by voice_render.c; none by master_render.c (grep, file:line in report)
- READ: audio noise mix = voice_render.c:1127 JF(6544) = (6432*4320_noiseSVF)*JF(6528) + (6448*3536_DCOmix)*JF(6512); 6528 = DCO NOISE LEVEL (juno_apply.c:221, blob 29, curve 54) is the ONLY patch-dependent noise gain
- READ: none of the 14 dropped-index cells is in the audio-noise multiply chain
- READ (binary name table 0x9a0030, static PE read): idx 20=MASTER TUNE(dflt 0)->368; 433=Note voice1(dflt 36)->304; 450-457=Gate voice1-8(dflt 0)->{320,1856,6864,9680,9824}; 467=Mute voice1(dflt 0)->9824; 493=Pitch Bend(dflt 0)->{4112,7456}; 495=Modulation CC#1(dflt 0)->{4000,7376}; 878=LFO RATE H; 1029=VCF CUTOFF FREQ H; 1178=DELAY TAP TIME
- READ: every dropped index is IDENTITY at its descriptor default (Note=36 == prepare's 304=2.000303; all others default 0 == port's unwritten-0/note-rewritten state)
- READ: cells 368/384/4000/4112/7376/7456/2048/84304 have NO writer anywhere in src/*.c (stay 0 in port)
- READ: MASTER TUNE cell 368 (+384) -> v61 -> cell 880 (voice_render.c:702-710) feeds BOTH DCO pitch (880->3616->3776 sum, :1057-1061) AND VCF key-follow CV (6976 = 880+752, :1157, * VCF KEY FOLLOW 7408 :1205) — the only dropped-cell path that statically shifts VCF frequency (mid-band suspect)
- READ: mod bus 1808 noise term = 2048*1408 (voice_render.c:936); 2048 unwritten -> noise-as-mod-source DEAD in port; PROVEN (coldstate_ab gate): plugin power-on state bit-identical -> 2048=0 there too
- READ: 4000/7376 (Modulation CC#1) gate the shaped-LFO mod bus into DCO pitch and VCF cutoff; dead at CC#1=0, live only with non-default controller values
- READ: 9824 = per-voice MUTE gain (idx 467): smoothed at 9856 and multiplies the final voice output JF(10672) at voice_render.c:1618; juno_note.c:194 rewrites 1.0 every note-on
- READ: 2064 (LFO RATE mirror, recalled juno_apply.c:216) is the raw-vs-smoothed NOISE crossfade weight in the mod-source conditioner (voice_render.c:833-834) — not in the audio-noise path
- INFERRED: prime suspects for the real-host 'more noise'/mid-band delta are non-default MASTER TUNE (368/384->880) or live CC#1/bend (4000/7376/4112/7456); cell 384's writer param is unidentified and needs an emulation probe

### Full report

LANE cell-semantics — full cell -> (render-read?, port-writer, meaning) table with file:line provenance.
Accessor idiom: voice_render.c uses JF/JI(a1|base, OFFSET) (juno_engine.h:39-40); a1 = per-voice base (voice*10512), base = shared block [84272,84432]. All render-dataflow claims are READ (grep of the transcribed DSP src/voice_render.c, itself PROVEN bit-exact by the standing render-A/B gates). Dropped-index NAMES/min/max/default are READ from the binary's own name table rva 0x9a0030 + descriptor DB 0x98c040 (static pefile read, scratchpad/enumnames_final_table.py, executed this lane — no emulation, no captures). master_render.c reads NONE of the 14 cells (grep: zero hits).

=== TABLE: the 14 dropped-index voice cells ===

CELL 304 — M.CV note pitch. RENDER-READ: voice_render.c:632 (v27; copied to 336, conditioned into v28 -> 464 at :637 = the DCO pitch CV; juno_note.c:27 documents v28==state[304] with portamento off). PORT WRITER: juno_note.c note-on (juno_mcv_bits[], immediate, PITCH_OFF=304 at :97) + juno_prepare.c:68 JI=0x400004f7 (2.000303). DROPPED IDX: 433 = "Note (voice 1)", range 0..127 DEFAULT 36 — and (36-12)/12 + stretch = 2.000303 = exactly the prepare default, so enumerator-dispatch-at-default == port state (identity). Overwritten by every note-on. NOT a suspect.

CELL 320 — M.Gate. RENDER-READ: voice_render.c:565,569,571 (read+one-shot clear via aux latch), :2155 restore; collapses to binary state[560] gating both ADSRs (juno_note.c:43-58). PORT WRITER: juno_note.c note-on/off (GATE_OFF=320 :98). DROPPED IDX: 450 = "Gate (voice 1)", 0..127 DEFAULT 0 (dispatch writes the whole gate-notify family {320,1856,6864,9680,9824} — exactly the cells juno_note.c writes). Default 0 = gate closed = port's recall-time state. NOT a suspect.

CELL 368 — MASTER TUNE CV. RENDER-READ: voice_render.c:604 (v14) -> copy 400 (:619, never re-read) BUT ALSO live at :707 v61 = v57 + v14*JF(a1,848) [848=1.0 juno_init.c:924] -> cell 880 (:710). 880 is read TWICE: :1057 v168 -> :1059 v169 = 880*3600 + 752*3584 -> 3616 -> the DCO pitch sum 3776 (:1086-1092); and :1155 -> :1157 JF(6976) = 880*6960 + 752*6944 [both 1.0, juno_init.c:1069-70] -> :1205 VCF term (6976 + 7488[-1.0 init:1077]) * 7408 [7408 = VCF KEY FOLLOW, recalled juno_apply.c:195]. So MASTER TUNE shifts BOTH DCO pitch and the VCF key-follow CV. PORT WRITER: NONE anywhere in src (stays 0). DROPPED IDX: 20 = "MASTER TUNE", -100..100 DEFAULT 0 (identity at default; a system-settings value, host-carried). SUSPECT if the user's host has non-zero master tune.

CELL 384 — second tune-CV summand (INFERRED: fine-tune sibling). RENDER-READ: voice_render.c:606 (v16) -> copy 416 (:620, never re-read) + live at :702 v57 = v16*JF(a1,864) [864=1.0 init:925] -> same 880 sum as 368 (same downstream: DCO pitch + VCF key CV). PORT WRITER: NONE. Plugin-side writer NOT identified in this lane (not among the given dropped-cell map) — recommend an emulation probe for which param writes 384.

CELL 1088 — LFO RATE (conditioner input). RENDER-READ: voice_render.c:763; v70 = 1088 crossfaded by 1040, clamp 0..1, expf(v*1200)*1184 + 1216 -> LFO frequency -> phase increment (:775-800). PORT WRITER: juno_apply.c:215 binding {8, curve22, 1088} + juno_prepare.c:240 (0.56862748). DROPPED IDX: 878 = "LFO RATE H" (raw-float twin, default bits 1058115986) — session probes verified byte-identical to the byte path (given). NOT a suspect.

CELL 2064 — LFO RATE mirror, used as the NOISE-mod-source slew crossfade. RENDER-READ: voice_render.c:833-834: v102 = v95 + 2064*(v101*2448 - v95), where v95 = cell 1424 (per-voice copy of shared noise 84432, written :791) and v101 = one-pole smoothed noise (states 1568/1584, coeff 2464 = juno_init.c:963 bits 1013491486; gain 2448 = init:962 bits 1096810496); then :848 JF(1408) = v102 * 2432 [0.5, init:961]. PORT WRITER: juno_apply.c:216 {8, curve22, 2064} + prepare:242. So 2064 shapes the RANDOM-LFO mod source — but its consumer term is dead (see 2048 below). NOT an audio-noise suspect.

CELL 1856 — "any key held" broadcast flag. RENDER-READ: voice_render.c:794 (v84 -> 1840 copy; v85 = v79+v84 clamp +-1 -> 1488 free-run/arp gating seed). PORT WRITER: juno_note.c:193 (gate-notify 1.0) + :218 broadcast to all 8 voices. DROPPED IDX: 450..457 = "Gate (voice 1..8)" (the 1856 write is the value-independent broadcast; voices 2..8 write their own regions, only 1856 lands in unit-0 — consistent with the probe's <10512 window). Already ported (juno_note_broadcast_held). NOT a suspect.

CELL 4000 — MOD WHEEL amount -> DCO. RENDER-READ: voice_render.c:1078: v182 = (3984 * (4016 * 1808)) * 4000 -> 3744 (:1079) -> pitch-mod sum 3824/3776. 3984 = Mod depth DCO (recalled, juno_apply.c:454), 4016 = 1.0 (prepare:81), 1808 = the mod bus (below). PORT WRITER: NONE (0 -> term dead). DROPPED IDX: 495 = "Modulation (CC#1)", 0..127 DEFAULT 0 (also writes 7376). Identity at CC#1=0; live-audible only if the host sends/stores CC#1.

CELL 4112 — PITCH BEND amount -> DCO. RENDER-READ: voice_render.c:1074: v184 = (4112 + 3856*(3680 - 4112)) * 4128 [bend depth DCO, recalled juno_apply.c:452] -> 3760 (:1082) -> pitch sum. PORT WRITER: NONE (juno_apply.c:432-435 documents it as live bend/mod amount, 0 at rest). DROPPED IDX: 493 = "Pitch Bend", -8192..8191 DEFAULT 0 (also writes 7456). Identity at 0.

CELL 6736 — VCF CUTOFF FREQ (coarse). RENDER-READ: voice_render.c:1133-1134: v200 = 6736 + 6720*(6576 - 6736) -> cutoff polynomial (6752..6816) -> 6704. PORT WRITER: juno_apply.c:169 {35, curve22, 6736} + prepare:255 (1.0). DROPPED IDX: 1029 = "VCF CUTOFF FREQ H" — verified byte-identical twin of idx 779 (given). NOT a suspect.

CELL 6864 — VCF velocity coefficient. RENDER-READ: voice_render.c:1149 -> smoother 6896 (coeff 6928). PORT WRITER: juno_note.c:189/:268 = juno_curve(56, velocity). Part of the idx-450 gate-notify family. Already ported (incl. wrapper velocity policy). NOT a suspect.

CELL 7376 — MOD WHEEL amount -> VCF. RENDER-READ: voice_render.c:1201: (crossfade(v221*v225 -> by 7312) * 7360 [Mod depth VCF, recalled juno_apply.c:455]) * 7376, summed into the VCF cutoff-mod v227 -> 7280. v221 = smoothed mod bus 1808 (smoother 7168/7184/7200/7216, gain 7232). PORT WRITER: NONE (0 -> term dead). DROPPED IDX: 495 (CC#1), DEFAULT 0.

CELL 7456 — PITCH BEND amount -> VCF. RENDER-READ: voice_render.c:1191-1192: (v227*7328 - 7456*7328) + 7456, then *7472 [bend depth VCF, recalled juno_apply.c:453] in the cutoff-mod sum. PORT WRITER: NONE. DROPPED IDX: 493 (Pitch Bend), DEFAULT 0.

CELL 9680 — VCA velocity coefficient. RENDER-READ: voice_render.c:1499 -> smoother 9712 (coeff 9744) -> 9760 (:1507, crossfade with 9664 by 9648) -> 9776 (coeff 9808) -> multiplies the FINAL voice output: :1616 v384 = v383 * JF(9776). PORT WRITER: juno_note.c:190/:269 = juno_curve(57, velocity). NOT a suspect.

CELL 9824 — per-voice MUTE gain target. RENDER-READ: voice_render.c:1517 -> smoother 9856 (coeff 9888, init juno_init.c:1143) -> multiplies the FINAL voice output: :1618 JF(10672) = v384 * JF(9856); 10672 is the voice out (*outL, :2158). PORT WRITER: juno_prepare.c:91 (1.0) + juno_note.c:194 (1.0 at gate-notify). DROPPED IDX: 467 = "Mute (voice 1)", 0..1 DEFAULT 0 (unmuted). Note-on rewrites 1.0; identity in practice. NOT a suspect.

(idx 1178 = "DELAY TAP TIME" 0..100 dflt 50 — writes no voice cells cold; outside this lane's voice-cell scope.)

=== NOISE PATH (the user-audible question) ===

NOISE LEVEL recall cell = 6528: juno_apply.c:221 binding {blob 29, curve 54, cell 6528} "DCO NOISE LEVEL".

AUDIO noise chain (all READ, voice_render.c):
1. Shared LFSR (per-sample, chained across the 8 voice calls): 84336 updated :578-621 (24-bit LFSR, v20 = bits * 5.9604645e-8 -> JF(base,84336) :621). Scale: :622 84368 = 84336*84400 + 84416; 84400 = juno_init.c:2870 (v182 = 1.0f [init:416] or bits 1069341347 [init:719], rate-branch), 84416 = 0 (init:2871). Crossfade :625-631: 84432 = 84368 + 84304*(84272 - 84368); 84272 = 0 (chorus_init.c:2472), 84304 = NO WRITER anywhere -> 0 -> 84432 == 84368 (pure scaled LFSR).
2. Per-voice audio branch: :1107 v190 = JF(base,84432) -> SVF states 4288/4304/4320 (:1110-1119), coefficients 4336 = v31 rate-dep (juno_init.c:993), 4352 = 2.0 (:994), 4368 = bits -1097229926 (:995), 4384 = 0 (:996), 4400 = bits 1067030938 (:997). Colored-noise output = 4320.
3. Mix into VCF input: :1120-1127: v199 = 6432 * 4320 [6432 = z-copy of 6416 = 1.0, juno_init.c:1062]; v198 = 6448 * 3536 [6448 = 1.0 "osc enable" juno_prepare.c:75; 3536 = z-copy (:1054) of 3520 = the voice's own DCO/HPF output v526, written :2152]. THE MIX: :1127 JF(6544) = v199 * JF(6528) + v198 * JF(6512) [6512 = 1.007365, juno_prepare.c:84]. 6544 is the VCF ladder input (:1276 v242). => The ONLY patch-dependent scalar on the audio noise is 6528 (recalled, exhaustively gated). NONE of the 14 dropped-index cells is in this multiply chain.

NOISE as MOD source (all READ): 84432 -> JI(a1,1424) (:791) -> one-pole 1568/1584 (coeff 2464) -> crossfade by CELL 2064 with gain 2448 (:833-834) -> 1408 = *2432 (:848) -> mod bus term :936 "+ JF(2048) * JF(1408)". CELL 2048 HAS NO WRITER in any src file (grep: NONE) -> 0 in the port; the plugin's power-on is bit-identical (coldstate_ab PROVEN) -> 0 there too; 2048 is not in any known dropped-index cell set. => the noise-mod source is DEAD on both sides at rest. Mod bus 1808 (:920-936) = 1968*1728 + 2032*1760 + 2000*1680 + 2016*1696 + 1984*1712 + 1952*1744 + 2048*1408; only 1952 = 1.0 (prepare:77) is non-zero, so bus = shaped-LFO term v117 = poly(|LFO+2336|)*2400 [2.0, juno_init.c:959]. Bus reaches audio three ways: (a) LFO bus 1792 += 2080[1.0, prepare:78]*v120[LFO-delay window]*1808 (:939-941) -> DCO via 4032 (DCO LFO MOD, recalled) and VCF via 7344 (VCF LFO MOD, recalled) — LIVE in port; (b) direct DCO via 3984*4016*CELL 4000 — dead at CC#1=0; (c) direct VCF via 7360*CELL 7376 — dead at CC#1=0.

=== VERDICT (labeled) ===
- READ: No dropped-index cell scales the audio noise oscillator. Its only patch-dependent gain is 6528 (already recalled + exhaustively gated). The literal "more noise" cannot come from these 14 cells at their descriptor DEFAULTS — every one is identity at default (Note=36 == prepare's 2.000303; Gate/Mute/Bend/CC1/MasterTune = 0).
- INFERRED (prime suspects if a real host carries NON-default controller values): (1) idx 20 MASTER TUNE -> 368 -> 880 biases the VCF key-follow CV (880 enters cutoff via 6976*7408) AND DCO pitch — the only dropped-cell path that statically shifts VCF frequency, matching a mid-band (780-2200 Hz) spectral shift; (2) idx 495 CC#1 -> 4000/7376 opens the shaped-LFO bus into DCO pitch + VCF cutoff (motion that could read as "noisier"); (3) idx 493 Pitch Bend -> 4112/7456 same class. (4) CELL 384 (unknown writer, unit-gain summand into the same 880 tune CV) deserves an emulation probe to identify its writer param.
- INFERRED: cells 1968/1984/2000/2016/2032/2048 are the engine's mod-source (LFO-waveform) select gains; 2048 = the noise/random waveform's gain — if any live/system param sets 2048 nonzero, the noise WOULD enter the LFO bus; no such writer is known.
- Honest residual: 400/416 (the conditioned copies of 368/384) are write-only in voice_render; the live consumers are the direct reads at :604/:606 feeding v61 -> 880.