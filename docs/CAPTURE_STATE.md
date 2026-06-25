# The one capture that makes the port sound right

## Why this exists
The port runs **faithful DSP code** (audited) but on an **incomplete coefficient
state**. The plugin computes its coefficient values at runtime by walking the
parameter DB through a binding that exists **only in live memory** — proven three ways
to be unrecoverable from the static binary (`docs/STATE_AUDIT.md`,
`docs/DB_ENGINE_BRIDGE.md`). So ~5–20 internal/calibration coefficients (filter tune,
precise init levels, the pulse-osc level) cannot be derived statically.

A **single memory capture** of the running plugin's engine state reads those numbers
from the plugin's *own* ground truth. It is not fitting and not guessing — it's the
plugin's data, exactly like `Script.xml` and the preset bank. Done once per patch
(and once for the INIT patch as a reusable base, since the calibration constants are
patch-independent), it gives a complete, consistent coefficient state. `Script.xml`
preset-overrides + the faithful DSP then handle everything else.

## What to capture
Best value, in order:
1. **INIT patch** (a freshly-initialized/default patch) — the reusable base; its
   calibration constants apply to every preset.
2. **SQ Dynamic ARPG** (or any preset you want to hear exactly).

## How (≈5 minutes, Windows)
1. Install Frida: `pip install frida-tools` (or `npm i -g frida`).
2. Load the JUNO-60 / Cloud 60 plugin in any VST3 host (your DAW, or a small host like
   Carla / the Steinberg VST3 validator). Select the patch. Play & hold a note.
3. Find the host process name (Task Manager) or use `frida-ps`.
4. Run:
   ```
   frida -n <YourHost.exe> -l tools/capture_state.js
   ```
   (If it can't auto-detect the plugin module, set `MODULE_NAME` at the top of
   `capture_state.js` — list modules with `Process.enumerateModules()` in the Frida
   REPL and pick the Cloud 60 / System-8 / Roland one.)
5. It writes `juno_state_<base>.bin` and prints the path. Send that file back.

The dump is the engine state base (the `a1` pointer of `master_render`, rva 0x363380)
for 11 MB — the full CJu60Sim workspace, covering the voice, aux, and chorus
coefficient regions. Coefficients are stable per-sample, so the early-but-warm dump is
exact for them.

## What I do with it
```
python3 tools/parse_state.py juno_state_<base>.bin --name init     # or --name sqarpg
```
→ emits `src/captured_state_<name>.c` with `juno_load_captured_<name>(state)` that
writes every captured coefficient. The render then becomes:
`engine_init` + `chorus_init` → `juno_load_captured_init` (consistent base) →
Script.xml preset-overrides → faithful DSP. It also prints the 5 smoking-gun offsets
(4208 / 7600 / 7616 / 4064 / 4080) so we can confirm they're now their real values.

## Note on faithfulness
This keeps the port faithful: every number comes from the plugin (decompiled code +
Script.xml + preset bank + this one runtime read). The capture is load-bearing because
the static binary genuinely does not contain the per-patch coefficient values — only
the code and tables that *produce* them at runtime.
