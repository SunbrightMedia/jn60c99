# JP8 S3_STATUS.md -- JUPITER-8 PLUG-OUT .vst3 -> C99 port (drive2 = the plugin's own construction; lift gates on drive2; template exported; engine + full-chain gate next)
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
| 5 | Transcribe (layer 3: the hosted boot) | GREEN 2026-09-22 (logs/lift_gate_layer3_boot.log, job jp8_L3gate3): from the POST-STATIC-INIT image the C twin runs the lifted BUILD 0x445020 -> SETSR 0x4464F0 (float xmm1, 44100) -> host_init through HOSTPARAM 0x4465B0 -> recall of patch 5 through DISPATCH (flag 0) + ASG_NOTIFY -> 2200 samples (no snap: the plugin's own walker settles) -> NOTEON 60 / 64 / NOTEOFF / 64, on boot patches 2 and 63: 167,616 output words and the whole heap EXACTLY 0. Lift: 762 functions, 156,488 instructions, 280 trap sites (none reached). TOOTH (FINE TUNE setter + 0.0003 at 0x38633e): FAILS with 432 differences, first at state[0]+0x1480. Two harness defects paid on the way (PORT_LESSONS 12): the stack is state (BUILD copies static-init stack residue into 8 voice records) and the C side entered every call 8 bytes below the oracle's rsp. | PROVEN (EXACTLY 0) |

## ⚑ RESUME HERE (written 2026-09-28 when the chat was retired; everything below this block is the dated record)
**2026-10-16 -- THE SHARED LIFTER CHANGED UNDER THE JUNO L3 PROOF (docs/JUNO_LIFT.md).** jp8/tools/jp8_lift.py: a
32-bit cmov now clears the destination's upper half when its condition is false (playbook 283); jp8/src/jp8_cpu.h's
hardware float path: x86's NaN order for add / sub / mul / div and min / max as the instruction itself (playbooks
284-285). The committed JP8 lifts predate both: regenerate and re-gate them before any new JP8 claim, and check that
jp8/tools/jp8_fast.py parses the cmov statement's new else-branch.
**2026-10-12 -- THE USER'S ORDER: STEP 1 IS THE FAST LIFTER (playbook 230).** The lifter's output is exact and 5-13x
slower than the plugin's own code (measured on the JX-3P's voice render against the plugin run natively: 2,320 ms
per second of audio vs 159). jp8/tools/jp8_fast.py rewrites a lifted source with each function's registers and flags
in C locals (stores at calls only where dirty and where the callee may read or write; flags proven dead where
functions meet; small functions inlined in rounds): the JX voice render 371 ms, bit-exact (jx_master_bisect patch 5).
GRADED HERE (job jp8fast2): the three drive2 layer gates on the pass's output of jp8_lift.c are EXACTLY 0 (output,
heap, stack); its tooth bites (JX bisect, and here: the state differs). TIMED (jp8/tools/jp8_speed.py, 22,050 samples
of the render reference, one output checksum in every build): the plugin's own code natively 195 ms per second of
audio at 44.1 kHz on this CPU, the plain lift 1,093 ms, the fast pass 449 ms (2.3x; compare + branch fused). Still owed before it carries a product: the bounds check as an expression
(CHECK 2 as a function costs 4x: the compiler keeps it out of line in large functions), the xmm registers off the
stack, the remaining calls, and the speed of the JP8's own render measured against the plugin run natively. The JUNO-60's and JX-3P's row 24 closes with it (a lifted render).
**2026-10-11 (from the JX-3P track, JX-26a, playbook 213): `jp8_lift.py` now emits ISO C99** -- the 64-bit mul /
imul / div through jp8_cpu.h's exact helpers (jp8_mulu64, jp8_muls64, jp8_divu128, jp8_divs128) and the bit scans
through jp8_clz64 / jp8_ctz64 / jp8_popcount64, no __int128, no builtins (20 M operands equal to __int128's; the
JX's lifted source re-lifted: 14 lines changed, its lift gate EXACTLY 0). 2026-10-12: jp8/src/jp8_lift.c re-lifted by
jp8_lift_gates_all.sh (job jp8fast2: the three drive2 layers GREEN on it) and committed -- 94 lines changed, every
one a 64-bit mul / imul through the exact helpers; no __int128 or builtin left; gcc -std=c99 -pedantic-errors clean.
**Where it stands (each line has its log):**
- ORACLE = DRIVE2 (`jp8_emu.JP8()` default; `legacy=True` only reproduces old logs): HOST from the FACTORY 0x444FE0
  (ALLOC 0x8D0 + ctor 0x444000), BUILD, FTZ, SETSR(float xmm1), host_init (host ids 0,1,2 through HOSTPARAM), recall through
  HOSTPARAM per pool (host id from the executed std::map, RAW bank value), NO snap, NO latch clear. Step-4 control on it:
  idle master 1.57e-13, dry 0, NaN 0, 0 live and 0 total bad ramps (bench logs of jp8_ref_d2_*; `CONTROL` lines in the refs).
- 64-patch listen sweep on drive2: 51/64 PASS (SWEEP_44100_DRIVE2.md); triage PARTIAL — 6 FAIL rows explained by their own
  confound, 8 OPEN, patch 26's release not decaying is the one to check first (its "## Triage" section).
- LIFT GATES ON DRIVE2 (control plane RECORDED in process A and replayed verbatim in process B, PORT_LESSONS 15):
  layer 1 render: EXACTLY 0 on patches 2,63,10,0 (13,824 words each), heap + stack EXACT; tooth 0x3965cb bites (96 diffs)
  -> logs/lift_gate_layer1_drive2.log. Layer 2 recall (recall of patch 0, LFO KEY TRIG = 1, through HOSTPARAM, 66 recorded
  calls): EXACTLY 0 on 2,63 (46,080 words each), heap + stack EXACT; tooth 0x38633e bites (10,699 diffs)
  -> logs/lift_gate_layer2_recall_drive2.log. Layer 3 boot (factory -> BUILD -> SETSR -> host_init -> recall 5 -> 2200
  samples -> note): EXACTLY 0 on 2,63 (167,616 words each; 72 recorded calls = FACTORY, BUILD, SETSR, 3 host_init, 64 recall,
  note on/off), heap + stack EXACT; tooth 0x38633e bites (3,304 diffs) -> logs/lift_gate_layer3_boot_drive2.log (job
  jp8_gates_d2b, EXIT 0, 2026-09-28; the first run trapped at 0x72fd53 punpcklbw in the factory path, PORT_LESSONS 17).
  NOT YET: a HOST tooth (corrupt the constructed [HOST+8] on the C side; must fail) and the 64-patch reach on drive2.
  Lift: 769 functions, 156,870 instructions, 282 trap sites; roots in jp8_lift_seq.ROOTS (now incl. the factory 0x444FE0);
  dyn reach = build/jp8_lift/dynreach_d2.json (2,63,10,0,24 --recall 0) + dynreach_boot_d2.json (2,63 --recall 5 --boot),
  (build/ is not in git: jp8_lift_gate.sh regenerates both with jp8_dynreach.py, block hook, ~90-170 s each). Run all three: `sh tools/run_job.sh jp8_gates sh jp8/tools/jp8_lift_gates_all.sh`.
- TEMPLATE (step 6): `jp8/tools/jp8_template_export.py` -> jp8/gen/jp8_template.bin.gz (5.76 MB; raw 14.8 MB, sha256 in
  jp8_template.sha256): post-static-init image (whole mapping as oracle memory), heap [base, 0x3100304a0), stack residue
  (60 KB), page 0, scalars (heap_ptr0 0x3100304a0, hc0 0x9020, rsp, RET 0x105000, static 841 ok / 0 fail / 3 skipped /
  1 fault). Self-check byte-identical; tooth bites (crc, and the region compare with the crc re-sealed). The one oracle
  page outside the template (0x2b992ddfa000, a static-init stray) is NOT carried. jp8/gen/jp8_recall_tab.h/.json = the
  ORACLE's own recorded HOSTPARAM calls: host_init {0:1, 1:10, 2:100} and 64 pools x 64 patches in call order.

**Next, in order (tasks carried over from the retired chat):**
1. DONE 2026-10-12: the HOST tooth (jp8_lift_c.py JP8_HOST_TOOTH=1 flips one bit of the constructed [HOST+8] after
   the FACTORY call; jp8_lift_gate.sh runs it on the boot layer): it bites -- the output differs from sample 961 --
   while the same run without it is EXACTLY 0. DONE 2026-10-12: the 64-patch reach on drive2 -- 64 / 64 EXACTLY 0
   (logs/lift_reach64_drive2.log), and the fast pass's output (jp8_fast.py at a4ce65ac) 64 / 64 EXACTLY 0 on the same
   oracle runs (logs/lift_reach64_drive2_fast.log; job jp8_reach64_both, EXIT 0). The command was:
   `sh tools/run_job.sh jp8_reach64 sh jp8/tools/jp8_lift_reach.sh` -> logs/lift_reach64_drive2.log (~80 min).
2. DONE 2026-10-12: THE SELF-BOOTING ENGINE, jp8/src/jp8.h + jp8/src/jp8_engine.c (JP8_RELOC). jp8_init(template, rate)
   maps the JP8T regions, then the drive2 order of jp8_emu.JP8.boot: FACTORY + BUILD at MXCSR 0x1F80 (the HOST and the
   unit pointers checked against the READ facts), FTZ 0x9FC0, SETSR (the rate as a float in xmm1), the controller's
   default push (jp8_hostinit_tab); jp8_recall = the oracle's recorded HOSTPARAM calls (jp8_recall_tab.h); notes =
   NOTEON / NOTEOFF; render = per host sample VOICE_WRAP x8 + MASTER_WRAP in jp8_lift_seq.py's call layout. Every lifted
   call goes through jp8_call_x (the layer gates' call path); a trap kills the engine (JP8_E_TRAP, zeros out, nothing
   aborts); the host MXCSR is saved and restored. No snap, no latch clear, no replayed oracle call.
3. DONE 2026-10-12 -- 44100 on 4 patches, then ALL 64 patches (job jp8full_64, logs/full_gate_44100_64.log) and 96000
   on patches 2, 10, 52, 63 (job jp8full_96b, logs/full_gate_96000.log; the product build there on the multi-band
   JP8_FLAT map), every run EXACTLY 0 in both builds with its 4 teeth biting: THE FULL-CHAIN GATE, jp8_full_seq.py /
   jp8_full_emu.py / jp8_full_c.py / jp8_full_gate.sh (job jp8full_gate1, EXIT 0, logs/full_gate_44100.log). CONTROL 0
   (the template == the oracle's post-static-init memory), CONTROL 1 (sha256 of the image + the heap after jp8_init ==
   the oracle's), RUN A (whole render events) and RUN B (re-init + random chunks of 1..300): every output word, the end
   hash and the bump pointer EXACTLY 0 on patches 2, 63, 0 (a patch change under a held note) and 12 (ten keys on eight
   voices), 17,096-22,096 samples each, in BOTH builds: CHECKED (the lift, every access bounds-checked, -O1) and PRODUCT
   (jp8_fast.py's pass, no check, -O2). Teeth, each seen to fail: T1 a note one key up (sample 4096, voice 7), T2 the
   FINE TUNE addss turned subss (CONTROL 1), T3 one bit of [HOST+8] (CONTROL 1), T4 the template without its stack
   (CONTROL 1). SPEED (44.1 kHz, a note held, this shared Xeon): the product build 939 ms per second of audio (init
   205 ms, a recall 0.9 ms); the same fast pass on the identity map 472-520 ms; the plugin's own code natively 188 ms.
   The band table costs ~1.9x: every guest access reloads jp8_bdelta (any store may alias it). DONE the same day
   (playbook 232): JP8_FLAT -- every region in one host reservation, one offset, read once per function into a local --
   516 ms per second of audio (the identity path's speed); the gate's PRODUCT build is now the flat one: EXACTLY 0 on
   the same 4 patches, 4 teeth bite (job jp8flat_gate1, logs/full_gate_44100_flat.log).
3b. 2026-10-12: THE HOST LAYER'S ORACLE (jp8/docs/HOST_LAYER.md): jp8/tools/jp8_host_emu.py boots the plugin as a DAW
   does -- DllMain, InitDll, createInstance, initialize, setupProcessing, setActive -- and plays it through its OWN
   process() (the 96 kHz engine, the rate converter, the threaded engine render with the JX's worker transport): a note
   sounds and decays, no NaN. The framework is the JUNO's (fw_map: 13 of 24 functions byte-equal). OWED: the script
   file with 8 panel types truth/ lacks (stubbed: GUI only), the patch path, then the lift of the host layer.
3c. 2026-10-12: THE HOST PATH, LIFTED (jp8/docs/HOST_LAYER.md sections 4-6): jp8/src/jp8_host.c + jp8h.h run the
   plugin's own setupProcessing, setActive, process(), getState, setState, patch load, UI-timer drain, MIDI learn /
   forget and engine workers, lifted (jp8_lift.py --hostcalls --hook --alloc-tailcall; the roots read from the
   plugin's vtables by the reach; the lift from the 64-patch reach UNITED with the reach of the gate's own drive,
   playbook 237), on the JP8H v2 template = the oracle's memory after boot_host, BEFORE the host knows its sample
   rate (playbook 235): jp8h_init makes the setup calls at the rate it is given. Drive v4 (jp8_host_seq.py): 8 blocks
   per patch with host automation, the MIDI controllers, the host-rate chain 44100 / 96000 / 88200 / 22050 / back,
   setActive off-on, the drain and MIDI learn, sixteen setState inputs (crafted, the engine-rate setting 1..6, the
   voice count 4 / 1), 150 edit-controller calls (v5). The VST3 surface census
   and the controller census (226 parameters: 96 panel + CC 0..127, aftertouch, bend; IMidiMapping CC n ->
   0x0FFFC100 + n) are the JUNO-60's answers (jp8_surface_census.py, jp8_controller_census.py -> jp8/gen/
   jp8_controller.json). Speed: 950 ms per second of audio at 48000 (the 96 kHz engine), the plugin ~2.3x faster.
   GATE GREEN (job jp8_host_gate5, logs/host_gate_48000.log): drive v5 (+150 edit-controller calls) on patches 2, 63,
   0, 12 -- 305 steps, 97,280 words, 44,988 state bytes, 1,652 performEdits, 1,687 worker jobs, the memory after,
   EXACTLY 0 in the CHECKED and the PRODUCT build; 6 teeth fail (T1 74,668 differences, T2 a trap, T3 CONTROL 1, T4
   27,643, T5 a trap, T6 9,207). OWED: other first rates (JP8_HOST_RATES="48000 44100 96000"); the controller's
   parameter info in the C API; the editor; the speed.
3d. 2026-10-12: THE WORKERS ON THREADS, THREE FIRST RATES, THE CONTROLLER'S LOAD-TIME CALLS, NO LEAK (HOST_LAYER.md
   section 5, playbook 238). JP8H_THREADS (POSIX threads, a platform layer): the eight engine jobs render at once,
   their bookkeeping one at a time in unit order at rva 0x44580A -- GREEN at 48000, 44100 and 96000 (job
   jp8_host_gate7: checked, product and three threaded runs EXACTLY 0 at each rate, 6 teeth bite;
   logs/host_gate_3rates_v5.log). Drive v6: what a DAW asks the controller at load (226 parameter infos, the MIDI
   mapping, the units, the controller's own state) and setComponentState after every setState, in the C API
   (jp8h_param_info, jp8h_midi_assignment, jp8h_unit_*, jp8h_component_state ...). THE LEAK: the oracle answered
   HeapFree with a no-op and the C runtime mirrored it -- equal, and both leaking (a patch load 1.32 MB; the
   host-object area full after ~200 patch loads); both sides now reuse a freed block by its rounded size from the
   template's point, every host buffer is a slot of one scratch area (MEASURED: 160 loads grow the heap 31 MB, then
   stop). activateBus sets two bytes nothing reads (jp8_bus_census.py: no read in a patch load and 12 blocks, the output
   word for word the same; logs/bus_census.log). GATE GREEN (job jp8_host_gate8, logs/host_gate_v6_3rates.log; the
   graded content tree f3f032ff = 83fb7007 + the v6 64-patch reach): drive v6 (776 steps: 98,304 words, 46,944 state
   bytes, 1,748 performEdits, the reuse layer's live / free blocks, the memory after) at the first rates 48000, 44100
   and 96000 -- the checked, the product (lanes + guest memory not volatile, playbook 239) and three threaded runs
   EXACTLY 0 at each, 15 runs; 9 teeth bite (T1 75,684 differences, T2 a trap, T3 CONTROL 1, T4 27,644, T5 a trap, T6
   10,222, T7 the end hash, T8 step 2, T9 a trap: the lanes swapped divide by zero). The lift: 1,258 functions,
   167,736 instructions (jp8/src/jp8_host_lift.c, from the v6 64-patch reach united with the gate's drive).
3e. 2026-10-12: THE SCOPE AUDIT AND THE SWEEP (jp8/docs/SCOPE_AUDIT.md: 22 rows, each measured). The v6 drive moved
   ~10 of the 96 panel parameters; the census of their POSITIONS from the plugin's own display strings
   (jp8_param_positions.py: 37 switches, 59 continuous) drives the v7 sweep (jp8_host_seq.sweep_steps): every
   parameter at every position, the three effect units' types with their parameters, the arpeggiator's modes x
   ranges free and synced, the assign modes, KEY HOLD, host blocks of 1..512 samples, the effects' long tail; and the
   base drive gains the voice counts 2..8, MIDI channels 5 and 15, a note-on of velocity 0. The oracle runs the whole
   sweep without a throw (patch 2: 1,365 blocks, 14 min). OWED: its reach (three pieces running), then the gate at
   three rates with tooth T10 (EFFECT TYPE's automation dropped); jp8_mutation_gate.py (one-instruction slips in the
   reached lift); the editor (the user's script file and art); the speed.
3f. 2026-10-12: THE RENDER CLI, GRADED (scope row 22 PARTIAL). jp8/apps/jp8_render.c: template + factory patch + MIDI
   file -> WAV through the lifted process(); its plan replayed on the host oracle: patch 2, 5.56 s (chord, tempo
   change, CC 1 / 7 / 11 / 64, bend, pressure, channel 3, velocity-0 note-on) EXACTLY 0, 267,001 frames; a flipped bit
   is seen; 674 ms per second of audio (one core, three jobs running). The template ships (jp8/gen/jp8h_template.bin.gz,
   8.1 MB; raw sha256 a30f59c6...) and the host gate checks it (stage 2b, tooth T11). One command:
   jp8/apps/render_check.sh. NEXT: a live app (audio device, MIDI in) and the software-float builds (scope row 18).
3g. 2026-10-12: GATE9 (drive v7, three first rates) RED -- ON THE GUEST STACK ONLY. 1,849,808 words, 60,636 state
   bytes, 9,044 performEdits, 30,124 jobs, the heap and the memory after EXACT; 29 stack words differ (the CRT's float
   error handler: the oracle's raise path, the port's masked path). Cause: the host oracle's thread started at MXCSR 0
   (playbook 228, fixed in the JUNO / JX emulators, not in jp8_emu.py) and the C runtime ran a guest 0 as 0x9FC0 and let
   the host CPU's sticky flags show through stmxcsr. Fixed both (playbook 241): with the new runtime the product and
   SOFTFP=2 builds are EXACTLY 0 against the old oracle and against the fixed one, stack included. Software floats:
   SOFTFP=1 and 2 EXACTLY 0 on v7 (words, memory after); no software flush (tooth T12) changes the memory after; the
   oracle has DAZ but no FTZ (MEASURED; scope row 23: no graded drive makes a denormal result). AArch64: the render CLI
   (SOFTFP=2, qemu) byte-identical to the graded x86 render. The shipped template re-exported (raw f43e2d35...).
   NEXT: the full verify (A-E) on this commit; the JX's verify too (its lifted code includes jp8_cpu.h).
3h. 2026-10-12: 64 PATCHES THROUGH THE HOST PATH; DRIVE v8 -- THE TRANSPORT AND THE EDITOR (E1). Job
   jp8_host_gate10 (EXIT 0, the tree of ade5bf3a): drive v7 with the sweep over the 64 factory patches at 48000, host
   maximum block 4096 (blocks of 4096 and 4095 down to 1) -- checked, product, threads and software floats EXACTLY 0,
   12 teeth bite (scope rows 5 and 7 closed at 48000). Drive v8 adds the host transport under a synced arpeggio and
   the editor's open: on patch 2 at 48000 EXACTLY 0 with the memory after and the stack (828 steps; scope rows 3, 21;
   HOST_LAYER.md "THE EDITOR ON THE C SIDE"). Paid: the lifter had no bswap; the oracle's host set no IPlugFrame and
   ran the zero page as code where a PC faults (playbook 242: a frame now, and a named stop for any zero-page run);
   tooth T13 forced flags the plugin's output never depends on (playbook 243: of the context only the tempo changes a
   word on the drive; the position, flag and loop are stored -- the memory after grades them). The template ships again
   (raw 51be86b0..., v3: the editor imports' state and the frame). The render check on it: GREEN (job jp8_render_v3, EXIT 0:
   patch 2, 267,001 frames EXACTLY 0, its tooth bites). RUNNING: jp8_host_gate11 (v8 at three rates, 14 teeth).
3i. 2026-10-12: DRIVE v9 -- THE EDITOR'S WINDOW MESSAGES AND GUI TIMER (E2); THE MUTATION SURVIVORS (scope rows 20, 21).
   jp8_verify_eeb0 (drive v7, EXIT 1): A, B (44100, 96000), C, E GREEN; D RED -- 8 of 41 mutations survive (the same 8
   at all three rates). Counters per step and page diffs: five ran only in the one or two blocks the sweep gave a
   position and the next patch load reset them; three change only 0.0-vs-denormal values or meet a 0.0 coefficient
   (playbook 246). Drive v9: reach_steps hold those configurations and end each with a graded memory step (memhash);
   jp8/tools/jp8_mutation_prescreen.py (the C side alone) shows 5 of the 8 at 48000 / 44100 / 96000. E2: the window
   model on both sides (creation messages, window longs, the style, timers, WM_TIMER) -- EXACTLY 0 on patch 2 at 48000
   with the memory after and the stack; T15 (the timer id) bites. Paid: ATL calls the thunk it writes at run time (the
   C side runs its three instructions, playbook 245); the oracle answered IsWindowVisible 0 by default (both sides now
   model WS_VISIBLE); a second `_imp` in the oracle's class hid its heap reuse (playbook 244; tools/verify/
   dup_method_gate.py in make static). Template v4 ships (raw e618cfbd...). OWED: gate12 (v9 at three rates, 15
   teeth), the mutation gate on its references, 16 / 18 / 39, the render check on template v4.
3j. 2026-10-12: THE NATIVE ORACLE; GATE11 GREEN; FTZ MEASURED; THE REACH SCAN (scope rows 1-5, 11, 23, 24).
   Job jp8_host_gate11 (drive v8 at 48000 / 44100 / 96000, 14 teeth): EXIT 0 -- rows 1, 2, 3, 4 and 11 CLOSED at three
   rates. THE NATIVE ORACLE (jp8/docs/NATIVE_ORACLE.md): the real plugin under wine, a VST3 host in C; it needs the
   oracle's blank skin images natively too (initialize returns 0x8000FFFF without them). native_check.sh full: the 64
   patches x 3 rates through the render CLI, 192 renders EXACTLY 0 against the plugin on a CPU, deterministic, N1 / N2
   bite (row 5). FTZ (row 23): a counter found 1,069,551 denormal results in 6 s of one chord -- all unobservable (the
   PC's rules and the oracle's give the same words and the same image + heap); the old "no drive makes one" was never
   measured and false (playbook 248). THE REACH SCAN (row 24, playbook 247): random host input on the port alone, one
   minimized witness per trap target; the committed lift (still v6) trapped on CC 10 / 70 / 72 / 119; gate11's v8 lift
   holds all but CC 10's target (0x36CD10, an empty method). Drive v10 = v9 + witness_steps (jp8/gen/
   jp8_reach_witness.json). OWED: gate13 (v9) EXIT and its lift COMMITTED (the product runs the v6 one); the witness loop
   until the scan runs clean; gate14 (v10); jp8_native_fuzz.py graded natively (with its control and tooth).
4. C-twin listen (jp8_listen_c.py, the sweep law on the C engine) + agreement table vs SWEEP_44100_DRIVE2.
5. Skeptic items still open (SHIPPING_DESIGN.md): 3 (host RENDER does three things the stubs do not), 5 (carry all tables —
   done by carrying the whole image), 6 (the three skipped ctors), 8 (FP semantics / graded artifact), 9 (runtime gaps),
   10-12 (imports, static-init faults, reach: velocity lane, pitch bend, param changes). Then web shell (offline first).

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
- D7 (RESOLVED in the oracle 2026-09-22/23 = DRIVE2; the lift gates moved onto it 2026-09-23/28 -- see RESUME HERE. Found by the design workflow's skeptic; jp8/docs/SHIPPING_DESIGN.md item 1, probes in
  jp8/work/design/hostctor.py): THE ORACLE NEVER CONSTRUCTS THE HOST. jp8_emu.build() hands BUILD a zero-filled 0x8000 bump
  block; the plugin's processor (0x33a8db) calls factory 0x444fe0 = ALLOC(0x8D0) + ctor 0x444000, which writes [HOST+8] =
  96000.0 (base ctor 0x36c890), [HOST+0x38] = 8 and the vtable, and only then BUILD. BUILD copies [HOST+8] into every
  state+0x10, so on the zero HOST the rate is 0 and 353 ramps/unit get inf/NaN steps (READ + PROVEN): the "snap" and the
  latch clear of the boot recipe were a band-aid over this; without them the zero-HOST boot is not silent at idle (master
  pinned at 1.98, dry 65; PROVEN). With the real ctor (or HOST+8 := 96000.0): 0 NaN/inf steps, every ramp settles with NO
  snap, idle 1.57e-13 (PROVEN, patch 2). Consequence: EVERY reference so far (layers 1-3, the 64-patch reach, SWEEP_44100,
  listen2) was measured on the zero-HOST drive. The lifted code's EXACTLY 0 still stands (it reproduces the plugin under that
  drive); the DRIVE is wrong and must be replaced, then every reference regenerated. Also open from the same review: the
  recall must take HOSTPARAM's per-id path (id 756 LFO KEY TRIG has a direct setter; 12 patches), the boot order changes the
  sound (ctor -> BUILD -> SETSR -> host_init -> recall is the host's), and host RENDER 0x445DC0 does three things the stubs do not.
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
DRIVE2 lift quartet: jp8_lift_seq.py (shared drive), jp8_lift_emu.py (oracle + call recorder), jp8_lift_c.py (replay +
compare), jp8_lift_gate.sh / jp8_lift_gates_all.sh / jp8_lift_reach.sh, jp8_dynreach.py (block-hook reach), jp8_lift.py (the
lifter), jp8_template_export.py (template + recorded recall table). Older: jp8_emu.py (oracle; drive2 default), jp8_listen2.py (step-4 proof, JX law), jp8_sweep.py + jp8_sweep_collect.py
(64-patch sweep worker + SWEEP_44100.md builder), jp8_d4_law.py (RANGE/FINE/SUB law tables from the cells), jp8_d4_probe.py
(execution proof vs the engine's own pitch cells, early + late windows), jp8_d4_trace.py / jp8_param_census.py (dispatch write
hooks: parameter -> cell), jp8_d4_flag.py / jp8_d4_ramp.py / jp8_d4_spec.py / jp8_d4_bisect.py (D6 evidence), jp8_probe.py
(set / windows / tail / tailfx), jp8_d2.py, jp8_srtrace.py, jx_ctrl.py, jp8_bank.py + jp8_bank_census.py, abi_ledger.md/.json,
gen/params.tsv, work/fn_3f8240.asm, work/dis_full.py, work/dis_func.py.

## Next (2026-09-22, SUPERSEDED by RESUME HERE)
1. Sweep verdict into this page when the job (bench/jobs/jp8_sweep44100, EXIT file) ends; every FAIL triaged against the confound
   list in its log before it is called an engine defect.
2. Step 5 layers after the render+note path and the recall path: SETSR/BUILD (construction -> a compact template instead of the
   103 MB image), the host RENDER 0x445DC0 (D3, other rates), longer reach (more patches, keys, thousands of samples, both idle
   and note), then step 6-8 (template export, full-chain gate, web shell).
3. 48 kHz: the host resampler path (RENDER 0x445DC0, D3) is a later layer; the target rate law is the 44100 NATIVE constant set.

## STOP RECORD (2026-09-22) -- SUPERSEDED
Everything it listed was finished or replaced: layer 3 went GREEN on the old drive (logs/lift_gate_layer3_boot.log), the
old-drive sweep and reach completed (SWEEP_44100.md, logs/lift_reach64.log), and then D7 retired that drive. See RESUME HERE.
