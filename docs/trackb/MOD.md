# MOD.md — LFO, PWM, pitch modulation, portamento, keyfollow, CONDITION scatter

Blueprint for a native (non-transcribed) implementation of the MODULATION
subsystem of `src/voice_render.c`. Target: null < −90 dB against the bit-exact
reference (`tools/trackb/null_ab.py`), so every equation below is written in the
exact float evaluation order of the transcription. All arithmetic is
single-precision; parenthesization is load-bearing (`-ffp-contract=off`, no FMA,
x86 SSE2 reference).

**Line numbers**: every cite is the CURRENT `src/voice_render.c` (2185 lines,
pilot-2 header included). READ. Several in-repo comments still carry pre-pilot-2
numbers and are ~21–30 lines low — `juno_note.c:294` says "voice_render.c:674"
(actual **696**), `juno_note.c:212` says ":794" (actual **816**),
`juno_apply.c:795` says ":775-796" (actual **797-819**). Do not trust those;
trust the cites here, each of which was re-read at the stated line.

Notation: `[N]` = float cell at per-voice offset N (`a1 = base + voice*10512`);
`[[N]]` = the same cell copied as raw int32 bits; `[N]' ` = the value written
this sample; `base[N]` = the shared, un-shifted block. Init constants come from
`src/juno_init.c` (**two arms**: `if (rate == 44100)` covers lines 315–614,
`else` covers 617–916 — READ juno_init.c:314/615/616/917); prepare constants
from `src/juno_prepare.c`; recalled coefficients from `src/juno_apply.c`
BINDINGS + the discrete block. Cells with no writer in
init/prepare/apply/note are **0.0f** because the engine block is
`calloc`-allocated (READ gui/juno_bridge.c:147).

**Provenance discipline.** Everything in this document is **READ** (from
`src/*.c`, whose own provenance is the executed plugin binary) unless a claim is
explicitly marked PROVEN (a project record of an executed gate) or INFERRED (my
own dataflow reasoning). I executed nothing except float-bit decoding of the
constants quoted below.

---

## 1) Subsystem boundary — cells owned

Per-voice offsets (add `voice*10512`). "tap" = written every sample with no
reader inside `voice_render.c`; a native port should still WRITE it (probes /
master / future readers) but it never feeds back.

### 1.1 Portamento / glide `[592..832]` + output `[752]`
| cell | role | class |
|---|---|---|
| 592 | PORTAMENTO on/off — recall (`juno_apply.c` BINDINGS row `{54,52,T_ID,592}`), **overwritten per voice** by the assigner's legato bus (`juno_note.c:300-307`) | input |
| 608 | PORTAMENTO MODE — legato&&assign gate, recall (`juno_apply.c:654`) | input |
| 624 | PORTAMENTO TIME — recall curve 7 × (96000/H) (`juno_apply.c:238-239`, prepare default :107/:239) | input |
| 656 | glide error integrator | **CARRIED** (read :698, written :703) |
| 672 | glide rate state | **CARRIED** (read :697, written :705) |
| 688 | arrival ramp | **CARRIED** (read :701, written :720) |
| 704 | glided pitch (the "current value" / glide state) | **CARRIED** (read :687, written :734) |
| 720 | shadow of previous 704 (:693) | tap |
| 736 | glide-enable v45 (:699) | tap |
| 752 | FINAL PITCH CV out (:735) — read same-sample at :1078, :1086, :1176 | SCRATCH |
| 768, 784, 800, 816, 832 | glide constants (§4) | const |

### 1.2 Mod-CV combiner + external inputs `[848..1024]`
`848/864` weights (1.0), `880` summed tune/mod CV (:732, SCRATCH), `896` shadow;
`912` LFO rate-mod mantissa, `944` LFO ext-gate input, `976`/`1008` external LFO
inputs, `928/960/992/1024` their shadows. **None of 368, 384, 912, 944, 976,
1008 has a writer anywhere in the port** → all 0.0f; `[880]' == 0.0f` always.

### 1.3 LFO rate + tempo sync `[1040..1216]`
| cell | role | class |
|---|---|---|
| 1040 | "LFO Griffer Rate Sw" — no writer → 0 | input |
| 1056 | TEMPO SYNC switch — recall `{59,52,T_ID,1056}` | input |
| 1072 | tempo-synced rate — recall `curve48(rateByte)*curve53(1280)` (`juno_apply.c:622`), live host-BPM overwrite `juno_apply_lfo_tempo` (:804-816) | input |
| 1088 | LFO RATE — recall curve 22 (`{8,22,T_ID,1088}`), prepare default 0.56862748 | input |
| 1104 | smoothed modded rate | **CARRIED** (read :736, written :786) |
| 1120 | shadow of 1104 (:741) | tap |
| 1136 | effective rate after tempo select (:819) | tap — the only occurrence of 1136 in the file is that store; the phase-inc clamp at :826 uses the register `v83` |
| 1152, 1168, 1184, 1200, 1216 | rate constants (§4) | const |

### 1.4 LFO oscillator `[1408..2544]`
**The only CARRIED cells in the whole LFO are six**: `1104` (rate smoother),
`1488` (previous ext gate — the edge memory), `1504` (delay ramp), `1536`
(**phase**), `1568` (noise smoother), `1600` (S&H held value). Everything else
in the range is written-before-read within the sample.

