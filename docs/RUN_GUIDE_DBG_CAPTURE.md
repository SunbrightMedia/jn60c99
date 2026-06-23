# How to capture the runtime coefficients with IDA's debugger (no Frida)

`tools/extract_runtime_coeffs_dbg.py` reads the 349 runtime-applied coefficients
straight out of the live plugin using **IDA's own debugger** — same data as the
Frida path (`capture_runtime_coeffs.js`), same trust level, but you stay in IDA.
These values are produced at runtime (BBD clock from sample rate + the patch
applied by the parameter system), so a live read is the most accurate possible
source — they are measurements of the shipped plugin, not fitted.

## Steps
1. **Host:** load Cloud 60 in a VST host with the **patch + chorus mode** you want
   to reproduce. Keep audio running (the master `sub_180363380` is called every
   block, even in silence). Wait ~1–2 s after picking the patch so smoothing
   settles.
2. **Attach IDA:** open *this plugin's* database in IDA → **Debugger → Attach to
   process** → pick the host. Choose the local Windows debugger backend. IDA
   rebases the database onto the loaded module, so the script's addresses work
   as-is.
3. **Run:** **File → Script file… → `extract_runtime_coeffs_dbg.py`**.
4. It sets a breakpoint at the master, verifies it's reading the real engine
   state, takes a few spaced snapshots, and prints a C table (also written to
   `runtime_coeffs_capture.txt` next to the database).
5. **Paste** the `static const juno_coeff k[] = { … };` block over the placeholder
   in `src/runtime_coeffs_data.c`.

## What the self-checks guarantee
- **Base check:** the script confirms the engine-state pointer exposes fields we
  set statically (`state[2199956]==0x80000`, `[95828]/[101028]==1024`). If they
  don't match it aborts — you're reading the wrong object, not real coefficients.
- **Invariance:** it snapshots the 349 offsets several times across blocks; any
  offset that changes is per-sample **state**, not a coefficient, and is emitted
  as `0` (not applied). A clean run reports "all 349 time-invariant".
- After pasting, eyeball values against `docs/COEFF_PARAM_MAP.md` (on/off slots =
  0/1, "Part Tune" centred, …). The final arbiter is the sample-accurate A/B of
  the port vs the plugin.

## Notes
- The breakpoint fires every audio block, so the capture briefly glitches host
  audio — harmless; coefficients don't depend on audio continuity.
- No MIDI note is needed for the coefficients (they come from the patch, not the
  note); playing one doesn't hurt.
- If the automated continue/wait loop misbehaves in your setup, use **MANUAL
  MODE** at the bottom of the script (set the breakpoint yourself, then read once
  from the Python console — single snapshot, no invariance check).
- Capture at the sample rate you run the port at (44100 default); BBD-clock
  coefficients depend on it.
