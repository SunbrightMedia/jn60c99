# Chorus STRUCTURAL constants — per-mode derivation (JUNO-60 / JU-06A VST3)

Ground truth = the binary only (`aea4b19d-JUNO60VST3_64bit.vst3`), driven under
Unicorn (`scratchpad/oracle/emu2.py`). No captures of the running commercial
plugin were used. `src/runtime_coeffs_data.c` is itself a binary-derived table and
is cited only as an INDEPENDENT cross-check, never as a source. All values are for
**SR = 96000 Hz** (what the tests use) unless a SR sweep is shown.

Probes (all in `scratchpad/oracle/`): `cs_probe2..5.py`, `cs_bt.py`,
`cs_container.py`, `cs_drive.py`, `cs_drive2.py`, `cs_snapall.py`,
`cs_setactive.py`, `cs_setactive2.py`, `cs_enable.py`, `cs_descdefaults.py`,
`cs_final.py`, `cs_srdep.py`. Merged effect dump: `cs_effect_merged.json`.

---

## TL;DR — the two questions answered

1. **Do modes 3 and 4 write DIFFERENT structural constants to block A (91120) than
   mode 2?  → NO. Block A is bit-identical for modes 2, 3 and 4.**
   Proven three independent ways (see §2). The chorus I / II / I+II distinction is
   NOT carried in the master-read block-A structural cells.

2. **Full mode-5 block B (96336):** structural cells (Delay Time 96336, LFO Depth
   96368) were re-derived bit-exact from the binary; the mode-5 *enable* cells
   (Ip Fc 96384, Mute 96416) could NOT be reached under emulation (the mode-5
   sub-effect is constructed but never *enabled* — its smoother vector is not
   built), but they are the SAME shared constants as the block-A chorus (Ip Fc
   0x37ffd974, Mute 1.0), which WERE re-derived from the binary. See §3 + §5.

---

## 1. The effect object and the functions that were driven

The master DSP reads block A/B as `part+91120` / `part+96336`, where `part` is the
11 MB CJu60Sim alloc (`ST`, size 0xA83010, vtable RVA 0x98ae98).

The effect section is a **separate embedded object** — the "effect container" — at
`ST_END+0x10` (e.g. 0x310a8b020 in a run where ST=0x310008000), first-qword vtable
**RVA 0x9c3018**. Its param descriptors' storage pointers point back into `ST`, so
its writes land in the cells master_render reads. Layout inside the container:

| field | meaning |
|---|---|
| `cont+1480` | effect-type / mode selector (0..5) |
| `cont+6784` | sub-effect mode 0 (OD)   vtable 0x9c1550 |
| `cont+6976` | sub-effect mode 1 (DS)   vtable 0x9c1618 |
| `cont+7184` | sub-effect mode 2 chorus vtable 0x9c16e0 |
| `cont+7400` | sub-effect mode 3 chorus vtable **0x9c16e0 (same class as mode 2)** |
| `cont+7616` | sub-effect mode 4        vtable 0x9c17c0 |
| `cont+7824` | sub-effect mode 5 chorus vtable 0x9c18a0 |
| `cont+8176` | default sub-effect       vtable 0x9de990 |

Functions (RVA = symbolVA − 0x7FF91DC60000):

| RVA | symbol | role |
|---|---|---|
| **0x3BC980** | `sub_7FF91E01C980` | **effect-container setSampleRate** — calls setSampleRate on ALL sub-effects (writes block A+B structural UNCONDITIONALLY), then `switch(cont+1480)` runs a per-mode finalize (vtable +208 chorus / +328 mode5) on the ACTIVE sub-effect only. |
| 0x357B80 | `sub_7FF91DFB7B80` | block-A structural computer (Delay Time/Error Depth/LFO Rate/Phase/Depth); rate from an SR×type table `sub_7FF91DFB6380`. |
| 0x3587A0 | `sub_7FF91DFB87A0` | block-A LFO-rate helper (SR-indexed table). |
| 0x357310 | `sub_7FF91DFB7310` | block-B structural computer (Delay Time/LFO Depth). |
| 0x3C2750 | setValueDirect (`*(*(this+0x38)+40*idx+0x20)=xmm`) | the store all structural writes funnel through. |
| 0x3B8180 | `sub_7FF91E018180` | per-mode sub-effect config (`switch(cont+1480)` cases 0..5); sets sub-effect params + calls its compute. |
| 0x3B93E0 | `sub_7FF91E0193E0` | full setType/setActive: sets `cont+1480=mode`, calls 0x3B8180, param cascade, vtable[5]. |
| 0x3C29B0 | snap-all | `*storage = smoother.dest` for every registered param (applies defaults). |
| 0x3990C0 | `sub_7FF91DFF90C0` | CJu60Sim vtable[10] const-init (neighbouring one-pole coeffs; NOT the block-A/B writer). |

