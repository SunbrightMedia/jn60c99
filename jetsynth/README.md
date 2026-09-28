# jetsynth — a turbofan engine you play

An original C99 synth (not a port). Source sound = NASA-method noise
predictions; effects = the JUNO-60 port's own chorus, delay and reverb.
Live page: jetsynth/web/jetsynth.html (self-contained, wasm embedded).

## Controls (7 + BOOST)
| control | range | couples to |
|---|---|---|
| THROTTLE | TS 0.30–1.05 | drives the SPOOL target, not the sound |
| SPOOL | 0.25–12 s | x SIZE; slower up than down; slower at low power |
| SPEED | Mach 0–0.4 | jet noise (relative velocity), Doppler x ANGLE |
| ANGLE | 0° inlet – 180° exhaust | directivity: whine front, roar aft |
| DISTANCE | 15–800 m | spreading + air absorption; raises chorus/reverb sends |
| SIZE | 0.5–2x | rotor + jet pitch x 1/size, +20 log size; core does not move; spool slower |
| SPACE | 0–1 | JUNO chorus (turbulence), delay (echo), reverb |
| BOOST | hold | throttle target = full power; SPOOL sets the attack |

## Pipeline (repeatable)
```
sh jetsynth/tools/setup_oracle.sh DIR ; export JET_ORACLE=DIR      # pyNA, pinned, own venv
$JET_ORACLE/venv/bin/python jetsynth/tools/pyna_oracle.py all      # gates A + B
$JET_ORACLE/venv/bin/python jetsynth/tools/gen_tables.py           # -> gen/jet_tables.h
python3 jetsynth/tools/gen_fx_coefs.py emit 0 13 63                # -> gen/jet_fx_coefs.h
make -C jetsynth && make -C jetsynth test                          # wasm + page + host tools
```
Needs only clang + wasm-ld for the web build (no emscripten, no libc).

## What is proven, and how (labels per CLAUDE.md)
- **Gate A — driver == pyNA** (PROVEN, executed): `pyna_oracle.py driver` —
  my driver vs pyNA's own OpenMDAO pipeline, 5 sources x 19 angles x 24 bands,
  2 take-off steps: **0.0 dB**. Seen to fail: fan rpm +2 % → 21.8 dB.
- **Gate B — pyNA == NASA ANOPP** (PROVEN, executed): `pyna_oracle.py nasa` —
  NASA's STCA source spectra shipped with pyNA, 27 steps x 17 angles.
  Worst: jet 0.17, core 0.57, fan broadband 0.19, fan tones 0.71 dB.
  Seen to fail: fan rpm +2 %, jet V +2 %, M_0 +0.02. NOT seen to fail: core
  Ttj +2 % (too small an effect at 0.6 dB tolerance) — that tooth is weak.
- **fmodf** (PROVEN): the wasm build's own fmodf vs libm, 4M inputs, 0
  mismatches; a naive fmodf fails 1.1M (`make -C jetsynth test`).
- **FX coefficients** (PROVEN source): frozen from the certified standalone
  recall at 48 kHz as hex floats; no hand-typed number.

## Not proven / deviations (stated, not hidden)
- The SYNTH's output spectrum is not yet graded against pyNA (next gate:
  render a static point, 1/3-octave analyse, compare with pyNA - propagation).
- Buzz-saw (combination tones) is pyNA's Heidmann output but NASA's data has
  none, so it is UNVERIFIED. Its split across shaft orders uses a fixed
  random per-order weight (my choice).
- Deck fan rpm scaled x2.699 to match NASA's own STCA time series (INFERRED;
  see gen_tables.py). Spool dynamics, turbulence wobble, SIZE similarity
  scaling, FX blend amounts: design choices, not data.
- pyNA books a Doppler-shifted tone near a 1/3-octave edge one band away
  from NASA at the same level (115.1 vs 115.3 dB) — why gate B grades tones
  by total power.

## Paid on the way (method lessons)
1. pyNA source functions return msap / (rho c^2)^2 — use pyNA's own spl().
2. fan_source never divides tones by p_ref^2 — my extractor did (94 dB error;
   caught by gate B).
3. pyNA needs scipy < 1.14 and pandas < 2.0 → it gets its own venv.
4. Two oracle runs in parallel collide on pyNA's SQLite recorder — run gates
   one at a time.
