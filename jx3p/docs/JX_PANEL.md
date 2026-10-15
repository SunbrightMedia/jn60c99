# JX_PANEL.md -- the JX-3P's drawn panel and JX-3P.exe (scope row 20)

The JX plugin's GUI is the JUNO-60's framework (the same control classes, jx3p/tools/fw_map.py) with its own
Script.xml and art: the user's Script folder, pinned in `jx3p/truth/Script/` (24 sprite sheets, `SHA256SUMS`;
Roland's artwork: never publish it). `jx3p/gui/win/jx3p_win.c` is `gui/win/juno60_win.c` on the JX engine; what the
JUNO's program did not have is below. Labels: READ (the disassembly), EXECUTED (run in the oracle), INFERRED.

## The JX's own control classes

Found by their type names: the factory rva 0x34DF10 compares each Script.xml `<type>` and builds the class; each
class's vtable differs from its base's in a few slots (type name vt+0x108, init vt+0x30, update vt+0xB0, press
vt+0x120). Each rule is the plugin's, READ.

| Control | Class (vtable, base) | Rule | Where |
|---|---|---|---|
| jx3pLatchButton | 0x99F690, latchButton | `role` 0 or 1 (+0x170; other values refused). Press: value ^ (role ? 2 : 1) through the editor's set (rva 0x283C90, unclamped), the trio and the commit. Frame: 2 while the bit is set, + 1 while held | 0x350AF0, 0x350F80, 0x3510C0 |
| jx3pSlider | 0x99F4D0 / 0x99F630, slider | two positions (0x350F70); position = (value >> role) & 1 (0x350F30); position p sets (value & (2 >> role)) \| (p << role), nothing when equal, as a POSITION through the value's number table (0x351010 -> 0x283A60). A click off the cap with `clickable`: one position on, turning at the ends (the slider's release, 0x2E7AD0) | 0x350D10, 0x351010, 0x2E6B20, 0x2E7AD0 |
| exprLatchButton | 0x9A0048, latchButton | on while its `<state>` (postfix, as panel conditions) holds (0x350980). Press: on -> its offValueRef/offValue pairs, else its on pairs, in order, one multi-set (0x283B30 = the JUNO's 0x283C50), the trio and the commit. Frame: 2 while on, + 1 while held. The JX CHORUS button: on = EFFECT TYPE 2 (JX-3P CHORUS), TONE 128, LEVEL 255; off = LEVEL 0 | 0x34FA60, 0x350770, 0x3509C0 |
| patchSelectButton | 0x9A0F28, latchButton | `lane` (bool), `patchType` (default 0), `index`. The current patch is vm.vs.patchId (EXECUTED: the values object [model+0x80] vt+0x58 -> the vs+0x14 value). Press: lane 1 -> index x 16 + patch % 16 (the group A-D), lane 0 -> patch / 16 x 16 + index (1-16; C division); the patch manager selects it in list patchType (0x334D70 = the JUNO's 0x334E90) and loads the selection, pushed (0x337F70 = 0x338090). On (frame 2): lane 1 patch / 16 == index, lane 0 patch % 16 == index | 0x354BF0, 0x355040, 0x355110, 0x3551C0 |
| patchBlock | 0x9A0348, a plain control | `patchId` (+0x8C), `patchType` (+0x88). Text (0x3516E0): the name of patch patchId of bank vm.vs.bankId (EXECUTED: vt+0x50 -> vs+0x10; past the banks: bank 0) -- the characters between a '[' and the next ']' (a '[' on the way starts again; "String 1 [Str1]" -> "Str1"), else the patch's number (0x335520 = the list's number, format global 0xC7BB50 = 2: "A-1".."H-8"). Drawn inset 2 / 1 with its text writer. A down or a double click inside (0x351C90): focus, select patchId, load pushed | 0x3511E0, 0x3515F0, 0x351C90 |

## What else differs from the JUNO's program

* **A value's positions are its own number table** (`<value><numberTableRef>`; the value range object, rva
  0x2BFAD0 / 0x2BBB60: groups split by ',', alternatives by '|', a position its group's first value). The JUNO's
  program looked the table up by the CONTROL's stringTableRef -- right there only because the JUNO's names coincide
  (arpType, arpStep, hpfType). The JX's do not (value oscMod, control oscModL): its knobs, sliders and labels use the
  value's table.
* **No LFO LED** (Script.xml has no lfoLed; the engine's LED read, vt+104 rva 0x34AE20, is `ret 0`).
* **The host round trip** (JX-18): a panel edit of a parameter a host automates makes no engine record -- the plugin
  calls performEdit and the HOST sends the value back through process(). The program is that host: every performEdit
  (an edit's, a load's) becomes a parameter point of the next block, one queue per parameter, first seen first, its
  last value. The JUNO's bridge queues an engine record for an edit instead (its own model).
* **Every patch change mutes 0.5 s, then fades in over 10 ms** (writePatch, HOST_LAYER.md 2): initialize and every
  load. A note in that time is not heard -- the plugin's behaviour, not a fault.
* The engine is the JX product path (jx3p_product_init / _note / _param / _tempo / _block, the 96 kHz engine and the
  render object); its guest image and the factory bank are resources read through `JX_MEMFS` (jx_bridge.c read_file).

## Proof (jx3p/tools/jx_exe_check.py, the JUNO's tools/dist/native_check.py on the JX)

The program's `--render` runs a fixed script through its own handlers (MIDI, panel edits, a key click, the five JX
controls, the arp, patch changes, the CC menu) and logs every engine call. The checker replays the log through the
port's library built for Linux from the same sources (the build the JX gates grade against the plugin) and requires:
the output EQUAL BIT FOR BIT; each block's events and points = the DAW mapping of the MIDI queued plus the round trip;
each click on a JX control = the calls the rule above makes, computed from Script.xml and the library's model; the
meter ticks and the end state (getState's bytes) equal. Teeth: the replay drops an edit; the glue's velocity / 128;
the rule's other bit; a lost UI drain; and an EXE built with a defect (EXE_TOOTH=3: a DCO switch flips the other
bit) -- each must make the check RED.

That check re-states the rules it grades; the next section grades the program against the plugin's own code.

## Proof against the plugin's own GUI code (jx3p/tools/jx_panel_gate.py, scope rows 18-20)

The JUNO's tools/verify/cc_menu_gate.py method (CLAIMS A38), widened from the CC menu to every mouse event on the
five JX classes. The plugin builds its GUI tree at its module init (32 panels, 371 controls: 144 the CC search can
stop at, 177 of the five JX classes); the emulator's GDI+ gives each sprite sheet its size from the PNG header. The
gate requires the program's tree (kbscript `cctree`) to give the CC search the same input and the five classes the
same controls and rectangles, every panel's rectangle and modal byte equal; then it runs a seeded kbscript in the
program under Wine -- per panel configuration (vm.vs.mode, vm.vs.edit, TEMPO SYNC, DELAY TYPE, vm.vs.setup: 48) the
CC search at every corner and edge of every control and at random points, right presses with Shift / Ctrl / Alt,
Learn and Forget, CCs, blocks and drains; and on every live JX control a move, the down, moves, the up, double clicks,
inside, on the edges and just off them, from random values of what the control reads -- and plays the log into the
plugin (a worker: Unicorn only): the program's engine calls outside the mouse events, and at each mouse event the
plugin's OWN panel dispatch (rva 0x2AA9D0) on its root panel with the same message. After every event: getState's
bytes (every value, the CC map), the engine records pending for the next block and the host's edits (begin /
perform / end, each value) EQUAL, and the control the program hit = the control that took the message in the plugin.

