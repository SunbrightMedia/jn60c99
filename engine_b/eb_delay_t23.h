/* eb_delay_t23.h -- GENERATED SKELETON, see the .c */
#ifndef ENGINEB_EB_DELAY_T23_H
#define ENGINEB_EB_DELAY_T23_H
#include <stdint.h>

typedef struct {
    float   k101744;
    float   k6395312;
    float   k6395328;
    float   k6395408;
    /* ⚑ THE PER-SAMPLE DOUBLE-PRECISION PITCH CALL, HOISTED. EXACTLY 0.
     *
     * MEASURED on the user's board 2026-08-12: patches with DELAY TYPE 2, 3 or
     * 5 cost about DOUBLE -- ~10,000 cycles against ~5,200 -- and 18 of the 64
     * factory patches use them. The cause is this expression, which ran ONCE
     * PER SAMPLE:
     *
     *     v = eb_pitch_poly((double)(float)(k_a + k_b));
     *     v = clamp(v, -512, 512);
     *
     * eb_pitch_poly is a THIRTEEN-TERM DOUBLE-PRECISION polynomial and the
     * ESP32-S3 HAS NO DOUBLE FPU, so every term is a libgcc soft-double call.
     * CLAUDE.md already prices that shape at 18,200-22,300 instructions a
     * sample where it appears in the DCO.
     *
     * BOTH INPUTS ARE COEFFICIENTS. k_a and k_b are set once by
     * eb_master_coefs_build from CF(base, ...) and never change between
     * recalls, so the whole expression is LOOP-INVARIANT and was being
     * recomputed 44,100 times a second for a value that cannot move.
     *
     * This is not an approximation and needs no sonic gate: the same
     * expression, same types, same order, evaluated once at build time. The
     * null must stay EXACTLY 0 and that is the whole proof. */
    float   pitchmod_pre;
    /* ⚠ THE SECOND HOIST WAS TRIED AND THE NULL REFUSED IT. The LFO phase
     * increment (v255 * k6395648, through the wrap ladder and the k6395664
     * zero-guard) is loop-invariant BY INSPECTION and folding it to a float
     * constant broke 2 of 36 scenarios at -0.9 dB. The render loop computes
     * that ladder with DOUBLE literals -- `v258 < 4.0`, `v258 + -2.0` -- so
     * each step is a float promoted to double, added, and rounded back, and a
     * float-only fold is NOT the same function. It is worth a few compares and
     * it is not worth being wrong; the null said so on its first run. */
    float   k6395648;
    float   k6395664;
    float   k6395696;
    float   k6395712;
    float   k6396128;
    float   k6396144;
    float   k6396160;
    float   k6396176;
    float   k6396192;
    float   k6396208;
    float   k6396224;
    float   k6396240;
    float   k6396256;
    float   k6396272;
    float   k6396288;
    float   k6396304;
    float   k6396320;
    float   k6396336;
    float   k6396352;
    float   k6396368;
    float   k6396384;
    float   k6396400;
    float   k6396416;
    float   k6396432;
    float   k6396448;
    float   k6396464;
    float   k6396480;
    float   k6396496;
    float   k6396512;
    float   k6396528;
    float   k6396544;
    float   k6396560;
    float   k6396576;
    float   k6396592;
    float   k6396608;
    float   k6396624;
    int32_t k6429412;   /* ring length, a power of two */
} eb_dly23_coef;

typedef struct {
    float    s6395344;
    float    s6395360;
    float    s6395376;
    float    s6395600;
    float    s6395632;
    float    s6395680;
    float    s6395728;
    float    s6395744;
    float    s6395760;
    float    s6395776;
    float    s6395792;
    float    s6395808;
    float    s6395824;
    float    s6395840;
    float    s6395856;
    float    s6395872;
    float    s6395888;
    float    s6395904;
    float    s6395920;
    float    s6395936;
    float    s6395952;
    float    s6395968;
    float    s6395984;
    float    s6396000;
    float    s6396016;
    float    s6396032;
    float    s6396048;
    float    s6396064;
    float    s6396080;
    float    s6396096;
    float    s6396112;
    float    s6429424;
    float    s6429440;
    float    s6429444;
    float    s6429448;
    float    s6429456;
    float    s6429460;
    float    s6429464;
    uint32_t s6395616;
    int32_t  s6429408;
    int32_t  s11022348;
    float   *ring;   /* the port's 6396640.., k6429412 entries */
} eb_dly23_state;

void eb_dly23_tick(eb_dly23_state *s, const eb_dly23_coef *c,
                   float in36, float in38, float k5,
                   float *o176, float *o177, float *o56, float *o58);

#endif
