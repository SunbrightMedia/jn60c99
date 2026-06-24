# JUNO-60 System-8 Delay / Multi-FX DSP — faithful transcription

Middle tier of the template stack `CPrmDSPRev< CPrmDSPSystem8Dly< CPrmDSPJu60 > >`:
the **`CPrmDSPSystem8Dly`** "System-8 delay" multi-FX. This documents the
**delay / chorus / flanger** portion only. The reverb that follows it is in
`docs/REVERB_DSP.md` (do not redo). The mod-FX `v538` block is also out of scope.

Per-sample DSP: `sub_7FF91DFC3380` @ rva `0x363380`
(`float* (a1=engine/state, a2=in**, a3=out**)`) in `allcode/decomp_340000.c`.
The delay/FX is the **`v39` switch** at lines **25646–26838**, running *before* the
reverb and producing the reverb-input pair `v169`(R) / `v170`(L) at `LABEL_105` (25839).

Container ctor: `sub_7FF91DFC31A0` / `sub_7FF91DFC3010` in `allcode/decomp_380000.c`
(~line 20065). Image base `0x7FF91DC60000`.

---

## 1. Sub-effect inventory

The container ctor constructs 6 sub-effect objects, each embedded at an offset and each
handed the shared engine `a4`. The ctors are **thin config objects**: they store integer
config (buffer size, mode, max length, sample-rate divisor) and, at param-update time, call
the engine's *define-tap* / *set-coefficient* helpers. They do **not** store `.rdata` table
pointers (unlike the reverb ctor `sub_7FF91E021110`, which stored `&unk_…63A350` etc.).
Their delay lengths/coeffs are computed at runtime via the knob→value LUT dispatcher
`sub_7FF91DFB6380` (see §2).

| Obj offset | Class | Ctor | Setup/param fns | Role |
|---|---|---|---|---|
| `+6784` | `sCDSPSystem8DlyDly`  | `sub_7FF91DFBFAB0` @0x35FAB0 | `sub_7FF91DFBFB60`/`…FBF0` (time), `…FCF0`–`…0590` (taps/coeffs), apply `sub_7FF91DFC0790` | **Delay line** (stereo delay w/ glide + damping + feedback) |
| `+6976` | `sCDSPSystem8DlyPan`   | `sub_7FF91DFC2450` @0x362450 | `sub_7FF91DFC2500`/`…2590` (time) | **Pan / auto-pan / ping output stage** (same skeleton as Dly) |
| `+7184` | `sCDSPSystem8DlyCh`    | `sub_7FF91DFBDA40` @0x35DA40 | `…DB00`,`…DC00`,`…DC70`,`…DE50` (rate/depth/taps) | **Chorus** #1 |
| `+7400` | `sCDSPSystem8DlyCh`    | `sub_7FF91DFBDA40` @0x35DA40 | (same vtable) | **Chorus** #2 |
| `+7616` | `sCDSPSystem8DlyFlSt`  | `sub_7FF91DFBEAD0` @0x35EAD0 | `…EB90`,`…EC10`,`…EC90`,`…ED00`,`…E6B0` (`255−x` feedback) | **Flanger / stereo (ChSt)** |
| `+7824` | `sCDSPSystem8DlyMfx1`  | `sub_7FF91DFC0830` @0x360830 | `…0920`… (curve-22 times) | **Mod-FX 1** (combined delay+chorus cascade) |

Ctor config constants (delay `sub_7FF91DFBFAB0`): `[+56]=128` (buffer/quantum),
`[+64]=2` (mode/voices), `[+68]=4778` (**max delay in samples**), `[+72]=120`
(time divisor → `2400000/120 = 20000` scale), `[+76]=96000` (design SR).
Chorus/flanger ctors carry `[+52]=2, [+56]=40, [+60..72]=128, [+76]=120, [+80]=96000`.
The mfx ctor carries both a delay block (`[+68]=4778`) and a chorus block (`[+108..136]`),
consistent with it being a **delay→chorus cascade**.

### Engine helper semantics
- `sub_7FF91E021090(eng, node, coef)` / `sub_7FF91E0210F0` → **set coefficient** on engine
  node `node`: `**(eng->[56] + 40*node + 32) = coef`.
