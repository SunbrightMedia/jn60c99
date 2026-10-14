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

## 2b. The render object and the rate setting (EXECUTED + READ)

`jx3p/tools/jx_conv_tables.py` boots the JX through its own entry path (jx_host_emu, two host rates),
reads the render-object table (rva 0xC7BC30, 45 entries + the terminator), its coefficient vectors
and the engine-rate setting table (rva 0x981B58), and compares them with the JUNO-60's
(src/conv_tables.h, in the generator's own blob form):

- **The table and the 9 vectors are the JUNO-60's, byte for byte** (sha256 of table + vectors
  8902407066ef...86d61 on both; EXECUTED 2026-10-10, job jx_conv; `--tooth`: one flipped coefficient
  bit is seen, job jx_conv_tooth). The JX-3P's render object is src/juno_conv.c with
  src/conv_tables.h as they are.
- The setting table's entries 0..5 are the JUNO-60's (96000, 88200, 48000, 44100, 32000, then the
  word the automatic setting never reads); 81 of 128 words differ from index 6 on (the bytes after
  the table in the image). Generated: `jx3p/src/jx_srate.h` (JX_SRATE[128]).
- READ (`jx3p/tools/fw_map.py --pair`, the normalized streams to their ret): the setting listener
  0x3221D0 == the JUNO's 0x3222F0; the identity render 0x344130 == 0x344270; the automatic engine
  rate 0x34B120 == 0x34B260.

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

**The 84 records initialize queues (EXECUTED, `jx_boot_census.py --records 48000`, job jx_records).**
All at offset 0, applied by the first process() before its render:
- 72 model values of the patch tree (`fm.PATCH.*`, ids 0x0060xxxx and 0x00A0xxxx -- the JUNO-60's
  id space, src/juno_state_tables.h): the default patch, e.g. 0x00600004 = 175, 0x00600014 = 3,
  0x00600080..0x0060009C = 11565 each (0x2D2D, the name), 0x00A00000 = 0x3F2FAFB0 (a float, 0.687),
  0x00A02802 = 0x3F800000 (1.0). All are in the host entry's id map (744 ids from the static
  initializers; jx_emu.host_map() lists only ids < 0x100000, which once made it look like 3).
- MASTER TUNE, host id 2 = 100 (the map sends it to engine id 20).
- 10 host settings: 0x0FFFC000 = 0, 0x0FFFC003 = 1, **voiceCount 0x0FFFC00E = 6**, 0x0FFFC008 = 62,
  **sampleRate 0x0FFFC015 = 0** (96000), 0x0FFFC010 = 0, 0x0FFFC014 = 0, 0x0FFFC016 = 62, edit
  0x0FFFC01C = 0, **writePatch 0x0FFFC01D = 1**.
- 1 kind-0 record.
So a fresh instance arms the writePatch fade (0.5 s at gain 0, then 10 ms in) and plays six voices:
the first block shows step -1, 1023 samples past the drop, the delay at 46977 of 48000 (READ x
EXECUTED agree).

**The voice count (READ, the render 0x3F9220 + the assigner).** Per voice unit u = 0..7 (the unit
objects 0x40 apart from HOST+0x68): the assigner's count (vt+0x88, 0x357E50 = [asg+8]) synced to
HOST+0x38 through vt+0x80 (0x357CE0) when it differs; the clock 0x357EA0 adds the block's engine
samples to [asg+0xB0]; u < count: the unit's job; else its two output vectors zeroed (no wrapper
call). The master unit's assigner is not synced. The setter 0x357CE0: 0x356E80(asg, 0) (each voice
whose released flag +0x62 is 1: flag cleared, gate-off sweep 0x357570 over them; if +0x1C was 1, the
sweep over all and the voice records reset), 0x355280 (with +0x18 clear: the sweep over all voices
[asg+0xC], voice records reset, +0x44/+0x4C..+0x5F cleared; else +0x1C = 1), the store vt+0x78
(0x356F60: count = min(n, 8), mask, mode/flags/records/order array reset, then 0x355280 again), then
host parameter 800 (0x320) into the mode +0x10 (a change to 1 or 2 clears the held-note bitmap
+0x50..+0x5F, to 0 clears +0x44) and 799 (0x31F) into +0x14, both through vt+0x50 (0x357E60: the
parent [asg+0xA8], its vt+0x60 with edx 0). The sweep posts a gate-off only for a gated voice: at
boot it posts nothing. The assigner's time read vt+0x70 (0x357EF0) is [asg+0xB0] / 96 (signed); the
port's model of it (jx_bridge.c unit_get70) is the sample clock / 48 -- to be checked against this.

## 3b. The patch protocol (EXECUTED, 2026-10-10)

A patch load through the plugin's patch browser (rva 0x335730) queues 75 records, the same order for
every patch: writePatch (so EVERY patch change mutes 0.5 s and fades in 10 ms), MASTER TUNE 100, then
the patch tree. The next block's render driver hands them to the engine's host entry (0x3F9A30): the
id map gives the dispatch id; dispatch 769 takes value - 128, 20 (MASTER TUNE) value - 100 (READ:
also 22: -12, 0x299 / 0x2C3: -100, 0x2F4 and 0x33F..0x343 their own calls), the range check
(0x3DD7E0), then every unit's dispatch (0x3EBB00) with flag 0 and its assigner notify (4). Census over
all 64 factory patches (`jx_patch_protocol.py`, scratchpad/jx/patch_protocol.pkl): 62 dispatch kinds
(69 with the arp's 312..318 on two patches), against the port's old pool model: 17 model-only ids
(all constant over the bank), 20 product-only ids (most of them varying per patch: 855..861,
873..878, 1028, 1029, 1058, the effect floats), 769 off by 128, flag 1 instead of 0. MEASURED effect:
patches 0, 20, 49 about 3x louder in the port than with the plugin's values.

The engine-level oracle now drives the plugin's own records (`jx_emu.boot(product=True)`:
initialize's records, then `recall_product(k)`: patch k's records, through the host entry;
records in jx3p/gen/jx_patch_records.json from `jx_patch_records.py`). `jx_recall_product_check.py`:
that engine equals the booted plugin's at its render, word for word, every unit's state, parameter
object and assigner (patches 0, 5, 20, 49, 63; tooth: one record left out, 81 words differ).

## 3c. The render driver's clock tick (EXECUTED + READ, 2026-10-10; PORTED, JX-7)