| cell | role |
|---|---|
| 1408 | LFO noise out (:870) — SCRATCH |
| 1424 | latch of `base[84432]`, the shared noise (:814) — SCRATCH |
| 1440, 1456 | latches of `[976]`/`[1008]` (:812-813) — SCRATCH, both 0 |
| 1472 | LFO delay-envelope LEVEL (:853) — SCRATCH |
| 1488 | clamped ext gate — **CARRIED** (read :805, written :825) |
| 1504 | delay ramp — **CARRIED** (read :802, written :810 **dead**, :840 live) |
| 1520 | shadow of 1504 (:809) — tap |
| 1536 | **LFO PHASE** — **CARRIED** (read :806, written :868) |
| 1552 | previous phase (:811) — written then read at :854 **within the sample**; its cross-sample value is dead ⇒ effectively SCRATCH |
| 1568 | noise smoother state — **CARRIED** (via its :800 copy in 1584, written :852) |
| 1584, 1616 | in-sample int copies of 1568 / 1600 (:800, :804) |
| 1600 | S&H held value — **CARRIED** (read via 1616 at :867, written :882) |
| 1632, 1648 | "S&H clock" — 1632 has **no writer** (0), 1648 is write-only (:807). Both dead. |
| 1664 | phase increment (:834) — tap |
| 1680, 1696 | saw / inverted saw (:885, :888) — SCRATCH |
| 1712 | square out (:941) — SCRATCH |
| 1728 | triangle out (:928) — SCRATCH |
| 1744 | sine out (:952) — tap (register copy is what is used) |
| 1760 | S&H out (:886) — SCRATCH |
| 1776 | delay depth v120 (:959) — tap |
| 1792 | **LFO OUT, delay applied** (:961-963) — SCRATCH, read at :1083, :1187 |
| 1808 | **LFO waveform mix, NO delay** (:960) — SCRATCH, read at :964, :1094, :1196 |
| 1824 | square-phase sign; **ENV1/ENV2 trigger source** (:929) — read :967, :1022 |
| 1840 | shadow of 1856 (:818) — tap |
| 1856 | "any key held" — broadcast to ALL 8 voices by `juno_note.c:220-226` | input |
| 1872 | LFO KEY TRIG — recall `(byte==0)?1:0` (`juno_apply.c:623`), prepare default 1.0 | input |
| 1888 | phase run gate ("Reset Sw") — prepare 1.0 (`juno_prepare.c:76`) | input |
| 1904 | "LFO UseExtGate" — no writer → 0 | input |
| 1920 | LFO DELAY — recall SR-variant arm 42/43/44 (`{7,44,T_ID,1920,…,1}`) | input |
| 1936 | LFO DELAY switch — recall `(byte==0)?0:1` (`juno_apply.c:621`) | input |
| 1952…2048 | waveform enables: 1952 Sin, 1968 Tri, 1984 Sqr, 2000 Saw, 2016 Saw-inv, 2032 S&H, 2048 Noise. **Only 1952 is written (prepare :77 = 1.0); the other six have no writer → 0.** | input |
| 2064 | LFO noise mix — recall mirrors LFO RATE curve 22 (`{8,22,T_ID,2064}`) | input |
| 2080 | LFO Internal Sw — prepare :78 = 1.0 | input |
| 2096, 2112 | external-LFO mix — no writer → 0 | input |
| 2128…2512 | phase/waveform constants (§4) | const |
| 2528, 2544 | int latches of 1824 / 1808 (:965-966) — taps for the ENV section | tap |

### 1.5 Mod router / DCO mixers `[3520..4176]` (the parts MOD owns)
`3552` mod source (no writer → 0), `3568`/`3680` its latches (:1077, :1087),
`3584`/`3600` key-mix weights (1.0), `3616` key CV (:1082), `3632` shadow,
`3696` latch of `[752]` (:1088), `3712` LFO×gain (:1095), `3744` mod-wheel term
(:1101), `3760` bend term (:1104), `3776` **PITCH-MOD SUM** (:1108-1114),
`3808` **PWM SUM** (:1117-1123), `3824` write-only tap (:1124).
Coefficients: `3856` (0), `3872` (1.0), `3888/3904/3920/3936` PWM SOURCE one-hot,
`3952` (0), `3968` **UNISON per-voice detune**, `3984` MOD SENS DCO, `4000` (0),
`4016` (1.0), `4032` DCO LFO MOD, `4048` (1.0), `4064/4080/4096` (0 — the
env→pitch path is dead), `4112` (0, live bend), `4128` BEND depth DCO,
`4144` DCO PWM DEPTH, `4160/4176` (0.5, 0.5).

### 1.6 Keyfollow `[6944..6976]`, `[7408]`, `[7488]`
`6944`/`6960` weights (1.0), `6976` VCF keyboard CV (:1179, SCRATCH),
`6992` shadow, `7408` VCF KEY FOLLOW (recall curve 24), `7488` −4.0 offset.

### 1.7 LFO → VCF hand-off `[7088..7232]` (VCF.md owns the cutoff sum)
`7088` A-smoother state (**CARRIED**, input `[1792]`), `7104` its output
(dead store at :1189, live at :1194); `7168` B-smoother state (**CARRIED**,
input `[1808]`), `7184` its output (dead store :1197, final store :1203 — but
**`[7184]` is never read anywhere in `voice_render.c`**; the cutoff sum at
:1220-1221 consumes the register `v221`, so `[7184]` is a tap, not a hand-off
cell. `[7104]` by contrast IS genuinely re-loaded, at :1204). Coefficients
`7120`/`7200` (rate-armed), `7136`/`7216` (0), `7152`/`7232` (1.0).

### 1.8 CONDITION per-voice analog scatter — **render READS ONLY**
| cell | read at | consumer |
|---|---|---|
| 5520 "Duty Tune" | **:1706** | `[4816]' = [5520] + [3808]` (:1711) — the DCO **pulse width** |
| 7600 "Cutoff Tune" | **:1240** | `v232 = [7568]'*[7696] + [7600]`, summed into the cutoff at :1248 |
| 7616 "Resonance Tune" | **:1243** | `[7536]' = [6848]*[7792] + [7616]` |
| 10320 "AMP LEVEL" | **:1598** | `v367 = v366 * [10320]` (`v366 = v364`, :1597) — per-voice output level |

These four offsets appear in `voice_render.c` at **exactly those four lines and
nowhere else**, always on the right-hand side of an assignment (verified by
grep over the whole file). **The render never writes them.** They are set at
recall time only, by `juno_apply_condition` (`juno_apply.c:472-485`), which
writes 5520/7600/10320 and deliberately leaves **7616 = 0.0** (`juno_apply.c:483`
— so the resonance-trim term is inert in the shipping engine). `3968` (UNISON)
is the fifth per-voice-distinct constant, written by `juno_apply_unison_spread`
(`juno_apply.c:497-506`) and read only at **:1114**.

---

## 2) Flow — execution order inside one voice-sample

```
retrig-latch head (:587-594)
  → shared noise advance (:595-653)        [DCO.md §2.1 owns it]
  → input conditioning  (:623-660)          → [464] pitch CV, [480] gate
  → gate binarizer      (:661-693)          → [560]
  → GLIDE               (:682-735)          → [704], [752]
  → mod CV sum          (:724-732)          → [880]
  → LFO RATE            (:726-819)          → [1104], [1136]
  → LFO OSC             (:800-966)          → [1792], [1808], [1824], [1472]
  → ENV1 / ENV2         (:967-1075)         [ENV.md]
  → mod router          (:1076-1091)        → [3616], [3648], [3664], [3696]
  → PITCH SUM  [3776]   (:1092-1114)
  → PWM  SUM   [3808]   (:1117-1123)
  → …VCF input, keyfollow (:1176-1179), LFO→VCF smoothers (:1187-1203),
     cutoff sum (:1210-1228), CONDITION cutoff/res trims (:1240-1243)…
  → VCA, CONDITION level (:1598), output write (:1640)
  → pitch spline (:1641-1665) consumes [3776]
  → PW total [4816] = [5520] + [3808] (:1711)
  → DCO bank, latch tail (:2175-2179)
```

Two ordering facts a native rewrite must not lose:

1. **The LFO is computed BEFORE both envelopes** and `[1824]` is the envelope
   trigger when `[2560]/[3040] != 0` (`ENV.md §2.4`). Moving the LFO after the
   ENVs changes which sample's LFO polarity gates the ADSR.
2. **`[3776]` is consumed twice, at :1641 (pitch spline) and :1704**, both
   *after* the voice output is written at :1640. The PWM total `[4816]` is
   likewise assembled at :1711. Modulation is therefore produced early and
   consumed late inside the same sample — there is no extra delay, but the DCO
   bank that uses it renders after the output write (see CELLMAP §2 preamble).

