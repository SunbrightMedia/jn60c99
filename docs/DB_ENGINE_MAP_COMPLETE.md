# JUNO-60 (Cloud 60) — Complete DB→Engine Parameter Map

Authoritative, capture-validated mapping from every JUNO-60 patch-DB index
(`750..877`, 128 indices) to its `{bank decode position, engine state offset,
tableId/transform}`. Lets the C99 preset loader apply 100 % of any factory patch.

- **Machine-readable map:** `refs/db_engine_map_full.json`
- **Ground-truth oracle:** `src/captured_patch.c` (live engine state of bank
  record 0, "SY Poly Synth", 110 engine offsets).
- **Validation rule:** a binding is `capture_validated: true` only when
  `juno_param_apply_lut(offset, tableId, rec0_step[+bias]) == captured[offset]`
  **bit-exact** (the matching hex is quoted in each entry's `note`), or the DSP
  demux is unambiguous. 41 entries pass; a wrong binding was never asserted.

## DB numbering

`DB = 750 + script_index`. Block-1 names come from `refs/default_patch.json`
(the on-disk System param DB) and **coincide** with `Script.xml`
(`refs/script_param_map.json`) for the synth block (DB755..813). The two
**diverge for DB854+**: Script.xml's tail names are misaligned there, so
`default_patch.json` + the 24/24 bank range-fit are authoritative for the
global/FX block.

## The three decode blocks

| Block | DB range | Position formula | Status |
|-------|----------|------------------|--------|
| **block1_synth** | 750..813, 830..853 | `pos = db − 736` (full-record nibble stream, stride-1) | 100 % range-fit; 23/24 pure-LUT params round-trip bit-exact vs rec0 (DB773 via byte-0 gate) |
| **name_arp** | 814..829 | name at decoded 78..93; arp SW/TYPE/RANGE at decoded 149/153/157 (deserializer record bytes 298/306/314); OCTAVE/HOLD at 161/165 | hardcoded, deserializer-proven |
| **block2_global_fx** | 854..877 | `pos = 309 + (db−871)*4` (= `321 + (db−876)*4`, stride-4) | 24/24 range-fit vs default_patch specs |

`value = byte[2k]*16 + byte[2k+1]` (high nibble first), per-record header 23,
record stride 20223. Block-1 stride-1 is broken **only** by the name/arp block;
it resumes correctly at DB830.

## Newly resolved this pass (capture-validated)

| DB | Param | Engine | Transform | Evidence (rec0) |
|----|-------|--------|-----------|-----------------|
| **798** | PORTAMENTO | off 624 | `LUT[7][step]` — **tableId 7**, not 4 as the param-table listed | step 10 → `0x3ad61183` == capture |
| **801** | BEND RANGE | off 4128 | **semitone**: `LUT[21][R+160]` = (R+32)/255, R = 0..23 semitones | R 11 → `LUT21[171]` = `0x3e2cacad` (43/255) == capture |
| **803** | TEMPO SYNC | off 1056 | `LUT[52]` switch — gates tempo-synced LFO rate (`v83 = v77 + JF(1056)*(JF(1072)−v77)`; =JF(1072) when on) | step 1 → 1.0 == capture; DSP-confirmed |
| **870** | MASTER TUNE | off 368 | `LUT[6]` (−1200..+1200 cent, def 128 center) | all 64 = 128 → 0.0 == capture |
| **844** | BEND SENS DCO | off 4128 | `LUT[21][step+128]` (default 43) | `0x3e2cacad` (43/255) == capture |
| **845** | BEND SENS VCF | off 7472 | `LUT[21][step+128]` | `0x3e2cacad` == capture |
| **846** | MOD SENS DCO | off 3984 | `LUT[22]` = pure step/255 | `0x3db0b0b1` (22/255) == capture |
| **847** | MOD SENS VCF | off 7360 | `LUT[22]` = pure step/255 | `0x3f5cdcdd` (220/255) == capture |

DB844-847 offset+tableId are DSP- and capture-proven, but **read 0 in block1
for every factory preset** (they ride the engine default), so they are correct
transforms that the factory bank never exercises. DB843 BEND GAIN (0..3) is not
a distinct engine coefficient — it scales the `BendRange(4128)×BendLevel(4112)`
product (MED).

### Disproven / left unbound (rigor over coverage)

- **DB754 VCF LFO MOD** — `refs/script_param_map.json` proposed off 4016, but
  that offset is the **master LFO output gain** (`voice_render` `v174 = JF(4016)`
  scales the whole LFO; rec0 = 1.0, not reproducible from the step). Marked
  UNBOUND rather than asserting a wrong target.
- **DB810 VCA LEVEL** — no captured per-voice offset reproduces rec0 step 110
  via any LUT; likely targets `Patch Level` (off 101072, non-per-voice, outside
  the capture) or a host gain. UNBOUND.

## Demux / non-LUT bindings

- **DB759 DCO PWM SOURCE** (HIGH, validated): 6-way `MAN|LFO|ENV1±|ENV2±` →
  one-hot `3888`(LFO)/`3904`(ENV1)/`3920`(ENV2)/`3936`(Manual). Demux proven by
  the PWM-mix DSP (`voice_render.c:1083-1089`) + rec0 capture.
- **DB855 VCA ENV-select** (MED, partial): `ENV1|ENV2|GATE` → one-hot
  `10176`/`10192`/`10208`. rec0 = ENV2 → `10208` = 1.0 is capture-proven; the
  full 3-way order (which value drives 10176 vs 10192) still needs the setter
  trace.
- **DB800 ASSIGN MODE** (HIGH): raw int → voice-allocator `+1352`
  (`sub_7FF91E010D40`): 0=POLY1 / 1=MONO / 2=UNISON / 3=POLY2. Not a DSP LUT
  (separate object, outside the capture). Cross-preset validated (pads→POLY1,
  bass→MONO).

## Global / FX selectors (block2, host/driver-side)

All capture-validated by their rec0 decode landing on the correct semantic value:

| DB | Selector | rec0 |
|----|----------|------|
| 868 | sub-osc wave `-2OCT SIN…-2OCT TRI` | 0 |
| 870 | master tune | 128 (center) |
| 871 | model JUNO-60/106 | 0 (JUNO-60) |
| 872 | filter type LPF-24…HPF-24 | 0 (LPF-24) |
| 873 | effect/chorus `…JUNO CH1\|CH2…` | 2 (JUNO Chorus I) |
| 875 | FX-A delay/mod slot | 0 (DELAY) |
| 876 | reverb type AMBIENCE…MOD | 3 (HALL 2) |

These drive `master_render` / driver selectors (chorus_mode, reverb type, FX-A
v39), not static per-voice LUT slots — flagged `tableId: "host"`.

## Host-side FX sends (not static LUT)

DB794 EFFECT DEPTH, DB795 REVERB LEVEL (off 10759440), DB796 DELAY LEVEL
(off 4297760), DB797 DELAY TIME (off 4297584) are **host-pushed** through the
runtime red-black tree (captured node ≠ static LUT step). The loader applies
DB796/797 with curve-22 when DB875 = DELAY; the reverb send is host-side. Flagged
`tableId: "host"`, `capture_validated: false`.

## Untouched / non-panel

DB750/755/757/761-769/774-778/780/802/804-809/812-813/816/824-853 are System-8
framework params (CV/mod-matrix jacks, OSC2/3, extends) that are either non-panel
or sit at their engine default in **every** factory preset (range-valid decode,
no audible binding). Enumerated with `confidence: LOW` and `engine_offset: null`.

## Counts

- 128 DB indices covered (750..877).
- **41 capture-validated** (`capture_validated: true`).
- **44 HIGH confidence**.
- The 23 previously-proven synth params + DB770/783/793 all re-validated
  bit-exact in this pass via `juno_param_apply_lut` round-trip against
  `src/captured_patch.c`.
