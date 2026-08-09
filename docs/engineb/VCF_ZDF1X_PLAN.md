# WORK ORDER — the 1x ladder refit (EB_VCF_ZDF1X), written for Opus 5
2026-08-09, Fable 5. USER-BINDING framing: **THIS IS A TEMPORARY, FLAGGED
EXPERIMENT.** It ships nothing by itself. Build it behind `EB_VCF_ZDF1X`
(default 0), prove it or kill it, and report. **If it works and functions
perfectly — every gate below green — the USER decides adoption.** Nothing in
this plan authorizes changing any default.

## 0. Why this exists (one paragraph, then work)
The two-chip wall needs ~1,000 cycles out of a 3,394-cycle voice. The only
item that big is the VCF complex: 846 (four 4x sub-steps) + 237 (32-tap
decimator) = 1,083 cycles/voice. Every prior attack CHEAPENED THE PORT'S
TOPOLOGY and died: half-rate same-topology 3.17 dB, ADAA 2.22/5.77/33.94 dB,
control-rate 7.32 dB, interleave (16-register wall), Q15 (+3.9 dB). The one
method that has won twice (wavetable DCO −24.8 %, res-shaper LUT −1,009 cyc)
has never been aimed here: **replace the topology, fit the response, gate at
1.0 dB/third-octave.** Target: a 1x zero-delay-feedback 4-pole with fitted
saturation, ≤250 cycles/voice, replacing all 1,083.

## 1. What the port's ladder actually is (read eb_vcf_ladder.c first)
- Input node at 1x: `drive = ((k*c9168)+1)*(in*c9136) + (−dith)*c9120`,
  wrap24 dither free-running, `drive_prev` kept.
- Per sample: `A = 1−2G`, `R = 1/((G^4)k+1)`, `Rk = R*k`.
- FOUR sub-steps at 4x. Input weights `[prev*.c9216+drive*.c9232,
  (prev+drive)*.c9248, prev*.c9232+drive*.c9216, drive*.c9200]` — a linear
  upsampler of `drive`. Each sub-step: feedback `x = ins −(s1*c9520)*Rk`
  (S is the port's own one-step-ahead zero-input predictor), hard clip ±1,
  quintic `nl = x + x^5*c9184`, four cascaded bilinear one-poles, output tap
  `y4*c9104` (c9072/c9088 proven dead — EB_VCF_DEADCOEF).
- 32-tap symmetric FIR decimator, output `*c9152`.

## 2. The replacement, precisely
1. **Exact cutoff map, derived not assumed.** The port's G is the bilinear
   one-pole GAIN at 176.4 kHz: tangent `g4 = G/(1−G)` (PROVEN in the half-OS
   work; assuming G=tan cost 29 dB once — do not repeat). To 1x:
   `t2 = 2t/(1−t^2)` applied TWICE gives `g1 = tan(4·atan(g4))`; then
   `G1 = g1/(1+g1)`. ~10 flops, no frequency knowledge.
2. **Linear core:** standard TPT/ZDF 4-pole: instantaneous gains, combined
   zero-input response S̄, solve `u = (x_in − Rk1·S̄)/(1 + Rk1·G1^4)` (ONE
   division/sample), push u through four one-poles. Keep the same resonance
   normalisation law as the port (its R plays this role at 4x — derive the 1x
   equivalent from the port's own expressions, then VERIFY by measurement in
   gate G-A; do not trust the derivation alone).
3. **Nonlinearity:** the same clip+quintic (c9184), placed on the loop input
   u, PLUS 2–4 FITTED compensation constants (input drive scale, output
   makeup, optionally k-dependent via a small table) — because one saturation
   at 1x replaces four at 4x and the harmonic levels WILL differ unfitted.
4. **Dither stays per-sample and untouched** (stochastic; C2 proved no
   approximation of a dither carrier survives).
5. **Interface unchanged:** `eb_vcf_tick(st, c, in, G, k)` same signature,
   same return. eb_render.c must not change.
6. **Timing:** the FIR's ~3.9-sample group delay disappears. The sonic gate
   is level-based BY CHARTER (a null collapses on 18.2-cent UNISON beats —
   measured −46 dB); do not chase phase. NOTE it in the result doc.

## 3. FIT DATA — covenant line, read twice
Fit constants ONLY against the TRUNK ORACLE's rendered output (the trunk is
the plugin's own machine code behavior, proven EXACTLY 0). **NEVER against
the user's DAW bounces** (diagnostic covenant — a constant fitted to a bounce
is CAPTURED and poisons the fork). The fitted constants are fork-fit values,
same provenance class as `eb_vcf_halfos_fir` (fitted to the port's own
response) and the wavetable tables. Label them so in comments.

