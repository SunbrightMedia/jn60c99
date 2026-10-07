# B6 -- the plugin booted as a host boots it (2026-10-06)

LIVING. Answers: what does the plugin's OWN preset load hand the engine, and how
is it executed? Tool: `probes/b6/wrapper_emu.py` (plumbing over `e2e_emu`),
censuses `probes/b6/state_load_census.py`, `state_mask_census.py`,
`patch_load_census.py`; gate `tools/verify/state_load_gate.py` (CLAIMS A22).

## The wall that fell (P112 section 7)

The 2026-07 wall ("CRT abort in a magic-static string parse, then a fault at
rva 0x284c04") had one root cause: the emulator gave the plugin no TEB/TLS.
Every MSVC magic static checks `guard > *(TLS[TlsIndex] + 24)`; with gs base 0
the epoch read 0 and every static looked constructed, so empty objects were
used. A real TEB with the PE's TLS template (epoch INT_MIN at +24) fixes it.
The host boot then needs only operating-system plumbing, each item MEASURED:

| step | what the plugin needed |
|---|---|
| DllMain (CRT + 844 C++ initializers) | OS version (ConcRT throws `unsupported_os` otherwise), system info, `InitOnceExecuteOnce` that runs its callback, `GetProcAddress` -> named stubs |
| InitDll (module init) | `InitCommonControlsEx`, folder paths, `GetFullPathName`, string conversions, Shell folder listing (IShellFolder / IEnumIDList / IMalloc with well-formed pidls), `Script.xml` in `<module dir>\Script\` (truth/Script.xml), `TextCodeTable.dat` (GUI strings, not supplied: served empty) |
| IComponent::initialize | GDI+ and DIB sections for the GUI skin (blank images, each state as large as its control, slider knobs smaller: Script.xml geometry) |
| controller + connection | IHostApplication::createInstance for IMessage / IAttributeList, IConnectionPoint both ways, an IComponentHandler |

None of it is plugin logic; the skin images and the text table never reach the
engine. initialize returns kResultOk; getState / setState run the plugin's code.

## What a state load does (EXECUTED)

* `IComponent::setState` (rva 0x34AAA0) -> deserializer (rva 0x321F20) sets the
  model value of every entry of the payload, inside a begin/end marker (126/127)
  that raises the core's "loading" flag (core+584, rva 0x321B30).
* The core's model listener (rva 0x347050) queues, for EVERY entry, a kind-2
  engine event (parameter id, raw model value) -- 95 events, in the payload
  order, which is the plugin's parameter-list order (getState writes the list in
  order; the list is the static name table at rva 0x3DD990, READ). Measured: all
  95 are queued even when no value changed.
* For the 79 host-exported parameters it also calls the edit controller's
  performEdit (no beginEdit while loading), which reaches the host's
  IComponentHandler: 79 performEdit calls per load.
* The render driver (rva 0x320B20) applies queued events in queue order at their
  sample offsets (all 0 here) through the engine's host entry (rva 0x3C7AE0,
  flag 0). The "sort" the P112 notes mention is a vector insert of the previous
  block's carry-over (rva 0x31E7E0), not a reorder.
* initialize itself queues the 95 defaults the same way; the first process()
  applies them.

## The voice count (NEW, READ + EXECUTED)

The 95 include `vm.vs.voiceCount` (id 0x0FFFC00E, default 6). The host entry's
special case stores it at engine+0x38; the engine render (rva 0x3C7400) then, per
voice unit u = 0..7, sets assigner[u]'s voice count to it when it differs (vt[16],
rva 0x355940) and renders only units u < count (the others' outputs are zeroed,
their workers not signalled). So the plugin as shipped plays SIX voices. The
`e2e_emu` harness builds on a zero HOST (engine+0x38 = 0, assigners at 8) and
renders all eight units: it omitted this preamble. Now run by the harness and the port, gated: CLAIMS A21, tools/verify/voice_count_gate.py (25/25).

## Census (probes/b6/state_load_census.py, EXECUTED 2026-10-06)

| payload | engine events | order | values | handler calls |
|---|---|---|---|---|
| the plugin's own getState | 95 kind 2, offset 0 | = payload (list) order | = payload | 79 performEdit |
| every value + 1 | 95 | = payload | = payload & storage width (256 -> 0 for 8-bit leaves: VCF CUTOFF, ENV1/ENV2 SUSTAIN, DELAY/REVERB DIRECT LEVEL) | 79 |
| one value changed | 95 (all, not only the changed one) | = payload | = payload | 79 |
| the 95 entries reversed | 95 | REVERSED (follows the payload) | = payload | 79 |

So the engine order is the payload order. A DAW saves the payload with getState,
which writes the list order; so a DAW preset recall reaches the engine as 95 host
edits in list order at one sample (plus whatever the host does with the 79
performEdits: VST3 hosts forward them as parameter changes, host-dependent).
performEdit values are normalized (LFO RATE 145 -> 145/255).

## The plugin's own patch load (EXECUTED, probes/b6/patch_load_census.py)

The patch browser's "load" (ManagePatch handler rva 0x322E60 -> patch manager
rva 0x338090 -> rva 0x335850) sets every leaf of the patch tree from the record
bytes, depth first, each value at its running offset; the core queues one engine
event per value of the parameter list, exactly as setState does (the markers
2*slot / 2*slot+1 raise the same loading flag). All 64 factory records:

* 87 kind-2 events at offset 0, ONE order for every record (the tree order):
  MASTER TUNE first (the record carries SYS_COM after its 16-byte name: Local
  SW, Master Tune (SYSTEM-1), MASTER TUNE = 01 0a 06 04), the panel values, the
  8 name words, NAME1..3, then PATCH2 (the H floats as 8 nibbles, the DLY leaves
  in Script.xml order, not list order).
* Leaves outside the parameter list (the LFO / OSC waves, the scatter leaves,
  TEMPO, ...) are set in the model and never reach the engine.
* The model's own serialization (rva 0x335990) reproduces every record after
  its name, 64/64: a record IS the serialized patch tree.
* The decode is the model's set-from-bytes: int1x7 = the byte, int2x4 =
  (b0 << 4) | b1, int8x4 / int4x4 = the bytes OR-ed shifted -- nothing masked
  (crafted records). setState instead stores value & mask (8, 7 or 16 bits, or
  the value: state_mask_census.py).
* Each event is a host edit, so a patch change in the plugin is NOT the recall
  the gates A17-A19 model (flag 1): it ramps through the host-role programs (A20).

Generated for the port: src/juno_state_tables.h (tools/verify/gen_state_tables.py:
every record offset and decode derived from 72 records, the one candidate that
fits); port: juno_gui_plugin_init / juno_gui_state_load / juno_gui_load_patch;
gate: tools/verify/state_load_gate.py.

## Found on the way (each a port defect, fixed)

| defect | the plugin (READ + EXECUTED) |
|---|---|
| no start-up mute | the engine's construction sets every unit's skip counter to 960 (rva 0x398EA0); a unit under it outputs zero and runs no DSP, only its ramp pump (rva 0x398F30 / 0x398EC0); a unit the voice count stops keeps it |
| fine cutoff "last value" | VCF CUTOFF FREQ H stores (int)(H * 255.0f) as the cutoff object's last value (rva 0x359890), from which the next step's glide time is measured; the port kept the float's bits |
| arp refresh glide time | the arp switch re-sends the stored cutoff through the cutoff setter (leaf 312, rva 0x3B9990 -> 0x3597F0): its time follows the step from the last value and the byte becomes the last value; the census only saw step 0 |
| ARPEGGIO SW out of range | the host entry calls the arp switch with (v != 0) directly (rva 0x3C7AE0, dispatch 831), no range check |
| MASTER TUNE record offset | 18, not 20 (juno_hostparams.c) |
| oracle FP mode | a chain that never recalls must still set the plugin's FTZ|DAZ (e2e_emu set_ftz): playbook 120 |
| arp switch with keys held | ON releases each pressed key's note and hands the key to the arp; OFF plays the arp's keys again as notes, order and velocity set by the key-trig flag (rva 0x3C49F0, 0x3C42D0); the port flushed everything |
| LFO KEY TRIG wild value | sets the keyboard's key-trig byte before the range check and sticks once above 2 (rva 0x3C4ED0) |
| the app's warm-up | juno_gui_warmup lacked the render's preamble (the voice-count sync): after initialize's six, the first key landed on a stopped unit (state_load_gate app family; playbook 138) |
| the velocity switch | the wrapper's switch byte (core+572) is vm.vs.velSense, default 1, set at initialize (rva 0x320420) and moved by no host call; the port forced 100 (CLAIMS A23, probes/b6/kbd_vel_default.py) |
| vm.vs.quality | in Script.xml, bound by no code: no name string for it in the binary (READ; the same search finds velSense and voiceCount, which are bound) -- a UI value with no effect on the sound |
