# PATCH_MANAGER.md -- the patch window: the plugin's patch manager, ported (CLAIMS A39)

The plugin keeps its patches in a librarian, the patch manager (a singleton, rva 0x330D10; static at
rva 0xC43B60). Its window (Script.xml panel `patch`, modal, 1690 x 696) draws it and drives it with
the list control (`patch`, vtable rva 0x968D00), the bank name control (`patchBankName`, rva 0x968FE8)
and the buttons (functions ManagePatch rva 0x322E60, ManagePatchBank rva 0x323FD0). Port:
`gui/juno_pm.c` / `gui/juno_pm.h` (C99, no platform calls: the app gives the files and the dialogs),
used by JUNO-60.exe and, compiled into the WASM, by the web page. Every rule READ from the binary
(the rva at each) and graded against the plugin's own code by `tools/verify/patch_manager_gate.py`.

## Data (READ, confirmed by executing)

| Where | What |
|---|---|
| pm+0x08 | int cur[2]: the current bank of the main list and the sub list (no JUNO control shows the sub list) |
| pm+0x10 | int sel[]: the selected patch |
| pm+0x18 / +0x28 | the bank name controls / the list controls registered by their show (rva 0x3308B0 / 0x3308C0) |
| pm+0x38 | the banks, 48 bytes each: a deque of States (the history) and its cursor |
| pm+0x50 | the clipboard: one record body (boot: the init record) |
| pm+0x68 / +0x6C | the editor count (attach rva 0x32FD50 / detach rva 0x32EEC0) / the autosave counter (rva 0x32F280) |
| State (88 B) | +0 the view given at its push, +8 the 64 bodies, +0x20 the name, +0x40 the view's image at that push |
| global 0xCB05B8 | the init record: the view's image at the first attach, or Script/Initial.bin's first record |
| global 0xC43B50 | the number format 0..2 (ctrl+J), process-wide; its setting "Patch/Format" read at module init (rva 0x332D30, parse rva 0x3E33F0: spaces, one '-', "%i"), written at exit (rva 0x338220); another value: the number is empty, a cell shows the name alone (rva 0x335640) |

A record body is 20207 bytes; a bank file record is a 16-byte name + the body. The name is the body's
8 name words at body offset 140: 16 chars, a char = byte[140 + 2k] * 16 + byte[141 + 2k]. A file's name
wins over the body's (rva 0x330ED0).

The record image (the serializer, rva 0x335990): a patch load (rva 0x335850) of ANY 20207 bytes, then
the serializer, gives the same bytes back (EXECUTED: 3 random bodies, every byte). Port: the bridge's
`juno_gui_record` / `juno_gui_queue_record`.

## History (undo / redo)

Each bank: a deque of up to 64 States and a cursor. push (rva 0x32CA60, bank, view): at cursor 63 the
oldest State goes; else the redo tail goes; the current State records the view (and, given one, its
image); a copy is appended and becomes current. undo (rva 0x335AE0): the cursor back; when the State
reached was pushed with the view, the State left keeps the view's image and the view takes the reached
one's. redo (rva 0x333480): the cursor on; when the State left was pushed with the view, the view takes
the reached State's image.

## Commands (the list's keys, rva 0x3278C0; Shift bit 0, Ctrl bit 1)