The render driver (the JUNO-60's machine code) ticks the engine 24 times per beat at the host tempo,
120 when the host gives none: one tick per 1,000 samples at 48 kHz, the first at sample 0 of the first
block, before the engine renders. A tick is the engine's vtable +0xB8 (rva 0x3F84A0, called at
0x320F52): per unit its note manager's counter +0x0 += 1, the manager's tick (0x3F5910) and the note
store's tick (0x3EFD10). The manager's tick does nothing until the flag +6 is set -- the arpeggiator's
pattern apply sets it (0x3F2C28, in 0x3F2B00: 3e) -- and then, at the next 12- (or 24-) tick boundary, clears
it and plays its note lists again through the note store; the note store's tick runs its step machine
(+0x2C state, +0x14 / +0x18 counters, 16 slots of 12 bytes at +0x326) and plays notes through its own
output (vtable +0 / +8 into the assigner at +0xFD8; the step function at +0xD98). MEASURED through
process() at 48000 before the port: on factory patch 34 the note plays on the clock -- 2 samples after
its block starts the plugin's output and the port's differed; patch 0 was equal. (This section first
named the setter of +6 "the KEY ASSIGN setter" and listed 38, 59 and 60 with 34 as clock patches,
from host parameter 800: wrong -- 800 is the assigner's mode; the clock patches are those with the
ARPEGGIO switch on, 34 and 61, EXECUTED by jx_tick_gate.py's reach counts.)

PORTED (jx3p/src/jx_seq.c, ~1,150 lines, every branch from the instructions): the tick 0x3F84A0, the
manager's tick 0x3F5910 and release 0x3F56E0, the note store's tick 0x3EFD10 and its graph (0x3EF210,
0x3EF3B0, 0x3EF910, 0x3EFBF0, 0x3F1650, 0x3F1B10, 0x3F1EA0, 0x3F2120), the 19 step functions, the
store's random numbers 0x3F2A90 and the mode setter 0x3F1910; the note store's whole object (0xFF0
bytes, its +0x20 pattern pointer kept as its offset). The render driver's tick timing inside a block is
the JUNO-60's drv_block (gui/juno_bridge.c), ported as jx3p_product_block. Graded by
`jx3p/tools/jx_tick_gate.py` (the tick and the note fan-outs against the plugin's own, event by
event, every control object after every event, every unit's state at checkpoints) and
`jx_product_gate.py` (process(), 3d).

## 3d. The product path, stage 1 (EXECUTED, 2026-10-10)

`jx3p_product_open(host_rate)` / `jx3p_product_process(L, R, n)` (jx3p/gui/jx_bridge.c): the engine at
the template's own rate -- 96000, the automatic setting's at hosts 44100, 48000 and 96000 (EXECUTED:
[HOST+8] after setupProcessing) -- on 96 kHz data (`jx_template_export.py 96000 --out`,
`jx_master_recall_export.py --rate 96000 --template --out`; committed as .gz), through src/juno_conv.c
(the render object, equal to the JX's). `jx3p/tools/jx_product_gate.py` grades it against the plugin's
own process() (jx_host_emu: its patch browser's load, its render driver, its render object): patch 0
EQUAL at 44100 (130 blocks of 512), 48000 (141) and 96000 (282), a note from 0.6 s to 1.2 s; the tooth
(the 44.1 kHz data, no render object: the web app's path) differs at every rate. Patch 34 (ARPEGGIO
on) differed until the clock was ported (3c); with the render driver (jx3p_product_block, JX-7) patches
0, 34, 61 and 20 are EQUAL at the three rates (job jx7_gates), and with the notes inside their blocks
(`--exact`); a second tooth (`--tooth-clock`: the first key does not restart the clock) must differ on
34 and 61.

## 3f. Host automation through process() (READ + EXECUTED, 2026-10-10; PORTED, JX-11d)

The JUNO-60's wrapper code, the JX's tables. READ, the functions equal by `fw_map.py --pair`: process()'s
parameter record 0x31F1A0 (JUNO 0x31F2C0), the id map lookup 0x319990 (0x319AB0; its id pre-map 0x40F340
is `mov eax, ecx`), the record value law 0x31A820 (0x31A940), the CC value law 0x31A730 (0x31A850), the
vector's id 0x319B30 (0x319C50), the CC map lookup 0x319940 (0x319A60), the render driver 0x320A00
(0x320B20, 923 instructions); the round 0x428460 = the JUNO's 0x3F2050 (0.5, floor / ceil). The driver
(rva 0x3210B6): a kind-1 record's id through the id map (the tree at .data 0xCE8638; none: nothing) to
the engine's host entry vt+0x70 (0x3F9A30) with the record's OWN id and the value law
round(min + (max - min) x v) in single precision, half away from zero, clamped to int32; kind 2 straight
to the host entry. process() makes one kind-1 record per parameter queue below the MIDI-mapping base
(0x0FFFC100) -- its last point, the value as a float -- after the block's notes, in queue order.

EXECUTED (jx_gen_midi_tables.py, the booted plugin at 48000 and 44100, equal): 83 parameters in the core's
vector -- the model ids 0x0060xxxx, 0x00A0xxxx (two with the range 0..0x3F800000, the bits of 1.0f),
MASTER TUNE 0x00000002 (0..200) and ten host settings (voiceCount 0x0FFFC00E 2..8, sampleRate 0x0FFFC015
0..3, writePatch 0x0FFFC01D ...); 83 ids in the id map, every key cross-checked through the lookup and
911 ids probed (the host entry's 744, the settings, the MIDI ids); 55 CCs in the default map. Generated
into jx3p/src/jx_midi_tables.h (`--check` rebuilds it from two boots).

PORTED: `jx3p_product_param(id, offset, value)` (jx_bridge.c) queues the record as process() makes it; the
next `jx3p_product_block` puts it after its own events; the driver applies it through the id map, the law
and the lifted host entry. A MIDI-mapping id (base + 0..129: CC, aftertouch, bend) is refused (-1): not
ported yet. GRADED (jx_product_gate.py --edits, GATE 3d): seeded queues from the note-on on -- ids from
the map and ids it lacks, values 0..1, the ends, -0.25, 1.25, 1e-9, several points of one id per block,
several ids at one sample: seed 1 at 48000, 108 points (107 records), 225 blocks EQUAL to the plugin's
process(); teeth: no points to the port (`--tooth-edits`: differs from block 68), the law truncated
(`--tooth-law`).

## 3g. The MIDI controllers through process() (READ + EXECUTED, 2026-10-10; PORTED, JX-12)

A DAW sends MIDI controllers as VST3 MIDI-mapping parameters: base 0x0FFFC100 + n (n 0..127 the CC n, 128
channel aftertouch, 129 bend). process() (the JUNO's code, 3f) makes a MIDI message of each queue's last
point -- CC data round(v x 127), bend round(v x 16383) as two 7-bit bytes, beyond 129 three zero bytes --
and hands it to the push (0x31F3C0): a CC the default map assigns (55 CCs) first queues that parameter's
kind-1 record (the CC value law 0x31A730), then the message's own record after the wrapper's rules (a
note-on at velocity 0 becomes a note-off at 64; the velocity switch, on by default, changes nothing). The
render driver's dispatch (rva 0x32113C; its status table at 0x32193C / 0x32191C, READ): 0x90 note on
(vt+0x80), 0x80 note off (vt+0x78, with the message's velocity), 0xB0 the CC entry (vt+0x88 = 0x34AD50:
CC 1 -> vt+0x100 mod = dispatch 495 to the nine units, 10 -> `ret`, 11 -> vt+0x118 expression = dispatch
498, 64 -> vt+0x120 sustain: per unit 0x3F6B50 on [HOST+0x88+0x40 u] (its +0xC, then the note manager's
+0xA and +0x9: 0x3F6210 / 0x3F61E0, the held notes released when off), 123 -> vt+0x128 all notes off: per
unit 0x3F56C0, the assigner's vt+0x20 with 123; every other CC nothing), 0xE0 the bend entry (vt+0x98 =
0x3F91B0: clamped to -8192..8191 by 0x3F6D00, dispatch 493), 0xA0 / 0xC0 / 0xD0 three entries that are
`ret 0`.

PORTED (jx_bridge.c): `jx3p_product_note(type, offset, channel, pitch, velocity)` -- process()'s note
conversion and the push; `jx3p_product_param` takes the MIDI-mapping ids too; the driver's kind-0 dispatch
calls the CC and bend entries through the LIFT: the engine's vtable slots 0x78..0xA8 are lift roots
(jx_lift_roots.py CONTROL_SLOTS) and the reach has two controller runs (jx_dynreach.py --ctl). Not ported:
MIDI learn and the CC map's state entries (the map is the boot's), the model's records the push also
makes (the UI timer's), the velocity switch's other value (no path reaches it).

MEASURED (jx_lift_gate.py --loads ctl, GATE 3e): the controller script (jx_dynreach.py ctl_script: 66 calls
-- mod, expression and ignored CCs at their ends, 15 bends across and beyond the clamp, sustain on / off
around note-offs and note-ons, all notes off with keys down and held, the three empty entries) through the
plugin's entries and the lifted ones from patches 0 and 34: every return value and a heap checkpoint after
every call EXACTLY 0; teeth: the C twin skipping a sustain release (entry 86) or one CC (entry 6) is RED.
The first gate compared only the end state, and a skipped release did not bite (a later release freed the
same notes): playbook 202. The guest image: a bend read a page of the 64 KB curve table (0x9A4000-
0x9B4000, read at bend + 8192) that no census run had reached; .rdata and .data now ship whole.

## 3h. The note path is the plugin's own, LIFTED (EXECUTED, 2026-10-10; JX-12b)

The --ctl product gate (3g) was RED at 48 / 96 kHz: a small difference after a note-on when the sustain, all
notes off and mapped CCs came together (each group alone EQUAL). The mapped CCs were the key: the default CC map
sends CC 5 to PORTAMENTO (0x600060) and CC 116 to LEGATO (0x600062) -- and NO factory patch sets LEGATO (three
set PORTAMENTO). The port's note path was transcribed (jx_alloc.c, jx_nstore.c, jx_ktrack.c,
jx_dispatch_note.c, jx_seq.c) and graded EXACTLY 0 over 22,008 events -- every one of them in the factory
bank's note modes. The experiment that settled it: the same run with the two note entries lifted was EQUAL.

So the port now runs the plugin's own code for the whole note path: the engine's note entries (vt+0x80
0x3F9150, vt+0x78 0x3F90F0), its clock tick (vt+0xB8 0x3F84A0), the note store's mode setter (0x3F1910) and the
assigner's count setter (CAssignB vt+0x80, 0x357CE0: the render preamble's voice-count sync) -- and with them
the note managers, the note stores and their step machine, the assigners (assign modes, legato, portamento)
and the posts into the voices. Roots: the engine slots 0x78..0xB8 (jx_lift_roots.py CONTROL_SLOTS) and the
19 step functions, read from the setter's own jump table. Reach: jx_dynreach.py --notes from patches 0 and 34
(ARPEGGIO 0 / 1 x ASSIGN MODE 0..2 x LEGATO 0 / 1 x PORTAMENTO 0 / 120, each with overlapping keys,
re-strikes, the sustain, all notes off and ticks: 816 calls) and --tick from patch 34 (every step mode 0..18
put into every store by the setter, keys held across the 12- and 24-tick boundaries: 1,578 calls). The
transcribed modules keep their own gates; the port no longer includes them.

MEASURED (jx_lift_gate.py, a heap checkpoint after every script step): --loads notes from patch 0 and from
34, 816 calls each, and --loads tick from 34, 1,578 calls (1,426 checkpoints) -- every return value and every
heap byte EXACTLY 0; the controller runs (--loads ctl, 0 and 34) still EXACTLY 0. Teeth: the twin skipping
one legato note-on (entry 148) -- 2,574 words differ; skipping one tick of step mode 7 (entry 1,132). The tick
gate (jx_tick_gate.py) now counts its reach on the plugin's side (code hooks on the 19 step functions and the
assigner's note entries during the ticks); its tooth drops the step clock's `inc` (0x3EFE5E) from the lifted
source (jx_lift.py --tooth-drop). Through process(): the --ctl runs EQUAL at 44.1 / 48 / 96 kHz; the note modes
set at the start (jx_product_gate.py --set) EQUAL; GATE 3c 36 / 36; the full chain 4 / 4 (its key-shift tooth
now in the port's note entries, JX_FULL_TOOTH: it had lived in the removed transcription).

## 3i. The host tempo (READ + EXECUTED, 2026-10-10; PORTED, JX-8)

The render driver (0x320AE4 = the JUNO's 0x320C04, fw_map) takes the ProcessContext's tempo: T = round(tempo x
10), half away from zero (0x428460), clamped to an int. When the host's tempo is valid and T changed (core+580)
it calls the engine's vt+0xB0 (0x3F9DD0) with T: for T in 400..3000 every unit's dispatch 375 -- the effect
objects' tempo setters by the effect type (4. item 1 below has the chain). The clock's period is (60e9 x host
rate / T) / 24 in 1e-8 host samples, 120 without a valid tempo. PORTED: jx3p_product_tempo(valid, tempo) per
block, the driver's T and period, the tempo entry LIFTED (root 0x3F9DD0). MEASURED: jx_lift_gate.py --loads
tempo from patches 0 and 34 -- the tempo entry at 12 values of T (inside, at and past 400..3000, 0, negative)
under every effect mode (records 65 and 67 at 0..5) -- EXACTLY 0, every return value and heap byte; tooth: one
tempo call dropped (entry 152). Through process() (GATE 3d --tempo): patches 33 and 34 at a fixed 120, at
95.5 then 140 inside the run, and with no valid tempo, then 200, then none; tooth --tooth-tempo.

## 3j. The engine-rate setting (READ + EXECUTED, 2026-10-10; PORTED, JX-15)

The rate setting (vm.vs.sampleRate, state id 0x0FFFC015, & 0x7F) reaches the core's listener (0x3221D0): the
requested engine rate is JX_SRATE[v] (jx3p/src/jx_srate.h, the image's table at 0x981B58: 96000, 88200, 48000,
44100, 32000; 5 = the automatic setting, the current rate; 6..127 the bytes after the table). At the next
block's start the driver compares it with the render object's engine rate and, when they differ, calls the
engine's setSampleRate (vt+0x18, 0x3F9970: the rate a float in xmm1) and looks the render object up again;
found, the tick phase and the note count start again -- before the tempo and before the block's records.
setSampleRate on the running engine allocates nothing and calls no import (EXECUTED); its large frames call
the CRT's stack probe (__chkstk 0x6AC420), which reads gs:[0x10] -- 0 in the oracle (GS base 0, page 0 zero),
so the port maps 4 KB of zeros at 0 (the page census allows reads there and refuses writes). PORTED: the
listener, the driver's switch, setSampleRate LIFTED. MEASURED: jx_lift_gate.py --loads rate from patches 0 and
34 (48000, 44100, 88200, 32000, 96000 twice -- its early out --, keys held, notes and ticks between) EXACTLY 0;
tooth: one setSampleRate dropped (entry 12). Through process() (GATE 3d --state 'rV@T'): the setting at
48 kHz to 48000 and 44100 and back to 96000 on the running engine, at 44.1 kHz to 88200 -- EQUAL; index 6 (a
byte past the five rates: 31 Hz) silences the plugin and the port alike (--expect-silent).

## 3k. A fresh instance: the plugin's order (EXECUTED, 2026-10-10; PORTED, JX-15b)

The plugin calls setSampleRate(96000) while it is activated and applies nothing else; initialize's 83
records (the 82 state defaults in list order, writePatch = 1) and its all-sound-off message (CC 120) wait in
the queue. The first process() switches the engine's rate when the setting asks for another one, THEN
applies the queue (EXECUTED: hooks on setSampleRate and the host entry over start() and the first block). A
guest image taken after the records cannot follow that order: a setState holding the rate setting before
the first block was ~1 ULP off from block 47 on (playbook 204). The guest image (JXG1 version 2,
jx_guest_export.py) is now the heap as setActive leaves it. jx3p_product_init(image, bank, host rate) is a
fresh instance on the product path -- the render object for (96000, host rate) and initialize's records
queued (jx3p/src/jx_state_tables.h: the defaults, writePatch, JX_STATE_BOOT_MIDI); a patch load, a setState
and the first block's events queue after them, as the plugin's do. jx3p_init applies the records at once,
through the lifted host entry (the engine of the oracle's boot(product=True): the gates that drive the engine
directly keep it). MEASURED: jx_lift_gate.py --loads boot / boot48 / boot44 / boot88 / boot32 / boot31 /
bootat44 (the engine as setActive leaves it at 96000 -- bootat44: 44100 --, the switch to each rate of the
table and to 31 Hz, the records, CC 120 through the CC entry, a patch load, a key and a tick) EXACTLY 0;
tooth: initialize's writePatch dropped (entry 164). Through process(): the setting at 0..4 before the first
block at 48 kHz, at 2 and 3 at 44.1 kHz -- EQUAL (2 and 3 were the RED cases); the state gate (3l), the
product runs and the web check all start from jx3p_product_init.

## 3l. The DAW state, the UI timer, KEY HOLD, MIDI learn (READ + EXECUTED, 2026-10-10; PORTED, JX-17, JX-17b)

The JUNO's wrapper code (fw_map: getState 0x349EA0, setState 0x34AAA0, its deserializer, the CC map, the UI
timer 0x320000, the learn 0x31A920 / 0x319B70 / 0x3191C0) on the JX's tables: jx3p/src/jx_state_tables.h,
generated from the booted plugin (jx_state_census.py: initialize's queue, getState, setState of every entry at
14 test values, shuffled and partial payloads, the CC map assigned, moved and freed; jx_gen_state_tables.py).
getState: a big-endian byte count, the 82 parameter entries (id, value) in list order, the 128 CC map entries
0x10000000 + n (the model id CC n drives, -1 none). setState: writePatch (0x0FFFC01D) = 126, the payload's known
parameters in payload order at their storage laws (& 0xFF 45 entries, & 0x7F 6, & 0xFFFF 11, as given 20),
writePatch = 127; a count of 0 queues nothing; the CC map emptied and refilled; entries of 8 bytes when the
stream is longer than (83 + 128) x 64 / 5 = 2700 bytes (83: the CC map's records, READ at 0x322210 --
playbook 207); LFO RATE and VCF CUTOFF also set their host-only floats (byte x 1/255). The push queues, besides
the engine's records, the UI timer's: a mapped CC's value (the last one stays; KEY HOLD's in order) and every
note; the drain sets the store, the keyboard's note value (per key the last velocity, minus a note-off's) and
a waiting MIDI learn's CC. KEY HOLD at 0 -- a setState entry, a patch load (before ARPEGGIO's record: KEY
HOLD's tree node begins with it), a drained CC -- releases the keys the UI timer has seen: a note-off record
per key. MEASURED: jx_state_gate.py, six chains (state paths, stream framing, the CC map, the storage laws,
KEY HOLD, MIDI learn): every save (155) and every queued record equal to the plugin's, on jx3p_product_init's
boot; mutants -- no float link, the limit from the state list (2688), the store unmasked, KEY HOLD releasing
nothing -- each RED (4 of 4).

## 3m. The patch browser: any bank (EXECUTED, 2026-10-10; PORTED, JX-16)

A JX bank file has the JUNO-60's geometry: a 23-byte header ("KoaBankFile00003PG-JX3P"), then records of 20,223
bytes -- a 16-byte name, then the bytes the patch browser's load (0x335730 = the JUNO's 0x335850) reads into the
model, which queues one record per value for the engine. The port had only the factory bank's RECORDED loads;
now it decodes any record as the plugin does: jx3p/src/jx_patch_tables.h (jx_patch_census.py: the plugin's own
load of the 64 factory records and 11 crafted ones -- each byte OR-ed with 0x10 / 0x30 / 0x70 / 0xF0 / 0x80, three
position patterns, three of seeded random bytes; jx_gen_patch_tables.py: the ONE decode per record that
reproduces every load, or it stops). 75 records per load: 45 two-nibble fields, 20 eight-nibble, 8 four-nibble,
2 constants (writePatch = 0 first) -- the bytes OR-ed in 4 bits apart, nothing masked (the JUNO's law). The
JUNO's three position patterns repeat 8,288 bytes apart and fitted LEGATO at two offsets; the random records
made every decode unique (playbook 205). PORTED: jx3p_product_load_record(record) -- the records queued in
order, the store takes each value as decoded, KEY HOLD at 0 releases the drained keys before ARPEGGIO's record
--, jx3p_product_load_patch(i) on the bank init read, jx3p_bank_open(path) for another bank of the format,
jx3p_bank_patches(). MEASURED (jx_patch_gate.py): the 64 factory records, 24 records of random bytes (12 of
nibbles, 12 of whole bytes), keys drained then factory and random loads, a bank file of 5 random records loaded
by index -- every queued record (7,281), every save and every block after each load equal to the plugin's;
tooth: a two-nibble field's high nibble masked -- RED. Through process() (GATE 3d --recall 'rS@T'): random
records loaded with keys held, the audio after the mutes graded.

## 3n. The editor's set: the host's round trip (EXECUTED, 2026-10-10; PORTED, JX-18)

A panel control sets the model (0x283C90 = the JUNO's 0x283DB0). EXECUTED on every record of the CC map at 14
values (jx_model_census.py, 1,162 sets): the model keeps the value at the entry's storage law (getState); then
for 63 of the 82 state entries the plugin queues NO engine record -- it calls the host: beginEdit,
performEdit(id, (float)(stored - min) / (float)(max - min), both operands unsigned 32-bit: 882 of 882 sets
fit), endEdit; the host sends the value back through process() like automation. The other 19 -- the patch
name's 8 words, the two linked floats, the host settings (voices, the rate setting ...) -- and writePatch
(& 0x7F) queue one engine record with the stored value, no host call. jx3p/src/jx_state_tables.h
JX_STATE_EDIT_HOST holds the routing (jx_gen_state_tables.py checks every set against it). PORTED:
jx3p_model_set(id, value), jx3p_host_edits (what the host receives, in order), jx3p_model_commit (the
control's commit: the keyboard's change list). MEASURED (jx_state_gate.py chain 'editor', 38 steps): every
save, queued record and host edit equal to the plugin's -- the round trips through process(), values past the
ranges, a bipolar range, KEY HOLD at 0 with drained keys, the rate setting through the editor; mutant: the
performEdit value as stored / max -- RED (the bipolar entry).

THE EDIT GESTURE (EXECUTED 2026-10-13; PORTED). The census above ran every set FINAL. The model's sets (0x283C90;
the position's, 0x283A60) pass a flag to the multiset (0x283B30) and its listener: 1 final, 0 a step of a drag (a
slider's move). The controller keeps ONE open edit, not one per parameter: a host parameter's set sends beginEdit only
while none is open, then performEdit, and when final endEdit (none open); a step leaves it open. A set no host sees
(the patch name) and a load's performEdits leave it as it is; a final set of ANOTHER parameter after a step ends the
edit without a beginEdit of its own (the plugin's quirk, kept). Found by jx_panel_gate.py's full run (a JX switch
dragged: the plugin beginEdit ... endEdit across the events, the program a triple per step). PORTED:
jx3p_model_set_flag (kinds 2 beginEdit / performEdit, 3 performEdit, 4 performEdit / endEdit), jx3p_model_set =
the final set. MEASURED: jx_state_gate.py chain 'gesture' (29 steps: a final set alone, a drag, steps with no change,
two parameters crossing, a set no host sees and a patch load inside an open edit, round trips in a drag, the plain
set after a step) -- every save, record and host edit EQUAL (85 host edits); mutant JX_GESTURE_TOOTH 1 (one open edit
per parameter) RED.

## 3n2. The loads' host edits and the CC menu's model (EXECUTED, 2026-10-11; PORTED)

A LOAD TELLS THE HOST TOO. setState and the patch browser's load call performEdit -- alone, no beginEdit while
loading -- once per host parameter they set (the 63 of JX_STATE_EDIT_HOST; a patch: all 63, in its records'
order; a setState: the payload's, in payload order), the value by the editor's law on the stored value (past the
ranges too: random-byte records). The JUNO-60's census had it (docs/B6_WRAPPER_BOOT.md: 79 per load); the JX port
had none until 2026-10-11 (playbook 210: the JX-18 comparison was checked on the editor's chain only). PORTED:
jx_edit_push(kind 1) in jx3p_state_load and jx3p_product_load_record; jx3p_host_edits(ids, vals, kinds, cap)
gives the kind (0 the editor's begin / perform / end, 1 a load's perform). MEASURED: jx_state_gate.py, 7 chains,
692 host edits; jx_patch_gate.py, 4 chains, 6,081 host edits (1,512 on random-byte records) -- EQUAL.

THE CC ASSIGN MENU'S MODEL (JX-23): the handler 0x31D300, search 0x31D150, entry 0x3199F0, CC-of 0x319A50,
learn 0x31A920 and forget 0x3191C0 are the JUNO's code (fw_map --pair; docs/CC_MENU.md). PORTED: jx3p_cc_entry
(the record of an id: no record, no menu), jx3p_cc_of (the "#n" of "Forget MIDI CC": -1 when none or while a
learn waits); learn and forget were (JX-17b). MEASURED (jx_state_gate.py): every record's CC-of after every step
of the 7 chains (learns armed, completed by a drain, refused, forgotten; CC maps from setState) EQUAL; the
record index of every id equal to the plugin's CC map order; mutant (the CC shown while a learn waits) RED. The
press's search hit-tests control rectangles whose sizes come from the art's frames: with the drawn panel (row 20).

## 3o. A window's zoom (READ + EXECUTED, 2026-10-11; PORTED, JX-25)

The JUNO-60's rules (docs/WINDOW_ZOOM.md, CLAIMS A40) on the JX's own code: the getter 0x2AA470 and the fit
0x312580 equal the JUNO's 0x2AA590 / 0x312750 (fw_map --pair; the fit's 35 instructions, its common return at
0x3125F1). The JX's windows: main 1924 x 704, patch 1668 x 600 (jx3p/truth/Script.xml, zoomValueRef
vm.vs.mainZoom / vm.vs.patchZoom); the JX editor attaches under the oracle (createView "editor", attached: its
GUI built from the Script.xml, blank images of the real sizes -- no art needed). EXECUTED: the getter's set is
the value object's own (no engine record, no host edit: the editor on an 800 x 600 screen sets mainZoom 62 ->
39 and the engine's queue and the host's edits stay empty); the panel trio's set of a zoom queues one engine
record, as jx3p_model_set does; panelPatch (not in the DAW state) queues nothing. PORTED: jx3p_zoom_fit,
jx3p_zoom_get (one kept fit per window, the app's), jx3p_value_set (the value object's set), jx3p_model_get.
MEASURED (jx_zoom_fit_gate.py, 16 screens from none to 3840 x 2160, portrait, two monitors, screens changing
under a running editor): 278 steps, 3,392 fits, 192 engine records, both zooms after every step -- EQUAL;
teeth (JX_ZF_TOOTH 1-4: the margins swapped, the larger fit, the fits rounded, no fit kept) all bite.

## 3p. The level meters (READ + EXECUTED, 2026-10-11; PORTED, JX-22)

The JX panel has two meters (Script.xml barGraphL / barGraphR: ch 0 / 1, decay 8, fade 10, horizontal) and no
LFO LED (no control reads vm.vs.dm; the engine's vt+104 is 0x34AE20, `ret 0`). THE ENGINE SIDE IS THE JX'S OWN
(READ, the render 0x3F9220): the output gain stage's loop takes, after each sample's gain, the larger magnitude
per channel (andps 0x7FFFFFFF; `comiss peak, x; jae`: the peak becomes x unless peak >= x -- a NaN replaces it
and the next sample replaces the NaN), both from 0; then under the lock at HOST+0x10 the held peaks at
HOST+0x20 / +0x24 become maxss(held, peak) for BOTH channels (the JUNO-60 takes the left one the other way
round: docs/LED_METER.md rule 5); a call of no samples merges peaks 0. The read (the engine's vt+72, 0x34AE30),
the tick (0x31C330: the dB step through the CRT's log10 0x708A70, the decay, the fill 0x2C98F0) and the draw
(0x31C0F0) are the JUNO's code (fw_map --pair: equal; LED_METER.md rules 6, 9-12). PORTED: the peaks in
jx3p_render's gain stage (jx_gain_sample, jx_peak_end: on the HOST's own words, the port's memory being the
plugin's heap), jx3p_peak, jx3p_meter_tick, jx3p_bar_draw; jx3p_gain_tail / jx3p_gain_cells for the gate. On
the way: the fade-in length's float-to-int is now the plugin's cvttss2si (0x80000000 out of range; a C cast is
undefined there). MEASURED (jx_meter_gate.py): part 1 in plain IEEE mode -- 1,200 tails of the render's loop as
a segment of the real engine (NaN payloads, infinities, denormals, signed zeros; held peaks; 15 gain states:
steady, muted, the delay ending inside the call, fading, clamping, an unordered step), 54 reads, 13,052 ticks
(every float next to the 998 dB steps: the margin 6.47e-9, so the C log10 gives the CRT's step), 1,500 draws;
part 2 in the running plugin -- 5 chains (44.1 / 48 / 96 kHz, chords, a clock patch, an effects patch, a warm
patch change, silence), 560 meter reads (356 with a peak) and every sample -- EQUAL; teeth (JX_LM_TOOTH 1-5:
the merge's operands swapped, the peak before the gain, an ordered peak test, the floor 0.0001, the fade one
step early) all bite.

## 3q. The model's record image (EXECUTED, 2026-10-11; PORTED, JX-24)

What the plugin's serializer (rva 0x335870 = the JUNO's 0x335990) writes: the bytes the patch window stores when
it writes a patch. EXECUTED (jx_record_census.py, the booted plugin): at boot a 20,207-byte body (1,160 bytes
nonzero; the same after the first block); a patch load of ANY body -- factory or random bytes -- gives the body
back, every byte; the set of a DAW-state entry that is a leaf of the patch tree writes the leaf in the load's
encoding inverted (INT1X7 the low byte, INT2X4 two nibbles, INT4X4 four, INT8X4 eight, the high one first; LFO RATE
and VCF CUTOFF also their float's leaf); the host settings write nothing -- 738 sets, 1,258 bytes. PORTED: the
image in the bridge (g_prec) from jx3p/src/jx_record_tables.h (JX_DEFAULT_REC, generated by
jx_gen_record_tables.py from the census, with --check), each store set writing its leaf, a record load keeping its
bytes, jx3p_record. MEASURED (jx_record_gate.py): 751 steps -- the boot, 738 sets, 7 loads, 5 setStates -- every
byte EQUAL; teeth (a two-nibble leaf's nibbles swapped; a load keeping the image) bite.

## 3r. The patch window: the plugin's patch manager (READ + EXECUTED, 2026-10-11; PORTED, JX-24)

The JX's patch manager -- the librarian of the patch window: the banks, the list's keys and mouse, the buttons'
functions, the bank name, undo / redo, copy / cut / paste / insert, write / rename / new / delete of patches and
banks, import / export, the number format, the autosave, every file -- is the JUNO-60's code (docs/PATCH_MANAGER.md,
CLAIMS A39): 70 of its 77 functions equal at -0x120 (fw_map), the rest found by their normalized code (the menu
service 0x436540, the number parse 0x419800 ...); its data mapped through the same instruction of the twin
function (the manager 0xC7BB60, the number format 0xC7BB50, the init record 0xCE8700, the menu override
0xCEA428); the list and bank name controls' vtables by their mouse handlers (0x99F958, 0x99FC40). A record body is
the JUNO's size (20,207 bytes), the name at the same place (body 140, 16 nibble pairs); the bank file's product tag
is PG-JX3P. The JX plugin reads Script/Initial.bin (absent: the init record is the view's image at the first
attach), InstalledBankNames.dat, the data, Patch and old folders, as the JUNO.
PORTED: gui/juno_pm.c itself (no copy), built for the JX with -DJPM_PRODUCT="PG-JX3P" and jx3p/gui/jx_pm_glue.c
(the view's calls on the JX bridge: the record image 3q, the patch browser's load, the model's get, the editor's
set, the commit). ORACLE: tools/verify/patch_manager_emu.py takes a profile (jx3p/tools/jx_pm_emu.py: the JX
addresses, the JX host, no art), the JUNO's run unchanged (patch_manager_gate.py seed 1, a fresh 60-command
reference: GREEN). GATE: jx3p/tools/jx_patch_manager_gate.py, the JUNO's gate with the JX's folders, files, factory
bank and list rectangle (Script.xml: 331,35 size 1284,480); the bank name control's presses are left out -- its
button is a frame of the art (row 20) -- and its rename and menu are reached by Ctrl+W / Ctrl+B. MEASURED: seeds 9
(40 commands), 1, 2, 3 (150), 1, 5, 6 (200) and 100 (281: 70 writes, 70 undos, 70 redos, a 64-state history) --
every command's banks, histories, clipboard, selection, number format, autosave count, record image, window values,
dialogs, file operations, files and model calls EQUAL; teeth (the JUNO's PM_TOOTH set): 17 of 19 bite (each on a
seed that reaches it); 18 and 19 are the bank name control's presses.

## 3s. The JUNO-60's gate classes on the JX (2026-10-11, JX-26; docs/GATE_PARITY.tsv)

The parity ledger (every JUNO gate CLASS with its JX twin, tools/verify/gate_parity.py) had not been re-mapped since
August: 18 classes "MISSING" though later gates covered many, five "OK" on files no suite ran, twenty new JUNO gates
in no row. Re-mapped: 55 classes; each owed one closed by an option of a gate that runs:
- jx_lift_gate.py (the lifted parameter and note system, the whole heap): --loads exhaustive (every id of the host
  entry's map, 744, at every value 0..255 and past it, the float ids by 1/256 and the IEEE edges: 252,750 calls, a
  DIGEST after each -- the sha256 of every heap page the call wrote, named by a Unicorn write hook -- EXACTLY 0),
  fxmodes (every effect parameter and type at every value under each value of EFFECT / DELAY / REVERB TYPE),
  notevel (every note x every velocity), random / random2 (48 record sets of random values in each id's declared
  range, wild ones among them), and the warm chain's heap after EVERY patch. Teeth: the call that wrote most dropped.
- jx_product_gate.py through process(): --rerate (a host-rate change on the running instance: setActive(false),
  setupProcessing(rate), setActive(true); PORTED as jx3p_setup_processing / jx3p_set_active -- the JUNO-60's
  juno_gui_set_active: the automatic setting re-reads the engine's rate, the render object is looked up again,
  found: its buffers, the tick phase and the note count start again, then the all-sound-off record), --state
  sID=V (the voice count 4, 8, 3, 2 while notes sound), --vel (the wrapper's velocity rules: 0 a note-off at 64,
  the edges, channels 1 and 10), the JUNO-60's 18 host rates (seven play: the table's 44100 48000 88200 96000 176400 192000
  384000; 11 are silent on both sides: outside the table, and its kind-2 11025 / 22050 -- EXECUTED), and
  every factory patch with TEMPO SYNC (0x60006A) engaged and released under a held note at a host tempo.
- jx_master_bisect.py (every unit and control object per chunk): --script (seeded polyphony, up to 10 keys over six
  voices, the state right after each chunk's events too), --modes (the 19 voice-mode values no factory patch holds,
  Script.xml's ranges, READ), --fxrender (each effect type at each value, every effect parameter at 0 / 128 / 255).
- fuzz_gate.sh (run again; its tooth now a voice helper's slip -- the master tooth it first tried was never reached),
  jx_nan_ab.py (a NaN in live cells: moved ones and READ-only parameters -- the chorus clamp's inputs are
  parameters, never moved: 64 moved cells did not reach it), ramp_walk_gate.sh (now the PRODUCT's sweep and tick,
  jx_bridge.c, not the retired jx_ramp.c), jx_conv_tables.py --check (the rate-setting header),
  jx_provenance.py (jx3p/docs/PROVENANCE.tsv: every file, its role, maker and running proof -- its first run found
  jx3p/src/jx_recall.c, the pool-model recall and its 197 KB table, built into every product and called by
  nothing: taken out of every build), tools/verify/c99_gate.py and approx_audit.py --jx (playbook 213).
BLOCKED on inputs the project does not have: the panel art (row 20) and the user's own JX-3P banks.

## 3t. NaN and denormal parity of the render code (EXECUTED, 2026-10-11; scope row 23)

- THE FLAG RULE (playbook 219). After comiss / ucomiss a NaN sets CF = ZF = PF = 1: "A < B", "A <= B" (and
  "A == B") read TRUE, "A > B", "A >= B" FALSE. Hex-Rays prints the predicate that selects a block as a relation in
  the instruction's operand order; C reads every relation FALSE on NaN. So a decompiled `<` / `<=` in the
  instruction's order, or `>` / `>=` with the operands swapped, takes the other branch on NaN. minss A, B returns
  B when either is NaN (fminf returns the operand that is not NaN); the two agree on every other input, signed
  zeros included (glibc's fminf is minss on ordered inputs: EXECUTED).
- THE MAP. tools/verify/nan_sites.py: the plugin's function under Unicorn with a hook on every comiss / ucomiss /
  minss / maxss / minsd / maxsd / cmp / `test r, r` (recursive descent from the entry; the voice's own copy, rva
  0x3A22C0 -- the wrapper's jump table at 0x3771B4 picks one copy per voice); the C file rewritten into a copy
  whose every relation and fminf / fmaxf / select call logs its operands (types and results kept); both run the same
  scene (a patch or a variant's records, the oracle's FP mode, the warm-up from boot, a key down and up). A site
  and an instruction are one when their operand values agree in order or swapped; ties are broken by the cell an
  operand reads (the memory displacement), by a constant operand (rip-relative data, or a register whose every
  reaching definition is a constant load), by program order, and an inner test that reuses the outer test's flags
  (`if (v >= 0) { if (v > 0) ... }`) takes the outer's instruction. The fixes: `!(A >= B)` / `!(A > B)` for the
  wrong relations, jx_minss / jx_maxss / jx_minsd / jx_maxsd (jx_voice_helpers.h: the compare, then the chosen
  operand's bits) for every min / max -- also those with a constant operand, for the denormal operand the oracle's
  minss hands back unflushed.
- THE FP MODE (playbook 220). Unicorn honours DAZ and never flushes; its minss returns a denormal operand as it is.
  Every JX gate that grades against the oracle runs the port in jx_set_fp_oracle_mode (DAZ on, FTZ off); the
  product and the web page keep FTZ + DAZ (on hardware, under FTZ no operand is denormal, and the select equals
  minss on every other input).
- THE REACH (playbook 221). A site no scene runs is not graded. The master's scenes, besides the 64 patches and the
  54 effect variants: `e:` events (records while a key sounds: a DELAY / REVERB TYPE change arms the delay's clear
  fade, a DELAY TIME change glides its read head), a scene's own length (`@N`: EFFECT TYPE 2 for one second, its 2-
  and 3-step reads), and a `w:` written state (the read head's speed cell +265360 lowered to 0.2 on both sides: its
  measured top speed is 2.23 steps per sample at 44.1 and 96 kHz, so no parameter reaches the 4-step reads). A
  compare of two integer C operands is graded by its types (a rotated loop's `i < 256` has no instruction of its
  own); a site in a branch no build compiles (`#if JX_NAN_TOOTH`) is no site (the preprocessor's output decides).
  The constant rule walks the whole function (xmm12 = 0 is set 2000-2900 instructions before its compares: capped
  at 600, it left lines 2334 and 3634 "for review" -- both WRONG).
- GATE 3i runs the map on both functions (64 patches, the mode / effect variants and the master's reach scenes,
  from boot, key up) -- 0 sites may be wrong, unmatched, conflicting or left for review (a site nobody graded fails
  like a wrong one); every site must run (--all-run, the reach guard) -- and its tooth (the decompiler's form
  planted back at every site written in the machine's). Both new rules were seen to fail: one patch alone leaves 128
  voice sites unrun (REACH, exit 1); without the cell rule lines 1422 / 1501 stay for review (exit 1). Result (job
  nan_mapjx3, then the 12 master fixes re-graded): voice 275 / 275 run and right; master 144 / 144 run, 0 wrong.

## 3u. NaN parity, second pass: equalities, helpers, the compiler, the web engine (EXECUTED, 2026-10-11; row 23)

- EQUALITIES (playbook 222). Every float equality of the plugin is `ucomiss` (four `comiss`) followed by a bare
  je / jne -- no parity test: an unordered pair sets ZF, so the machine's "equal" is TRUE on NaN; C's `==` is FALSE.
  The plugin's JX voice holds 53 such compares, the master 41 (12 of the master's float tests belong to the four
  inline copies of jx_lfo_step, written in the machine's form since 2026-10-10: READ, listed in the census). The map
  now grades `==` / `!=` by the instruction and its flag consumers (a jp / setp / lahf after it would make C right;
  none in either function): voice 53, master 37 WRONG -- rewritten jx_feq / jx_fne (jx_voice_helpers.h,
  `!(a < b) && !(a > b)` / `a < b || a > b`).
- THE HELPERS (playbook 223, tools/verify/nan_helpers.py). Each helper alone at its rva in Unicorn (the oracle's MXCSR
  written into the register: the JX emulator's call() reads it from a field, the JUNO's never) against the port's C
  function, bits in and out (a float -> double conversion would quiet a signalling NaN): quiet / signalling /
  negative NaNs and payloads, infinities, zeros, denormals, the boundaries the helpers test, random values and
  random bit patterns. jx_h_3A2180 (the wrap to [-1, 1)) returned a signalling NaN unquieted -- `comiss x, -1; jae`
  falls into the fmod on NaN; jx_h_3A2010 (the pitch spline) clamped a signalling NaN to 8.9 -- C's fmax gives NaN
  for it, maxsd gives -20; jx_h_3A2210 (the triangle) -- its two wrap tests in the machine's form. tanf, expf, the
  24-bit wrap and the CRT's own fmodf (rva 0x724EE8, statically linked) equal. Teeth: the wrap's `<` back; the
  oracle at the reset MXCSR (no DAZ: the triangle on a denormal differs).
- THE COMPILER (playbook 225, tools/verify/nan_codegen.py). GCC computed `x * 16384` as the negation (xorps) of the
  `x * -16384` it had for the read index -- exact for numbers, a NaN's sign flipped where the plugin's two mulss keep
  it: 12 sites in the master's read heads. -frounding-math -fsignaling-nans keep every operation the C writes; the
  port runs in round to nearest, so no number changes. The gate reads GCC's output (-g: each instruction's C line):
  every sign flip on a line that negates, every negation a flip; its tooth (no flags) finds 12.
- THE WEB ENGINE (playbook 224, tools/verify/wasm_fptoint_check.py). emcc's default feature set converts float ->
  int with trunc_sat: 0 for a NaN, INT_MAX above the range, where x86 (the plugin, the native port) gives INT_MIN.
  The page builds with -mno-nontrapping-fptoint; the check rebuilds the page's engine with names kept and scans every
  function (trunc_sat only in libc's printf), and a probe of NaN / infinity / past-range conversions prints what
  x86 prints; its tooth (the default) shows both. A NaN result's sign and payload in WASM are the WebAssembly
  spec's choice, not graded.
- THE CENSUS. Every float compare / min-max instruction that ran must be graded through a C site: a tie had let
  two sites share one instruction (all candidates of one kind and order: the verdict holds for each) and leave the
  twin ungraded. An equality takes a candidate read by je / jne, a relation one read by jb / ja / jae / jbe; a
  compare of two C integers is graded by its C types first (master line 2619, `*v490 == 1`). Tooth: line 1162 taken
  out of the map, its instruction (ucomiss at rva 0x3A22FD, the cell +270208 it reads) must be reported UNCLAIMED.
- RESULT (job mapfin2): voice 332 / 332 sites run, 0 wrong, census 302 / 302; master 204 / 204 run, 0 wrong,
  census 175 + 12 READ; jx_nan_ab EQUAL (68 cells); nan_helpers EQUAL (8 helpers); nan_codegen clean; the page's
  WASM == native (64 patches, 3 rates) and its conversions x86's. GATE 3i of make verify-jx3p runs all of it.

## 3e. The arpeggiator's step modes (READ + EXECUTED, 2026-10-10)

The note store's step machine is the ARPEGGIATOR -- the JUNO-60 plugin's design (docs/HOST_RENDER_LAYER.md
"The arp controller": the same dispatch ids 831..835 with the same roles). Its step function (+0xD98)
is one of 19 (the mode setter 0x3F1910, jump table 0x3F1A50; above 18, unsigned, mode 12's). Its one
caller is the pattern apply 0x3F4C50 (thunk 0x3F4BB0, called from 0x3F2B00 at 0x3F2B72), which copies
a template (table 0x9FAE50, 6-byte entries 0..5) and a step pattern (0x9FAE80, rows of 0x226 bytes)
into the store and derives the mode:

| input | where it comes from (READ: the host entry's dispatch at 0x3F9B99) |
|---|---|
| ARPEGGIO (X+0) | record 52, id 0x600108, dispatch 831 (0x3F66B0, v != 0); off: the apply is not run |
| ARPEGGIO TYPE, ka+0x18 (0..5) | record 53, id 0x600110, dispatch 832 (0x3F6B10; above 5 ignored) |
| ARPEGGIO STEP, ka+0x1C (0..5) | record 54, id 0x600118, dispatch 833 (0x3F6670; above 5 ignored) |
| SCATTER TYPE, ka+0x20 (0..9) | id 0x600120, dispatch 834 (0x3F6BD0) |
| SCATTER DEPTH, ka+0x24 (-7..7, stored + 7) | id 0x600128, dispatch 835 (0x3F6BA0) |
| +0xDA1 (byte) | nothing writes it but the constructor's 0 |

The template's byte 2 is the base mode: ARPEGGIO TYPE 0..5 (Script.xml: 1OCT UP, 1OCT UP+DOWN, 1OCT
DOWN, 2OCT DOWN, 2OCT UP+DOWN, 2OCT UP) gives 0, 6, 3, 3, 6, 0. The SCATTER table at 0xA0F0D0 (10
types x 10 fields x 15 depths of int32; fields 0..6 go to parameters 0x138..0x13E of the object at
ka+0x10, field 7 to 0x3F51B0, field 9 to 0x3F5180) gives in field 8 the mode modifier: 1 (type 8,
every depth) makes the base 0 / 3 / 6 into 2 / 5 / 8 (templates 0 and 5 / 2 and 3 / 1 and 4); 3 (type
9, depths -5..+5) makes every base 10; 2 would make 11 but no entry holds it. With +0xDA1 set the
mode would be 15..18 from +0xFE4 -- and the step clock would play through 0x3F2120 instead of
0x3F1EA0 -- but no instruction stores to +0xDA1 (READ: every displacement-0xDA1 operand in the image is
a compare), it is 0 after the boot, and nothing wrote it through the 64 factory patch loads and every
one of the host entry's 744 ids set to 0, 1, 2, 3, 5, 9 and 127 (EXECUTED, a write hook on all nine
stores).

NO PRODUCT PATH SENDS SCATTER, as in the JUNO-60 plugin (EXECUTED: not in any factory patch's 75
records, not in initialize's 84, not among the 210 entries of the plugin's own getState; READ: none of
the 303 editor widgets of Script.xml binds SCATTER TYPE / DEPTH, where ARPEGGIO, TYPE and STEP each
have one; a host parameter change with the model id reaches nothing -- but so does ARPEGGIO TYPE's,
so that probe proves nothing). SCATTER stays at the build's (0, 7): field 8 = 0. So the PRODUCT
reaches modes 0, 3 and 6 -- every one in the factory bank (ARPEGGIO = 1 only on patches 34 and 61,
the two that play on the clock); the engine's own host entry reaches 2, 5, 8 and 10 more.

Graded (`jx3p/tools/jx_tick_gate.py`, every control object after every event, every unit's state at
checkpoints): the factory patches 34, 61, 0, 38, 20; variants of the plugin's own patch load --
ARPEGGIO / TYPE / STEP changed (product states, modes 0, 3, 6), SCATTER appended (the engine's entry,
modes 2, 5, 8, 10); and every one of the 19 modes put into every store by the plugin's own setter after
patch 34's load (the port: its transcription), the 12 no input reaches included.

## 3v. The oracle graded by the real CPU (EXECUTED, 2026-10-11; rows 23, 24; playbooks 226, 227, 228)

- THE NATIVE REPLAY (jx3p/tools/jx_native_replay.py, tools/verify/native_replay.c). The oracle builds the scene --
  the plugin's product boot at 44.1 kHz, its own patch load, a note-on 60 / 105, NaNs if asked -- and its memory
  goes out region by region (the image as it stands, the used heap, the stubs and their parameter blocks, the
  buffers, the low page from 0x10000); a native process maps each region at its own address (every pointer inside
  stays valid) and runs JX.render()'s loop: the plugin's own voice and master render through the stubs, on this
  CPU. Batch mode restores the snapshot before each scene. No NaN: Unicorn == the CPU, every output sample and every
  unit's window (jx_master_bisect.clean); the port == the CPU at MXCSR 0x1FC0 (the gates' mode, jx_set_fp_oracle_mode)
  and at 0x9FC0 (FTZ + DAZ: the plugin in a host; the port's jx_enable_hw_ftz). The sweep: every live cell's NaN
  alone (--all: 1416 scenes), three NaNs each -- equal, both modes; 6 reach (the JX's cells are rewritten before they
  are read, so the decisions stay graded site by site by nan_sites.py). Tooth: the port with JX_NAN_TOOTH must
  differ from the CPU (the chorus clamp's inputs).
- THE CRT's FMA3 CODE (tools/verify/crt_fma_gate.py). The CRT init (rva 0x74A920, an _initterm entry) sets
  0xCEFC0C on FMA + AVX + OSXSAVE with the YMM state saved; 12 math functions test it. The port reaches four: expf
  (0x722EA0: differs at ONE input of 2^32, -68.5303421; the voice passes v * 5.2834215 with v in [0, 1]), tanf
  (0x725150: never), sin / cos (0x7247F0: only |x| >= 2^23; the parameter system passes 3522 / n), log10 (0x708A70:
  7 meter inputs by 2.2e-16, under the meter's 1e-12 margin). Unicorn reports no FMA and cannot decode VEX: these
  runs are native, the image mapped at its base, the functions called through ms_abi. Tooth: the flag address moved
  4 bytes loses expf's difference.
- EVERY CPU QUESTION (tools/verify/cpu_census.py, playbook 228). Seven JX functions hold cpuid / xgetbv (two that
  fill JUCE's CPU info, the CRT's __isa_available_init and FMA3 init, three that keep no answer) and OpenSSL's
  OPENSSL_ia32_cpuid; of every reader of their answers the port reaches: the render driver (rva 0x320A00: its four
  ISA tests sit behind `cmp r13d, 8`, reached 0 times with 2 channels while its loads run every block), the CRT's
  memmove (0x6E4010), memset (0x6E5870) and strrchr (0x6E6BAC; its one reached call passes 'e') -- run in Unicorn on
  both paths, equal results, the code run differs --, its strnlen / wcslen / wcsnlen (0x72B2B0, 0x72B400, 0x72B52C:
  leaf functions with no .pdata entry, an AVX2 path for __isa_available >= 5) run NATIVELY on both paths (an int3 on
  the AVX2 path fires under this CPU's answer only; 3000 random strings, equal lengths), and the four FMA3 math
  functions above. The answers: static (the engine oracle jx_emu skips DllMain: 1, 0, 8239),
  Unicorn (JXHost runs DllMain: 2, 2, no limit), this CPU (5, 2, no limit). The census also found false roots: the
  lifted code's comments carry memory-operand displacements (`[rip + 0x79fb9d]` fell in JUCE's CPU-info getter);
  a bracketed operand names no function. Nor does a number in hand-written code that starts no function (playbook
  258: JX-3P.exe's MIDI word 0x6401B0 fell in a function that reaches the CRT's wcsstr, whose SSE2 and SSE4.2 paths
  differ -- no port code reaches it). And the census reads every source the JX's products compile: the shared
  gui/juno_pm.c, src/juno_conv.c cite the JUNO-60's addresses, taken as their JX twins (fw_map's equal code, the
  table JX_TWINS, `--twins` makes it again; 11 twins had been outside the reach). Teeth: the answers written off
  their globals (no path moves: refused); displacements taken as names (ungraded readers: the census fails); data
  words taken as names (wcsstr back: the census fails); one twin taken out (refused). And the FP mode: Unicorn starts at MXCSR 0
  and JXHost never set it, so process() ran with every exception unmasked (the plugin's ScopedNoDenormals, rva
  0x34AC18, made 0x8040, not a host's 0x9FC0); jx_emu now starts at 0x1F80 as a Windows thread does, and the census
  checks the switch loads 0x9FC0 (its --tooth-mxcsr: entry 0 is seen). The JUNO's 21 process() chains gave the
  same 594,372 samples either way.
- ROW 24. Two DIFFERENT NaNs meeting in one add / multiply keep the compiler's operand order: the ISO C99 limit
  (exact only if every such operation tests its operands), the user's decision.

## 4. Next

1. DONE (JX-8, 3i). The host tempo (READ, 2026-10-10; AUDIBLE: patches 33, 40, 43, 44, 48 and 54 of the factory bank (6 of
   64) render differently with T = 1200 than without -- a census of the plugin's engine, 24,000 samples a
   patch, every patch): the render driver computes T = round(tempo x 10) from the
   ProcessContext and, when the host's tempo is valid and T changed, calls the engine's vt+0xB0
   (0x3F9DD0): for T in 400..3000 every unit's dispatch 375 (0x177) = T -- the parameter object's
   vt+0x650 (0x3EB7E0): 0x3E12D0, then by the effect type [obj+0x5B8] (0..5) the effect object's tempo
   setter (+0x3270 / +0x3330: vt+0xA8, +0x3400 / +0x34D8 / +0x35B0: vt+0xC0, +0x3680: vt+0x138),
   [obj+0x440] = T, vt+0x8B0. Every DAW gives a tempo, so this runs at the first block of every DAW
   session; the port's driver has the fixed 120 and no tempo entry (vt+0xD0 / +0xF0, the transport,
   are `ret 0`). Port it and grade it through process() with a ProcessContext.
2. DONE (JX-10, S3_STATUS (5)): the web page plays the product path (96 kHz data, the render object,
   the render driver); WASM == native on its calls at three rates, the page checked in headless Chromium.
3. A patch change on a running engine (warm recall, SCOPE_AUDIT row 9) and host edits beyond a patch
   load (row 12) -- both are the engine's host entry (0x3F9A30) and the units' parameter dispatch
   (0x3EBB00) on a RUNNING engine. MEASURED 2026-10-10 (scratchpad census, patch 5's 75 records onto a
   running patch 0): 705,648 instructions executed, 7,102 distinct, 232 functions; per record 50-200 new
   instructions, record 67 (the master effect mode, dispatch 875) 1,185 new in 56 functions; writes
   into every unit's low state, its high window, the master state and the whole parameter object
   (0x26000 bytes from state + 0xAAC320: the ramp records live there); NO allocation and NO import
   call through 6 warm loads over effect modes 0, 1, 2, 5 -- pure code over existing memory.
   LIFTED AND EXACT AT THE ENGINE (2026-10-10, JX-11): `jx3p/tools/jx_lift.py` runs the JP8's lifter
   (jp8/tools/jp8_lift.py, unchanged: one C statement per instruction) on the JX binary from the host
   entry 0x3F9A30 and the oracle's dynamic reach (`jx_dynreach.py`: warm loads of all 64 patches and the
   sweep of every id from patches 0 and 34, loads from 61 and 40): 472 functions, 26,432 instructions,
   96 trap sites none of the runs reaches (AVX/FMA math variants, padding). `jx_lift_gate.py` (process A
   the oracle, process B the lifted C twin under jp8_rt.c with JP8_RELOC -- guest addresses kept, every
   access translated and bounds-checked): the engine running (a patch, a key held, 2048 samples), the
   same calls through both, every return value and the WHOLE HEAP (98 MB) compared. MEASURED EXACTLY 0:
   warm loads of 5, 34, 40, 62 onto patch 0 (300 calls); of 0, 61, 50 onto the arpeggiator patch 34
   (225); every one of the host entry's 744 ids at 13 values (0..1000 and -1), a heap checkpoint after
   each id (65,472 calls). Tooth: one mulss of the LFO-rate listener made a divss (0x35D29F) -- 72 words
   differ, the 8 rate cells of each of the 9 units. A reach from patch 0 alone missed the arpeggiator's
   switch-off: the gate trapped there ("indirect target 0x3e0210 not lifted") -- a gap is a trap, never a
   silent difference. IN THE PRODUCT (2026-10-10, S3_STATUS (7)): the port's memory is the plugin's heap
   (jx_bridge.c: one block at the guest addresses, from jx_guest_export.py's image of the heap after the
   boot); jx3p_recall runs a patch's records through the lifted entry on the running engine (WARM),
   jx3p_param one host edit, the render driver takes parameter records (type 2) in a block's event list.
   The lift's roots: the host entry, the oracle's reach (jx3p/gen/jx_lift_reach.json) and the
   slot-family closure over the classes live in the heap plus the control classes in full
   (jx_lift_roots.py); the image pages it reads: a dynamic census and a static scan (jx_guest_export.py
   image_pages). Graded: GATE 3d --recall (warm changes, a key held, through the plugin's process()),
   GATE 3e --loads modes / settings.
4. The rest of the JUNO's host layer on the JX engine: the state, other rates (done: 3j-3n). The editor's
   own logic: the window zoom (3o), the meters (3p), the CC menu's model (3n2), the record image (3q) and the
   patch window (3r) done. The drawn panel waits for the JX art (row 20): with it, the CC menu's search, the
   bank name control's presses and the apps' panel.
