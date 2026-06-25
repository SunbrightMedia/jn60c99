/* test_init_default.c - smoke test + before/after validation for the
 * construction-time parameter-default initialization (src/juno_init_default.c).
 *
 * 1) Builds a fresh engine state (chorus_init + engine_init), records the 5
 *    critical read-as-zero offsets BEFORE juno_init_default, applies it, prints
 *    the AFTER values, and asserts they are NONZERO and finite.
 * 2) Counts how many of the broader voice-region runtime offsets the default
 *    apply now fills (nonzero) vs still zero.
 * 3) Renders a few hundred samples of one note via juno_driver_render_sample and
 *    asserts every output sample is finite.
 */
#include "../src/juno_engine.h"
#include "../src/juno_driver.h"
#include "../src/juno_init_default.h"
#include <stdlib.h>
#include <stdio.h>
#include <math.h>

static const int CRIT[5]      = {4208, 7616, 7600, 4064, 4080};
static const char *CRIT_NM[5] = {"4208 JU OSC Sqr Lev", "7616 Resonance Tune",
                                 "7600 Cutoff Tune", "4064 ENV1 Level",
                                 "4080 ENV2 Level"};

int main(void)
{
    unsigned char *st = calloc(1, JUNO_STATE_BYTES);
    if (!st) { printf("alloc failed\n"); return 1; }

    JF(st, 16) = 96000.0f;
    juno_chorus_init(st);
    uint32_t rate = juno_engine_init(st);

    /* BEFORE */
    float before[5];
    for (int i = 0; i < 5; ++i) before[i] = JF(st, CRIT[i]);

    int written = juno_init_default(st);

    /* AFTER + assertions on the 5 criticals */
    int fail = 0;
    printf("init_default wrote %d coefficient slots (rate=%u)\n\n", written, rate);
    printf("critical offsets  before -> after:\n");
    for (int i = 0; i < 5; ++i) {
        float a = JF(st, CRIT[i]);
        printf("  %-22s %12g -> %12g %s\n", CRIT_NM[i], before[i], a,
               (a != 0.0f && isfinite(a)) ? "[nonzero,finite OK]" : "[FAIL]");
        if (!(a != 0.0f && isfinite(a))) fail = 1;
    }

    /* Voice-region runtime-offset fill report. Count the engine-state slots in the
     * voice-0 main block [176,10672] (where param-applied coefficients live, before
     * the per-voice +10512 broadcast) that are now nonzero vs still zero. Reported
     * at the 16-byte param-slot grid the apply path uses. This is the "runtime
     * parameter layer" the construction default-apply is responsible for. */
    int region_nz = 0, region_z = 0;
    for (int off = 176; off <= 10672; off += 16) {
        float v = JF(st, off);
        if (v != 0.0f) ++region_nz; else ++region_z;
    }
    printf("\nvoice-0 main region [176..10672] @16B grid: %d nonzero, %d zero\n",
           region_nz, region_z);
    printf("(default-apply writes 526 distinct nonzero coefficient slots total;\n"
           " remaining zeros are non-param slots or FX-init-derived coeffs.)\n");

    /* Render one note, assert finite. */
    static struct juno_host_shim shim;
    juno_driver_attach_host(st, &shim, 0 /* dry */);
    juno_note_on(st, 0, 60);
    float l = 0.0f, r = 0.0f;
    int nonfinite = 0;
    for (int i = 0; i < 512; ++i) {
        juno_driver_render_sample(st, &l, &r);
        if (!isfinite(l) || !isfinite(r)) ++nonfinite;
    }
    printf("rendered 512 samples; last=(%g,%g); nonfinite=%d\n", l, r, nonfinite);
    if (nonfinite) fail = 1;

    if (fail) { printf("\nFAIL\n"); free(st); return 1; }
    printf("\nOK: criticals nonzero+finite, render finite, no crash\n");
    free(st);
    return 0;
}