What the plugin's own code showed (EXECUTED; each was a defect of the program, fixed):

* **The down is not the press.** The latch family (jx3pLatchButton, exprLatchButton, patchSelectButton: the
  latchButton handler, rva 0x2CD350) captures the mouse at the down and presses (vt+0x120) at the UP --
  jx3pLatchButton wherever the up is, exprLatchButton and patchSelectButton only with the up on the control (its hit
  flag +0x104). The program pressed at the down. patchBlock (rva 0x351C90) does load at a down or a double click.
* **The slider class whole**: jx3pSlider runs the slider handler (rva 0x2D0660): the down (vt+0x130, 0x2E6B20) --
  Ctrl: the default (0x2E6960), no drag; on the cap: a grab; off it without `clickable`: a jump and a drag from the
  centre --, the move (vt+0x140, 0x2E7940), the release (vt+0x138, 0x2E7AD0: a drag sets the point's position, a
  click on a clickable slider steps one position, turning at the ends), the point's position (vt+0x148, 0x2E7D80) and
  the cap (vt+0x150, 0x2E7C00). The program had a click rule only; each function is now ported.
* **The dispatch** (rva 0x2AA9D0; the root's own handler, 0x2AAD50, first tests the window's resize corner): an open
  panel (+0x70) takes part in a message when it holds the point (+0x18), when it holds the mouse (+0x30), or when it
  was in the last message's way (+0xDD: offered once more outside it, then cleared); then its controls from the last,
  then its open panels from the last -- the first that takes the message ends the walk; a MODAL panel (+0xDC,
  Script.xml `<modal>`) takes what none of them took, and a down outside all its panels closes it (rva 0x2A77A0: its
  open condition's value set to 0, flag 1, the trio and the commit). The SETUP page is modal, its size Script.xml's
  `size-win-pi` (800 x 260). EXECUTED by class: a control takes a down or a double click on its rectangle -- never a
  label, a display or a bar graph -- and no class takes a move or an up unless it holds the mouse; a down captures it
  until the up: the latch family, knobs and sliders with their panels (+0x30 up the chain), the keyboard alone,
  patchBlock and patchName nothing. A control may stand out of its panel (the patch select row: 2 rows below it): a
  press there reaches it only through the panel's hover. The program now walks every message (moves too) this way,
  with the same hover flags and capture, and closes the SETUP page so (tooth 10: no hover).
* **A label takes no mouse event** (rva 0x2D8B20): the plug-in-only "disable" layer over TEMPO (`<control-pi>`,
  black at alpha 0x60) passes presses to the knob under it. The program does not draw that layer: in the program the
  TEMPO knob IS the host's tempo (it is the host, JX-8) -- the same choice as JUNO-60.exe (docs/CC_MENU.md).
* **The patch name** (rva 0x33E950; corrected 2026-10-15, scope row 25): its rectangle is Script.xml's
  (231,294)-(501,324). The row-20 note "a down on its button changes nothing" was measured with every dialog
  cancelled: the arrow opens the name's edit, the rest of it the patch menu (see "The generic classes" below).

* **A drag holds the host's edit open.** The slider's steps set the position with the flag 0 and its release with
  1 (rva 0x283A60); the controller keeps one open edit (beginEdit at the first step, endEdit at the final set:
  HOST_LAYER.md 3n). The program sent beginEdit / performEdit / endEdit at every step. Now the switch passes the
  flag (jx3p_model_set_flag); tooth 9 makes every step final again.

## The generic classes, the wheel and the editor's timer (scope row 25, 2026-10-15)

jx_panel_gate.py now presses every live control of every class the program draws -- knob, slider, latchButton,
unlatchButton, keyboardX, patchName, label, display, barGraphX -- turns the wheel on them, and runs the editor's timer,
against the plugin's own handlers on its own tree. What it found the program had to become (READ, then EXECUTED by
the gate):

