# Tier B render — bit-exact vs the plugin, all 64 patches (identical-state A/B)

**Result: 64/64 factory patches render BIT-IDENTICAL to the plugin** — both the
per-sample voice output (main+sub) and the master stereo output (L+R), over 8000
samples each, with the 3 deep-checked patches also confirmed at 24000. Zero
diverging samples on any patch. The port's DSP-in-motion — `voice_render.c`
(sub_180369070…), `master_render.c` (sub_180363380), and the shared analog-noise
composition — is a faithful transcription for the entire factory bank.

## Why this A/B is trustworthy (and the prior one was not)

An earlier end-to-end A/B recalled the patch **independently** on each side (plugin
value-tree dispatch vs our `juno_gui_apply_bank`), so recall / prepare / warmup-latch
/ voice-slot / CONDITION-scatter differences leaked into the audio comparison and got
mis-attributed to the render. It produced two findings that were later disproven (a
"2× LFO-delay 1920" that is actually correct, and "noise stepped 8× is patch 4's
primary divergence" — patch 4 has zero noise).

The trustworthy design removes every one of those confounds by starting **both
engines from byte-identical state**:

1. Under Unicorn (`scratchpad/oracle/e2e_emu.py`, `id_capture*.py`): BUILD →
   setSampleRate(48000) → recall patch → note-on (MIDI 60, vel 105). The note lands
   on the diagonal unit/slot (unit 7, slot 7). Dump that voice unit's **entire 12 MB
   state** and the master unit's state, right after note-on.
2. Render the plugin's own per-sample composition forward N samples; capture the
   voice output stream and the master in/out streams.
3. Our side (`id_voice_ab.c`, `id_master_ab.c`): `memcpy` the dumped plugin state
   into our engine byte-for-byte, then render with our `juno_voice_render` /
   `juno_master_render`. Compare sample-by-sample.

Because both start byte-identical, **any** divergence is unambiguously a real
transcription bug in our render — no confounds, exact-cell localizable. There were
none.

## Coverage (not trivial)

- All effect paths: DELAY TYPE (v39) ∈ {0,1,2,3,5} and EFFECT TYPE (v551) ∈ {1,2,3,5}
  across the bank — mode-1 distortion+pan and mode-5 chorus-variant included.
- Signals non-trivial: ~7999/8000 distinct nonzero voice samples; true stereo
  master (L≠R on ~1998/2000) — the chorus/effect path is genuinely active.
- Heavy-noise patches (SY Snow Drops, BS Slow Blob, FX Wind) bit-identical, so the
  once-per-sample noise/LFSR composition (juno_driver_render_voices) is proven exact.

## Validation gate

The 64-patch capture uses a build-once + memory-snapshot-restore loop
(`id_capture_batch.py`) for speed. Before trusting it, the batched capture of patches
4/32/13 was confirmed **byte-identical** (whole 11 MB state dumps) to the earlier
per-patch fresh captures. Only then were the other 61 captured.

## The one non-audio difference (documented, not a bug)

A full-state diff shows exactly one 4-byte scratch cell differing — voice-relative
offset 1728, written at `voice_render.c:899` then read at `:924` as
`JF(1968)*JF(1728)+…` where `JF(1968)==0` for every factory patch, so it is
zero-annihilated and never reaches the audio. Confirmed: the voice output is
bit-identical at every sample despite this cell differing. Not an audio divergence.

## Reproduce

```
cd scratchpad/oracle
python3 id_capture_batch.py         # plugin-side capture, all 64 (Unicorn, ~5 min)
sh id_build.sh                       # build id_voice_ab / id_master_ab (links src/*.c)
python3 run_ab64.py                  # runs both harnesses for all 64 -> ab64_results.json
```
Full per-patch table: `scratchpad/oracle/ab64_findings.md`.

## Phase 1 — expanded coverage (beyond the single held note)

The 64/64 above covered note-on → sustain for one held note (MIDI 60, vel 105, 48k).
The identical-state design was then extended across every playback dimension — same
method (drive the plugin into the target state, dump it, load byte-identical into our
engine, render forward, compare) — and **every case is bit-identical**, independently
re-verified by re-running `id_voice_ab`/`id_master_ab` on the left-behind artifacts:

- **Release tails** — note-on → sustain → note-off, then A/B the release-phase render
  from the post-note-off state: patches 4/13/30, voice+master bit-identical over the
  full tail (up to 36000 samples; envelopes decay 10³–10⁵× to the FTZ floor, so the
  release curve + filter + FX tail are genuinely exercised).
- **Polyphony + master summation** — 4- and 8-note chords: every sounding voice unit
  *and* the summed master stereo bit-identical (24000 samples), so multi-voice mixing
  is exact.
- **Notes / velocities / sample rates** — ~36 cases over notes {36,48,72,96},
  velocities {1,40,127}, rates {44100,48000,96000}: all bit-identical. 44.1 kHz (its own
  coefficient arms) is fully covered and shows no systematic divergence.
- **Pitch-bend / mod-wheel** — bend {±0.5, +1.0} and mod applied via the plugin's own
  dispatch, then A/B from the bent state: bit-identical (each wheel value shifts
  >8000/8192 samples vs baseline, so it genuinely reaches the audio).
- **Arpeggiator** — reframed honestly: the arp is an *event generator* (proven 330/330
  vs CArpeggio separately), not a render dimension; its fired notes render through the
  already-proven voice path.

### Velocity is correctly inert (verified, not assumed)

vel 1 vs vel 127 render **bit-identical** in the real engine even on the "VeloRez" /
"VeloMOD" patches. This is faithful, not a bug: the plugin's own recalled VCF/VCA
VELOCITY SENS (cells 7424/9600) is **0.0 for every factory patch** (confirmed in the
plugin's dumped state *and* the raw bank bytes 1862/2102), matching the
velocity-insensitive JUNO-60 hardware. The "Velo" names are designer labels, not
keyboard velocity.

### One honest residual (untested, not a divergence)

The A/B harness renders `voice_render`/`master_render` directly and does **not** tick
the control-rate parameter smoother (our `juno_note_tick` / the plugin's
`sub_7FF91E0224A0`) — which is a genuine no-op in all tested scenarios (recall snaps to
target, no ramps armed, no knobs moved), so it does not affect any result here. It is
therefore *not verified in-composition*: it would only matter for real-time knob
automation *during* a sounding note (live tweaking), which patch playback does not do.
The recall-time side of it is the "recall ramps" cold-load item.

## Scope note — what this proves and what it does NOT

This proves the **render** (Tier B) is bit-exact given identical state. It does not by
itself prove **cold-load** sample-identity (fresh patch load → note → render), which
additionally requires the state-setup to match. Known residual cold-load differences,
all in state setup (not the render) and none audible on a normal load-then-play:
- **Voice-slot allocation order** — the plugin's POLY allocator (sub_7FF91DFB3150)
  scans its LRU array back-to-front and picks slot 7 first from a clean state; our
  bridge picks slot 0. Different slot → different per-voice CONDITION scatter (sub-cent).
- **Recall ramps vs snaps** — the plugin glides some recalled values over ~ms; we snap
  to target. Only differs if a note sounds within the ramp; realistic load-then-play
  converges.
- **Warmup latch** — the plugin mutes its first 960 samples (~20 ms) after prepare;
  we start immediately. Inaudible.
