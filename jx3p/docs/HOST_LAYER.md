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

## 4. Next

1. The host tempo (READ, 2026-10-10; AUDIBLE: patches 33, 40, 43, 44, 48 and 54 of the factory bank (6 of
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
4. The rest of the JUNO's host layer on the JX engine: the state, the patch manager, other rates.
