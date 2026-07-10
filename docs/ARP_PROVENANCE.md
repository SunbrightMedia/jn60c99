# CKbdArp / CArpeggio — binary provenance for `carp.c` / `carp.h`

Every claim below is traced to the decompiled binary
`aea4b19d-JUNO60VST3_64bit.vst3` (PE ImageBase `0x180000000`). The decompile was
rebased at `0x7FF91DC60000`, so a symbol `sub_7FF91E0xxxxx` has
`RVA = 0x7FF91E0xxxxx − 0x7FF91DC60000`. Data-table RVAs below were computed the
same way and read back from the PE with `pefile` (`.rdata`, VA range
`0x934000..0xC4244A`).

> Note on the task's RVA hint: the table was named `unk_7FF91E624480` with an
> alleged "RVA 0x624480". That is the low 24 bits of the *symbol VA*, not the
> RVA. The real RVA is `0x7FF91E624480 − 0x7FF91DC60000 = 0x9C4480`. Reading
> `0x624480` returns x86 code; reading `0x9C4480` returns the pattern table.
> All tables here use the base-corrected RVAs and were verified to contain data.

---

## 1. Object field map (CArpeggio, `a1 + N`)

| Offset | Meaning | Where proven |
|---|---|---|
| `+56`   | `field56` octave-pass counter (incremented on pattern wrap, clamped in selectors) | inc at `sub_7FF91E020260`:124; clamp in every selector |
| `+208`  | per-note press ref-count (WORD[128]) | `sub_7FF91E023440`:2046-2049 |
| `+464`  | per-note stored velocity (BYTE[128]) | `sub_7FF91E023440`:2054; read `sub_7FF91E020260`:216,223 |
| `+610`  | step timing records, 6 bytes/step `{dur:u16, gateLen:u16, accent:u8, velScale:u8}` | written by `sub_7FF91E01F3D0`; read `sub_7FF91E020260`:132 |
| `+804`  | runtime active-note records, 12 bytes × 16 slots | `sub_7FF91E01DD80`, `sub_7FF91E01F9F0` |
| `+996`  | runtime STEP×SLOT grid, 4 bytes/cell, 64 bytes/patStep | `sub_7FF91E01F9F0`; read `sub_7FF91E020260`:131,138 |
| `+3054` | `nslots` active slot count (char) | selectors + `sub_7FF91E020260`:133 |
| `+3055` | pattern length (char) | `sub_7FF91E01F9F0`:2788; `sub_7FF91E020260`:118 |
| `+3056` | current pattern-step position | `sub_7FF91E020260`:117-125 |
| `+3064` | **held-note list, sorted ascending** (int8[128]); `[count-1]` = top note | `sub_7FF91E023440`; selectors |
| `+3192` | per-note "is held" flag (BYTE[128]) | `sub_7FF91E023440`:2053,2089 |
| `+3320` | `count` = number of held notes | `sub_7FF91E023440`:2090 |
| `+3460` | selector "has started" flag | all selectors |
| `+3461` | UP&DOWN direction flag (1=up, 0=down) | `sub_7FF91E01E5C0` |
| `+3464` | selector running index | all selectors |
| `+3468` | request-octave-advance flag | `sub_7FF91E01EFC0`:254; cleared by span selectors + `sub_7FF91E020260`:179 |
| `+3472` | `oct_shift` current octave offset (× semitone) | `sub_7FF91E020260`:200; span selectors |
| `+3476` | `range` = octaves − 1 | set by `sub_7FF91E01FE60`; read by selectors + `sub_7FF91E020260`:175 |
| `+3480` | selector function pointer | set by `sub_7FF91E01FCB0`; called `sub_7FF91E020260`:145 |
| `+4051` | velocity sensitivity | `sub_7FF91E0235A0`:2195 |
| `+4052` | fixed velocity (0 = use input) | `sub_7FF91E0235A0`:2194 |
| `+4056` | owner / note-sink pointer | `sub_7FF91E022F20`:1910 |

---

## 2. Per-mode ordering (exact)

`ARPEGGIO TYPE` (stored 0..5) selects a note-selector through the map
`word_9C4458[type].byte2` → the dispatch `sub_7FF91E01FCB0` (`a1+3498` → case):