## 4. Execution order — each step its own commit
- **S1 DOMAIN.** Measure the reachable (G, k) domain: JUNO_EB_VCF_GRANGE
  exists for G (known: G ∈ [0.000119, 0.209771] over the battery — g4 ≤ 0.2655,
  so g1 stays finite; the map's pole is at G = 0.2929). Add the same
  instrumentation for k. ALSO bound the ANY-PRESET domain: sweep the VCF-path
  parameters over all 256 bytes (zero_proof.c shows the recall plumbing).
  Out-of-domain policy: clamp + document, same relaxation class as the alias
  decision — state it, do not hide it.
- **S2 GATE THE GATE.** Find which of the 36 scenarios drive k near
  self-oscillation. If NONE does, ADD a synthetic high-resonance scenario
  (precedent: the doctored EFFECT-4 scenario) BEFORE building anything. A
  fit judged by a gate that never reaches self-osc is vacuous, and self-osc
  amplitude is set ENTIRELY by the saturation being replaced.
- **S3 LINEAR SKELETON.** Build the ZDF core with saturation OFF both sides
  (EB_VCF_NOSAT exists on the port side for exactly this). **Gate G-A:**
  magnitude response vs the port's linear ladder on all 128 recalled
  coefficient sets, 0.1 dB to 18 kHz. Nothing nonlinear until G-A is green.
- **S4 FIT.** Enable the quintic; fit the compensation constants against
  trunk renders on the saturation-heavy + self-osc scenarios, matching
  third-octave band energy. Coarse grid, then refine. Maximum THREE fit
  iterations — if iteration 3 still fails a gate, STOP (see S7).
- **S5 GATES.** Full sonic gate, BOTH rates, all scenarios incl. the new
  high-res one, 1.0 dB every band. Then TEETH: perturb a fitted constant
  ~10 % and show the gate FAILS — a gate that cannot bite this path proves
  nothing (project law: a check never seen to fail is not a check).
- **S6 COST.** Static census first (objdump per-call); **abort-to-decision
  threshold: > 450 cycles/voice estimated** — that misses the headroom target
  and the USER decides whether to continue. Then one firmware
  (EB_VCF_ZDF1X=1) and the standard wake sweep. Expected voice ≈ 2,450–2,550.
- **S7 VERDICT, either way.** Success = all gates green + silicon number →
  the flag EXISTS, DEFAULT OFF, user decides adoption. Failure = write
  `data/zdf1x_result.md` with the numbers (precedent: c2_result.md), close
  the lever, revert nothing (it was never on), fall back to the asm plan.

## 5. Known traps — every one has already cost a session somewhere
1. G is NOT the prewarped tangent (29 dB error once). Derive from H(z).
2. Do not judge by null; the sonic gate is the instrument (charter).
3. The three probe traps from F5/O8: fake reference FIR; per-sample cells
   read as coefficients; folded positions masked as harmonics.
4. `#error` on impossible combos: EB_VCF_ZDF1X with EB_VCF_ILV,
   EB_HALF_OS_VCF, EB_VCF_ADAA, or EB_VCF_NOSAT-in-a-shipping-build.
5. New state fields change `eb_vcf_state` size → test_sizes + the S3 blob
   layout asserts → REGENERATE the firmware blob, or reuse existing fields
   (xprev/xprev2/F2p/F2pp are free when ADAA is off).
6. Sub-300-cycle silicon deltas are noise floor; do not report one as a win.
7. Trunk builds must be BYTE-IDENTICAL with the flag absent — verify the
   default-0 build's objects match before the first commit.
8. The dither and drive_prev are 1x state ALREADY — do not "simplify" them.

## 6. What success buys (so the numbers are checked against a target)
Voice 3,394 → ~2,500. Two-voice core 6,788 → ~5,000 vs 5,442: **the two-chip
44.1 kHz fit closes with ~8 % headroom from this alone**, before zero-coefs
(−60..130) and the VCA+HPF structural look (379 cycles, never examined).
Stack them and the 2-voice core lands ~4,600–4,800 = 12–15 % headroom.
Single-chip stays dead regardless (free-VCF floor 2,275 > 1,380) — do not
reopen it.
