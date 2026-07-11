# Per-parameter setter — "raw 0..255 byte → parameter"

The final port needs a simple interface: *a panel value (0..255) goes in, the engine
coefficient changes* — the same thing the plugin does when you turn a knob or recall a
patch. That interface is now exposed, and it is **bit-for-bit the plugin's own
value-tree recall dispatch**, driven one parameter at a time.

## Why this is exact, not an approximation

`juno_bank_apply` (the full patch recall) walks a table of `BINDINGS` in
`src/juno_apply.c`. Each binding is one panel parameter:

```
{ blob_pos, curve_id, transform, offset }
```

and recall does, for the raw byte at `blob_pos`:

```
JF(state, offset) = juno_curve(curve_id, transform(byte))   // + rate-variant arm
```

The per-parameter setter runs *that exact line* for a single binding. So feeding the
setter the byte a bank record would hold for a parameter produces the identical engine
float the full recall produces. `tests/test_param_setter.c` proves this: for every
exposed parameter, at 44.1/48/96 kHz, the byte that reproduces the full-recall cell
exists, is stable, and writes the engine offset — 25 params × 3 rates, bit-exact.

## C API (`src/juno_apply.h`)

```c
int         juno_param_count(void);                 // # exposed panel parameters
const char *juno_param_name(int i);                 // human name ("" if out of range)
int         juno_param_offset(int i);               // engine state offset (-1 if oob)
float       juno_apply_param(unsigned char *state,  // apply raw byte 0..255 to param i
                             int i, int byte, int Hr); //   at host rate Hr; returns float
```

`juno_apply_param` writes voice-0's cell only. After a batch of edits, replicate voice 0
to the other seven voices (`juno_driver_seed_voices`) and re-apply the CONDITION scatter.

## Browser / WASM API (`gui/juno_bridge.c`, exported in `gui/web/build.sh`)

```c
int         juno_gui_param_count(void);
const char *juno_gui_param_name(int i);
int         juno_gui_param_offset(int i);
float       juno_gui_set_param(juno_ctx *c, int param_index, int byte);  // 0..255 in
```

`juno_gui_set_param` is the whole interface: it applies the raw byte through the recall
dispatch **and** makes it audible on all 8 voices immediately (seed voice 0 → all, then
restore the current CONDITION analog scatter — exactly what a bank recall does). It reads
the host rate from the engine (`state[16]`) so the SR-variant curves stay correct.

From JS:

```js
const count   = M.cwrap("juno_gui_param_count","number",[])();
const name    = M.cwrap("juno_gui_param_name","string",["number"]);
const setParam = M.cwrap("juno_gui_set_param","number",["number","number","number"]);
// turn "VCF CUTOFF FREQ" to halfway:
setParam(ctx, 0, 128);        // -> 0.50196 (curve 22 at byte 128)
```

## Current coverage

The 25 exposed parameters are the single-byte panel knobs the recall binds directly:
VCF cutoff/resonance/HPF/key-follow/env-mod, both ADSRs, DCO PWM/saw/sub/noise levels,
VCA level/tone, portamento, tempo-sync. Multi-byte / structural parameters (the FX
routing recalled by `delay_recall.c` / `chorus_recall.c` / `effect_modes.c`, bend/mod
sensitivity, voice-assign, arp) are driven by patch recall today; extending the
single-byte setter to them is straightforward follow-up (each has the same
byte → dispatch → cell shape) but was out of scope for this pass.
