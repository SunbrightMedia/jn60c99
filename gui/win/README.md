# gui/win -- JUNO-60.exe: the port and the plugin's panel as one Windows program

One `.exe`, its own window, nothing else to install: the C99 port (the same
sources as `libjuno.so`, compiled natively) under the plugin's own panel, with
Script.xml, the 31 sprite sheets and the banks embedded.

**LOCAL ONLY.** The program embeds Roland's artwork (`truth/Script/`) and the
user's banks (`scratchpad/userbanks/`). It is built into `scratchpad/dist/`
(gitignored): never commit it, never publish it.

## Build

```
python3 tools/dist/make_native.py          # -> scratchpad/dist/JUNO-60.exe
```

Needs mingw-w64 (`x86_64-w64-mingw32-gcc`, `-windres`). The port's flags
(`-std=c99 -O2 -ffp-contract=off -fno-strict-aliasing`), then GDI+, winmm,
comdlg32. The banks go in as one zero-run coded blob (Factory first, then
`scratchpad/userbanks/*.bin`; `--no-userbanks` leaves them out).

## What runs

| Part | The plugin path it stands for |
|---|---|
| Boot | `juno_gui_create(48000)` + `juno_gui_plugin_init`: six voices, the 95 defaults, the start-up mute, the 96 kHz engine and its converter |
| Audio | its own thread, the plugin's SSE FTZ / DAZ mode, `juno_gui_process_ex` (the plugin's process()) per 256-sample block into waveOut at 48000 (Windows' mixer resamples) |
| Keys, MIDI in (winmm) | host note events (velocity v / 127); CC n, aftertouch, pitch bend as the MIDI-mapping parameters base + n / + 128 / + 129 |
| A control | the GUI's model set (rva 0x283DB0 = `juno_gui_model_set`) |
| A patch | the patch browser's queued load (`juno_gui_queue_patch`, rva 0x335850) |
| UI timer | every 50 ms the drain (`juno_gui_ui_tick`, rva 0x320120), then a redraw of what changed |
| The panel | `gui/skin/skin.js` in C: the same Script.xml walk, sprite frames, conditions and READ rules (CHORUS, key velocity, octave shift) |

OPTION menu: panel, voices 2..8, engine rate, zoom, **audio latency** (21 / 32
/ 43 / 64 ms; default 43). The title bar shows "audio drop-outs: N" if the
output ever ran dry, and "NO AUDIO OUTPUT DEVICE" if waveOut did not open.

## Tests (no window)

| Mode | What it gives | Graded by |
|---|---|---|
| `--dump-controls FILE` | every control of the original panel: type, value ref, id | equal to the web skin's list (123 rows, same order and ids) |
| `--shot FILE.bmp [--bank B] [--patch N]` | the panel as drawn | equal to the web skin's canvas except text glyphs (GDI vs browser fonts) |
| `--render FILE [--bank B] [--patch N]` | the audio thread's own path on a fixed script, raw float L R; every engine call to FILE.log; the worst block's time | `tools/dist/native_check.py`: the log replayed through `libjuno.so`, equal bit for bit; every block's host events = the queued MIDI in the DAW mapping |

```
WINEPREFIX=<a prefix> python3 tools/dist/native_check.py      # under Wine on Linux
python3 tools/dist/native_check.py --tooth replay | glue      # each must FAIL
```

Window-level smoke test (2026-10-08, Wine + Xvfb + an ALSA null device): a
driver posting real mouse messages into the window: INC / DEC change the patch
(the title names it), CHORUS I lights its LED, a key plays; the audio loop
rendered without a drop-out through four patch changes.

## Not ported

The same as gui/skin (README there): the LFO LED and output meters, the CC-assign
menu, writing patches into a bank, the SYSTEM-8 buttons.
