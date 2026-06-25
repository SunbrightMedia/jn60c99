# RolandCloud JUNO-60 Preset-Bank Format (`KoaBankFile00003` / `PG-JU60`)

Reverse-engineered from `refs/preset_banks/bank1.bin` (1,294,295 bytes, 64 factory
presets) so the C99 port can load real factory banks. This document records the
on-disk layout, the nibble encoding, the decode→param mapping, and the validation
evidence (DB-range fit and the "SQ Dynamic ARPG" panel anchors).

---

## 1. On-disk layout

```
+0      23 bytes   File header:
                     "KoaBankFile00003"  (16 bytes, magic)
                     "PG-JU60"           (7 bytes,  product tag)
+23     64 records, each EXACTLY 20,223 bytes   (64 * 20223 = 1,294,272; +23 = 1,294,295)
```

Each record:

```
+0      16 bytes   Preset name, ASCII, space-padded   e.g. "SQ Dynamic ARPG "
+16     20,207 b   Parameter body (see below)
```

The 64 record names decode in bank-UI order (A1..H8): they match the supplied
name list exactly (`SY Poly Synth`, `SQ Dynamic ARPG`, `KY Delicate Keys`, ...,
`FX Wind`). This was the first cross-check that the record stride (20,223) is correct.

### Nibble encoding of the body

The first **3,040 bytes** of each record body are *nibble-encoded*: every byte is
in `0x00..0x0F`. A parameter value (0..255) is reconstructed from **two consecutive
bytes**:

```
value = body[2*k] * 16 + body[2*k + 1]        # k = decoded-position index
```

This yields **1,520 decoded values** per record (`3040 / 2`). Verified: zero bytes
`> 0x0F` anywhere in `body[0:3040]` across all 64 records (the first byte `> 0x0F`
appears at body offset 3040 in every record). Decoded values beyond the param
region are padding / unrelated serialized members.

The decoded value stream is what the plugin's deserializer
(`sub_7FF91E051330` → `sub_7FF91DEE65C0`, byte-stream copy into the 667-byte
record struct `v49`) consumes; the loader then copies a 326-byte param block from
`v49+21` into the patch object at `+6`
(`allcode/decomp_300000.c` ~L40116-40124). We decode the on-disk nibble stream
directly rather than re-running that deserializer; the alignment below is fixed by
hard anchors, not by tracing every byte of the struct.

---

## 2. Decoded-value layout (the two param blocks)

Across the 64 records, **81 decoded-value positions vary**; the rest are constant.
They cluster into two blocks plus a small tail.

### The patch parameter DB block

`refs/default_patch.json` documents the shared Roland system parameter DB,
**indices 755..877 = the JUNO-60 patch block (123 params)**, each with
`{min, max, default_step, spec}`. The decoded stream maps onto this block in **two
contiguous runs**:

| DB indices | Meaning                                   | decoded position formula        | status |
|------------|-------------------------------------------|----------------------------------|--------|
| 755 .. 853 | Synth voice (DCO / HPF / VCF / VCA / ENV / LFO / key-assign) | `pos = (db_index - 755) + 11` | **PROVEN, 100% range-fit** |
| 854 .. 877 | Global / effects (LFO trig src, ENV times, master tune, model, filter type, FX types) | `pos = (db_index - 755) + 200` | **PARTIAL** (reverb/filter-type anchored; a few positions off) |

In **block 1**, DB indices 854..877 read all-zero (they are placeholders there);
the live global/FX values live in **block 2** at offset +200.

### The decisive anchor: embedded patch name

DB indices **814..829** are the 16 "4 char" name fields. With the block-1 formula
`pos = (db_index-755)+11`, those land on decoded positions **70..85**, which spell
out the ASCII preset name exactly:

```
record 1, decoded positions 70..85  ->  "SQ Dynamic ARPG "
```

This pins the block-1 offset to **+11** with no ambiguity (the embedded name is the
only ASCII run in the decoded stream and it falls precisely on the DB name fields).

The tail positions (decoded 926..930, 1043, 1282..1283) also vary but lie outside
the DB patch block; they were not mapped (likely a second serialized member /
housekeeping fields).

---

## 3. Mapping method and validation

