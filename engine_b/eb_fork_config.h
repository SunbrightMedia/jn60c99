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
