# ENV.md — Envelopes, gate conditioner, velocity gains, DCO retrigger latch

Blueprint for a native (non-transcribed) implementation of the envelope/gate
subsystem of `src/voice_render.c`. Target: null < −90 dB against the bit-exact
reference, so every equation below is written in the exact float evaluation
order of the transcription (all arithmetic is single-precision; parenthesization
in the source is load-bearing — `-ffp-contract=off`, no FMA).

**Line numbers**: all cites are the CURRENT `src/voice_render.c` (2185 lines,
pilot-2 header included). Older docs (`src/juno_note.c` header, the task brief)
cite pre-pilot-2 numbers that are ~21–34 lines lower, and the offset is NOT
uniform (the decompiler's line breaking changed too), so remap by CONTENT, never
by a fixed delta. Verified examples (READ, each opened at the target line):
`juno_note.c:45–46`'s ":636 v29==state[320]" → actual **658**, and its
":661-669 state[560] = 1.0" → actual **683–691** (683 is `v36 = v34 + 1.0`, 691
is `JF(a1,560) = v36`; 682 is the unrelated `v35 = JF(a1,608)` and 693 the
unrelated `JF(a1,720) = v40`); `juno_note.c:59–60`'s "566–572" → actual 587–594
and "2141–2149" → actual 2175–2179.

Notation: `JF(a1,N)` = float cell at per-voice offset N (`a1 = base +
voice*10512`); `JI` = same cell as int32 bits. `[N] = x` means the cell is
stored this sample. `g` below = binary gate `JF(560)`. Init constants come from
`src/juno_init.c` (two branches: `if (rate == 44100)` at :314, else-branch used
otherwise — READ); prepare constants from `src/juno_prepare.c`; recalled
coefficients from `src/juno_apply.c` BINDINGS.

---

## 1) Subsystem boundary — cells owned

Per-voice offsets (add `voice*10512`). "shadow" = a cell written from another
cell at a fixed point in the sample; a native port must WRITE all of them (other
code may read them, and state A/B compares them).

⚠ **A shadow is not automatically SCRATCH.** In the two ADSRs the shadow cells
are the *only* read path by which the previous sample's values reach the
equations: the shift chain at :975–979 copies STATE→shadow at the top of the
block, and every later read is of the shadow, not of the STATE cell. So
2608/2656/2688/2736 (and the ENV2 twins 3088/3136/3168/3216) are CARRIED —
read at :985 (2656, 2608), :1001 + :1005–1006 (2688), :1007 (2608), :1012–1013
(2736); ENV2: 3136 and 3088 at :1040, 3168 at :1056, 3088 again at :1062, 3216
at :1067–1068. READ (grepped: those are the only reads).
The shadows that really are SCRATCH for this subsystem (written, no reader
inside it) are 352, 512, 576, 2528/2544, 6880/6912, 9696/9728, 9792, 9840/9872,
9920, and the two aux outputs 2768/3248 (see §5).

### Gate conditioner (input 320 → binary gate 560)
| cell | role |
|---|---|
| 320 | M.Gate input (immediate write by note-on/off; `juno_note.c`) |
| 352 | shadow of this-sample raw gate (line 639) |
| 432 | zeroed every sample (line 631) |
| 480 | smoothed gate v29 (line 660) |
| 496 | sign classifier v34 (line 672); 512 = shadow of prev 496 (line 638) |
| 528, 560 | binary gate v36 ∈ {0,1} (lines 690–691) |
| 576 | previous sample's 560 bits (read line 686, stored 692) |
| 544 | CONST gate bias (init :918) |
| 176/208/240/272 (+shadows 192/224/256/288, product 448) | host-smoother cells for M.CV/M.Gate; port leaves 240/272 = 0 (immediate writes) so v29 == raw 320 — see §4 |

### ENV1 — "filter ENV" (default VCA source too), cells 2560–3024
STATE: 2592 (output y), 2624 (peak-detector h), 2640 (phase flag p, after
shift), 2672 (slewed target t), 2720 (smoothed rate r).
Shadows written per sample: 2608←2592, 2656←2640, 2640←2624, 2688←2672,
2736←2720 (lines 975–979), 2576 (gated input), 2704 (recomputed slew const),
2528/2544 (LFO taps, lines 965–966), outputs 2752 (normalized) and 2768
(aux copy, no reader found — see §5).
Recalled: 2784 A, 2800 S, 2816 D, 2832 R (juno_apply.c:177–189), 2560 LFO-trig
switch (juno_apply.c:666). Init consts: 2864/2880/2896/2912/2928/2944/2960/2976/
2992/3008/3024 (juno_init.c:967–977); 2848 = 1.0 (juno_prepare.c:73).

### ENV2 — "amp ENV" (VCA MODE 1), cells 3040–3504
Exact structural clone of ENV1 with offset map +480: 2560→3040, 2576→3056,
2592→3072, 2608→3088, 2624→3104, 2640→3120, 2656→3136, 2672→3152, 2688→3168,
2704→3184, 2720→3200, 2736→3216, 2752→3232, 2768→3248, 2784→3264 A, 2800→3280 S,
2816→3296 D, 2832→3312 R, 2848→3328 (=1.0, prepare:74), 2864→3344 … 3024→3504.
(READ — lines 1022–1075 mirror 967–1021 term-for-term.)

### VCF velocity chain
6864 (target, written by note-on = `juno_curve(56, vel)`, juno_note.c:196),
6880 shadow, 6896 STATE (smoothed), 6912 shadow, 6928 CONST coeff, 7248 copy of
6896 (line 1208), consumers 7440/7504/7424 (§2.5). 7424 = VCF VEL SENS recall
(juno_apply.c:681).

### VCA velocity + gate-twin + gate-mode env
9680 (target = `juno_curve(57, vel)`), 9696/9728 shadows, 9712 STATE, 9744
CONST; 9600 VCA VEL SENS recall (juno_apply.c:682) → per-sample int copy 9648
(lines 1517–1519); 9616 CONST base 0.93 (prepare:90) → copy 9664 (line 1520);
9760 blend; 9776 STATE final VCA velocity gain (9792 shadow, 9808 CONST).
9824 gate-twin (note-on 1.0, juno_note.c:201; porta-gate may zero it,
juno_note.c:306) — **but see the power-on default below**; 9840/9872 shadows,
9856 STATE smoothed twin, 9888 CONST.
9824 gate-twin — **power-on 1.0**, `juno_prepare.c:91` (`JI(st,9824)=0x3f800000`;
inside the replicated block [176,10688) so all 8 voices get it — prepare header
:49). `juno_init.c` never writes it and note-OFF never clears it; only note-on
(→1.0) and the porta-gate `off` arm (→0.0) move it afterwards. Its smoother
9856 is zeroed by `chorus_init.c:328` (9840/9872 too, :327/:329), so at power-on
9856 ramps 0→1 — see §4.
9584 VCA TONE (recalled, juno_apply.c:200 `{49, 24, T_ID, 9584}`) → per-sample
int copy 9632 (line 1518); 9632 is the tone-blend selector of the output
bright/dark pair 10480–10640 (§2.11 / §5.1). NOT part of 9552.
9904 STATE gate-mode envelope (9920 shadow, out 9936), consts 9952/9968/9984/
10000/10016/10032.
VCA source switches (recall, juno_apply.c:410–420): 10176 GATE, 10192 ENV1,
10208 ENV2. Mixer taps: 10048←JI(3232), 10064←JI(9552) (lines 1575–1576), 10224
coeff (no writer found → 0, §5).

### DCO retrigger latch (aux Array A)
`JF(base, 101504 + voice*32)` (`auxoff`, line 585; strides juno_engine.h:32–34).
Consumed head (587–594) / cleared tail (2175–2179). Array B 101520+v*32 is
DSP-inert (juno_note.c:65).

---

## 2) Per-sample equations (exact order)

### 2.1 Retrigger-latch head mask — lines 587–594
```
v2 = JF(320);  saved = 0;
if (JF(base, auxoff) == 1.0f) {         // one-shot armed
    saved = JI(320);                    // save exact BITS
    v2 = 0.0f;  JI(320) = 0;            // gate reads 0 for this sample only
}
```
Everything downstream (352, 480, 560, both ADSR inputs, 9904 gate-env, DCO
sync) sees a zero gate for exactly this sample.

### 2.2 Tail restore — lines 2175–2179
```
if (JF(base, auxoff) == 1.0f) { JI(320) = saved; JI(base, auxoff) = 0; }
```
Bit-exact restore; the latch self-clears. Net effect: one sample of gate-low
(phase-resets the DCO; delays a coincident re-attack by one sample —
juno_note.c:251–262).

**Arming — three sites, all of them required (READ, grepped: these are the only
writers of `101504+v*32` in `src/` + `gui/`):**
1. **Engine BUILD, all 8 voices** — `juno_init.c:3225`
   `JF(a1, JUNO_VOICE_AUX_BASE0 + av*JUNO_VOICE_AUX_STRIDE) = 1.0f;` inside the
   `for (av = 0..7)` loop (comment :3212–3223). This is the arm that fires on
   each voice's **very first rendered sample** — it is what produces the §2.1
   head mask and the cold DCO phase reset at power-on. A native port that starts
   the latch clear silently loses that first-sample mask on every voice.
2. **MONO retrigger** — `juno_note_retrig()` (`juno_note.c:235–239`), whose only
   caller is `gui/juno_bridge.c:596` (`mono_note_on`).
3. **Every note-off** — `juno_note.c:262`, inside `juno_note_off`.

A **POLY note-on does NOT arm it** (it writes the DSP-inert Array B
101520+v*32 instead) — `juno_note.c:166–184`, PROVEN per CLAUDE.md. That is a
statement about note-on only; it does not exempt site 1.

### 2.3 Binary gate conditioner — lines 623–693
```
v26 = JF(272)*JF(240);                  // host-ramp product; 0 in port  (651)
v29 = (JF(208)*v26 - v2*v26) + v2;      // smoothed gate; == v2 when v26==0 (658)
JF(480) = v29;                          // (660)
v31 = v29 + JF(544);                    // bias CONST 544 > 0             (662)
v32 = (v31 < 0) ? v31 : 0.0f;           // (663–666)
v34 = (v29 == 0.0f) ? -1.0f : v32;      // (668–672), JF(496)=v34
v34 = (v34 < 0) ? -1.0f : (v34 > 0 ? 1.0f : v34);   // (673–681); v32<=0 so never +1
v36 = v34 + 1.0f;                       // ∈ {0.0, 1.0}                   (683)
JF(528) = v36;  JI(576) = old JI(560);  JF(560) = v36;   // (690–692)
```
Semantics: `560 = (v29 != 0 && v29 >= -JF(544)) ? 1 : 0`. With the port's
immediate writes (320 ∈ {0, 1}, 240/272 == 0): `560 = (320 != 0)`. READ.
Also each sample: `JF(352)=v2` (639), `JI(432)=0` (631), `JI(512)=JI(496)`
(638), shadows 224←208, 192←176, 288←272, 256←240, 336←304, 448←v26.

### 2.4 ADSR core (ENV1; ENV2 identical via the +480 map) — lines 964–1021
Let `A=JF(2784), S=JF(2800), D=JF(2816), R=JF(2832)` (recalled), constants §3.

Input gating (964–974):
```
k = (JF(1824) > 0) ? 1 : 0;             // LFO pulse polarity   (967–970)
if (JF(2560) == 0.0f) k = 1;            // trig switch off → always gate (971–972)
gin = JF(560) * k;   JF(2576) = gin;    // (973–974)
```
Shift chain (975–979): `[2608]=[2592]; [2656]=[2640]; [2640]=[2624];
[2688]=[2672]; [2736]=[2720]` — int copies, order matters.

Release flag (980–984): `rel = ((gin + JF(2864)) >= 0) ? 0 : 1;  gh = 1-rel;`
(2864 = −0.5 → rel = gate-low).

Peak detector (985–988):
```
h = gh * (JF(2896)*[2656] + [2608]);    // 11.75*prev_phase + prev_output
JF(2624) = h;
v128 = h + JF(2880);                    // −8.75
v129 = h - [2640];                      // h − previous h
```
Slew const (989–991) — **write it EXACTLY as the source, no algebra**:
```
JF(2704) = ((JF(2848)*JF(2960)) - (JF(2928)*JF(2848))) + JF(2928);
```
⚠ **Do NOT simplify this to `JF(2960)` (or to the factored lerp
`JF(2928) + JF(2848)*(JF(2960)-JF(2928))`).** With 2848 == 1.0 the algebraic
value is JF(2960), but the source form is `(s − 8.75f) + 8.75f`, which is
catastrophic cancellation at exponent 2^3: ulp(8.75) = 2^-20, so the low
mantissa bits of the ~3.9e−4 slew step are destroyed. PROVEN (I recomputed both
branches in single precision from the §3 bit patterns in the source's exact
order):

| rate branch | JF(2960) | computed JF(2704) | rel. error |
|---|---|---|---|
| 44100 | `0x39ce11c1` | `0x39ce0000` | 3.37e−4 |
| else  | `0x393d5383` | `0x393d0000` | 1.72e−3 |

JF(2704) is consumed at :1006 (`v134 = v133 + JF(2704)`, the sustain up-slew),
so the substitution changes every slewing sustain sample. The factored lerp form
is likewise not float-identical (it rounds twice, the source rounds three
times — one multiply per operand).

Phase flag (992–1000):
```
p = (v128 < 0) ? 0 : 1;                 // output reached 8.75 → decay/sustain
if (v129 < 0) p = gh;                   // detector fell → re-arm attack on regate
JF(2640) = p;
```
Target + rate select (998–1009):
```
sus  = (gh*(S*JF(2928)) - JF(2944)*gh) + JF(2944);   // 8.15 + gh*(S*8.75 − 8.15)
atk  = gh * (1 - p);                                  // attack-phase flag (v135)
rsel = (JF(2816)*0.00390625f)*p + (JF(2784)*0.00390625f)*atk;   // D/256 or A/256 (v136, 1004)
if ((sus - [2688]) > 0) sus = [2688] + JF(2704);      // upward slew (1005–1006)
t = fminf(JF(2928), sus);   JF(2672) = t;             // clamp at peak 8.75 (1008–1009)
```
Rate smoothing + output (1010–1017):
```
err = (atk*JF(2912) + p*t) - [2608];                  // (v140, 1011) atk target 14.75
r   = (JF(2976)*rsel - JF(2976)*[2736]) + [2736];     // one-pole on the rate (v141)
JF(2720) = r;
rate = ((JF(2832)*0.00390625f)*rel - rel*r) + r;      // release bypasses smoothing
y = rate*err + [2608];   JF(2592) = y;                // (v142, 1015–1017)
```
(v142 source form: `(((R*0.00390625)*rel − rel*r) + r)*err + prev`.)
Release (gloss only — code the source form above): atk = p = 0 → err = −prev, so
the output decays exponentially toward 0. ⚠ The per-sample coefficient is *not*
simply `R/256`: with rel == 1 the source computes `((R*0.00390625) − r) + r`,
which in single precision differs from `R*0.00390625` whenever the smoothed rate
`r` is non-zero on that sample (same cancellation shape as the slew const above).
Keep the `rel`/`r` terms.
Outputs (1018–1021):
```
JF(2752) = (y * JF(2992)) * JF(3008);   // × 1/8.75 × 1.0 → normalized 0..1
JF(2768) = JF(2752) * JF(3024);         // × 1.0 (write-only aux)
```
ENV2 = same equations at lines 1022–1075 with the §1 offset map
(input gate switch 3040, release-rate term `v161 = (JF(3312)*0.00390625)*rel`
at 1065, outputs 3232/3248 at 1072–1075).

### 2.5 VCF velocity smoother + consumption — lines 1170–1175, 1208–1218
```
JI(6848) = JI(6832);                    // resonance shadow (NOT velocity) (1170)
JF(6880) = JF(6864);  JF(6912) = JF(6896);
JF(6896) = (JF(6864) - JF(6896))*JF(6928) + JF(6896);   // one-pole; coeff >1 @44.1k! (1175)
JI(7248) = JI(6896);                    // (1208)
cutoff CV term: ((JF(7440) + JF(7248)) * JF(7504)) * JF(7424)   // (1216–1218)
             = (smoothed_vel − 0.503937) * 8.0 * VCF_VEL_SENS
```
summed into the big cutoff CV v227 (1212–1228).

### 2.6 Envelope → VCF cutoff — lines 1180–1186, 1228
```
JI(7040) = JI(7008);                    // env-select factor (bit copy) (1180)
v210 = JF(2752) + (JF(7040)*JF(3232) - JF(7040)*JF(2752));   // lerp ENV1→ENV2 (1183–1185)
JF(7072) = (JF(7024)*JF(6640) - JF(7024)*v210) + v210;       // lerp env→"Int" 6640 (1186)
cutoff CV term: JF(7072) * JF(7392)     // VCF ENV MOD depth (1228)
```
7008/7024 have no writers (recall-inert, juno_apply.c:641–646) → defaults 0 →
ENV1 drives the filter.

### 2.7 Envelope → DCO mod taps — lines 1084–1091, 1108–1123
`JI(3648)=JI(2752); JI(3664)=JI(3232)` (1090–1091); pitch-mod sum uses
`JF(4080)*JF(3664) + JF(4064)*JF(3648)` scaled by `JF(4096)` inside `JF(3776)`
(1108–1114); PWM sum uses `JF(3904)*JF(3648)`, `JF(3920)*JF(3664)` inside
**`JF(3808)`** (1117–1123):
```
JF(3808) = (((((v186*JF(4160)) + JF(4176)) * JF(3888))
             + (JF(3904)*JF(3648)))
             + (JF(3920)*JF(3664)))
             + JF(3936)) * JF(4144);      // :1117–1123  — the real PWM MOD SUM
```
⚠ **Not 3824.** `JF(3824)` is written one line later, at :1124, from `v188`
(:1116) = `(JF(3744) + JF(3696)) + JF(3760)` — an unrelated tap with **no reader
in voice or master render**. 3808 is the cell the pulse-width path consumes
(via s4816 at :1711). Routing the ENV→PWM terms into 3824 would leave the pulse
width unmodulated and write a dead cell. Matches DCO.md:169/172 and
CELLMAP.md:306–307. READ.

### 2.8 VCA velocity gain — lines 1516–1538
```
JI(9568)=JI(9552); JI(9632)=JI(9584);
JI(9648)=JI(9600);                      // VCA VEL SENS copy (1517,1519)
JI(9664)=JI(9616);                      // base 0.93 copy (1520)
JF(9696)=JF(9680); JF(9728)=JF(9712);
v330 = (JF(9680) - JF(9712))*JF(9744) + JF(9712);  JF(9712)=v330;   // one-pole (1525–1526)
v331 = (v330*JF(9648) - JF(9648)*JF(9664)) + JF(9664);  JF(9760)=v331;
     // = 0.93 + sens*(vel − 0.93)      (1527–1529)
JF(9792)=JF(9776);
v333 = (JF(9808)*v331 - JF(9808)*JF(9776)) + JF(9776);              // (1532)
JF(9776) = fmax-like clamp: (v333 <= 0) ? 0 : v333;                 // (1533–1538)
```

### 2.9 Gate-twin smoother (9824) — lines 1539–1549
```
JF(9840)=JF(9824); JF(9872)=JF(9856);
v338 = (JF(9888)*JF(9824) - JF(9888)*JF(9856)) + JF(9856);          // (1543)
JF(9856) = (v338 <= 0) ? 0 : v338;                                  // (1544–1549)
```

### 2.10 Gate-mode VCA envelope — lines 1550–1567
```
w = JF(9904);  g = JF(560);  JF(9920) = w;
v343 = w * JF(10000);                   // w * e (2.7182817)   (1553)
v344 = w + JF(9984);                    // linear attack step  (1554)
v345 = clamp(v343, −1, 1);              // (1555–1558)
if ((w + JF(9952)) >= 0)                // w >= 0.0608108…      (1559)
    v344 = (JF(9968)*g - JF(9968)*w) + w;   // one-pole toward g (1560)
v346 = (v345*JF(10016) - JF(10032)*v345) + JF(10032);   // level-dep release coeff (1561)
v347 = (v346*g - v346*w) + w;           // release one-pole     (1563)
if (g != 0.0f) v347 = v344;             // (1564–1565)
JF(9936) = v347;  JF(9904) = v347;      // (1566–1567)
```

### 2.11 VCA CV mix + amplitude — lines 1568–1605, 1638–1640
```
X = (JF(2752)*JF(10192) + JF(10176)*JF(9936)) + JF(10208)*JF(10048);   // (1582,1586–1588)
v360 = (JF(10224)*JF(10064) - JF(10224)*X) + X;      // 10224==0 → X    (1586–1588)
v362 = v360 * JF(10304);                             // ×1.0            (1590)
v364 = (v362 <= 0) ? 0 : v362;  v367 = v364 * JF(10320);  // ×CONDITION gain (1592–1598)
JF(10080) = JF(6848) * JF(10336);                    // −0.15×resonance (1579)
v368 = (JF(10256)*v359 + v363) * (JF(10080) + 1.0f); // filter-out × res comp (1599)
v371 = ((JF(10272)*v370) + JF(10288)*v368) * v367 * JF(10400);  // (1600–1604), JF(10160)=v371
...
v384 = v383 * JF(9776);   JF(10656) = v384;          // × VCA velocity  (1638–1639)
JF(10672) = v384 * JF(9856);                         // × gate twin → voice output (1640, 2180–2182)
```

---

## 3) Constants table

All READ from the cited init/prepare lines; floats decoded from the exact bit
patterns (store the BITS, not the decimals).

| cell(s) | bits | value | meaning | source |
|---|---|---|---|---|
| 544 | 0x3cb9c264 @44100 / 0x3c2aaa63 else | 0.022675700 / 0.010416600 | gate sign bias | juno_init.c:614/912,918 |
| 2864, 3344 | 0xbf000000 | −0.5 | release threshold on gated input | init:967/978 |
| 2880, 3360 | 0xc10c0000 | −8.75 | attack-peak threshold | init:968/979 |
| 2896, 3376 | 0x413c0000 | 11.75 | peak-detector hold drive | init:969/980 |
| 2912, 3392 | 0x416c0000 | 14.75 | attack target (overshoot) | init:970/981 |
| 2928, 3408 | 0x410c0000 | 8.75 | envelope peak / sustain scale | init:971/982 |
| 2944, 3424 | 0x41026666 | 8.1499996 | sustain base | init:972/983 |
| 2960, 3440 | 0x39ce11c1 @44100 / 0x393d5383 else | 3.9304610e−4 / 1.8055555e−4 | sustain slew-step INPUT — ⚠ **not** equal to the computed JF(2704)/JF(2184); see §2.4 | init:973/984 |
| 2976, 3456 | 0x3e9166f5 @44100 / 0x3e05f213 else | 0.28398862 / 0.13080625 | rate-coefficient smoother | init:974/985 |
| 2992, 3472 | 0x3dea0ea1 | 0.11428571 (=1/8.75) | output normalizer | init:975/986 |
| 3008/3024, 3488/3504 | 0x3f800000 | 1.0 | output gains | init:976–977/987–988 |
| 2848, 3328 | 0x3f800000 | 1.0 | slew-lerp selector | juno_prepare.c:73–74 |
| A/S/D/R 2784/2800/2816/2832 (ENV2 3264/3280/3296/3312) | per patch | juno_curve(35, b40)/(50, b42)/(38, b41)/(38, b43); ENV2 blob 45/47/46/48 | recalled; attack arms 33/34/35, decay/release 36/37/38 per rate | juno_apply.c:177–191,235–236 |
| 2560, 3040 | — | LFO TRIG ENV switch (0/1) | juno_apply.c:664–668 |
| 6928, 9744 | 0x3fa754b5 @44100 / 0x3f2493b7 else | 1.3072726 / 0.64287895 | velocity smoother coeff (>1 @44.1k: damped-oscillatory, deliberate) | init:438/743,1068,1141 |
| 9808, 9888 | 0x3bf7adf5 @44100 / 0x3b638e39 else | 7.5585791e−3 / 3.4722222e−3 | VCA vel + gate-twin smoother | init:431/736,1142–1143 |
| 7440 | 0xbf010204 | −0.50393701 | VCF velocity center offset | prepare:86 |
| 7504 | 0x41000000 | 8.0 | VCF velocity scale | init:1078 |
| 7424 / 9600 | byte/255 | VCF / VCA VEL SENS | juno_apply.c:681–682 |
| 9616 | 0x3f6e147a | 0.92999995 | VCA velocity base gain | prepare:90 |
| 9952 | 0xbd7914c2 | −0.060810812 | gate-env attack-mode threshold | init:1144 |
| 9968 | 0x3c96c6dc @44100 / 0x3c0a8719 else | 0.018405370 / 0.0084550614 | gate-env attack one-pole | init:587→1145 |
| 9984 | 0x3d005da8 @44100 / 0x3c6bdf4b else | 0.031339318 / 0.014396499 | gate-env linear attack step | init:586→1146 |
| 10000 | 0x402df854 | 2.7182817 (e) | release-coeff level scale | init:1147 |
| 10016 | 0x3c0cba00 @44100 / 0x3b814af8 else | 0.0085892677 / 0.0039457045 | gate-env release coeff (high level) | init:585→1148 |
| 10032 | 0x3cdfccc2 @44100 / 0x3c4d9f03 else | 0.027319316 / 0.012550118 | gate-env release coeff (low level) | init:584→1149 |
| 10176/10192/10208 | 0/1 | VCA MODE switches (GATE/ENV1/ENV2) | juno_apply.c:410–420 |
| 10304 | 0x3f800000 | 1.0 | | prepare:93 |
| 10336 | 0xbe19999a | −0.15 | resonance level compensation | init:1150 |
| 10400 | 0x3cbc6a7f | 0.023 | output scale | init:1154 |
| 6864 / 9680 | per note | juno_curve(56/57, velocity) | juno_note.c:196–197 |
| 101504+v·32 | 1.0 arm / 0 clear | DCO retrig latch Array A | juno_engine.h:33–34 |

"else" branch = init's non-44100 set (juno_init.c:314). Scaling ratio ≈
96000/44100 (INFERRED it is the 96 k-family set; a native port must read the
values from the initialized state or replicate both branches, not re-derive).

---

## 4) Interactions with other subsystems

- **LFO**: ENV input gating reads the LFO pulse `JF(1824)` (written line 929)
  when the trig switch 2560/3040 is set (§2.4); lines 965–966 also export
  `[2528]=JI(1824)`, `[2544]=JI(1808)` for the LFO section. The ENV outputs'
  copies 3648/3664 feed DCO pitch/PWM mod (§2.7); 7040/7072 feed VCF (§2.6).
- **Gate conditioner ↔ host smoothers**: v29 uses `v26 = JF(272)*JF(240)`
  (line 651) — the en=1 ramp machinery. Port writes M.Gate immediately so
  240/272 stay 0 and `560 == (320 != 0)` exactly (juno_note.c:43–53). A native
  port must keep the full formula if host-style ramped gates are ever driven.
- **Glide conditioner**: gate 560 gates portamento via
  `v45 = ((v36*JF(608) − JF(608)) + 1.0)*JF(592)` (lines 694–696): 608 =
  PORTAMENTO MODE (legato-only glide, juno_apply.c:648–654), 592 = per-voice
  porta gate (juno_note.c:277–307).
- **6832/6848 is RESONANCE, not velocity**: shadow at line 1170; feeds the
  cutoff correction (v229, lines 1231, 1242–1243) and VCA level comp
  (`JF(10080)`, line 1579). Do not confuse with 6864.
- **expf cutoff segment (lines 1235–1297)**: the `expf` at 1261 and the
  rational polynomial 1275–1291 are the VCF cutoff→coefficient mapper (gated by
  `JF(7632)==1.0`), NOT an envelope; the envelopes only enter it through the CV
  v227 terms of §2.5/§2.6. The only other envelope-adjacent `expf` is line 798
  (LFO-delay shaper, coeffs 1184/1200/1216).
- **Retrig latch arming** is owned by juno_note.c / the bridge (MONO retrigger
  + every note-off); voice_render only CONSUMES (§2.1–2.2). Array B
  (101520+v·32) is written by POLY note-on and read by nothing.
- **VCA MODE=2 (GATE)** makes 9936 the sole amp CV — organ-style, no ADSR
  (juno_apply.c:403–409); modes 0/1 select ENV1/ENV2 normalized outputs.
- **Voice output** `JF(10672)` (lines 1640, 2180–2182) is the product of the
  filter/amp path with BOTH the VCA velocity gain 9776 and the smoothed gate
  twin 9856 — a voice with 9824 never set renders silent.

## 5) Open questions

1. **Cell 9552** (→ copies 9568/9632/10064; used at lines 1614, 1623–1636 and
   in the v360 mix) has no writer anywhere in src/ — 0 from calloc. INFERRED
   inert (its coefficient 10224 also has no writer → 0). Confirm against the
   binary before hard-coding the simplification `v360 = X`, `v383 = v375`.
2. **2768/3248** are written (lines 1021/1075) but never read by voice or
   master render (grep). Keep the stores for state A/B equality; confirm no
   cross-unit reader under emulation.
3. **JF(2704)** is recomputed per sample as a lerp that collapses to JF(2960)
   only because 2848==1.0 (prepare). If any path ever writes 2848≠1, the slew
   changes — a native port should keep the three-term expression.
4. **>1 smoother coefficient** (6928/9744 = 1.3072726 @44.1k) overshoots on
   velocity changes; bit-exactness requires the exact single-precision order
   `(target − state)*coef + state`.
5. **init "else" branch coverage**: proven bit-exact at 48000/88200/96000/
   192000 per CLAUDE.md cold-state gate, i.e. the plugin itself uses one
   non-44100 constant set; do not "fix" the apparent time-constant mismatch.
6. **Gate magnitudes**: conditioner tolerates any positive gate (bias 544);
   port always writes 1.0. If host ramps are ever implemented, v29 becomes
   fractional during transitions and 560 can differ from (320 != 0) only for
   negative gates > −JF(544) — unreachable in the current port. INFERRED.
