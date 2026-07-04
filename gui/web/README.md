# In-browser GUI (WebAssembly) — the no-download way

The whole JUNO-60 C99 engine compiled to WebAssembly. It runs **entirely in the
browser** — no download, no Python, no localhost, no server. Same engine as the
desktop/local GUIs (bit-identical: captured cutoff `0.415686`, identical render
output), just compiled with emscripten instead of gcc.

## Use it — the permanent-URL way (recommended)

No file to create, no merge. The app is mirrored into the repo's `docs/` folder;
just point Pages at it:

1. Repo **Settings** → **Pages** (left sidebar).
2. **Source: Deploy from a branch.** Branch: `claude/c99-gui-fable5-yfhak1`,
   folder: **`/docs`**. Save.
3. Wait ~1 minute, refresh. A link appears — the synth lives at:

```
https://<owner>.github.io/<repo>/
```

Bookmark it. Every push to that branch republishes automatically — just refresh.
(Once the branch is merged, switch the Pages branch to `main`.)

**Alternative — auto-rebuild via Actions** (`pages-workflow.yml`): copy it to
`.github/workflows/pages.yml` and set Source → "GitHub Actions". This rebuilds
the WASM from `src/` in CI so the hosted binary can't drift. Optional; the
`/docs` method above is simpler.

## Use it — locally, no build

The prebuilt `juno.js` + `juno.wasm` are committed. Any static file server works
(the browser needs `http://`, not `file://`, to fetch the WASM):

```
python3 -m http.server -d gui/web 8000     # then open http://localhost:8000
```

## What it does

- Every mapped parameter as a slider (continuous) or ON/off toggle, grouped +
  filterable. Slider **positions are the real captured factory values**; min/max
  **bounds are heuristic** (`~`) until a real range table is present.
- **Piano** (MIDI 36–72), **Render & play** (renders in-browser, plays via Web
  Audio), chorus dry/I/II.
- **Patches**: factory recall, Save/Load (stored in this browser via
  localStorage), and Export/Import `.json` for sharing.

## Real ranges

Drop a real `param_meta.json` (from `tools/extract_param_meta.py`, run once in
IDA) into this folder; matched sliders switch to the plugin's true min/max and
show `●`. The committed `param_meta.json` is an empty placeholder.

## Rebuild the WASM

```
# with emscripten (emcc) on PATH:
bash gui/web/build.sh
```

## Honest limits (engine-side)

Same as the other front-ends: the note-trigger path (unit #1) isn't ported, so
the piano/gate stay silent; voice 0 only; ranges heuristic until dumped. See
`docs/CONTROL_LAYER.md` and `docs/PORT_STATUS.md`.