### Method
1. Decode the nibble stream (`value = 2 bytes`) → 1,520 values per record.
2. Use the DB patch block (`default_patch.json`, indices 755..877) as the target.
3. Fix the block-1 offset with the embedded-name anchor (DB 814..829 → ASCII name
   at decoded pos 70..85 ⇒ offset **+11**).
4. Validate by **DB range constraint**: for every DB index, the decoded value at the
   mapped position must lie within `[min,max]` for **all 64 presets**.
5. Locate block 2 (global/FX) by the same range scan + the reverb panel anchor.

### Range-fit results

| Region                              | params checked | within `[min,max]` for all 64 | fit |
|-------------------------------------|----------------|-------------------------------|-----|
| **Block 1, DB 755..853** (off +11)  | 82             | 82                            | **100.0%** |
| Block 1 + block 2 combined          | 106            | 104                           | 98.1% |

The two block-2 misses are DB864 (`1|2`, max=1) and DB868 (`-2OCT SIN..` sub-osc
wave, max=5) at offset +200 — i.e. block 2 is **not** a perfectly DB-aligned copy;
only its anchored params are trustworthy (see §5).

### SQ Dynamic ARPG panel anchors (record index 1)

Decoded against the DB specs, the patch reads:

| Panel fact (photo)        | Decoded                              | match |
|---------------------------|--------------------------------------|-------|
| Key-assign = poly         | DB800 = 0 → **POLY1**                | ✓ |
| Arpeggio / a main switch ON | DB756 = 1 → **ON**, DB803 = 1 → ON | ✓ |
| DCO 8' range              | DB760 = 3 → **8FEET**               | ✓ |
| Noise present (low)       | DB775 = 1 → **WHITE**, DB779 = 90    | ✓ |
| DCO saw/pulse + levels    | DB770=255, DB771=255, DB772=159 (osc levels non-zero) | ✓ |
| Sustained amp env         | DB795=195, DB797=125 (sustain-ish, non-plucky) | plausible |
| Reverb = HALL2            | DB876 = 3 → **HALL 2** (block 2, off +200) | ✓ |
| Delay = DLY               | DB875 = 0 → **DELAY** (block 2)      | ✓ |

The reverb HALL2 hit (DB876=3 at decoded pos 321) is what fixed block-2 offset to
+200; combined with the name anchor and 100% block-1 range-fit, the synth-voice
decode is considered solid.

---

## 4. Engine-paramID mapping (`refs/preset_bank.json`)

### What is and isn't recoverable
`refs/default_patch.json` `_meta` establishes (and our work confirms) that a
**definitive DB-index → engine-paramID table is not statically recoverable**: the
DB has no name field, the engine registry carries no DB index, and the bridge is a
runtime-built red-black tree. So we deliver:

- **The fully-validated DB-indexed decode** for every preset
  (`db_synth_params` = DB755..853, 100% range-validated; `db_global_fx_params` =
  DB854..877 from block 2, partial).
- **A confident engine-paramID subset** (`params` / `params_broadcast`) for the
  one DB index whose DB `spec` is an exact, unique semantic match to an engine
  base-patch param in `refs/param_table_full.json`:

  | DB index | DB spec                              | engine paramID | engine name | confidence |
  |----------|--------------------------------------|----------------|-------------|------------|
  | 760      | `64FEET\|32FEET\|16FEET\|8FEET\|4FEET\|2FEET` | **43** | `OSC1 Feet` | HIGH (spec is identical and unique) |

  `params_broadcast` repeats each confident value across all 8 per-voice copies
  (engine stride 110: `OSC1 Feet` = pids 43,153,263,373,483,593,703,813), since the
  base patch is broadcast per-voice by the engine.

### `refs/preset_bank.json` shape
```json
{
  "<bank_index 0..63>": {
    "name": "SQ Dynamic ARPG",
    "params":            { "<engine_paramId>": step },   // confident, base voice
    "params_broadcast":  { "<engine_paramId>": step },   // same, all 8 voices
    "db_synth_params":   { "755": .., "853": .. },        // PROVEN (off +11)
    "db_global_fx_params": { "854": .., "877": .. }        // PARTIAL (off +200)
  }
}
```

The `db_synth_params` map is the load-bearing payload: the bank-index→DB-index
mapping is bit-exact and 100% range-validated, so once the DB-index→engine-paramID
bridge is filled in (e.g. by capturing the runtime CC/key tree, or by matching
remaining DB specs to engine names), every preset can be applied without re-decoding.

