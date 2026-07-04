# JUNO-60 preset bank format (KoaBankFile00003 / PG-JU60)

Reverse-engineered from the plugin's own loader (`sub_7FF91DFB2380` "Load JU-06A
Bank" → per-patch parser `sub_7FF91DFB1710`) and verified by exact byte tiling +
an adversarial cross-check. Decoder: `tools/decode_bank.py`.

## Layout (VERIFIED — high confidence)

```
+0      23 bytes   header: "KoaBankFile00003" (16, format version) + "PG-JU60" (7, model)
+23     64 records × 20223 bytes each        (23 + 64*20223 == file size exactly)

each record:
  [0:16]      16 bytes   patch NAME, ASCII, space-padded   e.g. "PD Classic Pad"
  [16:238]    222 bytes  parameter blob (the ONLY region the loader consumes)
  [238:...]   ~19985 B   padding (zeros + repeating 8×'$' / 8×'1' marker blocks)
```

The blob is 111 slots of 2 nibbles each; value (0..255), **hi-nibble first**:

```
value[k] = ((blob[2k] & 0xF) << 4) | (blob[2k+1] & 0xF)      normalized = value / 255
```

Measured over the 64 patches: **~51 slots actually vary** (the real sound
parameters), 63 are ever non-zero, the rest are fixed/unused. So the real
information per patch is a name + ~51 bytes; the file is ~99% padding.

All 64 factory names decode cleanly (`SY Poly Synth` … `FX Wind`). Category
prefixes: SY synth, SQ sequence/arp, KY keys, BR brass, PD pad, LD lead, BS
bass, BL bell, PL pluck, FX effect.

## Parameter semantics (PARTIAL)

19 of the 111 positions have parser-CONFIRMED transforms and the programmer-state
byte slots they write (see `PARSER_CASES` in `tools/decode_bank.py`): raw `/255`
stores, bipolar recenters, boolean flags, and curve inverse-lookups (LFO rate,
`pow(v,1.6)`, dB) for the non-linear controls.

## What is NOT recoverable from this repo (honest gap)

Mapping every blob byte → its parameter identity → the engine coefficient our
port reads requires two **static data tables** that the decompile *references*
but does not contain the values of (Hex-Rays decompiles code, not `.rdata` data):

- `dword_7FF91E8A4290` — the ~31-entry src→dest table (blob byte → param dest).
- the 16-float curve LUTs (`xmmword_7FF91E5C95xx`) for the ~6 non-linear params.

These live in the plugin's `.rdata`. The full plugin **code** decompile is in
`refs/allcode_decomp.tgz`, but the 12 MB plugin **binary** (where those bytes
are) is not in the repo — only the C99 port build. And "PD The Juno Pad" (our
only captured oracle patch) is **not in this bank**, so the mapping can't be
recovered empirically either.

=> **Decoding (names + values) is done.** Making a patch *audible* on our engine
needs those two tables extracted **once, statically, from the plugin binary**
(not a runtime capture); then the parser + mapping transcribe directly from the
code already in `refs/`.
