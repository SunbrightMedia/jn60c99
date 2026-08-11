/* eb_fork_config.h — the S3 FORK's build constants (F3). THE TRUNK IGNORES
 * THIS FILE ENTIRELY: nothing in engine_b compiles differently unless a
 * TARGET build defines EB_FORK_S3, and no gate in the trunk battery does.
 *
 * The values are the user's Phase-2 charter, as constants rather than prose:
 * targets are FORKS BY BUILD FLAGS off the certified trunk, and this header
 * is that flag surface. O6 (fork execution) consumes it; F3 defines it.
 *
 *   EB_FORK_VOICES 6      -- the S3 build's polyphony, a compile constant so
 *                            loops unroll and buffers size statically.
 *   EB_FORK_SR 48000      -- design rate. 44100 is a RESERVE DIAL: it buys
 *                            8.8 % budget and is only pulled if silicon says.
 *   EB_PITCH_FORK 1       -- eb_pitch_fork_eval replaces eb_pitch_eval.
 *                            Gate: tools/engineb/pitch_cents_gate.py,
 *                            EXHAUSTIVE 2^32, PASS at worst 0.00074 cents
 *                            against the 0.05-cent bound (67x margin).
 *   EB_EXP_FORK 1         -- eb_exp_fork replaces expf in the LFO path.
 *                            Gate: tools/engineb/exp_ppm_gate.py, EXHAUSTIVE
 *                            2^32, PASS at worst 0.119 ppm against 2 ppm,
 *                            tails bit-identical to libm.
 *   EB_C4_SIMD_RECURSIVE 0 -- CLOSED NEGATIVE, do not revisit without new
 *                            evidence: Q15 lanes on the resonant ladder
 *                            measure +3.9 dB worst-block (the error is as
 *                            loud as the signal near self-oscillation), and
 *                            even Q28 scalar sits AT the -80 dB block bound
 *                            with no margin. docs/engineb/data/
 *                            c4_ladder_probe.c is the evidence. Fixed-point
 *                            SIMD remains a candidate ONLY for feed-forward
 *                            spans (FIR decimators, mix stages).
 *
 * OPEN, deliberately not decided here: the global-LFO reduction (one LFO for
 * the engine instead of six) is worth ~4,100 instr/sample but is conditional
 * on BOTH of: (a) verifying the hardware fact that the real JUNO-60 shares
 * one LFO across voices INCLUDING how the plugin's per-voice CONDITION
 * scatter perturbs it, and (b) silicon still needing it. Neither is
 * established tonight, so it is not a constant.
 */
#ifndef ENGINEB_EB_FORK_CONFIG_H
#define ENGINEB_EB_FORK_CONFIG_H

#ifdef EB_FORK_S3
#ifndef EB_FORK_VOICES
#define EB_FORK_VOICES 6
#endif
#ifndef EB_FORK_SR
#define EB_FORK_SR     48000
#endif
/* Each evaluator is overridable on the command line so the gates can build
 * the flag surface with the substitutions OFF -- the build that proves the
 * flag itself changes nothing. See JUNO_EB_FORK in tools/engineb/null_b.py. */
#ifndef EB_PITCH_FORK
#define EB_PITCH_FORK  1
#endif
#ifndef EB_EXP_FORK
#define EB_EXP_FORK    1
#endif
#ifndef EB_C4_SIMD_RECURSIVE
#define EB_C4_SIMD_RECURSIVE 0
#endif
/* EB_HALF_OS -- half-oversampling of the DCO path (F5 design, O8 build).
 * DEFAULT 0, AND THAT IS A COMMITMENT, NOT A PLACEHOLDER: the user approved
 * the alias-position relaxation on the explicit condition that it stays
 * REVERSIBLE. The exact 4x path remains compiled in the binary; setting this
 * back to 0 restores it completely, with no other edit anywhere.
 *
 * What it changes when 1: the DCO runs 2 sub-steps per sample at a DOUBLED
 * increment instead of 4, and eb_decim_tick uses the 24-tap designed FIR
 * (eb_halfos_fir.h) instead of the port's 32-tap polyphase set. The biquad,
 * and everything else, is untouched.
 *
 * THE RELAXATION, in one sentence, as signed: alias LEVEL matched within
 * +1 dB per band; alias POSITIONS not preserved. */
