/* eb_chorus.h — ENGINE B MODULE M-CHORUS: the JUNO-60 BBD chorus (slot 2,
 * block A), the arm that runs when EFFECT TYPE (cell 11022052) is 2, 3 or 4.
 *
 * SCOPE. This module owns src/master_render.c:2753-2935 and nothing else: the
 * chorus input mix, its two-biquad + DC-block input filter, the BBD delay line
 * and its two interpolating taps, the LFO, the delay-time smoother and startup
 * ramp, the two output state-variable filters, the BBD noise generator, and the
 * dry/wet mix. It does NOT own EFFECT TYPE 0/1 (pan/distortion), 5 (ensemble,
 * block B), the delay or the reverb.
 *
 * PROVENANCE
 *   docs/engineb/FX_CHORUS.md — the MEASURED behavioural specification.
 *   src/master_render.c:2753-2935 — the arm this file replaces, READ line by
 *   line. Every arithmetic expression below is in the port's own evaluation
 *   order and its own association; nothing is re-expressed. "Algebraically the
 *   same number" is not the same float, and this project has already shipped
 *   that mistake once (fmodf, 8,388,608 of 2^32 inputs).
 *
 * WHAT ENGINE B CHANGES, and why each change cannot change a number
 *   1. The 30-cell shift chain at :2754-2780 becomes 30 struct fields moved by
 *      the compiler in registers. Moving a value is not arithmetic.
 *   2. The 11 MB flat state block becomes a ~4.4 KB struct: the same floats,
 *      addressed by a small constant offset from one pointer instead of a
 *      6-digit one. Addressing is not arithmetic either.
 *   3. Coefficients live in a separate read-only struct so a recall writes them
 *      once instead of the DSP re-loading them from scattered cells per sample.
 *   NOTHING ELSE CHANGES. This module is intended to null EXACTLY 0, not to
 *   -100 dB, and tools/engineb/null_b.py --module chorus is what decides.
 *
 * MEMORY, stated in bytes (the brief asks for this explicitly)
 *   eb_chorus_state : EB_CHORUS_RING*4 + 56 floats/ints
 *                   = 4096 + 224 = 4,320 B at the default ring
 *   eb_chorus_coef  : 40 floats + 1 int = 164 B
 *   TOTAL 4,484 B, of which the delay line is 4,096 B and is the only
 *   allocation that scales. EB_CHORUS_RING is a COMPILE-TIME budget: define it
 *   to 512 and the struct is 2,272 B. MEASURED (FX_CHORUS.md §2) the longest
 *   delay ever reached at 48 kHz is 456 samples, so 512 is provably sufficient
 *   there; EB_CHORUS_STATIC_ASSERT below refuses a ring that cannot hold
 *   EB_CHORUS_MAX_DELAY + 2. The line is one contiguous array so it can be
 *   moved to PSRAM by changing where the struct lives, with no DSP edit.
 */
#ifndef ENGINEB_EB_CHORUS_H
#define ENGINEB_EB_CHORUS_H

#include <stdint.h>

/* COMPILE-TIME BUDGET. The plugin's own ring length (cell 95828) is 1024 at
 * every host rate (MEASURED). Keep 1024 unless the target forces 512. */
#ifndef EB_CHORUS_RING
#define EB_CHORUS_RING 1024
#endif

/* The longest modulated delay the chorus can ask for, in samples. MEASURED at
 * 48 kHz: 456. Held at 512 so the assertion has margin over the 88.2/96 kHz
 * arms, which have a longer minimum delay in samples. */
#ifndef EB_CHORUS_MAX_DELAY
#define EB_CHORUS_MAX_DELAY 512
#endif

typedef char eb_chorus_ring_budget_assert[
    (EB_CHORUS_RING >= EB_CHORUS_MAX_DELAY + 2 &&
     (EB_CHORUS_RING & (EB_CHORUS_RING - 1)) == 0) ? 1 : -1];

/* ---------------------------------------------------------------- coefficients
 * Written by recall / prepare, read-only in the audio path. The comment on each
 * field is the port state cell it comes from, so the shim's load is checkable
 * against src/master_render.c by grep. */
