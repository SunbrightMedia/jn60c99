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

NOT graded against the plugin's own GUI code: the five classes' rules are READ, the checker re-states them. The
next step is the JUNO's cc_menu_gate.py method: run each class's own press on the plugin's own tree in the oracle.

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
