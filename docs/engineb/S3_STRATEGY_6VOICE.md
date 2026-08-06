# STRATEGY: 6 VOICES + FX ON THE ESP32-S3

Date 2026-08-06. Written after a day in which every lever tried was worth
1-7 % and the gap is **3.54x**. The user's instruction: a new strategy, not
more cheap cuts. This is that.

## WHY EVERYTHING SO FAR FAILED TO MATTER

Every lever this project has ever attempted — C1, C2, C3, C4, C5, half-OS,
the edge short-circuits — attacked the **instruction count**. Not one has
attacked **c/i**, which is **1.56 MEASURED**. That is a 56 % tax on every
instruction the engine executes, it is spill-and-reload stalls on a core with
16 float registers, and it is *structural*, not algorithmic.

**Attacking c/i multiplies every other gain.** It has never been tried.

Second: the profile was only done today. Before it, levers were aimed at
pitch (1.7 % of the engine) and call overhead (~1 %) while the DCO sat at
**40 %** untouched. Aim matters more than effort.

## THE LADDER

| phase | instr | cycles | vs 2 cores | nature |
|---|---|---|---|---|
| today | 24,686 | 38,510 | 3.54x | |
| 0. edge short-circuits | 23,046 | 35,951 | 3.30x | **DONE, EXACTLY 0** |
| 1. **block processing** | 23,046 | 26,502 | **2.44x** | **exact** |
| 2. DCO transition synthesis | 15,846 | 18,222 | 1.67x | research |
| 3. FX at half rate | 13,496 | 15,520 | 1.43x | relaxation |
| 4. VCF 2x + corrective filter | 12,096 | 13,910 | 1.28x | relaxation |
| 5. FX rings -> internal RAM | 10,496 | 12,070 | **1.11x** | exact |

**1.11x is within ordinary tuning of a fit.** Nothing above requires a
different chip.

## PHASE 1 — CORRECTED BY MEASUREMENT BEFORE IT WAS BUILT

**The version below is WRONG and is kept so the correction is legible.**

