# CHAIN4 play-latency diagnosis (2026-09-15)

## Symptom (user, live bench, panel image)
Hand-played notes (panel IO14 = C, and the console keys) respond with a large
delay -- "three-quarters of a second or more" -- on BOTH press and release,
plus audio glitching. Reboot does not change it. Present on the boot patch
(patch 0) and on patches 37-39 (stepped with `n`).

## What is NOT the cause (proven)
- **The note engine.** The firmware's own KEYH histogram reads 2 blocks
  (~12 ms) note-event -> publish. Fast.
- **The patch attack envelope.** Measured on the HOST port (libjuno.so) with
  `tools/engineb/env_measure.py`, all 64 factory patches, note 60 vel 105:

  | patch | onset | attack (to 90%) | release |
  |------:|------:|----------------:|--------:|
  | 0 (boot) | 0 ms | **0 ms** | 1320 ms |
  | 37 | 0 ms | 10 ms | 2000 ms |
  | 39 | 0 ms | 40 ms | 2000 ms |

  Every patch's attack ONSET is 0 ms -- sound starts immediately. So the
  **press** delay the user hears cannot be the envelope.

## What IS the cause
- **Press delay = the CHAIN TRANSPORT.** POS1 (the DAC board) renders only
  voice 7 locally; voices 2-6 live on POS2/3/4 (`s3_chain.h` lo/hi map). A
  hand-played note usually lands on a REMOTE voice, whose audio must travel
  back down the chain (4->3->2->1). The design budgets that trip at 17 ms
  (`docs/engineb/CHAIN4.md` §7), but the user's live log shows heavy churn
  (realign ~85/s, drop 2.1% vs ~0.9% healthy), which lets the receive buffers
  stand deep and the audio arrive late + glitchy. The DAC DMA adds a fixed
  ~35 ms floor (`S3L_DMA_N=6`).
- **Release "delay" = genuine pad behaviour, NOT a defect.** The factory
  patches the user played have long releases (1.3-2.0 s). The note keeps
  sounding after the key is lifted because that is the sound; the port
  reproduces the `.vst3` faithfully.

## How it is being measured on silicon (no ears, SHIP LAW)
`S3L_KEYLAT` (POS1) times each note from submit to first audio in the
post-inject bank, at two thresholds: `lo` (sounding) and `hi` (audible).
`S3L_LATSELF` drives it with NO operator: every ~1 s, storm off, it self-plays
one note across the six voices, so the unattended bench prints KEYLAT per voice
on its own capture. Probe state lives in PSRAM (`EXT_RAM_BSS_ATTR`) so the
measurement image keeps internal DRAM byte-identical and cannot trigger the
playbook-98 moved-buffer boot mute.

## Fix direction (pending the silicon number)
Reduce the standing transport latency: the RX-to-latest drain cap, the per-hop
I2S RX DMA depth, and the POS1 DAC `S3L_DMA_N` are the priced knobs; the
realign churn (which lets buffers back up) is the deeper target. Measure the
per-voice KEYLAT first, then cut the dominant contributor. The `.vst3` DSP
stays bit-exact; only the fork transport is tuned.