#ifndef EB_HALF_OS
#define EB_HALF_OS 0
#endif
#ifndef EB_QUARTER_OS
#define EB_QUARTER_OS 0
#endif
/* EB_HALF_OS_VCF -- half-oversampling of the VCF LADDER. SEPARATE from
 * EB_HALF_OS and DEFAULTED OFF EVEN WHEN EB_HALF_OS IS ON, because O8
 * measured it and it does not hold: the cutoff transform is exact and the
 * decimator is the same designed filter, yet the ladder's response above the
 * cutoff diverges by -0.9 dB at 6 kHz, -2.6 dB at 9 kHz and -12.4 dB at
 * 16 kHz. That is not aliasing at -43 dB, it is the filter's own skirt --
 * i.e. audible brightness, per patch. A bilinear filter run at half the rate
 * cannot have the same shape near Nyquist; the transform fixes the cutoff and
 * nothing fixes the shape. See docs/engineb/data/o8_halfos_result.md §7.
 * The code stays in the tree so the negative result is reproducible in one
 * command instead of re-derived. */
#ifndef EB_VCF_ILV
#define EB_VCF_ILV 0
#endif

#ifndef EB_VCF_NOSAT
#define EB_VCF_NOSAT 0
#endif

#ifndef EB_VCF_DEADCOEF
#define EB_VCF_DEADCOEF 0
#endif

#ifndef EB_VCF_ADAA
#define EB_VCF_ADAA 0
#endif

#ifndef EB_HALF_OS_VCF
#define EB_HALF_OS_VCF 0
#endif

/* EB_QUARTER_OS: run the DCO at the OUTPUT rate, one sub-sample per sample.
 * Row 4 of docs/engineb/S3_PLAN_THAT_FITS.md, and the row that carries the
 * plan on its own.
 *
 * WHAT THE PHYSICS SAYS BEFORE ANY CODE RUNS. The port's edge is
 * clamp1(tri(x) * g * 256 * amp) with g = (1/256)/inc4, so g*256 = 1/inc4 and
 * the edge spans inc4/amp in phase -- a FIXED DURATION in time, independent
 * of how many sub-samples that duration is cut into. Oversampling therefore
 * does not change the edge's spectrum; it changes how accurately the edge is
 * SAMPLED. At 4x the ramp is sampled four times and decimated. At 1x it is
 * sampled once, and where that one sample lands in the ramp is what aliases.
 *
 * So this is the rung F5 stopped short of, and it is not obviously
 * admissible. It is built to be MEASURED by the alias gate that already
 * exists (tools/engineb/o8_gate2.py), not because it is expected to pass. */
#ifndef EB_QUARTER_OS
#define EB_QUARTER_OS 0
#endif

/* DEFAULTED HERE, not left to the preprocessor's implicit 0. This file's own
 * note on EB_DCO_SUBSTEPS says why: a silent 0 from an undefined macro reads
 * exactly like a deliberate setting. */
#ifndef EB_DCO_WT
#define EB_DCO_WT 0
#endif

/* EB_DCO_WT implies EB_QUARTER_OS: the band-limited DCO produces ONE sample
 * per sample and the decimator's FIR has nothing left to decimate. The biquad
 * tail still runs -- it is rate-dependent recall data, not anti-aliasing. */
#if EB_DCO_WT && !defined(EB_QUARTER_OS_SET)
#undef EB_QUARTER_OS
#define EB_QUARTER_OS 1
#define EB_QUARTER_OS_SET 1
#endif

#if EB_QUARTER_OS
#define EB_DCO_SUBSTEPS 1
#elif EB_HALF_OS
#define EB_DCO_SUBSTEPS 2
#else
#define EB_DCO_SUBSTEPS 4
#endif

/* EB_LFO_SHARED stays DEFAULT OFF even in the fork: the charter's second
 * condition (silicon still needs it) is F4's to establish. Condition (a) is
 * MET and gated: the phase identity was measured across the bank under
 * staggered notes, forced LFO TRIG ENV, and maximum LFO DELAY TIME, and the
 * shared build nulls against the port -- see eb_render.c's note and
 * F3_S3_FORK_DESIGN.md. Turn it on with -DEB_LFO_SHARED=1. */
#ifndef EB_LFO_SHARED
#define EB_LFO_SHARED 0
#endif

/* EB_LFO_FREERUN -- run voice 0's cvgate/glide/LFO chain even when voice 0 is
 * AT REST. It DEFAULTS TO EB_LFO_SHARED, because a shared LFO without it is
 * broken rather than merely slower: the whole instrument's modulation sits
 * behind one voice's at-rest test, and that voice is the last one the
 * allocator ever assigns.
 *
 * Measured consequence before this existed: the shipping firmware had NO LFO
 * at any polyphony below eight notes, on every cycle figure taken on the
 * board. See docs/engineb/data/lfo_dead.md for the full chain and for why no
 * gate in this repo could see it -- the gate's shim holds every voice awake,
 * so the branch this flag removes never executed under test.
 *
 * It costs the prologue's real work every sample instead of an early return.
 * That cost is UNMEASURED on silicon; do not quote an estimate for it. */
#ifndef EB_LFO_FREERUN
#define EB_LFO_FREERUN EB_LFO_SHARED
#endif
#endif