---

## 3) Per-sample equations (exact order)

### 3.1 Portamento / glide — :682-735

Inputs: `g = [560]'` (binary gate, §ENV 2.3), `cv = [464]'` (conditioned pitch,
== `[304]` M.CV at rest).

```
:693  [720] = [704]                                   // shadow of the carried value
:694  v43  = (g * [608]) - [608]
:696  v45  = (v43 + 1.0f) * [592]        → [736]      // glide enable (:699)
:697  v46  = ([672] / (([768] * [624]) + [800])) * [768]
:698  v47  = [656]
:700  v48  = v47 - v46
:702  v50  = (v48 + cv) - [704]
:703  [656] = v50                                     // integrator, UNCONDITIONAL
:704  v51  = v50 * ([624] + [784])                    // v41 formed at :688
:705  [672] = v51                                     // rate state, UNCONDITIONAL
:706  v52  = v51 + [704]                              // glide candidate
:707  if (([816] - fabsf([704] - cv)) < 0.0f) v54 = 0.0f;
:714  else { v53 = [688] + [832]; v54 = (v53 < 1.0f) ? v53 : 1.0f; }
:720  [688] = v55 = (float)v54                        // arrival ramp, UNCONDITIONAL
:721  v56  = ((v55 * cv) - (v55 * v52)) + v52         // lerp(candidate → cv)
:722  if (v45 == 0.0f) v56 = cv;                      // glide OFF ⇒ direct
:734  [704] = v56
:735  [752] = v56                                     // FINAL PITCH CV
```