- `sub_7FF91E0210D0(eng, …, node, len, 0)` → `sub_7FF91E022920` = **define tap length** `len`.
- `sub_7FF91DFB6380(LUT, curve, knob)` → knob→normalized value via `dword_7FF91E5C…[]` arrays.
  *(The first arg `&unk_7FF91E910DC8` is ignored; the curve index selects the array.)*

---

## 2. Recovered constant tables (knob→value LUTs)

These are the source constants for all delay/chorus/flanger **times, depths, rates and
feedback**. Each is an int32 array that is actually **float32 bit-patterns**, indexed by a
clamped param value. Decoded values saved to `refs/delay_tables.json`.

| Curve | RVA | Runtime addr | N | Decoded meaning (float) |
|---|---|---|---|---|
| 19 | `0x96C8E0` | `0x7FF91E5CC8E0` | 256 | feedback amount, 0.0→1.0 exponential. Flanger reads it as `[255−knob]` (inverse). |
| 22 | `0x96D2E0` | `0x7FF91E5CD2E0` | 256 | **generic time/rate scale**, ≈ `knob/255` (linear 0→1). Most-used (delay, chorus pre-delay, mfx). |
| 58 | `0x986D68` | `0x7FF91E5E6D68` | 14 | musical ladder `0.0412…0.795` (= curves 61/64; rate/time steps). |
| 59 | `0x987900` | `0x7FF91E5E7900` | 82 | **monotone 1.0→0.0** decay curve (feedback / HF-damping vs index). |
| 60 | `0x987A48` | `0x7FF91E5E7A48` | 11 | short-time set `0.0052…0.0524`. |
| 61 | `0x9874C8` | `0x7FF91E5E74C8` | 14 | identical to 58 (delay set B). |
| 63 | `0x987AB0` | `0x7FF91E5E7AB0` | 256 | **17-plateau stepped attenuation** 1.0…0.03125 (coarse level/mix steps). |
| 64 | `0x987EB0` | `0x7FF91E5E7EB0` | 14 | identical to 58 (chorus rate/depth). |
| 65 | `0x987EF0` | `0x7FF91E5E7EF0` | 17 | flanger rate ladder `0.00131…0.0524`. |

Representative decodes:
- **22** (first/last): `0, 0.00392, 0.00784, … 1.0` — exact `n/255`.
- **58/61/64**: `0.04123, 0.05235, 0.06544, 0.08179, 0.10467, 0.13081, 0.16344, 0.20580,
  0.26105, 0.32579, 0.40942, 0.51764, 0.64288, 0.79550` — a ~+2.0 dB/step (×1.25…) ladder.
  (exact values per `refs/delay_tables.json`)
- **59**: `1.0, 0.94406, 0.89125, 0.84140, … 0.0` (82 pts, monotone — a damping/feedback map).
- **63**: 17 plateaus of 15–17 entries each: `1.0×17, 0.84140×17, 0.74989×17, 0.5×17,
  0.30000×17, 0.26162×17, 0.1875×17, … 0.03125` (coarse stepped gain).
- **65**: `0.00131, 0.00164, 0.00206, 0.00262, … 0.05235` (rate ladder).

The delay-length conversion in the ctors is:
`len_samples = (2400000.0 / divisor) * curveValue`, then halved repeatedly until it fits the
allocated line (`while (len > maxLen) len *= 0.5`) — e.g. `sub_7FF91DFBFBF0` line 23061,
`sub_7FF91DFBDC70` line 22026. With `divisor=120`, `2400000/120 = 20000` samples full-scale.

There are **no `.rdata` delay-length tables** for this section (the reverb's
`0x63A350`/`0x639F20` are reverb-only). This is the key structural difference from the reverb.

---

## 3. Mode selector and overall data flow

```
a2 (4 voice stereo pairs) ──▶ input mix (25587–25645) ──▶ v36 (R pre-FX), v38 (L pre-FX)
                                                              │
            v39 = **(*(a1+136)+136)   selects FX mode         ▼
            ┌─────────────────────────────────────────────────────────────┐
            │  v39 switch  (delay / chorus / flanger / cascade)            │
            │  every case writes v169 (R-in) , v170 (L-in)                 │
            └───────────────────────────────┬─────────────────────────────┘
                                             ▼  LABEL_105 (25839)
                                   PLATE REVERB (REVERB_DSP.md) ──▶ out
```