| TYPE | selector byte | selector fn | behaviour |
|---|---|---|---|
| 0 | 0  | `sub_7FF91E01EFC0` | **UP** |
| 1 | 20 | `sub_7FF91E01E5C0` | **UP&DOWN** |
| 2,3,4,5 | 19 | `sub_7FF91E01E850` | **DOWN across octaves** |

- **UP** `sub_7FF91E01EFC0` (0x3BEFC0): `note = sorted[step]`, `step++`; when
  `step > count-1` reset to 0 and raise `oct_adv_flag(+3468)`. The octave offset
  is then advanced by the step trigger (below).
- **UP&DOWN** `sub_7FF91E01E5C0` (0x3BE5C0): index `i` bounces over
  `0 .. count*(range+1)-1`; `note = sorted[i % count]`, `oct_shift = i / count`.
  Direction flips exactly at the endpoints (`+3461`), so top/bottom are each
  played once (no doubling). Clears `oct_adv_flag`.
- **DOWN** `sub_7FF91E01E850` (0x3BE850): index `i` descends over
  `count*(range+1)-1 .. 0` (then wraps to top); `note = sorted[i % count]`,
  `oct_shift = i / count`. Clears `oct_adv_flag`.
- Single-octave DOWN `sub_7FF91E01E6E0` (0x3BE6E0, selector 3) is transcribed
  too but is not reached by TYPE 0..5.

All selectors share the fallback `if (note < 0) note = sorted[count-1]`
(`*(char*)(count + a1 + 3063)`), and the `field56` clamp
`if (field56 > max(count-nslots,0)) field56 = 0`.

**Octave advance + fold** — from the step trigger `sub_7FF91E020260`
(0x3C0260) lines 173-204, applied after the selector:
```
if (oct_adv_flag && range) {           // only UP raises the flag
    oct_adv_flag = 0;
    if (range < 0) oct_shift = (oct_shift-1 < range) ? 0 : oct_shift-1;
    else           oct_shift = (oct_shift+1 > range) ? 0 : oct_shift+1;
}
pitch = note + 12*oct_shift;
if (pitch > 127) pitch = pitch - 12 - 12*((pitch-128)/12);
if (pitch <   0) pitch = pitch + 12 + 12*((~pitch)/12);
```

Verified runtime output (C,E,G held): UP `60 64 67…`; UP 2-oct
`60 64 67 72 76 79…`; UP&DOWN `60 64 67 64 60 64 67…`; DOWN 2-oct
`79 76 72 67 64 60…`.

---

## 3. Extracted tables (raw bytes + format)

### 3a. TYPE→selector map — `word_9C4458` (RVA 0x9C4458)
36 bytes = 6 records × 6 bytes. Raw:
```
01 02 00 00 00 00 | 01 02 14 00 00 00 | 01 02 13 00 00 00
01 02 13 00 00 00 | 01 02 13 00 00 00 | 01 02 13 00 00 00
```
Only `byte[2]` is consumed (`a1+3498`, → `sub_7FF91E01FCB0`): `{0,20,19,19,19,19}`.
`byte[5]` → `a1+4052` (fixed velocity) = 0 for every type, i.e. the arp always
uses the played key's velocity.

### 3b. RATE table — `word_9C43B8` (RVA 0x9C43B8)
60 bytes = 10 × {evenDur:u16, oddDur:u16, accentMod:u16}, durations in 24-PPQN
ticks. Read by `sub_7FF91E01F3D0`. `evenDur == oddDur` in every row → the step
length is one constant per rate index:
```
idx : dur ticks : subdivision
 0  :   24  : quarter
 1  :   16  : dotted-eighth
 2  :   12  : eighth
 3  :    8  : eighth-triplet
 4  :    6  : sixteenth
 5  :    4
 6  :    3
 7  :    2
 8  :    1
 9  :    1
```
(accentMod column = `1,1,2,3,4,6,8,12,16,24`; `sub_7FF91E01F3D0` writes
`accent = (step % accentMod != 0)` into `+610[+4]` — used for accent velocity,
not transcribed into note output.)