Semantics (INFERRED): a leaky-integrator glide. `[704]` is the **current
value**, `cv = [464]` is the **target**. `[464]` is **not** written by the note
path — it is computed in-render at `voice_render.c:659` (`[464] = ((v12·[448]) −
([448]·[336])) + [336]`, the conditioner's lerp) from the raw note pitch `[304]`.
`[304]` is what the note path writes: `PITCH_OFF 304` (`juno_note.c:97` is the
`#define`), stored at `juno_note.c:160` on a note-on and at `:274` for a legato
pitch-only change. So the note path moves the target one cell upstream of the
glide. `[656]`/`[672]` are the integrator and its rate; `[688]` is an arrival ramp that
lerps the output onto the target once `|current − target| < 0.05`.

Three traps, all READ from the code above:
* **`[656]`, `[672]` and `[688]` update UNCONDITIONALLY** — the `v45 == 0`
  bypass at :722 replaces only the OUTPUT. A native port that skips the whole
  glide block when portamento is off leaves the integrator without the residue
  the reference carries, and the first sample after portamento is enabled
  diverges.
* `[832]` = **1e-9** per sample: the arrival ramp needs ~10⁹ samples to reach
  1.0, so in practice `[688] ≈ 0` and the lerp at :721 is near-identity. It is
  *not* a fast "snap"; do not "simplify" it to a threshold.
* `[592]` is **per-voice** at runtime: recall writes the patch value to all 8,
  then the assigner's legato bus (`juno_note_porta_gate`, `juno_note.c:300-307`)
  zeroes it on individual voices. Glide state is therefore genuinely per voice.

### 3.2 Mod-CV sum — :724-732
```
:724  v57  = [384] * [864]
:725  [896] = [[880]]                 // shadow of the PREVIOUS sample's value —
                                      //   this store precedes the :732 update
:729  v61  = v57 + ([368] * [848])
:732  [880] = v61                     // == 0.0f (368/384 have no writer)
```
Order is load-bearing in principle: `[896]` is written **before** `[880]` is
updated, so it holds the previous sample's value, not this one's. `[896]` has no
reader anywhere, and `[880]` is identically 0.0f in the shipping engine, so
getting the order wrong is currently unobservable — but the listing follows the
source.

### 3.3 LFO rate — :726-819

```
:727  v59 = [912]                                          // == 0.0f
:731  e   = (int)[1168]                                    // [1168] = −20.0 ⇒ e = −20
:742  if (e < -32)        v59 *= 2.3283064e-10f;           // 2^-32
      else if (e > 32)  { e = 32; v59 *= juno_exp_ad3c[32]; }
      else if (e < 0)     v59 *= juno_exp_acc0[~e];        // = 2^(e)
      else if (e > 0)     v59 *= juno_exp_ad3c[e];         // = 2^(e)
:762  f   = (int)(float)(-[1168])                          // = +20
      …identical five-way ladder with f…                   // = ×2^(−e)
:784  v68 = ((v59 - [1104]) * [1152]) + [1104]
:786  [1104] = v68                                          // one-pole, CARRIED
:741  [1120] = old [1104]
:787  v70 = ((v68 * [1040]) - ([1040] * [1088])) + [1088]   // lerp([1088], [1104]', [1040])
:788  v71 = (v70 <= 0.0f) ? 0.0f : v70;
:793  v73 = (v71 < 1.0f)  ? v71  : 1.0f;                    // clamp to [0,1]
:798  v75 = expf(v73 * [1200]) * [1184]
:801  v77 = v75 + [1216]
:799  v76 = [1056] * [1072]
:815  v83 = (v76 - ([1056] * v77)) + v77                    // lerp(v77, [1072], [1056])
:819  [1136] = v83
```
`juno_exp_acc0[19] = 2^-20` and `juno_exp_ad3c[20] = 2^20`, both exact powers of
two, so the double ladder is an **exact ×1.0** at the shipped `[1168] = −20`
(INFERRED, from the table values in `src/juno_tables.h:47-52`). With `[912] = 0`
and `[1040] = 0`, the whole block collapses to
`[1136]' = lerp(expf(clamp01([1088])·[1200])·[1184] + [1216], [1072], [1056])`.
**Keep the full form** — the collapse depends on four cells that only a host
parameter path could make nonzero.

`expf` is a real libm call at :798 — the **first** of exactly two in the voice
(the VCF's at :1261 is the second; grep returns no others). CLAUDE.md records glibc `expf` == newlib `expf` bit-identical over
32,000,423 inputs (PROVEN); a native port must not substitute its own exp.

### 3.4 LFO ext gate, phase increment, delay ramp — :800-853
```
:800  [[1584]] = [[1568]]      :804 [[1616]] = [[1600]]     :807 [[1648]] = [[1632]]
:812  [[1440]] = [[976]]       :813 [[1456]] = [[1008]]     :814 [[1424]] = [[base 84432]]
:802  v78 = [1504]             :805 v80 = [1488]            :806 v81 = [1536]
:809  [1520] = v78
:810  [1504] = v80             // DEAD STORE — overwritten at :840, no reader between
:811  [1552] = v81

:803  v79 = [944] * [1904]                                  // == 0
:816  v84 = [1856]             :818 [1840] = v84
:817  v85 = v79 + v84
:820  v86 = (v85 >= -1.0f) ? fminf(v85, 1.0f) : -1.0f       // ext gate, clamped
:825  [1488] = v86
:833  v92 = v80 - v86                                       // v92 < 0  ⇔  gate ROSE

:824  v87 = [2128]
:826  v88 = fminf(v87, v83 * 1.52587890625e-05f)            // 2^-16
:832  v91 = v88 * [2144]
:834  [1664] = v91                                          // PHASE INCREMENT

:827  v89 = ((1.0f - v78) * [1920]) + v78                   // delay one-pole toward 1
:828  v90 = (v89 >= -1.0f) ? fminf(v89, 1.0f) : -1.0f
:836  if (v92 < 0.0f) v90 = 0.0f;                           // RESET on gate RISE
:840  [1504] = v90
:841  v96 = v90 + [2272]                                    // −0.63212102
:844  v97 = v96 * [2256]                                    // × e
:846  v99 = (v97 <= 0.0f) ? 0.0f : v97;
:853  [1472] = v99                                          // delay LEVEL, 0…1
```
`v92 < 0` means **the gate ROSE**. (CELLMAP §F calls this a "falling ext-gate
edge"; the arithmetic above says otherwise — `v80` is the OLD `[1488]`, `v86`
the new one. Treat the equation as authoritative.) With `[1904] = 0` the gate is
exactly `[1856]`, the **any-key-held** flag broadcast to every voice
(`juno_note.c:220-226`), so the LFO delay restarts on the **first key of a
phrase**, not on every key, and simultaneously on all 8 voices.

`[2272]/[2256] = −0.63212103 / 2.7182820` (the §4 roundings; the exact decoded
values are −0.6321210265159607 and 2.7182819843292236) ⇒ the level stays at 0 until the ramp
passes `1 − 1/e`, i.e. exactly one time constant, then rises to 1.0. That is the
LFO DELAY.

### 3.5 **The LFO phase accumulator** — :806, :835, :838-845, :858-868

**Type: `float` (single precision), one cell, `[1536]`. Not an integer, not a
fixed-point counter. It is CARRIED across samples** (read at :806 into `v81`,
written back at :868), and its span is **2** — the phase lives in `[-1, 1)`.

```
:835  v93 = v91 + v81                       // increment + previous phase
:838  v94 = [1872];                         // LFO KEY TRIG coefficient
:842  if (v92 >= 0.0f) v94 = 1.0f;          // …only on a gate RISE is [1872] used
:845  v98 = (v93 * v94) * [1888]            // [1888] = 1.0 (prepare :76)

      // WRAP LAW, verbatim :858-866:
:858  if (v98 <= 1.0f) { if (v98 < -1.0f) v98 = fmodf(v98 - 1.0f, 2.0f) + 1.0f; }
:863  else                                  v98 = fmodf(v98 + 1.0f, 2.0f) - 1.0f;

:868  [1536] = v98
```

* The retrigger is a **multiply**, not an assignment: on the sample where the
  gate rises, the phase becomes `(prevPhase + inc) * [1872]`. With KEY TRIG on
  (`[1872] = 0`, i.e. patch byte ≠ 0) the phase lands on **exactly 0.0**, not on
  `inc`. With KEY TRIG off (`[1872] = 1.0`, byte == 0) the phase is untouched
  and the LFO free-runs.
* `[1888]` multiplies the phase **every sample**, not just on reset. Prepare
  sets it to 1.0; if it were ever 0 the LFO would sit at 0 forever.
* The wrap uses `fmodf` with the ±1 pre/post offsets — **not** `p -= 2.0f`.
  For the increments the engine actually produces the two agree, but the
  key-trig multiply and any large `[1136]` can push `|v98| > 3`, where they do
  not.

### 3.6 Noise smoother and S&H — :851-857, :867-886
```
:839  v95 = [1424]                                    // this voice's latched shared noise
:851  v101 = ((v95 - [1584]) * [2464]) + [1584]       // [2464] = 0.0142
:852  [1568] = v101                                   // CARRIED
:855  v102 = (((v101 * [2448]) * [2064]) - (v95 * [2064])) + v95   // [2448] = 14.0
:870  [1408] = v102 * [2432]                          // [2432] = 0.5

:854  v529 = [1552]                                   // = the pre-update phase
:867  v103 = [1616]                                   // = previous held value
:871  if (v529 < 0.0f && v98 > 0.0f) v103 = v95;      // rising zero crossing → sample
:882  [1600] = v103                                   // CARRIED
:883  v105 = v103 * [2416];   :886 [1760] = v105
```
The S&H edge test compares the **pre-update** phase with the **post-wrap** new
phase (`v98` after :858-866). `[2064]`, the "noise mix", is the LFO RATE
curve-22 value again (recall row `{8,22,T_ID,2064}`) — that is not a typo.

### 3.7 Waveform shapers — :869-952
Each shaper adds its own offset to the master phase and re-wraps it with the
same `fmodf(±1)` law.
```
saw   :869  v104 = wrap(v98 + [2288])          // [2288] = −1.0  (wrap at :873-881)
      :884  v106 = (v104 * [2352]) + [2480];  :885 [1680] = v106   // ×0.5, −0.5 ⇒ [−1, 0)
      :888  [1696] = -v106                    // exact negation of the register

tri   :887  v107 = v98 + [2320]                // [2320] = −0.5  (NOT re-wrapped here:
      :889-897 the fmodf results are DISCARDED — the wrap lives inside juno_triangle)
      :915  v109 = juno_triangle(v107)         // src/juno_dsp.c:54-71
      :917  v111 = v109 * [2384];   :928 [1728] = v111

sqr   :905  v108 = wrap(v98 + [2304])          // [2304] = 0.0
      :916  v110 = v108 + [2496]               // [2496] = 0.0
      :918  v110 = (v110 >= 0) ? ((v110 > 0) ? 1.0f : v110) : -1.0f    // sign, keeps ±0
      :929  [1824] = v110                      // ← the ENV1/ENV2 trigger
      :930  v113 = (v110 * [2368]) + [2512];   :941 [1712] = v113

sine  :927  v112 = wrap(v98 + [2336])          // [2336] = 0.0
      :940  u = fabsf(v112)
      :946  v117 = ( ( (u*((u*u)*u))*[2224]
                       + ( (((u*u)*u)*[2208])
                           + ( ((u*[2176]) + [2160]) + ((u*u)*[2192]) ) ) )
                     + [2240] ) * [2400]
      :952  [1744] = v117                      // the MIX at :956 uses the REGISTER v117
```
The "sine" is a quartic in `|phase|` — a smoothed triangle, evaluated in exactly
the grouping above (:946-951). **Do not substitute `sinf`.** Its value at u=0 is
≈ −0.99810 and at u=1 is ≈ +0.99810 (INFERRED from the coefficients in §4).

### 3.8 Mix and delay depth — :942-963
```
:943  v116 = (([2032] * [1760]) + ([2000] * [1680])) + ([2016] * [1696])
:953  v118 = ([1968] * [1728]) + v116
:956  v121 = ((v118 + ([1984] * [1712])) + (v117 * [1952])) + ([2048] * [1408])
:960  [1808] = v121                                    // waveform mix, NO delay
:955  v120 = (([1936] * [1472]) - [1936]) + 1.0f       // = lerp(1, level, delaySw)
:959  [1776] = v120
:961  [1792] = (([2096] * [1440]) + ([2112] * [1456])) + (([2080] * v120) * v121)
:964  v122 = [[1808]];  :965 [[2528]] = [[1824]];  :966 [[2544]] = v122
```
**`[1792]` carries the delay envelope; `[1808]` does not.** This is the single
most likely "almost right" bug in the whole subsystem — see §7.

With only `[1952] = 1.0` written by prepare, `v121` reduces to `v117 * 1.0` and
`[1792]` to `([2080] * v120) * v121`. Keep the full sum: the other six waveform
enables are engine-reachable cells that recall simply never writes.

### 3.9 Pitch modulation sum `[3776]` — :1076-1114
```
:1076 [[3536]] = [[3520]]   :1077 [[3568]] = [[3552]]   :1080 [[3632]] = [[3616]]
:1081 v169 = ([880] * [3600]) + ([752] * [3584])   → [3616]   // keyboard CV, unity weights
:1087 [[3680]] = [[3552]]   :1088 [[3696]] = [[752]]
:1090 [[3648]] = [[2752]]   (ENV1)      :1091 [[3664]] = [[3232]]  (ENV2)

:1093 v176 = [1792] * [4016]                      // DELAYED LFO × gain
:1094 v177 = [4016] * [1808];   :1095 [3712] = v177   // UNDELAYED LFO × gain
:1098 v180 = v176 * [4032]                        // × DCO LFO MOD depth
:1100 v182 = ([3984] * v177) * [4000]  → [3744]   // mod-wheel vibrato ([4000] = 0)
:1103 v184 = ((([3856] * [3680]) - ([4112] * [3856])) + [4112]) * [4128] → [3760]  // bend
:1105 v185 = (([4048] * v180) + v182) + ([3872] * v184)

:1108 [3776] = ( ( ( ( ( (([4080]*[3664]) + ([4064]*[3648])) * [4096] )
                        + v185 )
                      + v169 )
                    + [3952] )
                  + [3968] )
:1115 [[3792]] = [[3840]]                         // DCO RANGE feet, staged
:1116 [3824] = ([3744] + [3696]) + [3760]         // write-only tap
```
`[4064]/[4080]/[4096]` and `[3952]` have no writer ⇒ the env→pitch and the spare
offset terms are 0. `[3968]` is the **per-voice** UNISON detune.

### 3.10 PWM sum `[3808]` and the pulse width — :1117-1123, :1706-1711
```
:1117 [3808] = ( ( ( ( ( ( ([3712] * [4160]) + [4176] ) * [3888] )
                        + ([3904] * [3648]) )
                      + ([3920] * [3664]) )
                    + [3936] )
                  * [4144] )

:1706 v397 = [5520]                                  // CONDITION per-voice duty trim
:1711 [4816] = v397 + [3808]                         // the DCO's pulse width
```
`[4160] = [4176] = 0.5` map the LFO's ±1 to 0…1. `[3888]/[3904]/[3920]/[3936]`
are the PWM SOURCE one-hot (LFO / ENV1± / ENV2± / Manual, `juno_apply.c:363-386`;
the ENV arms are **signed** ±1). `[4144]` is DCO PWM DEPTH (curve 45); its
unapplied default is the denormal-ish `6.8337208e-26` (prepare :253), so an
unrecalled engine has essentially zero PWM. Prepare also arms `[3936] = 1.0`
(Manual), so the default PW is `[5520] + [4144]`.

**The PWM LFO term uses `[3712]`, i.e. `[1808]` — the UNDELAYED LFO.**

### 3.11 Keyfollow — :1176-1179, :1227
```
:1178 [[6992]] = [[6976]]
:1179 [6976] = ([880] * [6960]) + ([752] * [6944])      // both weights 1.0
:1206 v224 = [6976]                                     // fresh value
:1227 …+ ( ((v224 + [7488]) * [7408]) + (v223 * [7392]) )   // into the cutoff CV sum
```
`[7488] = −4.0`, `[7408]` = VCF KEY FOLLOW (recall curve 24 — **bipolar**;
`juno_apply.c:195-198` documents the blob-44-not-48 fix). The DCO's key mix at
:1081 uses the same `[752]`/`[880]` with unity weights. So the VCF and the DCO
track exactly the same glided pitch; only the VCF applies an offset and a
signed depth.

### 3.12 LFO → VCF smoothers — :1187-1203
```
A (from the DELAYED [1792]):
:1189 [7104] = [7088]                    // DEAD STORE (overwritten at :1194)
:1190 v213 = [1792] - [7088]
:1191 v214 = (v213 * [7120]) + [7088]
:1193 [7088] = v214                                        // CARRIED
:1194 [7104] = (v213 * [7136]) + ([7152] * v214)           // [7136]=0, [7152]=1

B (from the UNDELAYED [1808]):
:1197 [7184] = [7168]                    // DEAD STORE (overwritten at :1203)
:1198 v218 = [1808] - [7168]
:1199 v219 = (v218 * [7200]) + [7168]
:1201 [7168] = v219                                        // CARRIED
:1202 v221 = (v218 * [7216]) + ([7232] * v219);  :1203 [7184] = v221
```
In the cutoff sum (:1219-1226, VCF.md owns it) the **B/undelayed** path is
scaled by `[7360]·[7376]` (MOD SENS VCF · MOD SW) and the **A/delayed** path by
`[7344]` (VCF LFO MOD). Same delayed/undelayed split as the DCO.

### 3.13 CONDITION scatter — set at recall (`juno_apply.c:472-485`), never in render
```
C     = clamp(cbyte, 0, 255)
recip = f32(0x3bfe03f8)                  // 1/129 as float32
L     = (float)(C + 1) * recip           // NOT (C+1)/129 — one multiply
cube  = (L * L) * L
for v in 0..7:
    [5520  + v*10512] = L    * COND_TUNE_SCAL[v]
    [7600  + v*10512] = cube * COND_FINE_SCAL[v]
    [10320 + v*10512] = cube * COND_GAIN_SCAL[v] + 1.0f
    // 3968 and 7616 are left at 0.0
```
At the default byte 128, `L == 1.0f` and `cube == 1.0f` exactly (I decoded the
bits and evaluated the two float32 products: `129.0f * 0x3bfe03f8 == 0x3f800000`).
Tables (`juno_apply.c:466-471`):

| v | TUNE (→5520) | FINE (→7600) | GAIN (→10320, +1) |
|---|---|---|---|
| 0 | 0.02 | 0.0 | −0.0 |
| 1 | 0.01 | 0.00416666688 | −0.005 |
| 2 | 0.025 | 0.00186666672 | −0.015 |
| 3 | 0.015 | −0.00150833325 | −0.01 |
| 4 | −0.005 | 0.00208333344 | −0.02 |
| 5 | −0.015 | −0.00333333341 | −0.0 |
| 6 | 0.0 | −0.00249999994 | −0.02 |
| 7 | −0.01 | 0.000833333354 | −0.008 |

Ordering constraint (`juno_apply.c:463-465`): `juno_apply_condition` **must run
after** `juno_driver_seed_voices`, which replicates voice 0 over voices 1..7 and
would otherwise flatten the scatter. Same for `juno_apply_unison_spread`
(`juno_apply.c:491-492`).

---

## 4) Coefficients / constants table

Bits are authoritative — store the bit pattern, not the decimal. "44100 / else"
means `juno_init.c`'s two-arm switch (44100 arm = lines 315-614, else arm =
617-916; the else arm serves 48000/88200/96000/192000).

| cell(s) | bits | value | writer | role |
|---|---|---|---|---|
| 768 | 0x43800000 | 256.0 | init:919 | glide step scale |
| 784 | 0x30000000 | 4.6566129e−10 | init:920 | glide rate epsilon |
| 800 | 0x34000000 | 1.1920929e−07 | init:921 | glide divisor epsilon |
| 816 | 0x3D4CCCCD | 0.05 | init:922 | arrival window |
| 832 | 0x3089705F | 9.9999997e−10 | init:923 | arrival ramp step |
| 848, 864 | 0x3F800000 | 1.0 | init:924-925 | mod-CV weights |
| 624 | 0x3D01499D | 0.031564344 | prep:107 computes `·(96000/H)`, **prep:239 then overrides it with the raw 96 k value** | portamento time base (recall curve 7, sr_variant 2) |
| 592, 608 | recall | 0 / 1 | apply row 237, apply:654 | PORTAMENTO on/off, MODE |
| 1152 | 0x3D06090A | 0.032723464 | init:926 | **rate-INVARIANT** rate-smoother coeff |
| 1168 | 0xC1A00000 | −20.0 | init:927 | rate-mod exponent (nets to ×1.0) |
| 1184 | 0x3EEEB6BD | 0.46623793 | init:928 | exp rate scale |
| 1200 | 0x40A911CA | 5.2834215 | init:929 | exp rate arg gain |
| 1216 | 0xBED3A702 | −0.41338354 | init:930 | exp rate offset |
| 1088, 2064 | recall curve 22 | dflt 0x3F119192 = 0.56862748 | apply rows 215-216, prep:240/242 | LFO RATE / noise mix |
| 1072 | recall `c48(b)·c53(1280)`; live BPM | — | apply:622, :804-816 | tempo-synced rate |
| 1056 | recall curve 52 | 0 / 1 | apply row 244 | TEMPO SYNC |
| 1920 | recall arm 42/43/44 | dflt 0x3C2AAA78 = 0.010416619 | apply row 217; **prep:241 overrides prep:128** | LFO DELAY one-pole |
| 1936 | recall `(b!=0)?1:0` | 0 / 1 | apply:621 | LFO DELAY switch |
| 1872 | recall `(b==0)?1:0` | 0 / 1 (dflt 1.0) | apply:623, prep:97 | LFO KEY TRIG (0 ⇒ retrigger) |
| 1888 | 0x3F800000 | 1.0 | prep:76 | phase run gate |
| 1952 | 0x3F800000 | 1.0 | prep:77 | LFO Sin enable (**the only waveform enabled**) |
| 2080 | 0x3F800000 | 1.0 | prep:78 | LFO Internal enable |
| 1968,1984,2000,2016,2032,2048,2096,2112 | — | 0.0 | none (calloc) | tri/sqr/saw/saw-inv/S&H/noise/ext0/ext1 enables |
| 2128 | 0x3C7E8251 | 0.015534000 | init:942 | phase-inc clamp max |
| **2144** | **0x400B51DA @44100 / 0x3F800000 else** | **2.1768708 / 1.0** | init:943 (v30 @:593/:916) | **rate→phase-inc scale (96000/44100 at 44.1 k)** |
| 2160 | 0x3B30F27C | 0.0027000001 | init:944 | sine c0 |
| 2176 | 0x3DFA0F91 | 0.12210000 | init:945 | sine c1 |
| 2192 | 0x4009844D | 2.1487000 | init:946 | sine c2 |
| 2208 | 0xBF612D77 | −0.87959999 | init:947 | sine c3 |
| 2224 | 0xBEC94467 | −0.39309999 | init:948 | sine c4 |
| 2240 | 0xBF0072B0 | −0.50174999 | init:949 | sine offset |
| 2256 | 0x402DF855 | 2.7182820 (e) | init:950 | delay-env scale |
| 2272 | 0xBF21D2AF | −0.63212103 | init:951 | delay-env offset (= −(1−1/e)) |
| 2288 | 0xBF800000 | −1.0 | init:952 | saw phase offset |
| 2304 | 0x00000000 | 0.0 | init:953 | square phase offset |
| 2320 | 0xBF000000 | −0.5 | init:954 | triangle phase offset |
| 2336 | 0x00000000 | 0.0 | init:955 | sine phase offset |
| 2352 | 0x3F000000 | 0.5 | init:956 | saw gain |
| 2368, 2384, 2416 | 0x3F800000 | 1.0 | init:957,958,960 | square / triangle / S&H gain |
| 2400 | 0x40000000 | 2.0 | init:959 | sine gain |
| 2432 | 0x3F000000 | 0.5 | init:961 | noise gain |
| 2448 | 0x41600000 | 14.0 | init:962 | noise smoother mix |
| 2464 | 0x3C68A71E | 0.014200000 | init:963 | noise smoother coeff |
| 2480 | 0xBF000000 | −0.5 | init:964 | saw offset |
| 2496, 2512 | 0x00000000 | 0.0 | init:965-966 | square threshold / offset |
| 3584, 3600, 6944, 6960 | 0x3F800000 | 1.0 | init:989-990, 1069-1070 | key-CV weights (DCO, VCF) |
| 7488 | 0xC0800000 | −4.0 | init:1077 | VCF keyfollow offset |
| 7408 | recall curve 24 (bipolar) | patch | apply row 195 | VCF KEY FOLLOW |
| 3872, 3936, 4016, 4048 | 0x3F800000 | 1.0 | prep:79-82 | bend arm, PWM Manual, LFO gains |
| 4160, 4176 | 0x3F000000 | 0.5 | init:991-992 | LFO ±1 → 0…1 for PWM |
| 3856, 3952, 4000, 4064, 4080, 4096, 4112, 6720, 7312, 7328, 7376 | — | 0.0 | none (calloc) | dead/live-host mod terms |
| 3984 | recall curve 22 | dflt 0x3DB0B0B1 = 0.086274512 | apply:454, prep:251 | MOD SENS DCO |
| 4032 | recall curve 0 | patch | apply row 232 | DCO LFO MOD depth |
| 4128 | recall `c22·c4·mode` | dflt 0x3E2CACAD = 0.16862746 | apply:452, prep:252 | BEND depth DCO |
| 4144 | recall curve 45 | dflt 0x15A931DA = 6.8337208e−26 | apply row 234, prep:253 | DCO PWM DEPTH |
| 3888/3904/3920/3936 | recall one-hot ±1 | — | apply:363-386 | PWM SOURCE |
| 3968 | recall `UNISON_3968[v]` or 0 | per voice | apply:497-506 | UNISON detune |
| 5520 | prep 0x392291E6 = 1.5503875e−4, then CONDITION | per voice | prep:83, apply:480 | pulse-width base ("Duty Tune") |
| 7600 | CONDITION | per voice | apply:481 | cutoff fine trim |
| 7616 | — | 0.0 | none | resonance trim (CONDITION deliberately skips it) |
| 10320 | prep 1.0, then CONDITION | per voice | prep:94, apply:482 | per-voice level |
| 7120, 7200 | 0x3E5A6D3B @44100 / 0x3DC8FB30 else | 0.21330731 / 0.098135352 | init:1071,1074 (v15 @:464/:765) | LFO→VCF smoother coeff |
| 7136, 7216 | 0x00000000 | 0.0 | init:1072,1075 | LFO→VCF direct term |
| 7152, 7232 | 0x3F800000 | 1.0 | init:1073,1076 | LFO→VCF output gain |
| 7296 | 0x3F800000 | 1.0 | prep:85 | LFO gain into VCF |
| — | `juno_exp_acc0[32]`, `juno_exp_ad3c[33]` | exact powers of two | juno_tables.h:47-52 | rate-mod exponent ladder |

**`[1920]` and `[624]` note (READ, easy to get wrong):** `juno_prepare.c:128`
writes a 3-class rate-armed default for `[1920]` and `:107` writes a continuous
`·(96000/H)` default for `[624]` — and then the "SETTLED override" block *later
in the same function* overwrites **both** with rate-INDEPENDENT values
(`:241` → `0x3C2AAA78`, `:239` → `0x3D01499D`). The overrides win; the unapplied
defaults are rate-independent. Recall then supplies the per-patch rate-armed /
rate-scaled values.

---

## 5) Inputs from outside the subsystem

| source | cells | when written |
|---|---|---|
| note path (`juno_note.c`) | `304` M.CV (note-on :160, legato pitch-only :274), `320` M.Gate (:164 open, :249 close), `1856` any-key-held (broadcast, :220-226), `9824` gate twin (:201), `592` porta gate (:300-307) | note on/off, immediate |
| ENV section | `2752` (ENV1 out), `3232` (ENV2 out) → latched to `3648`/`3664` at :1090-1091 | same sample, before :1092 |
| gate binarizer | `560` → glide enable at :694 | same sample, :691 |
| input conditioner | `464` (conditioned pitch CV) → glide target at :702, :721 | same sample, :659 |
| shared noise block | `base[84432]` → `[1424]` at :814 | same sample, :646-653 |
| DCO | consumes `[3776]` (:1641, :1704) and `[4816]` (:1711) | after the output write |
| VCF | consumes `[6976]` (:1206/:1227), `[7104]`, `[7184]`, `[7600]`, `[7616]` | :1187-1254 |
| VCA | consumes `[10320]` (:1598) | :1598 |
| ENV1/ENV2 | consume `[1824]` (:967, :1022) | after :929 |
| recall (`juno_apply.c`) | every "recall" row of §4 | patch load / live edit |
| driver | `juno_driver_seed_voices` (voice 0 → 1..7), then CONDITION + UNISON per voice | boot and cold recall |

### 5.1 Per-VOICE vs SHARED — what a native port may hoist

**Truly shared memory:** only the noise block `base[84272..84436)`. MOD touches
it once, via the `[1424]` latch at :814.

**Per-voice memory, but provably voice-INVARIANT value** — the entire LFO
(`[1040..1216]`, `[1408..2544]`) and every mod-router coefficient. The argument
(INFERRED, by induction on samples; I did not execute it):

* *P1 — identical start.* `juno_driver_seed_voices` (`juno_driver.c:63-70`)
  block-copies `[176, 10688)` from voice 0 to voices 1..7 on every cold boot
  (`gui/juno_bridge.c:158`, `:252`) and on the degraded warm path (`:907`).
  All six carried LFO cells are inside that range.
* *P2 — identical per-sample inputs.* The LFO's only non-constant inputs are
  `[1856]`, broadcast identically to all 8 voices (`juno_note.c:220-226`), and
  `[1424]`, which equals `base[84432]` — and `juno_driver_render_voices`
  restores the noise block **before each voice** (`juno_driver.c:86-95`), so
  all 8 voices read the *same* one-step advance. CLAUDE.md records that this
  snapshot/restore is PROVEN equivalent to the plugin's 9 isolated units (the
  164-byte block byte-identical across units 0..7 at 6 checkpoints × 5
  scenarios).
