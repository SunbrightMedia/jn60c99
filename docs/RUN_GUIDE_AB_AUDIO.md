# Phase 0 — audio-rate A/B validation (run guide)

The oracle that makes accuracy measurable. Renders the port from an explicit event
log and compares it sample-for-sample / spectrally to a plugin reference WAV.

## Pieces
- `tests/render_events.c` — renders the port from an event log (`tests/oracle/*.txt`).
- `tools/ab_compare.py` — compares a reference WAV vs a port WAV (resample, align,
  metrics). Needs `numpy` (`pip install numpy`).
- `tests/oracle/*.txt` — event logs (note on/off timing, patch, sample rate, duration).

## Run
```
make oracle REF=/path/to/plugin_reference.wav EV=tests/oracle/<log>.txt
# or manually:
./tests/render_events tests/oracle/<log>.txt /tmp/port.wav
python3 tools/ab_compare.py <plugin_reference.wav> /tmp/port.wav
```

## Metrics (lower error = closer)
- **level diff** — RMS mismatch (dB).
- **residual (gain-norm)** — best-scalar-gain residual, dB below the reference RMS.
  `< -20 dB` ≈ sample-accurate; `> -3 dB` ≈ uncorrelated.
- **waveform corr** — normalized cross-correlation (1.0 = identical shape).
- **envelope error** — RMS of the 20 ms-window level difference (dB).
- **log-spectral distance** — mean per-1/3-octave timbre error (0 = identical;
  `> 0.3` audibly off), plus the worst-offending bands.

## The reference-render protocol (what to export from the plugin)
For each test vector, render in the plugin and note the exact events:
1. **Sample rate 96 kHz** (the port's captured coefficients are 96 kHz-specific).
2. **Mono or stereo, 16-bit WAV.**
3. A known patch, a known note sequence, with **exact on/off sample positions** and
   velocity — write them into a `tests/oracle/<name>.txt` log (see format below).
4. Keep a few seconds of tail for release/effects.
5. Ideally also export a **dry** version (effects off) so the synth core can be
   validated separately from the reverb/delay tail.

### Event-log format (`tests/oracle/<name>.txt`)
```
sr    96000
dur   5.0
patch base        # base = captured PD Juno Pad ; sqarpg = hand-tuned overlay
0.5 on  60 100
0.5 on  64 100
2.5 off 60
2.5 off 64
```

## IMPORTANT — which reference actually validates what
- A reference of **PD The Juno Pad** (the patch whose coefficients the port has
  captured) validates the **DSP itself** — voice + master + chorus — independent of
  the (not-yet-built) parameter layer. **This is the reference we most need first.**
- A reference of any **other** patch (e.g. SQ Dynamic ARPG) currently measures the
  *parameter-layer gap* (Phase 2), not the DSP, because the port can't faithfully
  apply that patch's parameters yet. Useful later, misleading now.

## First result on record (SQ Dynamic ARPG, hand-tuned overlay)
`tests/oracle/cmaj_sqarpg.txt` vs the user's Ableton export:
log-spectral distance **0.520**; the port is missing ~20 dB of 250–400 Hz body
(sub/low octave) and ~25 dB of 12–16 kHz brilliance. This is a *parameter/overlay*
gap (expected), and it shows the harness localizes divergence correctly. The clean
DSP validation awaits a PD Juno Pad reference render.
