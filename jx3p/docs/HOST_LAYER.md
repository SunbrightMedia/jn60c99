# JX-3P — THE HOST LAYER (the plugin as a DAW runs it)

Status 2026-10-10: the oracle boots and plays the plugin through its own process() (EXECUTED); nothing
of the host layer is ported to C yet. Labels: READ = static reading of the JX image, EXECUTED = run
under Unicorn, INFERRED = neither.

## 1. The wrapper is the JUNO-60's (READ)

`jx3p/tools/fw_map.py` reduces each function to a normalized instruction stream (rip-relative operands,
branch targets and in-image immediates masked; a switch table written as its offset in the function)
and maps the JUNO functions the JUNO port rests on to the JX image: 24 of 24 map to exactly one JX
function (`--tooth`: the JUNO's engine BUILD maps to nothing, one changed byte breaks a match).

| JUNO rva | JX rva | function |
|---|---|---|
| 0x348B40 | 0x348A00 | GetPluginFactory (export) |
| 0x349CA0 | 0x349B60 | processor createInstance |
| 0x349EA0 / 0x34AAA0 | 0x349D60 / 0x34A960 | IComponent::getState / setState |
| 0x34AA50 | 0x34A910 | IComponent::setActive |
| 0x34A380 | 0x34A240 | IAudioProcessor::process |
| 0x3CB150 | 0x3FD040 | IAudioProcessor::setupProcessing |
| 0x320420 / 0x321AC0 | 0x320300 / 0x3219A0 | core initialize / core setup |
| 0x320B20 | 0x320A00 | the render driver |
| 0x3208E0 | 0x3207C0 | the all-sound-off record |
| 0x320120 | 0x320000 | the UI-timer drain |
| 0x31F4E0 | 0x31F3C0 | the non-note MIDI path |
| 0x322E60 / 0x335850 / 0x338090 | 0x322D40 / 0x335730 / 0x337F70 | ManagePatch / patch load / patch manager |
| 0x343A80 / 0x343E30 / 0x344280 | 0x343940 / 0x343CF0 / 0x344140 | render-object lookup / rate converter / silence |
| 0x34B260 | 0x34B120 | the automatic engine rate |
| 0x3C7A20 | 0x3F9970 | engine setSampleRate |
| 0x3BE2F0 | 0x3F0160 | arp init |
| 0x2AA590 / 0x312750 | 0x2AA470 / 0x312580 | window zoom getter / fit |

The host settings (vm.vs, Script.xml) are the JUNO's with one more entry, `edit`, so every id from
0x0FFFC01C on moves up one: voiceCount 0x0FFFC00E (default 6), sampleRate 0x0FFFC015 (default 0),
velSense 0x0FFFC00D (default 1), quality 0x0FFFC00F (default 0), **edit 0x0FFFC01C, writePatch
0x0FFFC01D**, auth 0x0FFFC01E. (Ids: 0x0FFFC000 + the running size of the entries before, int4x4 = 4;
the rule reproduces every JUNO id the JUNO port uses.)

## 2. The engine (READ)

The plugin's processor builds its engine with the factory 0x3F84E0 (ALLOC 0x880 + ctor: vtable
0xA15B88, rate 96000.0 at HOST+8, 8 voices at HOST+0x38, the output gain stage below at 1.0 / 0 / 0).
Vtable slots: 0x08 BUILD 0x3F8610, 0x18 setSampleRate 0x3F9970 (returns at once when the rate is
unchanged), 0x38 RENDER 0x3F9220, 0x70 host parameter entry 0x3F9A30, 0x78 / 0x80 note off / on.

**The render (0x3F9220).** Per voice unit u = 0..7: the assigner's count synced to HOST+0x38 (its
vt+0x88 / vt+0x80), its clock 0x357EA0(n); u < count: the unit's job flagged for its worker thread;
else its outputs zeroed. Then it waits for the done count HOST+0x410, runs MASTER_WRAP 0x377010 per
sample, and -- unlike the JUNO's render 0x3C7400 -- an **output gain stage** per sample over both
channels: HOST+0x860 gain, +0x864 step, +0x868 samples left, +0x86C delay, +0x870 time (s), +0x878
the rate source (vt+0x20). While samples are left the gain moves by the step, clamped to [0, 1];
after that a positive step holds 1.0, otherwise the gain is 0 and the delay counts down; when it
ends the fade-in starts: trunc(rate x time x 0.001) samples (at least 1), step 1/that.

**The worker (0x3F8C60).** A thread per voice unit: on its flag it runs VOICE_WRAP per sample over
the block (unit 0 also calls vt+0x68 of its engine object each sample: 0x34AE20, `ret 0`), then
raises the done count under the lock HOST+0x418 and wakes the render. The assigner clock 0x357EA0
only adds the block size to assigner+0xB0.

**The voice count (READ).** The assigner (vtable 0x9A1198; ASG_NOTIFY 0x356BF0 = the JUNO's 0x3549B0)
returns its count from +8 (0x357E50); its setter 0x357CE0 is NOT the JUNO's 0x355940: it resets
(0x356E80, 0x355280), stores the count (vt+0x78), then re-reads host parameters 0x320 (800; a
change clears +0x50/+0x58 or +0x44 and is kept at +0x10) and 0x31F (799, kept at +0x14) through
vt+0x50 -- the JX's own control layer, to be ported, not shared.

**writePatch.** The host parameter entry 0x3F9A30 takes 0x0FFFC00E as the voice count (HOST+0x38)
and **0x0FFFC01D (writePatch), any value**, as: 1 sample left at step -1 (the gain drops to 0), a
delay of trunc(rate x 500 x 0.001) samples (0.5 s), then a fade-in over trunc(rate x 10 x 0.001)
samples (10 ms; 960 at 96 kHz). The factory leaves step 0, so the gain stage outputs 0 until such an
event (READ); initialize's defaults carry writePatch (INFERRED from the JUNO's state list; to be
EXECUTED).

## 3. The oracle (EXECUTED)

`jx3p/tools/jx_host_emu.py` runs the JUNO's host oracle (`probes/b6/wrapper_emu.py`,
`tools/verify/host_process_emu.py`, loaded a second time with the JX profile) on `jx_emu`: DllMain
(the PE entry 0x6ACD8C), InitDll (export 0x3FB630), GetPluginFactory, createInstance, initialize (the
component vtable's slot 3), the edit controller (its class id asked from the component), setState,
setupProcessing, setActive, process(). The ONE replacement is the worker transport: the oracle stops
the render where it is about to wait (the done lock's acquire, 0x3F9587), runs each flagged worker's
own code from its entry until it parks at its wait (0x3F7010), and resumes the render there. The
render, the gain stage, the master and process() are the plugin's own instructions.

First run (host 48000): initialize leaves 84 queue records; the first block runs 6 worker jobs (the
default six voices), output 0, gain 0.0.

## 4. Next

1. EXECUTE (`jx3p/tools/jx_boot_census.py RATE`): the first second of a fresh instance (the 0.5 s
   mute and the 10 ms fade-in), a note through process() at host 48000 / 44100 (converter) and
   96000 (identity), the 84 records.
2. A JX gate in the JUNO's shape (host_process_gate.py): the plugin's process() vs the port.
3. The C side: the JUNO's host layer (src/juno_conv.c, the render driver, the state, the patch
   manager) on the JX engine, the gain stage and the writePatch fade in the JX bridge.
