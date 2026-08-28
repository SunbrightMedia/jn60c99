# b37 — MIDI-to-sound LATENCY BUDGET (2026-08-28)

User requirement: **under 10 ms** from key press to sound. Fine with ~5 ms if it
is the ONLY latency and there are no surprises.

Constants read from the firmware (`esp32s3/main/juno_s3_listen.c`):
- `SR = 44100`, `CHUNK = 256` → one block = **5.805 ms** (= the 5804 µs period).
- I2S output DMA: `dma_desc_num = 6`, `dma_frame_num = CHUNK = 256`.
- Output write is BLOCKING (`portMAX_DELAY`); the engine runs ahead, so the DMA
  queue stays near-full.
- `S3L_FX_PIPE = 1`: the FX output is one chunk late.

## Current budget (measured constants, NOT yet a wire measurement)
| stage | latency | source |
|---|---|---|
| MIDI UART receive + parse | ~1.0 ms | 3 bytes @ 31250 baud |
| note waits for next block | 0–5.8 ms (avg 2.9) | block quantisation |
| FX pipeline | 5.8 ms | S3L_FX_PIPE, one chunk |
| **output DMA queue (6×256)** | **~29–35 ms** | 6 descriptors, near-full |
| **TOTAL** | **~38–45 ms** | dominated by the DMA queue |

The current design is ~4x over the 10 ms target, and the DOMINANT term is the
6-deep output buffer.

## The tension (this is the real problem)
The deep buffer exists to serve the INVARIANT — audio never breaks. Patch recall
misses 1–4 blocks (C10). A 6-deep queue hides that; a 2-deep queue would click.
So: **low latency and the no-click INVARIANT pull in opposite directions**,
through the buffer depth.

## The path to < 10 ms (no clicks, no sonic trade)
1. **Bound every compute burst** so the engine never misses more than ~1 block —
   the O3 "chunk-and-bound" method, already proven on silicon for parameter
   edits (76,779 edits, unknown=0, b17). Extend it to recall and MIDI.
2. **Then shrink the buffer**: `dma_desc_num 6 → 2`.
3. **Shrink the block**: `CHUNK 256 → 128` (2.9 ms/block; 128 mod 4 = 0, so the
   control-rate split still divides).

Target budget at CHUNK=128, DMA=2×128, FX pipe kept:
| stage | latency |
|---|---|
| MIDI | ~1.0 ms |
| note → block | 0–2.9 ms (avg 1.5) |
| FX pipeline | 2.9 ms |
| output DMA (2×128) | ~5.8 ms |
| **TOTAL** | **~9–12 ms** |

That is AT the edge of 10 ms. To be safely under, either drop the FX pipe back
in-block (needs the master-chain question re-opened) or take CHUNK to 64
(2.9 ms DMA, higher overhead). Both are measurable.

## Consequence for the VCA move
The VCA move adds one MORE block. Under a 10 ms budget there is no room for it.
The latency requirement **rules out the VCA move** and forces the bounded-burst
path — which is the bit-exact, no-sound-change, no-added-latency path anyway.

## OPEN / OWED
- This is a budget from constants, NOT a wire measurement. The true figure needs
  a scope: GPIO high on MIDI-note-parse, and the DAC output edge, measured
  apart. Bench is remote (bench_agent). That measurement is the next step.
- The MIDI path today is UART (GPIO 18). USB-MIDI does not enumerate yet; its
  latency is unmeasured.
