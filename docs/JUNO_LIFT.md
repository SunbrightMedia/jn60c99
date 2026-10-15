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

