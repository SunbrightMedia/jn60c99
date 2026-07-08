# Arpeggiator step-rate / gate / sequence / velocity — binary findings

Ground truth: decompile `scratchpad/allcode/decomp_*.c` (rebase 0x7FF91DC60000, so
RVA = symbol − 0x7FF91DC60000) plus raw bytes read back from the PE
`aea4b19d-JUNO60VST3_64bit.vst3` (pefile) and raw disassembly (capstone) where the
decompiler dropped register arguments. The reference WAV was used only as a
consistency check at the end — every number below is derived from the binary.

---

## 1. THE STEP RATE — proven: 6 ticks (1/16) by default, and there is NO user RATE parameter

### 1.1 The step clock is the +610 duration records, not the 12/24 owner-clock divisor

* One master tick = 1/24 quarter note (24 PPQN). The audio process loop computes
  the tick period as `v100 = 60000000000 * sampleRate / roundedTempo / 24`
  (`decomp_300000.c:27326`) and fires a vtable "tick" callback each time the
  accumulator `a1+560` crosses it (`:27480`). Each tick fans out per part via
  `sub_7FF91E026750` @0x3C6750 (`decomp_3C0000.c:4768-4787`):
  `++routerTickCounter; sub_7FF91E023C50(router); sub_7FF91E01DEA0(arp);`.
* `sub_7FF91E01DEA0` @0x3BDEA0 (CKbdArp per-tick, `decomp_380000.c:27128-27279`)
  advances `+20/+24` by exactly 1 per call, fires scheduled note-offs
  (`slot+8 == tick`), and when `tick == *(a1+3048)` runs the step trigger
  `sub_7FF91E020260`.
* Step trigger `sub_7FF91E020260` @0x3C0260 (`decomp_3C0000.c:132`):
  `*(a1+3048) += *(u16*)(a1 + 6*patStep + 610)` — **the step length is the
  +610 record duration, i.e. `RATE_TABLE[rate_index]` ticks, always.**
* `sub_7FF91E023C50` @0x3C3C50 — the function our port used as the step clock —
  is **not the step clock**. It is the *quantized chord re-latch* handler on the
  note-router object (built by `sub_7FF91E023630`, arp at +1304): when the
  pending flag `router+6` is set, on the next `tickCounter % (24/(2-(router+5!=0)))
  == 0` boundary it re-inserts held keys (`sub_7FF91E023440`) and restores the
  selector index (`sub_7FF91E0234B0`). `router+5` is set by
  `sub_7FF91E024590` @0x3C4590 from table `{0,2,4,1,3,5}&1` (xmmword_9DEBB0 =
  `00000000 02000000 04000000 01000000` + immediates 3,5) — with the forced
  argument 2 (below) it is `4&1 = 0` → re-latch quantized to **12 ticks**
  (eighth). This is where the misread `24/(2-(division!=0))` divisor lives.

### 1.2 Who sets rate_index — the whole chain

Per-part objects (built in `sub_7FF91E0268D0`, `decomp_3C0000.c:4947-4986`):
CKbdArp (`sub_7FF91E022F20`), router (`sub_7FF91E023630`), **cfg** (0x28 bytes,
`sub_7FF91E020E90`: fields cfg[6]=cfg[7]=−1, cfg[8]=−1, cfg[9]=−8), **arp
controller** (0x30 bytes, `sub_7FF91E024900`).

DB parameter dispatch `sub_7FF91E027AE0` @0x3C7AE0 (`decomp_3C0000.c:5851-5868`):

| DB id | setter | field | Script.xml leaf (match by min/max/default, see 1.4) |
|---|---|---|---|
| 831 | `sub_7FF91E0249F0(ctl, v!=0, 0)` | ctl+0 enable | ARPEGGIO SW (0..1, def 0) |
| 832 | `sub_7FF91E024E50(ctl, v)` | ctl+4 (≤5) | ARPEGGIO TYPE (0..5, def 0) |
| 833 | `sub_7FF91E0249B0(ctl, v, …)` | ctl+8 (≤5) | ARPEGGIO STEP (0..5, def 0) |
| 834 | `sub_7FF91E024F10(ctl, v, 0)` | ctl+20 (≤9) | SCATTER TYPE (0..9, def 0) |
| 835 | `sub_7FF91E024EE0(ctl, v, 0)` | ctl+16 (−7..7 ok) | SCATTER DEPTH (−5..5, def 0) |

