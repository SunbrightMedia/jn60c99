# Test GUI — full parameter control + patch recall

Barebones Tkinter panel latched onto the C99 engine through a flat C ABI
(`gui/juno_bridge.c` → `libjuno.so`, loaded via ctypes). No dependencies
beyond a C compiler and stock Python 3 (Tk).

```
make gui                       # builds libjuno.so
python3 gui/juno_gui.py        # opens the panel
python3 gui/juno_gui.py --selftest   # headless bridge check (no display)
```

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