* *P3 — identical updates.* Warm patch loads replicate only CHANGED BYTES, to
  all 8 voices (`gui/juno_bridge.c:909-916`); a live param edit writes all 8
  copies (`gui/juno_bridge.c:280-289`).
* *P4 — the per-voice constants don't reach it.* CONDITION writes 5520/7600/
  10320 and UNISON writes 3968; none of those four is in the LFO's read set.

⇒ all 8 LFO states are bit-identical every sample, so **computing the LFO once
per sample and broadcasting `[1472]`, `[1776]`, `[1792]`, `[1808]`, `[1824]` is
bit-exact.** Hoisting is worth roughly one eighth of the LFO cost. See §7 R4 for
what invalidates it.

**Per-voice DISTINCT — never hoist:**

| what | cells | why |
|---|---|---|
| glide | 656, 672, 688, 704, 720, 736, 752, and the input 592 | per-voice pitch target and per-voice legato gate |
| keyfollow | 3616, 6976 | derived from `[752]` |
| CONDITION | 5520, 7600, 10320 | per-voice by construction |
| UNISON | 3968 | per-voice table |
| pitch sum | 3776 (contains 3616 and 3968) | — |
| PWM total | 4816 (contains 5520) | — |
| LFO→VCF smoothers | 7088, 7168 | voice-invariant *inputs*, but they sit in the VCF's per-voice state; hoisting them would also require proving the VCF path identical, which it is not (CONDITION) |

