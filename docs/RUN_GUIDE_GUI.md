# Test GUI — full parameter control + patch recall

Two front-ends over the same engine bridge (`gui/juno_bridge.c` → the DLL/so):
a **web app** (`gui/juno_web.py`, recommended) and a **Tk desktop app**
(`gui/juno_gui.py`). Both need the built engine library.

## Web app (localhost, runs from a checkout)

```
make dll        # (Windows DLL already committed; Linux/Mac: make gui)
python3 gui/juno_web.py            # serves http://localhost:8765 + opens browser
python3 gui/juno_web.py --port 9000 --no-browser
python3 gui/juno_web.py --selftest # headless API check
```

Zero dependencies (Python stdlib http.server + ctypes). It serves
`gui/index.html`:
- **Every mapped parameter** as a slider (continuous) or ON/off toggle
  (switch), grouped by section, filterable. Slider **positions are the real
  captured factory values**; min/max **bounds are heuristic** (marked `~`)
  until the real range table is dumped — see *Real ranges* below (then marked `●`).
- **Piano keyboard** (MIDI 36–72) for the note gate, **Render & play** (renders
  through the full pipeline to a WAV the browser plays), chorus mode dry/I/II.
- **Patch recall**: factory patch, plus Save/Load JSON patches from `presets/`.

### Real ranges (optional, faithful)

The plugin's true per-parameter min/max live in a binary metadata table
(`unk_1809EC040`, 4966×16 bytes) that is **not** in the offline decompile.
Recover it with one IDA step:

```
# in IDA 9.3 on the analysed Cloud 60 database:
File > Script file… > tools/extract_param_meta.py
# copy param_meta_dump/param_meta.json  ->  gui/param_meta.json
```

The web app auto-loads `gui/param_meta.json`; matched sliders then use the real
range and show `●`. (Verify the ID→offset alignment noted in the script header.)

### Patch bank (.bin)

Upload the real bank `.bin` to the repo and I'll wire the plugin's deserializer
(`sub_18033C330`: `.s8p`/`PLUGOUT_PATCH`/`.PRM`) so its patches list in the
loader. Until then the loader uses JSON patches + the built-in factory patch.

## Tk desktop app (original)


Barebones Tkinter panel latched onto the C99 engine through a flat C ABI
(`gui/juno_bridge.c` → `libjuno.so`, loaded via ctypes). No dependencies
beyond a C compiler and stock Python 3 (Tk).

```
make gui                       # builds libjuno.so
python3 gui/juno_gui.py        # opens the panel
python3 gui/juno_gui.py --selftest   # headless bridge check (no display)
```

**Windows:** no build needed — a prebuilt `juno.dll` (mingw-w64, static,
imports only KERNEL32+msvcrt; smoke-tested under Wine) is committed in the
repo root and the GUI loads it automatically:

```
py gui\juno_gui.py
```

To rebuild it: `make dll` (cross) or natively
`gcc -std=c99 -O2 -fno-strict-aliasing -shared -static -o juno.dll gui/juno_bridge.c src/*.c -lm`
from MinGW/MSYS2. Any crash/traceback lands in `gui/crash.log`.

## What it is

- **Every mapped parameter** — the rows of `docs/COEFF_PARAM_MAP.md` (the
  sub_180388170 registry parse), grouped by engine section, filterable.
  Edit a value and press **Enter** to write it. This uses the plugin's own
  parameter mechanism: a raw float store to the state offset, native units,
  no curves (docs/CONTROL_LAYER.md).
- **Patch recall** — *Factory patch* re-applies the built-in captured patch
  (PD The Juno Pad, 96 kHz). *Save/Load patch…* snapshot/restore all mapped
  offsets as JSON in `presets/`.
- **Render WAV…** — renders N frames through the full per-sample pipeline
  (voice 0 → master/chorus) to `gui/render.wav` for offline listening.
- **Chorus mode** 0/1/2 selector (0 = dry/bypass), via the driver's host shim.

## Honest limitations (engine-side, not GUI-side)

- **No note-on path yet.** The ramp-gate engine (control-layer unit #1) is
  not transcribed; the *Gate* buttons poke `state[101504]` but the filter
  envelope stays closed → silence. Expected. Renders are still useful for
  verifying the pipeline runs and params/patches store correctly.
- **Voice 0 only**; voices 1–7 render silent (docs/PORT_STATUS.md).
- Raw pokes fully apply to live-read params; derived biquad-style slots
  (High Cut A0/B0…) need the un-ported coefficient appliers to recompute.
- Engine runs at 96 kHz to match the captured patch.
