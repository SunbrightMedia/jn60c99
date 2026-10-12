# JUPITER-8 — THE NATIVE ORACLE (scope row 23, and a fast grader)

The real plugin DLL (`jp8/truth/JUPITER-8VST3_64bit.vst3`, checked against `SHA256SUMS`) in a real Windows process
under wine, driven by a minimal VST3 host in C (`jp8/tools/native/jp8_native_host.c`, mingw). A CPU executes the
plugin's own machine code: no emulator between them.

## Why a second oracle

The Unicorn oracle (`jp8_host_emu.py`) is the project's ground truth runner, but Unicorn 2.1.4 never flushes a
denormal RESULT (FTZ) — PROVEN by `jp8/tools/jp8_unicorn_fp_probe.py` — while the plugin runs `process()` at MXCSR
FTZ + DAZ (its ScopedNoDenormals). A PC flushes. The native oracle runs the PC's semantics; the port's x86-64 build
runs the guest's MXCSR on the real CPU, so the two must agree word for word.

It is also FAST: the render check's 5.6 s of audio boots and plays in ~6.5 s (Unicorn: ~7 min per replay).

## The harness (plumbing only)

`jp8_native_host.c` boots the plugin as `jp8_host_emu.JP8Host.boot_host` does: `LoadLibrary` (DllMain), `InitDll`,
the factory's processor and controller, both `initialize`d with an `IHostApplication`, both `IConnectionPoint`s
connected, a component handler, the component's `getState` handed to the controller's `setComponentState`; then
`setupProcessing` (rate, maximum block 512 as `jp8_render`'s `jp8h_init`) and `setActive(1)`; the factory patch through
the plugin's own patch load (rva 0x355F90, as `wrapper_emu.load_patch`); then a PLAN replayed through `process()`:

| line | meaning |
|---|---|
| `B n` | a block of n samples (the lines up to the next `B` are its input) |
| `E on offset channel pitch vel-bits` | a note event (the 48-byte VST3 Event as `jp8_host.c` builds it) |
| `P id offset value-bits` | a parameter queue point (queues grouped by id, first seen first, as `jp8_host.c`) |
| `C state ppq tempo cycle-start cycle-end` | the block's ProcessContext (state, the host rate, ppq, cycle, tempo) |

Every host object answers as the Unicorn oracle's do (`probes/b6/wrapper_emu.py`, `host_process_emu.py`).
`jp8_native_check.py` lays the module out where the oracle's MODPATH puts it, in a private wine prefix: the DLL and
the Script files from truth/, the oracle's own stub panel file and its 76 blank skin images (sized by its own sizer;
without them `IComponent::initialize` returns 0x8000FFFF), the data and user folders emptied before every run (the
plugin writes `InstalledBankNames.dat`). The layout is recorded with checksums (`layout.json`).

## Controls and teeth (mantra 5)

* CONTROL: on the render check's plan (patch 2, 48000), the native output equals the CLI's WAV, which the Unicorn
  oracle's replay equals (`jp8/apps/render_check.sh`): the native harness agrees with the proven path. PROVEN.
* DETERMINISM: two native runs give the same bytes. PROVEN.
* TOOTH N1: one bit of the WAV flipped -> 1 frame differs. TOOTH N2: the port built with the host gate's T1 slip
  (one `addss` of the FINE TUNE setter turned `subss`) -> 266,518 of 267,001 frames differ. Both PROVEN.
* `jp8_plan_replay` (the port's side of a plan) equals the native run on the render check's plan. PROVEN.

## Results

See `jp8/docs/SCOPE_AUDIT.md` rows 5, 6, 20 and 23 for the current runs (the sweep `native_check.sh full`: the 64
factory patches at 48000, 44100 and 96000; the reach scan and the fuzz).

## FTZ: what the oracle's gap can hide (row 23)

`ftz_probe.sh` builds the render CLI with software floats and a counter (`ftz_probe_src.py`): every denormal result
made while the guest's FTZ bit is set. MEASURED (patch 2, a six-note chord, 48000): 1,069,551 such results in 6 s of
audio, the first in block 0; 7,351,781 in 32 s. Yet the PC's rules (flush) and the oracle's (keep) give the same
output words and the same 280 MB of image + heap after the drive: every one is read as zero under DAZ inside
`process()` or overwritten. The host gate grades the PC's rules (`JP8_SOFTFP=2`) against the oracle with the memory
and the stack at every graded step: EXACTLY 0. So on every graded drive the flush is UNOBSERVABLE and the oracle's
missing FTZ hides nothing. The earlier text ("no graded drive makes a denormal result") was never measured, and false.

## Running it

    sh jp8/tools/native/native_check.sh full                 # 64 patches x 3 rates, determinism, N1, N2
    python3 jp8/tools/native/jp8_native_check.py <patch> <plan> <wav> [rate]
    sh jp8/tools/native/ftz_probe.sh <patch> <in.mid> [rate] [tail]
    python3 jp8/tools/native/jp8_reach_scan.py <replay> <seed> <cases> [--one-id] [--ids panel|midi]
    python3 jp8/tools/native/jp8_native_fuzz.py <replay> <seed> <cases> [--control] [--tooth <slipped replay>]

Needs wine64 (or `JP8_WINE`) and x86_64-w64-mingw32-gcc (or `JP8_MINGW`).
