# ENGINE B — THE CHORUS: behavioural specification (MEASURED, 2026-08-02)

Everything here was executed. The oracle is the sealed port (`libjuno.so`),
driven at the master stage directly through `tools/engineb/fx_chorus_probe.c`,
so the chorus block is observed with a known input signal instead of a note.
`src/` was not changed.

Probes (committed, repeatable):

| file | what it does |
|---|---|
| `tools/engineb/fx_chorus_probe.c` | calls `juno_master_render` with synthetic voice inputs; traces state cells for each sample |
| `tools/engineb/fx_chorus_recon.py` | first look: cell values, ring size, impulse |
| `tools/engineb/fx_chorus_spec.py` | pass 1 — power-on state, byte sweeps, per-patch modes |
| `tools/engineb/fx_chorus_spec2.py` | pass 2 — warmed measurements + independent tap reconstruction |
| `tools/engineb/fx_chorus_spec3.py` | pass 3 — rate table, mix law, noise floor, reference vectors |
| `tools/engineb/fx_chorus_cost.c` | executed-instruction driver for callgrind |

Data: `docs/engineb/data/fx_chorus{,2,3}.{json,npz}` (also in
`scratchpad/engineb/`, which is gitignored — the committed copy is the one to
trust). §9 lists what is in each file.

---

## 0. Two corrections to the brief, before anything else

1. **The FX are NOT the largest remaining piece by executed work.** The brief
   says master_render's 4,774 static instructions exceed the voice path's 3,491.
   Static size is not cost. `docs/engineb/DENSITY.json`, already MEASURED in
   this repo, records **1,306 executed instructions for each sample for the
   whole master (chorus + delay + reverb + output)** against **22,289 for the
   voice path** — the master is 4.3% of the executed total of 30,459. The FX are
   still worth doing well, and the chorus may not be degraded, but they are not
   where the 80x lives.

2. **The chorus arm costs 417 executed x86-64 instructions for each sample**
   (MEASURED, §7). That is one third of the whole master and it is already
   above the first-guess budget of 400 cycles once it is moved to a
   Cortex/Xtensa. The budget line is real, not slack.

---

## 1. Where the chorus is, and proof that the probe reached it

The JUNO-60 chorus is the master's **slot-2 effect, block A**. The routing
integer is cell `11022052` (EFFECT TYPE); its power-on value is **2**
(MEASURED). The chorus arm runs when the routing is 2, 3 or 4.

| cell | meaning | measured behaviour |
|---|---|---|
| `90368` / `90384` | chorus input, L / R | = **12.0 x (sum of the 8 voice samples)** — exact, and exactly linear over amplitudes 0.125 … 2.0 and for a negative input |
| `91728 … 95823` | the BBD ring buffer | 1024 float cells |
| `95824` | ring write index | decrements, masked with 1023 |
| `95828` | ring length | **1024** |
| `91088` / `91104` | chorus block output, L / R | feeds the rest of the master |

**Isolation was verified, not assumed.** At power-on the Wet level (`91232`) is
0, and with it the block output is **bit-identical** to `Dry x input` for every
sample (`isolation_wet0_exact: true` at both 44.1 and 48 kHz). That proves the
whole wet path — line, taps, LFO, noise — enters the output only through the
one term the probe then isolates by setting Dry = 0 and Wet = 1.

---

## 2. The BBD delay line

| property | measured value |
|---|---|
| length | **1024 float cells = 4,096 BYTES**, at 44.1, 48, 88.2 and 96 kHz alike |
| geometry | ONE mono line, shared by both output channels |
| write index | `w = (w - 1) & 1023`, written AFTER the two reads in the same sample |
| written value | the input-filter output x `OnOff x Mute` — **no feedback path exists** |
| taps | two, read at `(w - trunc(-16384 x d) + 1) & 1023` and `+2`, where `d` is that channel's modulated delay time in units of 16384 samples |
| interpolation | **LINEAR** between the two taps |

**The interpolation result is not read off the decompile — it is
reconstructed.** `fx_chorus_spec2.py` keeps its own copy of the ring and the
write index, recomputes both tap indices, both tap values and the fraction from
the traced delay time, and requires them to equal the engine's stored cells bit
for bit:

    4,000 / 4,000 samples: L taps and fraction bit-exact
    4,000 / 4,000 samples: R taps bit-exact
    4,000 / 4,000 samples: linear interpolated value bit-exact

