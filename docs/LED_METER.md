# LED_METER.md -- the LFO LED and the level meters (CLAIMS A37)

The plugin's panel has an LFO-rate LED (Script.xml `lfoLed`, `vm.vs.dm`, in the open one of
`origLfoRateTsOff` / `origLfoRateTsOn`) and two output meters (`barGraphX` L / R, `ch` 0 / 1,
in `functionUpperOrig`). Both are fed by the engine and read by the GUI. Read 2026-10-09 from
the binary (the decompilation and the disassembly), then graded by
`tools/verify/led_meter_gate.py`, which runs the plugin's own functions.

## The engine side

| # | Rule | Label | Where |
|---|---|---|---|
| 1 | The engine object holds the LED's store at +1040: `last` (float), `sum` (float), `period`, `since`, `nread`, `nacc`, `toggle` (int32); its constructor zeroes all seven | READ, EXECUTED (part 2: the store after every read) | rva 0x3C5A50 |
| 2 | Voice unit 0's render thread, after each of its samples, calls the engine's vt+104 (rva 0x3C7230): under the engine's lock at +40, the store's add of unit 0's parameter entry 29 -- the value's bits (rva 0x3C10B0: entry type <= 1), voice 0's cell 2528, the LFO's square (cell 1824: -1, +-0 or 1) | READ (rva 0x3C6F00: `if (!a2) vt+104`), EXECUTED (the cell = what the add stores, every read) | rva 0x3C6F00, 0x3C7230 |
| 3 | The add (rva 0x324A30): when the value differs from `last` (both ordered: ucomiss / je) and is >= 0 (comiss / jb), `period = since`, `since = 0`; then `sum = v + sum`, `since`, `nread`, `nacc` each + 1, `last = v` | EXECUTED (part 1) | rva 0x324A30 |
| 4 | The read (rva 0x324980, with lo -1, hi 1): `nread` to 0; if `period >= 4 x nread` (32-bit) the mean `sum / nacc` since the last such read (then both 0; 0 when `nacc` is 0); else `hi` and, every second read, `((9600 - period) hi + period lo) x 0x38DA740E` (1/9600); the result `(x - lo) / (hi - lo)` | EXECUTED (part 1) | rva 0x324980 |
| 5 | The engine render (rva 0x3C7400) ends with the peak of the call's samples per channel: groups of four while four remain (maxss / comiss in the plugin's order), then one at a time; merged into +32 / +36 under the lock at +16 (left: `max(call, held)`, right: `max(held, call)`, maxss operand order) | EXECUTED (part 1: NaN payloads, infinities, denormals; part 2) | rva 0x3C787B..0x3C798A |
| 6 | A meter's read (the engine's vt+72, rva 0x34AF70): the held peak of channel `ch`, then 0 | EXECUTED | rva 0x34AF70 |
| 7 | The period the store keeps at boot is the start-up mute's: the unit's first rendered sample (960) changes the square once. With LFO RATE 0 (patches 2, 28, 31, 47, 48, 58) the square never moves again, so the read alternates 1.0 and 0.9 forever -- the plugin's own LED flickers between frames 23 and 20 | EXECUTED (part 2 chain slow48: the plugin itself) | -- |

## The GUI side (each control at every tick of the 50 ms window timer)

The window's WM_TIMER (SetTimer 50 ms, rva 0x310210 / 0x311750) sends `GT::CTimerInfo` through
the control tree (slot +96 of each open control). A control in a closed panel does not exist.

| # | Rule | Label | Where |
|---|---|---|---|
| 8 | The LED (rva 0x324FF0 -> 0x325070): the read (rule 4), then frame `cvttss2si((float)(nframes - 1) x v)`, below 0 -> 0, above nframes - 1 -> nframes - 1 (24 frames: `lfoLedRed.png`); redrawn if the frame changed | EXECUTED (part 1, the read and the frame) | rva 0x325070 |
| 9 | A meter (rva 0x31C450): its read (rule 6); the peak clamped to [0.001f, 1.0f] (float compares; NaN -> the floor) as a double; `1000 x (int)(log10(p) x 333 + 999)`; with decay > 0 at least `state - 500000 / decay` (Script.xml decay 8: 62500 a tick), never below 0; the new state; the bar's fill of `state / 1000` of 999 (rva 0x2C9A10: horizontal `x0 + v (x1 - x0) / 999`) | EXECUTED (part 1, the segment from after the base handler) | rva 0x31C450, 0x2C9A10 |
| 10 | log10 is the MSVC CRT's (rva 0x6D2660), statically linked, with an FMA3 path taken when the CRT's flag is set (a CPU with FMA3). The port uses the C library's. Every float next to each of the 998 dB steps lies at least 6.47e-9 from it (exact, 60 digits): any log10 within 1e-12 gives the same step | EXECUTED (the SSE2 path), PROVEN (the margin: part 1) | rva 0x6D2660 |
| 11 | A meter draws (rva 0x31C210, horizontal): of the fill's width w, `n = min(control width - w, min(fade, w))` columns fade; the first `w - n` columns are one plain blit from the bitmap's left edge at the fill's corner, then column k at alpha `255 - 255 (k + 1) / fade` from the bitmap's column `w - n + k` | EXECUTED (part 1, a blitter whose slots record) | rva 0x31C210 |
| 12 | Script.xml `direction` 1 is horizontal (the parser: byte = direction != 0, "must be 0 or 1"); a meter's object is zeroed at creation (state 0) | READ | rva 0x2C9E60, 0x34FA60 |
| 13 | An LED shown or hidden runs its update (vt+0xB0 = rva 0x325070: the read, rule 4, and the frame, rule 8) -- not only at a tick. The editor's attach shows every open control (one read); at the model's notify (rva 0x2853C0) the panels whose open conditions read a value in the change list open or close (rva 0x2C4890: show vt+0xA0, hide vt+0xA8, both through rva 0x2C4B20), the controls in tree order: a TEMPO SYNC or panel-mode flip reads twice (the LED hidden, then the other shown). A patch load puts TEMPO SYNC in the change list even when its value is the same; a commit without a notify (initialize's load) leaves the panels as they were. The tick reads only a shown LED (rva 0x324FF0) | EXECUTED (the plugin's editor attached under emulation, 2026-10-09: the reads counted per call, `scratchpad` probes) | rva 0x2C4890, 0x2C4B20, 0x325070 |

