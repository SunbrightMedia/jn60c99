# THE JUNO-60 LIFT — the plugin's own code in C99 (USER-BINDING 2026-10-15)

The user, 2026-10-15: "Of course you should be using the plugins own code! I just need it in C99. Nothing should be
hand-written from scratch unless it's to do with glue to the ESP32 or raspi, and seldom code at that." And: "report
your progress to full completion as a percentage every time you say something in this chat."

Why (playbooks 274, 275 and the 2026-10-15 session): every defect found in the hand-written port was in a place no
gate looked -- the author of the port also chose the tests, so the blind spots were the same. A mechanical
translation of the plugin's own instructions has no per-feature blind spot: when every instruction form is right,
every path is right, including the paths no test drives.

## The plan (tasks L1-L7)

| Step | What | Done when |
|---|---|---|
| L1 | Census: every plugin instruction a product can reach -- the VST3 entries, the editor's handlers and timers, the engine workers; static reach (direct calls, jump tables, every vtable and function pointer) united with the dynamic reach of every JUNO drive | the list exists; its size is the denominator below |
| L2 | The lifter takes any image (jp8_lift.py / jp8_fast.py / jp8_xlane.py); the JUNO lift `jn_lift.c` | every census instruction is in the generated C; a static check finds no trap on a reachable path |
| L3 | The lifter proven per instruction form: the lifted C of one instruction vs the real CPU and Unicorn, edge and random states (registers, memory, flags, MXCSR) | every form of the census EQUAL; a planted wrong semantic fails |
| L4 | The template (the oracle's memory after boot, before the host knows its rate) and the C API (`junoh.h`): the plugin's own entries only; plumbing for host objects and imports | every entry of the census roots callable |
| L5 | Gates: a drive like jp8_host_gate.sh (every output word, state byte, performEdit, the memory after: EXACTLY 0) and the existing JUNO gates pointed at the lifted port | all EXACTLY 0; teeth bite |
| L6 | Machine search: random sequences of every entry point (host calls, MIDI, settings, panel events, many calls in one block), compared after every call, steered to code no test reached | 24 hours with no difference |
| L7 | JUNO-60.exe and the web page call only lifted plugin entries (a static check refuses a port-invented call); speed work only in the lifter | both apps checked against the plugin |

The hand-written port (src/, gui/juno_bridge.c) stays the product until L7 passes; then it is retired.

## The progress measure (reported in every message)

progress = 5·L1 + 25·L2 + 15·L3 + 10·L4 + 20·L5 + 15·L6 + 10·L7, each term the fraction done:
L1 1 when the census exists; L2 census instructions in the lift / census instructions; L3 forms proven / forms in the
census; L4 entries in the API / root entries; L5 gate drives EXACTLY 0 / gate drives planned; L6 clean hours / 24;
L7 apps checked / 2. Rounded down to a whole percent; a regression lowers it.

## Log

- 2026-10-15: plan written; JX-3P work stopped (the user); the hand-port verify jobs stopped. Progress 0%.
- 2026-10-15 L1 DONE: tools/verify/juno_lift_reach.py booted the JUNO host oracle and a composite product drive
  (64 patches, MIDI, host automation, setState/getState, UI timer, MIDI learn, the editor's model set / commit, the
  editor attached + window zoom, voice-count / engine-rate settings). REACHED 873 functions, 76,457 instructions in
  them, 64,354 distinct instructions executed, 177 instruction forms (scratchpad/lift/juno_reach.json; the executed
  rva set juno_executed.json). L2: tools/lift/gen_juno_lift.sh ran the image-generic lifter -> lift/jn_lift.c:
  1,883 functions, 157,724 instructions. 634 traps, 501 of them int3 (padding after no-return calls), the rest AVX /
  FMA in CRT branches the oracle (SSE) does not take. tools/lift/check_reached.py is the L2 gate: no trap on a
  reached rva (pending the executed-set re-run).
- 2026-10-15 L2 reach-complete: the one reached unsupported form (pshuflw xmm1,xmm0,0 at 0x6af7bb) added to the
  shared lifter (jp8/tools/jp8_lift.py pshuflw/pshufhw, pshufd's style); re-lift -> tools/lift/check_reached.py
  PASS: 0 reached traps of 570 (the rest int3 padding + AVX/FMA/SSE4 in CRT branches the SSE oracle never takes).
  check_reached counts only WHOLE-instruction traps, not div0 guards. EVERY executed product instruction is now
  C99. Not yet compiled or run -- that is L4 (template + build) and L5 (the gate EXACTLY 0).
- 2026-10-15 L4 keystone: tools/lift/jn_template_export.py (the proven JP8 exporter adapted to the JUNO host
  oracle at the post-boot_host cut, format JNT v1). Exported lift/jn_template.bin (38 MB; image 14.1 MB, stack
  57 KB, heap [base,bump) 24.7 MB, page0/stub empty): SELF-CHECK every region byte-identical to oracle memory,
  scalars equal; the TOOTH bites. Outside the template (scope for the L5 gate): 0x580000000, a 16 MB region at
  0x5a0000000, and BUF 0x700000000 -- carried only if the lifted host reads them (the gate traps otherwise).
  NEXT L4: junoh.h + lift/jn_host.c (the lifted VST3 entries on jp8_cpu.h, host-object + import shims), then L5
  (the gate vs host_process_emu, EXACTLY 0).
- 2026-10-15 L4 compiles: gcc -std=c99 -ffp-contract=off -fno-strict-aliasing -fwrapv -fPIC -I jp8/src -c lift/jn_lift.c
  -> jn_lift.o (5.6 MB, rc 0, no diagnostics): the 12.6 MB lift is valid C99 against the shared runtime header
  jp8/src/jp8_cpu.h. (The earlier rc 127 was /usr/bin/time missing after a container restart, not a compile error.)
- 2026-10-15 L4 template (facts+stubs): tools/lift/jn_host_ref.py (the proven jp8_host_ref.py pointed at the JUNO host
  oracle host_process_emu.HostProcess, format "JNH1"). boot_host cut; 8 regions (page0, image, stack, heap-to-bump,
  stub, com 0x5a0000000, buf, teb 0x580000000), 68 facts (audio, comp, core, ctrl, process_fn = *(*audio + 8*9),
  patch_fn 0x335850, com_next, vt_events/pchanges/pqueue/stream, heap_ptr/limit, hc, mxcsr, rsp, ret, r0..r15,
  x0..x15, eflags, lasterr, fake_heap), 837 stubs (addr -> name). 38 MB (gz 7 MB). SELF-CHECK byte-identical, facts and
  stubs equal; the TOOTH bites (flip -> crc fail; re-seal -> region compare fail). Scope note: the JUNO oracle REPLACES
  the engine render's thread transport (CWaveGen vt+56, 0x3C7400) with the e2e_emu composition over the plugin's OWN
  voice (0x398F30) / master (0x398EC0); so the reach/lift cover the DSP, and jn_host.c must carry that render
  composition as glue (graded against e2e_emu by L5), the JUNO twin of jp8_host.c's thread transport. The JUNO editor
  is simpler than JP8's (no window-message model): createView + attached, a window found by its fit (0x312750), zoom
  via 0x2AA590. NEXT L4: junoh.h + lift/jn_host.c (init via the live host setup + the render composition), then L5.
- 2026-10-15 L4 host-flavor lift: jp8_lift.py gained a minimal, JP8-safe --replace flag (a named rva becomes one host
  hook, f_x(c){jp8_hook(c,rva);}, body never lifted; the twin of --alloc's body replacement; guarded, so JP8's gate
  is unchanged). tools/lift/gen_juno_lift.sh now emits the HOST flavor: --hostcalls (imports / COM -> jn_host.c),
  --alloc 0x67522C --alloc-tailcall (the CRT allocator = e2e_emu ALLOC), --replace 0x3c7400 (the engine render's
  thread transport, served by the host). Regenerated lift/jn_lift.c: 1883 functions, 157054 instructions, 601 traps
  (471 int3 padding + AVX/FMA/SSE4 in unreached CRT branches). L2 check PASS (0 reached traps of 566). Compiles clean
  under the device/web build flags (-DJP8_RELOC -DJP8_FLAT -DJP8_GS_BASE=0x580000000ULL, rc 0, 8.3 MB object).
- 2026-10-16 L5 INIT GREEN: the lifted JUNO host boots EXACTLY like the oracle. lift/junoh.h (API) + lift/jn_host.c
  (the host glue: JNH1 template loader, COM + import shims, live setupProcessing + setActive + host objects, patch
  load, get/set state, UI timer, MIDI learn, editor record set; process/render stubbed) built with lift/jn_lift.c +
  jp8/src/jp8_rt.c -> libjunohost.so. tools/lift/jn_host_gate.sh (two processes): the oracle (jn_host_mem_ref.py,
  Unicorn) vs the lifted host (jn_host_mem_c.py, ctypes) after boot_host + setup(48000, 512). Found and fixed on the
  way: (1) juno_lift_reach.py installed its hook AFTER start(), so setupProcessing/setActive ran un-censused -- now
  boot, hook, setup; (2) the census keyed indirect edges by the block start, not the call instruction, dropping every
  non-pdata indirect target -- now keyed by the call; (3) the plugin's adjustor / ILT thunks (pdata gaps, reached by
  indirect call) are not pdata starts -- tools/lift/thunk_roots.py roots each whose jmp lands on an executed method
  (1665 thunks). Lift grew 1889 -> 3652 functions. junoh_init rc 0; image + heap + com byte-identical (heap_top
  0x317aec780, com_next 0x5a0001ab0); the rate tooth bites (image differs at +0xc43c20). NEXT L5: the render
  composition (jp8_hook 0x3C7400 over the plugin's own voice 0x398F30 / master 0x398EC0), then process()/patch/state/
  editor drives EXACTLY 0.
- 2026-10-16 L5 PROCESS GREEN: the lifted render is bit-exact. jn_host.c's jp8_hook(0x3C7400) composes the engine
  render over the plugin's own VOICE_WRAP (0x398F30) / MASTER_WRAP (0x398EC0) per sample, with the assigner
  voice-count sync, on a copy of the process() CPU (a nested stack) -- the oracle's host_process_emu._serve in C.
  junoh_process builds the events / parameter queues / context / process-data like host_process_emu.process and calls
  IAudioProcessor::process (slot 9). Gate (tools/lift/jn_proc_{ref,c}.py, jn_proc_seq.py shared drive): the oracle vs
  the lifted host over no-context AND context blocks, a chord, release, flush, 512-sample blocks -- 4224 output words
  BYTE-IDENTICAL; the note tooth bites (a semitone up differs at byte 3720). On the way: a trace-diff
  (jn_otrace.py + the --trace lift) PROVED the lifted process() identical to the oracle for all 3155 instructions --
  no mislift; the only gaps were completeness (interior indirect-call / tail-jmp targets with no pdata of their own,
  e.g. 0x3c7c6f no-context, 0x3b929f context). Robust fix: the census records jmp edges too, jn_extra_roots.py roots
  every interior indirect target (plus the pdata-gap thunks), and the census + reference + gate share ONE process
  drive (jn_proc_seq) so no path is un-censused. jn_host_gate.sh now runs both the init and the process gate. The
  quick-census (2-patch) lift proved it; NEXT: the FULL 64-patch census for the committed lift, then the state /
  patch / editor drives and the all-patch product gate, then L3 (per-instruction) and L6 (machine search).
- 2026-10-16 FULL census confirm: tools/verify/juno_lift_reach.py over all 64 factory patches + the shared process
  drive -> 4667 functions, 789,263 instructions in lift/jn_lift.c. jn_host_gate.sh GREEN on this committed-quality
  lift: init (image+heap+com byte-identical, tooth bites) AND process (4224 output words byte-identical, note tooth
  bites). The lifted JUNO boots and renders bit-exact to the oracle. NEXT: end-state memory compare after the process
  drive, the state save/load + patch load + editor drives, the all-patch product gate; then L3 and L6.
- 2026-10-16 L5 process end-state GREEN: the process gate now compares the plugin's end-state memory (image + heap +
  host arena) after the drive as well as every output word. Both byte-identical to the oracle on the full-census lift.
  The lifted render is proven to the sample AND to every internal engine-state byte (ramps, LFO phases, filter state).
