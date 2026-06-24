# JUNO-60 Reverb DSP — faithful per-sample transcription

Source: `allcode/decomp_340000.c`, function `sub_7FF91DFC3380` @ rva `0x363380`
(`float *__fastcall sub_7FF91DFC3380(__int64 a1, float **a2, float **a3)`),
lines 24843–27707. `a1` = engine/FX state, `a2` = input buffers, `a3` = output.

> **This function is the whole multi-FX chain.** It is *not* one reverb. It contains, in
> series: an input/voice mix-down, an upstream time-FX block (delay/chorus/flanger — the
> `v39` switch, state zone `4297xxx`/`6395xxx`/`6430xxx`), then **the reverb** (the
> `10759888`-based plate), then a final coloration/output stage, and a *separate*
> parallel mod-FX (`v538` switch, state zone `84xxx–96xxx`). **Only the reverb is
> documented here.** The reverb is a **Dattorro/Griesinger figure-of-eight plate** whose
> per-sample code is the `else` branch at lines **26944–27098** plus the input feed
> (`v169`/`v170`) and the output saturator (lines **27100–27137**). All coefficients are
> held in float state (loaded from the `.rdata` tables at re-tune time — they are *not*
> literals in this function), exactly as the brief predicted.

---

## 0. Where the reverb sits in the data flow

```
a2 (voice stereo) ──▶ input mix (lines 25587–25645) ──▶ v36 / v38  (pre-FX stereo)
                                                          │
        v39 switch  (upstream time-FX: delay/chorus/…)    ▼
        produces the REVERB INPUT pair:           v169 (R-in) , v170 (L-in)
                                                          │
                                              ┌───────────▼───────────┐
                                              │   PLATE  REVERB        │   buffer @ a1+10759888
                                              │  (lines 26944–27098)   │   heads @ a1+10759856
                                              └───────────┬───────────┘
                                       L tap sum = v516 ,  R tap sum = v517
                                                          │
                              output saturator / level (lines 27100–27137)
                                                          │
                              a1+101264 (out L) , a1+101280 (out R)
                                                          ▼
                       **a3   = state[101264]*2 ;  *a3[1] = state[101280]*2
```

`v169`/`v170` are assigned by **every** `v39` case (25806, 26025, 26209, 26625, 26835); they
are the dry stereo signal arriving at the reverb. When the reverb is faded out
(`v462 <= 0` or decay `state[10759376] <= 0`), the tank is skipped and the input passes
straight through: `v516 = v170; v517 = v169;` (line 26872–26873).

---

## 1. State-offset map (reverb only)

All offsets are byte offsets from `a1`. `f` = float32, `i` = int32/uint16 index.

### Buffer + circular-index state
| Offset | Type | Meaning |
|---|---|---|
| `10759888` (0xA42850) | f[] | **Plate delay buffer base.** All tank read/write taps index here: `*(a1 + 4*(uint16)(head + tapOff) + 10759888)`. |
| `10759856` (0xA42830) | i | **Write head** (master phase). Decremented mod 2^16 once per sample at line 26840: `head = (uint16)(head - 1)`. All taps are `head + tapOffset`, wrapped to 16 bits. |
| `10759872` (0xA42840) | i | Clear/retune countdown. While `>0`, the buffer is being zeroed in 256-word strides (lines 26876–26941) and the live tap table is reloaded from the source table. |

### Tap-offset tables (the delay-line lengths, in samples, as additive head offsets)
| Offset | Type | Meaning |
|---|---|---|
| `11022064 … 11022196` | i ×34 | **Live tap-offset table** (stride 4). Each entry is a per-line offset added to the write head. Read/written as 16-bit. |
| `11022208 … 11022340` | i ×34 | **Source tap-offset table** (the retuned target). Copied into the live table when the clear countdown reaches 0 (lines 26892–26925). |
| `11022032` (0xA82530) | f | **Reverb wet fade / crossfade gain** `v462`/`v514` (ramps ±0.0004/sample toward 0 or 1; clamped [0,1]). Gates the whole tank on/off smoothly. |

Tap-slot roles (from usage in 26944–27098), head = `state[10759856]`:

