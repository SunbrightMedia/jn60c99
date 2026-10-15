# The editor's set: the host's round trip (CLAIMS A42)

What a panel control's value does in the JUNO-60 plugin, and how the port does the same.
The JX-3P's twin: jx3p/docs/HOST_LAYER.md 3n (its code is this code, `fw_map.py --pair 0x283DB0 0x283C90`).

## 1. The rule (EXECUTED, 2026-10-15)

A panel control sets the model: rva 0x283DB0 (`model, value object, value, flag`; flag 1 a final
set, 0 a step of a drag). `tools/verify/juno_model_census.py` runs it on every record of the core's
CC map (95 records, ids by rva 0x319C50) at 14 values each (0, 1, 2, 5, 127, 128, 255, 256, 300,
65535, 65536, -1, 2^31 - 1, -2^31), final, the plugin booted as a host boots it: 1330 sets.

1. The model keeps the value at its storage law (getState: `value & mask`; LFO RATE and VCF
   CUTOFF set their host-only floats too). KEY HOLD at 0 releases the held keys at once.
2. For **79** entries -- the parameters a host automates -- the plugin queues **no engine
   record**. Its controller calls the host: `beginEdit`, `performEdit(id, v)`, `endEdit`, where
   `v = (float)(uint32)(stored - min) / (float)(uint32)(max - min)` (the range of the plugin's
   MIDI table; 1106 of 1106 sets fit). The engine gets the value only when the host sends it back
   through `process()`, as automation.
3. For the other **16** -- the patch name's 8 words (0x00600080..0x0060009C) and 8 settings
   (0x0FFFC000, 03, 08, 0E, 10, 14, 15, 16: the voice count, the engine-rate setting, the view
   values) -- one kind-2 engine record (id, stored value) for the next block, no host call
   (224 of 224 sets). The engine-rate setting's listener also runs at once (rva 0x3222F0).
4. A load -- the patch browser (rva 0x335850), setState -- tells the host each host parameter's
   new value: `performEdit` alone, beside its engine records.

THE EDIT GESTURE (EXECUTED by `editor_gate.py` chain `gesture`): the controller keeps ONE open
edit, not one per parameter. A host parameter's set sends `beginEdit` only while none is open,
then `performEdit`, and when final `endEdit`; a step leaves the edit open; a set no host sees and a
load's `performEdit` leave it as it is.

## 2. The port

- `src/juno_state_tables.h` `JUNO_STATE_EDIT_HOST[95]`: the routing, generated from the census
  (`tools/verify/gen_state_tables.py` checks every one of the 1330 sets against it;
  `tools/repro/regen_check.py` rebuilds it from the plugin).
- `gui/juno_bridge.c`: `juno_gui_model_set_flag(c, id, v, final)` -- the editor's set;
  `juno_gui_host_edits(c, ids, vals, kinds, cap)` -- the host calls since the last call (kinds:
  0 begin / perform / end, 1 a load's perform, 2 begin / perform, 3 perform, 4 perform / end);
  `juno_gui_queue_records` -- the records waiting for the next block. `juno_gui_model_set` stays
  the record model (every entry a record) for the gates that grade the model's store alone.
- The apps are the host. JUNO-60.exe (`gui/win/juno60_win.c` `collect_edits`) and the web page
  (`gui/skin/engine.js` `collectEdits` / `sendEdits`) take every `performEdit` since the last
  block and send it into the next block as a parameter point: one per parameter, in the order
  first seen, its last value (a VST3 host's queue; `process()` takes a queue's last point), before
  the MIDI mapping's points.

## 3. The proof

`tools/verify/editor_gate.py` (make verify, section THE EDITOR'S SET). Three chains built from the
plugin's own record list, each on a fresh boot, plugin (Unicorn) vs port (libjuno), two processes:

| chain | steps |
|---|---|
| census | every record at the 14 values, final; a block after each record |
| gesture | a key held; two host parameters' drags crossing, a record entry and a patch load inside an open edit, round trips inside a drag, a plain set after a step, the commit |
| roundtrip | a key held; every host parameter at 2 seeded values, each sent back through `process()` |

Compared after every step: the host calls, the records pending for the next block, getState's
bytes, and after a block both channels' samples bit for bit (the round trip through the engine).
Teeth (`--mutants`, builds with `-DJUNO_EDSET_TOOTH=n`): 1 `performEdit`'s value stored / max,
2 every entry a record (the old model), 3 one open edit per parameter, 4 the engine-rate setting
switched at each set (section 4) -- each must FAIL.

The apps: `tools/dist/native_check.py` replays JUNO-60.exe's log through libjuno and requires every
`# hostedit` line equal to the build's and every block's parameter points = the round trip, then the
MIDI mapping (tooth `rt`: a point lost); `exe_oracle_check.py` plays the same points into the
plugin itself; `tools/verify/skin_kb_check.mjs` holds the page's host edits equal to the exe's.

## 4. Found on the way: the engine-rate setting switches at the next block

The audio comparison found a port defect outside the routing: the engine-rate setting's set
(`juno_gui_set_engine_rate_setting`) switched the engine at once, at every set that asked another
rate. The plugin's listener (rva 0x321B30 -> 0x3222F0) only stores the request; the render
driver's next block (rva 0x320BA2) switches once, to the last request -- as CLAIMS A30 states.
Fourteen sets inside one block (the census chain) re-initialized the port's engine 13 times and
the plugin's not once. Fixed: the set stores the request, `drv_block` switches. Tooth 4 (the old
switch) must FAIL; the nine gates that drive the setting (rate switch, boot, MIDI controllers,
state save / load, host rate, host process, KEY HOLD, CC map) are GREEN on the fix
(METHOD_PLAYBOOK 275).

## 5. Scope

- The page applies a MIDI CC at once (`juno_gui_host_param`) and the round trip's points at the
  next block; the exe sends both in the next block, the round trip first. They differ only when a
  CC and a panel edit reach the same engine value inside one block.
- A drag's steps (flag 0) are graded on the bridge (chain `gesture`); the JUNO-60.exe controls send
  final sets (the generic classes' drags: task row 25c, the JX's twin in jx3p/docs/JX_PANEL.md).
