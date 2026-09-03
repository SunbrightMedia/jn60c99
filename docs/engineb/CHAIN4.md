# CHAIN4 — the ORIGINAL-port CLASSIC on FOUR boards (binding design)

User directive 2026-09-03: flash the classic Juno built from the ORIGINAL
PORT's sound on 4 boards. b44 measured the exact-classic voice at ≈5,045
cyc/sample; six voices + chorus need ≈31–35k of the 4-board 43,536 — no
smaller machine runs it. This document is the design the firmware follows.
Labels: PROVEN(executed) / READ(static) / INFERRED.

## 1. Topology — three copies of the PROVEN pairwise link

The chain is 4→3→2→1. Chip 1 owns the DAC. Each hop is one instance of the
O6 pairwise link (A-side = downstream chip, master RX; B-side = upstream
chip, slave TX), with its own control UART, handshake, CRC-proven mix gate,
pattern lock, and drain-to-latest — all machinery already proven on the
two-board bench. Nothing new is invented per hop; only the NUMBER of hops
and the slot format change.

```
chip4 ──hop C──> chip3 ──hop B──> chip2 ──hop A──> chip1 ──> DAC
 (B)             (A+B)            (A+B)            (A)
```

## 2. Voice distribution and the BIT-EXACT pre-add law

READ (eb_master_in.c:20-23): the master consumes the eight voice slots as
four PAIR SUMS, each one float add in fixed order:
`v8=voice[1]+voice[0]  v13=voice[3]+voice[2]  v18=voice[5]+voice[4]
 v24=voice[7]+voice[6]`.

READ (devchord.h, listen_mask_probe MEASURED): a chord of k sounds slots
8−k..7. Six voices therefore occupy slots 2..7 — three COMPLETE pairs
(v13, v18, v24) — and slot IS global identity at base 0
(juno_apply.c:603, g=(base+v)&7). ALL FOUR CHIPS RUN BASE 0 and share the
ONE plain chord-6 answer key. There is no per-base key in this design.

Distribution (each chip runs the FULL recall; only RENDERING is windowed):

| chip | renders slots | contributes to the wire (toward chip 1) |
|---|---|---|
| 4 | 2,3 | slot0 = voice[3]+voice[2] (the v13 pre-add, exact order) |
| 3 | 4,5 | forwards slot0; slot1 = voice[5]+voice[4] (v18 order) |
| 2 | 6 | forwards slots 0,1; slot2 = raw voice[6] |
| 1 | 7 + chorus + master + DAC | injects; renders nothing downstream |

Chip 1 injection: voices[3]=slot0, voices[2]=0; voices[5]=slot1,
voices[4]=0; voices[6]=slot2; voices[7]=local. Then
v13 = 0.0f+slot0, v18 = 0.0f+slot1, v24 = local+slot2 — each add
reproduces the single-engine float exactly.

⚠ THE ±0 EDGE (stated, not hidden): when a remote pre-add yields −0.0,
chip 1's `0.0f + (−0.0)` gives +0.0 — one sign bit on a zero. Every
downstream consumer adds or multiplies it, and ±0 are numerically equal
through both, so the PCM null is 0. A cell-level bit compare could see it;
the sonic gate cannot. INFERRED from float semantics; the host gate
(chain_sum_gate) runs the real engine and reports whether it ever fires.

## 3. Wire format — TDM4, one format on every hop

4 slots × 32-bit @ SR, Philips TDM. BCLK = 5.6448 MHz — twice the proven
2.8224 and still far inside jumper-wire spec (INFERRED). Slot map on EVERY
hop: 0 = v13 pre-add, 1 = v18 pre-add, 2 = raw voice[6], 3 = spare.
A middle chip merges by WRITING ITS OWN slots and copying the rest from
its received (CRC-proven) chunk; an unproven upstream mix-gate feeds zeros
instead — the chain degrades one pair at a time, never breaks (INVARIANT).
The training pattern fills all 4 slots; chunk = 4×CHUNK words (1024,
power of two — the lock masks hold).

## 4. Clocking and pacing — one pacemaker, chip 1