### 3c. GATE table — `word_9C43F8` (RVA 0x9C43F8)
10 × u16 gate percent: `30,40,50,60,70,80,90,100,120,0`. `sub_7FF91E01F3D0`
computes `gateLen = dur * gate% / 100` (integer) → `+610[+2]`. Index 8 (120%)
gives legato overlap, index 9 (0%) silences.

### 3d. Pattern-grid slab — `unk_9C4480` (RVA 0x9C4480)
Slab stride `8250` bytes per index `a3`; each slab holds 15 sub-patterns of
`550` bytes indexed by `a4` (`8250 = 15 × 550`). Loader
`sub_7FF91E023010`:1955-2007. A 550-byte sub-pattern =
`6-byte header + 16 blocks × 34 bytes`:
- header `[b0..b5]`; the loader uses `b1>>2` (→ gate/pattern index `a1+16`),
  `b3>>1` (→ sensitivity `a1+4051`), `b5>>2` (→ pattern length `a1+3055`).
- each 34-byte block = one **slot**: `block[0]` = default note (60), `block[1..32]`
  = a per-patStep on/off velocity cell (byte, `&0x7F`), `block[33]` unused.
  The expansion `sub_7FF91E01F9F0` scatters `block[1+patStep]` into grid cell
  `+996 + 64*patStep + 4*slot` (byte 0 only).

Sub-pattern 0 raw (first 14 bytes): header `0A 1C 2C C8 00 04`, block0
`3C 7F 00 00 00 00 …` → i.e. default note 0x3C=60, patStep-0 velocity 0x7F=127.

---

## 4. Timing / gate derivation

Clock handler `sub_7FF91E023C50` (0x3C3C50), gating condition:
```
if (clockFlag(owner+6) && (clkCounter(owner+0) % (24 / (2 - (rateSw(owner+5)!=0))) == 0)) …
```
→ divisor `12` when `rateSw==0`, `24` when `rateSw!=0`. The arp is at
`owner + 1304`. This is the concretely-decoded quarter/eighth clock.

`carp.c` derives, given sample rate `SR` and host `BPM`:
```
samples_per_tick = SR * 60 / (BPM * 24)            // 24 PPQN
step_ticks       = 24 / (2 - (division!=0))        // 12 or 24   (default)
                 = RATE_TABLE[rate_index][0]       // if use_rate_table
step_samples     = step_ticks * samples_per_tick
gate_ticks       = step_ticks * GATE_TABLE[gate_index] / 100   // integer, per F3D0
gate_samples     = gate_ticks * samples_per_tick
```
Verified: 120 BPM / 48 kHz → division 0 = 12000 samples/step (eighth),
division 1 = 24000 (quarter); gate index 7 (100%) closes at the step boundary.

---

## 5. Velocity (exact)

Note-on override `sub_7FF91E0235A0` (0x3C35A0):
```
sens  = a1+4051;  fixed = a1+4052
v6    = (uint8)(127 - sens * (127 - inVel) / 100)
base  = fixed ? fixed : perNoteVel
vel   = (uint8)(base * v6 / 127);   if (vel == 0) vel = 1
```
`inVel`/`perNoteVel` are the velocity the key was pressed with (`a1+464[note]`).
With sens=0, fixed=0 (the factory default) `vel = perNoteVel` unchanged.

---

## 6. Held-note list (exact)

Insertion sort — `sub_7FF91E023440` (0x3C3440), non-poly branch (`a1+3489==0`):
a genuinely new note shifts every sorted entry `>=` it up one slot and inserts,
keeping `+3064[]` ascending; `+3320` is the count; `+3192[note]` de-dups a
re-press (which only bumps the `+208` ref count and refreshes `+464` velocity).
Removal — `sub_7FF91E01F2A0` (0x3BF2A0): decrement ref count; at 0, delete from
the sorted list (shift the tail down) and clear `+3192[note]`.

---

## 7. What remains genuinely ambiguous (NOT guessed)

