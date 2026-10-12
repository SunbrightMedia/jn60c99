# JUPITER-8 — THE HOST LAYER (the plugin as a DAW runs it)

Status 2026-10-12: the oracle boots and plays the plugin through its own process() (EXECUTED), and the C side runs
the plugin's own host entries, lifted, bit-exact against it: jp8_host_gate.sh GREEN on 4 patches, 6 teeth (section 5). Labels: READ = static
reading of the JUPITER-8 image, EXECUTED = run under Unicorn, INFERRED = neither.

## 1. The wrapper is the Roland Cloud framework (READ)

`jx3p/tools/fw_map.py jp8/truth/JUPITER-8VST3_64bit.vst3` (normalized instruction streams, the JX-3P's method): 13 of
the 24 JUNO wrapper functions map to exactly one JUPITER-8 function; the other 11 differ in their bytes.

| JUNO rva | JUPITER-8 rva | function |
|---|---|---|
| 0x348B40 | 0x36A700 | GetPluginFactory (export) |
| 0x349EA0 | 0x36BA50 | IComponent::getState |
| 0x34AA50 | 0x36C600 | IComponent::setActive |
| 0x34A380 | 0x36BF30 | IAudioProcessor::process |
| 0x3CB150 | 0x449EE0 | IAudioProcessor::setupProcessing |
| 0x321AC0 | 0x33BC30 | core setup |
| 0x3208E0 | 0x33AA50 | the all-sound-off record |
| 0x343A80 / 0x343E30 / 0x344280 | 0x365310 / 0x3656C0 / 0x365B10 | render-object lookup / rate converter / silence |
| 0x34B260 | 0x36CDF0 | the automatic engine rate |
| 0x3C7A20 | 0x4464F0 | engine setSampleRate (= SETSR of the drive2 oracle) |
| 0x3BE2F0 | 0x43C310 | arp init |
| 0x349CA0 | 0x36B860 | processor createInstance -- NO byte match; the same shape (READ): ALLOC 0x3A8 (the JUNO's 0x3B0), the core at class + 0x148, rax = class + 0x110 |

Not matched (different bytes; to be located when needed): setState, core initialize, the render driver, the UI-timer
drain, the non-note MIDI path, ManagePatch, the patch load, the patch manager, the window zoom getter and fit.

## 2. The engine render is threaded (READ)

CWaveGen vt+0x38 = RENDER 0x445DC0 (rcx = HOST, r9 = the output pointer pair, stack arg 6 = frames). Per block: the
host lock HOST+0x40; per unit u (0..7): its two output vectors resized to the block (HOST+0x2E0 + 0x30 u), the
assigner's voice count synced to [HOST+0x38] (vt+0x88 / vt+0x80), the assigner clock 0x37DF50(nframes), and when
u < [HOST+0x38] the unit's JOB flagged (job = HOST + 0x4D0 + 0x80 u: +0x30 frames, +0x34 = 1, its lock +0x38, its
condition +0x48 signalled). Then the done lock HOST+0x488 and the wait until [HOST+0x480] = [HOST+0x38]; then the
master loop on the calling thread (MASTER_WRAP 0x3F8040 per sample, a2 = the 16 unit-vector pointers + 4 i) and the
output peaks (abs max per channel).

The WORKER 0x445670 (rcx = job, edx = unit) is a thread: FTZ | DAZ set on entry (0x36C8C0, restored at exit
0x36C960); its loop: take the job lock (0x4456F0), wait while +0x34 = 0, for flag 1 render the block -- VOICE_WRAP
0x3F80B0 per sample through the pair at job+0x20 / +0x28, both advanced by 4; unit 0 also feeds a tracker at
HOST+0x460 every sample (0x33F550, two parameter reads 0x43EEA0 ids 0x20 / 0x21) -- then flag 0, the done count
+1, the done condition, the lock released, back to the top; flag 2 ends the thread. The locks are boost's
(lock bit 31, event bit 30, a lazily created event).

## 3. The oracle (EXECUTED): jp8/tools/jp8_host_emu.py

The JUNO's host oracle (probes/b6/wrapper_emu.py + tools/verify/host_process_emu.py) loaded a second time with the
JUPITER-8's PROFILE on jp8/tools/jp8_emu.py, exactly as jx3p/tools/jx_host_emu.py does for the JX-3P:
DllMain 0x6F726C, InitDll 0x448710, GetPluginFactory 0x36A700, createInstance 0x36B860, the TLS directory
(0xB9E120..0xB9E13C, index 0xD278E8). The one replacement is the thread transport (the JX's): the render stops at
the done lock's acquire 0x4460E7, the oracle runs the worker function from its entry for every flagged unit until it
comes back to the top of its loop (0x4456F0, its lock released), and resumes the render at the same instruction.

The JUPITER-8's script folder (all from truth/): Script.xml draws on ScriptResourceCmn.xml (43 bitmaps) and the
About / Auth / Browse / Header / Manage / Setup / Tweak scripts, and on TextCodeTable.dat; all are served. EIGHT PANEL
TYPES the main panel uses are defined in no script of truth/: edit, functionUpper, functionLower, bendModSens,
origDelayTimeTsOn / Off, origLfoRateTsOn / Off -- a script file of the plugin's folder the truth copy lacks. Without
them the view manager refuses the root panel (the plugin's own log, hooked at 0x466AA0: "Unable to find child panel
type definition edit", "Unable to convert root panel definition main to root panel", "Unable to create view
manager") and IComponent::initialize returns E_UNEXPECTED. The oracle serves them EMPTY in a stub file named for what
it is (ScriptMissingPanelsStub.xml): GUI scaffolding, like the blank skin images, that never reaches the engine. OPEN:
the real file, from the user's install (it also carries the synth panel the GUI needs).

First run (EXECUTED 2026-10-12): DllMain 4.5 s, InitDll 16 s, initialize -> S_OK; start(48000, 512): HOST rate
96000.0 (the 96 kHz engine of the default setting), 8 voices; 12 blocks of 512 with a note on at block 2 and off at
block 9: 8 or 16 worker jobs per block (one or two engine renders behind the rate converter), peak 1.6e-13 idle,
0.079-0.082 under the note, 0.049 in the release, back to 1.6e-13; no non-finite sample; 0.5 s per block.

## 4. The VST3 surface (EXECUTED 2026-10-12, jp8/tools/jp8_surface_census.py)

The JUNO-60's census probe (probes/host_api/vst3_surface_census.py, now a function of any started host oracle) run on
the JUPITER-8 booted at 48000 / 4096: every answer is the JUNO-60's (docs/HOST_CALL_CENSUS.md) -- one framework.

| Call | The JUPITER-8 |
|---|---|
| canProcessSampleSize | 32-bit kResultOk, 64-bit kResultFalse |
| getLatencySamples / getTailSamples | 0 / 0 |
| getBusCount / getBusInfo | 1 audio out "Stereo Out" (2 channels, flags 1), 1 event in "Event In"; no inputs |
| getBusArrangement | out: stereo (3); in: 0x80070057 (no input bus) |
| setBusArrangements | mono, stereo, 5.1 accepted (kResultOk), stored |
| setIoMode, setProcessing, getRoutingInfo | kNotImplemented (0x80004001); setProcessing changes nothing |
| activateBus(.., 1) | kResultOk; the core's first 1 KB or a unit's first 512 bytes change (on the JUNO: the bus flags, which its render never reads -- bus_audio_census.py; not yet asked here) |

## 5. The C side (EXECUTED 2026-10-12): the host path, lifted

jp8/src/jp8_host.c + jp8h.h run the plugin's own VST3 entries -- setupProcessing 0x449EE0, setActive 0x36C600,
process() 0x36BF30, getState 0x36BA50, setState 0x36C650 -- its patch load 0x355F90 and its engine workers 0x445670,
all LIFTED (jp8_lift.py --hostcalls --hook --alloc-tailcall: jp8/src/jp8_host_lift.c, ~970 functions, ~130,000
instructions; the roots are read from the plugin's own vtables by the reach), on the JP8H v2 template: the oracle's
memory after boot_host (DllMain, the factory, the component and controller initialized and connected, the handler,
setComponentState) -- the point a DAW reaches BEFORE it knows its sample rate. jp8h_init(template, rate, max block)
then makes the host's own setup calls (setupProcessing, setActive(1)) through the lifted code and creates the blocks'
host objects in the oracle's order (one bump allocator: the same guest addresses). Plumbing only: the host objects
(IEventList, IParameterChanges, IParamValueQueue, IComponentHandler, IBStream) and the imports the path reaches
(HeapFree, GetCurrentThreadId, the SRW locks) answer as the oracle's; the thread transport is two hooks (the jobs at
0x4460E7, a worker's park at 0x4456F0). An unlifted path, an unknown host call or an unshimmed import TRAPS (named).

The gate (jp8_host_gate.sh; drive jp8_host_seq.steps, v4): per patch the patch load and 8 process() blocks (a note,
ten keys on eight voices, their release, host automation of two of the plugin's own parameters (from the controller
census), MASTER TUNE and an id the plugin does not have, a host clock, block sizes 480 / 32) and getState; then the
MIDI controllers through process() (IMidiMapping's ids: the mod wheel, expression, the sustain pedal held across a
key's release, aftertouch, bend down / up / back, all notes off under held keys, CC 7, a panel parameter swept); the
JUNO-60's host-rate chain (48000 -> 44100 -> 96000 -> 88200 -> 22050 (no converter: silence, no worker job) -> 48000,
a key held across each change); setActive off / on; the UI timer's drain (the core's vtable slot 1, rva 0x33A290)
and MIDI learn as the GUI's CC menu makes it (Learn rva 0x326660, Forget 0x324F00 on core + 24, the record index
from the plugin's own lookup 0x325870 -- the JUNO-60's functions, byte-equal; CC 3 learned to a panel parameter,
drained, moved, forgotten, a learn of an id with no record); then the EDIT CONTROLLER as a DAW asks it (IEditController
slots 10-15: getParamNormalized, setParamNormalized at 0, 0.75, 1, 1.5 and -0.1, getParamStringByValue,
normalizedParamToPlain, plainParamToNormalized, getParamValueByString of "64" and "xyz") on four panel parameters,
MASTER TUNE, a MIDI-mapped id and an id the plugin does not have -- 150 calls, each graded by its answer, its double
(xmm0) and the bytes it wrote (the display string, the parsed value); then sixteen setState inputs, each followed by a note
and getState: a CC assigned to a panel parameter, a CC assigned to an id the plugin does not have (it corrects it),
every value at the int32 maximum and at -5 (it clamps 86 of them), a state cut after 20 entries, a count of 0 and
an empty stream (kResultFalse), the engine-rate setting (the state's 0x0FFFC015) at 1..5 and 6 (no converter:
silence), the voice count (0x0FFFC00E) at 4 and 1 (9 makes the plugin throw: a real host never sends it), and the
first patch's state as written. Graded: every step's result, every output word, every state byte, every performEdit
(id and value bits), the worker jobs, the bump pointer, the host-object allocator and the memory after (the image,
the heap, the host objects). The imports the crafted states and settings reach answer as the oracle does: GetFocus /
SetFocus 0 (the editor's focus, rva 0x31bd8b), RaiseException 0 for an exception the plugin handles itself, a C++
throw (0xE06D7363) traps, named; the controller's Enter / LeaveCriticalSection 1.
THE REACH (playbook 237): the lift is the closure of the 64-patch reach UNITED with the reach of the gate's own drive
-- the v3 gate (job jp8_host_gate3b) ran 85 steps EXACTLY 0 on the 64-patch reach alone, then a crafted state's next
block called an indirect target the long drive never had. The checked build's band check learned regions that span
256 MB bands at one offset (jp8_cpu.h jp8_cont, jp8_rt.c jp8_span_ok): with four patches the heap crosses
0x320000000.
THE GATE (job jp8_host_gate5, jp8/logs/host_gate_48000.log), patches 2, 63, 0, 12 on the united reach: 305 steps,
97,280 output words, 44,988 state bytes, 1,652 performEdits, 1,687 worker jobs and the memory after EXACTLY 0 in the
CHECKED and the PRODUCT build; the lift: 1,218 functions, 165,514 instructions (jp8/src/jp8_host_lift.c, generated
by the gate); teeth T1 74,668 differences, T2 a trap (the render then waits for a worker: CreateSemaphoreA), T3
CONTROL 1, T4 27,643, T5 a trap (a changed state's path is not in the lift), T6 9,207.
Development runs (a reach of the drive itself): patch 2 -- 125 steps, 73,728 words, 37,164 state bytes, 1,364
performEdits; patches 2, 63, 0, 12 -- 155 steps, 95,232 words, 43,032 state bytes, 1,652 performEdits, 1,663
worker jobs, end EXACT, in the CHECKED and the PRODUCT build; teeth T1 (one addss of the lift turned subss) T2 (a
worker job skipped) T3 (one template byte) T4 (the setActive after a new rate dropped) T5 (every state value read one
off) T6 (the UI timer never drains) each FAIL. The lifter learned pcmpeqb / pcmpeqw on the way (strnlen's SSE2 scan,
reached by setState at 0x776499).

V6 (2026-10-12): WHAT A DAW ASKS THE CONTROLLER, AND A HOST THAT DOES NOT LEAK.
- The controller's load-time calls, lifted and in the API (jp8h.h): getParameterCount (226) and every
  getParameterInfo (jp8h_pinfo, VST3's 792 bytes), IMidiMapping::getMidiControllerAssignment (CC n -> 0x0FFFC100 + n,
  128 aftertouch, 129 bend; bus 1 kResultFalse), IUnitInfo (2 units: Root 0, Others 2; 0 program lists;
  getSelectedUnit / selectUnit), IEditController::getState / setState (READ: `xor eax,eax; ret` -- the controller
  keeps no state of its own) and setComponentState (a DAW hands the controller the component's state after setState;
  no handler call, it moves the controller's model). An index outside [0, count) makes the plugin THROW (EXECUTED:
  std::vector::at, a C++ throw at rva 0x72e9a5): the API refuses it (JP8H_E_ARG) -- a real host never asks.
  getUnitByBus and setUnitProgramData answer kResultFalse, getProgramListInfo has no list to give (READ): not in the
  API. The IMidiMapping and IUnitInfo pointers come from the plugin's own queryInterface, once, in jp8h_init.
- THE LEAK (playbook 238). The oracle answers HeapFree with a no-op and the C runtime mirrored it: EXACTLY 0, and
  both sides leaked. MEASURED per call: a patch load 1.32 MB of heap, setState 35 KB, getState 15 KB, a process()
  block 8 KB (that one is MSVC's std::deque<float> -- 16-byte blocks for the 300,000-sample rings at HOST + 0x50 and
  + 0x78, kept by the deque and bounded by its 131,072-slot map at 4 MB: not a leak); and every host call that hands
  the plugin a buffer took new bytes of the 4 MB host-object area (about 200 patch loads filled it). Now, on both
  sides from the template's point: a freed block goes on the free list of its rounded size, the next allocation of
  that size takes the last one back (LIFO), zero-filled (jp8_host_emu.JP8Host.heap_reuse_on, jp8_rt.c
  jp8_heap_reuse); every host buffer is a fixed slot of one scratch area (jp8_host_emu.SCR, jp8_host.c SCR_*),
  cleared before use; one stream object serves every state call. MEASURED: 160 patch loads cycling the 64 factory
  patches grow the heap 31 MB and then stop (259 blocks kept by the plugin). The gate grades the reuse layer's live
  and free block counts, and the oracle stops if the host-object area moves after the setup.

SPEED (the product build, 48000 host, the 96 kHz engine, four keys held, this shared Xeon with three other jobs):
950 ms per second of audio (init 176 ms, a patch load 4 ms) -- inside real time with no margin; the plugin's own
code natively is about 2.3x faster (188 ms per second at 44.1 kHz, the full-chain measurement, scaled to 96 kHz).
Where the time goes (callgrind, 30 blocks, four keys): 67 % in the eight voice-unit render functions (one copy per
unit: f_395000, f_39ed80, f_3a8a40, f_3b2700, f_3bc3c0, f_3c6080, f_3cfd40, f_3d9a00, 8.4 % each) -- about 7,600 host
instructions per voice per engine sample against the plugin's own 3,632; VOICE_WRAP 3.5 %, the CRT's math 6 %. The
arithmetic is the hardware's (MXCSR set); the extra cost is the guest memory and stack traffic (every inlined call
still writes its return address to the guest stack) and the flag bookkeeping -- the fast pass's next targets. The
hottest function compiled (-O2): 52,813 host instructions, 15,522 of them (29 %) on the host's own stack frame --
spills: the sixteen guest registers and the temporaries do not fit the host's sixteen. The biggest lever left is
the plugin's own: it renders its eight voices on eight threads; the runtime runs those jobs one after another. A job
never allocates (a counted drive, patch 2: 0 of 50,504 allocations inside a job), so the jobs are independent and
could run in parallel; what stands in the way is the jobs' bookkeeping -- the done count and the lock words are
read-modify-write instructions that would then have to be atomic, which ISO C99 cannot say. DONE the same day, as a
platform layer (JP8H_THREADS: POSIX threads, __thread; the default build stays sequential ISO C99): each flagged job
runs on its own thread with the render's registers and its own stack; all render at once; at rva 0x44580A (a new
hook: the job's render loop has ended) each waits for its turn, and the bookkeeping runs one job at a time in unit
order -- the sequential transport's order, so no atomics are needed and the result is the same. Patch 2's v5 drive:
EXACTLY 0 in 10 of 10 runs; 711 ms per second of audio against the sequential 1,058, on this 4-core machine with
two other jobs running (an idle machine with 8 cores gains more). The gate grades it as a third build.

Scope NOT covered yet (owed): other first setup rates (44100, 96000: jp8_reach_merge.py takes their reaches;
job jp8_host_gate7 runs them on the v5 drive); the editor (and the drawn panel: the script file truth/ lacks);
IEditController2 (knob mode, help, about: GUI only).

## 6. Next

1. Other first rates: JP8_HOST_RATES="48000 44100 96000" (one lift, the oracle and both builds at each).
2. The controller's parameter info in the C API (from the census data or the lifted calls); the editor.
3. The speed: the lifted path must gain margin before it is a product (the fast lifter's next steps, S3_STATUS).
