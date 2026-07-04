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

## Resolved with the plugin binary (extraction, not capture)

Given the original `JUNO60VST3_64bit.vst3` (PE x64, imagebase `0x180000000`), the
two data tables were extracted **statically** by RVA (no runtime capture):

- `dword_7FF91E8A4290` (RVA `0xC44290`, .data) — the **31-entry src→dest table**,
  now embedded in `tools/decode_bank.py` / `gui/web/bank.js`.
- the curve LUTs (RVA `~0x969500`, .rdata) — the non-linear param maps.

The per-patch parser `sub_7FF91DFB1710` was fully transcribed (19-case switch:
`/255` raw, bipolar `(v>>1)+128` recenter, boolean, VCF-cutoff cubic, dB→amp,
`pow(v,1.6)`, exp-time). An adversarial pass re-decoded all 64 patches (1984
params) with **zero mismatches**. So each patch now decodes to its 31 parameter
values at their correct programmer-state destinations.

## The remaining gap — audible recall (honest)

Two things are still not delivered, for one shared reason:

1. **Specific panel names** per parameter. The 31 values are positioned
   correctly but their labels are transform-derived **roles** (e.g. "Bipolar mod
   depth", "Filter-mapped discrete"), not confirmed "VCF Cutoff"-style names.
2. **Applying a patch to our engine** so it sounds.

Both need the **programmer-value → engine-coefficient binding**. The plugin does
this through a generic, reflection-based **Koa value tree** (`CKoaValue` /
`CKoaStruct` nodes), **not** a small lookup table — so it is effectively the
whole (un-ported) parameter system, plus a per-block coefficient recompute. And
"PD The Juno Pad" (our only captured engine-state oracle) is **not** in this
bank, so the binding can't be pinned empirically from what we have.

Paths to close it: (a) port the Koa parameter→coefficient system (large), or
(b) capture **one** bank patch's engine-coefficient state from the running
plugin (`tools/capture_runtime_coeffs.js`) — a single ground-truth pair pins the
binding for all 64 patches, since the transform is deterministic.

=> Shipped: a faithful **bank browser** (`gui/web` "Load bank (.bin)…"): 64 real
factory names + per-patch values. Audible recall remains the open item above.