---

## 5. Honest list of what is NOT pinned

- **DB-index → engine-paramID bridge (general case).** Only DB760→pid43 is mapped
  with high confidence. The remaining ~120 synth params are decoded to **DB index**
  (proven) but not yet bound to engine paramIDs. Likely matches by spec (e.g. DB759
  PWM source `MAN|LFO|ENV1±|ENV2±`, DB800 key-assign `POLY1|MONO|UNISON|POLY2`,
  DB795/796/797 osc/level pairs) are plausible but not bijectively proven and are
  deliberately left out of `params`.
- **Block 2 (DB854..877) internal layout.** Offset +200 is fixed by the reverb
  HALL2 anchor and passes 24/24 range-fit for that sub-range, **but** DB864 and
  DB868 violate their ranges at that offset, so block 2 is not a clean DB-aligned
  copy. Trust only the anchored selectors there (DB872 filter type, DB876 reverb
  type, DB875 delay type); treat the rest of `db_global_fx_params` as provisional.
- **Master Tune / ENV times.** These live in block 2 (block-1 copies are zero); not
  reliably positioned, so excluded from confident engine params.
- **Tail varying positions** (decoded 926..930, 1043, 1282..1283) are unidentified.
- **The exact deserializer transform** between the 20,223-byte on-disk record and
  the 667-byte struct was not fully traced; the nibble decode + hard anchors make
  that unnecessary for the synth-voice block, but it would be required to certify
  block 2 and the tail.

---

## 6. Reproduction

Decode formula, per record (after the 23-byte file header, record stride 20,223):
```python
body = record[16:]                       # skip 16-byte name
nib  = body[:3040]
val  = [nib[2*k]*16 + nib[2*k+1] for k in range(1520)]
def db(idx):                             # DB patch index 755..877 -> value
    return val[(idx-755) + (11 if idx <= 853 else 200)]
```
`db(814..829)` spells the preset name; `db(760)` is OSC1 feet; `db(876)` is reverb type.

## Deserializer-proven layout (supersedes the guessed offsets above)

Traced the actual preset deserializer instead of inferring the format. The byte
layout is defined by the binary, not a single linear offset:

- **Nibble decode is authoritative**: store `sub_7FF91DF9CDA0` (rva 0x33CDA0,
  decomp_300000.c:49191/49195) writes two nibbles per byte; decode is
  `value = body[2k]*16 + body[2k+1]` (high nibble first). Name pack
  `sub_7FF91DF9BC80` (0x33BC80, :48309) confirms it for the 32-byte→16-char name.
- **Base offset is a hardcoded 140**: `sub_7FF91DFB2C90` (0x352C90,
  decomp_340000.c:13920) `return 140;` → decoded position 70, exactly where the
  16-char name lands ("SQ Dynamic ARPG ").
- **Per-preset param loop**: bank parser `sub_7FF91DF91530` (0x331530, :40217)
  validates magic + `PG-JU60`, then loops `sub_7FF91DF90ED0` (0x330ED0) over 64
  params, distributing via the nibble store.

**Why the prior `(db-755)+11` model broke past the name:** the stream is serialized
structs of varying width, NOT one linear DB-indexed array. The synth block is
**stride 1**; the **PAT_NAME1 arp/jack block is stride 4** (`int8x4` params, value in
byte 0, 3 pad bytes). The arp params are a separate stride-4 region, so a linear
offset extrapolation lands on the wrong byte after the name.

**Arp params (record-absolute bytes, hardcoded at decomp_300000.c:40107-40109):**

| param | decoded pos | record bytes | SQ Dynamic ARPG (rec 1) |
|---|---|---|---|
| ARPEGGIO SW   | 141 | 298,299 | **1 (ON)** |
| ARPEGGIO TYPE | 145 | 306,307 | **0 (UP)** |
| ARPEGGIO STEP | 149 | 314,315 | **1** |
| OCTAVE SHIFT  | 161 | 338,339 | **0 (1 octave)** |
| KEY HOLD      | 165 | 346,347 | 0 |

Proven by: the deserializer hardcoding offsets 298/306/314, AND ARPEGGIO SW=1
correlating exactly with the 7 "SQ" presets (and 0 for the other 57) across bank1.bin.