> **RESOLVED (both items 1 and 2 below were closed later).** The STEP×SLOT grid
> is now fully modeled and driven by `carp.c` (`carp_set_scatter` + the per-slot
> step loop), verified **330/330 bit-exact** against the plugin's own code under
> Unicorn across all 110 reachable patterns × 3 selector/range setups. The slab/sub
> selection is proven: **slab = SCATTER TYPE, sub = SCATTER DEPTH + 7** (loader
> `sub_7FF91E023010`), and the per-patch recall of SCATTER TYPE/DEPTH is bound to
> value-tree leaf 92/93 = record byte 322/330 (param-DB dispatch cases 834/835).
> See `scratchpad/oracle/arp_pattern_grid_spec.md` and `scatter_recall_spec.md`.
> The historical notes below are kept for provenance.

1. **Parameter binding → loader args `a2/a3/a4`.** `sub_7FF91E023010` takes
   `(type, a3, a4)` where `a3` picks the 8250-byte slab and `a4` the 550-byte
   sub-pattern. *(RESOLVED: `a3 = SCATTER TYPE`, `a4 = SCATTER DEPTH + 7`, driven
   from the param-DB setters `sub_7FF91E024F10` (cfg[8]) / `sub_7FF91E024EE0`
   (cfg[9]=v+7) via `sub_7FF91E020EC0`; the full STEP×SLOT grid `+996` is now
   expanded, pruned+sorted, and iterated one selector call PER ACTIVE CELL by
   `carp.c`. The default slab0/sub7 reduces to one selector call per step, so the
   earlier one-call-per-step model was the correct special case for the factory
   default — which all 64 factory patches use.)*

2. **Grid note-hold field (`+996` cell `+2`).** `sub_7FF91E01DD80` zeroes the
   grid and `sub_7FF91E01F9F0` writes only byte 0 of each cell, yet the step
   trigger reads a `u16` hold at cell `+2` for note-off scheduling
   (`sub_7FF91E020260`:218). *(RESOLVED: cell `+2` is the per-cell gate length
   written by the backward tie-accumulation `sub_7FF91E01FED0` (ported as
   `fed0_gates` in `carp.c`); for the reachable patterns every tie is a pure hold
   and the base gate is `dur * gate% / 100`, so at the factory default it equals
   the `+610` gate length used before. Note-off ticks are now bit-exact for all
   110 patterns.)*

3. **Two rate mechanisms.** The owner clock divisor (12/24, §4) and the fine
   RATE table (`rate_index` 0..9, §3b, via `a1+4047`/`sub_7FF91E0234F0`) are
   both present. The mapping from any single UI "rate/step" control onto them is
   part of the untraced parameter-binding layer (item 1). `carp.c` exposes both:
   `carp_set_division` (default, decoded clock) and `carp_set_rate_index`
   (`use_rate_table`).

4. **`ARPEGGIO STEP` (0..5) → octave-range mapping** `{0,1,2,2,2,2}` in
   `carp_set_range` is asserted by `ARP_FINDINGS.md` (from `Script.xml`), not
   re-derived here; `sub_7FF91E01FE60` stores the range value verbatim to
   `+3476`, so any 0..5→range table is a UI-layer decision, not engine logic.

---

## UPDATE (state-diff campaign): step rate + gate corrected from the binary

A full binary re-derivation (scratchpad/oracle/arp_rate_findings.md) corrected two
defaults the earlier transcription got wrong:

- **Step rate = RATE_TABLE[rate_index], rate_index = 4 → 6 ticks = 1/16** at 120 BPM.
  Enabling the arp runs sub_7FF91E024F40 which hard-codes cfg[7]=2 → the rate map
  {0,0,4,1,3,5}[2] = 4. There is NO user arp-RATE parameter. The `24/(2-(division!=0))`
  = 12/24-tick "owner clock" the port previously used is actually the chord RE-LATCH
  quantizer (sub_7FF91E023C50 via router+5), never the step length. Fix: carp_init
  `use_rate_table=1, rate_index=4` (was 0/0 → eighth notes, the audible "half-time" bug).
- **Gate default = index 7 (100%)**, from the default sub-pattern header (0x1C>>2). The
  bridge's override to index 3 (60%) is removed.
- First note of an UP phrase = the lowest held key at the played octave (60, then
  72, 84 for range 2) — never an octave-high start. Velocity is pass-through of the
  played key (grid vel 127 with sens 100 makes the sens term vanish).

VERIFIED: carp_tick with held C4 @120 BPM emits notes at t=0.000, 0.125, 0.250, …
(1/16), first note 60. make test green.
