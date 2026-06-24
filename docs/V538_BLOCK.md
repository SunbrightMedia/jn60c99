# The `v538` block (state zone 84xxx–96xxx) — identification

Source: `allcode/decomp_340000.c`, function `sub_7FF91DFC3380` @ rva `0x363380`
(the whole multi-FX chain). The `v538` block is the **tail switch**, lines
**27140–27700**, followed by the common epilogue at 27701–27706.

---

## Verdict

**NOT a second reverb.** The `v538` block is the chain's **input-stage modulation /
drive effect** — a small bank of selectable algorithms (chorus / ensemble / flanger
and a couple of static distortion-and-tone variants). It is an *insert with one-sample
feedback*, placed **upstream** of the `v39` time-FX and the plate reverb, not a parallel
or alternate reverb tank.

Decisive evidence:

1. **No plate fingerprints.** None of the cases use the reverb's circular buffer
   (`a1+10759888`), its decrementing 16-bit `head` (`a1+10759856`), its tap-offset
   tables (`11022xxx`), its 4 damping one-poles, or its allpass lattice. The cases that
   *do* have a delay line use a **completely separate, small** circular buffer with its
   own head, and read it with **LFO-modulated fractional interpolation** — the signature
   of a chorus, not a reverb tank.
2. **No reverb output.** The block writes `a1+84672` / `a1+84704`; it never touches the
   reverb output accumulators `a1+101264` / `a1+101280`. Those are written
   unconditionally by the plate stage and the function tail still emits them
   (`**a3 = state[101264]*2`, lines 27703–27705) regardless of which `v538` case ran.
3. **It is on the *input* path, with feedback.** Its previous-sample outputs
   (`84672/84704`) are read at the very top of the next sample (lines 25606/25623) and
   mixed back into the dry input before the `v39` FX and reverb (see Routing).

**Confidence: High** on "not a reverb" and on the routing. **Medium–High** on the exact
per-case effect labels (chorus vs. ensemble vs. flanger): the modulated-delay cases are
unambiguously chorus-family; the two static cases (`v538 ≤ 1`) are a drive + allpass-tone
shaper whose exact musical name I infer from structure rather than a label string.

---

## 1. Selector

```c
v538 = **(_DWORD **)(*(_QWORD *)(a1 + 136) + 112LL);     // line 27140
```

`*(a1+136)` is the engine's parameter/config object; `[+112]` is a small int type
selector dereferenced to an int. (Compare: the `v39` upstream-FX switch a few lines up
uses the sibling field `[+136]`, line 25646.)

### Switch cases (exact ranges)

| `v538` | Lines | State zone | Algorithm |
|---|---|---|---|
| `0` (the `<=1` fall-through, `LABEL_164`) | 27265–27389 | `849xx–860xx` | static drive + allpass tone shaper (variant A) |
| `1` | 27143–27259 | `860xx–870xx` | static drive + allpass tone shaper (variant B) |
| `2`, `3`, `4` (the final `else`, `v538 <= 4`) | 27515–27699 | `903xx–960xx` + buffer `91728`, heads `95824/95828` | **dual-voice modulated delay (chorus / ensemble / flanger)** |
| `5` | 27395–27511 | `959xx–963xx` + buffer `96928`, heads `101024/101028` | **single-voice modulated delay (chorus / flanger)** |
| `>5` | falls to `LABEL_164` (case 0) | — | default = variant A |

Decompiled control flow: `if (v538==1) {case1} else { if (v538<=1) goto case0;
if (v538>4){ if(v538==5){case5} else goto case0 } else {cases 2-4} }`. So `0` and any
unmapped value ≥6 default to the variant-A drive; `2/3/4` share one code block (the
delay-time / depth / feedback coefficients differ per value but the topology is one).

---

## 2. Output routing (it IS on the audio path)

Per sample the block leaves two scalars:

```
a1+84672  = wet output sample  (v580-source: 87040 / 85968 / 96304 / 91088 by case)
a1+84704  = second wet output  (v580: 87040... actually the *second* of the pair)
```

(For each case the block computes a stereo-ish pair; `84672` and `84704` hold the two.)

These are **consumed at the very top of the next sample** (the function's input mix,
lines 25586–25645):