Input mix (25587–25629): the 4 voice pairs at `a2[0/2]`, `[4/6]`, `[8/10]`, `[12/14]` are
each summed L+R and scaled by per-pair gains `*(a1+84448/84464/84480)`; a feedback/aux path
(`84512…84880`, `101072…101120`) forms `v36` (=`v34*v35`, 25640) and `v38` (=`v34*v37`,
25644) — the stereo pre-FX signal fed to whichever mode is active. (`v36`≈R, `v38`≈L.)

### `v39` → mode map (verified by branch structure)

| v39 | Lines | State zone | Effect | LFO | Feedback |
|---|---|---|---|---|---|
| `1` | 25647–25808 | `4297xxx` / `6395264…6395304` ring `4298096` | **Stereo Delay** (glide + damping) | none (glided time) | yes |
| `0` (default) | 25813–26027 (`LABEL_69`) | `101xxx`/`102xxx`, rings `102800`,`2199968` | **Stereo Chorus** | inline triangle | no |
| `2,3` | 26031–26210 | `6395xxx`/`6396xxx`, ring `6396640` | **Chorus** (curve-LFO) | `sub_7FF91DFC8DC0/8FC0` | (mix/AP only) |
| `4` | 26631–26836 | `6429xxx`/`6430xxx`, rings `6430944`,`6463728` | **Flanger / 2nd Chorus** | `sub_7FF91DFC8DC0/8FC0` | yes (`19[255−x]`) |
| `5` | 26216–26627 | `6496/6497xxx` + `10692/10693/10726xxx` | **Delay → Chorus cascade** (mfx) | inline tri + curve | yes (stage 1) |
| else | → `LABEL_69` | — | falls through to chorus (v39==0) | — | — |

`*(a1+11022348)` is the **active-mode latch**: each case writes its own id (1,0,2,5,4) and,
on a mode change, zeroes its envelope/feedback accumulators (e.g. 25651–25653). This is the
glitch-free mode-switch reset.

---

## 4. Common per-sample primitives

All cases share these idioms (named here, used throughout the pseudocode):

**Fractional (interpolated) delay read.** A tap time `t` (samples) is split:
```
ti  = (int)(t * -16384.0)                 # integer sample offset (note negative scale)
tf  = t*16384.0 - (int)(t*16384.0)        # fractional in [0,1)   (stored to state)
s0  = BUF[(wr - ti + 1) & (size-1)]       # two adjacent ring samples
s1  = BUF[(wr - ti + 2) & (size-1)]
y   = (tf*s1 - tf*s0) + s0                # = lerp(s0, s1, tf)
```
The `16384` factor is a sub-sample fixed-point scale (14-bit). `wr` is the per-ring write
index; `size-1` is the ring mask (held one slot above the index in state).

**Ring write (end of each case).** `wr = (wr - 1) & (size-1); BUF[wr] = processed_input;`

**Triangle LFO (inline, cases v39 1/0/5-stage1/4-stage1).** A phase accumulator
`ph += rate*v5` (v5 = a tempo/SR scale); slope sign chosen by `ph` zero-cross to pick a
`+step`/`−step`; slew-limited by a `fabs(Δ)*coef` clamp; wrapped/clamped to `[-1,1]`; then
×depth. (e.g. 25915–25948 for v39==0.)

**Curve LFO (cases v39 2/3 and 4 and stage-2 of 5).**
`sub_7FF91DFC8DC0(x)` = degree-13 polynomial curve eval over a 26-coef row table
`unk_7FF91E5E94E0` (row = `int(x+20)`, x∈[-20,8.9]) — a non-linear LFO/saturation shaper.
`sub_7FF91DFC8FC0(ph)` = **bipolar triangle** from phase ph∈wrapped[-1,1]:
`|ph|≤0.5 → 2·ph`, `ph>0.5 → 2−2·ph`, `ph<−0.5 → −2−2·ph`.
`sub_7FF91DFC8F30/F90(x)` = phase wrap to [-1,1].

**Damping / one-pole filters.** Each tap output passes a small cascade
`s += (x−s)*c1; out = a*s + b*s_prev` (the `102608/624/640/656…` coef groups), the same
HF-damping structure as the reverb tank, used here for the chorus/flanger tone control.

**Wet/dry mix.** Final per-case: `out = mix*(allpass(wet)) + (1−mix)*dry + wet*send`,
where `dry` is the stored pre-FX (`v36`/`v38` mirrors at `101760/101776`, `6395728/744`, …)
and `send`/`mix` come from curve-63/22 derived coefficients. Output is then `×*(a1+101744)`
(the global delay-section output gain) → `v169`/`v170`.