* **The knob** (the slider class's frame, rva 0x2D0660; the knob's own 0x2D6050 / 0x2D74C0): a down lays out a
  travel of n x 15 px (at most 200, under 4 x the control's height) with the point at the position; moves set by the
  point (flag 0: one host edit open), Shift one position per move past 2 px, Ctrl alone the default; the up sets the
  last point (flag 1), a click without a drag steps the clickable ones.
* **The slider** (the same frame; the JX switch is its class with a two-position accessor): the cap's place and the
  point's position with the tilt, the slack across, the resolution's remainder, Shift one step; a grab off the cap
  first jumps to the point.
* **The latch family** (rva 0x2CD350): the press at the UP, with the up on the control -- latchButton toggles its
  positions (on "1", off "0"), unlatchButton QUEUES its function (below), menuButton / setupButton open their menus.
* **The editor's timer** (SetTimer 50 ms; WM_TIMER rva 0x3103BE): the root panel's tick (rva 0x2AB250: an open
  panel's controls last to first, then its panels), then the module's idle (CModuleB vt+0x38): the function registry
  (rva 0x296300) runs each queued function whose time is BEFORE now (a press's function waits for the next tick).
  The clock is GetTickCount; a script's is its own ("gtick T"); the oracle answers GetTickCount with the same T.
* **The focus** (+0x10 -> +0x10 -> +0x18) and the operators: a control with a key operator (+0x80; the patch name's
  at +0x98) and a wheel operator (+0x90) takes the focus on a down or a wheel; on: the key operator's state 4 and its
  3200 ms timer; off: a step 0 when it was in state 3, the wheel operator's running 800 ms timer stopped with a step 0
  (a final set: the open host edit closes), the click direction back to 1. The tick: the key operator's states (1, 2
  repeat the step, 3 a step 0, 4 the focus let go), the wheel operator's 800 ms end; the display's order is the wheel
  operator's first (rva 0x2DE8B0, unseen: its step 0 is none).
* **The wheel** (WM_MOUSEWHEEL rva 0x3117C8 -> the message rva 0x43E370, the root's vt+0x50): a delta of 1..119
  counts 120; on a knob, a slider, a JX switch or the patch name: the focus, a step of (Ctrl: min(positions / 2, 10))
  x the notches (truncated), the 800 ms timer; on the keyboard OCTAVE SHIFT plus the notches (not taken); the latch
  family, labels, displays (not editable): nothing.
* **The patch name** (vt 0x99FA80, an editable display of fm.PATCH.NAME0.name[0..7], two chars each): a down or a
  double click on its rectangle takes the focus; ON ITS ARROW (the bitmap's frame at buttonPosition) the display's
  edit (rva 0x2CF920): the text -- the values' bytes, trimmed (rva 0x41A330: to the first zero, spaces of the C
  locale off both ends) -- offered, the answer trimmed and set (rva 0x2CFC70 -> 0x2EB160: two signed chars per value,
  the first the high byte, past the end a space; the eight with the flag 1, then the trio), the focus let go and taken
  again -- taken. ELSEWHERE ON IT (Script.xml gives no nonActiveArea: that rectangle is empty) the patch menu (rva
  0x330CF0 + 0x334590: two items per bank -- its name, then " " -- of 32 cells each, the current cell's path offered,
  a chosen path [t, s] the bank t / 2 and the patch (t % 2) x 32 + s) and, when a cell was chosen, its load without a
  push (rva 0x337F70) -- taken only then; a press it does not take goes on to the controls under it. Its wheel and
  its keys step the patch (its accessor, rva 0x33EBA0: the selection plus the step in 0..63, loaded; 64 positions).
  Ported: gui/juno_pm.c (juno_pm_patch_menu, juno_pm_load_selection, juno_pm_step) and jx3p_win.c (pn_mouse,
  pn_edit, the wheel and the timer through the operator classes).

* **The window's point** (every WM_ mouse message: rva 0x312600 / 0x312720 -> 0x2ABFC0): each coordinate
  (v x 200 / zoom + 1) / 2 in C's division, the zoom by the getter (rva 0x2AA470) -- the program had x 100 / zoom,
  truncated: at the default 75 % two of three points were a pixel off. kbscript `wpt` logs a point and its conversion;
  the gate runs the plugin's own conversion on its main window (247 points a quick run, 185 where the old rule
  differs, zooms 25 .. 51 under the Wine screen's fit).
* **The leave** (WM_MOUSELEAVE, asked at every WM_MOUSEMOVE with TrackMouseEvent TME_LEAVE, rva 0x3104C6): a move to
  (0x80000001, 0x80000001), not converted, flags 0 -- and the dispatch counts that point INSIDE every open panel (rva
  0x2AAA0F, READ; EXECUTED: the plugin's hover flags after a leave), so a leave marks every reachable open panel as
  hovered. One event path: the window's messages and the script's commands both call ev_down / ev_move / ev_up /
  ev_leave (the window's plain moves had not walked the panels at all). Each panel's hover flag (+0xDD) is compared
  (kbscript `hover`).
* **The keys** (WM_KEYDOWN without its repeat bit, WM_KEYUP: rva 0x310724): the key message {type, code, mods} (rva
  0x43AE20 / 0x436640; the code by the plugin's table, rva 0x43ABE0, generated into the program from the binary; Shift
  1, Ctrl 2, Alt 8) to the root's key (rva 0x2AA960): its listeners -- the list is never filled (READ: only its getter
  touches it; EXECUTED: empty) -- then the focused control's vt+0x58: the frame's (rva 0x2D0610) and the editable
  patch name's (rva 0x2DE710) key operator (rva 0x2D5AE0; the layout mover before it, rva 0x2C4630, is off:
  EXECUTED). Up / Right +1, Down / Left -1 (no operator's reverse flag is set: EXECUTED on all 141); a key down steps at
  once (Shift: times min(positions / 2, 10)), state 1 and 200 ms (the tick repeats every 50); a key up, state 3 and
  800 ms (the step 0). Graded: every virtual key's code against the plugin's table, arrows on knobs, sliders, JX
  switches and the patch name with the ticks between.
* **The resize corner** (the root's own mouse before its dispatch, rva 0x2AAEF0): a 20 px circle at (right - 20,
  bottom - 20) in 32-bit arithmetic; entering keeps the zoom (+0x140), a down there takes the mouse and the focus,
  moves set the zoom to max((2 x z0 + 1) / grab_x / 2, (2 y z0 + 1) / grab_y / 2) kept in the value's range, the up
  lets go. Graded through the zoom (kbscript `zoom` against the plugin's getter) and the converted points after it.
* **The patch window's buttons** (unlatchButtons, ManagePatch / ManagePatchBank): the latch family's rule -- pressed at
  the down, the function QUEUED at the up when the up is on the button (rva 0x2CD350 / 0x2CD7E0) and run at the next
  idle; the program had run it at the down. Graded in the plugin's OWN patch window: the editor opens it on
  panelPatch 1 (its root, vt 0x97FE48, named by its fit), and each press goes to that root's mouse (vt+0x48) at the
  program's point less the window's place (the program draws it centred in the main window; the plugin's is a window
  of its own). Compared at the down, right after the up (nothing run yet) and after the editor's timer: the patch
  window's values (open, patchManager, the lists, bankId, patchId), the state, the pending records. The program's
  click outside the window closes it (the plugin's window has its own close box): never pressed by the gate.
* **The option menu** (the menuButton's up with its action, rva 0x3251C0 -> 0x4147B0; EXECUTED item by item under the
  oracle): "JX-3P Layout" / "SYSTEM-8 Layout" (checked by vm.vs.mode), "Set MIDI Control Mapping for SYSTEM-8" and
  "Clear MIDI Control Mapping" (greyed by the plugin's test, rva 0x31A2B0), "2 / 4 / 6 / 8 Voices", "Optimize for
  Lower CPU Usage" (checked by vm.vs.sampleRate != 0), "Roland Cloud...", "Authentication..."; an up whose flags are
  exactly 7 (the right button -- flag 4 for 0x204-0x206, rva 0x4481C0 -- with Shift and Ctrl) adds five developer
  items. The popup numbers only the items with a text (from 1000, rva 0x4361E0). The choices: a layout sets
  vm.vs.mode; the mappings apply the plugin's one preset or clear the map (rva 0x31A3D0, jx3p/gui/win/jx_cc_preset.h
  generated by jx_gen_cc_preset.py and checked against the plugin's own apply and test -- the preset IS the default
  map, and a record two entries name keeps "Set" enabled always); a voice count sets vm.vs.voiceCount; the CPU item
  sets vm.vs.sampleRate 0 / 3; "Roland Cloud..." launches the plugin's string 40, empty where the plugin cannot reach
  Roland Cloud, and shows its message 14 (a warning box) -- this program's case. The program's old menu (its own
  items, 2-8 voices, four engine rates) is gone; its own settings (zoom, audio latency) are in the window's system
  menu. The oracle's side: each menuButton's own update (vt+0xB0, rva 0x325320) once, which sets the core pointer
  (+0x178) the menu reads the CC map by -- without it the menu read the zero page. Graded: the items, enables, checks,
  separators and the answer; then the state (the CC map in it), the pending records, the boxes.
* **Not ported, the user's call** (listed in SCOPE_AUDIT row 25): "Authentication..." (the Roland Cloud account's
  login panel: vm.vs.auth opens it; its authDisplay / authButton classes talk to Roland's servers), the five developer
  items (a JX-03 patch conversion, an AMP level conversion, a preset dump for PLUG-OUT, a bank's TSV import / export:
  each calls the patch manager, rva 0x32CB30 / 0x353E30 / 0x3534A0 / 0x339FD0 / 0x32F190 / 0x32E9B0, then sets
  vm.vs.patchManager to 11-15), and the setup panel's buttons (midiIn / midiOut, "MIDI CTRL Input / Output", rva
  0x2E5BB0 -> 0x2E5F00: the plugin's own OS MIDI ports -- the SYSTEM-8 link the user ruled out on 2026-10-07,
  docs/HOST_CALL_CENSUS.md). The program shows the two items and does nothing but say so; its setup panel's first
  button is the program's own MIDI input menu (a standalone program has no host to give it MIDI). Also the vendor's
  texts and windows (EXECUTED under the oracle): Help launches the plugin's manual (its message 13 where the manual is
  missing), About opens a window the oracle cannot see, the SYSTEM-8 link's buttons show message 4 (no SYSTEM-8); the
  texts are in the plugin's TextCodeTable.dat, not in truth/. The program shows its own help and about text and a
  status line for the link's buttons. SCOPE_AUDIT row 26.

The oracle's side: the patch name's text is its own update's (vt+0xB0, before each event: the template never draws,
so the live editor's notifications are the gate's call), the patch menu's popup answers a path (the service writes
the vector the menu passes), the edit's offer is read at its call of the text service (rva 0x2CFA19). A down that the
patch name does not take (its menu cancelled) is the plugin's too: the walk goes on.

The harness's own defects, found the same way: the plugin's queue at the boot (the script starts with a block); a
mouse that pressed where it had not moved (the hover flags decide what a panel offers: playbook 253); a pipe in
jx_verify.sh that hid a gate's verdict (playbook 251).

Evidence (2026-10-13/14): the full run GREEN -- 4283 mouse events (1846 taken), 5786 states, 4332 pending lists (300531 records), 89379 host edits, 20546 CC probes (x2), 1728 right presses (22 learns, 42 forgets), 51 CC map entries moved, 24 open-flag sets, every reach item (job jxpanel_s6); the quick run GREEN. Teeth: exe 3-8 and CC 1-7 bit on the program before its last two fixes (jobs jxpanel_teeth, jxpanel_cc18), exe 9 and 10 on the final one (job jxpanel_s5); the full verify-jx3p runs every one again (section 5c); CC tooth 8 cannot bite (computed). The bridge's open edit: jx_state_gate.py chain 7 GREEN, 7 mutants bite (job jxstate_gesture).

Scope: the five JX classes, the CC search and Learn / Forget on the plugin's tree, the bank name control's presses
(jx_patch_manager_gate.py with the art's sizes). NOT graded against the plugin's own handlers: the generic classes'
presses (knob, slider, latchButton, unlatchButton, menuButton, setupButton, keyboardX, patchName, label, display,
barGraphX -- the JUNO's program's code, graded through their engine calls only: scope row 25) and the drawn pixels
(the oracle's template has no live view: the drawing is READ).

## Build, check, use (LOCAL ONLY: the program embeds Roland's artwork)

```
python3 jx3p/tools/make_native_jx.py      # -> scratchpad/dist/JX-3P.exe (gitignored; objects cached by their inputs)
python3 jx3p/tools/jx_exe_check.py        # the check above (Wine); jx3p/tools/jx_verify.sh runs it with its teeth
```

| | |
|---|---|
| Keys | click the keybed (lower on a key = louder); MIDI in: SETTING; the wheel over the keybed: OCTAVE |
| Patches | the row of names (a click loads it), A-D (the group) and 1-16 (the patch), the arrows by the name; PATCH: the patch window (banks, write, rename, files) |
| Panels | OPTION: Original / SYSTEM-8 layout, voices 2-8, engine rate, zoom, audio latency; EDIT (Original layout): the PG-200 panel |
| MIDI CC | a right click on a control: Learn MIDI CC / Forget MIDI CC |
| Files | `%APPDATA%\JX-3P\settings.ini`; the banks: `%APPDATA%\JX-3P\Banks` (the factory bank "1 Preset" is installed there once and saved at the first close -- the plugin's rule) |