The check has teeth: run in the same place, **nearest-neighbour matches only
74 / 4,000** and **allpass matches only 74 / 4,000** at 48 kHz (232 / 4,000 at
44.1 kHz — the residue is the samples where the fraction is near zero).

So the answer to the question the brief asks is: **linear, two taps, no allpass,
and it is the cheap choice as well as the correct one.**

The maximum delay ever reached is 456 samples at 48 kHz, so **512 cells (2,048
bytes) would be provably sufficient at 48 kHz** — the read never overtakes the
write, and with no feedback nothing else depends on the buffer length. Keeping
1,024 costs 2 KB and removes the argument. Recommendation: keep 1,024 as the
compile-time budget, with a build-time assertion that
`max_delay_samples + 2 < RING`.

---

## 3. The LFO

The LFO is a wrapped bipolar ramp; the modulation is its **absolute value**, so
the waveform is a **triangle**.

    phase[n] = wrap_unit( phase[n-1] + eps[n-1] + rate )
    eps[n]   = (phase[n] < 0) ? -5e-7 : +5e-7       (cell 91456)

`wrap_unit` is `src/juno_dsp.c`'s `juno_wrap_unit` (`x>1 -> fmodf(x+1,2)-1`).

| property | measured |
|---|---|
| power-on phase | **0.0** exactly (cells 90624 / 90640 / 90656 / 90672 all 0 at create) |
| phase range | [-0.9999986, +0.9999995] |
| period | 100,000 samples at 48 kHz; 91,875 at 44.1 kHz |
| **Chorus I rate (EFFECT TYPE 2)** | **0.480 Hz** at every host rate |
| **Chorus II rate (EFFECT TYPE 3)** | **0.820 Hz** at every host rate |
| EFFECT TYPE 4 (flanger) rate | 9.20 Hz |
| triangle check | `(d - min)/(max - min)` vs `abs(phase)`: max deviation **9.2e-6** |
| L / R relationship | second phase = `abs(wrap_unit(phase + 91168))`, `91168 = 1.0` = half a period, so the two channels are in **antiphase**: measured correlation of the two delay trajectories = **-1.0000000** |

The rate cell (`91152`) is the per-sample phase increment, so
`rate_Hz = increment x SR / 2`. It is the ONLY cell that distinguishes Chorus I
from Chorus II.

---

## 4. Delay time and modulation depth

For each channel, in units of 16,384 samples:

    d = base + (abs(phase_channel) x LFO_Depth) x mod_scale + mod_offset
    delay_samples = d x 16384        (tap = trunc, fraction = frac)

`base` is a one-pole smoother running toward the recalled Delay Time
(`91120`), coefficient `91248` (about 6.1e-5 — a 0.34 s time constant). It
converges to the target exactly, so at rest `base = 91120`.

Measured on a **warmed** block (600,000 samples of silence first — pass 1 got
this wrong and measured the startup transient instead):

| host rate | min delay | max delay | excursion | LFO rate |
|---|---|---|---|---|
| 44,100 | 66.15 smp = **1.5000 ms** | 242.5 smp = 5.4999 ms | 176.4 smp = **4.00 ms** | 0.48 Hz |
| 48,000 | 72.00 smp = **1.5000 ms** | 456.0 smp = 9.4999 ms | 384.0 smp = **8.00 ms** | 0.48 Hz |
| 88,200 | 132.3 smp = 1.5000 ms | (from the constants) | 384.0 smp = 4.35 ms | 0.48 Hz |
| 96,000 | 144.0 smp = 1.5000 ms | (from the constants) | 384.0 smp = **4.00 ms** | 0.48 Hz |

The minimum delay is **exactly 1.5 ms at every rate**. The excursion is not.

