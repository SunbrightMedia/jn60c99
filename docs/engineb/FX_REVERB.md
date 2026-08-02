# ENGINE B — THE REVERB: behavioural specification (MEASURED, 2026-08-02)

Every number below was executed. The oracle is the sealed port (`libjuno.so`),
driven at the master stage directly through `tools/engineb/fx_chorus_probe.c`
(reused unchanged), so the reverb is observed with a known input signal instead
of a note. `src/` was not modified.

Probes (committed, repeatable):

| file | what it does |
|---|---|
| `tools/engineb/fx_reverb_recon.py` | first look: cells, tap array, wipe countdown |
| `tools/engineb/fx_reverb_spec.py` | isolation + **bit-exact topology reconstruction** |
| `tools/engineb/fx_reverb_spec2.py` | parameter laws, memory extent, reference vectors |
| `tools/engineb/fx_reverb_cost.c` | callgrind driver — the reverb arm's executed cost |
| `tools/engineb/fx_reverb_cand.c` | the proposed cheap formulation, costed by `cost.py` |

Data: `docs/engineb/data/fx_reverb.{json,npz}` (§9 lists the contents). The
copies in `scratchpad/engineb/` are gitignored; the committed ones are the ones
to trust.

Run with `LD_LIBRARY_PATH=.` after `make libjuno.so` and
`cc -O2 -shared -fPIC -o scratchpad/fx_chorus_probe.so tools/engineb/fx_chorus_probe.c -L. -ljuno`.

---

## 0. The headline answers

1. **The reverb line does NOT fit internal SRAM.** At 48 kHz the tank needs
   **45,566 floats = 182,264 B** with the default PRE DELAY and **49,406 floats
   = 197,624 B** at the maximum PRE DELAY the recall accepts (MEASURED, §7).
   The plugin itself allocates a single 65,536-float line = **262,144 B**. The
   engine B budget is 200 KB *total* internal on a 512 KB part. The reverb alone
   is 91–99 % of it. **It must live in PSRAM** — specifically the four long loop
   delays (138,104 B); the short elements (44,160 B, or 59,520 B at maximum
   PRE DELAY) can and should stay internal.
2. **`EB_REVERB_LEN` in `engine_b/eb_types.h` is 8,192 floats (32,768 B). That
   placeholder is 6.0× too small.** It is the first thing to fix.
3. **The reverb arm costs 298 executed x86-64 instructions per sample**
   (MEASURED, §8) — 20 % of the whole master's 1,462. A candidate rewrite for a
   scalar FPU models at **480–1,014 cycles/sample on the S3 out of internal
   SRAM (nom 636)**, i.e. above the first-guess 500-cycle reverb budget but
   14–29 % of the whole-engine 3,500. Out of PSRAM with no caching the same
   model gives 6,420–24,576 — **the memory tier, not the arithmetic, is the
   risk.** §8 explains why the true figure should be near the internal one and
   why that claim is MODELED and unmeasured.
4. **The 48 kHz reverb is 2.08× longer than the 44.1 kHz reverb**, in samples
   *and* in seconds (max tap 46,551 vs 22,358 — MEASURED at every TYPE). This is
   the plugin's own rate law, not a bug, and engine B targets 48 kHz, so it pays
   the larger memory. There is no saving here.

---

## 1. Where the reverb is, and proof the probe reached it

The reverb is a **global send in the master output stage**, not an insert. It
runs on every patch regardless of EFFECT TYPE routing.

| cell | meaning | measured (patch 0, 48 kHz) |
|---|---|---|
| `10759888 … 11022028` | **the delay line**, 65,536 floats | 262,144 B, contiguous, ends exactly where the mute cell begins |
| `10759856` | write position | decrements, used as `(uint16)(pos + tap)` |
| `11022208 … 11022340` | tap table written by recall (34 ints) | latched into… |
| `11022064 … 11022196` | …the working tap table the DSP reads | copied when the wipe completes |
| `10759120 … 10759184` | input-filter state (5 cells) | `10759120` also holds this sample's scaled reverb input |
| `10759200 … 10759312` | damper state, 2 cells per loop | |
| `10759392` | the one allpass coefficient | **0.5**, shared by all 9 allpasses |
| `10759408` | send level (REVERB LEVEL) | 0.372772216796875 |
| `10759424` / `10759440` | dry gain / wet gain | 1.0 / 0.49803922 |
| `10759376` / `11022032` | run gate / mute crossfade | 1.0 / ramps 0→1 |
| `10759872` | lazy-wipe countdown | 256 after every recall |
| `10759344` / `10759504` / `10759488` | modulation phase / increment / depth | depth is **0 except TYPE 5** |

