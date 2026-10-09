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
comdlg32, avrt (WASAPI's audio scheduling class). The banks go in as one zero-run coded blob (Factory first, then
`scratchpad/userbanks/*.bin`; `--no-userbanks` leaves them out).

## What runs

| Part | The plugin path it stands for |
|---|---|
| Boot | `juno_gui_create(R)` + `juno_gui_plugin_init`: six voices, the 95 defaults, the start-up mute, the 96 kHz engine and its converter; R = the output device's own mix rate when the plugin's converter table has it (44100, 48000, 88200, 96000, 176400, 192000, 384000: as a DAW at that rate), else 48000 and Windows converts |
| Audio | its own thread (the "Pro Audio" scheduling class), the plugin's SSE FTZ / DAZ mode, `juno_gui_process_ex` (the plugin's process()) per 128-sample block; WASAPI shared mode, event-driven; waveOut when WASAPI does not open. A device whose mix rate changes is followed as a DAW does: setActive / setupProcessing / setActive (CLAIMS A28) |
| A patch load while it plays | landed by the audio thread: it renders ahead first (the queue grows by the slowest recent load's block, measured), then queues the load at a block boundary -- the load's slow block (about 7-9 ms on the test machine) cannot empty the queue. The change lands some ms late; the audio does not break (END_GOAL's INVARIANT). Same calls as the test path |
| MIDI in (winmm) | host note events (velocity v / 127), any channel; CC n, aftertouch, pitch bend as the MIDI-mapping parameters base + n / + 128 / + 129 |
| The keybed | the plugin's keyboard control (READ, docs/KEY_HOLD.md rule 10): its layout, its hit test (the point clamped into the control, a gap belongs to the next key), velocity 1016 x (y - top) / height / 7; a press releases every key above 0 first unless KEY HOLD is on and Shift is down; the button up releases the key unless KEY HOLD; the mouse wheel over it moves OCTAVE SHIFT one step (rva 0x2D4420; the plugin also shows the octave for a moment, here while it is not 0). Each send is the plugin's write into its keyboard note value (`juno_gui_keybed_write`, rva 0x2D47E0: a change only; the release at vm.ks.offVel = 64). Keys are drawn from that value (down above 0): what the UI timer drained and the keybed wrote |
| A control | the GUI's model set (rva 0x283DB0 = `juno_gui_model_set`), then the commit every panel control makes (`juno_gui_commit`) |
| A patch | the patch browser's queued load (`juno_gui_queue_patch`, rva 0x335850) and its set of the patch number; the INC / DEC / LOAD buttons (ManagePatch) commit after it, a load from the patch window's list does not (READ, rva 0x322E60 / 0x3278C0). Every factory patch has KEY HOLD 0: the load releases the keys the UI timer has seen (CLAIMS A36) |
| UI timer | every 50 ms the drain (`juno_gui_ui_tick`, rva 0x320120: the notes into the keyboard's value, the CC map's records, then the model's commit), then a redraw of what changed |
| The panel | `gui/skin/skin.js` in C: the same Script.xml walk, sprite frames, conditions and READ rules (CHORUS, key velocity, octave shift) |

OPTION menu: panel, voices 2..8, engine rate, zoom, **audio latency** -- the
queue the program keeps: the lowest the device allows (WASAPI's smallest period,
IAudioClient3, Windows 10; 11 ms where the device has none), 5, 8, 11, 16, **21
(default)**, 32, 43 ms -- and a line naming the output in use (API, rate,
channels, device period, queue). The latency, the zoom and the MIDI input are
kept in `%APPDATA%\JUNO-60\settings.ini`; `--latency N` sets the latency for one
run. The title bar shows "audio drop-outs: N" when the device found the queue
empty (WASAPI: the padding 0 at a device event; waveOut: every buffer played),
and "NO AUDIO OUTPUT DEVICE" when no output opened.

Which setting is safe depends on the computer: a normal block takes about 1 ms
of its 2.67 ms here; a patch load's block 7-9 ms (rendered ahead, see above).
At "lowest" the queue is the device's buffer and cannot grow for a load: a
patch change may click there.

## Tests (no window)

| Mode | What it gives | Graded by |
|---|---|---|
| `--dump-controls FILE` | every control of the original panel: type, value ref, id | equal to the web skin's list (123 rows, same order and ids) |
| `--shot FILE.bmp [--bank B] [--patch N]` | the panel as drawn | equal to the web skin's canvas except text glyphs (GDI vs browser fonts) |
| `--render FILE [--bank B] [--patch N]` | the audio thread's own path on a fixed script, raw float L R; every engine call to FILE.log; the worst block's time | `tools/dist/native_check.py`: the log replayed through `libjuno.so`, equal bit for bit; every block's host events = the queued MIDI in the DAW mapping |
| `--play FILE --seed N [--fp-oracle]` | a seeded performance through the program's own inputs: MIDI through its winmm callback (any channel, note-on at 0 among the releases, mod wheel, bend, aftertouch, the pedal), the keybed through its mouse handlers (clicks, Shift-clicks, drags inside and past the keys), KEY HOLD and OCTAVE SHIFT from the panel, patch changes from the buttons and the list; the 50 ms UI timer every 19 blocks; raw float L R and the call log | `tools/dist/exe_oracle_check.py`: the log played into THE PLUGIN ITSELF (the official .vst3 under Unicorn: its own boot, patch browser, model set and commit, keyboard note value write, UI-timer drain and process()); every sample of both channels equal (`--fp-oracle`: the oracle's DAZ-only FP mode), the magnitude spectra equal; `--tooth`: the plugin side's first MIDI note and first keybed press a semitone up must FAIL (a velocity step was blind on patches without velocity sensitivity) |
| `--kbscript FILE` | panel events, one per line -- the mouse (down / move / up with Shift, the wheel), a control's edit, a patch load (buttons or list), MIDI notes and CCs, an audio block, the UI timer, the CC assign menu's presses and probes, the state -- through the program's own handlers; every engine call to FILE.log | `tools/verify/skin_kb_check.mjs`: the same seeded scripts into the web skin with real pointer events; the same engine calls in the same order (the keyboard rules are READ from the plugin and written twice, in C and in JavaScript); `tools/verify/cc_menu_gate.py`: the CC assign menu's probes and presses against the plugin's own handler on its own tree |

```
WINEPREFIX=<a prefix> python3 tools/dist/native_check.py      # under Wine on Linux
python3 tools/dist/native_check.py --tooth replay | glue | tick   # each must FAIL
```

Window-level smoke test (2026-10-08, Wine + Xvfb + an ALSA null device): a
driver posting real mouse messages into the window (INC / DEC load patches -- the
title names each one after the audio thread lands it --, CHORUS I lights its LED,
a key plays) and reading the audio loop's counters (window properties
`juno.audio`, `juno.blocks`, `juno.dropouts`, `juno.desc`): WASAPI opens at
48000 (period 10 ms) and renders at real time. Under Wine the drop-out count is
NOT meaningful: Wine's ALSA layer takes the whole queue in 20 ms chunks, so the
padding reads 0 at every second event (traced). Real-time behaviour must be
read on a Windows PC: the title bar's count.

The CC assign menu (CLAIMS A38, docs/CC_MENU.md): a right-button press or double click with no
Shift, Ctrl or Alt on a parameter's control pops up "Learn MIDI CC" / "Forget MIDI CC #n"
(`cc_press`, `cc_target`, `cc_menu`); any other right press acts as a left one. Graded by
`tools/verify/cc_menu_gate.py` against THE PLUGIN'S OWN HANDLER (rva 0x31D420) on THE PLUGIN'S OWN
PANEL TREE (built by its module init; the sprite sheets' real sizes): the tree the search reads,
11280 search probes, 1632 right presses with modifier keys and items, CCs and drains, every state;
teeth: builds with `-DCC_TOOTH=N` (make_native.py `--define`). `--play` makes right presses (Learn,
Forget, nothing) and sends CCs 16-19; exe_oracle_check.py replays them in the plugin and compares
the state at the end (getState's bytes); `--render` learns VCF RESONANCE, sends CC 20, forgets.

kbscript lines for the CC assign menu: `rdown X Y MODS ITEM` (a right press, MODS 1 Shift, 2 Ctrl,
8 Alt; ITEM 0 learn, 1 forget, 2 none; not taken: a press the controls take), `ccmsg X Y MODS
[ITEM]` (the same, never a press after it), `ccpick X Y` (the search alone), `cctree` (the tree
it searches), `cc N V` (MIDI CC in), `state` (the state as getState writes it).

## Not ported

The same as gui/skin (README there): writing patches into a bank, the SYSTEM-8 buttons. The LFO LED and the two level meters are ported (CLAIMS
A37, docs/LED_METER.md): the program's WM_TIMER runs the three bridge calls and blits
their result; `--play` and `--kbscript` log every tick (led / meter / bar), which
exe_oracle_check.py replays in the plugin itself.
