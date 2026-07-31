# DCO — native-implementation blueprint (Track B)

Source of truth for this doc: `src/voice_render.c` (exact transcription of the
plugin's per-voice render, sub_180369070), `src/juno_init.c` (constructor
constants), `src/juno_prepare.c` (setSampleRate constants), `src/juno_apply.c`
(recall BINDINGS), `src/juno_note.c` (note path), `src/juno_dsp.c` +
`src/juno_tables.h` (helpers/tables), `src/juno_driver.c` (drive protocol).
Every claim is labeled **READ** (seen in source, cited file:line) or
**INFERRED** (deduced). All state offsets are bytes; `s[N]` means the float32
cell at offset N relative to the voice base `a1 = base + voice*10512`
(`JUNO_VOICE_MAIN_STRIDE`, juno_engine.h:32). `S[N]` (capital) means the
SHARED region relative to `base` (unshifted, offsets ≥ 84272). `wrap(x)` means
wrap into [-1,1] exactly as transcribed: `x>1 → fmodf(x+1,2)-1`, `x<-1 →
fmodf(x-1,2)+1`, else unchanged (READ voice_render.c:1723-1731; identical to
`juno_wrap_unit`, juno_dsp.c:101-106). `tri(p)` = `juno_triangle` (wrap then
piecewise `2p / 2-2p / -2-2p`, juno_dsp.c:54-71).

**Numeric contract (load-bearing):** every operation is float32 with ONE
rounding per op, in the exact association shown ((float) casts in the source
mark the tree). No FMA (`-ffp-contract=off`). The pitch spline alone is
evaluated in double and collapses to float at the ±512 clamp. A native
implementation must keep the op tree; re-association will not null at −90 dB.

---

## 1. Subsystem boundary

### 1.1 Cells the DCO section OWNS (writes every sample), per voice

**CARRIED vs SCRATCH (READ; mechanically enumerated over every `JF/JI(a1,N)`
access in voice_render.c:34-2183, in source order).** The criterion is exact and
decidable: the body runs identically every sample, and every FIRST access listed
below is unconditional — none falls inside an `if`/`else` block (checked; the
function's branches are the wrap, the sign clamps, the sub edge test and the
§2.0 latch bracket, none of which gates a first access). So a cell is

- **CARRIED** ⇔ its FIRST access in the sample is a READ — the value stored on
  sample *n* is consumed on sample *n+1*. These are the only cells a native
  implementation must keep as persistent state.
- **SCRATCH** ⇔ its FIRST access is a WRITE — nothing from the previous sample
  survives. A SCRATCH cell may still be read later in the SAME sample (an
  intra-sample tap), and the store must still be reproduced for a state-level
  A/B, but it holds no memory.

| group | CARRIED (persistent state) | SCRATCH (write-first) |
|---|---|---|
| gate/pitch conditioning (voice_render.c:623-692) | 496 (`R:638→W:672`), 560 (`R:686→W:691`) | 192, 224, 256, 288, 336, 352, 400, 416, 432, 448, 464, 480, 512, 528, 576 |
| portamento/glide (:693-735) | 656, 672, 688, 704 | 720, 736, 752 |
| bend CV (:724-732) | 880 (`R:725→W:732`) | **896** (`JI(a1,896)=JI(a1,880)`, :725 — int z⁻¹ shadow of 880, write-only: no reader anywhere in voice_render.c) |
| CV / mod sums (:1078-1124) | 3616 (`R:1080→W:1082`) | 3632, 3648, 3664, 3680, 3696, 3712, 3744, 3760, 3776, 3792, 3808, 3824 |
| level pipeline (:1125-1128, :1702-1707) | — | 4240, 4256, 4272, 4736, 4752, 4768 |
| noise voice SVF (:1129-1140) | 4288 (`R:1131→W:1139`), 4304 (`R:1130→W:1132,1134`) | **4320** — written :1140, read :1145, then CLOBBERED at the top of the next sample by :1130 `JI(a1,4320)=JI(a1,4304)` before any read. It looks like SVF state and is not. |
| pitch/inc (:1665, :1704-1717) | — | 4416, 4784, 4800, 4816, 5456 |
| phase/counter (:1670-1671, :1718-2136) | 4832, 4864 (`R:1670/1671→W:2136/2135`) | 4640, 4656, 4672, 4848, 4880 — 4640 (phase) and 4672 (sub counter) do NOT carry directly: they are write-first, and their end-of-sample values reach the next sample only through the :2135-2136 → :1670-1671 handoff `4640→4864→4880` / `4672→4832→4848` (§2.9). |
| osc taps (:1748, 1787 etc.) | — | 4896 (saw), 4912 (pulse) — last sub-block value; the live value flows through the C locals `_s4896`/`v424` |
| 4×-rate history (shifts :1672-1699, writes :1807, 1911, 2015, 2117) | 4944, 4960, 4976, 4992, 5008, 5024, 5040; 5072..5168; 5200..5296; 5328..5424 (7 per phase) | 5056, 5184, 5312, 5440 — the OLDEST tap of each phase is refilled at :1672-1699 before any read, so each polyphase delay line needs **7** persistent registers, not 8 |
| correction state (shifts :1700-1701, writes :2166-2169) | 5472 (`R:1701→W:2169`), 5488 (`R:1700→W:1701,2166`) | 5504 (`W:1700→R:2161`) |
| DCO output (:2173-2174, :1076) | 3520 (`R:1076→W:2174`) — the real one-sample memory into the VCF | 4928, 3536 (3536 is the intra-sample copy OF the carried 3520, :1076) |
| source mix / VCF input (:1141-1149) | 6544 (`R:1148→W:1149`) | 6432, 6464, 6480, 6496, 6560 |

