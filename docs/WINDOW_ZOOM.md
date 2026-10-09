# WINDOW_ZOOM.md -- a window's zoom: the fit to the screen (CLAIMS A40)

The plugin's panels with a window of their own -- the main panel (`vm.vs.mainZoom`) and the patch
window (`vm.vs.patchZoom`, Script.xml `zoomValueRef`) -- read their zoom through one getter, and the
getter keeps the zoom inside the screen. Found 2026-10-09 by `tools/dist/exe_oracle_check.py`: with the
patch window opened, the plugin's DAW state held patchZoom 65519 where JUNO-60.exe held 62. Read from
the binary, then graded by `tools/verify/zoom_fit_gate.py`, which runs the plugin's own code.

## Rules

| # | Rule | Label | Where |
|---|---|---|---|
| 1 | The getter: the window's zoom value (vt+0xD8 of the window with its value id, +0x138), at most the window's fit (vt+0x120), and the value SET to that (the value object's own set, vt+0x70: no model commit) | READ, EXECUTED | rva 0x2AA590 |
| 2 | Every coordinate conversion of the window calls the getter -- a draw, an invalidation, a hit test (nine call sites) | READ | rva 0x2AC0F0..0x2AC55E |
| 3 | The fit: `min((cy - 120) * 100 / h, (cx - 40) * 100 / w)` for the virtual screen cx x cy (GetSystemMetrics 78, 79) and the panel's rectangle w x h (its Script.xml size: main 1924 x 740, patch 1690 x 696), each an integer division (idiv) | READ, EXECUTED | rva 0x312750 (slot 36 of the window, vtable rva 0x9490E8) |
| 4 | The window keeps the first positive fit (+0x13C) for its life; a non-positive one is computed again at the next call. The patch window lives across its closes and opens | EXECUTED | rva 0x312756 |
| 5 | The editor's attach (IPlugView::attached) lays the main window out: mainZoom clamped then. The patch window's open (vm.vs.panelPatch 1, the notify) lays it out: patchZoom clamped then, and the main window converts too (its PATCH button redraws). A zoom set alone converts nothing (no message loop under emulation; a real window then redraws -- rule 2) | EXECUTED | -- |
| 6 | No lower bound: a fit below 25 is set as it is (an empty screen, as the emulator's GetSystemMetrics 0 gave: -17, stored as 65519 in the 16-bit value) | EXECUTED | -- |

On a 1920 x 1080 screen the fits are 97 (main) and 111 (patch): the default 62 never changes. A
1024 x 768 screen (Wine's default) gives 51 and 58; a zoom picked above the fit comes back to it.

## The port

- `gui/juno_bridge.c`: `juno_gui_zoom_fit(cx, cy, w, h)` (rule 3) and `juno_gui_zoom_get(value, cx, cy,
  w, h, &cache)` (rules 1, 4: one cache per window, the app's).
- `gui/win/juno60_win.c`: `zoom_conv(win)` at the editor's open (after IComponent::initialize's load, as
  a host opens the editor after initialize), at every zoom set (`zoom_apply`: the window resizes), at
  the patch window's open (both windows) and at every draw; the screen is GetSystemMetrics 78 / 79;
  a set is logged `zoomfit WIN VALUE`, the open `editor CX CY`.
- `gui/skin/skin.js`: `zoomConv(win)` at the same points; the screen is the page's (`window.screen`,
  the browser's analog of the virtual screen).

## Graded

- `tools/verify/zoom_fit_gate.py` (in `make verify`): 16 scenarios -- screens from none to 3840 x 2160,
  portrait, two monitors, odd sizes, and screens that change under a running editor -- through the
  plugin booted as a host boots it with GetSystemMetrics answered (`probes/b6/wrapper_emu.py`
  `screen`), its editor opened (`host_process_emu.attach_editor`: createView, attached), its zooms
  set and its windows' own getter called (`window_conv`), the patch window opened, closed and opened
  again; every fit it computes (computed or kept) and mainZoom / patchZoom after every step, against
  the port's two calls replaying the same conversions: 278 steps, 2688 fits, EQUAL. Teeth
  (`-DZF_TOOTH=n`): 1 the margins exchanged, 2 the larger fit, 3 the fits rounded, 4 no fit kept --
  all bite.
- `tools/dist/exe_oracle_check.py`: the program's editor opens on its own screen in the plugin too
  (`editor CX CY`: the screen answered, the plugin's editor attached); at each `zoomfit` the plugin's
  own getter converts its window and must read the program's value; the end state (getState, both
  zooms in it) must be equal. Tooth `EXE_TOOTH=2` (no conversion at the patch window's open) bites.
- `tools/verify/skin_kb_check.mjs`: the page on the program's screen (read from the program's log)
  logs the same `zoomfit` lines at the same calls as JUNO-60.exe.

## Limits (stated)

- Rule 5's "a real window redraws after a zoom set": READ (rule 2), not executed -- the emulator runs
  no message loop. The apps convert at once after a set; the plugin at its next draw. The values meet
  at the first draw.
- The page's screen is the browser's `window.screen` (CSS pixels of the current monitor), not the
  virtual screen of all monitors (a browser cannot read it).