```c
v14 = state[84560];                 // a feedback/insert gain (a1+84592 mirror)
v19 = state[84704];   // prev wet R
v29 = state[84672];   // prev wet L
v28 = v19 * v14;      // 84752
v30 = v29 * v14;      // 84736
...
v33 = state[84832];   // = current dry input mix (built from v32=84624)
v35 = (v30*v9 - v9*v33) + v33;      // crossfade dry<->wet  (v9 = state[84544], wet/dry)
v37 = (v28*v9 - v9*v33) + v33;
v36 = state[101072] * v35;          // 101104  -> becomes a1+4297200 input to v39 FX
v38 = state[101072] * v37;          // 101120  -> becomes a1+4297216 input to v39 FX
```

`v36`/`v38` are then the stereo **input to the `v39` upstream time-FX switch**
(written to `a1+4297200/4297216` at lines 25672–25673 and used as the source signal in
every `v39` case: 25674, 25845, 25869, 26082, 26255, 26676 …), which in turn feeds the
reverb input pair `v169/v170`. (`a1+101104/101120` are scratch mirrors, written but not
re-read in this function.)

So the signal chain is:

```
voice mix ─► [v538 effect]  ──(wet, 1-sample fb via 84672/84704, x state[84560])──►
            crossfade dry/wet (state[84544]) ─► v36/v38 ─► [v39 time-FX] ─► v169/v170
            ─► [plate reverb] ─► 101264/101280 ─► **a3 (x2)
```

i.e. the `v538` block is an **insert effect at the head of the FX chain** (think the
JUNO/Roland-Cloud input "chorus/ensemble" stage), with a single-sample self-feedback
loop and a dry/wet mix. It is *not* metering and *not* a parallel reverb.

`a1+84624` (`v32`, line 27143/27266/etc. `*(a1+84624)` read at the top of every case) is
the block's **mono input** — built at line 25632 from the summed voice mix
`v31` through a one-pole (`*84640 + 84656`). So the block takes one mono drive of the
input, processes it, and returns a stereo wet pair.

---

## 3. Per-case structure (effect identification)

### Cases 0 and 1 — static drive + allpass tone shaper (no delay line)

Lines 27143–27259 (case 1) and 27265–27388 (case 0) are byte-for-byte the same shape on
different offsets. Fingerprints:

- **Short fixed shift registers** moved by explicit 16-byte copies (e.g. `86160→86176→
  …→86272`, a 7-deep line; plus 3-deep lines `86976/86992/87008/87024`). These are
  *fixed-tap FIR/state lines*, **not** a modulo circular buffer (no head index, no
  wrap, no fractional read).
- **Odd-order polynomial soft-clip / waveshaping** on several nodes, e.g.
  `v699 = v697*(v697*v697) * c` (cube), `v731 = ((v58*v58)*v58)*c + v58*c2`
  (lines 27160, 27198–27222, 27289, 27320–27344) — cubic + linear blends = classic
  tanh-style soft saturator approximations. `fminf(x,1.0)`/`-1.0` hard-clip rails appear
  around each (27174, 27194, 27201, 27316…).
- **Allpass / 1-pole lattice**: `x - delayed` then `g*x + delayed` pairs
  (27179/27185/27188, 27307/27309) and a one-pole smoother.
- **Wet/dry mix at the end via a sign-dependent crossfade** using a 3-tap FIR
  (`87072/87088/87104` and `87120/87136/87152`, then `if(v735>=0) … else …`,
  27238–27257; same with `86000…86080` in case 0). The two FIR taps feed `84672` and
  the `v580` second output.

No LFO call, no noise call, no modulated delay → this is a **static nonlinearity +
tone-shaping insert** (overdrive / "color" / a fixed phaser-like allpass timbre). The
two variants (0 vs 1) differ only in coefficient bank / line lengths.

### Cases 2/3/4 — dual-voice modulated delay (chorus / ensemble / flanger)

Lines 27515–27699. Fingerprints of a **modulated delay line (chorus family)**:

- **LFO**: `sub_7FF91DFC8F30()` (lines 27545, 27582) is a phase wrapper — `if(x>1)
  x=fmod(x+1,2)-1` — i.e. a wrapping LFO phase generator. Its `fabs` is taken
  (`v594`, `v586`) to make a triangle.