MEASURED on the Xtensa build: `eb_dco_step_i` has **no separate symbol** --
gcc already inlines it at -O2. The DCO is ONE 484-instruction body whose four
sub-steps are a loop, and the recall-rate coefficients are already hoisted
out of it. The only per-iteration loads left are `inc`, `g`, `pw`, `pwm1`,
`pwp1` -- and those **change every sample** (eb_render.c:229-233 writes them
from eb_dcoprep_tick's modulation), so no amount of blocking removes them.

**Blocking per voice therefore buys almost nothing, and the estimated
1.56 -> 1.15 was wrong.**

**What c/i actually is.** Spills are only **9.3 %** of instructions
(MEASURED, O-b). The 1.56 is FPU DEPENDENCY LATENCY: a serial chain of
single-precision operations where each waits on the previous. Blocking one
voice does not break a serial chain -- **it is still the same chain, just
looped differently.**

**The only thing that fills those stalls is INDEPENDENT work, and the engine
has six independent copies of it: the voices.** LTO already demonstrated the
mechanism at small scale -- it inlined across the voice loop and the measured
per-voice slope fell 5,343 -> 5,031 cycles (-5.8 %) with no arithmetic change.
Hand-interleaving two voices' DCO sub-steps in one loop body is the same
mechanism applied deliberately instead of incidentally.

**REVISED PHASE 1: VOICE-PAIR INTERLEAVING.** Process voices two at a time
through the DCO and the ladder, their arithmetic interleaved in one body, so
each voice's independent operations fill the other's dependency stalls.
Exact -- the voices never interact, so the null must still be EXACTLY 0.
Expected c/i 1.56 -> 1.2-1.3 (LTO's incidental 5.8 % is the floor, not the
ceiling); the number must be MEASURED on the board, not estimated again.

### The original (wrong) text follows

## PHASE 1 — BLOCK PROCESSING (the one that changes the multiplier)

**What it is.** The engine renders sample-by-sample: for each sample, for
each voice, call each module. Every call reloads its coefficient struct
(the DCO's has ~20 fields), spills float registers, and pays call overhead.
The DCO reloads its coefficients **24 times per audio sample**.

Restructure to blocks of 32: load coefficients ONCE per module per voice per
block, then run 32 samples in a tight loop over a small intermediate buffer.

**Why it is EXACT.** Same arithmetic, same order, same values — only the
loop nesting changes. The voice chain is feed-forward within a sample
(cvgate -> glide -> LFO -> env -> modcv -> vcf_cv -> DCO -> decim -> VCF ->
VCA), so no cross-module feedback prevents it. **The null must be EXACTLY 0
and that is the acceptance test.**

**Expected: c/i 1.56 -> ~1.15**, i.e. **1.36x on everything at once**. The
figure is an estimate; the MEASUREMENT is one build of one module (start with
the DCO, the largest) plus the existing sweep firmware.

**Cost:** ~1.3 KB of intermediate buffers per voice. Trivial.

**Risks, named:** the shared noise LFSR steps once per sample for all voices
and must keep doing so; at-rest voices must still advance per sample; the
master's one-sample FX feedback (cells 84672/84704) crosses block boundaries
and must be carried, not reset.

## PHASE 2 — DCO TRANSITION SYNTHESIS (the 40 % line)

**The observation that makes it possible.** MEASURED: the DCO's clamped edge
is saturated on **98.85 %** of sub-steps. So the oscillator output is, almost
always, **piecewise constant** — a pulse/square train whose levels are the
precomputed `sat_hi`/`sat_lo` times fixed gains. The interesting samples are
the transitions, and at 100 Hz there are 200 transitions per second against
44,100 samples.

**And the decimator is LINEAR** (32-tap FIR + biquad). So

    output = DC level  +  sum over transitions of
             (step amplitude x the decimator's STEP RESPONSE, time-shifted)

The step response is a fixed 32-sample vector computable at recall. Between
transitions the output is a constant. **This replaces 4 sub-steps x
(saw+pulse+sub+saturate) + a 32-tap FIR per sample with: a phase compare, and
on the rare transition sample, adding a stored vector.**

**Expected: 8,712 -> ~1,500 instructions.** This is the single largest item
on the board.

**Honest status: RESEARCH.** The 1.15 % of sub-steps in the edge regions are
NOT constant — they ramp — and must be handled by a small table of
pre-decimated edge shapes indexed by sub-sample transition position. Whether
that reproduces the port closely enough is unknown and must be gated the same
way half-OS was: response match, alias level, harmonic level.

## PHASES 3-5 — the rest

3. **FX at half rate.** Chorus/delay/reverb at 22.05 kHz with interpolation
   is standard practice and largely inaudible on tails. ~-2,350. A
   relaxation, needs a gate and the user's decision.
4. **VCF at 2x with a corrective one-pole.** The half-OS VCF rung was
   DECLINED because it moves the skirt 2.6-12.4 dB — but a corrective filter
   after the ladder was never tried, and the error is a smooth, computable
   frequency response.
5. **FX rings into internal RAM.** MEASURED: the FX chain runs at c/i 2.36
   against the voice chain's 1.56, purely because 6.16 MB of rings live in
   PSRAM. The rings are sized for 11.9 SECONDS of delay; nobody has measured
   what the patches actually use. Sizing them to the real range may fit the
   hot ones in internal RAM.

## WHAT THIS IS NOT

It is not a week of 5 % cuts. Phases 1 and 2 are a rewrite of the hot path.
Phase 1 alone is worth more than everything attempted this project to date,
and it is EXACT — no relaxation, no permission, no sound change.

## CONFIDENCE, stated because today's estimates were repeatedly wrong

* Phase 0: **MEASURED** (EXACTLY 0, -1,640).
* Phase 1: the mechanism is certain (reloads and spills are visible in the
  disassembly); the SIZE of the gain is an estimate. Measure on the DCO first.
* Phase 2: the observation is MEASURED (98.85 %); the synthesis is unbuilt.
* Phases 3-5: modelled, each needs its own gate.

**The first thing to do is Phase 1 on the DCO alone and measure c/i on the
board.** That single number tells us whether this strategy is real, and it
costs one build.