Note that `[3808]` (the PWM sum before the per-voice trim) *is* voice-invariant
whenever the PWM SOURCE is LFO or Manual, but becomes voice-distinct as soon as
the source is ENV1/ENV2 (the envelopes are per-voice). Do not hoist it.

---

## 6) Native-rewrite notes

1. **Six carried floats are the whole LFO.** `rateSm, extGatePrev, delayRamp,
   phase, noiseSm, shHold`. Everything else in `[1408..2544]` can be locals as
   long as the memory stores remain for any outside reader.
2. **Keep the memory stores.** `[1792]`, `[1808]`, `[1824]`, `[752]`, `[3616]`,
   `[3776]`, `[3808]`, `[6976]` are read by other subsystems *through the
   cells* later in the same sample; `[1744]`, `[1776]`, `[3824]`, `[1664]`,
   `[1520]`, `[1840]`, `[720]`, `[736]` have no in-file reader but should still
   be written until proven dead (same policy as ENV.md/DCO.md).
3. **Three dead stores may be dropped** (verified: no reader between the store
   and its overwrite): `[1504]` at :810, `[7104]` at :1189, `[7184]` at :1197.
   Also the two `fmodf` calls at :892 and :896 whose results are discarded —
   these must **not** be turned into assignments to `v107`; `juno_triangle`
   performs the wrap itself (`src/juno_dsp.c:56-61`), and this exact mistake is
   already recorded in the transcription's comment at :898-904.