- **Noise/randomisation**: `sub_7FF91DFC8D60()` (lines 27554, 27557) is a small
  bit-twiddling PRNG returning a value `* 5.96e-8` (≈ ±1, 24-bit). Used to slightly
  randomise the modulation — consistent with an "ensemble"/BBD-flavoured chorus.
- **Dedicated circular delay buffer** at `a1+91728`, head/length `a1+95824`/`a1+95828`,
  decremented and wrapped: `v646 = (state[95824]-1) & (state[95828]-1); state[95824]=
  v646; BUF[v646] = wet;` (27695–27697). Mask `&(len-1)` ⇒ power-of-two length.
- **Two LFO-modulated, fractionally-interpolated read taps** (= two chorus voices /
  stereo): delay time `v619`/`v622` → integer part `(int)(x*-16384)` indexes the buffer,
  fractional part `x*16384 - floor` linearly interpolates two adjacent samples
  (`95856/95860`, frac `95864`; and `95872/95876`, frac `95880`) at lines 27633–27660.
- **Feedback + wet/dry**: `v645 = state[91264]` mixes `g*delayed + (1-g)*dry`
  (27692–27694) into the two outputs `91088`/`91104` → `84672` / `v580`.
- Plus the same input one-pole / allpass front-end as the static cases.

This is a **stereo (2-tap) modulated delay**: chorus when delay ≈ 5–30 ms, flanger when
shorter with feedback, "ensemble" with the noise-dithered LFO. The three values 2/3/4
select the same engine with different rate/depth/feedback/voice-count coefficient banks.

### Case 5 — single-voice modulated delay (chorus / flanger)

Lines 27395–27511. Same chorus engine but **one** modulated tap:

- LFO `sub_7FF91DFC8F30()` (27414) → `fabs` → triangle, depth scaled into a delay time.
- Separate small circular buffer `a1+96928`, head `a1+101024`/`a1+101028`, wrap-write at
  27506–27508 (`v579 = (state[101024]-1)&(state[101028]-1)`).
- **One** fractionally-interpolated read tap (`101056/101060`, frac `101064`,
  lines 27459–27468) — single voice.
- Output `96304` → `84672`, second output `96320` → `v580` (a lightly-detuned/EQ'd copy,
  27502–27505), giving a pseudo-stereo single-voice chorus/flanger.

---

## 4. Shared vs. own coefficient tables

The block uses **its own** coefficient/state region (`84xxx–96xxx`) entirely separate
from the reverb's (`10759xxx` / `11022xxx`). It does **not** read the reverb's tap tables,
`g`, or damping triplets. The LFO/PRNG helpers (`sub_7FF91DFC8F30`, `…8D60`) are generic
and used by other per-voice DSP functions in the binary (e.g. `decomp_380000.c`), so they
are shared utilities, not reverb-specific.

---

## 5. Open questions

1. **Exact coefficient meanings inside each case.** I classified by structure (shift
   register vs. modulo buffer, cubic clip vs. interpolated read, LFO/noise presence).
   The specific roles of individual `84xxx/85xxx/86xxx/91xxx/96xxx` coefficients
   (rate, depth, feedback amount, EQ corner) are loaded at param-update time from
   `.rdata`, not as literals here, so the precise per-case parameter mapping is not
   resolvable from this function alone.
2. **Whether 2/3/4 are three distinct musical modes or one mode with three banks.**
   They share one code path (one topology); the difference is purely the coefficient
   bank selected upstream by `v538`. Naming them individually (chorus I / chorus II /
   ensemble) would require the param-update / preset code.
3. **Static-case label.** Cases 0/1 are clearly "nonlinear drive + allpass tone shaper
   with wet/dry"; whether the product UI calls this "overdrive", "color", or a fixed
   phaser is a label question outside this function. The DSP is a static waveshaper +
   short FIR/allpass, definitively **not** a reverb and **not** a modulated delay.
4. **`v580` / `84704` second-output exact pairing.** Each case computes a pair; I traced
   `84672` (first) and `84704 = v580` (second) and confirmed both are read back as the
   stereo feedback pair next sample. The L/R assignment convention (which is "left") is
   cosmetic given the symmetric crossfade.