| Key | rva | Does |
|---|---|---|
| ctrl+W | 0x333660 | rename bank: the bank name control's text edit (its commit rva 0x33F260): trimmed; not a file's name (empty, a leading '.', one of `" * / : < > ? \ |`) or another bank's (case ignored): message 37 and the edit again with that text |
| ctrl+B | 0x3344C0 | select bank: a menu of the banks, the current one checked |
| ctrl+R | 0x32C6E0 | new bank: "Initial" (unique: "Initial 1", ...), 64 init records, appended, current |
| ctrl+T | 0x32DDC0 | delete bank: message box 38 (OK deletes); none left: one "Initial" |
| ctrl+I / ctrl+E | 0x32F2B0 / 0x32EAD0 | import (banks added; a file that is no bank: message 2 after all) / export the current bank (the save dialog, "<name>.bin"; a failed write: message 3) |
| ctrl+U / ctrl+G | 0x341F10 / 0x340B80 | SYSTEM-8 send / get: taken, not ported (the user's decision) |
| ctrl+N | 0x32C970 | new patch: the init record inserted at the selection, patch 64 dropped |
| Delete | 0x32E070 | delete patch: the selection erased, the init record appended |
| ctrl+O | 0x338090 | read patch: the view takes the record (pushed with the view) |
| ctrl+S | 0x332960 | write patch: the view's image into the selection (pushed without the view) |
| Space | 0x333680 | rename patch: a text edit of the trimmed name; trimmed, padded / cut to 16 |
| ctrl+C / ctrl+X | 0x32D6E0 / 0x32D950 | copy / cut (cut: erase + the init record appended) |
| ctrl+V / ctrl+Y | 0x333960 / 0x3307C0 | replace the selection / insert at it (patch 64 dropped) from the clipboard |
| ctrl+Z / ctrl+Shift+Z | 0x335AE0 / 0x333480 | undo / redo |
| ctrl+J | -- | the number format: 0 "01".."64", 1 "1-1".."8-8", 2 "A-1".."H-8" (the default) |
| ctrl+Shift+D | 0x32E190 | (no help text) the current bank as text, `<data>/<name>.txt`, a line per patch: the cell's text, CRLF |
| arrows | 0x334E90 | the selection: up / down clamped 0..63; left / right a column (16 rows x 4 columns) |
| Enter / Esc | 0x338090 + 0x3262C0 / 0x3262C0 | read and close / close |

The buttons: ManagePatch load (read, then close), save, saveLast, rename, inc / dec (rva 0x3245C0: the
bank and selection from the view's values, the selection +-1 CLAMPED 0..63, a read without a push --
the apps wrapped 64 -> 1 before: a defect); ManagePatchBank select, new, delete, import, export, inc /
dec (the bank, clamped), incSub / decSub. Script.xml's JUNO panels use inc, dec, load, save, rename, new,
delete, import, export and the SYSTEM-8 four.

## The window's model calls (EXECUTED: every call compared)

| When | Calls | rva |
|---|---|---|
| a load | the record into the view; bankId (vm.vs, 0x0FFFC010) and patchId (0x0FFFC014) set with flag 1 | 0x338090 |
| every key the list takes, a press / move / release on it | patchManager (0x0FFFC004) not 1: set to 1, notify, commit | 0x327CF8, 0x327E95, 0x328038 |
| every button, unconditionally | patchManager 1, the list's value (patchListMain 0x0FFFC005; incSub / decSub: patchListSub) 1, notify, commit | 0x3232F6, 0x324850 |
| the bank name's commit, the name taken or refused | the button tail | 0x33F402 / 0x33F190 |
| the close (Enter, Esc, load) | panelPatch (0x0FFFC002) open: set 0 (flag 0), notify, commit | 0x3262C0 |
| the open list's notify listener | patchManager and patchListMain back to 0 (raw: no set) | 0x3285F0 |
| the window's open (panelPatch 0 -> 1) | the bank and the selection from the view's values (rva 0x330E10); every bank's history keeps its current State alone, cursor 0 (rva 0x3308C0) | 0x33F200 / 0x33F4F0, 0x328330 |
| initialize | the load (no push), then commit only | 0x320420 |

The bank name control's mouse (rva 0x33F0A0): a press or double click on its button (its bitmap's frame
at buttonPosition: 64,60 14x34) opens its text edit (the rename, through the text edit's handler rva
0x2DE890); elsewhere on it the bank menu, and when a bank is chosen the button tail.

