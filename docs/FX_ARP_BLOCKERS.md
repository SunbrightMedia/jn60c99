# Arp + FX — what blocks a faithful transcription

Investigated the three subsystems for "SQ Dynamic ARPG" (arpeggiator, delay, reverb).
All three hit the **same two walls**, and neither can be cleared from the current
extraction without fabricating values (which the project forbids).

## Wall 1 — the `.rdata`/`.data` sections were not extracted
The `allcode` dump captured **code + disassembly only**. The constant data sections
(coefficient tables, tempo tables, and the C++ **vtables**) are not in it. Every FX
block is driven by those tables:

| block | needs from `.rdata`/`.data` |
|---|---|
| Reverb `CDSPRev` | 4 coefficient tables `unk_63A350 / 63A600 / 639F20 / 63A130` (loaded by the ctor) |
| Delay `CDSPSystem8DlyDly` | tempo/note-value table `unk_910DC8` (used to turn TIME/SYNC into a delay length) |
| (earlier gaps, same cause) | gate-target const `unk_63EB50`; the preset-format schema; chorus runtime coeffs |

The disassembly shows the `lea` that points at each table, but not the bytes. Without
the bytes I cannot reproduce the reverb/delay coefficients.

## Wall 2 — the process methods are vtable-indirect
The actual audio processing is called through `(*(vtable+N))(...)` (e.g. the delay's
process at `*(*obj + 128)`, the arp's note-getter at `obj+3480`, note-on at
`vtable[0]`). Resolving *which function* each slot points to requires reading the
vtables — which live in `.rdata`/`.data` (Wall 1). A static call-graph can't follow
them. So even the code paths can't be fully chained without the data sections.

## The arpeggiator specifically
`sub_1803C0260` clocks through a **precomputed pattern table** (`obj+996`, step notes
at `obj+610`) built elsewhere from held keys + ARP MODE + ARP RANGE, and fires notes
via vtable[0]. The clock + wrap logic is visible; the pattern builder and the
note-getter are vtable-indirect (Wall 2). Faithful transcription needs them resolved.

## What unblocks all of it (one static extraction — no Frida, no runtime)
A single pass over the plugin DLL dumping the **data sections + vtables** clears every
item above at once. In IDA: for each `unk_…` table, select the data range and dump
bytes (or run an exporter over `.rdata`/`.data`); and dump each relevant class vtable
(the list of method pointers) so the indirect calls resolve to named functions. This
also retro-unblocks the preset parser schema and the `unk_63EB50` gate constant.

Concretely, the tables needed first:
- `unk_7FF91E63A350`, `unk_7FF91E63A600`, `unk_7FF91E639F20`, `unk_7FF91E63A130`
  (reverb coeff sets — sizes from the ctor's stride usage),
- `unk_7FF91E910DC8` (delay tempo/note table),
- the vtables for `CDSPRev`, `CDSPSystem8DlyDly`, and the `CKbdArp` synth voice object.

## Honest status
- Delay, reverb, arp are all **gated on the data-section extraction**, not on more
  reverse engineering of the code (the code is in hand).
- I will not fabricate the coefficients or guess the vtable targets.
- Once the data sections are provided, all three become straight transcription like
  the voice/master/chorus were.
