/* eb_master.h — engine B's OWN master chain: eight voice samples in, one
 * stereo sample out, with no port state anywhere.
 *
 * This is the piece task 1b-2 needs and 1b-0 explicitly did not have. 1b-0
 * gated engine B's VOICE chain by feeding its samples into the PORT's
 * juno_master_render; the master was still the port's. This assembles the ten
 * gated master modules into the chain the port's function actually is.
 *
 * THE ORDER IS THE PORT'S, and one step of it is counter-intuitive enough to
 * state plainly: THE EFFECT STAGE RUNS AFTER THE OUTPUT IS ALREADY FORMED.
 * src/master_render.c writes the two output cells at :2367/:2375 (the
 * master-out stage) and only then dispatches the EFFECT arms at :2378. The
 * final samples at :2941 are 2x those cells. So an effect arm contributes
 * NOTHING to the sample it runs in -- it writes cells 84672 and 84704, which
 * the INPUT stage reads on the NEXT sample. The effect send is a one-sample
 * feedback loop, not an insert, and modelling it as an insert would be wrong
 * in a way no cold single-note test could show.
 *
 *   voices[8] -> master_in -> (v36, v38) and cell 84624
 *             -> DELAY dispatch on delay_type
 *             -> reverb -> master_out -> the stereo output
 *             -> EFFECT dispatch on effect_type, reading cell 84624
 *             -> feedback cells 84672 / 84704, consumed next sample
 *
 * ---------------------------------------------------------------------------
 * THE RINGS ARE THE CALLER'S, DELIBERATELY. Six of the delay arms carry a
 * power-of-two ring, and MEASURED over all 64 factory patches the port sizes
 * them at 6.10 MB in total -- three of 524,288 floats (2 MB each), three
 * smaller, one of 1,024. That does not fit any microcontroller this project
 * targets, and hiding it inside a struct would make it look like it does.
 *
 * So `eb_master_rings` is passed IN, with its lengths, and the engine checks
 * every access against them. The host gate can point them straight at the
 * port's own cells (exact, no extra memory); firmware must decide what it can
 * afford and will find the number stated here rather than discovered by a
 * linker error. This follows eb_delay.h's precedent, where EB_DELAY_LEN is a
 * compile-time budget with an overrun flag and the ring is last in the struct
 * so it can live in external memory.
 *
 * ⚠ ONE PORTABILITY DEBT, found by LINKING the chain outside the harness for
 * the first time: eb_delay_t23 and eb_delay_t5 call `juno_pitch_poly` and
 * `juno_triangle`, which live in src/juno_dsp.c -- the PORT. Engine B cannot
 * be built for a target without them, so either src/juno_dsp.c comes along or
 * those two get engine B implementations (engine_b/triangle.h already has one
 * candidate). Recorded here because the null gates link the whole port and
 * would never have surfaced it; the first firmware build would have.
 */
#ifndef ENGINEB_EB_MASTER_H
#define ENGINEB_EB_MASTER_H

#include <stdint.h>
#include "eb_master_in.h"
#include "eb_master_out.h"
#include "eb_delay_t1.h"
#include "eb_delay_t23.h"
#include "eb_delay_t5.h"
#include "eb_fx_e1.h"
#include "eb_fx_e5.h"
#include "eb_dly_t4.h"
#include "eb_fx_e0.h"
#include "eb_delay.h"
#include "eb_reverb.h"
#include "eb_chorus.h"

enum {
    EB_MASTER_OK = 0,
    /* RETIRED BY TASK 1b-3, and kept in the enum so a caller that still tests
     * for it compiles. Every DELAY TYPE (0-5) and every EFFECT TYPE (0-5) now
     * has a module. The two that had none -- DELAY TYPE 4 and the EFFECT
     * LABEL_164 core -- are selected by NO factory patch, so they were reached
     * by DOCTORING the bank's own nibble pair (null_b.py's DOCTOR table), which
     * drives the instrument's own recall with a value the factory bank happens
     * not to carry. A user preset can select them, and the trunk is the full
     * instrument, so they were never optional. */
    EB_MASTER_UNSUPPORTED_ARM = 1
};

