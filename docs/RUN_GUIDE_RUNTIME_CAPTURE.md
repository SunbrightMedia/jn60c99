# How to capture the runtime coefficients (Frida) — `capture_runtime_coeffs.js`

## Why a runtime capture (not another static dump)
The DSP (`voice_render` + the master `sub_180363380`) reads **349** coefficient
offsets that **no static initializer writes** — verified by diffing every read
against every write across `voice_render.c`, `master_render.c`, `juno_init.c`
(sub_1803990C0) and `chorus_init.c` (sub_1803A1300). We traced the source:
- `sub_180388170` is the **parameter registry** — it registers ~1121 parameters,
  each via `lea rax,[rdi+slot]` (the coefficient address) + a default, calling the
  registrar `sub_1803ABA00`. It writes **no floats** to the audio state itself.
- So these values are **applied at runtime** when default/preset parameters are
  set, several through a param→curve mapping.

107 of the 349 are voice-region (the **patch**: osc levels, cutoff, envelopes,
mix); 242 are chorus/master-region (BBD clock, LFO, mix, output saturator).
Without them the engine is silent (no patch) — `voice_render` produces 0 even with
the note-on gate set, because osc level / VCA env / etc. are 0.

Capturing them for one patch is the faithful, non-fitted way to get a **playable**
engine: these are measurements of the shipped plugin, exactly the runtime-only
case the handoff sanctions Frida for.

## Steps (Windows, plugin in a host)
1. Load **Cloud 60** on a track. Choose the **patch + chorus mode** you want to
   reproduce (the values are patch-specific). Let audio run ~1s.
2. Set `MODULE` in `tools/capture_runtime_coeffs.js` to the plugin binary name if
   it isn't auto-found (it lists loaded modules if not).
3. `frida -n <host.exe> -l tools/capture_runtime_coeffs.js` (or `-p <pid>`).
4. After ~200 audio blocks it reads the 349 offsets off the engine-state pointer
   (arg0) and prints a C table.
5. **Paste the printed `static const juno_coeff k[] = { … };` block** over the
   placeholder in `src/runtime_coeffs_data.c`.

`juno_runtime_coeffs_apply()` is already wired into the init sequence and the
driver gates on `juno_runtime_coeffs_loaded()`, so the next build is playable:
a note sounds and (if the captured patch had chorus on) the chorus is live.

## Built-in self-validation
The script now (a) confirms `arg0` is the engine state by checking known static
fields (`state[2199956]==0x80000`, `[95828]/[101028]==1024`) — if this fails the
capture is aborted (wrong pointer); (b) snapshots the 349 offsets twice and flags
any that change as per-sample STATE (emitted as 0, not applied), leaving only
time-invariant coefficients. Play a **sustained** note so the two snapshots are
during steady audio. After pasting, also eyeball values against
`docs/COEFF_PARAM_MAP.md` (on/off slots = 0/1, etc.).

## Verifying after paste
`make test` should still pass (finite). `test_master_smoke` will report
`path: full master/chorus`. Set the driver's `chorus_mode`
(`juno_driver_attach_host`) to the captured mode (0=off,1=I,2=II,5=…).

## Notes
- **Polyphony:** these are voice-0 offsets. The same patch values apply to voices
  1–7 at their strided copies (main +10512) once per-voice rendering exists.
- **Sample rate:** BBD-clock coefficients depend on rate; capture at the rate you
  run (44100 default), or capture per rate and key the table.
- **State vs coefficient:** the 349 are read-but-never-written-by-any-DSP-function,
  so they are genuine applied coefficients, not per-sample state. Capturing after
  settling avoids any transient.
