# JP8 S3_STATUS.md -- JUPITER-8 PLUG-OUT .vst3 -> C99 port (PORT_PIPELINE steps 0-4 DONE, step 5 layers 1-2 GREEN, later layers open)
Repo layout (moved from the ephemeral scratchpad 2026-09-22): `jp8/truth/` (checksummed, clean names,
SHA256SUMS), `jp8/tools/` (oracle `jp8_emu.py` + probes; every `gen/*.py` named below now lives here),
`jp8/logs/` (every log named below), `jp8/docs/` (this file, `abi_ledger.md/.json`), `jp8/gen/params.tsv`,
`jp8/work/` (disassembly + scratch). Smoke after the move: boot 841/845 ok, faults 0 after static init,
patch 2 note renders, NaN 0 (2026-09-22, this session).

Last update: 2026-09-22 (fourth agent: D4 resolved, boot recipe corrected to the flag-0 recall = D6, 64-patch sweep, step 5 started). Every number below has a log in jp8/logs/ (named per line).
Labels: PROVEN = executed under Unicorn on the plugin's own code; READ = static disassembly; INFERRED = deduction.

| # | Step | State | Label |
|---|------|-------|-------|
| 0 | Intake | DONE: truth/SHA256SUMS, 16 files (.vst3, Script*.xml, 3x Code8_N.Dat, 1_Preset.bin, TextCodeTable.dat) | PROVEN (checksummed) |
| 1 | Census | params.tsv 5223 rows (name table 0xA30D70, engine DB 0xA1CD80); XC ctor table 845 entries, 841 run, 3 skipped by address, .data tail 3441 B filled; BUILD = 9 x 0xA9C0C0 (recon_boot.log). recon.json not produced (pe_recon `all --json` never run) | READ + PROVEN(boot) |
| 2 | ABI ledger | DONE: gen/abi_ledger.md + abi_ledger.json. BUILD 0x445020 (rcx); SETSR 0x4464F0 (rcx, rate = FLOAT in xmm1, playbook 87 holds); RENDER 0x445DC0 (rcx, r9, stack arg6 nframes -- the HOST process, not the oracle drive); HOSTPARAM 0x4465B0 (rcx, edx host id, r8d value; host map root .data 0xD22478 = {0:18,1:19,2:20}); NOTEON 0x445CF0 / NOTEOFF 0x445C90 (rcx, dl note, r8b vel); DISPATCH 0x437630 (rcx proc, edx id, r8 flag, r9 value); ASG_NOTIFY 0x37CD80; VOICE_WRAP 0x3F80B0 / MASTER_WRAP 0x3F8040 (the JX idiom byte for byte). CJp8Sim vtable 0xA1B678 = the per-unit STATE class, not the entry set. Addendum 2026-09-22: DISPATCH flag 1 = engine frame applied at once (PROVEN); SETSR chain and the 44100-vs-generic table branch (READ) | READ (abi_check) + PROVEN where marked |
| 3 | Boot | PASS: static init 841/845 -> BUILD -> SETSR(float) -> FTZ -> host_init 3 writes via host_map() -> recall in the ENGINE frame WITH DISPATCH FLAG 0 (the HOSTPARAM path; D6, 2026-09-22) -> SNAP 379 ramps/unit + clear latch 960. Faults: 1 in static init (ctor #1 rva 0xB720C, the JX template condition: cookie-decoded null pointer, one stray page), 0 from BUILD on. IDLE 12000: master NaN 0, peak 1.6e-13, dry 0 (listen_p0_n60.log; listen2_*.log idle PASS x7) | PROVEN |
| 4 | Listen proof | Before D6 (flag-1 recall, half-defaulted patches): GREEN on patches 2, 10, 52, 63 at 44100 (listen2_sr44100_p*.log), patch 2 at 96000; 48000 = -12 semis = D3. AFTER D6 (flag-0 recall): the RANGE / FINE TUNE / SUB RANGE law PROVEN to the cent on keys 48/60/72 (d4_probe_p2_*.log, D4) and patch 0 settles on its law (d4_windows_p0_k60.log); the 64-patch sweep on the corrected drive is the step-4 reach: SWEEP_44100.md (jp8_sweep.py, one log per patch in logs/sweep44100/) | PROVEN at 44100 |
| 5 | Transcribe (layers 1-2: render + note path; recall path) | GREEN 2026-09-22: no IDA dump exists for the JP8, so `jp8_lift.py` LIFTS the machine code mechanically (x86-64 -> C99, one statement per instruction, jp8/src/jp8_lift.c: 270 functions / 79535 instructions from VOICE_WRAP 0x3F80B0, MASTER_WRAP 0x3F8040, NOTEON 0x445CF0, NOTEOFF 0x445C90, DISPATCH 0x437630, ASG_NOTIFY 0x37CD80 + every indirect target the TB-flushed dynamic reach saw; 228 trap sites = AVX/CRT-dispatch paths never reached, a trap turns the gate red). Gate `jp8_lift_gate.sh` (JP8_LIFT_LAYER=render): the C twin maps the oracle's regions at the SAME addresses, loads the post-warm-up dumps and replays the judged event list -- 64 samples held, NOTEON 67, 64 more, NOTEOFF 60+67, 64 release -- on patches 2, 63, 10, 0: 13,824 output words (8 voices main/sub + master L/R x 192 samples) and the whole 102.8 MB heap EXACTLY 0 on every patch (logs/lift_gate_layer1.log). TOOTH: `--tooth 0x3965cb` (the VCO1 RANGE addss -> subss) FAILS: "patch 63: state differs at state[0]+0x1170: oracle 913db6bc C b1ddf03d", 122 differences. Reach stated: key 60 (+67), 44100, 256 warm samples, 192 judged, 4 patches, every heap byte. LAYER 2 GREEN (JP8_LIFT_LAYER=recall, logs/lift_gate_layer2_recall.log): from the booted patches 2 and 63 the C twin recalls patch 5 through the LIFTED DISPATCH (64 pools x 9 units, flag 0, engine frame) + ASG_NOTIFY x 9, renders 512 samples so the plugin's own walker settles the ramps, then NOTEON 60 / 64 samples / NOTEOFF / 64: 46,080 output words and the whole heap EXACTLY 0 on both; its own TOOTH (--tooth 0x38633e, the FINE TUNE setter's + 0.0003, reachable only through DISPATCH) FAILS with 9,292 differences -- the render tooth is a no-op on a RANGE-3 patch, so each layer carries its own tooth (jp8_lift_seq.TOOTH). | PROVEN (EXACTLY 0) |

## Cost (instructions per host sample, UC_HOOK_CODE after ctl_flush_tb, 32-sample windows; PROVEN on this oracle)
| patch @ rate | idle | sustain | log |
|---|---|---|---|
| 2 'BR JP PWM Brass' @44100 | 30,542 | 30,495 | listen2_sr44100_p2.log |
| 10 'PD JP Soft Pad' @44100 | 29,478 | 29,463 | listen2_sr44100_p10.log |
| 52 '1981 Hi Brass' @44100 | 31,622 | 31,556 | listen2_sr44100_p52.log |
| 63 '1981 Chime' @44100 | 30,671 | 30,641 | listen2_sr44100_p63.log |
| 0 'PD Jupiter Glide' @44100 | 30,546 | 30,528 | listen2_sr44100_p0.log |
| 2 @48000 / @96000 | 30,462 | 30,991 | listen2_sr48000_p2.log, listen2_sr96000_p2.log |
Per-unit split, one sample, note held (exp1_count_0_44100.log, code hook): voices 3,632 x 8 (3,631..3,638) + master 1,288 = 30,349.
Idle == note: every unit runs every sample (no idle gating). Rate does not change the count (same code, different constants).
S3 verdict (1 x86 instr ~ 1.75 S3 cycles, calibration INFERRED; budget 10,000 cyc/sample @48k): 30.5k x 1.75 ~ 53k cyc/sample
= ~5.3x one S3 for the 9 units; one bit-exact voice ~ 3,632 x 1.75 ~ 6.4k cyc, so two voices per chip already exceed 10k ->
a bit-exact 8-voice JP8 is ~1 voice per S3. Same class as the JUNO exact engine (CLAUDE.md: two chips cannot run it).

## Defects, each with its resolution
- D1 (RESOLVED, previous agent): RENDER 0x445DC0 on a zero-filled HOST faulted (it needs the constructed CWaveGen channel
  vectors). The oracle drives VOICE_WRAP x8 + MASTER_WRAP per sample on the states BUILD constructed (jp8_emu.render_both),
  the JX/JUNO idiom. faults == 0 over 12000 idle samples (listen_p0_n60.log). Host RENDER stays READ-only.
- D2 (RESOLVED, this agent; PROVEN): every patch played +36 semitones (patch 2 key 60 = 2092 Hz, exp3/exp4 logs; patch 63
  +48 = 36 + its RANGE). Cause: the bank stores pools in the RAW frame (Script.xml: VCO2 SUB RANGE int2x4 0..72, default 36)
  and DISPATCH flag 1 takes the ENGINE frame (engine DB id 769 = -36..36); the inherited JX recall passed raw bytes through.
  Proof: 769 := 0 (flag 1) after recall -> key 48 130.64 Hz, key 60 261.36 Hz, -2 cents (d2_2_0_1.log); flag 0 changed
  nothing (d2_2_0_0.log, d2_2_36_0.log). Fix: gen/jp8_emu.py JP8.recall dispatches raw + engine-DB min for every pool.
  Mantra-5 control with the same law on the JX (gen/jx_ctrl.py, ctrl2_jx_sr44100_p0/p1.log): patch 0 -1194 cents = its
  DCO1 RANGE 2 (16', the jx_listen law), patch 1 (8') -9 cents: CONTROL PASS at 44100.
- D3 (READ, the port's design fact; shared with the JX): CJp8Sim slot 0x50 (0x3F8240) opens `cvttss2si eax,[state+0x10];
  cmp eax,0xAC44; jne generic`: a 44100-SPECIALISED constant set (rate ratio state+0x8B0 = 96000/44100 = 2.17687, written
  at 0x4020FE) versus a generic set whose ratio is the LITERAL 1.0 (0x3FE0A5) = 96000-referenced tables. PROVEN by
  jp8_srtrace.py (+0x8B0 = 2.17687 at 44100, 1.0 at 12000/22050/24000/48000/88200/96000) and by pitch: -1 cent at 44100,
  +0 at 96000, exactly -1200 at 48000 (listen2_sr*_p2.log); exp3 gave f/96000 per sample at every other rate. The per-unit
  drive (VOICE_WRAP once per host sample) is therefore exact at 44100 and 96000 only. A 48 kHz target must reproduce the
  host layer's resampler path (RENDER 0x445DC0 + cells state+0x1F50..0x1F90, identity at 48000) -- the JUNO's 96k-internal /
  2x-decimate shape. The JX oracle obeys the same law (ctrl_jx_sr*.log: same pitch at 44100 and 96000, one octave lower at
  48000; jx3p S3_STATUS lists 48000/96000 as open). Listen proofs passed at 44100 (JX precedent) and, for patch 2, 96000.
- D4 (RESOLVED 2026-09-22, PROVEN): "patch 0 tracks keys by -15.64 semis" was D6 (below): the flag-1 recall left ENV1
  SUSTAIN at the boot ramp's limit 0.995, so patch 0's pitch envelope (VCO ENV MOD 18 -> cell -2.70 oct, ENV1 A0 D140 S0)
  never decayed. On the corrected drive patch 0 dives and settles from 1.5 s at -1197 cents on every window to 7.4 s
  (d4_windows_p0_k60.log, harmonic 0.99) = its VCO1 RANGE 2 (16'). THE LAW, read from the cells the plugin's own setters
  write (jp8_d4_law.py -> d4_law.log; cells found by a write hook, d4_param_census_p0.log; consumer fn 0x395000 read-hooked):
  | id | parameter | cell (per voice slot, stride 0x5ED0) | setter | law (octaves) |
  |---|---|---|---|---|
  | 760 | VCO1 RANGE 0..5 | state+0x1390 | child vtbl 0xa19110 slot 0x40 = 0x385aa0, table .rdata 0xcbc2b8, set now | v -> v-3: 0=-36 1=-24 2=-12 3=0 4=+12 5=+24 semis |
  | 765 | VCO2 RANGE 0..5 | state+0x13a0 | slot 0x48 = 0x385ad0, same table | same |
  | 769 | VCO2 SUB RANGE -36..36 | state+0x1470 | slot 0x50 = 0x385a30 | v/12 (= v semitones) for all 73 values |
  | 766 | VCO2 FINE TUNE 0..255 | state+0x1480 | slot 0xa8 = 0x386310: curve 0x40 of .data 0xd22428 via 0x37e990, + 0.0003 (.rdata 0xa192e8) | 0 -> -59.64 c, 120..135 -> +0.36 c (dead zone), 255 -> +60.36 c; 0.5 c/step (full table in d4_law.log) |
  Sum (fn 0x395000, per sample): VCO1 = [0x1630]+[0x1370]+[0x1610]+[0x1460]+RANGE1 -> [0x16e0]; VCO2 = [0x1640]+lerp([0x1610],
  [0x1730],[0x1580] LOW FREQ)+[0x1380]+SUB+FINE+RANGE2 -> [0x16f0]; both clamped to [-4, 10]. The cells are OFFSETS (2.0024 on
  keys 48/60/72 alike); the oscillator adds the key term [0x35b0] (0x39b21a -> 0x394db0 = 2^x), so f = midi_hz(key)*2^(cell-2).
  EXECUTED on patch 2, VCO2 alone, keys 48/60/72 (overrides flag 0): RANGE 2 -> -1187 c (= -1200 + FINE 163's +12.4),
  RANGE 4 + FINE 255 -> +1259/+1260 c, SUB -7 + FINE 0 -> -760/-761 c, every window within 2 cents of the engine's own
  pitch cell (d4_probe_p2_range2.log, d4_probe_p2_range4_fine255.log, d4_probe_p2_sub-7_fine0.log: 18/18 PASS). Patch 0
  certified under the law: late-window -1197 c = RANGE 2 (d4_windows_p0_k60.log); its early window is the envelope (the
  sweep records both). The old "760 := 2/5 changed nothing" probes measured VCO1 of a PWM patch behind VCO2; retired.
- D6 (RESOLVED 2026-09-22, PROVEN; playbook 99, PORT_LESSONS 1-2): THE RECALL DISPATCHED WITH FLAG 1 LOST PART OF EVERY
  PATCH. Flag 1 = "set now" (0x440430) and leaves the BOOT RAMP behind the cell active with its old limit; the plugin's own
  walker moves the cell back within 64 samples and a snap does it at once (d4_ramp1480_p0.log: FINE TUNE 0.00405 -> 0.0003).
  On patch 0 the flag-1 recall + snap lost ENV1 SUSTAIN (0 -> 0.995), MIXER VCO1 (2.51 -> 0.5), HPF, PORTAMENTO, FINE TUNE
  (d4_flag1_p0.log); flag 0 -- what HOSTPARAM 0x4465B0 passes (xor r8d,r8d before DISPATCH slot 0x58, READ) -- arms the ramp
  (limit +0x14 = new value, active +0x1C) and every cell holds through 4160 rendered samples after the snap (d4_flag0_p0.log);
  flag 0 + snap lands the same cells as flag 1 for every pool/value (d4_flagcensus.log, 0 disagreements). JP8.recall now
  dispatches flag 0 (RECALL_FLAG). Consequence: every listen number dated before 2026-09-22 was measured on a half-defaulted
  patch (pitch laws unaffected; envelopes, mixer, HPF, portamento, fine tune were at boot defaults). Probe rule paid the same
  day: overrides after a flag-0 recall must be flag 0 too (a flag-1 override is undone by the snap; d4_spec_p2_rflag0_range4.log
  shows the un-muted VCO1 at 261 Hz beside VCO2 at 528 Hz). INFERRED for the JX owners: jx_emu.recall also dispatches flag 1.
- D5 (RESOLVED, harness): listen_p0_n60.log's 343 instr/sample was a UC_HOOK_BLOCK added after the render blocks were
  cached (Unicorn does not call it for cached TBs): 90x low. Count with UC_HOOK_CODE after uc.ctl_flush_tb (jp8_listen2.py).
- Master release rule: 24000 samples is shorter than a reverb/delay tail (patch 2 REVERB 161: 12% left at 0.54 s;
  at 96000 the same window is 0.25 s). Decay is judged on a 3 s tail (jp8_probe.py tail): monotone to <1e-4 on patches 2
  (44100, 96000) and 0. Not an engine defect.
- Note for the JX owners (INFERRED, out of scope): the JX has one negative-min pool too, id 769 DCO2 TUNE (-128..127,
  bank raw 128 = centre); the repo's recall dispatches raw 128 (engine +128) instead of 0. On patch 1 with DCO1 muted
  the DCO2 pitch reads -12 cents (raw) vs -9 cents (engine 0) (jxtune_p1_*.log); a value of 64 read -2780 cents, so the
  DCO2 TUNE mapping is not understood and the autocorrelation may be reading beats. Worth a look by the JX port.

## Step 5 method (the lifter; PORT_LESSONS 6-9)
jp8_lift.py (static reach + emission; --dyn indirect targets, --tooth rva, --trace), jp8_dynreach.py (executed set + indirect
targets on the oracle, TB cache flushed before the hook), jp8_reach.py (static census), jp8/src/jp8_cpu.h (register file,
eager flags, exact SSE helpers), jp8/src/jp8_rt.c (trap, MAP_FIXED_NOREPLACE loader, FTZ, jp8_call), the quartet
jp8_lift_seq.py (the shared event drive per layer) / jp8_lift_emu.py (oracle dumps + words) / jp8_lift_c.py (same addresses,
same drive, EXACTLY 0) / jp8_lift_gate.sh. Two-process rule kept: Unicorn in process A, ctypes in process B, files between.
Not the port's final shape: the C twin runs on the oracle's 103 MB address-space image (pointer cells verbatim); a device
template needs the state blocks compacted and pointer cells relocated (the JX's lesson 8) -- a later layer.

## Files (jp8/tools/)
jp8_emu.py (oracle; recall flag 0 in the engine frame), jp8_listen2.py (step-4 proof, JX law), jp8_sweep.py + jp8_sweep_collect.py
(64-patch sweep worker + SWEEP_44100.md builder), jp8_d4_law.py (RANGE/FINE/SUB law tables from the cells), jp8_d4_probe.py
(execution proof vs the engine's own pitch cells, early + late windows), jp8_d4_trace.py / jp8_param_census.py (dispatch write
hooks: parameter -> cell), jp8_d4_flag.py / jp8_d4_ramp.py / jp8_d4_spec.py / jp8_d4_bisect.py (D6 evidence), jp8_probe.py
(set / windows / tail / tailfx), jp8_d2.py, jp8_srtrace.py, jx_ctrl.py, jp8_bank.py + jp8_bank_census.py, abi_ledger.md/.json,
gen/params.tsv, work/fn_3f8240.asm, work/dis_full.py, work/dis_func.py.

## Next
1. Sweep verdict into this page when the job (bench/jobs/jp8_sweep44100, EXIT file) ends; every FAIL triaged against the confound
   list in its log before it is called an engine defect.
2. Step 5 layers after the render+note path and the recall path: SETSR/BUILD (construction -> a compact template instead of the
   103 MB image), the host RENDER 0x445DC0 (D3, other rates), longer reach (more patches, keys, thousands of samples, both idle
   and note), then step 6-8 (template export, full-chain gate, web shell).
3. 48 kHz: the host resampler path (RENDER 0x445DC0, D3) is a later layer; the target rate law is the 44100 NATIVE constant set.

## STOP RECORD (2026-09-22, user order "STOP AND SAVE ALL WORK, usage 95%")
Committed AS-IS, mid-gate. Layers 1 and 2 are GREEN (commits 6759ae8, 1128339). In flight when stopped, NOT green, NOT believed:
- step 5 layer 3 (boot path): jp8_lift_gate.sh was running (logs/lift_gate_layer3_boot.log, unfinished); jp8_rt.c / jp8_lift_emu.py / jp8_lift_c.py carry the handle-counter plumbing (jp8_hc_set) that was being added.
- 64-patch listen sweep at 44100: 46 of 64 patch logs in logs/sweep44100/ (EXIT 130 = killed, not a verdict). Resume: rerun jp8_sweep_job.sh for the missing patches.
- 64-patch lift reach gate (logs/lift_reach64.log, EXIT 130 = killed).
Resume order: finish the layer-3 gate (must be EXACTLY 0 + tooth), then the sweep + reach, then update the table above. Nothing in this record is PROVEN.