---

## 5. Per-case transcription (pseudocode)

`BUFn[i] = *(a1 + 4*i + base_n)`. `IN_R=v36`, `IN_L=v38`. `outGain = state[101744]`.

### v39 == 1 — Stereo Delay (lines 25647–25808)
State `4297xxx`; ring base `4298096` (mask `6395248`/idx `6395252` region). No LFO; the delay
*time* is **glided** (slew-limited) so pitch artifacts on time changes are smoothed.
```
# delay-time glide (25700–25719): target time → slew toward it (v416 Δ, v418 = |Δ|*coef)
t  = glide(target = state[4297584] ...)                 # v420, slewed samples
t  = max(t, 0.0001220703125)                            # min 1/8192 sample (25733)
# two interpolated reads from BUF@4298096 at slightly offset times (25737–25758)
yR = lerp_read(BUF4298096, wr=6395248, t*coefR)         # v433-ish
yL = lerp_read(BUF4298096, wr=6395248, t*coefL)
# damping one-pole + feedback recirculation (25762–25800):
#   wet = AP/one-pole(y); fb = wet*fbCoef  re-injected into the write
dryR=IN_R ; dryL=IN_L
state[4297552] = mix*AP(wetL) + (1-mix)*dryL + wetL*send      # L wet (25794)
state[4297568] = mix*AP(wetR) + (1-mix)*dryR + wetR*send      # R wet (25800)
wr = (wr-1) & mask ; BUF4298096[wr] = feedback_input         # (25802-25804)
v169 = outGain * state[4297568]    # R   (25806)
v170 = outGain * state[4297552]    # L   (25807)
```
Confidence: **High** on topology (stereo delay + glide + damping + feedback, single ring),
Medium on the precise feedback-vs-mix coefficient split (dense, 25762–25800).

### v39 == 0 — Stereo Chorus (default, lines 25813–26027)
Two rings `BUF_A@102800` (idx `2199952`, mask `2199956`) and `BUF_B@2199968`
(idx `4297120`, mask `4297124`); one modulated tap per channel; **no feedback**.
```
# inline triangle LFO: phase state[102288] += rate state[102720] ; depth state[102592]
lfo = tri_slew(phase += rate*v5)                         # 25915–25948 → v364
tap = base_delay + lfo*depth                             # v361 (modulated samples)
ti  = (int)(tap*-16384) ; tf = frac(tap*16384)           # 25949,25955
yR  = lerp(BUF_A[wrA-ti+1], BUF_A[wrA-ti+2], tf) * state[102304]   # v372 (25970)
yL  = lerp(BUF_B[wrB-ti+1], BUF_B[wrB-ti+2], tf) * state[102304]   # v389 (25993)
yR  = damp_cascade(yR, coefs 102608/624/640/656/672/688/704)      # 25974–25990
yL  = damp_cascade(yL, …)
dryR=state[101760]=IN_R ; dryL=v38_stored
outR_pre = mix*(state[102512]*dryR)+(1-mix)*dryR + yR*send(102528) # v401 (26011)
outL_pre = mix*(state[102512]*dryL)+(1-mix)*dryL + yL*send         # v402 (26014)
state[102320]=outR_pre ; state[102336]=outL_pre
wrA=(wrA-1)&maskA ; BUF_A[wrA]=state[4297136]            # dry write (26020)
wrB=(wrB-1)&maskB ; BUF_B[wrB]=state[4297168]            # (26023)
v169 = outGain * state[102336]    # R   (26025)
v170 = outGain * state[102320]    # L   (26026)
```
Confidence: **High** (read line-by-line). Two-voice chorus, modulated reads of a dry-written
ring, wet/dry blend, no regeneration.

