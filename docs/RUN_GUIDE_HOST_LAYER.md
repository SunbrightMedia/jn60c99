# How to run `extract_host_layer.py` (locate #1 note handler + #2 param appliers)

Pulls the host/parameter layer that sits ABOVE the audio closure, so we can
TRANSCRIBE (from the original code, not captures):
- **#1** the note/MIDI → pitch+gate handler (lets the port play notes), and
- **#2** the parameter → coefficient appliers (lets the port honour any patch).

It works by call-graph neighborhood of functions we already know (the audio
worker, voice dispatch, voice-list lifecycle, and the parameter registrar/
registry) plus a scan for writers of the voice gate region — reliable, unlike the
earlier signature guesses.

## Steps
1. Fresh analyzed DB (the one you rebuilt), **AU: idle**.
2. **File → Script file… → `tools/extract_host_layer.py`**.
3. It dumps the anchors + their callers, scans ~45k functions for the note-path,
   and dumps the top candidates + the param-applier path. A couple of minutes.
4. Output **`host_layer/`** appears next to the database. **Zip & upload it.**

## What it contains
- `audio_worker_*`, `dispatch_*`, `lifecycle_*` + their `*_caller*` files — the
  process callback and the note-on / voice-allocation path (**#1**).
- `note_path_candidates.md` + `notecand*_*` — functions writing the voice gate
  region (the note-on handler).
- `param_registrar_*`, `param_registry_*` + their `*_caller*` files — the
  parameter manager and per-parameter setters (**#2**).

After upload I read it to (a) transcribe the note handler, and (b) **scope** the
parameter-applier surface before committing — #2 may be large, and we decide with
eyes open. Every transcription is then checked against the captured ground truth.
