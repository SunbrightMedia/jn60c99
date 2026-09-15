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

## Attack classification of all 64 factory patches (host)
28 are PUNCHY (attack to 90% <= 60 ms): 0, 2, 6, 7, 10, 14, 15, 18, 23, 24,
26, 30, 31, 32, 34, 37, 38, 39, 41, 42, 46, 47, 50, 54, 58, 59, 61, 62.

36 are SLOW-ATTACK PADS (>60 ms, up to 1590 ms): 1, 3, 4, 5, 8, 9, 11, 12, 13,
16, 17, 19, 20, 21, 22, 25, 27, 28, 29, 33, 35, 36, 40, 43, 44, 45, 48, 49, 51,
52, 53, 55, 56, 57, 60, 63. The slowest: 63 (1590 ms), 48 (1480 ms),
43/45 (~1450 ms), 35/60 (1440 ms), 36 (930 ms).

So when the user steps to a pad (e.g. 36/48/56), the note ramps to full over
~1 s and FEELS like input lag, though it starts sounding at ~10 ms. This is
authentic JUNO behaviour, not a defect. The boot patch (0) is punchy.

## FIX (2026-09-15) -- validated on silicon, VERSION 20260915074035
Root cause: POS1 (DAC board) renders 1 voice + full FX + master with ~0 burst
budget (SCHED slack=7). A note's rebuild is 2 heavy steps (events + the voice);
eb_sched deferred each up to SCHED_STARVE=64 blocks before forcing -- 2x64=128
blocks = 743 ms. The KEYLAT wait trace proved it: voice 7 awake (atrest=0),
un-hushed (hush=0), silent (pk=0) for exactly 128 blocks. Note 60 = the C key
maps to voice 7, so every C press lagged 743 ms.

Two POS1-only changes (juno_s3_listen.c):
 1. nb_begin scopes the note rebuild to POS1's local voice window
    [S3L_VOICE_LO, EB_NUM_VOICES); the injected voices are never rendered here,
    so building their coefficients was pure waste. A note is now <= 2 steps.
 2. The note-step runs even with no burst budget; the ~0.65 ms overrun is
    absorbed by the 35 ms DAC DMA buffer.

RESULT on silicon: voice 7 (C key) 743 ms -> **12 ms**. un=0 (no underrun),
drift=-3 stable, B4 note-misses frozen at 2 (one-time, not per-note), CRC
0 bad -- MATCH (recall still bit-exact). Boot CRC uses the full rebuild, so it
is unaffected.

OPEN (secondary): remote voices (POS2-4) are mostly 0-6 ms but show rare
multi-second outliers under the self-timer -- followers have ample slack
(SCHED slack ~60000), so this is NOT rebuild starvation; it points at the
event-chain / transport (a dropped note-on resyncs only on the next event).
Tracked separately from the (now fixed) local-voice latency.