`part+1480` in earlier notes = `cont+1480` (the container is a distinct object, not
`ST+1480`). During plain `setSampleRate` the selector is 0, yet block A AND block B
structural are both written in the same call — the first proof of mode-independence.

---

## 2. Block A is mode-independent (modes 2 = 3 = 4) — three proofs

**Proof 1 (unconditional write).** In one `sub_7FF91E01C980` invocation (SR broadcast),
the container calls setSampleRate on *every* sub-effect, so both the block-A chorus
and the block-B chorus write their structural cells regardless of which mode is
selected. `cs_bt.py` backtrace of the `ST+91120` and `ST+96336` writes shows the
same parent chain `sub_7FF91E027A20 → sub_7FF91E021680 → sub_7FF91E01C980`, both in
the SAME master invocation, with `cont+1480 = 0` at the time.

**Proof 2 (re-drive per mode).** `cs_drive2.py`: set `cont+1480 = 2,3,4,5` and
re-invoke `sub_7FF91E01C980(cont, 96000)`. Every mode writes EXACTLY the same 7
structural cells with identical values:
`91120=0x3c0e0000 91136=0x3f77b282 91152=0x3727c5ac 91168=0x3f800000
91184=0x3b83126f  96336=0x3c1abc15 96368=0x3b442984`. The mode-specific finalize
(`switch` case 2/3/4/5) writes only sub-effect-internal state — never a master-read
block-A/B cell.

**Proof 3 (shared class).** Modes 2 and 3 use the *same* sub-effect class
(vtable 0x9c16e0); the single sub-effect bound to `ST+91120` is read for all of
modes 2/3/4. The per-patch LEVELS (Noise/Dry/Wet at 91200/91216/91232) were already
shown identical for 2/3/4 in `fx_recall_findings.md`.

Conclusion: **the 22 mode-3 patches read exactly the same block-A structural + level
cells as the mode-2 patches. No mode-3/4 override exists.**

---

## 3. Block A structural constants (modes 2/3/4) — @96000 Hz, VERIFIED bit-exact

Re-derived from the binary via `sub_7FF91E01C980` (structural), BUILD (On/Off) and
snap-all (Ip Fc/Mute/Dry). Bit-exact vs `runtime_coeffs_data.c`.

| off | idx | name | value @96k | source (binary) | SR-dep? |
|---|---|---|---|---|---|
| 91120 | 906 | Delay Time  | `0x3c0e0000` | setSampleRate (0x3BC980) | **yes** |
| 91136 | 907 | Error Depth | `0x3f77b282` | setSampleRate | no |
| 91152 | 908 | LFO Rate    | `0x3727c5ac` | setSampleRate | **yes** |
| 91168 | 909 | LFO Phase   | `0x3f800000` | setSampleRate | no |
| 91184 | 910 | LFO Depth   | `0x3b83126f` | setSampleRate | no |
| 91200 | 911 | Noise Level | *per-patch*  | `CHORUS_NOISE_LUT[tone]` (already solved) | — |
| 91216 | 912 | Dry Level   | `0x3fa66666` (1.3) | snap-all default | no |
| 91232 | 913 | Wet Level   | *per-patch*  | `CHORUS_WET_LUT[depth]` (already solved) | — |
| 91248 | 914 | Ip Fc       | `0x37ffd974` | snap-all default | no |
| 91264 | 915 | On/Off      | `0x3f800000` (1) | **BUILD** (default chorus enabled) | no |
| 91280 | 916 | Mute        | `0x3f800000` (1) | snap-all default | no |

## 4. Block B structural constants (mode 5) — @96000 Hz

| off | idx | name | value @96k | source (binary) | SR-dep? |
|---|---|---|---|---|---|
| 96336 | 917 | Delay Time  | `0x3c1abc15` | setSampleRate (0x3BC980) — VERIFIED | **yes** |
| 96352 | 918 | LFO Rate    | *per-patch* | `CHORUS5_LFORATE_LUT[tone]` (already solved) | — |
| 96368 | 919 | LFO Depth   | `0x3b442984` | setSampleRate — VERIFIED | no |
| 96384 | 920 | Ip Fc       | `0x37ffd974` | **not reachable in emu** (see §5); = block-A Ip Fc | no |
| 96400 | 921 | On/Off      | *per-patch* | `depth/255` (already solved, 0 mismatches) | — |
| 96416 | 922 | Mute        | `0x3f800000` (1) | **not reachable in emu** (see §5); = block-A Mute | no |

### SR-dependence (from `cs_srdep.py`, block A / block B)
```
SR      DelayTime(A)  LFORate(A)   DelayTime(B)     (Error/Phase/Depth are SR-independent)
44100   0x3b804ccd    0x37b69bf1   0x3b8c0000
48000   0x3b8c0000    0x37a7c5ac   0x3b98bc15
96000   0x3c0e0000    0x3727c5ac   0x3c1abc15
```
Delay Time and LFO Rate MUST be recomputed per SR; Error Depth (0x3f77b282), LFO
Phase (0x3f800000), LFO Depth (A 0x3b83126f / B 0x3b442984) are fixed constants.