Each hop's A-side (downstream chip) masters the hop clock; the B-side
slave-TX write paces the upstream chip's loop (the PROVEN s3_bpace
mechanism). So pacing chains: DAC → chip1 → chip2 → chip3 → chip4 — one
oscillator paces every render loop. The A-side RX master clocks still run
from each chip's own crystal, so each hop's RECEIVE stream can slip one
chunk every few minutes (crystal ppm, INFERRED); the existing
drain-to-latest + relock machinery absorbs exactly this, self-healing.
If the bench measures the slip as audible, the hardware fix is bussing
chip 1's hop clock — a carrier-board option, not a firmware one.

## 5. Control — per-hop UART + the EVENT CHAIN

Per hop, the existing 100 ms announce/handshake frames, unchanged: same
build fingerprint (base-0 key XOR), same patch, disjoint voice windows
(the upstream side advertises its CUMULATIVE window — everything it
forwards — so overlap still means what it meant). Patch follow is the
proven pairwise rule per hop: downstream is truth; chip1 steps, 2 follows
1, 3 follows 2, 4 follows 3.

NOTES: only chip 1 has MIDI/console/robot input. Every juno_event_note_on/
off chip 1 accepts is mirrored up the chain as a NEW frame type
('J','E': seq, kind, note, vel, sum). Chips 2–4 apply each received event
through the SAME juno_event path and re-forward it. One ordered stream +
the deterministic allocator = identical global allocation on all chips
(the same argument the 2-board design already rests on). A sequence gap
(dropped byte) is COUNTED, printed, and answered with all-notes-off — a
desynced allocator must resync, not play a wrong chord forever.

## 6. Pins — IDENTICAL map on all four chips

| function | pins | UART/I2S |
|---|---|---|
| DOWN port (toward DAC): slave TX audio | BCLK 15, LRCK 16, DATA 17 | I2S |
| DOWN control | TX 8, RX 9 | UART2 (chips 2–4) |
| UP port (away from DAC): master RX audio | BCLK 10, LRCK 11, DATA 12 | I2S |
| UP control | TX 13, RX 14 | UART2 on chip 1, UART1 on chips 2,3 |
| MIDI IN | RX 18 | UART1, CHIP 1 ONLY |
| DAC | 5, 6, 7 | chip 1 only |

Hop wiring (N = 2,3,4; N talks to N−1):
N.15 ← (N−1).10, N.16 ← (N−1).11, N.17 → (N−1).12,
N.8 → (N−1).14, N.9 ← (N−1).13, plus common ground.

## 7. Latency — stated before it is heard

Each hop adds one CHUNK (5.8 ms). Chip 4's pair reaches the DAC 3 chunks
(17.4 ms) after chip 1's local voice; note events also ride 1–3 UART hops
(~1 ms each) in the same direction. A held chord is unaffected (each
voice's stream is exact, time-shifted); a strummed ONSET skew of up to
~20 ms across the chord is the cost. If the bench finds it objectionable,
the firmware fix is delay-alignment at the merge points (uniform 3-chunk
latency); it is NOT in the MVP.

## 8. Builds — four images, positions compiled in

No strap: the four builds already differ (voice window), so S3_CHAIN_POS
∈ {1,2,3,4} is a compile flag; each image prints its position, window and
hop roles at boot and refuses silently mis-flashed positions via the
per-hop voice-window handshake. Engine flags: the b44 CLASSIC-EXACT set
(trunk + EXACTLY-0 levers + EB_CLASSIC), S3_EXACT_ONLY=1, chord 6 keys.
Render windows: pos4 [2,4), pos3 [4,6), pos2 [6,7), pos1 [7,8) — needs
S3L_VOICE_HI (new; the VOICE-5 defect showed LO alone cannot express a
window).

## 9. What is proven where

- Pre-add law + injection map + ±0 edge: host chain_sum_gate (runs the
  real trunk engine; EXACTLY-0 PCM null required) — BEFORE any flash.
- Topology/config pure functions: tools/engineb/chain_gate.c, every tooth
  seen to fail.
- Hop machinery: PROVEN on the 2-board bench (O6 step 2); reused.
- TDM4, three hops live, event chain on wires: ONLY the 4-board bench can
  prove these. First bench criterion: all three hops report hs=OK,
  mix=OPEN, and the chord-6 CRC MATCH on all four consoles.
