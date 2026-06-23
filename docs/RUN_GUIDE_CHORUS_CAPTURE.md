# How to capture the chorus coefficients (Frida) — `capture_chorus_coeffs.js`

## Why this is a runtime capture, not another static dump
The master (`sub_180363380`) reads **241** coefficient offsets that *no* static
initializer writes. We chased the source and confirmed:
- `sub_1803990C0` (voice init) — doesn't write them.
- `sub_1803A1300` (chorus constructor, now ported as `juno_chorus_init`) — sets
  the integer delay-line lengths/indices and zeros buffers, but **no floats**.
- `sub_180388170` — is the **parameter registry**: it registers ~1121 parameters,
  each via `lea rax,[rdi+offset]` (the coefficient slot) + a default, calling the
  registrar `sub_1803ABA00`. It writes **zero** floats to the audio state itself.

So the values are **applied at runtime** by the parameter system when defaults/
presets are set, and several pass through a param→curve mapping. The faithful,
non-fitted way to get them is to **read them out of the live plugin**. These are
measurements of the shipped binary — exactly the runtime-only case the handoff
sanctions Frida for.

## Steps (Windows, plugin in a host)
1. Load **Cloud 60** on a track in Ableton (or any host). Set the **chorus to the
   mode you want** (start with the default; capture each mode separately if you
   want full coverage — the coefficients differ per mode). Let audio run ~1s.
2. Edit `tools/capture_chorus_coeffs.js` and set `MODULE` to the plugin binary
   name if it isn't auto-found (it will list loaded modules if not).
3. Run: `frida -n <host.exe> -l tools/capture_chorus_coeffs.js` (or `-p <pid>`).
4. It hooks the master process, waits ~200 audio blocks (so smoothing settles),
   reads the 241 offsets off the engine-state pointer (arg0), and prints a C
   table.
5. **Copy the printed `static const juno_coeff k[] = { … };` block** and paste it
   over the placeholder array in `src/chorus_coeffs_data.c`.

That's it — `juno_chorus_coeffs_apply()` is already wired into the init sequence,
so the next build runs the chorus with the plugin's exact coefficients.

## Verifying
After pasting, `make test` should still pass (finite), and the master smoke test
will now show non-trivial output. If you captured a specific chorus mode, set the
driver's `chorus_mode` (in `juno_driver_attach_host`) to match (JUNO modes:
0 = off, 1 = I, 2 = II, others = I+II / mode 5 per the master's `v39` switch).

## Sample-rate note
Some coefficients (BBD clock) depend on sample rate. Capture at the rate you run
the port at (44100 by default). If you need multiple rates, capture each and key
the table by rate.
