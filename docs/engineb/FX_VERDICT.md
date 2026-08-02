# ENGINE B — FX VERDICT

Date 2026-08-02. Target: ESP32-S3, **one core**, 240 MHz, 48 kHz, 3,500
cyc/sample for the whole engine, 8 voices, all FX.

Every number carries a label. `MEASURED` = executed and counted.
`MODELED` = `tools/engineb/cost.py` converting a MEASURED host instruction
density plus a MEASURED S3 static instruction count into S3 cycles; **no S3
silicon has ever been measured in this project.** `STATIC` = counted from the
object, not executed.

---

## 1. Per effect

| effect | accuracy (MEASURED, `null_b.py`, 30 scenarios, 17 idle-prefix) | S3 cyc/sample (MODELED, nominal + band) | memory, bytes (STATIC, `sizeof`) |
|---|---|---|---|
| **chorus** (`eb_chorus.c`) | **30/30 EXACTLY 0** — 0 differing samples, not "below −100 dB". 19 of the 30 provably reach the arm (they diverged loudly before the fix). | **537** (329 … 1,434) = 15.3 % of 3,500 | **4,412** = 4,096 BBD line + 160 state + 156 coeff. 2,208 B with `-DEB_CHORUS_RING=512`, provably sufficient at 48 kHz (max delay MEASURED 456). |
| **delay**, TYPE 0 only (`eb_delay.c`) | **30/30 EXACTLY 0**. 15 of 30 provably carry it (a real smoother bug failed exactly those at −33.9 dB). Plus 14/14 EXACTLY 0 on branches no factory patch reaches. | **207** (132 … 529) for the 48 kHz build (`EB_DELAY_BIQUAD=0`); 235 for the 44.1 kHz build. Internal-SRAM tier. **PSRAM tier: ~387 / 567 / 927** at 30/60/120 cyc/access, 6 ring accesses/sample. | **524,400** at `EB_DELAY_LEN` 65536 (manual 800 ms). **1,048,688** if tempo sync 1/1 @128 BPM is honoured — currently the shim aborts instead of wrapping. |
| **reverb** (`eb_reverb.c`) | **30/30 EXACTLY 0**. Teeth PASS 10/10; a one-sample tap error fails **27/27** at −31.8 dB, so the tank is audible in 27 scenarios and the zero means something. | **812** (614 … 1,297) internal SRAM = 23 %. **~900** realistic with the long delays in PSRAM (16 sequential accesses/sample ≈ 2 line fills). All-PSRAM uncached bound 15,830 — a bound, MODELED-UNVALIDATED. | **199,640** = 61,192 internal rings + 138,104 long loop delays + 344 scalars. |

Accuracy achieved, plainly: **no effect has spent one bit of the −100 dB error
budget.** All three are bit-identical to the sealed oracle. The dB figures worth
quoting are the *teeth*, not the results: reverb wet ×(1+6.25e−5) = −100.5 dB
(passes), ×(1+6.25e−4) = −80.5 dB (fails); delay 1 ULP on `wet` = −146.7 dB.

### Not gated, and it matters
- Delay TYPES 1…5 are **not written**.
- No null scenario selects **REVERB TYPE 5**, so its modulated pre-delay is
  correct only by the split proof's construction.
- **EFFECT TYPE 4 (flanger)** shares the chorus arm; no factory patch reaches it.
- None of the three has been checked against the **plugin** (`plugin_check.py`).
  They are proven against frozen `src/`, which is a proxy.

---

## 2. FX total, and what is left

FX only, S3 nominal, all-internal tier (MODELED):

```
  537  chorus
  207  delay   (48 kHz build)
  812  reverb
------
1,556 cyc/sample   =  44.5 % of the 3,500 whole-engine budget
```

Against the first-guess sub-budgets (400 + 300 + 850 = 1,550): **+6 cycles,
0.4 % over.** The FX are, to within noise, exactly on their allowance. Band:
1,075 … 3,260.

