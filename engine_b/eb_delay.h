/* eb_delay.h -- ENGINE B, MODULE DELAY (the DELAY TYPE 0 stage).
 *
 * Derived from docs/engineb/FX_DELAY.md, whose specification is the literal
 * transcription docs/engineb/data/eb_delay_ref.c -- that transcription nulled
 * BIT-EXACT (0 differing samples) against the sealed engine on 20 non-vacuous
 * configurations. This file re-expresses the same arithmetic with engine B's
 * own state layout: one struct, one compile-time ring, no 12 MB context.
 *
 * WHAT IS AND IS NOT SIMPLIFIED
 *   Every floating-point operation is kept in the reference's order and
 *   grouping. Nothing is "algebraically simplified": the multiplies by cells
 *   measured to be 1.0 (102624, 102688) and the two crossfades measured to take
 *   only 0.0/1.0 (102448, 102496) are STILL MULTIPLIES here, because the null
 *   runs at 44,100 Hz where cell 102448 is 1.0 and the DF-I biquad is the live
 *   path. The only compile-time reduction offered is EB_DELAY_BIQUAD=0, which
 *   removes the DF-I branch; that is legal ONLY at host rates other than 44,100,
 *   where 102448 was MEASURED 0.0 (FX_DELAY.md section 2.4). The 48 kHz target
 *   build uses it; the 44.1 kHz gate build does not.
 *
 * MEMORY (EB_DELAY_LEN = 65536, the default)
 *   ring          2 * 65536 * 4 = 524,288 B
 *   scalars                          120 B
 *   sizeof(eb_delay_state)       524,408 B
 *   This does not fit the 200 KB internal budget of docs/engineb/SCOPE.md and
 *   is the allocation that forces PSRAM. EB_DELAY_LEN is a COMPILE-TIME
 *   constant and the ring is the LAST member of the struct precisely so the
 *   line can be moved to external memory without touching the DSP.
 *
 *   65536 covers manual mode at both gate rates (800 ms = 35,278 samples at
 *   44.1 kHz, 38,398 at 48 kHz). It does NOT cover tempo sync (1/1 at 128 BPM
 *   = 90,000 samples at 48 kHz, FX_DELAY.md section 4). A tap that does not fit
 *   is not silently wrapped: `overrun` is set and the caller must fail.
 */
#ifndef ENGINEB_EB_DELAY_H
#define ENGINEB_EB_DELAY_H

#include <stdint.h>

#ifndef EB_DELAY_LEN
#define EB_DELAY_LEN 65536            /* power of two, COMPILE-TIME budget */
#endif
#if (EB_DELAY_LEN & (EB_DELAY_LEN - 1)) != 0
#error "EB_DELAY_LEN must be a power of two"
#endif

#ifndef EB_DELAY_BIQUAD
#define EB_DELAY_BIQUAD 1             /* 0 is legal only away from 44,100 Hz */
#endif

/* The 26 coefficient cells of the stage, named by their offset in the sealed
 * engine's context so every one can be traced back to a measurement. */
typedef struct {
    float b0, b1, b2, a1, a2;   /* 102368 102384 102400 102416 102432 HIGH CUT DF-I */
    float mixA;                 /* 102448  1.0 only at 44,100 Hz             */
    float svf_g, svf_r;         /* 102464 102480  HIGH CUT 2-pole SVF        */
    float mixB;                 /* 102496  0.0 = HIGH CUT bypassed (byte 14) */
    float dry, wet;             /* 102512 102528  DIRECT LEVEL, LEVEL        */
    float fb;                   /* 102560  FEEDBACK                          */
    float on;                   /* 102576  the OFF gate (LEVEL >= 2)         */
    float mute;                 /* 102592                                    */
    float lp_g;                 /* 102608  LF DAMP FREQ                      */
    float k624;                 /* 102624  1.0 in every measured state        */
    float lf_damp;              /* 102640  LF DAMP                           */
    float hp_g;                 /* 102656  HF DAMP FREQ                      */
    float hf_damp;              /* 102672  HF DAMP                           */
    float k688;                 /* 102688  1.0 in every measured state        */
    float dc_g;                 /* 102704  DC blocker, rate constant         */
    float fade_k;               /* 102720                                    */
    float fade_up, fade_dn;     /* 102752 102768                             */
    float slew;                 /* 102784  time smoother, rate constant      */
    float time_target;          /* 102352  DELAY TIME                        */
    float fade_gain;            /* 84496                                     */
} eb_delay_cfg;

typedef struct {
    float s1[2], s2[2];                 /* input SVF                    */
    float bx1[2], bx2[2], by1[2], by2[2]; /* input DF-I biquad          */
    float lp[2], hp[2], dc[2];          /* loop damping filter          */
    float fbtap[2];                     /* loop output, one sample late */
    float t_step, t_smooth;             /* delay-time smoother          */
    float fade, fadesum;                /* mute fade                    */
    int32_t w[2];                       /* ring write index (DECREMENTS)*/
    int32_t overrun;                    /* tap did not fit EB_DELAY_LEN */
    float ring[2][EB_DELAY_LEN];        /* LAST: the PSRAM candidate    */
} eb_delay_state;

/* One sample, both channels. `route_change` is the sealed engine's cell
 * 11022348 (an effect-routing change forces the fade to 0 -- the click
 * suppressor). */
void eb_delay_process(const eb_delay_cfg *c, eb_delay_state *s,
                      int route_change, float xL, float xR,
                      float *outL, float *outR);

#endif /* ENGINEB_EB_DELAY_H */
