/* eb_dcoprep.c — see eb_dcoprep.h. A transcription of
 * src/voice_render.c:1702-1717 with the port's variable numbers kept. */
#include "eb_dcoprep.h"
#include <math.h>

/* EB_PW_RANGE -- write-only instrumentation, and the one question that
 * decides the WAVETABLE DCO. A mip-mapped wavetable is the only remaining
 * lever that changes the DCO's order of magnitude, and it has to be rebuilt
 * whenever the PULSE WIDTH moves. If pw is static on most patches, one table
 * per note serves. If it moves every sample, a table is useless and the lever
 * dies before it is written.
 *
 * Reports to /tmp/eb_pw.log, for the reason eb_vcf_ladder.c records: the null
 * harness discards its workers' stderr, so a stderr report reads as "pw never
 * moved" -- a measurement that silently measures nothing. */
#ifndef EB_PW_RANGE
#define EB_PW_RANGE 0
#endif
#if EB_PW_RANGE
#include <stdio.h>
#include <math.h>
static float ebpw_prev[8], ebpw_lo = 1e30f, ebpw_hi = -1e30f;
static float ebpw_dmax = 0.0f;
static int ebpw_seen[8], ebpw_slot = 0;
static unsigned long ebpw_n = 0, ebpw_moved = 0;
/* THE STEP HISTOGRAM. "pw moves on 52 % of samples" does not say whether it
 * CRAWLS or JUMPS, and a wavetable only cares about the size. Decade buckets
 * of |dpw| per sample. */
static unsigned long ebpw_bkt[8];
/* THE INCREMENT'S OWN RANGE. The band-limited DCO's edge detection tests
 * `p < prev`, which is a wrap only while the phase INCREASES. Whether the port
 * can ever hand it a negative increment is not a thing to reason about: the
 * expression is fmaxf(k5568, pitch*k5536), floored by a RECALLED cell, and the
 * sign of that cell across the bank is a measurement. */
static float ebpw_ilo = 1e30f, ebpw_ihi = -1e30f;
static unsigned long ebpw_ineg = 0;
static void ebpw_report(void) __attribute__((destructor));
static void ebpw_report(void)
{
    FILE *f;
    if (!ebpw_n) return;
    f = fopen("/tmp/eb_pw.log", "a");
    if (!f) return;
    fprintf(f, "inc=[%.9f,%.9f] negcalls=%lu\n",
            (double)ebpw_ilo, (double)ebpw_ihi, ebpw_ineg);
    fprintf(f, "calls=%lu moved=%lu span=[%.6f,%.6f] worststep=%.8f "
            "bkt=%lu,%lu,%lu,%lu,%lu,%lu,%lu,%lu\n",
            ebpw_n, ebpw_moved, (double)ebpw_lo, (double)ebpw_hi,
            (double)ebpw_dmax, ebpw_bkt[0], ebpw_bkt[1], ebpw_bkt[2],
            ebpw_bkt[3], ebpw_bkt[4], ebpw_bkt[5], ebpw_bkt[6], ebpw_bkt[7]);
    fclose(f);
}
#endif

float eb_dcoprep_tick(const eb_dcoprep_coef *c, float pitch, float pwmcv,
                      float in3808,
                      float *out4800, float *out4816, float *out5456)
{
    float v395 = pwmcv + c->k6304;
    float v396 = pitch * c->k5536;
    float v397 = c->k5520;
    float v398 = fmaxf(c->k5568, v396);
    float v399 = (float)(v395 * c->k6320) + c->k6288;
    float v400;

    *out4816 = v397 + in3808;
#if EB_PW_RANGE
    if (v398 < ebpw_ilo) ebpw_ilo = v398;
    if (v398 > ebpw_ihi) ebpw_ihi = v398;
    if (v398 < 0.0f) ++ebpw_ineg;
#endif
#if EB_PW_RANGE
    {   float pw = *out4816;
        ++ebpw_n;
        if (pw < ebpw_lo) ebpw_lo = pw;
        if (pw > ebpw_hi) ebpw_hi = pw;
        /* PER VOICE, through an 8-slot ring. The first version compared
         * consecutive calls, which are DIFFERENT VOICES: it reported pw
         * moving on 100 % of samples with a worst step of 0.83, which is the
         * CONDITION scatter between voices and not motion in time at all. A
         * measurement that compares the wrong two numbers is not a small
         * error -- it would have killed the wavetable lever outright. */
        int q = ebpw_slot; ebpw_slot = (ebpw_slot + 1) & 7;
        if (ebpw_seen[q]) {
            float d = fabsf(pw - ebpw_prev[q]);
            if (d > 0.0f) ++ebpw_moved;
            if (d > ebpw_dmax) ebpw_dmax = d;
            {   int bk = 0;
                if      (d == 0.0f)   bk = 0;
                else if (d < 1e-6f)   bk = 1;
                else if (d < 1e-5f)   bk = 2;
                else if (d < 1e-4f)   bk = 3;
                else if (d < 1e-3f)   bk = 4;
                else if (d < 1e-2f)   bk = 5;
                else if (d < 1e-1f)   bk = 6;
                else                  bk = 7;
                ++ebpw_bkt[bk];
            }
        }
        ebpw_seen[q] = 1; ebpw_prev[q] = pw;
    }
#endif
    if (v399 <= 0.0f)
        v400 = 0.0f;
    else
        v400 = v399;
    *out4800 = 0.00390625f / v398;
    *out5456 = v400;
    return v398;
}