/* Caller-owned ring storage. Each length MUST be a power of two, and must be
 * the same length the coefficients were built against -- the port's own ring
 * length cells. */
typedef struct {
    float *t1;    int32_t t1_len;      /* port 4298096  */
    float *t23;   int32_t t23_len;     /* port 6396640  */
    float *t5_0;  int32_t t5_0_len;    /* port 6497616  */
    float *t5_1;  int32_t t5_1_len;    /* port 8594784  */
    float *t5_2;  int32_t t5_2_len;    /* port 10693488 */
    float *t5_3;  int32_t t5_3_len;    /* port 10726272 */
    float *e5;    int32_t e5_len;      /* port 96928    */
    float *t4_0;  int32_t t4_0_len;    /* port 6430944  */
    float *t4_1;  int32_t t4_1_len;    /* port 6463728  */
} eb_master_rings;

typedef struct {
    eb_master_in_coef  in;
    eb_dly1_coef       d1;
    eb_dly_t4_coef     d4;
    eb_fx_e0_coef      e0;
    eb_delay_cfg       dcore;
    eb_dly23_coef      d23;
    eb_dly5_coef       d5;
    eb_reverb_cfg      rev;
    eb_chorus_coef     cho;
    eb_master_out_coef out;
    eb_fx_e1_coef      e1;
    eb_fx_e5_coef      e5;
    /* The delay CORE's output gain, port cell 101744 (the port's v418). The
     * four ARM modules apply it internally -- it is their last multiply -- but
     * the core is a module of its own and the port applies the gain, and the
     * CHANNEL CROSS, outside it. */
    float   k101744;
    int32_t delay_type;      /* the port's v39,  cell JUNO_PROG_DLY */
    int32_t effect_type;     /* the port's v551, cell JUNO_PROG_EFX */
} eb_master_coef;

typedef struct {
    eb_master_in_state in;
    eb_dly1_state      d1;
    eb_dly_t4_state    d4;
    eb_fx_e0_state     e0;
    eb_dly23_state     d23;
    eb_dly5_state      d5;
    eb_fx_e1_state     e1;
    eb_fx_e5_state     e5;
    eb_reverb_state    rev;
    eb_chorus_state    cho;
    eb_delay_state     dcore;        /* LAST: it carries its own large ring */

    /* THE ONE-SAMPLE FEEDBACK, port cells 84672 and 84704. Written by the
     * EFFECT stage at the end of a sample, read by the INPUT stage at the
     * start of the next. They are engine-level state because they are the only
     * values that cross the sample boundary between two different blocks. */
    float   fb84672, fb84704;

    int32_t route_change;            /* port cell 11022348 */
    /* EB_REV_NTAP, not 33. eb_reverb_process reads EB_REV_NTAP entries and
     * EB_REV_NTAP is 34, so a [33] array is read one past its end and the
     * last tap latches garbage. MEASURED: with [33] the reverb's A output
     * stayed EXACT and only its B output drifted in the last bits, which is
     * what a single wrong tap depth in one tank looks like. Found by comparing
     * the two eb_reverb_states byte for byte -- the first differing byte was
     * 196, which offsetof puts inside taps[33]. */
    int32_t rev_pending[EB_REV_NTAP];
    int32_t rev_wipe;
} eb_master_state;

/* One stereo sample. `voices` is eight per-voice samples in voice order --
 * exactly what eb_engine_render_voices() writes. Returns EB_MASTER_OK, or
 * EB_MASTER_UNSUPPORTED_ARM with silence when the patch selects a dispatch arm
 * engine B has not transcribed. */
int eb_master_render(eb_master_state *s, const eb_master_coef *c,
                     const eb_master_rings *r, const float *voices,
                     float *outL, float *outR);

#endif /* ENGINEB_EB_MASTER_H */