4. **Two cells are dead inputs**: `[1632]` (no writer, read only to feed the
   write-only `[1648]`) and `[7616]`.
5. **Rate arms.** Only three constants in this subsystem are rate-dependent:
   `[2144]` (2-arm, 44100 vs else), `[7120]`/`[7200]` (2-arm), and `[1920]` +
   `[624]` (recall-side, 3-class / continuous). `[1152]` and `[2464]` look like
   smoother coefficients but are written unconditionally by `juno_init` — they
   are rate-INVARIANT. Do not "fix" them.
6. **The rate ladder** at :742-781 is a two-sided `ldexpf` that nets to ×1.0 at
   the shipped `[1168] = −20`. A native port may keep the tables verbatim; it
   may **not** replace the pair with `powf(2, e) * powf(2, -e)` — the saturating
   arms (`< -32`, `> 32`) and the `~e` index are part of the law.
7. **Collapse only behind a flag.** With the shipping recall the LFO reduces to
   `phase → |phase| → quartic → ×[2080]·delayDepth`. That is a legitimate fast
   path, but the six zero-valued waveform enables and the four zero-valued rate
   inputs are engine-reachable cells; guard the fast path on them actually
   being zero rather than deleting the general form.
8. **`fmodf` must be the libm one** (or a bit-identical reimplementation).
   `phase - 2.0f*truncf(phase*0.5f)` is not the same function at the edges.