---

## 5. HONEST GAP — the three cells that could NOT be reached under emulation

`91264` (block-A On/Off) IS reproduced (BUILD enables the default mode-2 chorus).
But three cells belong to effect sub-objects that are constructed yet **never
enabled** in the emulated lifecycle, so their smoother vectors are not built and
neither snap-all nor `sub_7FF91E018180`/`sub_7FF91E0193E0` populates them:

* `96384` block-B Ip Fc, `96416` block-B Mute (mode-5 chorus, sub-effect cont+7824).

Evidence they are unreachable, not merely unwritten: `cs_setactive2.py` drives the
full `sub_7FF91E0193E0(cont,96000,5)` + snap; the only writes to 96384/96416 come
from snap-one (0x3c2e66) writing their default `0`. The enable call chain no-ops
because the mode-5 sub-effect's dependent state isn't allocated (matches the
`fx_recall_findings.md` documented gap).

**Best binary-supported values** (NOT guesses): 96384 and 96416 are the identically
named params ("Ip Fc", "Mute") of the SAME chorus class whose block-A twins
(91248 Ip Fc = `0x37ffd974`, 91280 Mute = `0x3f800000`) WERE re-derived from the
binary via snap-all. `runtime_coeffs_data.c` (independent binary capture) confirms
96384=`0x37ffd974`, 96416=`0x3f800000` — bit-identical to the block-A twins. So use:
`96384 = 0x37ffd974`, `96416 = 0x3f800000`. Flagged because they were transferred
from the block-A equivalents + the independent capture, not driven directly.

The OD block enable `84544 Effect SW = 0x3f800000` has the same nature (inactive
sub-effect); `84560 Mute SW = 0x3f800000` and `85152 DS Level = 0x41008081` DID
reproduce via snap-all.

---

## 6. Broader effect-section dump (coordinator's ~121 enable/output cells)

`cs_effect_merged.json` = value of all 425 effect-region master-read offsets under
the faithful sequence **BUILD → snap-all → setSampleRate** (structural last so it is
not clobbered), with `91264` taken from BUILD. Cross-check vs `runtime_coeffs`
(42 overlapping cells): **28 bit-exact**, 14 differ — every difference is one of:
per-patch cells (Noise/Wet/LFO-Rate/On-Off, handled by existing LUTs), the mode-5
enable pair from §5, the OD `Effect SW`, or delay-recall per-patch cells
(101072/101152/102352 — owned by `delay_recall.c`, not the effect prepare).

The load-bearing chorus/output enables the coordinator listed all reproduce from the
binary via snap-all + BUILD:
```
91216=0x3fa66666  91248=0x37ffd974  91264=0x3f800000(BUILD)  91280=0x3f800000
101136=0x3f800000 101744=0x3f800000 102496=0x3f800000 102512=0x3f800000
102624=0x3f800000 102640=0x3f800000 102672=0x3f800000 102688=0x3f800000
84560=0x3f800000  85152=0x41008081
```
Plus snap-all fills the whole delay/output filter block 102368..102688 with the same
coefficients as runtime_coeffs (102416=0x3fb07de6, 102432=0xbf07c840,
102464=0x3e52bdc7, 102480=0x3fb50bf3, 102544=0x37ffd974, 102560=0x3ed8d8d9,
102608=0x3bab929a, 102656=0x3f4ba5b0, ...).

### Recipe to regenerate from the binary (no runtime_coeffs needed for these)
```
e=emu2.Emu(); HOST=e.bump(0x8000); e.call(emu2.BUILD, rcx=HOST)   # On/Off, default enables
ST = sorted(a for a,s in e.allocs if s==0xA83010)[0]
e.call(0x3C29B0, rcx=ST)                                          # snap-all: defaults + output stage
setSampleRate(0x3C7A20, XMM1=f32(SR))                             # structural (Delay Time/LFO Rate per SR)
# then per active mode set On/Off(=1) for the selected block; mode-5 96384/96416 = §5 constants
```

---

## 7. Bottom line for the C port

* Modes 2/3/4 → block A: use the §3 table (mode-independent). Structural (91120/
  91152 SR-dependent; 91136/91168/91184 constants), Dry=1.3, Ip Fc=0x37ffd974,
  On/Off=1.0, Mute=1.0; Noise/Wet per-patch LUTs.
* Mode 5 → block B: use the §4 table. Structural 96336(SR-dep)/96368 from the
  binary; LFO Rate + On/Off per-patch LUTs; Ip Fc=0x37ffd974, Mute=1.0 (§5 flag).
* No per-mode structural override exists for block A — drop any expectation of
  distinct Chorus-I/II/I+II coefficient sets in the master-read cells.