### v39 == 2,3 — Chorus, curve-shaped LFO (lines 26031–26210)
Ring `BUF@6396640` (idx `6429408`, mask `6429412`). LFO via `sub_7FF91DFC8DC0` (clamped ±512,
26041–26043) and quadratic shaping (26086–26090). Two interpolated taps (R/L) into the one
ring (26152–26176). Damping cascade `6396320…6396512`; wet/dry `6396432`/`6396496`.
```
lfoRaw = clamp(sub_7FF91DFC8DC0(), ±512)                 # 26041
phase  = wrap(state[6395600] + lfoRaw*rate[6395648])     # 26044–26064 (mod 2)
depthR = quad_shape(phase, …)                            # v252/v255 (26086,26092)
depthL = quad_shape(1-phase, …)                          # v253 (26087)
yR = lerp_read(BUF6396640, wr, base+depthR)              # 26152→v289 (26178)
yL = lerp_read(BUF6396640, wr, base+depthL)              # 26166→v296 (26187)
… damp + wet/dry (26190–26204) …
wr=(wr-1)&mask ; BUF6396640[wr]=state[6429424]           # 26205-26207
v169 = outGain * state[6396112]   # R   (26209)
v170 = outGain * state[6396096]   # L   (26210)
```
Confidence: **High** on structure (single-ring stereo chorus, curve LFO), Medium on the exact
quadratic depth-shaping algebra (26086–26096).

### v39 == 4 — Flanger / 2nd Chorus (lines 26631–26836)
Two rings `BUF1@6430944` (idx `6463712`/mask `6463716`) and `BUF2@6463728`
(idx `6496496`/mask `6496500`). LFO via `sub_7FF91DFC8DC0/8F90/8FC0`. **Feedback present**
(`v207` adds `state[6430912]`/`[6430928]` regeneration, 26756–26759). Setup function
`sub_7FF91DFBE6B0` reads feedback from curve **19 indexed by `255−knob`** (flanger
inverse-feedback), the flanger signature. Quadratic LFO shaping `v179`/`v180` (26679–26688).
```
lfoRaw = clamp(sub_7FF91DFC8DC0(), ±512)                 # 26641-26642
ph2    = sub_7FF91DFC8FC0(sub_7FF91DFC8F90(phase))       # triangle (26645-26648)
depthR = ph2_shaped + quad(ph2,…)  ; depthL = ...        # v179,v180 (26679-26688)
fb     = (prevTap >= 0) ? +state[6430912] : +state[6430928]   # regeneration (26756)
yR = lerp_read(BUF1@6430944, wr1, base+depthR)           # 26780→v224 (26806)
yL = lerp_read(BUF2@6463728, wr2, base+depthL)           # 26794→v228 (26812)
… damp + wet/dry (26815–26827) …
wr1=(wr1-1)&mask1 ; BUF1[wr1]=state[6496512]             # 26828-26830
wr2=(wr2-1)&mask2 ; BUF2[wr2]=state[6496544]             # 26831-26833
v169 = outGain * state[6430448]   # R   (26835)
v170 = outGain * state[6430432]   # L   (26836)
```
Confidence: **High** that this is the flanger/stereo (feedback + inverse-FB table + dual
ring), Medium on whether the two rings are true stereo decorrelation vs L/R cross-feed (reads
stay per-channel; the regeneration is what makes it a flanger).

### v39 == 5 — Delay → Chorus cascade (mfx, lines 26216–26627)
**Two cascaded stages**, each stereo, 4 rings total, per-channel straight-through (R→R, L→L)
— a **cascade, not ping-pong** (no cross-channel buffer writes).

Stage 1 = modulated stereo **delay** with feedback; inline triangle LFO (rate `6497536`,
depth `6497408`, slew `6497600`). Rings `6497616` (R, idx `8594768`/mask `8594772`),
`8594784` (L, idx `10691936`/mask `10691940`). Feedback coef `6497520`. Outputs to
`state[6497136]`(R)/`[6497152]`(L).