On every enable / TYPE / STEP change, `sub_7FF91E024F40` @0x3C4F40
(`decomp_3C0000.c:3617-3652`) runs:

```
cfg[6] = min(TYPE, 2)                    // selector class
CArpeggio+4076 = min(STEP, 2)            // octave range input
cfg[7] = 2                               // rate selector — HARD-CODED, always 2
sub_7FF91E020EC0(cfg, …)                 // apply
sub_7FF91E024590(router, 2)              // re-latch quantizer (→ router+5 = 0)
```

**`cfg[7]` is written nowhere else in the binary (only writer: line 3648). There
is no arp RATE user parameter — the “RATE control” hypothesis is refuted.**

Apply `sub_7FF91E020EC0` @0x3C0EC0 (`decomp_3C0000.c:643-672`; raw disassembly
0x3C0F02-0x3C0F58 confirms the decompiler-dropped registers):

```
sub_7FF91E023010(arp, rdx=cfg[6], r8=cfg[8], r9=cfg[9])       // pattern/gate load
       (5th stack arg = dword_9D86D0[150*cfg8 + 120 + cfg9], group is all-zero)
sub_7FF91E0234F0(arp, cfg[7], dword_9D86D0[150*cfg8 + 105 + cfg9])   // RATE
sub_7FF91E0234C0(arp, dword_9D86D0[150*cfg8 + 135 + cfg9])           // octave delta
params 312..318 = dword_9D86D0[150*cfg8 + 15*k + cfg9], k=0..6       // scatter FX
```

Rate setter `sub_7FF91E0234F0` @0x3C34F0 (`decomp_3C0000.c:2136-2164`):

```
map[6] = {0,0,4,1,3,5}          // v10=17039872=0x01040000, v11=1283=0x0503 → bytes 00 00 04 01 03 05
rate_index = max(0, map[clamp(a2,0,5)] + a3);  stored at arp+4047
sub_7FF91E01F3D0(arp, rate_index, gateIdx=arp+4049)
```

`sub_7FF91E01F3D0` @0x3BF3D0 (`decomp_380000.c:28448+`) clamps to 0..9, stores
rate idx at +12 / gate idx at +16, and fills the 32 six-byte step records at
+610 with `dur = word_9C43B8[3*rate]` (= RATE_TABLE) and
`gateLen = dur * word_9C43F8[gate] / 100`.

### 1.3 Default derivation (the number)

Power-on defaults: TYPE=0, STEP=0, SCATTER TYPE=0, SCATTER DEPTH=0 (param DB
records, §1.4; also `sub_7FF91E024920` @0x3C4920 zeroes all controller fields at
construction). Hence cfg[8]=0, cfg[9]=0+7=7, cfg[7]=2 (forced).

* rate offset = `dword_9D86D0[150*0 + 105 + 7]` = **0** (read from PE, RVA
  0x9D86D0; row 0 group 7 = `{0,0,0,0,0,0,0,0,0,0,0,2,2,2,2}` — only extreme
  scatter depths shift the rate; the whole depth-7 column is 0 for all 10 types).
* octave delta = `dword_9D86D0[150*0 + 135 + 7]` = **0**.
* `rate_index = map[2] + 0 = 4` → `RATE_TABLE[4] = {6,6,4}` → **dur = 6 ticks**.

**At 120 BPM: tick = 60/(120·24) s = 20.833 ms → step = 6 ticks = 0.125 s =
sixteenth note.** This matches the reference render (~0.12 s/step) and refutes
our port's 12-tick default (`use_rate_table=0`, division=0 → eighth = 0.25 s).

(Construction-time `sub_7FF91E01E2F0` @0x3BE2F0 calls `F3D0(a1, 5, 2)` — rate 5,
gate 2 — but that state is unreachable while the arp is off and is overwritten by
the `sub_7FF91E024F40` pass the moment ARPEGGIO SW turns on.)

