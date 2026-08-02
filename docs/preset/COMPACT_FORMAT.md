# COMPACT PRESET FORMAT — 118 bytes per patch, MEASURED

**Question:** the factory bank is 1.23 MB. Can a bank fit a 24LC256 (32 KB)?

**Answer: yes, with room for 277 patches.** A patch is **118 bytes**.

## Why the bank is 1.23 MB

    23-byte header + 64 x 20,223-byte records = 1,294,295 bytes

The 20,223-byte stride is the plugin's own record format, sized for a whole
product line. Almost all of it is padding and parameter slots the JUNO-60 does
not use.

## What a patch actually contains

Measured, not estimated. Method: flip every byte of a patch record 0..3999,
recall it through the sealed engine, and hash {an audio-cell probe set} — the
voice block, the shared noise block, the FX regions and the master. Any byte
whose flip changes the hash is load-bearing.

Two corrections were needed to get a true reading, both worth recording:

* the probe initially included the **C++ header below offset 176**, which is
  audio-inert and changes with *any* record byte (a checksum or copy). It made
  all 4,000 bytes look live.
* the blob starts **16 bytes into the record**, so an uncorrected base tested
  the wrong bytes entirely.

Result across FX-diverse patches (0, 2, 7, 20, 61): 110-116 live bytes each,
**union 116**. That union then failed round-trip on **2 of 64 patches** — 5 and
47 — which both needed blob bytes **111 and 113**. Sampling patches was not
enough, and the round-trip proof is what caught it.

**FINAL: 118 bytes, in 32 contiguous runs.**

## Proof

Reconstruct each patch from its 118 bytes written into a fixed template
record (patch 0's, baked into firmware), then recall:

    round-trip: 64/64 patches reproduce the engine state EXACTLY

Not approximately — the same engine-state hash as loading the original 20,223-byte
record.

## Why no precision is lost

Every JUNO-60 parameter is **already a single byte, 0-255**. That is the
instrument's own resolution, not a compression choice. So storing one byte per
parameter is lossless by construction; there is nothing to quantise. A "few
values per parameter" scheme would be strictly worse and is unnecessary.

## Storage

| | bytes |
|---|---|
| per patch | 118 |
| 64 factory patches | 7,552 |
| 24LC256 capacity | 32,768 |
| **patches that fit** | **277** |

## The byte set

Contiguous runs of blob offsets (add 16 for the record offset, plus
23 + 20223*patch for the bank offset):

    14-21, 24-25, 28-33, 52-59, 70-71, 74-109, 111, 113-115
    118-119, 132-133, 474-475, 482-483, 498-499, 506-507, 514-515, 522-523
    538-539, 602-603, 618-619, 626-627, 634-635, 642-643, 650-651, 1852-1853
    2086-2087, 3041-3045, 3052-3053, 3060-3061, 3068-3069, 3076-3077, 3931-3933, 3935-3936

Machine-readable: `docs/preset/compact_bytes.json`.

## Still owed before this ships

1. **Validate against the PLUGIN, not just the port** (docs/trackb/THREE_WAY_GATE.md).
   The byte set was derived by driving `src/`. If the port ignores a byte the
   plugin honours, this format would silently drop it. The scan must be repeated
   against the plugin under Unicorn, or at minimum the 118-byte set must be
   confirmed to cover every byte the plugin's own recall enumerator reads.
2. **A gate in `make verify`** that re-runs the 64/64 round-trip, so a future
   engine change that starts reading a 119th byte fails loudly instead of
   silently corrupting stored user patches.
3. **Extend beyond the factory bank.** 118 bytes covers what the 64 factory
   patches and the tested FX contexts reach. A user patch with, say, EFFECT
   TYPE 4 (FLANGER) may touch bytes none of these do — and the FLANGER leaves
   are exactly the port's known blind spot.