### 1.2 Shared cells (base-relative, one copy for all 8 voices)
Noise block: S[84272..84432] — S[84288], S[84320], S[84352], S[84384] are z⁻¹
copies; S[84336] LFSR core; S[84368] scaled white; S[84432] noise output
(READ :595-653). Same classification (READ, same enumeration): **CARRIED** =
S[84336] (`R:595→W:643`, the LFSR itself) and S[84368] (`R:637→W:645`);
**SCRATCH** = S[84288], S[84320], S[84352], S[84384] (write-only shadows) and
S[84432] (written :653, read :808 and :1129 in the same sample). S[84272],
S[84304], S[84400], S[84416] are read-only inputs (§3). **Drive protocol (READ juno_driver.c:12-21, 73-80):** the
plugin runs 8 ISOLATED engine units; the port snapshots [84272,84436) and
restores it before each voice, so all 8 voices see the SAME single advance per
sample. A native implementation computes the noise step ONCE per host sample
and feeds the same value to all voices. Do NOT chain it 8×.

Aux retrigger latch: `base[101504 + voice*32]` (JUNO_VOICE_AUX_BASE0/STRIDE,
juno_engine.h:33-34), READ :585-594, :2175-2179.

### 1.3 Inputs read from other subsystems / recall (never written here)
- `s304` M.CV note pitch, `s320` M.Gate, `s176/s208` ramp targets, `s240·s272`
  ramp coeff (= 0 in practice, READ juno_note.c:44-47), `s544` gate bias.
- LFO outputs `s1792`, `s1808` (LFO block :854-963, out of scope here).
- ENV1 out `s2752`, ENV2 out `s3232` (ADSR blocks :964-1075).
- Live mod sources `s368, s384` (→880), `s3552→3680`, `s3856`, `s4000`,
  `s4112` — no writer in src/ or gui/ ⇒ 0.0 at rest (READ absence; cf.
  juno_apply.c:432-435 "mod sources 3856/3552/4112 are 0 at rest").
- Recall params (see §4): 592, 624, 3840, 3888/3904/3920/3936, 3952(never
  written ⇒ 0), 3968, 3984, 4032, 4064/4080/4096 (never written ⇒ 0), 4128,
  4144, 4192, 4208, 4224, 5520, 6528.
- Constants from init/prepare: everything in §3.

### 1.4 Output
`s3520` (== `s4928`) is the band-limited DCO+wave-mix output. It enters the
VCF **one sample delayed** through `s3536` (READ :1076, :1144). The noise
path (S[84432] → voice SVF → `s4320`) enters the same mix **without** delay
(:1129-1149). Mix result `s6544` is the VCF input (read at :1298).

---

## 2. Per-sample equations (verbatim-but-simplified, float32 unless noted)

Order below is execution order inside `juno_voice_render` for one voice.

### 2.0 Retrigger latch bracket (READ :587-594, :2175-2179)
```
if (base[aux] == 1.0f) { saved = s320.bits; gate_in = 0.0f; s320 = 0; }
else                     gate_in = s320;
... whole render runs with gate_in ...
if (base[aux] == 1.0f) { s320.bits = saved; base[aux] = 0; }
```
Effect: the gate signal is 0 for exactly one sample (envelope retrigger).
The DCO phase itself is FREE-RUNNING — nothing in :1718-2136 reads the gate
(READ; cf. juno_note.c:56-70).

**Arming rule — THREE armers, and it is MODE-DEPENDENT (READ; the omission of
the third was a real shipped bug, CLAUDE.md / fix e611f7d, caught by fuzz seed
15 and invisible to every cold gate).** A native implementation that arms only
on note-off reproduces that bug exactly:
1. **BUILD**, for all 8 voices at once: `juno_init.c:3225`
   (`JF(a1, JUNO_VOICE_AUX_BASE0 + av*JUNO_VOICE_AUX_STRIDE) = 1.0f` inside the
   `av` loop at :3224) — so every voice's FIRST rendered sample is gate-masked.
2. **Note-off**, the released voice: `juno_note.c:262`
   (`JF(st, AUX_EDGE(voice)) = 1.0f;`). (Line 255 is inside the explanatory
   comment block, not the write.)
3. **MONO retrigger only**: `juno_note_retrig()`, `juno_note.c:238`, whose sole
   caller is `gui/juno_bridge.c:596` in `mono_note_on`'s idle/releasing branch.
   A **POLY note-on does NOT arm it** — the plugin's POLY note-on writes only
   the DSP-inert aux Array B at `101520 + 32v` (READ from the mode-dependence
   note at juno_note.c:166-184, which records the measurement against the plugin
   on a warm engine). Arming unconditionally is measurably wrong: per that same
   note it takes fuzz_diff from 1 diverged seed to 18, because it re-phases every
   POLY note.

The latch is consumed and cleared by the render itself (:2175-2179), so it is a
true one-shot; `juno_note_glide` deliberately leaves it untouched (legato slide
must not re-phase the DCO).

