# CC_MENU.md -- the CC assign menu and the apps' MIDI input (CLAIMS A38)

The plugin's main panel holds one control, Script.xml `ccAssign`. A right-button press on a
parameter's control opens its menu: "Learn MIDI CC" and "Forget MIDI CC #n". Read 2026-10-09 from
the binary (the disassembly), then graded by `tools/verify/cc_menu_gate.py`, which runs THE
PLUGIN'S OWN HANDLER on THE PLUGIN'S OWN PANEL TREE.

## The plugin's rules

| # | Rule | Label | Where |
|---|---|---|---|
| 1 | A mouse message's type: down 0 (WM_LBUTTONDOWN, WM_RBUTTONDOWN), up 1, double click 2, move 3; its flags: 4 for a right-button message, then \| 1 Shift (MK_SHIFT), \| 2 Ctrl (MK_CONTROL), \| 8 Alt (GetKeyState(VK_MENU) < 0); no bit for a held left button | READ (both jump tables decoded) | rva 0x407EB0, 0x411DB0 |
| 2 | A panel offers a message to its controls from the last, then to its open panels from the last; the main panel's only control is the CC assign control, so it sees every press first | READ | rva 0x2AAAF0 |
| 3 | The handler takes types 0 and 2 with flags exactly 4, when the control is attached to its core (+0x80, the CC map at core+24); it searches from the top panel (the parent chain, vt+0x18) | EXECUTED (every type, every modifier set) | rva 0x31D420, 0x2C4540 |
| 4 | The search: a panel's controls from the last -- the control's hit test (vt+0x110), not a label or a display (its type name, vt+0x108) with exactly one value (rva 0x31D7F0), the CC map record of its first value (vt+0xD8 -> rva 0x319B10) >= 0 -- then its open child panels (+0x70) from the last; the first record found | EXECUTED (the hit, the filters, the open panels); the ORDER: READ -- not observable on this panel (computed by the gate: no two live controls it can stop at overlap, in any of the 12 configurations) | rva 0x31D270 |
| 5 | The hit test of every JUNO control class is its rectangle, half open: left <= x < right, top <= y < bottom. A knob tests a circle when its frame is at least 80 x 80 and its ratio 80..119 % (its init); no JUNO knob is (frames 50 x 50, 14 x 32, 14 x 44, 42 x 24) | READ, EXECUTED (the gate's tree: every knob's rectangle) | rva 0x2CEAD0, 0x2D62E0, 0x2D7032 |
| 6 | Found: the focus calls (vt+0xB8 with 1, then 0), then the menu: "Learn MIDI CC", enabled; "Forget MIDI CC" with " #%d" when the record's CC is >= 0 (rva 0x319B70), else greyed and without a number (no CC, or a learn waits); the menu service (rva 0x400130, its override pointer rva 0xCB21F8) pops it up; item 0 learns (rva 0x31AA40), item 1 forgets (rva 0x3192E0); the press is taken, whatever the item | EXECUTED | rva 0x31D4A4..0x31D76F |
| 7 | Not found, or any other message: not taken -- the press goes on to the controls, which do not test the button (a right press acts as a left one) | READ | rva 0x2AAAF0, 0x2D41F0 |
| 8 | The patch window is a separate modal view (Script.xml `patch`: `<modal>1</modal>`): while it is open no press reaches the main panel | READ | Script.xml |

Learn and forget themselves -- a learn takes the first CC below 120 the UI timer drains, while it
waits no CC drives a parameter -- are CLAIMS A32 (state_save_gate.py).

## Found on the way (MEASURED in the emulator)

- The plugin builds its whole GUI tree at its module init: every panel, every control an object of
  its own class, its rectangle from its sprite sheet's frame. The emulator's GDI+ had served blank
  images of guessed sizes; with each sheet's real size (the PNG header, truth/Script/) the plugin's
  rectangles equal the apps' for every control the search can stop at.
- The template's open bytes are all 0 and its CC assign control is not attached to a core (+0x80):
  the live editor sets both. A CC that reaches a parameter at the drain makes the viewless template
  close every panel. The gate attaches the control with the plugin's own attach (vt+0xB0, rva
  0x31D7B0, which sets +0x80 to the core) and writes the open bytes before every press.
- The plugin's tree has two controls the apps do not build: a `<control-pi>` label ("disable",
  plug-in builds only) over the TEMPO knob, in both layouts -- the apps read only `<control>` and
  keep TEMPO live (they run no host clock); the search skips labels, so the menu is the same. And
  the patch name's rectangle is its Script.xml position and size (258 x 42); the apps' click area is
  its button (28 x 34). It has nine values: never a CC target. Its left click is not graded here.

