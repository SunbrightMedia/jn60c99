# Arpeggiator (CKbdArp / CArpeggio) — binary findings & port status

Reverse-engineered from the recovered full decompile (`refs/allcode_decomp.tgz`,
files `decomp_380000.c` / `decomp_3C0000.c`), `refs/Script.xml`, and the bank
loader `sub_7FF91DFB1710`. All RVAs are image-base-relative (0x7FF91DC60000).

## Classes / entry points
- `CArpeggio` base ctor `sub_7FF91E01D270` (0x3BD270) — shared arp+Scatter core;
  seeds a PRNG at +8 (seed 31415, Scatter only).
- `CKbdArp` ctor `sub_7FF91E022F20` (0x3C2F20) — keyboard arp; owner/note-sink
  pointer stored at +4056.
- Tick / gate state machine `sub_7FF91E01DEA0` (0x3BDEA0); per-step trigger
  `sub_7FF91E020260` (0x3C0260); block driver `sub_7FF91E026750` (0x3C6750) ticks
  all 9 arp instances per block.
- Note output overrides (CKbdArp): note-on `sub_7FF91E0235A0` (0x3C35A0), note-off
  `sub_7FF91E023580` (0x3C3580). **They call the SAME owner note-sink the keyboard
  uses** → per-voice M.CV (param 1 / off 304+v*10512) + M.Gate (param 2 / off
  320+v*10512) via the immediate setter `sub_7FF91E0210F0`. The arp has no separate
  note path; voice allocation / M.CV / M.Gate emission are shared with keyboard play.

## Mode / range semantics (exact, from Script.xml + the selectors)
- **ARPEGGIO TYPE** (mode), stored value → 0 = UP, 1 = UP&DOWN, 2..5 = DOWN.
  - UP selector `sub_7FF91E01EFC0` (0x3BEFC0): `note = sorted[step]`, `step++`; on
    `step > count-1` wrap to 0 and raise the octave-advance flag (+3468). Ascending.
  - DOWN selector `sub_7FF91E01E6E0` (0x3BE6E0): `note = sorted[count-step-1]`; same
    wrap + octave-advance. Descending.
  - UP&DOWN and the remaining cases are step-pattern-table driven (table
    `unk_7FF91E624480`); the endpoint-repeat behaviour is in that binary table, not
    a closed-form branch (NOT decoded — flagged honestly, not guessed).
- **ARPEGGIO STEP** = octave RANGE (misleading name), stored value → 0 = 1 oct,
  1 = 2 oct, 2..5 = 3 oct → engine field +3476 = octaves-1.
  Applied as `pitch = sorted[idx] + 12*octaveIndex`, octaveIndex cycles 0..range,
  advanced once per full pass of the note list; out-of-range pitches fold by ±12.
- Held keys are kept in a **pitch-sorted ascending list** (+3064, count +3320),
  insertion-sorted on key input (`sub_7FF91E023440`).
- Velocity out (CKbdArp note-on): `vel = fixedOrInput*(127 - sens*(127-vel)/100)/127`,
  min 1.

## Timing — tempo-synced, NOT a per-patch rate
- Clock handler `sub_7FF91E023C50` (0x3C3C50): advance gate is
  `clockFlag && (clkCtr % (24 / (2 - (rateSw!=0))) == 0)` — a **24-PPQN quarter-note
  sync**, divisor 24 or 12 (a 2:1 rate switch). Step interval + gate length come from
  the pattern table (+610 durations, note-off at `+ table[+2]`). Master tempo is the
  host BPM. **There is NO ARPEGGIO RATE parameter anywhere** (checked Script.xml).

## Per-preset recall — the answer (rigorous, honest)
- **Script.xml:** arp SW / TYPE / STEP (+ Scatter type/depth, octave shift, key hold)
  are per-patch fields in struct `PAT_NAME1` (`fm.PATCH.NAME1`), i.e. conceptually
  saved with the patch in the plugin's full programmer tree.
- **BUT the factory `KoaBankFile00003` loader `sub_7FF91DFB1710` writes NO arp state.**
  Its 31-case switch (table `dword_7FF91E8A4290`, also in `tools/decode_bank.py`)
  maps only synth-sound destinations (LFO/DCO/VCF/VCA/ENV/chorus). No case reads or
  writes any arp field. So **loading a bank patch does not restore the arpeggiator**
  — not in our port, and not in the plugin's own compact-bank path either.
- Consequence: we CANNOT bit-exactly auto-enable the arp per bank preset. The arp
  bytes are not among the loader-consumed region, we have no factory bank file to
  even confirm they exist in the record's extended area, and the arp is tempo-synced
  (a standalone browser has no host BPM). Assigning bank byte offsets for arp would
  be an untestable guess → refused (cardinal rule).

## Port status / decision
- The webapp arp is a **manual** control (toggle + mode + octaves + rate in the UI).
  With the note-handler fix it now plays clean, correctly-ordered notes (verified:
  held C-E-G arps C4→E4→G4→… in UP mode). Its UP/DOWN ordering and octave-range math
  match the decoded selectors above.
- Per-preset auto-arp is deferred as **not faithfully recoverable** from the bank
  (loader carries no arp state; no host tempo in standalone). Documented, not guessed.
- A fully bit-exact CKbdArp port is possible for UP/DOWN (closed-form) but UP&DOWN
  needs the binary pattern table `unk_7FF91E624480`, and tempo sync needs a host
  clock — both outside the standalone dry-preview's scope.
