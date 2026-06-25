# JUNO-60 (RolandCloud) Arpeggiator — Reverse-Engineered DSP / Clock Notes

> **Panel exposure (confirmed from the plugin UI).** The JUNO-60's *entire* arp panel
> is: **ARPEGGIO** on/off, **ARP MODE** (UP / UP & DOWN / DOWN), **ARP RANGE** (1 / 2 / 3).
> That is the whole user-facing arp, and it is implemented by the **`CArpeggio`** base
> engine (direction selectors + octave range `+3472`/`+3476`). The derived **`CKbdArp`**
> 150-pattern sequencer (`word_7FF91E624480`, §4) is **RolandCloud framework code compiled
> into the DLL but NOT exposed by the JUNO-60 panel** — it is unused for this product. The
> faithful port (`src/arp.c`) transcribes only `CArpeggio`; the pattern layer is documented
> below for reference but deliberately not implemented. See `docs/EXPOSURE.md` (if present)
> for the general framework-vs-exposed boundary.

Source: decompiled C in `allcode/decomp_380000.c` and `allcode/decomp_3C0000.c`.
Image base `0x7FF91DC60000`. Data segments in `data_sections/data_sections/seg_*.bin`
(file names are RVA-based, e.g. `seg_rdata_935650.bin` covers rva `0x935650..0xC43000`).

Two classes implement the arp:
- **`CArpeggio`** — base step/clock engine. Ctor `sub_7FF91E01D270` @ rva `0x3BD270`.
- **`CKbdArp`** — derived keyboard-arp (pattern preset loader). Ctor `sub_7FF91E022F20`
  @ rva `0x3C2F20`; pattern loader `sub_7FF91E023010` @ rva `0x3C3010`.

Confidence legend: **[H]** high (directly read from code), **[M]** medium (inferred from
data + code), **[?]** uncertain / flagged in Open Questions.

---

## 1. Class / state map (object offsets, all relative to engine `a1`)

The arp object is a single large struct (~4080 bytes). Offsets confirmed from the cited code.

### Clock / step state (CArpeggio)
| Offset | Type | Meaning | Confidence |
|--------|------|---------|------------|
| `+0`   | vptr | vtable (`CArpeggio` / `CKbdArp`). `(**a1)(...)` = noteOn callback; `(*a1+8)` = noteOff; `(*a1+24)` = noteOn2 | [H] |
| `+8`   | u16  | PRNG state, seeded `31415` in ctor (used by `sub_7FF91E020E50` LCG: `x=18813*x+1`) | [H] |
| `+16`  | s32  | active voice/note count; scanner skips emitting when `>= 11` (voice limit) | [H] |
| `+20`  | s32  | host/sample position target (`+20` advanced by driver; loop runs while `+24 != +20`) | [H] |
| `+24`  | s32  | current processed position (`[a1+24]`); equals `+3048` triggers a step tick | [H] |
| `+32`  | ptr  | pointer to staged pattern source (set to `a1+3496` by `sub_7FF91E01F9C0`) | [H] |
| `+40`  | u8   | "pattern dirty / reload pending" flag | [H] |
| `+44`  | s32  | run/gate state machine (0=idle, 1..3 transient states; driver `sub_7FF91E01DEA0`) | [M] |
| `+48`  | s32  | one-shot countdown timer (decremented each driver call) | [M] |
| `+52`  | s32  | step counter (incremented on each tick) | [H] |
| `+56`  | s32  | position counter (parallel step counter, used by direction modes) | [H] |
| `+60`/`+64` | s32 | cached step/notecount for chord build (`sub_7FF91E01EDB0`) | [M] |
| `+196` | u8   | "use stored per-key velocity" flag (scanner: `v11 = key velocity`) | [M] |
| `+197` | u8   | arp enabled/running flag (`sub_7FF91E01FE90` sets it; driver gate) | [H] |
| `+597` | u8   | "collapse to single (highest) note" / chord-mono flag — when set, scanner picks max note `v6` instead of emitting per step | [?] |
| `+600`/`+604`/`+608` | s32/u8 | hold/latch timing (`sub_7FF91E01FE80`) | [M] |
| `+3048`| s32  | accumulated tick-duration; tick fires when `+24 == +3048`; advanced by `+610` table | [H] |
| `+3053`| u8   | clock divider / PPQN base = **16** (set in ctor) | [H] |
| `+3054`| s8   | number of active steps in current pattern | [H] |
| `+3055`| s8   | clock period — step advances when sub-counter `>=` this | [H] |
| `+3056`| s32  | clock sub-counter (`++`, reset to 0 on advance) | [H] |
| `+3060`| u8   | transpose center reference (subtracted in `sub_7FF91E01ED50`) | [M] |

