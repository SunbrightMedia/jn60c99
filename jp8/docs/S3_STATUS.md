# JP8 S3_STATUS.md -- JUPITER-8 PLUG-OUT .vst3 -> C99 port (PORT_PIPELINE steps 0-4 DONE, 5+ open)
Repo layout (moved from the ephemeral scratchpad 2026-09-22): `jp8/truth/` (checksummed, clean names,
SHA256SUMS), `jp8/tools/` (oracle `jp8_emu.py` + probes; every `gen/*.py` named below now lives here),
`jp8/logs/` (every log named below), `jp8/docs/` (this file, `abi_ledger.md/.json`), `jp8/gen/params.tsv`,
`jp8/work/` (disassembly + scratch). Smoke after the move: boot 841/845 ok, faults 0 after static init,
patch 2 note renders, NaN 0 (2026-09-22, this session).

Last update: 2026-09-22 (third agent). Every number below has a log in gen/ (named per line).
Labels: PROVEN = executed under Unicorn on the plugin's own code; READ = static disassembly; INFERRED = deduction.

| # | Step | State | Label |
|---|------|-------|-------|
| 0 | Intake | DONE: truth/SHA256SUMS, 16 files (.vst3, Script*.xml, 3x Code8_N.Dat, 1_Preset.bin, TextCodeTable.dat) | PROVEN (checksummed) |
| 1 | Census | params.tsv 5223 rows (name table 0xA30D70, engine DB 0xA1CD80); XC ctor table 845 entries, 841 run, 3 skipped by address, .data tail 3441 B filled; BUILD = 9 x 0xA9C0C0 (recon_boot.log). recon.json not produced (pe_recon `all --json` never run) | READ + PROVEN(boot) |
| 2 | ABI ledger | DONE: gen/abi_ledger.md + abi_ledger.json. BUILD 0x445020 (rcx); SETSR 0x4464F0 (rcx, rate = FLOAT in xmm1, playbook 87 holds); RENDER 0x445DC0 (rcx, r9, stack arg6 nframes -- the HOST process, not the oracle drive); HOSTPARAM 0x4465B0 (rcx, edx host id, r8d value; host map root .data 0xD22478 = {0:18,1:19,2:20}); NOTEON 0x445CF0 / NOTEOFF 0x445C90 (rcx, dl note, r8b vel); DISPATCH 0x437630 (rcx proc, edx id, r8 flag, r9 value); ASG_NOTIFY 0x37CD80; VOICE_WRAP 0x3F80B0 / MASTER_WRAP 0x3F8040 (the JX idiom byte for byte). CJp8Sim vtable 0xA1B678 = the per-unit STATE class, not the entry set. Addendum 2026-09-22: DISPATCH flag 1 = engine frame applied at once (PROVEN); SETSR chain and the 44100-vs-generic table branch (READ) | READ (abi_check) + PROVEN where marked |
| 3 | Boot | PASS: static init 841/845 -> BUILD -> SETSR(float) -> FTZ -> host_init 3 writes via host_map() -> recall in the ENGINE frame -> SNAP 353 ramps/unit + clear latch 960. Faults: 1 in static init (ctor #1 rva 0xB720C, the JX template condition: cookie-decoded null pointer, one stray page), 0 from BUILD on. IDLE 12000: master NaN 0, peak 1.6e-13, dry 0 (listen_p0_n60.log; listen2_*.log idle PASS x7) | PROVEN |
| 4 | Listen proof | GREEN at 44100 on patches 10, 52, 63 (jp8_listen2.py, the JX law: keys 48/60/72 within +-1 cent DRY and MASTER, harmonic 0.955-0.992, idle silent, dry+master release decay, NaN 0, faults 0) and patch 2 (pitch -1/0/-1 cents; master release needs the reverb-length tail: tail_p2.log 0.248 -> 2.7e-8 over 139k samples, monotone). 96000: patch 2 pitch +0/+0/-1 cents, master tail decays (tail_p2_96k.log), silent at once with FX off (tailfx_p2_96k.log). 48000: exactly -12 semis on every key = D3. Patch 0 NOT certified (D4) | PROVEN at 44100 (and 96000, patch 2) |

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
- D4 (OPEN): patch 0 'PD Jupiter Glide' tracks keys by -15.64 semis on all three keys (-1564/-1562/-1563 cents, harmonic
  0.84-0.90), not a whole number. VCO2 alone gives the same (probe_p0_vco2only.log); VCO1 alone is a PWM pulse the f0
  detector cannot read (harmonic 0.55-0.59). Patch data: VCO2 RANGE 4, VCO2 FINE TUNE 144, VCO1 RANGE 2. The JP8 RANGE ->
  pitch law is NOT 12*(RANGE-3) (the hint printed by jp8_listen2.py is REFUTED: patch 63 RANGE 4 tracks +0; 760 := 2 or 5
  on patch 2 left the pitch at 8', probe_760_*.log). RANGE and FINE TUNE tables must be read from the binary in step 5.
  Its master tail decays (0.658 -> 0.00145 over 180k samples, tail_p0.log; delay 191 / time 210 echoes for ~1.5 s).
- D5 (RESOLVED, harness): listen_p0_n60.log's 343 instr/sample was a UC_HOOK_BLOCK added after the render blocks were
  cached (Unicorn does not call it for cached TBs): 90x low. Count with UC_HOOK_CODE after uc.ctl_flush_tb (jp8_listen2.py).
- Master release rule: 24000 samples is shorter than a reverb/delay tail (patch 2 REVERB 161: 12% left at 0.54 s;
  at 96000 the same window is 0.25 s). Decay is judged on a 3 s tail (jp8_probe.py tail): monotone to <1e-4 on patches 2
  (44100, 96000) and 0. Not an engine defect.
- Note for the JX owners (INFERRED, out of scope): the JX has one negative-min pool too, id 769 DCO2 TUNE (-128..127,
  bank raw 128 = centre); the repo's recall dispatches raw 128 (engine +128) instead of 0. On patch 1 with DCO1 muted
  the DCO2 pitch reads -12 cents (raw) vs -9 cents (engine 0) (jxtune_p1_*.log); a value of 64 read -2780 cents, so the
  DCO2 TUNE mapping is not understood and the autocorrelation may be reading beats. Worth a look by the JX port.

## Files (gen/)
jp8_emu.py (oracle; recall in the engine frame), jp8_listen2.py (step-4 proof, JX law), jp8_listen.py (step 3+4 single
note; its counter is D5-broken), jp8_probe.py (set / windows / tail / tailfx), jp8_d2.py, jp8_srtrace.py, jx_ctrl.py
(control), jx_tune_probe.py, jp8_bank.py + jp8_bank_census.py (decode + tooth), abi_ledger.md/.json, params.tsv,
work/fn_3f8240.asm (slot 0x50 disassembly), work/dis_full.py, work/dis_func.py.

## Next (step 5 not started, per the lead)
1. Read the VCO1/VCO2 RANGE and FINE TUNE tables from the binary (D4) before any pitch layer is transcribed.
2. Decide the rate law for the target: transcribe at 44100 (the native set) or transcribe the host resampler for 48 kHz.
3. 64-patch listen sweep with jp8_listen2.py at 44100 (~100 s per patch, bounded) as the charter's reach before step 5.
4. Step 5 per PORT_PIPELINE: layer quartets with a tooth SEEN TO FAIL; template export from the step-3 boot (fresh build
   per patch); NaN census 0.