/* ===================================================== CONTROL-RATE LEVERS
 * docs/engineb/LAST_MILE.md, Phase A. Each holds one module group's OUTPUT
 * for EB_CR_N samples and skips the module on the held samples.
 *
 * WHY THESE ARE OPEN AGAIN AFTER BEING CLOSED. C2 closed control-rate CV at
 * -39.3 dB and C1 closed control-rate pitch at -89.5 dB. BOTH ARE NULL
 * NUMBERS, measured against the -100 dB trunk gate. A null answers "is this
 * the same waveform"; the fork's standard is third-octave BAND ENERGY, which
 * asks "does this sound the same". Nothing in this repo has ever measured
 * these levers under the second question. That is the whole reason they are
 * built here, and the sonic gate -- not this comment -- decides each one.
 *
 * DEFAULT 0 EVERYWHERE. Nothing changes in any existing build until a flag
 * is passed on the command line.
 *
 *   EB_CR_N        the hold length in samples (2 = every other sample)
 *   EB_CR_ENV      hold both envelope outputs        (A2)
 *   EB_CR_VCFCV    hold the VCF cutoff CV + shaper   (A1)
 *   EB_CR_MODCV    hold the modulation CV sums       (A1)
 *   EB_CR_PITCH    hold the pitch evaluator + dcoprep(A4)
 *   EB_CR_ALL      convenience: sets all four
 *
 * WHAT IS DELIBERATELY NOT HELD: the note/gate path (eb_cvgate) and the
 * glide state. Both carry note EVENTS, and an event that arrives one sample
 * late is a different note, not a slightly different one. */
#ifndef EB_CR_ALL
#define EB_CR_ALL 0
#endif
#ifndef EB_CR_N
#if EB_CR_ALL
#define EB_CR_N EB_CR_ALL
#else
#define EB_CR_N 1
#endif
#endif
#ifndef EB_CR_ENV
#define EB_CR_ENV (EB_CR_ALL ? 1 : 0)
#endif
#ifndef EB_CR_VCFCV
#define EB_CR_VCFCV (EB_CR_ALL ? 1 : 0)
#endif
/* SEPARATE FROM EB_CR_VCFCV, and the separation is a measurement, not tidying:
 * the resonance shaper is already a 256-entry table costing about 36 cycles,
 * so holding it saves nothing and only removes accuracy. Running it EVERY
 * sample from a HELD cutoff is both cheaper to be right about and cheaper to
 * run. */
#ifndef EB_CR_VCFRES
#define EB_CR_VCFRES 0
#endif
#ifndef EB_CR_MODCV
#define EB_CR_MODCV (EB_CR_ALL ? 1 : 0)
#endif
#ifndef EB_CR_PITCH
#define EB_CR_PITCH (EB_CR_ALL ? 1 : 0)
#endif

/* PER-GROUP HOLD PERIODS. EB_CR_N is the MASTER period and must be a power of
 * two; each group holds for its own divisor of it. The three are separate
 * because the gate measured them apart and they do not agree: the pitch chain
 * is as good at four samples as at two (4.09 dB against 4.18), while the
 * cutoff CV falls apart there (10.93 dB). One period for all of them would
 * have to be the worst group's. */
#ifndef EB_CR_NP
#define EB_CR_NP EB_CR_N
#endif
#ifndef EB_CR_NC
#define EB_CR_NC EB_CR_N
#endif
#ifndef EB_CR_NE
#define EB_CR_NE EB_CR_N
#endif
#if (EB_CR_N & (EB_CR_N - 1)) != 0
#error "EB_CR_N must be a power of two -- the phase test is a mask"
#endif

/* EB_CR_LERP -- INTERPOLATE the held value instead of stepping to it.
 *
 * THE MEASUREMENT THAT PUT THIS HERE. Every plain hold failed in the SAME
 * place, the 10,240 Hz band, and by amounts a slow control signal cannot
 * explain: envelopes 40.43 dB, cutoff CV 6.74 dB. A held control is a
 * STAIRCASE, the VCA and the filter MULTIPLY by it, and a staircase at half
 * the sample rate modulates the audio at fs/2 -- which lands exactly there.
 * The error was never the control's accuracy; it was the shape of its edges.
 *
 * So the held samples are filled by linear interpolation between the two
 * computed points. The output is one sample late and has no steps in it. The
 * cost is one add and one multiply on the computed samples, which is far less
 * than the module that is no longer running.
 *
 * IT IS PER GROUP, AND THAT IS A MEASUREMENT TOO. Interpolating the PITCH
 * chain made it far worse -- 3.21 dB stepped, 17.96 dB interpolated -- and the
 * reason is in the arithmetic rather than in the ear: eb_dcoprep produces the
 * increment AND the edge gain g = 0.00390625/inc, an exact reciprocal pair.
 * Interpolating the two INDEPENDENTLY breaks that identity, because the
 * midpoint of a reciprocal is not the reciprocal of a midpoint, and the DCO's
 * edge width is then wrong for its own increment. Stepping keeps the pair
 * consistent, and a stepped increment is inaudible where a stepped GAIN is
 * not. So: interpolate what MULTIPLIES the audio, step what describes it. */