**Isolation was verified, not assumed** (`isolation` and `isolation_send_only`
in the JSON). With the send gain zeroed from cold and dry zeroed, the master
output over 8,000 samples of a 220 Hz sine peaks at **1.57e-13** (−256 dBFS) at
both rates — the reverb contributes nothing but its own numerical floor. Zeroing
the send *after* a warm-up instead leaves a decaying tail (peak 1.73e-5 falling
to 2.68e-12 over 200,000 samples at 44.1 kHz), which is the tank ringing out, so
the residual is the reverb's own memory rather than a leak from another block.

---

## 2. The topology, proven by BIT-EXACT reconstruction

The structure below is **not read off the decompile**. `fx_reverb_spec.py`
re-implements it in numpy in float32, seeded only with the engine's own state at
t = 0 and the traced per-sample input, and requires it to reproduce the engine's
stereo pair cell for cell:

```
44100  bit_exact_L true  bit_exact_R true  max_abs_err 0.0  over 60,000 samples  (rms 0.702)
48000  bit_exact_L true  bit_exact_R true  max_abs_err 0.0  over 60,000 samples  (rms 1.204)
```

Non-vacuous: the compared signal is not zero, and an earlier run of the same
code with the output stage mis-modelled failed with max error 0.97. The
comparison is against cells `101200`/`101216` (= master output gain `101168` ×
the reverb's stereo pair) because the engine's final `outL/outR` pass through a
polynomial soft-clip that is not part of the reverb.

```
                   send                    ┌──────────────── L = (tA_L+tB_L+tC_L+tD_L)·wet·16·mute·gate
 (chorus/delay out)──×──> DC block ──> LPF2 │
                                      │     └──────────────── R = (tA_R+tB_R+tC_R+tD_R)·wet·16·mute·gate
                                      v
                              pre-delay (tap 0 → tap 1)
                                      v
                      AP1 → AP2 → AP3 → AP4        (allpass coefficient 0.5)
                                      v
                                   ×0.5
                    ┌──────┬────────┴────────┬──────┐
                    v      v                 v      v
                 loop A  loop B           loop C  loop D      (identical shape)

  each loop:   in + damper_out ──> allpass(g=0.5, ~1,345) ──> long delay ──┐
                       ^                                                  │
                       └──── one-pole damper (fc, hp, lp) <────────────────┘
               two taps out of the long delay, one to L and one to R
```

Executed detail, per sample:

* **`pos = (pos − 1) & 0xFFFF`** first; every tap is `buf[(pos + T[k]) & 0xFFFF]`,
  so every access stream advances by exactly one sample per step.
* **DC block** `y = b0·x + b1·x[n−1] + a1·y[n−1]`, coefficients
  `0.99613804, −0.99613804, 0.99227613` (rate-dependent, read from state).
* **2-pole lowpass** `z = c0·y + c1·y[n−1] + c2·y[n−2] + p1·z[n−1] + p2·z[n−2]`,
  `0.15297298, 0.30594596, 0.15297298, 0.63087291, −0.24276485` at 44.1 kHz.
* **Pre-delay**: `z` is written at tap 0 and read at tap 1. Tap 1 is the only
  modulated tap: its read index is offset by `−(int)(phase · depth · ∓2048)`,
  with `phase` a bipolar saw (`phase += inc; if (phase > 1) phase −= 2`).
  **depth is 0 for TYPE 0–4 and 0.203125 for TYPE 5** — so the modulation is
  dead on five of the six types and is the only thing that makes TYPE 5 differ
  from TYPE 2 (§4).
* **Four series allpasses**, delays 1,911 / 1,517 / 907 / 361 samples at 48 kHz,
  all with g = 0.5 taken from the *same* cell `10759392`.
* **Output of the diffuser is halved** and fed to all four loops identically.
* **Each loop**: `apin = 0.5·diff + damper_out`; standard allpass; the allpass
  output is written into the long delay; the delay's oldest sample `e` goes
  through a one-pole `lp += fc·(e − lp)` and the damper output is
  `lpc·lp + hpc·e`; two intermediate taps of the same long delay are summed into
  L and R. **There is no explicit decay gain — the decay IS the damper's
  `hpc`/`lpc` pair**, which is what REVERB TIME moves (§5).
* **Wet/dry**: `out = tapsum · wet(10759440) · 16.0 · mute(11022032) ·
  gate(10759376) + dry(10759424) · dry_input`. The multiply order is
  load-bearing for a bit-exact null: `(((tapsum · wet) · 16) · mute) · gate`.

Left takes taps `24,19,27,32` in that summation order; right takes `20,23,28,31`.

**Warm-up behaviour, which the LOCKSTEP rule makes load-bearing.** Every recall
re-arms `10759872 = 256`. While it is non-zero the reverb tank **does not run at
all**: master_render wipes one 256-dword stripe of the line per sample, the mute
crossfade is held at 0, and the tap table is latched from `11022208` into
`11022064` only when the countdown reaches 0. Then the crossfade ramps
`+0.00039999999` per sample to 1.0 (2,500 samples). Total: **2,756 samples of
reverb silence after every patch change**, then a linear fade-in. Engine B must
reproduce this or a warm patch change will not null.

One measured quirk: after the wipe completes, **44 of the 65,536 line cells are
still non-zero** (indices 65,237…65,280) — the wipe does not quite cover the
line. They sit beyond every tap (max 50,391) so they are never read at 48 kHz.
Recorded, not reproduced.

---

## 3. REVERB LEVEL (send) — value-tree index 795, front-panel blob 51

A 256-entry lookup, **rate-independent** (`level_rate_independent: true`,
44.1 kHz bits identical to 48 kHz for all 256 bytes). Bits are in
`fx_reverb.npz["level_send_bits"]`. Bytes 0–2 map to 0.0; the curve is
monotone and has repeated plateaus (the plugin quantises), so engine B should
carry the table, not a formula. It scales the tank input only; it is not in the
output path.

---

## 4. REVERB TYPE — record byte 658, values 0…5

**A methodological warning first.** `juno_gui_host_set` is a **no-op** for the
reverb TYPE (876), TIME (877) and PRE DELAY (1323) indices — a first sweep
through it moved not one cell and reported "TYPE has no effect", which would
have been a green and wrong result. The measurements here drive the **record
bytes** in a copy of the bank image and re-run the real recall through
`juno_gui_apply_bank`; the difference is visible in the tables below.

TYPE selects three things:

| TYPE | tap set | damper cutoff `fc` (48 k) | modulation depth | damper hp/lp at the patch's TIME |
|---|---|---|---|---|
| 0 | short (max tap 7,699) | 0.06522907 | 0 | 0.8566 / −0.9169, 0.8277 / −0.8985 |
| 1 | medium (19,181) | 0.13027629 | 0 | 0.6364 / −0.7335, 0.5562 / −0.6675 |
| 2 | long (46,551) | 0.13027629 | 0 | 0.5112 / −0.7247, 0.4214 / −0.6549 |
| 3 | long (46,551) | 0.03346036 | 0 | 0.5988 / −0.7860, 0.5142 / −0.7268 |
| 4 | long (46,551) | 0.70603102 | 0 | 0.5988 / −0.7860, 0.5142 / −0.7268 |
| 5 | long (46,551) | 0.13027629 | **0.203125** | 0.5988 / −0.7860, 0.5142 / −0.7268 |

All four dampers share one cutoff value. Types 2–5 share one tap set and differ
only in cutoff and modulation. The 44.1 kHz cutoffs are different numbers
(0.14190, 0.28284, 0.28284, 0.07283, 1.41421, 0.28284) — TYPE is the one reverb
parameter whose coefficients are **not** rate-independent.

Tap sets, both rates, all six types: `fx_reverb.json → type`.

---

## 5. REVERB TIME — record byte 666, 0…255

TIME writes **only** the eight damper hp/lp coefficients, in four mirrored
pairs (`mirror_pairs_equal: true`: cells 10759664≡10759712, 10759680≡10759728,
10759760≡10759808, 10759776≡10759824). So there are four independent curves —
`(hp, lp)` for loops A/B and `(hp, lp)` for loops C/D.

MEASURED over the full cross product (6 TYPEs × 256 bytes × 8 cells × 2 rates,
24,576 recalls):

* **Rate-independent**: the 44.1 kHz and 48 kHz arrays are bit-identical
  (`time_rate_independent: true`).
* **Joint with TYPE**: `type_dependent: true`; there are **16 distinct
  curves** over the (TYPE, cell) grid, not 4 — TYPE selects which family of
  TIME curves is used. Engine B needs the joint table, not a per-cell curve.

The full array is `fx_reverb.npz["time_hplp_bits_48000"]`, shape `(6, 256, 8)`
uint32 float bits, and it is the gating reference for the recall side.

---

## 6. REVERB PRE DELAY — value-tree index 1323, record byte 3947

MEASURED over bytes 0…127 × 3 tap classes × 2 rates, 768 recalls:

* `uniform_shift: true` at every point — tap 0 is pinned at 1 and taps 1…33 all
  move by the **same** integer.
* The closed form `predelay = max(⌊min(byte,100)·Hr/1000⌋ − 2, 0)` reproduces
  both the shift and the master pre-delay cell `10759360` exactly at every byte
  and rate (`closed_form_max_predelay_2_holds: true`). Values above 100 clamp.
* Shift relative to the default byte 20: **−958 … +3,840 samples at 48 kHz**
  (−880 … +3,528 at 44.1 kHz). Pre-delay at byte 100 is 4,798 samples (100 ms).

Because the shift is uniform, in a split-buffer implementation it moves **only
the pre-delay element's length**; every other element keeps its size. That is
the reason to split (§7).

---

## 7. MEMORY — the number that decides the architecture

The plugin uses one line addressed by a 16-bit mask, so its allocation is
`65,536 × 4 = 262,144 B` at every rate and every type. The tap layout is nearly
contiguous, so the honest minimum is only ~10 % below the addressed span.
Decomposing the 34 taps into the 13 real delay elements (MEASURED,
`element_decomposition` in the JSON):

| element | 48 kHz TYPE 2–5 | 44.1 kHz TYPE 2–5 |
|---|---|---|
| pre-delay | 958 | 880 |
| series allpasses 1–4 | 1,911 / 1,517 / 907 / 361 | 878 / 697 / 417 / 166 |
| loop allpasses A–D | 1,347 / 1,341 / 1,351 / 1,347 | 619 / 616 / 621 / 619 |
| loop delays A–D | 7,165 / 7,615 / 9,755 / 9,991 | 3,291 / 3,498 / 4,481 / 4,590 |
| **total floats** | **45,566** | **21,373** |
| **total bytes** | **182,264** | **85,492** |
| addressed span (bytes) | 186,208 | 89,436 |
| plugin's allocation (bytes) | 262,144 | 262,144 |

Shorter types are much cheaper: 48 kHz TYPE 0 is 26,856 B and TYPE 1 is
72,784 B. **But the compile-time budget must cover the worst case**, and the
project's rule is that recall must be correct for any preset value, so:

> **ENGINE B REVERB LINE BUDGET, 48 kHz: 49,406 floats = 197,624 B**
> (45,566 for TYPE 2–5 plus the 3,840-sample maximum PRE DELAY extension).

Split for placement:

| group | floats | bytes | where |
|---|---|---|---|
| pre-delay (max) + 4 series allpasses + 4 loop allpasses | 14,880 | **59,520** | internal SRAM |
| 4 long loop delays | 34,526 | **138,104** | **PSRAM** |

**Plain answer to the question asked: no, it cannot fit internal SRAM.** With a
200 KB total internal budget on a 512 KB part, a 182–198 KB reverb leaves
nothing for the eight voices, the chorus, the delay, the stack and the audio
buffers. The four long loop delays must go to PSRAM. Nothing else has to.

`EB_REVERB_LEN` is currently `8192` (32,768 B) in `engine_b/eb_types.h` — 6.0×
short — and `eb_fx` is 137,012 B, which is smaller than the reverb alone. Both
numbers are wrong and are corrected by this document.

---

## 8. COST

**MEASURED (callgrind, `tools/engineb/fx_reverb_cost.c`, two-point slope so the
warm-up cancels):** with the reverb tank running, `juno_master_render` executes
**1,461.8 x86-64 instructions per sample**; with the run gate forced to 0 so the
tank's arm is skipped and everything else is identical, **1,163.8**. The reverb
arm is therefore **298.0 executed instructions per sample**, 20.4 % of the
master. (Instruction counts: 48,781,102 / 78,016,560 at 20k / 40k samples with
the tank, 42,821,115 / 66,096,573 without.)

**The proposed cheap formulation** is `tools/engineb/fx_reverb_cand.c`: the same
DSP with the single masked line replaced by 13 independent circular buffers,
each advanced by a compare-and-add rather than a modulo, and no LFO branch for
TYPE 0–4. It needs, per sample, about **46 FP arithmetic ops, 30 loads/stores of
line data, and 26 index updates** — one allpass coefficient (0.5) shared by nine
allpasses means nine of the multiplies can be a shift-free constant the compiler
keeps in a register, and every damper is one multiply-add plus a two-term mix.

Measured and modelled cost of that file:

| target | tier | cycles/sample | label |
|---|---|---|---|
| x86-64 host | — | **363.3** (callgrind slope, ρ = 1.65 against 220 static) | MEASURED |
| Cortex-M7 | TCM | 325 … 936 (nom 514) | MODELED |
| ESP32-S3 | internal SRAM | **480 … 1,014 (nom 636)** | MODELED |
| ESP32-S3 | all-PSRAM, uncached | 6,420 … 24,576 (nom 12,456) | MODELED, worst case |

Against the first-guess 500-cycle reverb budget the internal-SRAM nominal is
**1.3× over**; against the whole-engine 3,500 it is 14–29 %. That is the number
to plan with, and the 500 line in `SCOPE.md` should be raised to ~700.

**The PSRAM row is a bound, not a prediction, and it is the one real risk.** It
charges every one of the 198 accesses as an uncached PSRAM access. In the real
layout only the four long delays are in PSRAM, giving **12 PSRAM accesses per
sample across 12 streams, and every stream advances by exactly one float per
sample** — perfectly sequential, so a 32-byte cache line serves 8 consecutive
samples and the expected miss rate is **1.5 misses/sample**, not 12. At a
plausible 40–100 cycles per line fill that is **60–150 extra cycles/sample**,
giving roughly **700–1,850 cycles/sample all in**. That estimate is MODELED and
rests on the 12 streams not conflict-missing against each other and against the
voice working set in the S3's small data cache. **No S3 silicon number exists in
this project.** This is the first thing to measure on the real part; if the
streams thrash, the fallback is to stage each long delay through a small
internal ring written back in bursts, which the sequential access pattern makes
straightforward.

Note the candidate is *slower* than the plugin's own arm on x86 (363 vs 298)
because a 16-bit mask is cheaper than 13 compare-and-add wraps on a machine with
folded memory operands. The trade is deliberate: it buys 80 KB and the ability
to place the long delays separately.

---

## 9. What is in the data files

`docs/engineb/data/fx_reverb.json`

| key | contents |
|---|---|
| `isolation`, `isolation_send_only` | the §1 isolation measurements at both rates |
| `topology_reconstruction` *(in `fx_reverb_pass1.json`)* | the §2 bit-exact result, plus the tap arrays |
| `level_send_10759408_bits`, `level_rate_independent` | §3 |
| `type` | §4 — per rate, per TYPE: 34 taps, 4 cutoffs (float and bits), modulation depth, 8 damper coefficients |
| `time` | §5 summary — mirror-pair equality, distinct-curve count, TYPE dependence |
| `time_rate_independent` | §5 |
| `predelay` | §6 — uniformity, closed-form agreement, shifts at bytes 0/100/127 |
| `memory` | §7 — max tap, minimum line, plugin allocation, power-of-2 line, per rate |
| `element_decomposition` | §7 — the 13 element lengths and the 8 output-tap delays, per rate × TYPE 0/1/2/5 |
| `wipe` | §2 — the 44 unwiped cells |
| `reference_vectors` | per-scenario summary + the coefficient set used |

`docs/engineb/data/fx_reverb.npz`

| key | shape | contents |
|---|---|---|
| `level_send_bits` | (256,) u32 | §3 send LUT, float bits |
| `time_hplp_bits_44100`, `_48000` | (6,256,8) u32 | §5 joint (TYPE, TIME) damper table, float bits |
| `ir_{44100,48000}_type{0,2,5}_in` | (24000,) f32 | the scaled tank input, per sample |
| `ir_…_L`, `ir_…_R` | (24000,) f32 | the engine's reverb stereo pair (cells 101200/101216) |
| `ir_…_g` | (24000,) f32 | the master output gain (cell 101168) those two include |

**How to gate engine B offline against these:** feed `…_in` into the engine B
reverb sample by sample and require the output, multiplied by `…_g`, to null
against `…_L`/`…_R` at ≤ −100 dB per `docs/trackb/ACCURACY_STANDARD.md`. The
input vector is supplied rather than regenerated so the gate does not depend on
the chorus or the delay being finished. There is no stochastic term in this
module; the sample-domain null is the whole standard.

---

## 10. Open items for whoever implements this

1. `EB_REVERB_LEN` must become 49,406 floats and be split into 13 named
   elements, with the four long delays in a separately-placed section.
2. TYPE 0 and 1 use shorter tap sets; the buffers still have to be sized for
   TYPE 2–5, but the wrap lengths are per-TYPE at recall time.
3. The 2,756-sample post-recall silence and the linear mute ramp are part of the
   behaviour and will show up in any warm-recall null.
4. Only TYPE 5 modulates. Keep the modulated read on a separate code path so
   TYPE 0–4 pay nothing for it.
5. The 44.1 kHz coefficients are NOT the 48 kHz ones for the damper cutoffs
   (§4) and the input filter, but the send LUT and the whole TIME table ARE
   rate-independent. Do not generalise either way.
6. Measure the PSRAM stream behaviour on real S3 hardware before trusting the
   700–1,850 cycles/sample estimate in §8.
