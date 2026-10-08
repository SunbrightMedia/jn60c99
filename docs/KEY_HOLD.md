# KEY_HOLD.md -- the keyboard's note value, KEY HOLD, and the panel keyboard (CLAIMS A36)

Found 2026-10-08 by the .exe's seeded check against the plugin (gui/win, seed 4): after a patch
change the plugin freed five voices the port kept. Every gate before graded chains with no UI-timer
drain, so the state this page is about stayed empty in all of them (playbook 163).

## What the plugin does

| # | Rule | Label | Where |
|---|---|---|---|
| 1 | One model value holds the panel keyboard's keys: `ms.ch[vm.ks.ch].note` (the model ring's slot 6; `vm.ks.ch` default 0), a state per key: a note-on's velocity, minus a note-off's velocity, 0 never / released | EXECUTED | probes below; rva 0x2A05C0 |
| 2 | The wrapper's push (rva 0x31F4E0) puts every MIDI message -- after the velocity switch's rule -- into the UI timer's queue (core+512) as well as the engine's; events first, then parameters (a mapped CC's store record before its own message). The queue appends every record (rva 0x3221F0): none is merged | EXECUTED | `hold_drain.py`, keyhold_gate chain `learn` |
| 3 | The UI timer's drain (rva 0x320120 -> 0x29FF40) applies the queue in order: each note straight into the states, ANY channel into channel 0's (on -> v, off -> -v; no engine record); each store record with its own value | EXECUTED | `notes_probe.py`, `hold_drain.py` |
| 4 | The core's model handler (rva 0x31C820), for a set of model values that holds KEY HOLD (`fm.PATCH.NAME1.KEY HOLD`, id 0x00600138) reading 0 -- changed or not -- first releases every key above 0: key order, each to 0, each an entry of the note value's change list, and runs the core's listener (rva 0x321B30) for the note value: one note-off per entry, velocity 0 through the switch's rule (switch off: 64), offset 0, BEFORE that set's own records | EXECUTED | `kb_trace.py`, `notes_who.py`, `slot4_probe.py`, `hold_paths.py` |
| 5 | Such sets: a patch load (the node holding KEY HOLD begins with ARPEGGIO SW, id 0x00600108: the release lands between the records of 0x0060009C and 0x00600108); each setState entry (the release just before KEY HOLD's record); the GUI's model set (rva 0x283DB0) of KEY HOLD at 0, even 0 -> 0; each drained store record of a CC learned to KEY HOLD, at its place in the drain's queue (notes queued after it come later) | EXECUTED | `hold_paths.py`, `hold_drain.py` |
| 6 | All 64 factory patches hold KEY HOLD = 0: every patch change releases the keys the UI timer has seen | READ (bytes) | factory bank, offset 340 |
| 7 | The change list: the listener queues ALL of it each time it runs for the note value; the model's commit (rva 0x283120, after the dispatch rva 0x2853C0) empties it. A release adds its entries inside a handler and nothing commits them there: a patch load leaves them (and 4208 values pending), so do the bare model set and a second load (whose release sends them again); the next keyboard write sends them again, then commits; a drain's end, setState and a panel control's commit empty them | EXECUTED | `stale_probe.py`, `clear_probe.py` |
| 8 | Panel controls commit after their set (rva 0x2DD100, 0x2DEAD0: set, 0x285320, 0x2853C0, 0x283120); the ManagePatch command handler commits after its load (rva 0x322E60); the patch list control commits only when its view value #0 is not already 1 (rva 0x3278C0) | READ | decomp |
| 9 | The panel keyboard's send (rva 0x2D47E0): a press writes (key, vm.ks.onVel if set, else the click velocity), a release (key, -vm.ks.offVel); Script.xml: onVel 0, offVel 64 (1..127). The write is a change only (rva 0x2A05C0) but the listener and the commit always run | EXECUTED (the write) / READ (the control) | `stale_probe.py`, `clear_probe.py`; keyhold_gate chain `keybed` |
| 10 | The panel keyboard control: keys keyRange low..high (the parser keeps high + 1); white keys one width / their count apart; first key chromaticRect 12, last 13; a black key at the previous key's right edge + chromaticOffset - its width / 2 (rva 0x2D45E0). The hit test clamps the point into the control and walks from the lowest key (a black key overlapping the key's right edge first; a gap belongs to the next key); velocity 1016 x (y - top) / height / 7 in 1..127 (rva 0x2D4AA0). Down (and double click) / drag: the hit key + 12 x OCTAVE SHIFT, if it is not the held key: unless KEY HOLD is on and Shift is down, every key above 0 is released first; then the press (rva 0x2D4920). Up: the held key released unless KEY HOLD (rva 0x2D48A0). Drawn: key i down when state[i + 12 x OCTAVE SHIFT] > 0 (rva 0x2D3E20) | READ | decomp |
| 11 | NOT such a set: the host's own parameter KEY HOLD through process() (id 0x00600138 in a parameter queue), 0 or 1, before or after a drain -- no release, the states stay | EXECUTED | keyhold_gate chain `host` |

The probes named above are scratch work of 2026-10-08 (not kept); every rule marked EXECUTED is
graded by `tools/verify/keyhold_gate.py`, which runs the plugin itself.

## The port (gui/juno_bridge.c)

- `ks_note[128]`: rule 1.
- The UI timer's queue as the drain applies it (rules 2, 3, 5). Only KEY HOLD's records read the
  notes (its release), so the port keeps: the notes queued before the first KEY HOLD record
  (`ks_pend`, the last per key), then each KEY HOLD record's value with the notes queued after it
  (`ks_kh`, `ks_wkey` / `ks_wval`, the last per key in each part). Every other store record keeps
  only its last value (`ui_q`): nothing reads the ones between.
- `ks_release` (rule 4): at the patch load's ARPEGGIO SW event, each setState entry, the GUI's
  model set, each drained KEY HOLD record at 0. Not in the host's parameter path (rule 11).
- The change list `ks_lkey` / `ks_lval` with `ks_listen` / `ks_commit` (rule 7): the drain's end
  and setState commit; `juno_gui_commit` is a panel control's commit; a patch load and
  `juno_gui_model_set` do not commit.
- `juno_gui_keybed_write` (rule 9: a change appends, the list is queued, then committed),
  `juno_gui_keybed_state` (what the keyboard draws), `juno_gui_queue_peek` (inspection, for the
  gates).
- Bounds: 64 KEY HOLD records and 1024 note writes per drain, 1024 change-list entries; past
  them the context reports an unported path (`juno_gui_unported`), never a silent difference.
- Rule 10 is the app's job: the port gives the operations (write, state, commit) that the
  plugin's keyboard control makes.

## Graded

`tools/verify/keyhold_gate.py` (in `make verify`): 10 chains at the product boot, host 48000 --
the seed-4 scenario; loads with keys drained / not drained / an arp patch / a record crafted with
KEY HOLD = 1; setState with KEY HOLD 0, 1, 5, absent; model sets 0 -> 0, 0 -> 1, 1 -> 0, with and
without a commit; a learned CC with notes before and after its record, and several KEY HOLD
records before one drain; keyboard writes (press, no change, a key held by MIDI at the same and
another velocity, releases), the velocity switch off (the UI's velSense set in the model: the
switch byte EXECUTED); the change list (load -> keyboard write, load -> drain -> write, load ->
load, model set alone, with commit, setState); host notes on channels 0, 5, 9, 15, note-on at 0;
the host's KEY HOLD through process(). Every sample, the 128 states and the engine's input queue
at every check. Teeth (-DKS_TOOTH=n), each seen to fail: no release; the drain's notes not kept;
the drain's release at its end; a load's release after its records (seen only in the queue); a
release's entries never sent again; no commit; no change test; the host's KEY HOLD releasing.

## Limits (stated)

- `vm.ks.ch` stays 0, `vm.ks.onVel` / `offVel` at their defaults: no panel of this port changes
  them (the plugin's keyboard channel setting would move the note value to another channel's).
- A GUI model set of a parameter the engine uses reaches the plugin's engine through the host
  (performEdit -> process()); the oracle has no such host, so the gate sets only KEY HOLD and
  OCTAVE SHIFT (no engine cell, EXECUTED) from the panel.
- Rule 8 and rule 10 are READ: the GUI framework is not executed (no window in the emulator).
  The .exe check (CLAIMS C6) grades the port against the plugin on the operations the GUI
  makes, not the mapping from a mouse event to those operations.