### Step / note tables
| Offset | Layout | Meaning | Confidence |
|--------|--------|---------|------------|
| `+610 + 6*step` | u16 | per-step **duration** table (added into `+3048` each tick) | [H] |
| `+612 + 6*step` | u16 | secondary per-step duration (gate-on portion; `sub_7FF91E0200D0`) | [M] |
| `+804 + 12*v` | 12B | active "voice slot" array (16 slots): `[0]`=playing note (0x80=free), `[1]`=source key, `+2`=u16 note, `+6`=u32 release-position (`+24+gate`) | [H] |
| `+996 + 64*step` | 64B | per-step note/velocity expansion table (`v9`); byte0=on/off (mask 0x7f), `+2`=u16 velocity offset | [H] |
| `+464 + key` | u8 | per-key stored velocity | [H] |
| `+208 + 2*key` | u16 | per-key hold counter (`&0x7FFF` = count, `0x8000`=sustained bit); `sub_7FF91E023440`/`sub_7FF91E01F110` | [H] |
| `+3064 + i` | s8 | **held-note list** (sorted MIDI keys; `-1`/0xFF = empty) | [H] |
| `+3192 + key` | u8 | per-key "is in held list" flag | [H] |
| `+3320` | s32 | held-note count (size of `+3064` list) | [H] |
| `+3324 + slot` | u8 | held-note → voice-slot back-reference (0x80 = none) | [H] |
| `+3452` | s8 | last/most-recent held key | [H] |

### Direction / mode state
| Offset | Type | Meaning | Confidence |
|--------|------|---------|------------|
| `+3456`| s32  | direction-mode misc (init `-1` in ctor) | [M] |
| `+3460`| u8   | "first tick done" latch; init `256` as `_WORD` (`[3460]=1`-ish on use) | [M] |
| `+3461`| u8   | up-down pendulum phase (1=going up, 0=going down); `sub_7FF91E01E990` | [H] |
| `+3464`| s32  | current step index within the direction sequence | [H] |
| `+3468`| u8   | "octave wrap pending" flag (consumed by scanner octave-shift block) | [H] |
| `+3472`| s32  | current octave offset (×12 applied to note); `sub_7FF91E01FE60` resets to 0 | [H] |
| `+3476`| s32  | octave range (number of octaves to span); set by `sub_7FF91E01FE60` | [H] |
| `+3480`| ptr  | **direction step-selector function pointer** (see §5) | [H] |
| `+3488`| u16  | misc init 0 | [M] |
| `+3489`| u8   | selects scanner variant: `sub_7FF91E0204E0` (multi-direction) vs `sub_7FF91E020260` (simple) | [H] |

### CKbdArp-specific (set in ctor `sub_7FF91E022F20`)
| Offset | Type | Meaning | Confidence |
|--------|------|---------|------------|
| `+3496..+4045` | bytes | **staged pattern record** (550-byte preset body copied here by loader) | [H] |
| `+3496` | u8 | step clock period (= header byte5 `>>2`) | [H] |
| `+3497` | u8 | range/octave param (= header byte1 `>>2`) | [H] |
| `+3500` | u8 | param (= header byte3 `>>1`) | [H] |
| `+4047` | u8 | rate/division param fed to `sub_7FF91E01F3D0` | [M] |
| `+4048`/`+4049` | u8 | cached params (v8/v11 from loader) | [M] |
| `+4050` | u8 | octave shift accumulator (`sub_7FF91E0234C0` clamps ±4) | [H] |
| `+4051` | u8 | accent/velocity depth (used by `sub_7FF91E0235A0`) | [H] |
| `+4052` | u8 | fixed-velocity override (0 = use per-note) (`sub_7FF91E0235A0`) | [H] |
| `+4056` | ptr | engine/voice-allocator pointer (note out target) | [H] |
| `+4064` | u8 | hold/latch enable (`sub_7FF91E023450`/`sub_7FF91E023570`) | [M] |
| `+4076` | s32 | direction/mode value (`sub_7FF91E01FE60` octave range) | [M] |

---

## 2. Clock & step algorithm (scanner `sub_7FF91E020260` @ rva 0x3C0260)