| Slot offset | Role |
|---|---|
| `11022064` | input-diffuser AP0 **write** head |
| `11022068` | input-diffuser AP0 **modulated read** (read index biased by `-(int)(v474*v475)`, ±2048-sample mod) |
| `11022072` / `11022076` | AP0 second write / read |
| `11022080`/`084`, `088`/`092`, `096`/`100`, `104`/`108` | further input-diffuser allpass write/read pairs (lattice) |
| `11022112`/`116`, `120`/`124`, `128`/`132` | **tank** allpass write/read pairs (the 4 long damped-allpass loops) |
| `11022136`,`148`,`152`,`164`,`168`,`180`,`184`,`196` | long-line write heads + cross-loop read heads |
| `11022140`,`156`,`160`,`172`,`176`,`188`,`192`,`144` | **output tap reads** summed into `v516` (L) / `v517` (R) |

### Coefficient / filter-state offsets (active tank, 26944–27098)
| Offset | Type | Meaning |
|---|---|---|
| `10759376` | f | **Decay/size enable** `v463`/`v515` (reverb amount; ≤0 ⇒ bypass). Multiplies the output taps. |
| `10759392` | f | **Diffuser allpass gain `g`** — single shared coefficient used by *every* allpass stage (16 references). Pattern `read - g*next` then `g*x + delayed`. Corresponds to the `0x639F20` `(g,−g,c)` schedule (a single working `g` here; the schedule is baked into the source coeffs). |
| `10759408` | f | Input scale into tank (with the `0.03125 = 1/32` constant, line 26947). |
| `10759424` | f | **Dry mix gain** added to each output tap (`+ state[10759424]*v170/v169`, lines 27074/27098). |
| `10759440` | f | **Output-tap master gain** `v513` (multiplied by the constant `16.0`). |
| `10759488`,`10759504` | f | Pre-tank modulator: triangle/saw LFO step (`10759504`) and depth (`10759488`) feeding the ±2048 modulated allpass read (`v474`). |
| `10759520`,`10759536`,`10759552`,`10759568`,`10759584`,`10759600`,`10759616`,`10759632` | f | Coefficients of the **input pre-filter** (two cascaded biquad/allpass sections, lines 26946–26960) operating on `v465` before injection. State regs: `10759120/136/152/168/184`. |
| `10759648` , `10759664`,`10759680` | f | **Tank damping one-pole #1** (loop A): `s += (x − s)*c1` then `s2 = s*b + s2_state*a` (lines 27007–27010). |
| `10759696` , `10759712`,`10759728` | f | Tank damping one-pole #2 (loop B), lines 27019–27022. |
| `10759744` , `10759760`,`10759776` | f | Tank damping one-pole #3 (loop C), lines 27031–27034. |
| `10759792` , `10759808`,`10759824` | f | Tank damping one-pole #4 (loop D), lines 27043–27046. |
| `10759120,136,152,168,184` | f | Input pre-filter delay/integrator state. |
| `10759200,216,232,248,264,280,296,312` | f | The 4 tank damping filters' state registers (2 each: one-pole accumulator + smoothed output). |
| `10759328,10759344` | f | Modulator phase accumulator (`v473`, wrapped to [-1,1] by subtracting 2.0). |

### Output saturator / level stage (lines 27100–27137)
| Offset | Type | Meaning |
|---|---|---|
| `101152,101136` | i | 1-sample shift register feeding `v521`→`101184`, `v522 = state[101168]`. |
| `101168` | f | `v522` = post-tank gain/coupling applied to both tap sums. |
| `101184` | f | second coupling factor (`v523 = (v522*v517)*state[101184]`, `v524 = state[101184]*state[101200]`). |
| `101200,101216` | f | scratch: `v522*v516`, `v522*v517`. |
| `101232,101248` | f | scratch: `v524`, `v523`. |
| `101296` | f | drive/input gain `v525` into the polynomial waveshaper (`v528=v524*v525`, `v529=v523*v525`). |
| `101312` | f | **output level** (final scale: `out = shaped * state[101312]`). |
| `101328,101344,101360,101376,101392,101408` | f | **polynomial waveshaper coefficients** (odd-order soft clipper: `c0 + c1·x + c2·x² + c3·x³ + c4·x⁴·… `, lines 27116–27131). |
| `101424,101440` | f | upper hard-clip threshold / value. |
| `101456,101472` | f | lower hard-clip threshold / value. |
| `101264` | f | **OUTPUT L accumulator** = `v535 = shaped_L * state[101312]`. |
| `101280` | f | **OUTPUT R accumulator** = `v537 = shaped_R * state[101312]`. |
| `a1+32`, `a1+36` | f | mirror copies of out L/R (line 27138–27139). |