typedef struct {
    float dtime;      /* 91120  delay time target, units of 16384 samples     */
    float depth_r;    /* 91136  right-channel depth trim                      */
    float rate;       /* 91152  LFO phase increment (the ONLY Chorus I/II diff)*/
    float phase_off;  /* 91168  L/R phase offset, 1.0 = antiphase             */
    float depth;      /* 91184  LFO depth                                     */
    float noise;      /* 91200  BBD noise level = EFFECT TONE * 0.005 / 255   */
    float dry;        /* 91216  dry gain, constant 1.3                        */
    float wet;        /* 91232  wet gain, from the EFFECT DEPTH table         */
    float smco;       /* 91248  delay-time smoother coefficient (~6.1e-5)     */
    float onoff;      /* 91264                                                */
    float mute;       /* 91280                                                */
    float b0, b1, b2, a1, a2;        /* 91296 91312 91328 91344 91360 biquad  */
    float hb0, hb1, ha1;             /* 91376 91392 91408 DC block            */
    float svf_f;      /* 91424  Chamberlin f                                  */
    float svf_d;      /* 91440  Chamberlin damping                            */
    float eps;        /* 91456  LFO ramp epsilon, +/-5e-7                     */
    float mod_scale;  /* 91472  SR_table / 16384  (see FX_CHORUS.md §4)       */
    float mod_off;    /* 91488  minimum delay, 1.5 ms                         */
    float ramp_inc;   /* 91504  startup ramp increment                        */
    float ramp_max;   /* 91520                                                */
    float slew_up;    /* 91536                                                */
    float slew_dn;    /* 91552                                                */
    float n_gain;     /* 91568  noise generator gain                          */
    float n_off;      /* 91584  0.3                                           */
    float nf[8];      /* 91600 91616 91632 91648 91664 91680 91696 91712      */
    int   ring_len;   /* 95828  MUST equal EB_CHORUS_RING                     */
} eb_chorus_coef;

/* ---------------------------------------------------------------- state
 * Field names are the port cell offset minus 90000 (c<n>) for the block-A
 * cells, so this struct diffs against src/master_render.c by eye. */
typedef struct {
    float line[EB_CHORUS_RING];   /* 91728.. the BBD line, 4,096 B by default */
    int32_t w;                    /* 95824   write index, decrements          */
    float line_in;                /* 95840   value written to the line        */
    float c368, c384;             /* chorus input L / R                       */
    float c400, c416, c432, c448, c464, c480, c496, c512;   /* input filter   */
    float c528, c544, c560, c576, c592, c608;               /* output SVFs    */
    float c624, c640, c656, c672;                           /* LFO            */
    float c688, c704, c720, c736, c752;                     /* smoother, ramp */
    float c768, c784, c800, c816;                           /* modulation     */
    float c832, c848;                                       /* noise source   */
    float c864, c880, c896, c912, c928, c944;               /* noise filt L   */
    float c960, c976, c992, c1008, c1024, c1040;            /* noise filt R   */
    float c1056, c1072;                                     /* wet L / R      */
    float c1088, c1104;                                     /* block output   */
    float t856, t860, t864, t872, t876, t880;   /* 95856.. tap scratch cells  */
} eb_chorus_state;

/* Zero-initialise. MEASURED (FX_CHORUS.md §3): the plugin's power-on LFO phase
 * is exactly 0 and the ring is zero, so an all-zero state IS the power-on
 * state. The ramp (c752) climbs from 0 by itself. */
void eb_chorus_reset(eb_chorus_state *s);

/* One sample. `in` is the chorus input (MEASURED: 12.0 x the voice sum); it
 * feeds both channels. Writes *outL / *outR.
 *
 * v56 / v58 are the two clamp fall-backs the port's arm inherits from earlier
 * in master_render as an IDA artefact of max()/clamp(). MEASURED over 14,000
 * chorus-arm entries on 7 patches: they are ALWAYS 0.0 and -1.0, so
 * eb_chorus_tick() (the engine entry) hard-codes them, while
 * eb_chorus_tick_x() takes them and is what the null shim calls, so the null
 * cannot be green because of an assumption. */
void eb_chorus_tick_x(eb_chorus_state *s, const eb_chorus_coef *k,
                      float in, float *outL, float *outR,
                      float v56, float v58);
void eb_chorus_tick(eb_chorus_state *s, const eb_chorus_coef *k,
                    float in, float *outL, float *outR);

#endif /* ENGINEB_EB_CHORUS_H */