**⚠ FINDING — the modulation depth at 48 kHz is DOUBLE the depth at 44.1 and
96 kHz.** The scale cell `91472` is `SR_table / 16384`, and the plugin's
prepare table uses `SR_table = 44100` for a 44.1 kHz host but `SR_table =
96000` for 48, 88.2 AND 96 kHz. The excursion in seconds is therefore
`0.004 x SR_table / SR`: 4.00 ms at 44.1 and 96 kHz, **8.00 ms at 48 kHz**,
4.35 ms at 88.2 kHz. This is the plugin's own behaviour, not a port artefact —
`91472` is part of the cold state that `coldstate_ab.py` already proves
bit-identical to the plugin's own `setSampleRate` at all four rates. Engine B
targets 48 kHz, so **engine B must use 8.00 ms, not the 4 ms that a datasheet
or the 44.1 kHz measurement would suggest.** Taking the 44.1 kHz number would
halve the chorus depth — a large, obvious sonic error that a 44.1-only probe
would have shipped.

Depth in pitch terms at 48 kHz: 384 samples over half a period (50,000
samples) = 0.0077 samples per sample = about **13 cents** of vibrato. At
44.1 kHz it is about 6.6 cents.

---

## 5. Signal path, in order

Measured cell by cell from the traced state; every coefficient below is a
prepare constant listed in `data/fx_chorus3.json -> structural_by_rate`.

1. **Input**: `x = (inL + inR) x 0.5`. Both inputs carry `12.0 x` the voice sum.
2. **Input filter**, into the line:
   * two IDENTICAL biquad low passes, direct form 1, `b = 91296, 91312, 91328`
     = `(0.0792, 0.1584, 0.0792)` — a `k x (1, 2, 1)` low pass — and
     `a = 91344, 91360` = `(1.21644, -0.53329)` at 48 kHz;
   * one first-order high pass (DC block): `b = 91376, 91392` =
     `(0.999019, -0.999019)`, `a = 91408` = `0.998038`.
3. **Ring write**: `line[w] = filtered x OnOff x Mute`, then `w = (w-1) & 1023`.
4. **Two tap reads**, linear interpolation (§2).
5. **Output filter**, one per channel: a two-integrator (Chamberlin) state
   variable filter, `f = 91424 = 0.251654`, damping `91440 = 1.538462`. Its
   low-pass output is used. `f = 2 sin(pi fc / SR)` puts fc near 1.9 kHz at
   48 kHz — the BBD reconstruction filter.
6. **BBD noise**: a deterministic generator (`juno_wrap24` fed back through
   `90848 / 90832`) through a 3-tap and then a 5-tap FIR/IIR pair
   (`91600 … 91712`), scaled by `(91584 + abs(phase_channel)) x NoiseLevel`
   and added to that channel's wet signal before the wet gain. `91584 = 0.3`.
7. **Wet gain and mix**:

       wet_c   = WetLevel x (ramp x (svf_c + noise_c))
       out_c   = OnOff x (DryLevel x in_c) + (1 - OnOff) x in_c + wet_c

   `ramp` (cell 90752) is a slew-limited startup gain; it reaches 1.0 and stays
   there. MEASURED: with Wet = 0 the output equals `1.3 x in` bit-exactly;
   halving Wet halves the wet term with **relative error 0.0**; `out(dry+wet)`
   equals `out(dry) + out(wet)` to 4.8e-7 absolute on a signal of RMS 5.5.

---

## 6. Per-patch parameters

| front panel | record | cell | law |
|---|---|---|---|
| EFFECT DEPTH | blob 50 | `91232` Wet Level | 256-entry table, monotone, 0 -> 0.0, 128 -> 0.28296, 255 -> **1.17**; identical at 44.1 and 48 kHz (MEASURED, full 0..255 sweep at both rates) |
| EFFECT TONE | rec 642 | `91200` Noise Level | **linear: `tone x 0.005 / 255`** (0 -> 0, 1 -> 1.9608e-5, 128 -> 0.0025098, 255 -> 0.005); identical at both rates |
| EFFECT TYPE | rec 634 | `11022052` routing | 0 pan, 1 distortion+pan, 2 **Chorus I**, 3 **Chorus II**, 4 flanger, 5 ensemble (block B) |
| Dry Level | — | `91216` | constant **1.3** |

Full 256-entry Wet and Noise tables: `data/fx_chorus.npz -> wet_lut`,
`noise_lut`.

