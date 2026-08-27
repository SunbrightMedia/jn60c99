# b26 — the VCA move: implementation-ready plan, branches on the probe number

`docs/engineb/data/b26_vca_move_plan.md` — 2026-08-27

b25 priced the keystone and found the cut is VCA-only (0.352, inside the
306–426 window). The `S3_VPROF` firmware is flashed to read `vca/vcf` on
silicon and confirm the one assumption behind that number (comparable CPI).
This plan is written NOW so that the instant the board prints its VERDICT line,
implementation is mechanical, not a fresh think.

## The decision the probe returns (compiled into the firmware, b25)
| silicon `vca/vcf` | branch |
|---|---|
| 0.30–0.41 | **A: move the VCA only** (the expected case, 381 cyc) |
| < 0.30 | **B: move VCA + nsvf** (414 cyc; VCA alone would undershoot parity) |
| > 0.41 | **C: move a fraction of the VCA** or re-open the cut (VCA alone risks making core 1 critical) |

Only the CUT SET differs between A and B. The machinery below is identical.

## Why this is bit-exact (not a sonic trade)
The voice back half is FEED-FORWARD: `nmix → vcf → vca → vout` (b24 §6). Moving
voice v's back half to core 1 one chunk late produces the SAME output sample
for sample n — it is merely computed across two chunks and emitted one chunk
later. This is the FX-pipe argument (juno_s3_listen.c:2134) applied one stage
upstream. The audio is identical; only absolute latency grows by one chunk
(2.9 ms at CHUNK=128), on top of the FX pipe's, for ~5.8 ms total. The INVARIANT
permits it: latency degrades, continuity does not.

## The shape (mirrors S3L_FX_PIPE, one stage earlier)
Flag `S3L_VCA_PIPE`, default 0, trunk byte-identical when off.

Per chunk, for each MOVED voice v (the top of core 0's owned range):
- **core 0, chunk k**: run v's FRONT half (through `eb_noisemix_tick`), stash
  the cut set into a per-voice carry buffer. Do NOT run `eb_vcf_tick` /
  `eb_vca_tick` for v.
- **core 1, chunk k+1**: read v's carry buffer, run `eb_vcf_tick` then
  `eb_vca_tick`, write `vout[v]` into the chunk-(k) time slot of the delay bank.
- **master, chunk k+1**: mixes `vout[all voices]` from time-aligned banks — the
  un-moved voices via a one-chunk FIFO, the moved voices from their delayed
  slot — so every voice contributes sample n. Aligned. Bit-exact.

## The cut set to carry (b24 §6, both corrections load-bearing)
`EB_VCF_ILV` already stashes most of it (`eb_render.c:777-782`). For a
chunk-LATE pass, two additions that a within-sample pass does not need:
1. **`st->glide[v].s560` — 7 floats, not 6.** The ILV pass reads it live; a
   chunk later it must be carried, and the one-chunk skew on it is silent.
2. **`eb_modcv_latch` STAYS ON CORE 0.** `decim → modcv → dco` closes a
   one-sample loop inside the voice; moving the latch breaks it. Only
   `vcf`+`vca` cross to core 1.
For branch B, also carry `nsvf`'s inputs and run `eb_nsvf_tick` on core 1.

## Race analysis (state it, do not hope it — the FX pipe's discipline)
- Two banks. Core 0 writes bank `cur` at owned voice indices; core 1 reads the
  carry buffer written by core 0 last chunk (no concurrent writer).
- One writer per volatile flag. `w_cur` flipped by core 0 only, before the
  worker is released, so the worker sees a stable value for the whole pass.
- First chunk has no predecessor → one chunk of startup silence, once. Guard
  with a `w_have_prev`-style flag; it is the pipeline filling, not a defect.

## How correctness is proven WITHOUT the board (do this first)
A host null harness renders the same audio twice — once straight, once with the
moved voices' back half deferred one chunk — and compares sample-for-sample,
offsetting by the one-chunk pipeline delay. MUST be EXACTLY 0 for any moved-voice
set S. This proves bit-exactness on the host; only the CYCLE BENEFIT needs the
board. Reference harness shape: `tools/engineb/null_b.py` with a new
`--vca-pipe S` mode. Seen-to-fail: skip the glide carry and confirm the null
goes non-zero.

## How the benefit is proven ON the board
`FXP:`-style per-second line already prints `fx= v1= wait=`. Add core-0 tail
cost with `S3L_VCA_PIPE` off vs on; core 0's per-sample max must drop by the
moved module's measured cost, and `underruns` must stay 0 through the stress
phase. Quote the delta, never the absolute (the probe rule).

## What this does and does not deliver
- **Delivers**: closes the steady-state ~197 µs / 259-cyc deficit (b12, b15) so
  a QUIET block fits its period — the precondition for "no clicks at rest".
- **Does NOT deliver**: burst headroom. Bursts (MIDI floods, knob storms, patch
  changes) are handled by chunking, already proven on silicon (O2/O3). Both are
  needed for the full invariant; this is the steady-state half.

## Order of work once the probe confirms the branch
1. host null harness `--vca-pipe` + seen-to-fail  (board-free, do immediately)
2. `S3L_VCA_PIPE` implementation behind the flag; trunk byte-identical off
3. host null EXACTLY 0 for the chosen cut set
4. flash off-vs-on; read the core-0 delta and `underruns=0`
5. fold into the shipping reconfigure line in esp32s3/LISTEN.md