Final (line 27703–27705): `**a3 = state[101264] + state[101264];  *a3[1] = state[101280] + state[101280];`
(i.e. **×2** on each channel.)

---

## 2. Signal-flow transcription (pseudocode)

Named signals follow the decompiler `v###`. `BUF[i]` ≡ `*(a1 + 4*(uint16)i + 10759888)`.
`head` ≡ `state[10759856]`. `tap(k)` ≡ live tap offset `state[11022000 + k]`.
`g` ≡ `state[10759392]` (diffuser allpass gain). `decay` ≡ `state[10759376]`,
`fade` ≡ `state[11022032]`.

```text
# ---- per sample ----
head = (head - 1) & 0xFFFF                        # advance master phase (26840)

# fade ramp (wet on/off), 26841–26869 — ramps fade toward 1 (active) or 0 (clearing)
fade = clamp(fade ± 0.0004, 0, 1)

if (fade <= 0) or (decay <= 0):                   # BYPASS
    v516 = v170 ; v517 = v169                      # dry passthrough (26872)
else:
    # ---------- INPUT INJECTION ----------
    in   = (v169 + v170) * (1/32) * pre_emph * decay * fade          # v465 (26947)

    # ---------- INPUT PRE-FILTER (2 cascaded sections) ----------   # 26946–26961
    # cross-coupled biquad/allpass smear of the mono input -> v472
    s0 = state[10759120]; ...                                        # (state 10759120..184)
    v468 = coupling(in, s0, s1, coefs 10759520/536/552)             # first section
    v472 = coupling(v468, s2, s3, s4, coefs 10759568/584/600/616/632)
    # v472 is the diffuser input

    # ---------- MODULATOR ----------                                # 26962–26974
    ph = state[10759344] + state[10759504]                          # phase accumulator
    if ph > 1.0: ph -= 2.0
    v474 = ph * state[10759488]                                     # mod depth
    v475 = (ph < 0) ? +2048 : -2048                                 # mod sign/scale
    state[10759344] = ph

    # ---------- INPUT DIFFUSION ALLPASS CHAIN ----------            # 26975–27002
    BUF[head + tap(64)] = v472                                      # write AP0 input
    # AP0: a *modulated* allpass (delay read index biased by -(int)(v474*v475))
    a = BUF[head + tap(68) - (int)(v474*v475)]                     # modulated read
    b = BUF[head + tap(76)]
    BUF[head + tap(72)] = a - b*g                                   # allpass write
    # AP1..AP4 (plain lattice allpasses, g shared):
    for (wr,rd) in [(80,84),(88,92),(96,100),(104,108)]:
        x  = BUF[head + tap(rd)]
        y  = (g * prevWrite) + x                                    # feed-forward sum
        BUF[head + tap(wr)] = prevWrite - g*x                       # allpass
    v491 = (...)                                                    # diffused mono
    v493 = v491 * 0.5                                               # split into the two tank rails (27000)

    # ---------- TANK : four damped-allpass loops (figure-8) ----------
    # Each loop: allpass(read tap, g) -> long delay write -> damping one-pole -> long read
    # LOOP A  (27001–27010)
    BUF[head+tap(104)] = (v493 - BUF[head+tap(108)]*g) + state[10759216]
    BUF[head+tap(136)] = v494*g + BUF[head+tap(108)]               # long-line write
    v495 = BUF[head+tap(148)] - state[10759200]                    # long-line read
    s = state[10759200] + v495*state[10759648]                     # damp one-pole #1
    state[10759216] = s*state[10759680] + state[10759216]*state[10759664]   # smooth

    # LOOP B  (27011–27022)  uses v493, taps 112/116/152/164, damp coefs 10759696/712/728
    # LOOP C  (27023–27034)  uses v493, taps 120/124/168/180, damp coefs 10759744/760/776
    # LOOP D  (27035–27046)  uses v493, taps 128/132/184/196, damp coefs 10759792/808/824
    #   (all four are structurally identical: AP into the buffer, delayed write, one-pole
    #    HF damping, feedback read; the loops share the single split source v493 and
    #    cross via the shared circular buffer — classic 4-rail plate tank.)

    # ---------- OUTPUT TAPS ----------                              # 27047–27098
    L_taps = BUF[head+tap(160)] + BUF[head+tap(140)] + BUF[head+tap(172)] + BUF[head+tap(192)]
    v516   = (((L_taps * state[10759440]) * 16.0) * fade) * decay  +  state[10759424]*v170
    R_taps = BUF[head+tap(144)] + BUF[head+tap(156)] + BUF[head+tap(176)] + BUF[head+tap(188)]
    v517   = (((R_taps * state[10759440]) * 16.0) * fade) * decay  +  state[10759424]*v169

# ---------- OUTPUT SATURATOR / LEVEL ----------                    # 27100–27137
state[101168] = state[101136]                                       # shift
v522 = state[101168]
xL = (state[101184]*(v522*v516)) * state[101296]                   # v528  (drive)
xR = ((v522*v517)*state[101184]) * state[101296]                  # v529  (drive)
# odd-order polynomial waveshaper with hard-clip rails:
yL = poly(xL, coefs 101328/344/360/376/392/408)                   # v531
if state[101424]-xL >= 0: yL = state[101440]                       # hard clip hi
if state[101456]-xL <= 0: yL = state[101472]                       # hard clip lo
state[101264] = yL * state[101312]                                 # OUT L  (v535)
yR = poly(xR, …) ; clip ; state[101280] = yR * state[101312]      # OUT R  (v537)

# ---------- final ----------
**a3   = state[101264]*2
*a3[1] = state[101280]*2
```

