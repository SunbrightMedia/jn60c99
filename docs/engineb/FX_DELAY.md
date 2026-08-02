# ENGINE B — THE DELAY, MEASURED

2026-08-02. Every number here was EXECUTED against the sealed engine
(`libjuno.so`). Nothing is read off the decompiler and reported as fact.
`src/` was not modified.

## 0. Headline

* The DELAY TYPE 0 block of `src/master_render.c` was transcribed literally and
  **nulled BIT-EXACT (0 differing samples, 0.000e+00 RMS error) against the
  sealed engine on 20 non-vacuous configurations** — 2 host rates x 2 patches x
  5 parameter sets, 6,000 samples each. That transcription is the specification.
* The wet path was live in 16 of those 20 (the other 4 are the DELAY-OFF
  controls). Four earlier "passes" were VACUOUS and were thrown away — see §8.
* **The high-cut filter TOPOLOGY switches on sample rate.** Cell 102448 is 1.0
  only at 44,100 Hz and 0.0 at 48,000 / 88,200 / 96,000 / 192,000. At the
  ESP32-S3 target rate the DF-I biquad branch is DEAD and only the 2-pole
  state-variable branch runs.
* **Maximum delay length at 48 kHz is not 800 ms.** Manual mode maxes at 800 ms
  = 38,400 samples. Tempo sync at the recall-default 128 BPM reaches 1,875 ms =
  **90,000 samples = 360,000 B/channel, 720,000 B stereo**, and scales as 1/BPM
  with no clamp. `EB_DELAY_LEN` is currently 12,000 — 3.2x short of the manual
  maximum and 7.5x short of the synced one.
* A candidate cheap formulation is written and costed: **MODELED 134 cyc/sample
  on the S3 (band 86..342)** against the first-guess delay budget of 300.

## 1. How the measurement was done, and why it is trustworthy

The delay is not reachable from the voice inputs of `juno_master_render`.
MEASURED: cell 84544 ("input crossfade") is 1.0, so
`v35 = v33 + 84544*(v30 - v33)` collapses to `v30 = 84672 * 84560`, i.e. the FX
chain's input is the PREVIOUS sample's slot-2 effect return (cell 84672), not
the voice sum. Feeding `a2[0]` therefore drives the delay with exactly zero
signal. A probe that did that would have "proved" whatever it liked.

The working injection point is **cell 84672 / 84704**, poked immediately before
each `juno_master_render` call. ISOLATION VERIFIED, not assumed:

    injected 1.0 at n=0 -> cell 101104 (v36, the FX-chain input) = 0.5760990381
    cell 101104 at n=1..5 = exactly 0.0        (a true unit impulse)
    delay stage output (cell 102320) = exactly 0.0 until n=6625

The delay's own output is read at **102320 / 102336** (`v414` / `v415`), before
the slot-2 effect and reverb, so no other FX contaminates it.

Harness: `scratchpad/engineb/dly.py` (rig), `nt3.py` (null), `teeth.py`,
`mkvec.py`, `p2/p13/p14/p16.py` (sweeps). Copies of the two C files are in
`docs/engineb/data/`.

## 2. Structure (PROVEN — this is the bit-exact null)

Per sample, both channels share one delay-time smoother and one mute fade.

### 2.1 Delay-time smoother
    if (target != last_target) step = target - prev_smoothed
    last_target = target
    d  = fabsf(step) * SLEW
    sm = (target - prev_smoothed > 0) ? min(prev_smoothed + d, target)
                                      : max(prev_smoothed - d, target)
It is a CONSTANT-TIME glide (the rate is set by the distance latched when the
target changed), not a constant-rate one. `SLEW` = cell 102784, a 2-class
rate constant: **0.000725624 at 44,100** (glide 1,378 samples), **0.000333333
at 48,000 and above** (glide 3,000 samples).

### 2.2 Mute fade
Fade cell 102288 moves by +/-1/128 per sample, clamped to [0,1], then is
multiplied by MUTE (102592). The value APPLIED to the tap is the previous
sample's (cell 102304), i.e. the fade is one sample late. The up/down decision
compares `(1/16384 + fade) >= previous smoothed delay time` — a cross-domain
comparison that is almost always false, so the fade sits at its clamp. It is
transcribed verbatim; do not "fix" it.

On an effect-routing change (cell 11022348 non-zero) the fade is forced to 0,
which is the click suppressor.

### 2.3 Read
    D    = (int)(smoothed * -16384.0f)          /* negative; truncates to 0 */
    frac = smoothed * 16384.0f - (float)(int)(smoothed * 16384.0f)
    t1   = ring[(w - D + 1) & (len-1)]
    t2   = ring[(w - D + 2) & (len-1)]
    tap  = (frac*t2 - frac*t1 + t1) * fade_applied