9. **`expf` at :798** — see §3.3.
10. **Order:** LFO before ENVs; glide before the LFO (the glide does not read
    the LFO, but `[752]` is latched at :1088 into `[3696]` which the bend tap
    reads). Keyfollow after glide. CONDITION is not computed here at all.

---

## 7) RISK

**R1 — the delayed/undelayed LFO split (highest risk).** `[1792]` has the LFO
DELAY envelope applied; `[1808]` does not. Pitch vibrato and VCF LFO MOD use
`[1792]`; **PWM and the mod-wheel path use `[1808]`**. A native port that keeps
one LFO output will sound correct on a patch with LFO DELAY = 0 and wrong on
every patch that uses the delay — and `null_ab.py`'s five scenarios (patches 5,
15, 61, 20, 2) may not include one, so this can pass the gate. Add a scenario
with a nonzero LFO DELAY *and* PWM SOURCE = LFO before trusting a green.

**R2 — the LFO retrigger is a multiply on the summed phase, and it is gated by
the BROADCAST any-key-held flag, not by the voice's own note-on.** Getting this
wrong produces the classic "almost right" LFO: retriggering per note in POLY
(the reference retriggers only on the first key of a phrase), or landing on
`inc` instead of exactly 0.0. Both are inaudible on a single-note gate test and
obvious on a held chord.

**R3 — `[2144]` inverted.** `2.1768708 @44100 / 1.0 else` (the *44100* arm is
the large one — `v30` at `juno_init.c:593` is inside the `== 44100` branch).
Swapping the arms makes the LFO 2.18× too slow at the most common host rate.
`null_ab.py` runs at 44100 only (`SR = 44100.0`), so an inverted arm would be
caught, but a *missing* `[2144]` would look like a 2.18× LFO everywhere.

**R4 — the LFO hoist is legal only under P1..P4 of §5.1, and it is INFERRED,
not executed.** It breaks if: a host drives `[944]`/`[976]`/`[1008]`/`[1904]`
(the external LFO/gate inputs — all currently 0 with no writer); the noise
snapshot/restore in `juno_driver_render_voices` is removed or reordered; a warm
path restores a state dump with per-voice-different LFO cells; or any future
per-voice LFO parameter appears. If a native port hoists, it should keep a
debug assert that voice 0's `[1536]` equals voice 7's.

**R5 — the live bend / mod-wheel / external-LFO chain is structurally present
and numerically dead.** `[368]`, `[384]`, `[3552]`, `[3856]`, `[4000]`,
`[4112]`, `[7456]`, `[944]`, `[976]`, `[1008]`, `[1904]`, `[6720]`, `[7312]`,
`[7328]`, `[7376]`, `[2096]`, `[2112]` have **no writer anywhere in the port**,
so every term they gate evaluates to 0.0 and `null_ab.py` cannot see a mistake
in them. They are real, host-reachable engine cells (`juno_mod.c` documents the
#112 host modulation layer that reaches six *other* indices). Transcribe those
terms verbatim; do not fold them away.

**R6 — glide state updates unconditionally.** §3.1. A "skip the block when
portamento is off" optimization is wrong.

**R7 — CONDITION must be applied after `seed_voices`, and 7616 must stay 0.**
`juno_apply.c:463-465`, `:483`. Re-seeding after applying CONDITION silently
flattens the analog scatter to voice 0's values, which is exactly the kind of
change that shifts timbre a few percent and passes a single-voice test. Note
also that `[5520]` feeds the **pulse width** (`[4816] = [5520] + [3808]`,
:1711) despite the applier's "per-voice detune (tune-trim)" comment — the math
is authoritative, the label is not (also flagged as DCO.md §5 open question 2).

**R8 — the "sine" is a quartic in |phase|, and the saw is unipolar.**
`[1680] ∈ [−1, 0)` and `[1696] ∈ (0, 1]`. Substituting a textbook bipolar ramp
or a real `sinf` changes both level and offset of every modulation destination.
Neither matters for the *factory* bank (only `[1952]` is enabled), which is
precisely why it would survive the gate and then break the first user patch
that switches waveform.

**R9 — `[1552]` looks carried but is not.** It is written at :811 from the
pre-update phase and read at :854 in the same sample. A native port that treats
it as a genuine one-sample delay (using the value from the *previous* sample)
shifts the S&H trigger by one sample. Conversely, `[1488]` and `[1504]` *are*
genuinely carried and their previous values are load-bearing for the edge test.

**R10 — unverified claims in this document.** The LFO-hoist induction (§5.1),
the "×1.0 exactly" collapse of the rate ladder (§3.3), the delay-envelope's
"one time constant" reading (§3.4), and every waveform-shape interpretation are
**INFERRED** from the source. The equations, cells, line numbers, constant bit
patterns and writer sites are **READ**. Nothing here was executed against the
plugin by me.