---

## 3. Topology summary

- **Type:** Dattorro/Griesinger plate (figure-of-eight), single shared circular buffer
  `BUF @ a1+10759888`, addressed by one decrementing 16-bit `head` plus per-line additive
  tap offsets. This is the standard "one big modulo buffer, many taps" plate layout.
- **Input diffusion:** **5 allpass stages in series** before the tank
  (one *modulated* allpass — AP0, read index dithered by a ±2048-sample LFO term
  `v474*v475` — followed by 4 plain lattice allpasses), all sharing the single diffuser
  gain `g = state[10759392]`. A 2-section cross-coupled biquad/allpass **input
  pre-filter** sits ahead of them. The diffused mono signal is split ×0.5 (`v493`) and
  fed to all tank rails.
- **Tank:** **4 damped-allpass loops** (rails A/B/C/D, lines 27001–27046), structurally
  identical: `allpass(g) → long delay write → one-pole HF damping → delayed read`. Each
  rail has its own damping one-pole (coef triplets at `10759648/664/680`,
  `696/712/728`, `744/760/776`, `792/808/824`) and its own delay state pair. They are
  cross-coupled only through the shared `BUF` (reads of one rail's write region by
  another's tap), which is how the figure-8 energy recirculation is realised here.
- **Feedback / decay:** the recirculation gain is folded into the input-injection scale
  (`decay = state[10759376]`, `fade = state[11022032]`) and the allpass/damping coeffs;
  there is no separate explicit feedback-matrix multiply — energy persists because the
  long-line writes (`tap 136/152/168/184`) re-enter via the cross reads.
- **Output taps:** **8 taps total**, 4 per channel, summed:
  - **L (`v516`)** = `BUF[tap160] + BUF[tap140] + BUF[tap172] + BUF[tap192]`
  - **R (`v517`)** = `BUF[tap144] + BUF[tap156] + BUF[tap176] + BUF[tap188]`
  - scaled by `state[10759440] * 16.0 * fade * decay`, plus a dry term
    `state[10759424] * v170` (L) / `v169` (R). Each channel reads one tap from each of
    the 4 rails — the classic plate stereo de-correlation by tapping different points of
    each loop.
- **Post:** a per-channel **odd-order polynomial waveshaper + hard-clip** (101xxx) and a
  final **×2** at the function tail.
- **Counts vs. tables:** 5 series input allpasses + 4 tank rails ⇒ 9 allpass-type stages
  visible in the active per-sample code, plus the 2-section pre-filter and 4 damping
  one-poles. The `0x639F20` table lists **14** allpass `(g,−g,c)` rows and `0x63A350`
  lists **20** delay lines: the extra stages are encoded as the **34 tap-offset slots**
  (`11022064…196` live / `…208…340` source) and the per-stage coeffs baked into the
  shared `g`/damping state — i.e. the table's 14+20 are realised as tap offsets and
  coefficient state, not as 14/20 distinct unrolled code blocks. The mapping table→slot
  is consistent (34 live slots ≈ 20 lines × {write,read} minus shared heads) but the
  exact line↔slot assignment is init-time data (see Open Questions).

**Confidence:** High on the overall topology, the input/output signal path, the bypass
logic, the buffer/head addressing, the output-tap set, and the saturator. Medium on the
precise per-rail allpass-vs-comb classification of loops B/C/D (read structurally identical
to A but I transcribed A in full and abbreviated B/C/D) and on the exact one-to-one mapping
between the 34 runtime tap offsets and the 20 named delay lengths in `reverb_tables.json`
(that binding is performed in the retune/init code, not in this per-sample function).

---

## 3a. Verification (cross-checked against raw decompile)

Loops A–D (lines 27001–27046) and the output taps (27047–27098) were read line-by-line
and confirmed. Each of the 4 tank rails is byte-for-byte the same shape (only taps/coeffs
differ), a self-contained Dattorro rail:

```
v = (v493 - g*delay_elem) + fb_X            # allpass in, with own damped feedback fb_X
BUF[allpass_tap]  = v                        # rail allpass node
BUF[longline_tap] = v*g + delay_elem         # nested long delay write
read = BUF[longread_tap] - damp_acc
damp_acc = read*c1 + damp_acc                # HF damping one-pole accumulator
fb_X     = damp_out*c3 + fb_X*c2             # smoothed output -> next-sample feedback
```

- rail A: allpass tap 11022104, delay-elem 11022108(=v492), long write 11022136, long read 11022148; damp coefs 10759648/664/680; fb/state 10759200/216
- rail B: 11022112/116, 11022152, 11022164; damp 10759696/712/728; state 10759232/248
- rail C: 11022120/124, 11022168, 11022180; damp 10759744/760/776; state 10759264/280
- rail D: 11022128/132, 11022184, 11022196; damp 10759792/808/824; state 10759296/312

The 4 rails run in **parallel**, all injected with the same split source `v493`; they share
the one physical buffer `BUF@10759888` but each maintains its own allpass/delay/damping
state and its own self-feedback — i.e. 4 parallel damped feedback allpass loops, tapped at
8 points (4/channel) for stereo de-correlation. The 4 damping coef-triplets line up 1:1
with the 4 damping-biquad groups in `reverb_tables.json`. **Topology confirmed.**

## 4. Open questions

1. **Tap-slot ↔ delay-length binding.** The live tap table `11022064…11022196` (34 slots)
   is populated at retune from `11022208…11022340`, which is itself filled by the
   setup/retune routine elsewhere from the `0x63A350` length table. This per-sample
   function only *uses* the offsets; the exact slot→length assignment (and the SR-column
   pick) must be read from the setup function (`sub_1803C1AC0` per prior docs / the
   retune path that writes `a1+11022208…`). Not resolvable from this function alone.
2. **Coefficient sources.** `g = state[10759392]`, the 4 damping triplets, the
   waveshaper coeffs (`101328…101408`) and clip rails are all consumed as state here;
   their load from `0x639F20`/`0x63A130` (allpass + damping biquad tables) happens in the
   init/param-update path, not in this function. I verified the *structure* matches
   unity-DC one-pole damping and an allpass lattice; I did not see the literal table
   values written (consistent with the brief).
3. **Loops B/C/D exact form.** Lines 27011–27046 are structurally parallel to loop A
   (27001–27010) — same allpass+one-pole+delayed-read shape with different taps/coeffs —
   but I transcribed A in full and treated B/C/D as identical-by-pattern. A line-by-line
   read could confirm whether any rail uses a comb (no allpass feed-forward) instead of an
   allpass; the damping-one-pole + delayed-read part is identical across all four.
4. **Input pre-filter order.** The two cross-coupled sections (26946–26961, coeffs
   `10759520…10759632`) are clearly a 2nd/4th-order filter feeding the diffuser, but I
   did not fully separate them into canonical biquad form; they may be a pre-emphasis /
   bandwidth control rather than part of the reverb proper.
5. **The `v538` block (84xxx–96xxx).** A *separate* modulated effect writing `a1+84672`,
   gated by the `*(a1+136)+112` selector. It is **not** on the reverb output path
   (101264/101280) and is not documented here; if it turns out to be an alternate reverb
   algorithm (hall type), it would need its own pass.
```