The write index DECREMENTS, so a positive offset reads backwards in time.
Interpolation is LINEAR between two adjacent taps.

### 2.4 Input filter — HIGH CUT, two topologies
Path A, DF-I biquad, cells 102368/102384/102400/102416/102432:

    yA[n] = b0*x[n] + b1*x[n-1] + b2*x[n-2] + a1*yA[n-1] + a2*yA[n-2]

Path B, 2-pole state-variable, cells 102464 (g) / 102480 (r = 1.414427161):

    t   = x - r*s1;   s1 += g*(t - s2);   s2 += g*s1_old;   yB = s2

Selected by cell 102448: `u = yB + 102448*(yA - yB)`. MEASURED 102448 = 1.0 iff
the host rate is 44,100, else 0.0 — for all 15 HIGH CUT bytes and 3 patches, at
44,100 / 48,000 / 88,200 / 96,000 / 192,000. (This agrees with the already
proven `src/juno_prepare.c:159`.)

Bypass by cell 102496: `w = x + 102496*(u - x)`. MEASURED 102496 = 1.0 for
HIGH CUT bytes 0..13 and **0.0 at byte 14** — byte 14 is "filter fully open".

### 2.5 Ring input
    ring_in = (w*ON + fbtap*FB) * MUTE
ON = 102576, FB = 102560, MUTE = 102592.

### 2.6 Loop damping filter (three one-poles, applied to the READ tap)
    d1 = 102624*(tap - lp)                 [102624 = 1.0 in every measured state]
    lp += 102608*(tap - lp)                                     LF DAMP FREQ
    e  = d1 - 102640*lp                                         LF DAMP amount
    d2 = e - hp
    hp += 102656*d2                                             HF DAMP FREQ
    f  = 102688*hp - 102672*d2             [102688 = 1.0 in every measured state]
    g  = f - dc
    dc += 102704*g                         [rate constant: 0.007836152 @44.1k,
    fbtap = g                               0.003599740 @48k and above]
The 102704 pole is a ~27 Hz DC blocker at 48 kHz.
**The output tap is `tap`, taken BEFORE this filter. The damping is in the
feedback loop only.**

### 2.7 Output
    out = (ON ? dry*x : x) + tap * wet
With ON = 0 the delay is a straight bypass (`dry` is skipped entirely).

## 3. The parameter laws (MEASURED, every byte, 44,100 and 48,000)

Full tables: `docs/engineb/data/fx_delay.json`.

| parameter | host idx | range | cell | law |
|---|---|---|---|---|
| DELAY TIME | 59 | 0..255 | 102352 | see §4 |
| DELAY LEVEL | 58 | 0..255 | 102528 wet, 102576 on | wet = b/255; on = (b >= 2) |
| DELAY FEEDBACK | 61 | 0..255 | 102560 | f32(b/255) * f32(0.9); b=0 -> 0.0, b=255 -> 0.9 |
| DELAY DIRECT LEVEL | 63 | 0..255 | 102512 | b/255 |
| DELAY HIGH CUT | 62 | 0..14 | 7 cells | table, RATE-INDEPENDENT (identical at both rates) |
| DELAY LF DAMP | 64 | 0..81 | 102640 | table, rate-independent, 1.0 -> 0.01 log-spaced |
| DELAY HF DAMP | 66 | 0..81 | 102672 | same table as LF DAMP |
| DELAY LF DAMP FREQ | 65 | 0..10 | 102608 | table, RATE-DEPENDENT |
| DELAY HF DAMP FREQ | 67 | 0..13 | 102656 | table, RATE-DEPENDENT |
| DELAY TAP TIME | 60 | 0..100 | — | **NO CELL MOVES. See §7.** |

### The OFF-gate — the port's claim, verified and CORRECTED
`src/delay_recall.c` documents "an OFF-gate when DELAY LEVEL < 2". MEASURED,
sweeping DELAY LEVEL over {0,1,2,3,255} with FEEDBACK pinned at 200, at both
rates, in DELAY TYPE 0:

| LEVEL | wet 102528 | fb 102560 | on 102576 | mute 102592 | dry 102512 |
|---|---|---|---|---|---|
| 0 | 0.000000 | 0.705882 | **0.0** | 1.0 | 1.0 |
| 1 | 0.003922 | 0.705882 | **0.0** | 1.0 | 1.0 |
| 2 | 0.007843 | 0.705882 | **1.0** | 1.0 | 1.0 |
| 255 | 1.000000 | 0.705882 | 1.0 | 1.0 | 1.0 |