### 1.4 Param DB proof of defaults

`sub_7FF91E00BAF0` @0x3ABAF0 → records at `unk_98C040 + 16*id`
(min,max,default,flags), read from the PE:

```
830:(0,65535,0)  831:(0,1,0)  832:(0,5,0)  833:(0,5,0)  834:(0,9,0)  835:(-5,5,0)  836:(-3,3,0)
```

This aligns 1:1, in order, with the Script.xml patch leaves `(INPUT JACK USING),
ARPEGGIO SW, ARPEGGIO TYPE, ARPEGGIO STEP, SCATTER TYPE, SCATTER DEPTH, OCTAVE
SHIFT` (ranges and defaults identical). **Defaults are all 0.**

---

## 2. GATE default — index 7 = 100%

`sub_7FF91E023010` @0x3C3010 (`decomp_3C0000.c:2008-2025`) loads the 550-byte
sub-pattern `a4 = cfg[9] = depth+7 = 7` of slab `a3 = cfg[8] = 0` from
`unk_9C4480` and derives:

* gate index = `header[1] >> 2`; slab 0 / sub 7 header = `0A 1C 2C C8 00 04`
  (PE read at RVA 0x9C4480 + 550·7) → `0x1C>>2` = **7** → `GATE_TABLE[7] = 100%`
  → gate = 6·100/100 = **6 ticks** (note-off scheduled on the next step's tick;
  the tick handler fires note-offs before the step trigger, and the step trigger
  itself force-closes the slot's previous note before the new note-on).
* pattern length = `header[5]>>2` = 1; slot 0: default note 60, step-0 cell
  velocity = `0x7F` (127); slots 1+ terminated (0x80).
* velocity sensitivity (arp+4051) = `header[3]>>1` = `0xC8>>1` = **100**.
* fixed velocity (arp+4052) = `word_9C4458[type].byte5` = **0** for every type.
* Note-off length source: `sub_7FF91E01FED0` @0x3BFED0 copies the +610
  `gateLen` (or full `dur` for tied cells, cell byte ≥ 0x80) into grid cell +2;
  the step trigger schedules `offTick = onTick + cell[+2]`
  (`decomp_3C0000.c:218`). For the default pattern: 6 ticks.

Our port's `carp_init` gate_index = 7 is **correct**; the bridge's init override
to 3 (60%) is **wrong** (§5).

---

## 3. First-step note / octave — UP, range 2, held {60}: **60, 72, 84, 60, 72, 84, …**

State initialisation, CArpeggio ctor `sub_7FF91E01D270` @0x3BD270
(`decomp_380000.c:26391-26409`):

```
+3464 sel_step   = 0        +3468 oct_adv_flag = 0
+3472/+3476 oct_shift, range = 0 (qword)
*(WORD*)(+3460)  = 256  →  started(+3460)=0, ud_dir(+3461)=1
```

Release-of-last-key reset, `sub_7FF91E01F2A0` @0x3BF2A0
(`decomp_380000.c:28423-28427`): when count(+3320) reaches 0 it zeroes
`+3464 (sel_step)`, `+3472 (oct_shift)`, `+3468 (oct_adv_flag)` — but **not**
`started` (stays 1 forever after the first note) and **not** `ud_dir`.

UP selector `sub_7FF91E01EFC0` @0x3BEFC0 (`decomp_380000.c:28238-28274`) with
count=1: first call sel_step=0 → **no** wrap, **no** oct_adv_flag → returns
sorted[0]=60; sel_step→1. Step trigger octave-advance
(`decomp_3C0000.c:173-199`) runs only when the flag is set, so first pitch =
60 + 12·0 = **60**. Every subsequent call wraps (sel_step 1 > count−1) → flag →
oct_shift 0→1→2→0 (range=2 = 3 octaves): **60, 72, 84, 60, …**
(With STEP=1 / range=1: 60, 72, 60, 72, … — the first emitted note is always
the lowest held key at the played octave, never 72.)

`src/carp.c` produces the identical sequence: `carp_init` seeds
sel_step=0/started=0/oct_shift=0/oct_adv_flag=0/ud_dir=1 exactly like the ctor,
its `sel_up` is a field-exact transcription, and `apply_octave_and_fold` matches
lines 173-204. Two second-phrase edge divergences exist (§5, items 3a-3c).

**ARPEGGIO STEP is octave range, proven from code (task 4):** dispatch id 833 →
`sub_7FF91E0249B0` (accepts 0..5) → `sub_7FF91E024F40` clamps `min(step,2)` →
stored to `CArpeggio+4076` (`decomp_3C0000.c:3643`) → `sub_7FF91E023010` reads
+4076 (`:2016`) → `sub_7FF91E01FE60` @0x3BFE60 stores it verbatim to +3476
(range, octaves−1) and zeroes oct_shift. The selectors consume +3476 as octave
span (`count*(range+1)-1`, `decomp_380000.c:27572`). It never touches the rate
path. So 0→1 oct, 1→2 oct, 2..5→3 oct — our port's `{0,1,2,2,2,2}` map ≡
`min(step,2)` is **exact** (and now binary-derived, no longer Script.xml-only:
numberTable `arpStep` "2|3|4|5,1,0" ↔ strings "3,2,1" agrees).

---

## 4. Velocity — formula and what the arp actually emits

Note-on goes through CKbdArp vtable slot 0 (vftable at RVA 0x9DEBA0, read from
PE: slot0=0x3C35A0, slot1=0x3C3580) = `sub_7FF91E0235A0`:

```
v6  = (uint8)(127 - sens*(127 - a3)/100)        // sens = arp+4051
base = fixed ? fixed : a4                        // fixed = arp+4052
vel  = (uint8)(base * v6 / 127);  if (vel==0) vel = 1
```

Call site (`decomp_3C0000.c:213-223`):
* `a3 = v11` = **pattern-grid step velocity** (`grid cell & 0x7F` = 127 in the
  default pattern). The alternative `v11 = per_note_vel` is gated on byte
  `+196`, whose only writer is `*(WORD*)(a1+196)=256` (`decomp_380000.c:27391`)
  → +196 = 0, so the grid velocity is used.
* `a4 = per_note_vel[selector_note]` (arp+464 = velocity the key was pressed with).
* Runtime constants (from §2): `sens = 100`, `fixed = 0`.

So at default: `v6 = 127 − 100·(127−127)/100 = 127` →
**vel = played_velocity · 127/127 = played velocity, clamped to ≥1. The arp
passes the held key's velocity through unchanged** (grid velocity 127 makes the
sens=100 term vanish). No attenuation, no replacement → VCF/VCA velocity sens
behave exactly as for a directly played note.

