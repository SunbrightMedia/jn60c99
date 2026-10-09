# gui/skin -- the plugin's own GUI on the C99 port

The JUNO-60 face of the Roland Cloud plugin, drawn from the plugin's own
`Script.xml` and the sprite sheets of its `Script` folder, playing the bit-exact
C99 port (compiled to WebAssembly, `gui/web/juno.wasm`).

**LOCAL ONLY.** The sprite sheets (`truth/Script/*.png`) are Roland's artwork from
the user's plugin installation. Never publish this page, never copy the sheets
into `gui/web/` or `docs/` (both may be served by GitHub Pages), never publish it
as an artifact.

## Run

From the repository root:

```
python3 -m http.server 8000
```

Open `http://localhost:8000/gui/skin/`. Audio starts on the first click.
URL options: `?zoom=75` (the plugin's zoom, 25..200; default 62, at most the screen's fit:
docs/WINDOW_ZOOM.md), `?skin=<url of a Script folder>/`, `?xml=<url of a Script.xml>`,
`?bank=<url of a .bin>` (the Patch folder's factory bank), `?banks=<url of a manifest>`
(`[{name, file}]`: more banks in the Patch folder), `?fresh` (the data folder starts empty and
nothing persists). For the checks only: `?rate=<Hz>` (the engine at that rate, no audio),
`?pmsetup=<url of a json>` (the patch manager gate's folders, no settings, no timer).

## What comes from where

| Fact | Source |
|---|---|
| Every position, size, sprite sheet, frame count and direction | `Script.xml`: `panelType`, `control`, `bitmap` |
| Every control's parameter | its `valueRef`, walked through `Script.xml`'s value tree to a Roland 7-bit address = the plugin's parameter id |
| Ranges, defaults, labels, lever positions | the value tree's `range` / `default`, `stringTable`, `numberTable` |
| Fonts and colours of the displays | `textWriter` |
| Which panels show (tempo sync, delay type, patch window, setup) | `openCondition`, postfix |
| The keyboard's key shapes, layout and black-key offsets | `keyboardX`: `keyRange`, `chromaticRect`, `chromaticOffset` |
| CHORUS OFF / I / II and their LEDs | the plugin's code, READ: rva 0x351410 (OFF: DEPTH 0 when TYPE is 2..4; I / II: TYPE 2 / 3, 4 with the other held; DEPTH 255; TONE 128), rva 0x3515B0 (LED I: TYPE 2 or 4, LED II: 3 or 4, DEPTH > 0) |
| The keyboard: layout, hit test, click velocity, press / release / KEY HOLD / Shift, the wheel, the keys drawn | the plugin's code, READ (docs/KEY_HOLD.md rule 10): rva 0x2D45E0 (white keys one width / their count apart, a black key at the key before's right edge + its offset - half its width), rva 0x2D4AA0 (the point clamped into the control, whole pixels; a gap belongs to the next key; velocity 1016 x (y - key top) / key height / 7, integer, 1..127), rva 0x2D4920 / 0x2D48A0 (a press releases every key above 0 first unless KEY HOLD is on and Shift is down; the button up releases the key unless KEY HOLD), rva 0x2D47E0 (each send is a write into the plugin's keyboard note value: a press at the click velocity, a release at -64), rva 0x2D4420 (the wheel: OCTAVE SHIFT one step), rva 0x2D3E20 (key i down when the note value's state of i + 12 x OCTAVE SHIFT is above 0: what the UI timer drained and the keyboard wrote) |
| A control's edit | the plugin GUI's model set (rva 0x283DB0) = `juno_gui_model_set`: the store keeps value & mask, the engine gets it at the next block; then the commit every panel control makes (rva 0x2DD100) |
| A patch load | the patch browser's load and its set of the patch number; the INC / DEC / LOAD buttons commit after it (rva 0x322E60), a load from the patch window's list does not (rva 0x3278C0) |
| The LFO LED and the two level meters | the plugin's code, EXECUTED (docs/LED_METER.md, CLAIMS A37): at each 50 ms tick the open LED's frame (`juno_gui_lfo_led_frame`: the engine's LED store read, rva 0x3C7180, then rva 0x325070) and each meter's state, fill and blits (`juno_gui_meter_tick`, rva 0x31C450; `juno_gui_bar_draw`, rva 0x31C210: a plain blit, then the fade columns at their alphas); the skin only blits what they return |

The patch window is the plugin's patch manager, ported (CLAIMS A39, docs/PATCH_MANAGER.md): the
banks, the 4 x 16 list (its rectangle from `Script.xml`, the cells as the plugin draws them), the
keys, the buttons, the bank name, drags, undo / redo, copy / cut / paste / insert, write, rename,
new / delete patch and bank, import / export, the number format, autosave. `gui/juno_pm.c` runs in
the WASM (`engine.js PatchManager`); the page gives it the files and the dialogs:

| What | In the page |
|---|---|
| The folders | `files.js`: the plugin's Windows paths, in memory; the data folder (the user's banks) kept in IndexedDB; the Patch folder the banks the page was given (read only); an export a browser download; a folder's names in NTFS's order |
| The text edit, the message boxes | the browser's modal prompt / confirm / alert |
| The bank menu, the file picker | they cannot block a page: the commands that open them first (ctrl+B, the bank menu button, a press on the bank name outside its button; ctrl+I, the import button) ask BEFORE the call, and the manager gets the answer |
| A double click | the click count of mousedown (a pointerdown has none): every second press of a series, as Windows gives it |
| The settings (PatchManager/BankName, Patch/Format) | localStorage |
| The editor's last close (every bank saved) | the page's pagehide; a hidden page saves too |

## The engine interface (the plug-and-play test API)

`skin.js` reaches the synth only through `engine.js`:

| Method | The plugin path it stands for |
|---|---|
| `init()` | the host's boot: initialize (six voices, the 95 defaults, the start-up mute) |
| `values()` | getState: the model, id -> value |
| `set(id, v)` | a GUI control's model edit (rva 0x283DB0) |
| `loadPatch(bank, idx)` | the patch browser's load (rva 0x335850) |
| `noteOn(n, vel)` / `noteOff(n)` | MIDI in through the wrapper's intake (channel 1, note-off velocity 64) |
| `keybedWrite(key, v)` / `keybedState(key)` | the panel keyboard's write into the plugin's keyboard note value (rva 0x2D47E0) / that value's state of a key |
| `commit()` | the model's commit a panel control makes after its set |
| `setTempo(bpm)` | the clock when no host runs one |
| `uiTick()` | the 50 ms UI-timer drain (rva 0x320120) |
| `patchManager(io, dirs)` | the plugin's patch manager (rva 0x330D10), its file and dialog calls given by `io` |
| `zoomGet(win, value, cx, cy, w, h)` | a window's zoom getter (rva 0x2AA590): the value, at most the screen's fit (rva 0x312750) |
| `start()`, `peaks()` | the audio output (display only) |

`WasmEngine` runs the port in the browser. A bare-metal board needs one class with
the same methods (e.g. over Web MIDI SysEx or Web Serial); the skin does not change.

## Gate

`node tools/verify/skin_check.mjs` (in `make webapp`) boots the page in headless
Chromium and checks: every sprite sheet loads; every control of the original panel
resolves; every control id names the same parameter in the port's own tables (taken
from the running plugin) -- an independent witness of the address walk; controls
write through the model path (the engine's getState holds the value): DCO RANGE, a
slider drag, a lever, the CHORUS rule and LEDs; INC loads patch 2 through the patch
load; a key sounds; no console error. Teeth (`--tooth chorus | address | swap`) all
bite (2026-10-08).

`node tools/verify/skin_kb_check.mjs` (in `make webapp`; needs `make native`'s
JUNO-60.exe and Wine) plays seeded panel scripts -- mouse down / drag / up with and
without Shift, inside, in the gaps and past the edges; the wheel; KEY HOLD and OCTAVE
SHIFT edits; patch loads from the buttons and the list; MIDI notes; the UI timer --
into the page with REAL pointer events and into JUNO-60.exe (`--kbscript`), and
requires the same engine calls in the same order: the keyboard rules are READ and
written twice (C and JavaScript); the exe's calls are graded against the plugin itself
(CLAIMS C6). 8/8 seeds the same calls; teeth 3/3 bite (velocity one step off, the other keys never released, a
gap given to the key before).

The LED and the meters (CLAIMS A37): the three calls the skin makes at each tick are graded against
the plugin's own functions by `tools/verify/led_meter_gate.py` (in `make verify`), and the WASM's
results against the native build's after every render of the app's flows by
`tools/verify/wasm_product_gate.py` (in `make webapp`, with a tooth: a WASM with another meter floor).

The CC assign menu (CLAIMS A38, docs/CC_MENU.md): a right-button press with no Shift, Ctrl or Alt
on a parameter's control opens "Learn MIDI CC" / "Forget MIDI CC #n" -- the plugin's search
(`ccTarget`: a panel's controls from the last, then its open panels; not a label or a display,
one value, a CC map record) and its menu (`ccMenu`: Forget greyed without a CC or while a learn
waits); any other right press acts as a left one. The page's MIDI input now gives the engine CCs,
pitch bend and channel aftertouch as a DAW gives them to the plugin (`engine.js midiIn` ->
`juno_gui_host_param`), so the mod wheel, the pedal, mapped and learned CCs work in the web app.
`tools/verify/skin_kb_check.mjs` holds the skin's menu equal to JUNO-60.exe's (whose menu is graded
against the plugin's own handler on the plugin's own panel tree by `tools/verify/cc_menu_gate.py`):
the same searches, real right presses with modifier keys, the items clicked or Escape, CCs, drains
and states; teeth `ccedge`, `ccmods`. Found by it: an old menu's outside-press listener, registered
by a late timer, closed the next menu on its own item's press -- each listener now acts only for
its own menu.

The patch window (CLAIMS A39): `tools/verify/skin_pm_check.py` (+ `skin_pm_run.mjs`, in `make
webapp`) plays the patch manager gate's references -- the plugin's own runs of seeded command
scripts -- into the page: its key, button and mouse handlers, its files, its dialog logic; after
every command the dialogs asked, the file changes, the model calls, the manager's whole state and
every file must equal the plugin's. 9 seeds; teeth on the page's own code (`keys`: up / down
exchanged, `capture`: a drag's moves lost, `button`: the bank name's button unknown) bite.
`skin_kb_check.mjs` also holds the window's patch loads (LOAD, ctrl+O) and the window zoom
(`zoomfit`) equal to JUNO-60.exe's. The LFO LED's show rule (docs/LED_METER.md rule 13): a LED
read when its panel shows or hides, as the plugin's show does.

## Not ported (drawn idle or left out)

| Item | Why |
|---|---|
| SEND / GET, SEND ALL / GET ALL, PLUG-OUT (ctrl+U / ctrl+G) | the SYSTEM-8 link: not needed (the user's decision) |
| Activation and login panels | licensing; not part of the synth |