So in TYPE 0 the gate is on cell **102576 only**; FEEDBACK is NOT zeroed. The
audible effect of the gate is §2.5 (no signal enters the line) and §2.7 (the
output becomes a straight bypass). This matches `delay_recall.c:515` and NOT
the TYPE-1 arm at line 360, which does additionally zero 102560 — the two arms
differ and the file's header comment does not say so.

### Wet/dry mix, stated plainly
There is no single "mix" control. `out = dry_path + tap*wet` where the dry path
is `DIRECT LEVEL/255 * x` when the delay is on and `x` when it is off. Both are
independent 0..1 gains; the sum is not normalised and can exceed the input.

### HIGH CUT table (rate-independent; b0,b1,b2,a1,a2 | svf_g | bypass)
Bytes 0..10 are all-pole (b1 = b2 = 0); bytes 11..13 become a proper biquad
with b1 = 2*b0; byte 14 duplicates byte 13's coefficients but sets the bypass
switch, so the filter is out of circuit. `svf_r` is 1.414427161 for every byte
(Butterworth Q).

## 4. Delay time and the MAXIMUM LENGTH

    coeff(102352) = (f32(H) * ms) * (1/16384000) - (2/16384)
    delay in samples = coeff*16384 + 2 = H*ms/1000 - 2   (then +1 from the read)

MEASURED over all 256 bytes at both rates, manual mode: the byte maps to an
INTEGER millisecond table spanning **10 ms .. 800 ms**, rate-independent
(max deviation from an integer ms: 7.1e-05 at 44.1k, 4.1e-05 at 48k).

MEASURED, tempo sync (TEMPO SYNC = 1), sweeping the byte and pushing host tempo:

| BPM | ms | samples @48k |
|---|---|---|
| 240 | 1000.0 | 48,000 |
| 128 (recall default) | 1875.0 | **90,000** |
| 60 | 4000.0 | 192,000 |
| 40 | 6000.0 | 288,000 |
| 20 | 12000.0 | 576,000 |

The synced time is `4 beats * 60000 / BPM` at the top division and is NOT
clamped. The plugin's own ring is 524,288 samples per channel (MEASURED at cells
2199956 / 4297124), so the PLUGIN ITSELF wraps below about 22 BPM at 48 kHz.

**MAXIMUM DELAY LENGTH IN BYTES AT 48 kHz** (float32, per channel / stereo):

| bound | samples | B/channel | B stereo |
|---|---|---|---|
| manual max, 800 ms | 38,400 | 153,600 | 307,200 |
| manual, rounded to a power of two | 65,536 | 262,144 | 524,288 |
| tempo sync 1/1 @128 BPM | 90,000 | 360,000 | 720,000 |
| tempo sync 1/1 @128 BPM, pow2 | 131,072 | 524,288 | 1,048,576 |
| the plugin's own allocation | 524,288 | 2,097,152 | 4,194,304 |

Against a 200 KB internal budget on a 512 KB part, **the delay line cannot live
in internal SRAM at any of these bounds. It is the allocation that forces
PSRAM.** `EB_DELAY_LEN` must stay a compile-time constant so the array can be
moved without touching the DSP, exactly as SCOPE.md requires. Today's 12,000
(250 ms) is a placeholder and is too short — capping the delay at 250 ms would
be a degradation of the FX, which CONSTRAINTS.md forbids.

## 5. Proposed cheap formulation (PROPOSED — costed, NOT yet nulled)

`docs/engineb/data/eb_delay_cheap.c`. Simplifications, each with its
measurement:

1. **Drop the DF-I biquad entirely at 48 kHz.** Cell 102448 = 0.0 at every rate
   except 44,100 (§2.4). Saves 5 multiplies, 4 adds and 4 state words per
   channel. RISK, stated: the biquad's state still evolves in the plugin even
   when its output is unused; that state can only become audible if 102448
   changes, which requires a host sample-rate change. Engine B is 48 kHz only.
2. **Drop the 102624 and 102688 multiplies** — 1.0 in every measured state.
3. **Branch on 102496 / 102576 / 102592** — measured to take only 0.0 and 1.0,
   so the two crossfades become selects.
4. Keep linear interpolation, the constant-time glide, the one-sample-late
   fade, and all three loop one-poles: all are load-bearing for the null.

MEASURED cost, `tools/engineb/cost.py measure`:

| target | cyc/sample nominal | band | vs 3,500 budget |
|---|---|---|---|
| ESP32-S3 (TARGET) | **134** | 86 .. 342 | 3.8% |
| Cortex-M7 | 152 | 78 .. 487 | 4.3% |

