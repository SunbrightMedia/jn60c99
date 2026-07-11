# FX cold-load recall — RESOLVED: 64/64 bit-exact

Phase 3 made the **voice** block bit-exact at cold-load (64/64 factory + 100/100 random).
This tracked the **master/FX** block, verified by the full-pipeline cold-load master A/B
(`scratchpad/oracle/id_coldmaster_ab.c` — our production render, voices + FX, vs the
plugin's captured stereo stream).

## Final state: **64/64 patches stereo-bit-exact over the FULL 8000-sample capture**

The last two items (below) closed the gate completely. Historical progression:
27 → 60 → 62 → **64** of 64.

### 1. REVERB-TYPE-dependent tap tables (the real cause of the last 2 divergences)
The 34-int reverb tap-index table (11022208..11022340) is **REVERB-TYPE-dependent**:
types 0 and 1 (short rooms) run their own stage sets; types 2..5 share the default that
`juno_engine_prepare` seeds. Our recall never rewrote it, so REVERB TYPE 0/1 patches
(41/62 type 0, 8/34 type 1) reverberated with the wrong tap positions — the late-tail
divergence at sample 1660. Proven output-relevant by cell-graft bisection (grafting only
this table made patches 41/62 bit-exact; grafting the entire delay coefficient block
changed nothing). Fixed: `juno_write_reverb_taps` (src/reverb_recall.c) — the plugin's
own REVERB TYPE dispatch output dumped under Unicorn at 44100/48000/96000, with the same
rate law as prepare's Class E (44.1k own table; other rates = 96k table + predelay
shift). Prepare now calls the shared writer for its type-2 default.

### 2. Tempo-synced DELAY TIME (the audible-beyond-the-window bug)
When TEMPO SYNC (blob 59, the shared LFO/DELAY sync switch) is on — **34/64 factory
patches** — the plugin ignores the manual ms table and quantizes the DELAY TIME byte
into one of 16 note divisions:

    division d = (byte == 0) ? 0 : (byte + 16) / 17      (1/32 .. 1/1, dotted+triplet)
    ms         = beats(d) * 60000 / BPM                  (recall default: 128 BPM baked)

Derived by sweeping the plugin's own dispatch (idx 797 time + idx 803 sync) under
Unicorn: 16 plateaus, bit-exact 48/48 (16 divisions x 3 rates) through the existing
3-op ms->coeff formula. The live-tempo law was verified bit-exact against the plugin's
tempo pushes at 60/88/176 BPM. Implemented sync-aware in `juno_apply_delay` (cell
102352 is written for EVERY delay type — the recall dispatches time before type
routing), plus `juno_apply_delay_tempo` (the host-tempo recompute, wired to the
bridge's BPM path next to `juno_apply_lfo_tempo`).

### Also closed: DELAY TYPE 1 (dual delay) wired
With the synced time available, `apply_slot1_delay1` is now wired (both instances:
102xxx variant block + 4297584.. second instance). Populating the blocks exactly as the
captured states renders bit-exact under our master path (proven by graft before wiring).
DELAY TYPE 5's reverb-hosted time (6497168) is sync-aware too.

## Gate (all green)
- `id_coldmaster_ab 8000`: **64/64** stereo-bit-exact (full captured window)
- `id_coldab_batch`: 64/64 voice-stream bit-exact
- `id_random_ab 100`: 100/100 bit-identical
- native suite: 17/17

Inaudible/inert and intentionally not chased: the aux DCO-retrigger latches (101504+,
re-phase silent voices only), the reverb structural constants at 10759360+ (never read
by the output), and the near-zero denormal buffers at 11022040+ (flushed by FTZ/DAZ).
