# JUNO-60 C99 — VST3 wrapper

This directory is the **Steinberg VST3 binding** around the bit-exact JUNO-60
C99 engine in `../src`. The engine is self-contained and needs nothing external;
this layer adds only the plugin glue.

## Files

| File | Role |
|------|------|
| `juno_ids.h`         | Component/controller UIDs + parameter ids. |
| `juno_processor.*`   | `IAudioProcessor`: host SR, MIDI events → note on/off, param changes, audio render, state save/load. Wraps `juno_synth`. |
| `juno_controller.*`  | `IEditController`: exposes the panel params (from `refs/juno_param_map.h`) + a 64-slot program list to the host. |
| `juno_factory.cpp`   | Module entry point + plugin factory (instrument class). |
| `CMakeLists.txt`     | Builds the engine + wrapper into `JUNO60_C99.vst3`. |

## Build

The only external dependency is the **Steinberg VST3 SDK** (not vendored here):

```sh
cmake -B build -DVST3_SDK_DIR=/path/to/vst3sdk
cmake --build build --config Release
```

Output: `JUNO60_C99.vst3`. The build compiles the engine **capture-free**
(`runtime_coeffs_data.c` is excluded — the product seeds from
`juno_capture_free_seed()`).

## Factory bank

The wrapper loads factory patches from a bank file. Point it at the bank with the
`JUNO_FACTORY_BANK` environment variable, or `-DJUNO_FACTORY_BANK="..."` at build
time; ship `refs/preset_banks/bank1.bin` in the plugin bundle's `Resources` for a
self-contained install. Program changes (0–63) select the record within it.

## Validation

The engine-facing contract this wrapper relies on is exercised end-to-end without
the SDK by `/tmp`-style harnesses in the repo history: `juno_synth_create_sr(44100)`
→ `juno_synth_load_preset` → `juno_synth_note_on/off` → `juno_synth_process`
renders non-silent stereo audio at the host sample rate with the capture file
absent. What still requires an SDK-present environment is the final compile/link
of the VST3 objects and a load test in a DAW / the SDK validator.

## Note on identity

The UIDs in `juno_ids.h` are freshly generated for this independent
reimplementation. They intentionally do **not** reuse the original Roland product's
class IDs — this is a clean-room C99 port, not a drop-in impersonation.