The scanner is the per-tick step engine. It is invoked from the driver each time the
sample-accurate position counter `+24` reaches the next tick boundary `+3048`
(call sites: `decomp_380000.c:27277`, `decomp_3C0000.c:522`, `decomp_3C0000.c:604`).

```
scanner(a1):                       # = sub_7FF91E020260
    a1[3056] += 1                  # clock sub-counter
    if a1[3056] >= a1[3055]:       # reached step clock period?
        a1[52] += 1                # advance step counter
        a1[56] += 1                # advance position counter
        a1[3056] = 0
        step = 0
    else:
        step = a1[3056]            # NOTE: sub-counter doubles as intra-step index
    a1[3048] += u16(a1[610 + 6*step])   # add this step's duration to next-tick boundary

    if a1[3054] <= 0: return       # no active steps
    v6 = -1                        # running "max note" for chord-collapse mode
    for v7 in 0 .. a1[3054]-1:     # iterate the pattern's active steps
        cell = a1[996 + 64*step + 4*v7]   # = v9
        if (cell & 0x7f) == 0: continue   # step off for this voice
        if a1[16] >= 11: { v6 = max(v6, slot.note); continue }   # voice limit -> just track

        if a1[3320] != 0:          # there are held keys
            key = (*a1[3480])(a1, v7)      # DIRECTION SELECTOR picks a held key (see §5)
            if key < 0: continue
            slot = a1[3324 + key]          # existing voice slot for this key
            if slot < 0x80 and slot >= v7: # retrigger -> note-off previous
                noteOff(prev note); free slot
            # note-off the voice currently in this output slot (v5)
            if v5.note < 0x80: noteOff(v5.note); free
            # --- octave handling ---
            if a1[3468]:                   # octave-wrap pending
                consume; step a1[3472] within [0, a1[3476]]  (dir-dependent)
            note = key + 12 * a1[3472]     # apply octave offset
            note = wrap_into_0..127 by ±12 # (folds out-of-range back by octaves)
            if a1[597]:                    # chord-collapse: keep only highest
                v6 = max(v6, note)
            else:
                a1[3324+key] = v7          # bind key->slot
                v5.key = key
                vel = a1[196] ? a1[464+key] : (cell & 0x7f)
                v5.note = note
                v5.release_pos = a1[24] + u16(a1[996+64*step + 4*v7 + 2])  # gate end
                noteOn(note, vel, a1[464+key])   # vtable[0]
```

Note-OFF emission is handled both inline (retrigger) and by the driver loop:
`sub_7FF91E0207E0` / `sub_7FF91E020960` / driver `sub_7FF91E01DEA0` scan the 16 voice
slots at `+806` (=`+804+2`) and, when `slot.release_pos (+6) == current position (+24)`,
call `noteOff` and free the slot. So gate length = `release_pos - onset_pos`, derived from
the per-step `+612`/`+996+...+2` duration fields.

