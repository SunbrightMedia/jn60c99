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
* **The patch name** (rva 0x33E950): its rectangle is Script.xml's (231,294)-(501,324); it takes a down on its
  button (the art's frame, 20 x 32) and changes nothing -- no model call, record or state (EXECUTED). The program
  takes the button's frame (two rows lower, 324-325, than the plugin's rectangle lets through) and changes nothing.

* **A drag holds the host's edit open.** The slider's steps set the position with the flag 0 and its release with
  1 (rva 0x283A60); the controller keeps one open edit (beginEdit at the first step, endEdit at the final set:
  HOST_LAYER.md 3n). The program sent beginEdit / performEdit / endEdit at every step. Now the switch passes the
  flag (jx3p_model_set_flag); tooth 9 makes every step final again.

The harness's own defects, found the same way: the plugin's queue at the boot (the script starts with a block); a
mouse that pressed where it had not moved (the hover flags decide what a panel offers: playbook 253); a pipe in
jx_verify.sh that hid a gate's verdict (playbook 251).

Evidence: the quick run (three configurations) GREEN, job jxpanel_q5; the full run and the teeth: in progress.

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