`src/carp.c` `velocity_calc(e, in_vel=per_note, per_note)` with its defaults
(sens=0, fixed=0) computes `v6=127 → vel=per_note` — **bit-identical output**
for the default pattern. Structural caveat: the binary's `a3` is the grid
velocity with sens=100, not the played velocity with sens=0; only relevant if
non-default patterns / sens are ever modelled (§5 item 5).

---

## 5. Changes needed (constants / fields only — NOT applied)

`src/carp.c`:
1. **`carp_init`: `e->use_rate_table = 0;` → `e->use_rate_table = 1;` and
   `e->rate_index = 0;` → `e->rate_index = 4;`** — this alone turns the default
   step from 12 ticks (eighth) into the proven 6 ticks (sixteenth) and fixes the
   observed bug. (`gate_index = 7` is already correct.)
2. `step_ticks()`/comments: the `24/(2-(division!=0))` owner-clock branch is the
   chord **re-latch quantizer** (sub_7FF91E023C50 via router+5, forced operand 2
   → 12 ticks), never the step length; the real plugin always steps by
   `RATE_TABLE[rate_index]`. Keep `division` only if re-latch quantization is
   ever modelled; it must not feed step duration. (Comment/semantics fix;
   default behavior fixed by item 1.)
3. `carp_tick` empty-keyboard branch, to mirror `sub_7FF91E01F2A0`:
   a. **add `e->oct_adv_flag = 0;`** (binary clears +3468 on last release; carp
      currently leaves a pending flag — can octave-shift the first note of the
      next phrase when range was 0 at wrap time).
   b. **remove `e->started = 0;`** (binary never clears +3460 after the first
      note; with it cleared, carp restarts DOWN (selector 19) at the top index,
      while the binary's 2nd-and-later phrases start at sorted[0] (bottom) and
      then wrap to the top — an audible ordering difference in DOWN mode).
   c. **remove `e->ud_dir = 1;`** (binary keeps +3461; if a phrase ends while
      UP&DOWN is descending, the binary repeats the bottom note once at the next
      phrase start; carp currently doesn't).
   (`e->sel_step = 0; e->oct_shift = 0;` are correct and stay.)
4. `carp_set_range` comment: mapping is now binary-proven (`min(step,2)` in
   sub_7FF91E024F40 → +4076 → sub_7FF91E01FE60 → +3476); drop the
   "asserted by ARP_FINDINGS.md, not re-derived" caveat.
5. Optional field-fidelity (output-identical at defaults, so optional):
   `vel_sens` engine value is 100 with `a3` = pattern velocity 127; carp models
   sens=0 with `a3` = played velocity. If ever exposed, the faithful form is
   `velocity_calc(e, /*a3*/127, per_note_vel)` with `vel_sens = 100`.

`gui/juno_bridge.c`:
6. **Init (`line 97`): `carp_set_gate_index(&c->arp, 3);` → `…, 7);`** — the
   binary default gate is index 7 = 100% (slab header 0x1C>>2), not 3 = 60%.
7. No call sets the rate: after change 1 nothing else is needed; alternatively
   add an explicit `carp_set_rate_index(&c->arp, 4);` (+ keep
   `use_rate_table=1`) next to the other init calls for clarity.

Not constants-only (flag, don't change now): the binary quantizes the FIRST
step to the next 24-PPQN tick after the key press (`sub_7FF91E01D810`/`DEA0`
LABEL_27: `+3048 = curTick + 1`, pattern step = −1), i.e. up to ~20.8 ms @120
late; carp fires the first step immediately (`first_step=1`). ≤1-tick phase
difference, audible only in edge alignment tests.

---

## 6. Underivable / honest flags

1. **Tempo operand scaling in the tick generator**: `decomp_300000.c:27326`
   proves the ÷24 (24 PPQN) but the decompiler dropped the xmm0 argument of the
   rounding helper `sub_7FF91E052050` (it is just `round()`,
   `decomp_3C0000.c:40791`), so the exact unit of `v15` (BPM vs deci-BPM etc.)
   is not directly pinned. The accumulator algebra (`a1+560` in 1e-8-sample
   units) is consistent with samples/tick = SR·60/(BPM·24), and the reference
   render corroborates it, but the constant itself is inferred.
2. **DB id → leaf-name binding** (831=SW … 835=SCATTER DEPTH) is proven by the
   exact (min,max,default) alignment of consecutive DB records 830..836 with the
   Script.xml leaf order plus the semantic match of each setter; the binary
   contains no literal name string tied to id 833 in the decompiled text.
   Confidence is very high but the linkage is positional, not nominal.
3. **sub_7FF91E023010's 5th argument** (stack arg = scatter-table group 8,
   `dword_9D86D0[150*t + 120 + d]`) is passed (raw asm 0x3C0F22/0x3C0F2E) but
   the decompiled body shows no use; the group is all-zero for every
   type/depth, so it cannot matter at any reachable setting.
4. **Non-zero scatter settings** (SCATTER TYPE/DEPTH ≠ default) reconfigure
   rate offsets (±2), octave deltas (±1), engine params 312..318, and select
   other 550-byte sub-patterns (different velocities/ties/slot counts). These
   are outside the default-state question and are not modelled by carp.c; the
   full 10×150 dword table lives at RVA 0x9D86D0 (600 bytes/row) and the
   pattern slabs at RVA 0x9C4480 (8250 bytes/type, 15×550 sub-patterns) should
   they ever be needed.
5. **9 engine instances**: the tick fan-out configures 9 identical part objects
   (`sub_7FF91E026750` loop). Which instance is audible in the VST wiring was
   not traced; it does not affect the per-arp constants above.
