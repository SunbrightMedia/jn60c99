# Sound test — the decisive diagnosis (this session)

The goal was an audible note. This documents what we proved, with hard numbers,
and why an audible note needs one more transcribed subsystem (the control-layer
ramp/envelope + LFO engine), not a tweak.

## What we built
`make sound` (`tests/sound_test.c`) loads the **live plugin's captured 12 MB engine
state** (`state_dump/state_t0.bin`, PD The Juno Pad, 96 kHz) and runs our exact
DSP forward from it — dry voice 0 and the full master/chorus path — writing WAVs
and reporting peak/RMS. This is also the per-sample processing check
docs/VALIDATION.md flagged as missing: it exercises voice_render + master_render
on genuine live state, not a reset engine.

## What we found (decisive)

**The captured state is a SILENT instant of the plugin.** Measured directly from
the dump:

| slot | meaning | value |
|---|---|---|
| 101264 / 101280 | master output L / R | **0 / 0** |
| 10672 (+v·10512) | per-voice output, all 8 voices | ~1e-38 ≈ 0 |
| 9856 | voice 0 VCA env | 0.99999 (open) |
| 4928 | voice 0 osc/wave mix | ±0.99 (DCO free-running) |
| 9040 | voice 0 filter input | small, but nonzero |

So at capture the DCO was free-running (JUNO DCOs always oscillate) but the final
output was **zero** — nothing was actually sounding (note released, or the capture
caught a silent moment). Our port **reproduces this faithfully**: running forward
96 000 samples from the dump, the output stays at the denormal floor (~−720 dBFS),
exactly matching the plugin's silent state.

**A fresh init behaves the same**, and that pinned the cause. With `juno_chorus_init
+ juno_engine_init + juno_runtime_coeffs_apply` and the documented note-on edge set,
voice 0's filter input builds to ~0.65 but the filter output collapses to ~1e-36.
Tracing it:
- The filter drive is `v371 = v368 · max(v360,0) · state[10400]`.
- `v360` reduces to `state[10208] · state[10048]`, and `state[10048]` carries
  `state[3232]`, which voice_render itself computes from the **LFO/mod section**
  gated on `state[560]`.
- In both the fresh init and the live dump, **`state[560] = 0`** (no LFO drive),
  **`state[6848] = 0`** (filter envelope closed), so the mod section produces
  ~1e-35 and the filter output collapses to the denormal floor.

Forcing the cutoff (`state[7520]`) open to 0.99 did **not** restore signal — proof
the bottleneck is the modulation/envelope path, not the cutoff coefficient.

## Conclusion — what's actually left for sound
voice_render is a **per-sample DSP that reads 326 control slots it never writes**
(envelope targets like `+9824`, the LFO at `+560`, filter env at `+6848`, …). Those
slots are populated by the **control layer**: one linear ramp per envelope/gate
(the ramp engine, advanced each sample by the pruner) plus the LFO. Our validated
init makes every *coefficient* slot bit-exact against the plugin (init = 100%), but
the *dynamic* envelope/LFO/gate slots are at their silent reset values — because the
capture itself was silent. There is **no faithful shortcut** (raising those slots by
hand would be tuning, which the project forbids): the values must come from running
the original control algorithm.

## What landed toward it
- `src/ramp_engine.c` / `.h` — **exact** transcription of the ramp/envelope engine
  (sub_1803C2D80 / 2E80 / 2E00 / 2E60). This is the generator for the VCA/VCF
  envelopes and the gate. Compiles clean; standalone-tested.
- Remaining to make a note sound from original code:
  1. the ramp→slot **bindings** (which flat slot each envelope/gate ramp drives,
     and the on/off target constants + times) from the param-manager constructor;
  2. the **LFO** per-block update (drives `+560` and friends);
  3. a note-on driver that triggers the ramps and runs render+prune per sample.

All three are offline transcriptions from `refs/`/`allcode` — no captures needed.
```
make sound   # reproduce the diagnosis above
```