**Chorus I / II / I+II.** Measured over all 64 factory patches with a FRESH
context for each (33 patches are EFFECT TYPE 2, 22 are TYPE 3, 8 are TYPE 5, 1
is TYPE 1): **types 2 and 3 differ in exactly one cell, the LFO rate** — every
other block-A structural cell is bit-identical. There is **no third block-A
constant set** for an "I+II" mode. Type 4 (flanger) overrides four cells (delay
time, LFO rate, LFO phase offset 0, LFO depth 3.0e-4) and type 5 (ensemble)
runs a separate effect in block B, out of the scope of this document.

**⚠ FINDING — an order-dependent recall in the sealed port.** Recalling a
Chorus I patch AFTER a Chorus II patch leaves the LFO rate at the Chorus II
value: measured at both rates, `type2_fresh = 0x37a7c5ac` but
`type2_after_type3 = 0x380f4e2e` at 48 kHz. `src/chorus_recall.c` writes
`91152` only when EFFECT TYPE == 3, so nothing restores it. In the plugin the
value is re-established by prepare, so a host that never changes sample rate
between patch loads would carry the same stale value — whether the plugin does
the same has NOT been checked here and is owed to `plugin_check.py`. Either
way, **engine B must write the LFO rate unconditionally on every recall.**

---

## 7. Cost, MEASURED

Executed x86-64 instructions inside `juno_master_render`, by the two-point
slope method (2,000 and 6,000 samples, so the fixed setup cancels), callgrind:

| configuration | instructions for each sample |
|---|---|
| chorus arm, EFFECT TYPE 2 | **1,299.7** |
| chorus arm, EFFECT TYPE 3 | 1,299.7 (same code) |
| pan arm, EFFECT TYPE 0 | 1,180.7 |
| ensemble arm, EFFECT TYPE 5 | 1,131.7 |
| chorus arm **removed** (a modified copy of master_render.c, `-DEB_NO_CHORUS`, `src/` untouched) | 882.7 |

**Chorus arm = 1,299.7 - 882.7 = 417.0 executed instructions for each sample
(MEASURED).** The two independent differences agree: 417 (against no arm) minus
298 (pan arm against no arm) = the 119 measured directly between the chorus and
pan arms.

Static composition of the arm (STATIC, counted from the 183 lines of
`src/master_render.c` that form it): 90 multiplies, 83 adds or subtracts, 2
`fabs`, 4 wraps, 2 `fminf`, 137 float loads from the flat state block, 31 float
stores, and **34 pure register-shift moves** that exist only because the port
keeps its delay-line history in scattered cells of an 11 MB block.

---

## 8. A cheap formulation for a Cortex-class FPU, and its cost

Nothing needs to be approximated. The whole algorithm is 4 KB of ring plus
about 40 words of state; the port's cost is dominated by addressing an 11 MB
flat block and by the 34 shift moves, both of which disappear for free in a
compact rewrite.

    struct eb_chorus {
        float line[1024];        /* 4,096 B — the only large allocation */
        int   w;                 /* write index, decrements, & 1023     */
        float phase, eps;        /* LFO ramp + the +/-5e-7 term         */
        float base;              /* smoothed delay time                 */
        float x1, x2, y1a, y2a, y1b, y2b, hz1, hy1;   /* input filter   */
        float svf[2][2];         /* the two output SVFs                 */
        float nz[8];             /* the BBD noise generator + filters   */
        float rate, depth, mod_scale, mod_off, dry, wet, noise, ramp;
    };                           /* about 4,300 B in total              */

Per sample, counted as essential arithmetic:

| stage | float ops |
|---|---|
| input mix + 2 biquads + DC block | 23 |
| LFO ramp, 2 wraps, 2 absolute values | 10 |
| 2 modulation terms | 6 |
| delay-time smoother + slew/error chain | 14 |
| ring write, index | 1 store |
| 2 taps: convert, 2 masked loads, fraction, 2 lerps | 16 |
| 2 output SVFs | 10 |
| BBD noise generator + its 2 filter sections | 30 |
| wet gain and mix, 2 channels | 10 |
| **total** | **about 120 float ops, 4 loads, 1 store, about 10 integer ops** |

**Estimate (MODELED, from the MEASURED 417 host instructions and the op count
above; no silicon number exists for the ESP32-S3 anywhere in this project):**