### 2.1 Shared noise generator — once per sample (READ :595-653)
```
w   = S84336            ; c1 = S84272 ; c2 = S84304        // previous values
S84352 = w ; S84288 = c1 ; S84320 = c2                     // z⁻¹ taps
n   = (int)(w * -16777216.0f)                              // trunc, NEGATED 2^24
if (n == 0) m = 1;
else        m = 2*n + ((bit23(n) == bit21(n)) ? 1 : 0)     // XNOR feedback, shl
m   = (m & 0x1000000) ? (m | 0xFF000000) : (m & 0xFFFFFF)  // sign-extend bit24
S84336 = (float)m * 5.9604645e-8f                          // 2^-24  (:640-643)
S84384.bits = S84368.bits                                  // z⁻¹     (:637)
f   = S84336 * S84400 + S84416                             // (:644)
S84368 = f
S84432 = (c1*c2 - c2*f) + f                                // = f + c2*(c1 - f)
```
c1 = S84272 and c2 = S84304 have NO writer anywhere except chorus_init's zero
of 84272 (chorus_init.c:2472; 84304 is never touched) ⇒ both are 0.0 forever
⇒ `S84432 == f` (READ+INFERRED). S84400 = 1.0 @44100, 1.4754223 @else (§3).
The exact int truncation, negation, and bit pattern are load-bearing (the
sequence is the plugin's PRNG); keep verbatim.

### 2.2 Gate & pitch conditioning (READ :623-692)
```
k    = s272 * s240                    → s448   // == 0.0 in practice (juno_note.c:44-47)
cv   = (s176*k - k*s304) + s304       → s464   // v28, :657 — THREE roundings
g    = (s208*k - gate_in*k) + gate_in → s480   // v29, :658 — THREE roundings
s192 = s176 ; s224 = s208 ; s288 = s272 ; s256 = s240 ; s336 = s304 ; s352 = gate_in
s512.bits = s496.bits (previous) ; s432 = 0
t    = g + s544                                // s544 rate-armed: 0.022675700 @44100
                                               //                / 0.010416600 @else (§3)
u    = (g == 0.0f) ? -1.0f : (t < 0 ? t : 0)   → s496 (pre-clamp value)
u    = clamp_sign(u)                           // <0→-1, >0→+1, 0 stays 0
bin  = u + 1.0f                       → s528, s560     // binary gate ∈ {0,1}
s576.bits = old s560.bits
```
`s560` is the binary gate consumed by both ADSRs (:973, :1028) and the VCA
(:1551). Exact float math verbatim from :623-692.

**Association note (load-bearing, corrected):** `cv` and `g` are NOT the
two-rounding lerp `a + k*(b-a)`. The source (:657-658) expands them into a
three-rounding tree — `(b*k − k*a) + a` — the same shape the doc gives verbatim
for §2.3's `out` (v56) and §2.5's `bndTrm`. Transcribe :657-658 as written.
This is numerically inert **only because k ≡ 0.0**: cells 176, 208, 240 and 272
have NO writer anywhere in `src/` or `gui/` (READ — grep over both trees returns
zero assignments to those offsets), so `s448 = s272*s240 = 0` and both
expressions collapse to `cv = s304`, `g = gate_in`. If any future path writes
those cells, the tree becomes audible and the lerp form will not null.

### 2.3 Portamento / glide → s752 (READ :682-735)
```
en   = ((bin*s608 - s608) + 1.0f) * s592       → s736   // v45; s592=Porta OnOff,
                                                        // s608=legato&&assign gate (juno_apply.c:654)
step = (s672 / ((256.0f*s624) + 1.1920929e-7f)) * 256.0f          // v46 (s768=256, s800=eps)
e    = (s656 - step + cv) - s704               → s656   // error accumulator
d    = e * (s624 + 4.6566129e-10f)             → s672   // s784=eps
cand = d + s704                                          // glide candidate
if ((0.05f - fabs(s704 - cv)) < 0) x = 0;                // s816=0.05 window
else { x = s688 + 1e-9f; if (x >= 1) x = 1; }            // s832=1e-9
s688 = x
out  = cand + x*(cv - cand)                              // (v56 = x*cv - x*cand + cand)
if (en == 0.0f) out = cv                                  // porta off/idle → direct
s704 = out ; s752 = out
```
(Exact op order :693-735 — the `en` chain starts at :694 `v43 = (v36*s608) -
s608` and :696 `v45 = (v43 + 1.0)*s592`, and `s720 = s704_old` is :693.)
Recall: s592 = PORTAMENTO on/off, s624 = porta time, SR-variant
`juno_curve(7)·(96000/H)` for H≠96000 (juno_apply.c:237-238).

**Prepare default of s624 is RATE-INDEPENDENT (corrected).** `juno_prepare.c:107`
does write `f32(0x3d01499d) * (96000/H)`, but that store is **dead**: the later
SETTLED-override block rewrites the cell unconditionally at
`juno_prepare.c:239` — `JI(st, 624) = 0x3d01499d;` — and `juno_engine_prepare`
has NO statement-level control flow (no `if`/`switch`/loop/early return; the
file's only conditionals are inline `?:` rate-selects on assignment right-hand
sides, e.g. :159, :177, :202-224), so :239 always executes after :107. The
cold/pre-recall value is therefore **0x3D01499D = 0.031564344 at every host
rate**, not 0.068711 at 44100. (The rate-dependent
`96000/H` post-multiply is real, but it lives on the RECALL path — juno_apply
row `{54, 7, T_ID, 624}` — not in the cold state.)

### 2.4 Bend CV and key mix (READ :724-732, :1078-1082)
```
s896.bits = s880.bits                 // (:725) int z⁻¹ shadow, taken BEFORE the
                                      // new s880 is stored at :732; write-only
s880 = s384*s864 + s368*s848          // s848=s864=1.0 ; s368/s384 live inputs (0 at rest)
s400 = s368 ; s416 = s384
s3616 = s880*s3600 + s752*s3584       // s3584=s3600=1.0  → key CV mix (:1081)
s3632.bits = old s3616.bits
```

### 2.5 Pitch-mod sum → s3776, PWM sum → s3808 (READ :1083-1124)
Copies first: `s3648.bits = s2752.bits` (ENV1), `s3664.bits = s3232.bits`
(ENV2), `s3680.bits = s3552.bits`, `s3696.bits = s752.bits` — the loads are at
:1084-1086, the stores at :1087-1088 and **:1090-1091**
(`JI(a1,3648)=v171; JI(a1,3664)=v172;`). **These are same-sample latches, NOT
delays:** ENV1's output cell 2752 is written at :1020 and ENV2's 3232 at :1074,
both in straight-line code BEFORE these copies, and 3648/3664 are read back at
:1108-1109 and :1120-1121 in the same sample. See §4.
```
lfo2   = s4016 * s1808                → s3712
lfoTrm = (s1792 * s4016) * s4032               // DCO LFO MOD depth (recall)
modTrm = (s3984 * lfo2) * s4000       → s3744  // mod-wheel vibrato (0 at rest)
bndTrm = ((s3856*s3680 - s4112*s3856) + s4112) * s4128   → s3760
                                                // = (bend + src*(mod−bend))·bend-depth
mid    = (s4048*lfoTrm + modTrm) + s3872*bndTrm          // s4048=s3872=1.0
s3776  = (((((s4080*s3664 + s4064*s3648)*s4096) + mid) + s3616) + s3952) + s3968
        // 4064/4080/4096 and 3952 have no writer ⇒ terms are 0.0 (env→pitch absent);
        // s3968 = per-voice UNISON detune (juno_apply.c:487-504), else 0
s3808  = (((((s3712*0.5f + 0.5f) * s3888) + s3904*s3648) + s3920*s3664) + s3936) * s4144
        // s4160=s4176=0.5 map LFO ±1→0..1 ; 3888/3904/3920/3936 = PWM SOURCE one-hot
        // (juno_apply.c:363-386, ENV arms signed ±1) ; s4144 = PWM DEPTH curve45
s3824  = (s3744 + s3696) + s3760               // write-only tap (no consumer, READ grep)
```
Level pipeline (two z-stages): `s4240.bits=s4192.bits ; s4256.bits=s4208.bits ;
s4272.bits=s4224.bits` (:1125-1128) then later `s4736.bits=s4240.bits ;
s4752.bits=s4256.bits ; s4768.bits=s4272.bits` (:1702-1707). 4192/4208/4224 =
recalled SAW/PWM/SUB levels (curve 54, juno_apply.c:204-220).

### 2.6 Noise voice filter → s4320 (READ :1129-1140) — Chamberlin-style SVF
```
x    = S84432                          // shared noise output (this sample)
s4320.bits = s4304.bits                // (:1130) shuffle first
b    = s4288 ; s4304 = b
lp1  = b*s4336 + s4320        → s4304  // overwrites: s4304 = lp1
hpin = b*s4352 + lp1                   // s4352 = 2.0
bpwt = lp1 * s4400                     // s4400 = 1.2
e    = x - hpin
s4288 = e*s4336 + b
s4320 = (e*s4368 + bpwt) + s4288*s4384 // s4368 = −0.3, s4384 = 0.0
```
`s4336` = SVF g: 0.7071496 @44100 / 0.3305040 @else (§3). Output `s4320`.

### 2.7 Source mix → s6544 (READ :1141-1149)
```
s6432.bits = s6416.bits               // s6416 = 1.0 (init :1062)
dco   = s6448 * s3536                 → s6480  // s6448 = 1.0 "osc enable" (prepare :75)
noise = s6432 * s4320                 → s6496
s6560.bits = old s6544.bits
s6544 = noise*s6528 + dco*s6512       // s6528 = NOISE LEVEL (recall curve54),
                                      // s6512 = 1.0073647 (prepare :84)
```
NOTE the one-sample delay: `s3536` is LAST sample's DCO out (:1076).

### 2.8 Pitch spline → frequency → increment (READ :1641-1665, :1704-1717)
```
x    = clampd((double)(s4448 + s3776), -20.0, 8.9)       // s4448 = −4.75 fixed tune
row  = juno_pitch_table[(int)(x + 20.0)]                 // 29 rows × 26 doubles
                                                          // (juno_tables.h:12)
poly = row[0] + x·row[2] + x²·row[4] + x³·row[6] + x⁴·row[8] + x⁵·row[10]
     + x⁶·row[12] + x⁷·row[14] + x⁸·row[16] + x⁹·row[18] + x¹⁰·row[20]
     + x¹¹·row[22] + x¹²·row[24]                          // ALL double; exact power
                                                          // factoring :1642-1661
r    = fmaxf(fminf(poly, 512.0), -512.0)                  // → float32 here
s3792.bits = s3840.bits                                   // DCO RANGE feet (:1107,1115)
f    = r * s3792                       → s4416            // "frequency" tap
inc  = fmaxf(s5568, f * s5536)         → s4784            // s5568 = 2^-32 floor
s4800 = 0.00390625f / inc                                 // (1/256)/inc
s4816 = s5520 + s3808                                     // pulse-width total (PW)
s5456 = max(0, (s3776 + s6304)*s6320 + s6288)             // s6320=0 ⇒ = s6288
```
`s5536` = 220/44100 @44100, 220/96000 @else (§3). The DCO core runs 4
sub-steps per host sample (§2.9), so **freq = 2·inc·H_design** (INFERRED
identity; phase span 2, 4·inc advance per sample). Feet `s3840` =
`0.125·2^min(byte,5)` (recall, juno_apply.c:624; default 1.0 = 8').

### 2.9 The 4×-oversampled oscillator core (READ :1718-2136)
Phase/counter resume: `s4848.bits = s4832.bits ; s4880.bits = s4864.bits`
(:1670-1671); at the end of the sample `s4864.bits = s4640.bits ;
s4832.bits = s4672.bits` (:2135-2136) — a plain handoff, no extra delay.

Define the shared **sine window** `S(x)` (Taylor sin to x¹¹, exact grouping
READ :1778-1786 and equivalents):
```
S(x) = ((x²·s6016 + s6000)·(x²·x²) + (x²·s5984 + s5968)) · (x²·x·x²)
     + (x²·x)·s5952 + x
     // s5952 = −1/6, s5968 = 1/120, s5984 ≈ −1/5040, s6000 ≈ 1/362880,
     // s6016 ≈ −1/39916800  (exact bits in §3; keep the bits, not the fractions)
```
**All three instances use the IDENTICAL tree** (READ, re-derived term by term):
saw :1741-1748, pulse :1778-1786, sub :1807-1823. The saw block merely names the
shared subexpression `x²·x` as `v409` (so its x⁵ multiplier reads
`v409*(x²)` and its cubic term `v409*s5952`), where the pulse/sub blocks write
`((x²·x)·x²)` and `((x²·x)·s5952)` out in full — same operands, same
association, same rounding sequence. That is decompiler CSE naming, **not** a
different order: implement ONE `S(x)` and call it three times.

Each of the four sub-blocks k = 1..4 executes the code below. Line ranges,
corrected: the per-block body is **1718-1823 / 1826-1927 / 1930-2031 /
2034-2133**, and the trailing `s4656 = p ; s4672 = cnt` re-save sits BETWEEN
bodies at **:1824-1825 / :1928-1929 / :2032-2033** (it is simultaneously block
k's epilogue and block k+1's prologue — it hands the just-computed phase down as
the next block's `p_prev`). Block 4 has no such re-save; its tail is instead the
cross-sample handoff at **:2135-2136**.
```
p_prev = (k==1) ? s4880 : s4640 ;  s4656 = p_prev ; (k==1: s4672.bits = s4848.bits)
p    = wrap(p_prev + inc)                → s4640

// SAW  (:1733-1748)
win  = tri((p + 1.0f) * 0.5f)                       // == 1 − |p| : dist from wrap edge
a    = (win * 256.0f) * s4800 * s5600               // = 0.2·win/inc   (s5600 = 0.2)
a    = clamp(a, -1, 1) ;  x = a * s5552             // s5552 = π/2
saw  = S(x) * (p * s5648)                → s4896    // naive ramp · edge window; s5648=1.0

// PULSE (:1747-1787)
q    = s4816 + p                                    // phase + PW
sq   = clamp_sign(q) * s5664                        // ±0.85 square
win  = tri( q / (q < 0 ? s4816 - 1.0f : s4816 + 1.0f) )
a    = clamp((win * s4800) * 256.0f * s5616, -1, 1) // = 0.1·win/inc   (s5616 = 0.1)
pulse= S(a * s5552) * sq                 → s4912

// SUB  (:1759-1823) — half-frequency square via a 0/2 counter
edge : if (p >= s5584 && s5584 > p_prev) cnt = s4672 + 2 else cnt = s4672
       if (cnt >= 4) cnt = 0 ;  s4672 = cnt         // s5584 = −0.005 crossing
ps   = ((cnt + p) + 1.0f) * 0.5f - 1.0f             // sub phase, period = 2 cycles
ss   = clamp_sign(ps) * s5680                       // ±0.85
win  = tri(-fabsf(ps)) + 1.0f                       // dist from sub transitions
a    = clamp(((win) * s4800) * 512.0f * s5632, -1, 1)  // = 0.2·win/inc (s5632 = 0.1)
sub  = S(a * s5552) * ss

OUT_k = sub*s4768 + (saw*s4736 + pulse*s4752)       // exact order :1807-1823
      → s4944 (k=1) / s5072 / s5200 / s5328
s4656 = p ; s4672 = cnt                             // re-save, k=1..3 ONLY:
                                                    // :1824-1825 / 1928-1929 / 2032-2033
```
Interpretation (INFERRED): each wave is its naive shape multiplied by
`sin((π/2)·clamp(K·dist/inc))` — a windowed-edge band-limiter; `dist` reaches
0 exactly at each waveform discontinuity (saw wrap; pulse both edges,
normalized by PW∓1 so both edges get equal windows; sub sign flips at the
−0.005 crossings, counter timing verified). The clamp saturates to 1 (full
amplitude) more than ~5·inc away from an edge. Sub-block-order details
(k=1 reads counter from s4848, the s4656/s4672 double-writes) must be kept
verbatim — they are what makes edge detection see the previous SUB-sample.

### 2.10 Decimation FIR, 32-tap symmetric (READ :2137-2167)
History shift BEFORE the four new sub-samples are computed (:1672-1699):
each line shifts 4944→4960→…→5056, 5072→…→5184, 5200→…→5312, 5328→…→5440.
After the core, the output is (exact summation order :2137-2165):
```
acc = (s5312+s5072)·s5712 + (s5440+s4944)·s5696          // note: 5712-pair first
    + (s5200+s5184)·s5728 + (s5328+s5056)·s5744
    + (s5424+s4960)·s5760 + (s5296+s5088)·s5776
    + (s5216+s5168)·s5792 + (s5344+s5040)·s5808
    + (s5408+s4976)·s5824 + (s5104+s5280)·s5840
    + (s5232+s5152)·s5856 + (s5024+s5360)·s5872          // = v519
v522 = (acc + (s5392+s4992)·s5888) + (s5264+s5120)·s5904
     + (s5248+s5136)·s5920
v524 = v522 + (s5376+s5008)·s5936
```
16 coefficients s5696..s5936 (§3), rate-independent, symmetric pairs across
the 4-phase × 8-sample history ⇒ a 4→1 polyphase decimator.

### 2.11 Correction stage → DCO output (READ :1700-1701, :2160-2174)
State shift early in the sample: `s5504.bits = s5488.bits ; s5488.bits =
s5472.bits` (:1700-1701). Then:
```
v520 = s5488                       // == old s5472 after the shift
v521 = v520*s6256 + s5504 ;  s5488 = v521
v525 = v524 - (v520*s6272 + v521)
s5472 = v525*s6256 + v520
v526 = ((v521 - v525*s5456) * s6336 - s6336*v524) + v524   // s6336 = 1.0
s4928 = v526 ;  s3520 = v526
```
With s6336 = 1 this reduces to `v526 = v521 − s5456·v525` (INFERRED algebra;
implement the verbatim four-op form). s6256/s6272 and s5456(=s6288) are
rate-armed (§3). This is the IIR completion of the decimator (INFERRED).

### 2.12 Route to outL/outR (summary, READ cites)
`s3520 → z⁻¹ s3536 (:1076) → mix s6544 (:1149) → VCF input stage (:1340)
→ 4-pole ZDF ladder + 32-tap output FIR → s9040 (:1514) → VCA section
(:1568-1605) → s10160 → one-pole (:1606-1612) → dual 3-tap FIRs
(coeffs s10560/s10576/s10592 vs s10608/s10624/s10640) blended by sign of
s9632 (:1613-1637) → s10544 → × s9776 (VCA env) → s10656 (:1638-1639)
→ × s9856 → s10672 (:1640) → *outL = *outR = s10672 (:2180-2182).`
Each voice is MONO; the master reads only the MAIN (even) buffer slots
(CLAUDE.md render-loop findings). Voices must be rendered in order 0..7.

---

## 3. Constants table

"init" = juno_init.c (constructor, 2-arm rate switch: `==44100` lines
314-615, `else` 616-917 — 48000/88200/96000/192000 all take the else arm,
READ juno_init.c:313-314). "prep" = juno_prepare.c. Bits are authoritative.

| offset | bits (44100 / else if armed) | value | writer | role |
|---|---|---|---|---|
| 304 | 0x400004F7 | 2.000303 | prep:68 | M.CV idle default (note-on overwrites, juno_note.c) |
| 544 | 0x3CB9C264 / 0x3C2AAA63 | 0.022675700 / 0.010416600 | init:614/912, store :918 | gate bias in binary-gate test (= 1000/44100 resp. 1000/96000) |
| 592 | recall | 0/1 | apply row 237 | PORTAMENTO on/off |
| 608 | recall | 0/1 | apply:654 | legato&&assign glide gate |
| 624 | 0x3D01499D (rate-INDEPENDENT) | 0.031564344 | prep:**239** (overrides the dead prep:107 divide; +recall curve 7 ·96000/H) | porta/env time base — see §2.3 |
| 768 | 0x43800000 | 256.0 | init:919 | glide step scale |
| 784 | 0x30000000 | 4.6566129e-10 | init:920 | glide eps |
| 800 | 0x34000000 | 1.1920929e-7 | init:921 | glide eps |
| 816 | 0x3D4CCCCD | 0.05 | init:922 | glide completion window |
| 832 | 0x3089705F | 1e-9 | init:923 | completion ramp step |
| 848, 864 | 0x3F800000 | 1.0 | init:924-925 | bend-mix weights (s368/s384) |
| 3584, 3600 | 0x3F800000 | 1.0 | init:989-990 | key-mix weights (752/880) |
| 3840 | recall | 0.125·2^min(b,5) | apply:624 (prep dflt 1.0 :98) | DCO RANGE feet |
| 3872, 3936, 4016, 4048 | 0x3F800000 | 1.0 | prep:79-82 | unity gains (bend arm, PWM Manual, LFO gains) |
| 3888/3904/3920/3936 | recall | one-hot ±1 | apply:363-386 | PWM SOURCE select |
| 3952, 4064, 4080, 4096 | — | 0.0 | none (calloc) | dead pitch-mod terms |
| 3968 | recall | UNISON_3968[v] or 0 | apply:487-504 | per-voice unison detune (semitones) |
| 3984 | recall (curve 22) | e.g. 0.0862745 dflt | apply:454, prep:251 | MOD SENS depth (DCO) |
| 4032 | recall (curve 0) | patch | apply:232 | DCO LFO MOD depth |
| 4128 | recall c22·c4·mode | 0.1686275 dflt | apply:452, prep:252 | BEND depth DCO |
| 4144 | recall (curve 45) | 6.834e-26 dflt | apply:234, prep:253 | DCO PWM DEPTH |
| 4160, 4176 | 0x3F000000 | 0.5 | init:991-992 | LFO ±1 → 0..1 for PWM |
| 4192 / 4208 / 4224 | recall (curve 54) | patch | apply:219/204/220 | SAW / PWM(square) / SUB level |
| 4336 | 0x3F3507C2 / 0x3EA937D3 | 0.7071496 / 0.3305040 | init:613/911 | noise SVF g |
| 4352 | 0x40000000 | 2.0 | init:994 | noise SVF damp |
| 4368 | 0xBE99999A | −0.3 | init:995 | noise SVF mix a |
| 4384 | 0 | 0.0 | init:996 | noise SVF mix b |
| 4400 | 0x3F99999A | 1.2 | init:997 | noise SVF bp gain |
| 4448 | 0xC0980000 | −4.75 | init:999 | fixed DCO tune (juno_note.c:99: do not write) |
| 5520 | 0x392291E6 (prep) | 1.5503875e-4 | prep:83 (+CONDITION per-voice, apply:480) | pulse-width base ("duty/tune trim") |
| 5536 | 0x3BA377EE / 0x3B162FC9 | 220/44100 / 220/96000 | init:592/910 | Hz→phase-inc scale |
| 5552 | 0x3FC90FDB | π/2 | init:1012 | window→sine arg scale |
| 5568 | 0x2F800000 | 2^-32 | init:1013 | inc floor |
| 5584 | 0xBBA3D70A | −0.005 | init:1014 | sub edge-detect threshold |
| 5600 | 0x3E4CCCCD | 0.2 | init:1015 | saw window scale |
| 5616 | 0x3DCCCCCD | 0.1 | init:1016 | pulse window scale |
| 5632 | 0x3DCCCCCD | 0.1 | init:1017 | sub window scale (×512 ⇒ eff. 0.2) |
| 5648 | 0x3F800000 | 1.0 | init:1018 | saw amp |
| 5664, 5680 | 0x3F59999A | 0.85 | init:1019-1020 | pulse / sub amp |
| 5696..5936 | see below | — | init:1021-1036 | decimator FIR taps |
| 5952/5968/5984/6000/6016 | 0xBE2AAAAB / 0x3C088888 / 0xB9500D01 / 0x3638EE91 / 0xB2D79B7C | −1/6, 1/120, ~−1/5040, ~1/362880, ~−1/39916800 | init:1037-1041 | sine Taylor coeffs |
| 6256 | 0x3F3507C2 / 0x3F800000 | 0.7071496 / 1.0 | init:612/915 | correction a |
| 6272 | 0x40000000 / 0x3FB4FDF4 | 2.0 / 1.414 | init:611/909 | correction b |
| 6288 | 0x40000000 / 0x3F800000 | 2.0 / 1.0 | init:610/914 | correction gain (→ s5456) |
| 6304 | 0xC0400000 | −3.0 | init:1059 | s5456 pitch-term offset (dead: ×0) |
| 6320 | 0 | 0.0 | init:1060 | s5456 pitch-term gain |
| 6336 | 0x3F800000 | 1.0 | init:1061 | correction mix |
| 6416 | 0x3F800000 | 1.0 | init:1062 | noise enable |
| 6448 | 0x3F800000 | 1.0 | prep:75 | osc enable |
| 6512 | 0x3F80F154 | 1.0073647 | prep:84 | DCO→VCF gain |
| 6528 | recall (curve 54) | patch | apply:221 | DCO NOISE LEVEL |
| S84400 | 0x3F800000 / 0x3FBCDAA3 | 1.0 / 1.4754223 | init:416/719 (→2870) | noise white gain |
| S84416 | 0 | 0.0 | init:2871 | noise offset |

Decimator taps (rate-independent, READ init:1021-1036):
```
s5696 0xBA254611 −6.3046912e-4   s5824 0xBC1650B1 −9.1745118e-3
s5712 0xBAEE5D05 −1.8185681e-3   s5840 0xBCF38E3B −2.9730907e-2
s5728 0xBB27E63F −2.5619415e-3   s5856 0xBD231694 −3.9816454e-2
s5744 0xBAD01376 −1.5874940e-3   s5872 0xBCB6B1F2 −2.2301648e-2
s5760 0x3B1B49D3 +2.3695126e-3   s5888 0x3CFE2E5C +3.1027965e-2
s5776 0x3C088507 +8.3324974e-3   s5904 0x3DE39F34 +1.1114350e-1
s5792 0x3C4163F1 +1.1803613e-2   s5920 0x3E451307 +1.9245540e-1
s5808 0x3BDD7D17 +6.7592966e-3   s5936 0x3E799469 +2.4373020e-1
```
Tables: `juno_pitch_table[29][26]` doubles (juno_tables.h:12) — the DCO uses
it directly inline (:1643); `juno_exp_acc0/ad3c` are ENV-side, not DCO.

---

## 4. Interactions with other subsystems

- **Note path (juno_note.c):** M.CV `s304` written immediately at note-on
  (`juno_mcv_bits` table); M.Gate `s320` immediate. The retrigger latch is armed
  at BUILD, at note-off, and on a MONO retrigger — **not** by a POLY note-on;
  full rule with cites in §2.0. `s4448` is init-owned; never write it on note
  events.
- **LFO block (:854-963):** provides `s1792` (pitch LFO) and `s1808`
  (PWM/vibrato LFO). The DCO only READS them.
- **ADSRs (:964-1075):** `s2752` (ENV1), `s3232` (ENV2) enter the pitch/PWM sums
  through the SAME-SAMPLE latched copies `s3648/s3664`. **There is NO delay on
  this path (corrected — an earlier revision of this bullet said "one-sample-
  delayed", which is false and would put a spurious z⁻¹ on the ENV→pulse-width
  path).** READ, in unconditional execution order (none of these lines sits
  inside a branch — checked): ENV1 writes its output cell at
  :1020 (`JF(a1,2752) = v143;`) and ENV2 at :1074 (`JF(a1,3232) = v165;`); the
  copies are loaded at :1084-1085 and stored at :1090-1091; and 3648/3664 are
  read by the pitch sum at :1109/:1108 and by the PWM sum at :1120/:1121 — all
  within the same sample. (§2.5 states this correctly; CELLMAP.md:292-293 calls
  them "latched ENV1/ENV2 out". The cells are SCRATCH, §1.1.) Their pitch gains
  (4064/4080/4096) are 0, so the only live route is PWM SOURCE = ENV1±/ENV2±
  (signed one-hot in 3904/3920) — which is exactly why the spurious delay would
  have been audible on every envelope transient of an ENV-PWM patch, and would
  not null at −90 dB.
- **Binary gate `s560`:** produced here, consumed by ADSRs and VCA. The DCO
  phase itself never resets — free-running (READ, no gate read in
  :1718-2136).
- **VCF:** receives `s6544` (:1298). Key-follow for the VCF is a separate mix
  (`s6976 = s880·s6960 + s752·s6944`, :1176-1179) — same 752/880 CVs.
- **Recall (juno_apply.c):** rows listed in §3. CONDITION scatter rewrites
  `s5520` per voice (`L·COND_TUNE_SCAL[v]`, apply:480) — since s5520 sits in
  the PULSE-WIDTH sum, "component tolerance" manifests as per-voice PW skew
  (and the historical label "tune trim" is misleading — see §5).
- **Driver protocol (juno_driver.c:12-21):** voices rendered 0..7 in order;
  noise block snapshot/restore per voice (equivalently: compute once, share).
  Per-voice patch coefficients are replicated to all 8 voice blocks
  (`juno_driver_seed_voices`); warm re-apply must use changed-bytes delta
  replication (CLAUDE.md WARM parity note), never a block copy over live
  smoother state.
- **Aux latch** is per voice at `101504 + 32v`; consumed and cleared here.

---

## 5. Open questions

1. **Sample-rate law of s5536 (pitch).** juno_init is strictly 2-arm: 44100
   gets 220/44100, EVERYTHING else gets 220/96000 (READ init:313-314,
   592, 910), and juno_prepare does not touch 5536. With freq = 2·inc·H this
   is pitch-true only at 44100 and 96000 (A440 would render at 220 Hz if the
   engine is driven with JF(16)=48000). The port is bit-exact against the
   plugin's own render at 44100/48000/88200 (CLAUDE.md), so this IS the
   binary's engine-level behavior; how the shipping host wrapper reconciles
   48k hosts (external resampling? engine pinned to 44.1k/96k?) is
   unresolved (#112 territory). A native implementation must reproduce the
   2-arm select, not a "corrected" 220/H.
2. **s5520 semantics.** Render math makes it the pulse-width base
   (s4816 = s5520 + s3808), yet the CONDITION applier labels it "per-voice
   detune (tune-trim)" (apply:460-480). The math wins for implementation;
   the label/derivation of COND_TUNE_SCAL deserves re-audit (INFERRED).
3. **s84416 (noise offset)** and **s84272/s84304 (noise one-pole inputs)**
   have no writers ⇒ constant 0; if any future recall path writes them the
   simplified `S84432 == f` collapses. Keep the full formula.
4. **Correction stage (§2.11) intent** (decimator IIR completion, DC?) is
   INFERRED; only the verbatim ops are proven. Its s5456 input has a
   disabled pitch dependency ((s3776−3)·0 — dead code kept by the plugin).
5. **Write-only taps** s3824, s4416, s4896/s4912 (last sub-block values) have
   no consumer inside voice_render (READ grep); whether the master or meter
   reads them was not re-checked here — keep the stores until proven dead.
6. **fmodf edge cases:** wrap() relies on C99 fmodf semantics incl. negative
   zero and exact ties at ±1.0; the sub counter compares `>= 4.0` on a float
   cell that also gets `.bits` copies — preserve int-bit copies exactly.

Verification hooks for a native rewrite: render A/B vs `tools/verify/
recall_render_ab.py` (57 patches, bit-exact requirement supersedes the
−90 dB null), `fuzz_diff.py` seeds, `test_note_path` / `test_poly_consistency`
for the latch/order protocol.

---

## Verification notes (adversarial re-derivation, 2026-07-31)

An adversarial pass re-derived every equation, cell number, constant and cite in
this doc against the sources. Nine defects were reported; **I re-checked all nine
against the source myself and all nine were real** — none were rejected, so
nothing in the report was left unapplied. What was checked and what changed:

1. **§4 ENV "one-sample-delayed" (major, FIXED).** Confirmed false by reading
   execution order: `JF(a1,2752)=v143` :1020, `JF(a1,3232)=v165` :1074, copies
   loaded :1084-1085 / stored :1090-1091, read :1108-1109 and :1120-1121 — all
   one sample, straight-line, no branch between them. §2.5 was already right;
   §4 was the outlier. Both now say the same thing.
2. **§3 row 624 + §2.3 (major, FIXED).** Confirmed `juno_prepare.c:107`'s
   `·(96000/H)` store is dead — :239 rewrites `JI(st,624)=0x3d01499d`
   unconditionally, and `juno_engine_prepare` has no statement-level control
   flow that could skip it (enumerated the whole function body: the only
   conditionals are inline `?:` rate-selects inside assignments). Cold value is
   0.031564344 at every rate; the old text was 2.177× high at 44100.
3. **§2.0 latch arming (major, FIXED).** Confirmed :255 is a comment and the
   write is :262; confirmed the two missing armers exist —
   `juno_init.c:3225` (BUILD, all 8 voices) and `juno_note.c:238`
   (`juno_note_retrig`, sole caller `gui/juno_bridge.c:596`, MONO only). Now
   documented as a three-armer mode-dependent rule, since building from the old
   text reproduces the bug CLAUDE.md records as fixed in e611f7d.
4. **Cell 896 (minor, FIXED).** Confirmed `JI(a1,896)=JI(a1,880);` at :725, and
   confirmed by grep that cell 896 has no reader in voice_render.c. Added to
   §1.1 and to §2.4's pseudocode, flagged write-only.
5. **§2.2 cv/g association (minor, FIXED).** Confirmed :657-658 are
   `(b*k − k*a) + a`, three roundings, not the two-rounding lerp the doc showed.
   Also confirmed by grep that 176/208/240/272 have zero writers in `src/` and
   `gui/`, which is what makes the discrepancy inert; that is now stated as the
   load-bearing reason rather than left implicit.
6. **§2.9 saw "different order" (minor, FIXED).** Confirmed the saw
   (:1741-1748), pulse (:1778-1786) and sub (:1807-1823) Taylor trees are
   term-for-term identical; `v409` is only a decompiler-named CSE for `x²·x`.
   The hedge is removed — one `S(x)` for all three.
7. **Cite ranges (minor, FIXED).** §2.3 → :693-735 (the `en` chain is :694/:696);
   §2.5 → stores at :1090-1091; §2.9 → per-block bodies 1718-1823 / 1826-1927 /
   1930-2031 / 2034-2133 with the re-save at :1824-1825 / :1928-1929 /
   :2032-2033 and no re-save in block 4 (its tail is the :2135-2136 handoff).
8. **§3 row 544 (minor, FIXED).** Confirmed the 44100 arm `v29 = 1018806884`
   = 0x3CB9C264 = 0.022675700 at `juno_init.c:614`, else arm 0x3C2AAA63 at :912,
   store at :918. Both arms now printed, matching every other rate-armed row.
9. **CARRIED/SCRATCH (minor, FIXED).** Added as the classification tables in
   §1.1/§1.2, derived mechanically from first-access order rather than by
   inspection. This changed three things that inspection gets wrong: `s4320` is
   SCRATCH (clobbered at :1130 before any read, despite looking like SVF
   output state); `s4640`/`s4672` are SCRATCH and carry only via the
   :2135-2136 → :1670-1671 handoff into 4864/4832; and each polyphase history
   line needs **7** persistent registers, not 8, because its oldest tap
   (5056/5184/5312/5440) is refilled before it is read.

Explicitly re-checked and found CORRECT (left unchanged): the LFSR/noise
generator and its bit-24 sign extension; the gate conditioner's sign-clamp
chain; the portamento chain including the `en==0 → out=cv` override; the pitch
and PWM sums' left-fold parenthesization at :1108-1123; the noise SVF's double
write of 4304; the 13-term double-precision pitch spline; the two genuinely
different oscillator multiply orders (saw `(win*256)*s4800*s5600` :1735 vs pulse
`(win*s4800)*256*s5616` :1768); the sub's `p >= s5584 && s5584 > p_prev` edge
test :1764; the 32-tap decimator summation order including the out-of-pattern
pairs; the correction stage; and the "no writer ⇒ 0" claims. The claim that the
DCO phase is free-running (no gate-derived cell read in :1718-2136) also holds.
