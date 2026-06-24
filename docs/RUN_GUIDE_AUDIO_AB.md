# Audio A/B — prove the running DSP matches the plugin

Two layers of running-DSP validation. The first needs nothing from you; the second
needs one trivial, fully-trustworthy capture (a WAV bounce — not Frida, not a memory
scan, just the plugin's own audio output).

## Layer 1 — capture-free, already passing (`make ab`)
We hold two full snapshots of the live plugin's engine state taken a moment apart
(`state_dump/` t0, t1). Loading t0 and running our `voice_render` forward, the
**control-rate** fields (envelope smoothers, gains, the VCF cutoff slew) converge to
the plugin's t1 values **bit-exactly** — e.g. the VCF cutoff matches to 0.000e+00
after 6367 samples. This proves the per-sample control-rate math is the plugin's.
58/155 dynamic voice-0 fields land within 0.01%; the rest are audio-rate filter
memory that decorrelates in phase over thousands of samples (Layer 2 covers those).

```
make ab
```

## Layer 2 — the audio bounce (one capture from you)
Sample-exact equality isn't the bar (note-on timing differs between hosts). A
faithful transcription matches in **envelope shape**, **pitch**, and **timbre**
(filter + harmonic spectrum). `tests/wav_compare` measures all three.

### What to bounce (make it reproducible)
In your DAW, on the **Cloud 60 / JUNO‑60** plugin:
1. Load the **PD The Juno Pad** preset (the one the coefficients were captured from),
   **chorus II**, no other insert/send FX, no reverb.
2. Project/render sample rate **96 kHz**, render to **16-bit PCM WAV**.
3. Play a **single held note** for ~4 s, then release and let it ring ~1.5 s
   (total ~5.5 s) — same shape as `make play`.
4. Pick any note you like, but **tell me the MIDI note number** (e.g. C4 = 60). Mono
   or stereo is fine.
5. Export and attach the WAV (name it `plugin_ref.wav`).

### What I do with it
```
make abwav REF=plugin_ref.wav     # renders the port note + diffs it vs your bounce
```
- **Pitch ratio** between the two reveals the MIDI-note → pitch-slot (offset 4448)
  mapping — this is exactly the one open gap, and your bounce pins it from real data
  rather than a guess.
- After matching pitch, **spectral centroid** + **magnitude-spectrum cosine
  similarity** judge the filter/oscillator transcription, and the **envelope
  contour** judges the ADSR timing. ~1.0 cosine + overlapping envelope = the running
  DSP is faithful, sample-timing aside.

This is the honest definition of "correct" for the running engine, and the bounce is
the only piece I can't produce myself.
