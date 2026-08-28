/* eb_reverb.h -- ENGINE B, MODULE REVERB (the master-stage reverb send).
 *
 * Specification: docs/engineb/FX_REVERB.md, every number of which was executed
 * against the sealed port. The topology there was proven by reconstructing the
 * plugin's ONE 65,536-float masked line bit for bit; this file implements the
 * SPLIT-BUFFER form of the same arithmetic -- 13 independent circular buffers,
 * one per delay element -- which is proven separately, and bit-exactly, by
 * tools/engineb/fx_reverb_split_proof.py (60,000 samples at 44,100 and 48,000
 * Hz, max_abs_err 0.0, both channels, non-vacuous).
 *
 * WHAT IS AND IS NOT SIMPLIFIED
 *   Every floating-point operation is in the plugin's order and grouping,
 *   including the multiply chain (((tapsum*wet)*16)*mute)*gate and the two
 *   different stereo summation orders. Nothing is algebraically simplified and
 *   no coefficient is folded. The ONE structural change is memory: the plugin's
 *   single 262,144 B line addressed by a 16-bit mask becomes 13 rings totalling
 *   199,296 B, so that the four long loop delays -- and only those -- can be
 *   placed in external memory. That change moves no arithmetic.
 *
 *   ONE BEHAVIOURAL DEVIATION, deliberate and stated: the plugin's lazy wipe
 *   zeroes one 256-float stripe of its line per sample for 256 samples. Engine
 *   B zeroes all thirteen rings in one go at the moment the countdown reaches
 *   zero. That is EQUIVALENT, not approximate: while the countdown is running
 *   the tank arm does not execute at all (the mute has already reached 0, which
 *   is the condition for the wipe to advance), so no buffer cell is read
 *   between the first stripe and the latch. The plugin also leaves 44 cells of
 *   its line un-wiped; they sit beyond every tap and are never read.
 *
 * MEMORY (48 kHz capacities, the defaults; MEASURED by sizeof, see eb_reverb.c)
 *   EB_REV_CAP_* are COMPILE-TIME budgets. The four long loop delays are the
 *   LAST members of the state struct, and are the 138,104 B that
 *   docs/engineb/FX_REVERB.md says must go to PSRAM on the ESP32-S3; everything
 *   before them (61,192 B of rings plus ~400 B of scalars) can stay internal.
 *   A latched tap set that does not fit a capacity is NOT silently wrapped:
 *   `overrun` is set and the caller must fail.
 */
#ifndef ENGINEB_EB_REVERB_H
#define ENGINEB_EB_REVERB_H

#include <stdint.h>

/* EB_REVERB_HALF — the fork's half-rate reverb lever (default OFF, so the trunk
 * and every non-fork build are byte-identical). See eb_reverb_process_half.
 *
 * The tank runs at half rate with a REAL 41-tap anti-alias/anti-image FIR
 * (eb_reverb_halfband.h): the fold band (>=11025 Hz) is >=53 dB down, so the
 * aliasing of the first cut (b35, -30 dB of grit in the tail) is GONE. The
 * remaining, deliberate trade is a wet reverb tail band-limited to ~8 kHz; the
 * dry main signal is kept full-rate and bit-exact. Judged by the user's ear at
 * F2; the sonic difference is measured in docs/engineb/data/b36. */
#ifndef EB_REVERB_HALF
#define EB_REVERB_HALF 0
#endif
#if EB_REVERB_HALF
#include "eb_reverb_halfband.h"   /* EB_REV_HB_TAPS, eb_rev_hb[] */
#endif

/* Worst case over REVERB TYPE 0..5 at 48,000 Hz (MEASURED, docs/engineb/data/
 * fx_reverb.json -> type[48000]); 44,100 Hz is strictly smaller in every
 * element, so a 48 kHz build covers both gate rates. The pre-delay carries the
 * maximum PRE DELAY (4,798 samples at byte 100) plus the 416-sample reach of
 * the TYPE-5 modulation, which deepens that one read. */
#ifndef EB_REV_CAP_PD
#define EB_REV_CAP_PD   5216      /* 4798 max PRE DELAY + 416 modulation + slack */
#endif
#define EB_REV_CAP_AP1  1911
#define EB_REV_CAP_AP2  1517
#define EB_REV_CAP_AP3   907
#define EB_REV_CAP_AP4   361
#define EB_REV_CAP_LA0  1347
#define EB_REV_CAP_LA1  1341
#define EB_REV_CAP_LA2  1351
#define EB_REV_CAP_LA3  1347
#define EB_REV_CAP_D0   7165
#define EB_REV_CAP_D1   7615
#define EB_REV_CAP_D2   9755
#define EB_REV_CAP_D3   9991

/* the 34 tap ints the recall writes (11022208 in the sealed port's state) */
#define EB_REV_NTAP 34

typedef struct {
    float send;                 /* 10759408  REVERB LEVEL                    */
    float gate;                 /* 10759376  run gate                        */
    float dry;                  /* 10759424                                  */
    float wet;                  /* 10759440                                  */
    float ap;                   /* 10759392  the ONE allpass coefficient, 0.5 */
    float f_in[8];              /* 10759520..10759632 DC block + 2-pole LP   */
    float damp[4][3];           /* 10759648/664/680 + 48k: fc, hpc, lpc      */
    float lfo_inc;              /* 10759504                                  */
    float lfo_depth;            /* 10759488  0 except REVERB TYPE 5          */
} eb_reverb_cfg;

