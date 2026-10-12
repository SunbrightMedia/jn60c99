# JUPITER-8 — THE HOST LAYER (the plugin as a DAW runs it)

Status 2026-10-12: the oracle boots and plays the plugin through its own process() (EXECUTED); nothing of the host
layer is in the C engine yet (jp8/src/jp8_engine.c drives the units directly, the drive2 path). Labels: READ = static
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

## 4. Next

1. The patch path: the plugin's own patch load (the patch browser) or the DAW state (setState), located and driven.
2. The C side: the lift rooted at the VST3 entries (process, setupProcessing, setActive, getState, setState) with
   the template = the oracle's memory after start(), the thread transport as two hooks in the lifted code (the jobs
   at 0x4460E7, the park at 0x4456F0), and the host objects (event list, parameter changes, process context, bus
   buffers) as C plumbing. Gate: process() blocks, plugin vs port, every output word.
