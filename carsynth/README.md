# carsynth — a playable combustion engine

C99 port of [engine-sim](https://github.com/ange-yaghi/engine-sim) (MIT, Ange
Yaghi, commit 85f7c3b) plus the JUNO-60 port's chorus/delay/reverb. No malloc,
no libc needed for the wasm build; the goal is an ESP32-S3 later.

## What was ported (upstream file → C99 file)
| upstream | here |
|---|---|
| gas_system.h/.cpp | src/es_gas.c |
| function.cpp, actions.h (harmonic cam lobe) | src/es_func.c |
| combustion_chamber, intake, exhaust_system, camshaft, cylinder_head, standard_valvetrain, fuel, ignition_module, piston_engine_simulator (step, placeCylinder, writeToSynthesizer), simulator (step order) | src/es_engine.c |
| synthesizer.cpp + butterworth / jitter / low-pass / derivative / leveling / delay filters | src/es_synth.c |
| convolution_filter.cpp | src/es_fftconv.c (FFT form) |
| assets/engines/atg-video-2/{07_gm_ls, 03_2jz, 01_subaru_ej25_eh}.mr | src/es_presets.c |
| es/sound-library/*.wav (+ its clip rule and volumes) | gen/es_ir.h via tools/gen_ir.py |

## Stated differences from upstream
1. **Crank speed is imposed** (the key sets it), like engine-sim's dyno hold
   mode. No rigid-body solver: pistons are placed by exact slider-crank
   geometry. Everything from cylinder volume to exhaust pulse is upstream's.
2. Convolution is FFT-partitioned (+256 samples latency); the exhaust
   channels share one impulse response, so they are summed then convolved once.
3. No int16 clamp after the leveler (it overshoots on new peaks); the
   instrument soft-limits at its output instead.
4. rand() is a 32-bit LCG.

## Instrument layer (src/car.c)
Key → rpm so the firing frequency (rpm/60 × cylinders/2) is the key's pitch
(folded by octaves into idle..redline). Key held → throttle = LOAD × velocity.
All keys up → throttle shut, revs fall to idle. Controls: ENGINE, EXHAUST,
LOAD, REV, TONE (engine-sim hf gain), NOISE (air noise + jitter), SPACE (JUNO FX).

## Measured
- Pitch tracks the key (spectral peaks on firing harmonics; B3 → 3,704 rpm V8).
- Speed, 44.1 kHz: native x1.8–2.6, wasm (node) x1.44–1.90 real time.
- An exact shortcut in dissipateExcessVelocity: output bit-identical (cmp).

## Not yet proven (next)
- Differential oracle: build engine-sim's own C++ classes with a kinematic
  harness and compare this port sample-by-sample with noise off.
- FFT convolution vs direct form test; wasm math vs libm test.
- ESP32-S3: double → float and fewer fluid substeps, each gated against the
  double build.

## Build
```
python3 carsynth/tools/gen_ir.py <engine-sim checkout>      # gen/es_ir.h
FX_RATE=44100 FX_OUT=carsynth/gen/car_fx_coefs.h python3 jetsynth/tools/gen_fx_coefs.py emit 0 13 63
make -C carsynth                                             # render_wav + web/carsynth.html
carsynth/build/render_wav out.wav 4 engine=0.5 @0.5:on=52,1 @2.5:off=52
```