| target | cycles for each sample |
|---|---|
| a direct port of the arm as written (flat state, shift moves) | 460 – 900 |
| the compact formulation above | **170 – 260** |
| budget in `docs/engineb/SCOPE.md` | 400 |

The compact form fits with room; the transcription as written does not. This
number is MODELED and must be replaced by a `cost.py measure` run as soon as
the module exists — that is the next step, not a later one.

**Do not remove the BBD noise generator to save its 30 ops.** MEASURED: with
the default EFFECT TONE its contribution is RMS 1.32e-4 against a dry RMS of
5.51, which is **-92 dB** — above the -100 dB null target of
`docs/trackb/ACCURACY_STANDARD.md`. Dropping it would fail the standard on its
own. Its cost is linear in the tone byte only through a gain, so there is no
cheaper correct version; it is a fixed 25% of the module.

**Do not "simplify" `juno_wrap_unit`.** The reachable LFO phase only ever
exceeds 1 by about 2e-5, so `x - 2` looks equivalent to
`fmodf(x + 1, 2) - 1`. It is not obviously so: `x + 1` near 2.0 rounds at an
ulp of 2.4e-7 while `x - 2` is exact, so the two can differ in the last bit,
and the second wrap (`phase + 1`) crosses the same boundary every period. This
is the same shape as the fmodf replacement that this project already got wrong
on 8,388,608 of 2^32 inputs. If a replacement is wanted, it must be proven by
exhaustive comparison over the reachable range and recorded as such.

---

## 9. What is in the data files

`docs/engineb/data/fx_chorus.json` — pass 1. Power-on block-A and auxiliary
cells with bit patterns at 44.1 and 48 kHz; the isolation results; the 0..255
EFFECT DEPTH and EFFECT TONE sweeps summarised; per-patch mode grouping.
**Its `delay_samples`, `wet_impulse_*` and `interp_*` entries are the DEFECTIVE
pass-1 versions** (unwarmed, and a tautological interpolation check) — kept for
the audit trail, superseded by `fx_chorus2.json`. `fx_chorus.npz`: `wet_lut`,
`noise_lut` (256 entries each), the pass-1 traces.

`fx_chorus2.json` / `.npz` — warmed delay range, LFO period and rate, the
independent tap reconstruction with its teeth test, the warmed wet impulse
responses (`ir_wetL_*`, `ir_wetR_*`, 4,096 samples), the phase and delay
trajectories over a full LFO period (`phase_*`, `delayL_*`, `delayR_*`), the
fresh-context mode table and the stale-LFO-rate finding.

`fx_chorus3.json` / `.npz` — the structural constants at 44.1, 48, 88.2 and
96 kHz with the derived delay, excursion and rate in samples, ms and Hz; the
per-EFFECT-TYPE table; the mix-law linearity results and the noise floor; and
**the reference vectors**: for `type2_chorusI` and `type3_chorusII` at 48 and
44.1 kHz, after 600,000 warm samples and a factory recall, 8,192 samples of
input (`ref_in_*`), the chorus input cell (`ref_chorusin_*`), both block
outputs (`ref_outL_*`, `ref_outR_*`) and the modulated delay time in samples
(`ref_delayL_*`). Engine B's chorus is gated against `ref_outL/R` — the
starting LFO phase and ring write index needed to reproduce them are recorded
in `reference_vectors[key]`.

---

## 10. Open, and owed

* No cross-check against the PLUGIN was run for this module.
  `tools/engineb/plugin_check.py` is the authoritative comparison and should be
  pointed at the block-A structural cells and the four rate arms, above all at
  the doubled 48 kHz modulation depth of §4 and the stale LFO rate of §6.
* The ESP32-S3 cycle figure is MODELED with no silicon anchor. Measure it.
* The BBD noise generator's own recursion (`90832 / 90848`, `juno_wrap24`) is
  described here by its role and its measured level, not by an executed
  per-sample law. It is deterministic and closed, so it can be specified
  exactly; that is a small separate piece of work before the module is written.
* EFFECT TYPE 5 (ensemble, block B) and EFFECT TYPE 4 (flanger) are not
  specified here. Eight factory patches use type 5.