Realistic PSRAM placement (delay at the 60 cyc/access tier, reverb ~900):
537 + 567 + 900 = **2,004 cyc/sample = 57 % of the whole budget.**

Now add the one other MEASURED-shaped whole-engine cost the brief names:

```
1,188  envelopes, 8 voices (MODELED from 81 MEASURED instructions)
1,556  all FX
------
2,744 cyc/sample   =  78.4 % of 3,500
  756 cyc/sample   left for the DCO, the VCF, the VCA/HPF, both CV blocks,
                   the decimator, the noise SVF and the voice summing
```

**756 is what remains. Here is what has to fit in it, already measured:**

| block | S3 cyc/sample (MODELED, 8 voices) |
|---|---|
| DCO | **17,413** |
| VCF ladder | **4,273** |
| VCA + HPF | **1,543** |
| VCF cutoff CV | **686** |
| pitch/PWM mod CV | **474** |
| decimator + noise SVF + CV cond. + summing (ESTIMATE, not written) | ~2,250 |
| **subtotal** | **~26,639** |

756 available. ~26,639 required. That is **35× short**.

---

## 3. Does 8 voices plus ALL FX fit 3,500 cyc/sample on one S3 core?

**No. Not close. Not by any margin that optimisation reaches.**

```
  2,744  envelopes + all FX
 26,639  rest of the voice path (24,389 MEASURED-shaped + ~2,250 ESTIMATE)
-------
 29,383  cyc/sample required   [MODELED]
  3,500  budget
-------
 25,883  cyc/sample SHORTFALL   =  8.4x over budget
```

Optimistic end of every band summed is still ~17,400 — **5× over**. The
pessimistic end is ~55,000.

**The FX are not the problem, and the brief's premise that they are the largest
remaining piece is wrong — as the chorus extraction already reported.** The FX
are 1,556 of 29,383, i.e. **5.3 % of the engine's cost**. This repo's own
`DENSITY.json` records 1,306 executed instructions/sample for the whole master
against 22,289 for the voice path. `master_render.c` being 4,774 static
instructions is a static-size fact about six mutually exclusive EFFECT TYPE arms,
only one of which runs.

### What would have to change, in the user's stated priority order

1. **Use the second core.** Costs the user nothing sonically — splitting voices
   4+4 changes no sample. Gives 7,000 cyc/sample. **Still 4.2× short.** It is
   necessary and it is nowhere near sufficient. Needs a lock-free hand-off and
   the free-running lockstep rule enforced across the split.
2. **Attack the DCO — 17,413, 59 % of the whole engine cost, one module.** It is
   the single largest item by a factor of four. It has never been optimised; it
   was transcribed and nulled. Nothing else on this list is worth doing first.
3. **Lower the VCF 4× oversampling** (4,273). MEASURED-STATIC floor is 1,872
   float ops/sample before any memory access, so layout work cannot touch it;
   the deletion of all 39 per-sample cell shifts and the 768 B → 172 B state cut
   did not move it. Dropping oversampling requires **re-deriving the cutoff law
   and the decimator and nulling the result** — it is the first change that
   spends error budget, and it must be measured against −100 dB, not assumed.
4. **A faster part, or a lower sample rate.** Both are outside the stated scope
   and both are listed here because 8.4× is not an optimisation gap.
5. **6 voices — absolute last resort, and it does not save the day.** The
   brief's "~5 %" figure is the **SILICON measurement of the sealed port**, whose
   91 % idle floor made polyphony irrelevant (4 voices = 84,560 vs 8 voices =
   93,288 cyc/sample, 9 %). **Engine B is different and this must not be
   conflated**: it skips silent voices properly, so its cost is close to linear
   in sounding voices. 6 voices cuts the ~26,639 voice path to ~19,979 and the
   total to ~22,724 — **still 6.5× over.** It buys 23 %, not 5 %, and it is still
   not enough. Do not spend the user's one permitted compromise on it.