## The apps' MIDI input

JUNO-60.exe takes MIDI as a DAW gives it to the plugin (CLAIMS C6). The web skin took notes only:
CCs, pitch bend and aftertouch never reached the engine, so the mod wheel, the pedal, CC 123, a
mapped CC and a learned CC did nothing there. Now `juno_gui_host_param` queues the DAW's mapping for
the next block through process()'s own path (proc_param: CC n -> the MIDI-mapping parameter base +
n, value d / 127; channel aftertouch base + 128; pitch bend base + 129, (lsb | msb << 7) / 16383;
graded against the plugin by midi_ctl_gate.py, CLAIMS A26), and the skin's MIDI input calls it
(engine.js `midiIn`).

## The port

- `gui/win/juno60_win.c`: `cc_press` (the flags: modifiers, the patch window), `cc_target` (the
  search on the program's tree), `cc_menu` (the labels, TrackPopupMenu, learn / forget), the
  WM_RBUTTONDOWN / WM_RBUTTONDBLCLK path; kbscript `rdown`, `ccmsg`, `ccpick`, `cctree`, `cc`,
  `state`; `--play` right presses; `--render` a learn, CC 20, a forget.
- `gui/skin/skin.js`: `ccTarget`, `ccMenu`, the right press in `down()`; Escape closes a menu;
  `engine.js`: `ccEntry`, `ccOf`, `ccLearn`, `ccForget`, `midiIn`.
- `gui/juno_bridge.c`: `juno_gui_cc_entry` (rva 0x319B10), `juno_gui_cc_of` (rva 0x319B70),
  `juno_gui_cc_learn` / `_forget` (A32), `juno_gui_host_param`, `juno_gui_midi_base`.

## Graded

- `tools/verify/cc_menu_gate.py` (make native): the plugin's tree (23 panels, 205 controls, 131 the
  search can stop at) gives the search the same input as the program's; 11280 search probes at
  every corner and edge of every control and at random points, each as a down and a double click;
  1632 right presses with Shift / Ctrl / Alt sets, the menu dismissed or Learn / Forget picked
  (333 taken, 34 learns, 27 forgets); CCs, blocks and drains between; 84 states (getState's bytes)
  equal; 12 panel configurations. Teeth (`--tooth N`, -DCC_TOOTH=N in the exe): 2 the right and
  bottom edges inside, 3 closed panels searched, 4 the modifiers ignored, 5 a greyed Forget acts,
  6 labels and displays searched, 7 controls with many values searched -- each bites; 1 (a panel's
  controls first to last) and 8 (the panels before the controls) cannot: the order is not observable
  on this panel (rule 4).
- `tools/dist/exe_oracle_check.py`: `--play` right presses (Learn, Forget, nothing) and CCs 16-19
  among the performance; the call log played into the plugin, every sample bit-exact and the state
  at the end equal to the plugin's getState (8 seeds; REACH: learns, forgets, moved CC map entries);
  `--tooth cc`: the plugin side loses the first learn.
- `tools/dist/native_check.py`: the `--render` script's learn, CC 20 and forget replayed through
  libjuno.so; the end state; `--tooth cc`.
- `tools/verify/wasm_product_gate.py`: the chain midi_cc_48000 (learns, CCs, drains, the mod wheel,
  the pedal, bend, aftertouch, a forget, CC 123, a panel edit), every render and state native ==
  WASM.
- `tools/verify/skin_kb_check.mjs`: the CC seeds -- the skin's search at the same probes, REAL right
  presses with modifier keys, the menu's items clicked (a greyed one stays open) or Escape, CCs
  through the page's MIDI input, blocks, drains, states -- the same calls and states as the exe
  (8 seeds); teeth `ccedge` and `ccmods` bite (a first tooth, `ccorder`, could not: rule 4).

Final evidence (2026-10-09, commit 129a7bd3, clean tree): make native GREEN (job final_a38), make
webapp GREEN with every tooth biting (job final_a38_web); the gate with the plugin's own attach
GREEN, teeth 4 and 6 bite (job cc_attach2).

## Limits (stated)

- The panels' open conditions (vm.vs.mode, TEMPO SYNC, DELAY TYPE, the setup page) are the
  program's own evaluation (CLAIMS C5): the template has no live view that evaluates them.
- No live window: the popup is the menu service's override (the items recorded, the scripted item
  returned; -1 for a greyed item, as Windows never returns one); the focus calls run on the template.
- The search order is READ only (rule 4).