MODELED, not silicon. Static counts on the S3: 148 instructions, 45 FP
arithmetic, 40 FP memory, 27 integer ALU, 8 branches, **0 libm, 0 softfloat**.
The delay is arithmetically cheap; its cost is memory. Two ring reads and one
ring write per channel per sample = 6 PSRAM accesses/sample. At the measured
Daisy SDRAM tier (78.7 extra cycles per 4-byte access) that alone would be 472
cyc/sample — **so if the line goes to PSRAM the delay becomes memory-bound and
the 300-cycle budget breaks.** The read pair is adjacent, so a 16-byte burst
cache line covers both taps; the write is a separate stream. This is the next
thing that needs measuring, and it must be measured, not argued.

## 6. Reference vectors

`docs/engineb/data/fx_delay_vectors.npz` — 16 scenarios (8 configurations x
44,100 and 48,000), 6,000 samples each. Per scenario, two float32 [6000,2]
arrays:

* `<rate>_<name>_in`  — the exact `v36`/`v38` the sealed engine saw (cells
  101104 / 101120), i.e. the delay stage's stereo input.
* `<rate>_<name>_out` — the sealed engine's delay stage output (cells
  102320 / 102336).

Scenarios: `A_short_fb200`, `B_min_fb250` (shortest time, feedback 250),
`C_hc0_damped` (darkest high cut + both damps), `D_hc14_open` (high cut
bypassed), `E_hc11_biq` (a true-biquad byte), `F_off_level0`, `G_off_level1`
(both sides of the OFF gate), `H_impulse` (unit impulse, direct level 0).
Each was preceded by 9,000 idle samples so the fade and time smoothers are
settled; the vectors therefore do NOT cover the smoother transients, which is a
stated coverage hole.

`docs/engineb/data/fx_delay_meta.json` carries, per scenario, the parameter
settings, all 26 coefficient cell values, the delay length in samples and the
ring length. An offline implementation can be gated with no oracle present.

`docs/engineb/data/fx_delay.json` carries the full per-byte parameter sweeps at
both rates plus the cell map.

## 7. DELAY TAP TIME 1178 — the known INFERRED gap, re-measured

Sweeping host parameter 60 (DELAY TAP TIME) over its whole range 0..100 at both
rates and reading `{102352, 102560, 102528, 102512, 102368, 102640}`:
**1 unique result over all 101 bytes.** The port freezes it at 50 and nothing
observable depends on it, so nothing in this specification depends on it
either. It stays INFERRED. If it is ever wired it will affect DELAY TYPE 1
(the dual-tap type), which this document does not cover.

## 8. What this document does NOT cover, and the traps hit on the way

* **DELAY TYPE 1..5 only partly.** The bit-exact null is TYPE 0. The decompiled
  block used here is entered for `v39 == 0`; `v39 == 1` (dual delay) is a
  separate block at `master_render.c:888`, and TYPES 2/3 (slot-1 chorus) and 5
  (slot-1 reverb) are different code again. A first null attempt on TYPE 1
  failed at +584 dB — correctly, because the wrong block was being compared.
* **VACUOUS PASSES, caught.** The first null run reported four `-999 dB`
  bit-exact passes. They were worthless: the patch's delay time was 16,512
  samples and the run was 6,000, so the tap never arrived and the "delay under
  test" contributed nothing. Every scenario in §6 now records its wet-tap RMS
  and 16 of 20 are non-zero.
* **TRUNCATED TRANSCRIPTION, caught by the null.** Two omitted lines (the right
  channel's ring write-index update) produced a clean-looking **-10.45 dB**
  failure, not a crash. That is the null doing its job.
* **Teeth, MEASURED.** Injecting a single-ULP error into the reference's
  coefficients: lf_damp -151.05 dB, svf_g -142.80 dB, feedback -149.99 dB,
  wet -148.76 dB, dc_g -155.32 dB — all detected against an unmutated
  0.000e+00. **Two mutations were NOT detected and this is stated, not hidden:**
  a 1-ULP change to the time TARGET (102352) is absorbed by the smoother's
  min/max clamp and by the integer truncation of the tap index, and a 1-ULP
  change to `ring[0]` lands in a slot the 4,000-sample window never reads back.
  Neither is a hole in the spec; both are limits of that particular probe.
* **Smoother transients are ungated** (§6).
* The plugin's `84544 == 1.0` input crossfade (§1) means the delay is fed by
  the slot-2 effect return, one sample late. Engine B's FX chain ORDER must
  reproduce that. It is stated here because it was found here; it belongs to
  the chain-level spec, not the delay.