**Blunt summary: no combination of the permitted compromises fits this engine on
one core, or on two. The DCO has to come down by roughly an order of magnitude,
and until it does every other number here is decoration.**

---

## 4. Memory

| item | bytes (STATIC) | placement |
|---|---|---|
| chorus BBD line | 4,096 (2,048 at `RING=512`) | internal |
| chorus state + coeff | 316 | internal |
| reverb pre-delay + 8 allpasses + scalars | 61,536 | internal |
| reverb 4 long loop delays | **138,104** | **PSRAM** |
| delay ring | **524,288** | **PSRAM** |
| delay state | 112 | internal |
| **FX total** | **728,452** | |
| of which internal | **66,060** | 33 % of the 200 KB internal budget |
| of which PSRAM | **662,392** | |

**Must live in PSRAM: the delay ring (524,288 B) and the reverb's four long loop
delays (138,104 B).** Both are the last members of their structs and both lengths
are compile-time, so the move is a linker section, not a DSP edit — that
requirement from SCOPE.md is met.

Facts that force this and cannot be argued away:
- The reverb at 48 kHz is **2.08× longer** than at 44.1 kHz (max tap 46,551 vs
  22,358). The plugin's own rate law. No saving available.
- The four shrink levers (44.1 kHz tank, TYPE 0 only, frozen PRE DELAY, 16-bit
  line) are all **refused**: each changes the sound, and the 16-bit line fails
  −100 dB by construction.
- Tempo sync 1/1 at the recall-default 128 BPM needs **1,048,576 B** of delay
  ring, and the law is unclamped as 1/BPM. Currently unimplemented; the shim
  aborts.
- `eb_fx`'s recorded 137,012 B is **smaller than the reverb alone** and
  `EB_REVERB_LEN` (8,192) was 6.0× short. Both are superseded by the numbers
  above.

---

## 5. What is still unproven, and the exact next measurement

**Unproven, ranked:**

1. **Every S3 cycle number in this document is MODELED. No ESP32-S3 silicon has
   ever been measured by this project.** The bands are 3–4× wide. The port's own
   history says this is where projects get it wrong: the Daisy silicon came in
   **2.2× worse than the worst case modeled**.
2. **PSRAM access latency is MODELED-UNVALIDATED.** The delay's cost swings
   207 → 927 cyc/sample across the assumed 30/60/120 cyc/access, and the
   reverb's all-PSRAM bound is 15,830 against an assumed-realistic ~900. Two
   thirds of the FX memory lives there. This single unmeasured constant can move
   the FX total from 1,556 to over 3,000.
3. **No plugin cross-check.** All three effects are nulled against frozen `src/`.
   `plugin_check.py` is the authority and has not been run on any of them.
4. Uncovered paths: delay TYPES 1…5, REVERB TYPE 5, EFFECT TYPE 4 flanger,
   delay tempo sync.
5. The ~2,250 unwritten voice-path figure is an ESTIMATE with a 1,080 … 5,900
   band.

**The exact next measurement — do this before anything else is written:**

> Flash an ESP32-S3 and run `eb_chorus_process`, `eb_delay_process` and
> `eb_reverb_process` in a timed loop against `esp_cpu_get_cycle_count()`
> (**with a wrap check — the port's 32-bit counter with no wrap check made every
> hardware number wrong by 7×**), 48 kHz, at least 100,000 samples, three
> placements each: all-internal, long lines in PSRAM cached, long lines in PSRAM
> uncached. Report cycles/sample per module per placement.

That one run replaces items 1 and 2, converts every MODELED figure in this
document into MEASURED, and tells us the real PSRAM constant. **It is also the
only measurement that can change the verdict in §3 — and it will not, because a
2× model error either way still leaves the DCO alone above the whole budget.**
