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

## Audible recall — partial, exact where bound (honest)

The plugin's fully-general **programmer-value → engine-coefficient** path runs
through a reflection-based **Koa value tree** (`CKoaValue` / `CKoaStruct`), not a
small table, so a complete static port of it is large and not done. But an
**empirical shortcut** delivers a verified subset without porting that tree:

- The user's live patch was identified as bank patch 5 `LD Classic Lead` (blob
  correlation), giving us its **real Ableton parameter values** as ground truth.
- Matching those unique values back to blob positions **anchors the blob→param
  alignment**; the per-param `(curve_id, engine_offset)` comes from the plugin's
  own setter thunks (run under Unicorn for the sample-rate-variant curves).
- The curve evaluator is bit-exact (proven vs the real machine code), so the
  chain reproduces the plugin's stored coefficient exactly for bound params.
  **Oracle:** `juno_curve(22,153) = 0.600000` == the plugin's own VCF cutoff
  float for patch 5.

Shipped (`src/juno_apply.c`, wired into `gui/web`): **Load bank → pick preset →
Apply → play.** 11 coefficients load bit-exactly (VCF cutoff/resonance, both
ADSR envelopes, filter env-mod, key-follow, VCA tone). See
`docs/AUDIBLE_RECALL_PLAN.md` for the exact/partial/approximate breakdown.

Still open (each blocked on certainty, not guessed): DCO oscillator mix and VCA
level (OscVoice/VoiceCmn setters live outside the extracted range), ENV2
decay/sustain (255/255 value-collision in the anchor patch), HPF (SR-variant
curve), LFO and the FX chain. Closing these needs either porting the Koa tree or
extracting the remaining setter thunks — both from the binary, no captures.
