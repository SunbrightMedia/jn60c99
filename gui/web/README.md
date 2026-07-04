# In-browser GUI (WebAssembly) — the no-download way

The whole JUNO-60 C99 engine compiled to WebAssembly. It runs **entirely in the
browser** — no download, no Python, no localhost, no server. Same engine as the
desktop/local GUIs (bit-identical: captured cutoff `0.415686`, identical render
output), just compiled with emscripten instead of gcc.

## Use it — the permanent-URL way (recommended)

Two one-time steps (the workflow can't be pushed by a bot token — it needs
`workflow` scope — so you add it):

1. **Add the workflow.** Copy `gui/web/pages-workflow.yml` to
   `.github/workflows/pages.yml`. Easiest: on GitHub, **Add file → Create new
   file**, name it `.github/workflows/pages.yml`, paste the contents, commit.
2. **Enable Pages.** Repo **Settings → Pages → Source → "GitHub Actions"**.

Then every push to the default branch republishes. The synth lives at:

```
https://<owner>.github.io/<repo>/
```

Bookmark it. When new changes land, just refresh — nothing to download or run.
(The workflow rebuilds the WASM from `src/` in CI, so the hosted binary can
never drift from the source.)

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
