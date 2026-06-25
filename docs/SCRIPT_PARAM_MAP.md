# Script.xml — the DB→engine binding, solved (capture-free)

**This supersedes the "runtime-only / not statically recoverable" verdict in
`docs/DB_ENGINE_BRIDGE.md` for the continuous params.** The binding was never in the
**PE binary** (that finding stands), but it IS in the plugin's own shipped resource
file **`Script.xml`** (`refs/plugin_resources/Script.xml`) — the Roland
parameter-definition map, found in the VST files. Using it is fully capture-free: it
is the plugin's own data, like the decompile and the preset bank.

## What Script.xml is

A 230 KB XML schema (`<script>`) defining every parameter the plugin knows, in
canonical Roland-address order, grouped into SYSTEM / SETUP / SYNTH / PATCH / PATCH2
structs. Each `<value>` has a **name, range, and default**. The `<control>` elements
are the panel layout. It is the `.uidesc`-class artifact that is **not** inside the
decompiled PE (the PE holds only VSTGUI parser strings + SVG assets).

## The two things it gives us

### 1. Definitive exposure (the parenthesis convention)
Script names that are **parenthesised** — `(OSC2 WAVE)`, `(LFO AMP DEPTH)`,
`(OSC3 EXT IN)` — are **not on the JUNO-60 panel** (System-8 framework / internal /
modular-jack params). **Unparenthesised** names — `LFO RATE`, `DCO RANGE`,
`VCF CUTOFF FREQ`, `ENV1 ATTACK` — are the JUNO-60 panel controls. Of the 114 patch
params, **61 are panel-exposed.** This is the authoritative exposure marker that
`docs/EXPOSURE.md` previously had to approximate.

### 2. The DB→engine binding
Script's patch-param order aligns **1:1** with the factory-preset DB synth block:

```
Script patch param i   <->   DB-index (750 + i)
```

Proven by: (a) the bridge's pre-existing static anchor **DCO RANGE == DB760**
(OSC1 Feet, offset 3840); (b) **range+default agreement** along the whole alignment
(every DB755+ param matches its Script twin's min/max/default, e.g. VCF CUTOFF=DB779
def 255, ENV1 ATTACK=DB784 def 0); (c) the 16-char preset-name block lands on the
same positions (DB814–829 ↔ Script name struct). The one apparent mismatch (DB769
`-11..11` vs Script `0..22`) is the signed/unsigned encoding of the same param the
bridge already biases (`case 769: value−11`).

The full chain is therefore static and capture-free:
```
DB-index --(Script.xml order)--> param name --(docs/PARAM_MAP.tsv registry)--> engine offset
```
`refs/script_param_map.json` (built by `tools/build_script_param_map.py`) carries every
patch param with `{db_index, name, range, default, panel_exposed, engine_offset}`.

## Impact: the pitch drift

The LFO params that drive the user's reported pitch drift were "unmapped/runtime-only"
before; they are now bound, and just below the previously-extracted DB block:

| DB | Script name | engine offset | registry name | SQ ARPG step | default |
|----|-------------|---------------|---------------|--------------|---------|
| 751 | LFO DELAY TIME | 1920 | LFO Delay | 0 | 0 |
| **752** | **LFO RATE** | **1088** | LFO Rate | **63** | 145 |
| **753** | **DCO LFO MOD** | **4032** | LFO Level (→pitch depth) | **128** | 128 |
| 754 | VCF LFO MOD | 4016 | LFO Gain | 68 | 128 |

SQ Dynamic ARPG's real **LFO RATE is step 63** (not the default 145, and not PD Juno
Pad's captured value the render currently uses). Applying DB752→1088 and DB753→4032
through the proven LUT apply engine (`juno_param_apply_lut`, tableIds 22 and 0) makes
the render use SQ ARPG's *own* LFO — the faithful fix for the vibrato character, with
the DSP code already verified faithful (`docs/CHORUS_VIBRATO_DIAG.md`).

## Status / limits

- Alignment + exposure: **validated**, high confidence.
- Engine-offset resolution: 20 of 61 panel params auto-resolved by name; the rest need
  a few more Script-name→registry-name bridges (mechanical — extend `NAME_BRIDGE` in
  `tools/build_script_param_map.py`). The DB-index→name half is complete for all 61.
- `Script.xml` + `TextCodeTable.dat` (which confirms the product is the **System-8
  PLUG-OUT** with a JUNO-60 model — corroborating the framework-vs-exposed model) are
  committed under `refs/plugin_resources/`.