The list's mouse (rva 0x327D70), 4 columns of 16 on its rectangle: a press (or a double click) inside
captures and notes the cell (the drag's source; a double click also arms a read); a move while captured
selects the cell under the pointer (the target; outside: the source again, no target); the release
inside selects its cell, moves source -> target (rva 0x330A80, pushed) and reads (pushed) when armed.
While a target is held the cells draw the move (rva 0x326B20). A cell: the number, ": ", the 16-char
name at (column x width + left + 3, row x height + top + 1), the selected one in listC, the others listN
(rva 0x326930, 0x328550).

## Files (EXECUTED with a writable emulated file system)

- Boot (the first attach, rva 0x32FD50): Script/Initial.bin (absent in the user's Script folder: the init
  record is the view's image), then the .bin files of three folders: the data folder
  C:\ProgramData\Roland Cloud\JUNO-60 (the user's), the plugin's Patch folder and the old folder
  C:\ProgramData\Roland\JUNO-60 -- the last two each once (InstalledBankNames.dat in the data folder
  lists "P/<name>", "O/<name>", CRLF). All sorted by their whole path, bytewise (Patch < data < old);
  each a bank named by its file (a name not among the banks', rva 0x334F20); a malformed file is not a
  bank; none: one "Initial". The current bank: the one named by the setting PatchManager/BankName.
- Save all (rva 0x336FD0): every bank to `<data>/<name>.bin` through tmp.tmp (written, the old file
  deleted, tmp moved); a .bin there no bank wrote is moved to `<name>.bak` (unique: "<name> 1.bak", ...).
  When: at the 6002nd tick of the 50 ms timer (rva 0x32F280, ~300 s) and at the last detach.
- A folder's names come in NTFS's order (upper case, ordinal: FindFirstFile on NTFS).
- The open dialog (rva 0x40B5D0, EXECUTED): many files; the first item's file-system path
  (SIGDN_FILESYSPATH), each other item's normal display name (SIGDN_NORMALDISPLAY 0), which the
  manager joins to the first item's folder. The save dialog: the bank's name + .bin offered.

## The apps

- JUNO-60.exe (`gui/win/juno60_win.c`): the files are Win32's (the embedded banks a read-only Patch
  folder `res:/Patch`; the data folder the program's Banks folder); the dialogs: an edit control over
  the bank name or the selected cell, TrackPopupMenu, MessageBox (the plugin's box types 0x31 / 0x30;
  the texts are the program's own -- TextCodeTable.dat is not in truth/), the shell's IFileOpenDialog
  (the plugin's options 0xA40) and GetSaveFileName. A record load from the window waits for the audio
  thread to land it at a block's start. Settings PatchManager/BankName and Patch/Format in its ini.
- The web page (`gui/skin`): the manager in the WASM (`engine.js PatchManager`); the folders by the same
  Windows paths in memory (`files.js`: the data folder kept in IndexedDB, the Patch folder the banks the
  page was given, read only, an export a browser download); the menus and the file picker cannot block
  a page, so the commands that open them FIRST (ctrl+B, the bank menu button, a press on the bank name
  outside its button; ctrl+I, the import button) ask before the call and the manager gets the answer;
  the text edits and message boxes are the browser's modal prompt / confirm / alert. A press's click
  count comes from mousedown (a pointerdown has none): every second press of a series is the list's
  double click, as Windows gives it.

## Graded

- `tools/verify/patch_manager_gate.py` (`make verify`): the same seeded command script (keys, buttons,
  list and bank name mouse -- clicks, double clicks, drags --, model sets, saves, timer ticks, with the
  dialogs' answers: texts incl. refused and non-ASCII names, menu picks and cancels, message boxes, file
  picks incl. a broken file and many files) on the plugin (Unicorn: its own handlers on its own list
  control, the dialogs scripted) and on the port (libjuno), the same files; after EVERY command:
  every bank's every history State (name, view flag, image, the 64 records), cursors, current bank,
  selection, clipboard, number format, autosave counter, the view's image and its bank / patch values,
  the window's values, the dialogs asked, the file operations in order, every file of every folder, and
  the model calls in order. Seeds 9 (40 commands), 1-7 (200), 100 (281, the deep history): GREEN. Teeth
  (`--tooth N`, `-DPM_TOOTH=N`), each seen to bite: 1 inc / dec wrap (seed 9), 2 undo without the view's
  swap (5), 3 insert replaces (9), 4 no delete question (1), 5 a bank name's duplicate test with case
  (6), 6 no .bak moves (9), 7 a drag moves nothing (9), 8 the history one State short (100), 9 the body's
  name kept (9), 10 the format's start 0 (9), 11 no key / mouse tail (9), 12 no list value in the button
  tail (9), 13 the window never closes (9), 14 the listener's reset gone (9), 15 no history collapse at
  the open (9), 16 no tail for a refused name (1), 17 an import's second name read as a path (9), 18 no
  tail after the bank menu (9), 19 the menu on the bank name's button (1).
- `tools/dist/exe_pm_check.py`: the gate's references through JUNO-60.exe under Wine (`--pm-script`):
  its key, mouse and button handlers, its Win32 files on real folders, its dialogs answered by the
  script: all 9 seeds, every command equal to the plugin.
- `tools/verify/skin_pm_check.py` (+ `skin_pm_run.mjs`): the same references through the web page in
  headless Chromium: its handlers, its files, its dialog logic; teeth on the page's own code (the up /
  down keys exchanged, a drag's moves lost, the bank name's button unknown) bite.
- `tools/verify/skin_kb_check.mjs`: a patch load from the window's LOAD button or the list's ctrl+O
  makes the same calls (the record, the sets, notify, commit) in the page as in the program.

## Not ported

SYSTEM-8 send / get (ctrl+U / ctrl+G, SEND ALL / GET ALL, PLUG-OUT): the hardware link, the user's
decision. ManagePatchBank importTsv / exportTsv: no JUNO control calls them.