Stage 2 = stereo **chorus** fed by stage-1 outputs; curve LFO via
`sub_7FF91DFC8DC0/8F90/8FC0` with per-channel phase accumulators (`10692864`/`10692880`,
rate `10693424`). Quadratic depth shaping (`10693024`/`10693056` curve). Rings `10693488`
(R, idx `10726256`/mask `10726260`), `10726272` (L, idx `10759040`/mask `10759044`).
```
# STAGE 1 (delay)
lfo1 = tri_slew(phase[6497104] += rate[6497536]*v5)      # 26304-26337
yR1 = lerp_read(BUF@6497616, wrR1, base+lfo1) * send[6497120]      # 26338→v64 (26363)
yL1 = lerp_read(BUF@8594784, wrL1, base+lfo1) * send               # 26351→v79 (26384)
… damp + feedback via 6497520 (26369-26404) …
state[6497136]=stage1_R ; state[6497152]=stage1_L        # (26407-26411)
wrR1=(wrR1-1)&maskR1 ; BUF6497616[wrR1]=state[10691952]  # 26415-26417
wrL1=(wrL1-1)&maskL1 ; BUF8594784[wrL1]=state[10691984]  # 26418-26420
# STAGE 2 (chorus) input = stage1 outputs
lfo2 = clamp(sub_7FF91DFC8DC0(),±512) ; tri=sub_7FF91DFC8FC0(...)  # 26424-26432
depthR=quad(phaseR[10692864]) ; depthL=quad(phaseL[10692880])     # 26460-26477
yR2 = lerp_read(BUF@10693488, wrR2, baseR+depthR)        # 26566→v154 (26596)
yL2 = lerp_read(BUF@10726272, wrL2, baseL+depthL)        # 26583→v158 (26602)
… damp + wet/dry (26605-26617) …
wrR2=(wrR2-1)&maskR2 ; BUF10693488[wrR2]=state[10759056] # 26618-26620
wrL2=(wrL2-1)&maskL2 ; BUF10726272[wrL2]=state[10759088] # 26621-26623
v169 = outGain * state[10692992]  # R   (26625)
v170 = outGain * state[10692976]  # L   (26626)
```
Confidence: **High** that it is a delay→chorus cascade (4 rings, 2 stages, per-channel
straight-through verified). Medium on the stage-1 feedback-vs-mix split and the exact
stage-2 curve-depth algebra.

---

## 6. State-offset map (delay/FX zones)

Byte offsets from `a1`. `f`=float32, `i`=int32 ring index/mask.

| Offset | Type | Meaning |
|---|---|---|
| `+136` → `[+136]` | ptr | host param block; `**(*(a1+136)+136)` = `v39` **mode selector** |
| `101744` | f | **global delay-section output gain** (all cases × this → v169/v170) |
| `11022348` | i | **active-mode latch** (1/0/2/5/4); mode-change reset trigger |
| **v39==1 (delay)** | | |
| `4297xxx` (4297136…4297712) | f | glide/damping/mix coeffs, dry mirrors, wet results `4297552`(L)/`4297568`(R) |
| `4298096` | f[] | delay ring buffer (mask/idx in `6395248`/`6395252`) |
| `6395264…6395304` | f | interpolation scratch (lerp s0/s1/frac) |
| **v39==0 (chorus)** | | |
| `101760/101776` | f | dry mirrors (IN_R/IN_L) |
| `102288` | f | LFO phase; `102720` rate; `102592` depth; `102752/102768` slope steps; `102784` slew |
| `102304` | f | tap gain; `102512`/`102528` dry/send; `102576` wet/dry mix |
| `102608…102704` | f | damping one-pole coefs |
| `102320/102336` | f | output L/R (→ v170/v169) |
| `102800` | f[] | ring A (idx `2199952`, mask `2199956`) |
| `2199968` | f[] | ring B (idx `4297120`, mask `4297124`) |
| **v39==2,3 (chorus)** | | |
| `6395600` | f | LFO phase; `6395648` rate; `6395696/6395712` shaping |
| `6396320…6396512` | f | damping/mix coefs; `6396432`/`6396496` wet/dry |
| `6396096/6396112` | f | output L/R |
| `6396640` | f[] | ring (idx `6429408`, mask `6429412`) |
| **v39==4 (flanger)** | | |
| `6429760` | f | LFO phase; `6429856/6429872` shaping; depth from quad |
| `6430624…6430784` | f | damping/mix; `6430912`/`6430928` **feedback** regeneration |
| `6430432/6430448` | f | output L/R |
| `6430944` | f[] | ring 1 (idx `6463712`, mask `6463716`) |
| `6463728` | f[] | ring 2 (idx `6496496`, mask `6496500`) |
| **v39==5 (cascade)** | | |
| `6497104` | f | stage-1 LFO phase; `6497536` rate; `6497408` depth; `6497600` slew |
| `6497424…6497520` | f | stage-1 damping; `6497520` **feedback** |
| `6497136/6497152` | f | stage-1 outputs (= stage-2 inputs) |
| `6497616` / `8594784` | f[] | stage-1 rings R/L (idx `8594768`/`10691936`) |
| `10692864/10692880` | f | stage-2 per-ch LFO phases; `10693424` rate |
| `10693024/10693056` | f | stage-2 curve depth/scale; `10693200…10693408` damping/mix |
| `10692976/10692992` | f | output L/R |
| `10693488` / `10726272` | f[] | stage-2 rings R/L (idx `10726256`/`10759040`) |