**Clock source:** sample/host-driven. The driver (`sub_7FF91E01DEA0`, and inline at
`decomp_380000.c:27205+`) increments `+20` from the host position and chases it with `+24`,
firing the scanner whenever `+24 == +3048` (the accumulated tick boundary). Internal-vs-host
tempo is upstream of this struct (the duration tables in `+610` encode the per-step timing in
the engine's tick units; base divider `+3053=16`). **[M]** on exact PPQN mapping.

The expanded scanner `sub_7FF91E0204E0` is identical in structure but inlines the
direction state machine (calls `+3480` and then mutates `+3472`/`+3461`/`+3468`
according to which selector function is installed) — selected when `+3489` is set.

---

## 3. Held-note management

Held keys live in the sorted list `+3064[i]` (s8 MIDI numbers, `-1` empty), count in `+3320`,
membership flag `+3192[key]`, and most-recent key in `+3452`.

**Add** (`sub_7FF91E023440` @ rva 0x3C3440): on key-down it
- increments per-key hold counter `+208+2*key` (saturating at 0x7FFF), bumps `+200`/`+204`,
- stores velocity `+464[key] = velocity`,
- if not already held: **inserts into `+3064` keeping ascending order** (shifts entries
  `>= key` up), sets `+3192[key]=1`, `++[+3320]`, `+3452=key`.
- A flat (mode `+3489`) variant just appends at the tail (`+3064[count]=key`).

**Remove** (`sub_7FF91E01F110` → `sub_7FF91E01F2A0` @ rva 0x3BF2A0): on key-up it
decrements the hold counter; when it reaches zero it removes the key from `+3064`
(shift-down compaction, or list scan in flat mode), clears `+3192[key]`, `--[+3320]`,
updates `+3452` to the new tail. When the list empties and no notes sustain, it flushes
all voices (`sub_7FF91E01D3A0`).

The list is always maintained **sorted ascending**; direction modes (§5) walk it
forward/backward/randomly rather than re-sorting.

---

## 4. Pattern preset data

### Tables (`.rdata`)
- **`word_7FF91E624458`** (rva `0x9C4458`) — per-**mode** header records, stride 6 bytes
  (3× int16). Indexed by `a2` (= mode value `a1[6]`). Loader copies record[0..3] →`[+3496]`
  and record[4..5] → `[+3500]`. First records decode to `(513,0,0)`, `(513,20,0)`,
  `(513,19,0)…` — i.e. a fixed `0x0201` tag plus a small parameter. **[M]**
- **`unk_7FF91E624480`** (rva `0x9C4480`) — main pattern table.
  - **Style stride = 8250 bytes** (`a3` = style index).
  - **Variation stride = 550 bytes** (`a4` = variation index), `8250/550 = 15` variations/style.
  - **Styles = 10**, variations = 15 (see bounds below).

### Counts (from loader callers)
- `sub_7FF91E024920` (`decomp_3C0000.c:3277`): style index `a1[8]` is checked `<= 9`
  → **10 styles (0..9)**.
- Same fn (`:3286-3288`): variation `a1[9] = v5 + 7`, checked `<= 0xE` → **15 variations (0..14)**.
  (matches 8250/550.)
- Synth-patch params per style come from a *different* table `dword_7FF91E6386D0`
  (stride `150` int32 per style; `sub_7FF91E020EC0`) — not the arp pattern.

### 550-byte variation record layout
```
offset 0..5    : 6-byte header
   byte0        : step-count source field (clamped to 32 by expander)   [values 0x0A typ.]
   byte1        : =28 (const) -> (>>2)=7  -> [+3497] range/octave param
   byte2        : 0
   byte3        : =200(0xC8) const -> (>>1)=100 -> [+3500]  (accent/velocity-scale base)
   byte4        : 0
   byte5        : CLOCK DIVIDER -> (>>2) = step period [+3496]
                  observed {0x04,0x08,0x0C,0x10,0x18,0x20,0x40} -> {1,2,3,6? 4,6,8,16}
offset 6..549  : 16 step records, 34 bytes each (16*34 = 544)
   per step (34 bytes):
     byte0      : MIDI note, absolute (centered on 60 = middle C). 0x80 = step OFF.
     byte1..32  : 32 micro-gate cells. (cell & 0x7f)!=0 => gate held that micro-tick;
                  the first 0x80 terminates the gate (note-off). Run length => gate length.
     byte33     : padding / stride filler
```
The expander `sub_7FF91E01F9F0` (@ rva 0x3BF9F0) reads `src[0]`=stepcount (clamped 32),
then for each step copies byte0 → voice-note table `+804+12*s` and spreads the 32 gate
cells into the `+996+64*s` (`+256` dest base) micro-gate matrix, then `sub_7FF91E01D540`
computes onset/gate boundaries and `+2256` = lowest note in the pattern (default 60).

### Decoded samples (full data in `refs/arp_patterns.json`)
- **style 0 var 0**: single note step0 = `C4` (60), gate 7 micro-ticks. (Most style-0 variations
  are minimal single-note seeds.)
- **style 8 var 10**: 7 active steps — notes `C4,F4(65),G4(67),C5(72),D#4(63),F4,G4` —
  a chord/sequence template; varying gate runs per step.
- **style 9 var 2**: full 10-step ascending arpeggio `C2 E2 G2 C3 E3 G3 C4 E4 G4 C5`
  (C-major broken chord across octaves), clock div 0x40 (slow).

The note bytes are *absolute templates*; at play time `sub_7FF91E01ED50` re-bases each
template note onto the actually-held keys: `out = lastKey + templateNote - center(+3060)`,
so the preset encodes interval/voicing relative to the held chord.

`refs/arp_patterns.json` contains all 10×15 = 150 decoded records (header fields + 16 steps
each with note/on-flag/note-name/gate-microticks), plus the mode header table.

---

## 5. Modes (arp directions)

The active direction is a **function pointer at `+3480`**, installed by the mode selector
`sub_7FF91E01FCB0(a1, modeIndex)` (@ rva 0x3BFCB0). 21 modes (0..20) plus default:

| modeIndex | selector fn (rva) | inferred behaviour |
|-----------|-------------------|--------------------|
| 0  | sub_7FF91E01EFC0 | direction variant | 
| 1  | sub_7FF91E01F060 | direction variant |
| 2  | sub_7FF91E01F0C0 | direction variant |
| 3  | sub_7FF91E01E6E0 | direction variant |
| 4  | sub_7FF91E01E790 | direction variant |
| 5  | sub_7FF91E01E800 | direction variant |
| 6  | sub_7FF91E01E400 | direction variant |
| 7  | sub_7FF91E01E4E0 | direction variant |
| 8  | sub_7FF91E01E560 | direction variant |
| 9  | sub_7FF91E01EDB0 | chord build (sub_7FF91E01EDB0 builds simultaneous chord) |
| 10 | sub_7FF91E01EEC0 | direction variant |
| 11 | sub_7FF91E01ED50 | "as-played"/transpose passthrough (uses `+3452` last key) |
| 13 | sub_7FF91E01E940 | direction variant |
| 14 | sub_7FF91E01EF80 | direction variant |
| 15 | sub_7FF91E01EC80 | **UP** (`+3464`++ wrap to 0, sets octave-wrap) |
| 16 | sub_7FF91E01EB10 | **DOWN** (`+3464`-- wrap to top) |
| 17 | sub_7FF91E01E990 | **UP-DOWN / pendulum** (`+3461` phase toggles, bounces at ends) |
| 18 | sub_7FF91E01EBF0 | **RANDOM** (LCG `sub_7FF91E020E50` picks index) |
| 19 | sub_7FF91E01E850 | direction variant |
| 20 | sub_7FF91E01E5C0 | direction variant |
| default | sub_7FF91E01ED30 | ORDER / as-played fallback (`+3064[idx]`, fallback to last) |

Each selector takes `(a1)` (and step index), reads the sorted held list `+3064`,
maintains its own cursor in `+3464`, sets `+3468` (octave-wrap pending) at sequence ends,
and returns the chosen MIDI key. The scanner then applies octave (`+3472`/`+3476`) and
velocity. Confirmed in detail for modes 15/16/17/18 (`sub_7FF91E01EC80/EB10/E990/EBF0`,
`decomp_380000.c:27937/27832/28003/28043`). The remaining selectors are the same shape but
their exact ordering was not individually traced — see Open Questions.

The simple scanner `sub_7FF91E020260` calls `+3480` generically (no per-mode octave logic),
while `sub_7FF91E0204E0` (selected by `+3489`) branches on the *identity* of the installed
function (`== sub_7FF91E01EBF0` random / `== sub_7FF91E01EB10` down / `== sub_7FF91E01E990`
up-down) to drive `+3472`/`+3461` octave advancement.

---

## 6. Open questions / unverified

- **Modes 0–14, 19, 20** (`sub_7FF91E01EFC0` … `sub_7FF91E01E5C0`): exact direction
  semantics not individually traced; only their installation order in `sub_7FF91E01FCB0`
  (`decomp_380000.c:28906`) and that they share the held-list-walk shape is confirmed.
- **`+597`** (chord-collapse / mono flag) and **`+3489`** (scanner-variant select):
  read-sites confirmed in the scanner, but the UI parameter that sets them was not located.
- **`+3460`** initialized as `256` (`_WORD`) in ctor but used as a byte latch — the high
  byte's purpose is unclear (likely two adjacent fields `+3460`/`+3461`).
- **Header table `word_7FF91E624458`** semantics: the `0x0201` tag and the small int
  parameter (`0,20,19…`) are copied to `[+3496]`/`[+3500]` but their musical meaning
  (mode-specific step-count / gate default) is inferred, not proven.
- **Step record byte33** (last of 34): treated as padding; not read by the expander in the
  paths examined.
- **Exact clock→tempo mapping**: `+3053=16` is a divider/PPQN base and `+610` holds per-step
  durations in tick units, but the conversion from host BPM/PPQN to these units happens
  upstream of `CArpeggio` and was not traced.
- **Note centering constant `+3060`**: confirmed subtracted in `sub_7FF91E01ED50`, but its
  initialization value was not located (template notes center on 60, suggesting `+3060≈60`).