typedef struct {
    /* input filter history: x[n-1], y[n-1], y[n-2], z[n-1], z[n-2] */
    float s0, s1, s2, s3, s4;
    float dlp[4], dhp[4];       /* damper state, per loop                    */
    float phase;                /* the pre-delay modulation saw              */
    float mute;                 /* 11022032 crossfade, 0.0004/sample         */
    int32_t wipe;               /* 10759872 lazy-wipe countdown              */
    int32_t taps[EB_REV_NTAP];  /* LATCHED tap table (the working one)       */
    int32_t dep[13];            /* derived read depth of each ring           */
    int32_t ot[4][2];           /* per loop, the two stereo output depths    */
    int32_t seeded;             /* 0 until the first process() call          */
    int32_t overrun;            /* a latched depth exceeded its capacity     */
#if EB_REVERB_HALF
    /* half-rate wrapper state (EB_REVERB_HALF only): the anti-alias FIR delay
     * line for the decimated mono send, and the anti-image FIR history of the
     * two half-rate wet channels, plus the even/odd phase. Present only in the
     * fork; the trunk never sees them. EB_REV_HB_TAPS comes from the generated
     * eb_reverb_halfband.h, included above under the same flag. */
    unsigned hph;
    float hb_in[EB_REV_HB_TAPS];              /* full-rate mono send line     */
    int32_t hb_iw;
    float hb_wl[(EB_REV_HB_TAPS + 1) / 2];    /* half-rate wet L history       */
    float hb_wr[(EB_REV_HB_TAPS + 1) / 2];    /* half-rate wet R history       */
    int32_t hb_ww;
#endif
    /* --- rings. read-then-write; index advanced by a compare-and-add --- */
    float pd[EB_REV_CAP_PD];
    float ap1[EB_REV_CAP_AP1], ap2[EB_REV_CAP_AP2];
    float ap3[EB_REV_CAP_AP3], ap4[EB_REV_CAP_AP4];
    float la0[EB_REV_CAP_LA0], la1[EB_REV_CAP_LA1];
    float la2[EB_REV_CAP_LA2], la3[EB_REV_CAP_LA3];
    int32_t w[13];
    /* --- LAST: the four long loop delays, the PSRAM candidates --- */
    float d0[EB_REV_CAP_D0], d1[EB_REV_CAP_D1];
    float d2[EB_REV_CAP_D2], d3[EB_REV_CAP_D3];
} eb_reverb_state;

/* Power-on state: everything zero, wipe armed. */
void eb_reverb_init(eb_reverb_state *s);

/* Seed from an already-running host's cells (the null harness's shim). `taps`
 * is the host's WORKING (already latched) table, not the pending one. */
void eb_reverb_seed(eb_reverb_state *s, const int32_t *taps, float mute,
                    int32_t wipe);

/* One sample. `inA`/`inB` are the master's pre-reverb pair (the plugin's v176
 * and v177); `outA`/`outB` are its v529/v530 -- note the plugin crosses them:
 * outA carries dry*inB and outB carries dry*inA.
 * `pending` is the recall's tap table, latched when the wipe completes.
 * `wipe_arm` is the recall's countdown cell: pass its current value, and the
 * updated value is written back through it, so a recall re-arming it to 256 is
 * picked up with no change-detection heuristic. */
void eb_reverb_process(const eb_reverb_cfg *c, eb_reverb_state *s,
                       const int32_t *pending, int32_t *wipe_arm,
                       float inA, float inB, float *outA, float *outB);

#if EB_REVERB_HALF
/* HALF-RATE REVERB (fork headroom lever, SONIC TRADE — NOT bit-exact).
 * Runs the tank at half the sample rate: the input pair is decimated 2:1, the
 * tank is clocked on every second sample with its ring depths halved and its
 * rate-dependent coefficients rescaled (see eb_reverb_halfrate_cfg), and the
 * output is linearly interpolated 1:2. Real echo and tail TIMES are preserved;
 * what is traded is reverb energy above ~11 kHz and a mute gate that fades at
 * half speed. Same call shape as eb_reverb_process. Bounded by sonic_gate.py,
 * judged by the user's ear at F2. Requires the cfg to have been passed through
 * eb_reverb_halfrate_cfg and the state derived with EB_REVERB_HALF set (which
 * halves dep[]/ot[]). */
void eb_reverb_process_half(const eb_reverb_cfg *c, eb_reverb_state *s,
                            const int32_t *pending, int32_t *wipe_arm,
                            float inA, float inB, float *outA, float *outB);

/* Rescale a fully-populated cfg from the full gate rate to half rate, in place.
 * Adjusts only the rate-dependent coefficients (the loop-damper corner and the
 * TYPE-5 modulation increment); the structural allpass gain, the per-pass loop
 * decay and the input filter are left as-is (documented trades). Idempotent it
 * is NOT — call exactly once, on a full-rate cfg. */
void eb_reverb_halfrate_cfg(eb_reverb_cfg *c);
#endif

#endif /* ENGINEB_EB_REVERB_H */
