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
URL options: `?zoom=75` (the plugin's zoom, 25..200; default 62),
`?skin=<url of a Script folder>/`, `?xml=<url of a Script.xml>`, `?bank=<url of a .bin>`.

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
| A key's click velocity and the octave shift | the plugin's code, READ: rva 0x2D4AA0 (1016 x (y - key top) / key height / 7, integer, 1..127), rva 0x2D4C40 (note + 12 x OCTAVE SHIFT; the engine's own OCTAVE SHIFT writes no engine cell) |
| A control's edit | the plugin GUI's model set (rva 0x283DB0) = `juno_gui_model_set`: the store keeps value & mask, the engine gets it at the next block |

The patch window's 4 x 16 list sits in the grid `panelPatch.png` draws (the list's
rectangle is in `Script.xml`; the columns are read off the artwork).

## The engine interface (the plug-and-play test API)

`skin.js` reaches the synth only through `engine.js`:

| Method | The plugin path it stands for |
|---|---|
| `init()` | the host's boot: initialize (six voices, the 95 defaults, the start-up mute) |
| `values()` | getState: the model, id -> value |
| `set(id, v)` | a GUI control's model edit (rva 0x283DB0) |
| `loadPatch(bank, idx)` | the patch browser's load (rva 0x335850) |
| `noteOn(n, vel)` / `noteOff(n)` | a key through the wrapper's MIDI intake |
| `setTempo(bpm)` | the clock when no host runs one |
| `uiTick()` | the 50 ms UI-timer drain (rva 0x320120) |
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

## Not ported (drawn idle or left out)

| Item | Why |
|---|---|
| The LFO-rate LED, the output bar graphs | the plugin pushes them from its audio side (`vm.vs.dm`, `extraId`); that path is not yet read |
| MIDI CC assign (`ccAssign`) | the engine has MIDI learn (`juno_gui_cc_learn`); the menu that arms it is not drawn yet |
| The patch window's WRITE / RENAME / NEW / DELETE | writing a record into a bank is not in the port's API yet |
| SEND / GET, SEND ALL / GET ALL, PLUG-OUT | the SYSTEM-8 link: not needed (the user's decision) |
| Activation and login panels | licensing; not part of the synth |