---

## 7. Topology summary

- **One engine, six embedded sub-effects**, but the per-sample path picks **one mode** per
  call via `v39`. The sub-effect *objects* (Dly/Pan/2×Ch/FlSt/Mfx1) are the parameter/setup
  front-ends; the actual per-sample math is the unrolled `v39` switch.
- **All delay lines are power-of-2 ring buffers** with a decrementing write index and a
  `& (size-1)` mask, read by **14-bit fractional linear interpolation** (the `±16384`
  fixed-point taps). This is uniform across every mode.
- **Modes:** plain stereo delay (glide + damping + feedback, no LFO); a default 2-voice
  chorus (inline triangle LFO, no feedback); a curve-LFO chorus; a flanger (curve LFO +
  inverse-feedback from curve 19); and a delay→chorus **cascade** (the Mfx1, 2 stages × 2
  rings, per-channel, definitively not ping-pong).
- **Constants** come from runtime knob→value LUTs (curves 19/22/58–65), not from a static
  delay-length `.rdata` table — the opposite of the reverb tier. Times are
  `(2400000/divisor)*curveValue`, octave-folded to fit each line; `maxLen=4778` samples for
  the delay/mfx lines.
- Every mode ends by writing `v169`(R)/`v170`(L) = `outGain * outputReg`, which `LABEL_105`
  hands to the reverb (REVERB_DSP.md). When the reverb is bypassed it passes these straight
  through.

### Confidence per component
| Component | Confidence | Notes |
|---|---|---|
| Sub-effect inventory & offsets | High | from ctor at decomp_380000.c:20065 |
| Knob→value LUT tables (curves) | High | bytes dumped & float-decoded; saved to JSON |
| Ring-buffer / fractional-tap primitive | High | identical pattern verified in all 5 cases |
| v39 mode map | High | branch structure read line-by-line |
| v39==0 chorus | High | full line-by-line |
| v39==1 delay | High (topology) / Medium (fb-vs-mix split) | dense glide+damping algebra |
| v39==2,3 chorus | High / Medium (quad shaping) | |
| v39==4 flanger | High / Medium (stereo decorrelation detail) | inverse-FB table confirms flanger |
| v39==5 cascade | High (cascade proven) / Medium (per-stage coef split) | 4 rings, R→R/L→L verified |

---

## 8. Open questions

1. **Exact slot→curve binding.** Each setup fn (e.g. `sub_7FF91DFBFF30`, `sub_7FF91DFBDE50`)
   calls `sub_7FF91DFB6380(curve, knob)` then writes several engine nodes (offsets `+104…
   +184`). The mapping of *which* engine node receives *which* curve output (and the per-node
   octave-fold) is init-time data; I documented the curve identities and the conversion
   formula but did not enumerate every node’s exact tap assignment.
2. **`v36`/`v38` exact L/R assignment.** The input mix (25587–25645) is a 4-pair feedback
   network; I have `v36`/`v38` as the two pre-FX rails feeding the modes, but the precise
   role of the aux path `84512…84880`/`101072…101120` (likely the global FX feedback / mod-FX
   tap) was not fully separated — it may couple the `v538` mod-FX block.
3. **Pan sub-effect (`+6976`).** Its ctor/skeleton is identical to the delay; I did not find
   a *distinct* `v39` case that is unambiguously "pan only". It may be folded into the
   delay/output stage (auto-pan via the same ring) rather than a separate mode — needs the
   param-routing table to confirm which `v39` value (if any) selects pure pan.
4. **`sub_7FF91DFC8DC0` curve table** (`unk_7FF91E5E94E0`, 26-coef rows). I identified it as a
   degree-13 polynomial LFO/shaper but did not decode the row coefficients (would need the
   row count and a dump); the per-row meaning (LFO waveshape vs saturation) is unconfirmed.
5. **Feedback-vs-mix coefficient split** in the dense cases (v39 1/4/5-stage1). The regen path
   and the wet/dry mix share nearby state slots; I flagged the regeneration offsets but the
   exact algebra (especially sign/order of the all-pass damping vs feedback) is Medium
   confidence.
6. **`v5` scale** (`state[84496]`, line 25586) multiplies LFO increments and tank inputs — it
   is a global tempo/SR/gate scalar; its exact derivation upstream was not traced.