## The port

- `gui/juno_bridge.c`: the store (`dm_add`, `dm_read`) fed after every engine sample from
  `JF(st, 2528)`; the render call's peak (`pk_begin` / `pk_sample` / `pk_end`) around each engine
  render call (the identity's segment, the converter's request); the reads `juno_gui_lfo_led`,
  `juno_gui_peak`; the GUI's three calls: `juno_gui_lfo_led_frame`, `juno_gui_meter_tick`,
  `juno_gui_bar_draw` (the blits in order). Integer steps wrap as the plugin's 32-bit ones.
- `gui/skin/skin.js`, `gui/win/juno60_win.c`: every UI-timer tick runs the three calls for the shown
  LED and both meters and draws what they return; nothing else is computed in the apps but the
  pixels of a blit at an alpha (the renderer's, as for every other control). Rule 13: after each
  notify the apps' model calls make (a commit's trio, a keyboard write, the patch manager's notify)
  and at the editor's open (after IComponent::initialize's load), each LED whose visibility changed
  runs `juno_gui_lfo_led_frame` (`led_shows` / `ledShows`; logged `ledshow NFRAMES FRAME`).

## Graded

`tools/verify/led_meter_gate.py` (in `make verify`; plumbing in `tools/verify/meter_emu.py`):
part 1, the plugin's functions on seeded and edge inputs (48 store sequences, 1200 render tails,
1500 LED reads, 13052 meter ticks incl. every float next to every dB step, 1500 draws), in plain
IEEE mode on both sides; part 2, 8 chains in the running plugin (its own voice thread's add and
render tail around the e2e composition) at 44100 / 48000 / 96000, fast and slow LFOs, reads every
block and every 50 ms, silence and loud chords, patch changes, a host-rate change, a DAW state with
the voice count at 1: every read's LED value, both peaks, the whole store and the held peaks after
it, and every sample. Teeth (`-DLM_TOOTH=n`), each must fail: see the gate. The tooth "the LED fed
voice 1's square" did not bite on the first seven chains: every voice's LFO runs in lockstep, so
voice 1's square is voice 0's whenever unit 1 renders -- always with the setting's 2..8 voices. A
DAW state can carry a count of 1 (the plugin takes it: the chain is bit-exact), and then only unit 0
renders; the chain voices1 holds that case (playbook 122).
`tools/verify/wasm_product_gate.py`: every tick after every render of the app's own flows,
native vs the WASM. `tools/dist/exe_oracle_check.py`: JUNO-60.exe's logged ticks replayed in the
plugin (its reads, frame, tick and draw), every value equal; since rule 13 the plugin's editor is
attached there too (`editor` line), its own LED updates at its notifies are hooked (the frame stores
rva 0x32510E / 0x325124 outside the replayed ticks) and each must equal the program's `ledshow`, in
order, none left over (8 seeds: 16 shows EQUAL; tooth `EXE_TOOTH=1`, no update at a hide, bites on 3
of 8 seeds). `tools/verify/skin_kb_check.mjs`: the page's `ledshow` lines equal the program's.

## Limits (stated)

- The emulator's SSE under DAZ: its maxss returns a denormal operand's own bits where the CPU
  returns the zero DAZ makes of it (MEASURED 2026-10-09, playbook 166). Part 1 therefore runs in
  plain IEEE mode, where the two agree. In the product the engine's samples are never denormal
  on x86 (FTZ); in the WASM (no FTZ) a denormal sample can reach the peak, where it reads as a
  tiny positive instead of 0 -- the meter's floor (rule 9) draws the same bar.
- The tick's timing: the plugin's timer runs on its window thread, the engine on the audio
  threads, so the samples between two reads depend on scheduling; the apps read every 50 ms.
  Equal at equal read points (part 2).
- Not modeled: the base handlers' early returns while a control is dragged (rva 0x2C47F0,
  0x2CFCF0: the drag tracker's state) -- the LED and the meters take no drag; the window
  closed (no reads: the store accumulates).
- A vertical bar is not drawn by the apps (`juno_gui_bar_draw` returns 0): no Script.xml
  `barGraphX` is vertical. Its fill (rule 9) is ported and graded.
