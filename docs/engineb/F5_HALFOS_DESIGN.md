# F5 — half-oversampling design: DCO path and VCF path (the spec O8 executes)

Date 2026-08-05 (Fable 5). The probe is `data/c6_halfos_probe.c` +
`tools/engineb/gen_c6_halfband.py --measure`; every number below is from its
third revision, and §5 records what the first two revisions measured instead
of their subject, because both defects are traps O8 could re-fall into.

## 1. The finding that makes the lever admissible

The JU-06A's DCO is NAIVE and its aliasing is audible BY DESIGN — measured
on patch 32's real recalled coefficients (pulse, pw=0.02):

| ~f0 | plugin's own 4x alias floor | fork 2x alias floor | rise |
|---|---|---|---|
| 441 Hz | −111.4 dB | −111.3 dB | +0.1 |
| 882 Hz | −108.6 | −108.2 | +0.4 |
| 1.76 kHz | −127.0 | −126.3 | +0.7 |
| 3.5 kHz | −53.6 | −103.0 | −49 (see §3) |
| 7.1 kHz | −51.1 | −50.8 | +0.3 |
| 10.6 kHz | **−43.1** | −43.3 | −0.2 |

**The loud aliases (−43..−54 dB at high pitch) are generated at the SHAPING,
which is byte-identical in both paths; they fold near their 4x positions and
their LEVEL survives 2x within ±0.7 dB.** The decimator's stopband governs
the IMAGES, and a designed 2x filter handles those (floors ≤ −103 everywhere
the plugin's own floor is quiet). Half-oversampling does not bulldoze the
instrument's alias character — that was the disqualification risk, and it is
now measured away AT THE LEVEL. What it cannot preserve is alias POSITIONS
(the fold pivot moves from 176.4 k to 88.2 k), which is §6's user decision.

## 2. DCO path (O8 items 1–3)

- **Oscillator: unchanged code.** `eb_dco_step4` stepped with a DOUBLED
  per-substep increment IS the 2x oscillator (memoryless shaping around a
  phase accumulator). O8 restructures to a 2-step loop for the cost win;
  the probe proves spectrum-equivalence of the two drivings first.
- **Decimator: DESIGNED to match the port cascade, not generic.** The probe's
  Kaiser half-band leaves 7–14 dB harmonic-level mismatch at high f0 — the
  port's FIR+biquad cascade has a specific in-band shape that IS the sound.
  O8 must fit the 2x FIR (patch-independent part) so the CASCADE response
  matches the port's |H| within **0.1 dB to 18 kHz**, computable exactly from
  the recalled FIR cells + biquad; per-patch coefficient derivation follows
  the same recall law as the 4x set. This is also the suspected cause of the
  3.5 kHz row's −49 dB anomaly (a port-cascade notch the generic half-band
  does not reproduce); O8 confirms with the matched filter before trusting
  that row.
- **`k5456` feedback**: eb_dcoprep's per-sample output feeds the decimator;
  its law is rate-referenced. O8 re-derives the 2x form the same way the 4x
  arm was read, and the null decides.

## 3. VCF path (O8 items 4–5) — the algebra is exact, no frequency knowledge needed

The ladder runs 4 sub-steps of bilinear one-poles with per-recall G. The 2x
transform needs no knowledge of the cutoff frequency:

    G  = tan(pi f / fs4)        (the port's own parameterisation)
    G' = tan(2 atan G) = 2G / (1 − G²)      — EXACT algebraic map
    A' = 1 − 2G'
    R' = 1 / (1 + k G'⁴)        (recomputed; Rk' likewise)

Sub-step input interpolation weights (c9216/9232/9248/9200) become the
2-point set by the same read-the-port method used for the 4x set. The 32-tap
folded FIR halves to 16 at 88.2 k, designed against the same 0.1 dB cascade
bound as §2. The quintic nonlinearity aliases like the DCO's shaping — same
argument, and the gate measures it rather than assumes it.

## 4. The gates (in order; a step that fails is backed out, not argued)

1. **Response match, computed**: 2x cascade |H| within 0.1 dB of the 4x
   cascade to 18 kHz, per patch class. Pure arithmetic; runs in the
   generator.
2. **Alias level, measured**: probe table per f0 band; fork floor within
   **+1 dB** of the plugin's own floor in every band (the plugin's floor is
   the standard — this project does not get to be "better" any more than
   worse; eb_dco.h says why).
3. **The band-limited null**: full 36-scenario battery, both rates, residual
   measured through an 18 kHz low-pass, bound **−80 dB global / −60 dB
   block**. NOT the trunk's −100/−80: alias repositioning makes that
   unreachable by construction, and pretending otherwise would only prove the
   gate was never run. The bound is where matched-response + matched-level
   arithmetic says a correct implementation lands; an implementation defect
   lands decades above it.
4. **Cycle re-price + silicon harness** after each path lands.

## 5. The probe's own three revisions (O8: do not re-learn these)

1. Rev 1 drove the 4x reference with an INVENTED decimator FIR — the
   "reference" had response nulls (signal −24.7 dB at 10.6 kHz). A reference
   that is not the instrument measures nothing.
2. Rev 1 also read the DCO levels from cells 4736/4752/4768 — the PER-SAMPLE
   copies, 0.0 before a note — the exact trap `coef_audit.py` exists for.
   The coefficients are 4192/4208/4224.
3. Rev 2's harmonic mask marked the FOLDED positions of every partial as
   "harmonic", excluding precisely the aliases from the alias measure — a
   measure of everything except its subject.

## 6. The user decision this design needs (same class as the 0.05-cent one)

At matched level, 2x aliasing sits at DIFFERENT FREQUENCIES than the
plugin's (the fold pivot halves). No gate can call repositioned-but-
equal-level aliasing "the same sound"; the instrument's own floor is −43 dB
up high, so the difference is physically audible in principle on bright
patches at high notes. The fork standard must therefore say: **alias LEVEL
matched within +1 dB per band, positions not preserved.** That is the
half-OS relaxation in one sentence, and adopting it is the user's call, made
once, recorded in eb_fork_config.h like the pitch bound was.

## 7. Expected account (modelled; the record says treat with suspicion)

DCO 4x→2x ≈ −4,350 · decim halved ≈ −450 · VCF sub-steps 4→2 ≈ −2,900 ·
VCF FIR halved ≈ −250 → **≈ −7,950 → ≈ 15,500 cycles at 6 voices**, 1.42×
over the 44.1 kHz budget, with O9's tabulation lever (~−2,900) and O10's DCO
work remaining. The path to fit stays alive if and only if the gates above
pass as specified.