#ifndef EB_CR_LERP_ENV
#define EB_CR_LERP_ENV 1
#endif
#ifndef EB_CR_LERP_CV
#define EB_CR_LERP_CV 1
#endif
#ifndef EB_CR_LERP_PITCH
#define EB_CR_LERP_PITCH 0
#endif

/* EB_ENV_CR -- the RATE-COMPENSATED envelope, the answer to the plain hold's
 * 40.43 dB. A plain hold at N=2 does not make the envelope slightly wrong, it
 * makes every attack and decay TWICE AS LONG, which is a different instrument
 * and the gate said so at once.
 *
 * The composition is exact where the envelope is linear: two steps of
 * y += a(target - y) equal one step of a' = 2a - a^2, so the state at the even
 * samples is unchanged. The same squaring applies to the rate smoother, and
 * the sustain SLEW is a linear ramp, so its step doubles instead. What is
 * left over is the zero-order hold on the odd samples and the two-sample peak
 * detector -- both of them errors of one sample, not of a time constant.
 *
 * MEASURED, AND IT IS NOT THE FIX: with the compensation on, the envelope
 * hold reads 41.89 dB against the plain hold's 40.43 dB -- no better, and the
 * failures stay in the same 10,240 Hz band. That is the result that named the
 * real defect: the envelope's TIME CONSTANT was never the problem, its EDGES
 * were, and EB_CR_LERP above is what answers them. The code stays so the
 * negative is one command away instead of re-derived, and it is DEFAULT OFF.
 *
 * When set to 2 it must equal EB_CR_N, because a mismatch is silent and would
 * read as a bad envelope rather than a bad flag. */
#ifndef EB_ENV_CR
#define EB_ENV_CR 1
#endif
#if EB_ENV_CR == 2 && (EB_CR_NE != 2)
#error "EB_ENV_CR=2 needs EB_CR_NE=2 -- see eb_fork_config.h"
#endif
#if EB_ENV_CR != 1 && EB_ENV_CR != 2
#error "EB_ENV_CR supports 1 (off) and 2 only: the compensation is the two-step pole square."
#endif

/* EB_VCF_MAPFAST -- the half-rate ladder's cutoff map in ONE division.
 * The three-step map collapses to Gp = 2G(1-G)/(1-2G^2) by exact algebra
 * (verified over 289 exact rationals). The float32 evaluation differs by at
 * most 5 ULP over the measured domain, so it is FORK-ONLY and faces the
 * sonic gate, not the null. See eb_vcf_ladder.c for the clamp mapping. */
#ifndef EB_VCF_MAPFAST
#define EB_VCF_MAPFAST 0
#endif

/* EB_DECIM_AVG -- lever A3. Replaces the half-rate ladder's 16-tap folded
 * FIR with a 2-tap average carrying THE SAME DC GAIN (the FIR's taps sum to
 * 1.0001332, so the average's weight is half of that and the output LEVEL is
 * unchanged by construction). Only the stopband changes, and how much that
 * costs is a gate question, not a comment question. */
#ifndef EB_DECIM_AVG
#define EB_DECIM_AVG 0
#endif

/* OUTSIDE the fork guard on purpose: eb_dco.c and eb_decim.c compile in the
 * TRUNK build too, and an undefined EB_DCO_SUBSTEPS there would be a silent
 * 0 in the #if -- a DCO that produces no sub-samples at all. */
#ifndef EB_HALF_OS
#define EB_HALF_OS 0
#endif
#ifndef EB_QUARTER_OS
#define EB_QUARTER_OS 0
#endif
#ifndef EB_DCO_SUBSTEPS
#define EB_DCO_SUBSTEPS 4
#endif

#endif

/* SAFE OUTSIDE THE FORK TOO. Everything above is inside the EB_FORK_S3 guard,
 * so a TRUNK build never sees those defaults -- and `#if !EB_LFO_FREERUN` in
 * eb_render.c would then be testing an UNDEFINED macro, which the preprocessor
 * silently reads as 0. It would give the right answer for the wrong reason,
 * and it would stop giving it the moment someone spelled the flag differently.
 * This project has already been bitten by a knob nothing read (S3_RING_SRAM,
 * 2026-08-11, cost one flash). Define it explicitly for the non-fork build. */
#ifndef EB_LFO_FREERUN
#define EB_LFO_FREERUN 0
#endif
#ifndef EB_LFO_SHARED
#define EB_LFO_SHARED 0
#endif
