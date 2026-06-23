/* test_master_smoke.c — crash/NaN smoke test for the full driver pipeline:
 * init -> per-sample (voice render -> master/chorus process -> stereo out).
 *
 * Per the handoff, NaN/crash checks are smoke-tests only, NOT a definition of
 * "correct". This confirms the master process (sub_180363380) and the driver
 * glue run end-to-end without crashing and stay finite. With the chorus
 * coefficients (sub_180388170) not yet captured, those fields are zero and the
 * chorus is inert; the output may be silent — that is expected missing-data
 * behaviour, not a failure.
 */
#include "../src/juno_engine.h"
#include "../src/juno_driver.h"
#include <stdlib.h>
#include <stdio.h>
#include <math.h>

int main(void)
{
    unsigned char *st = calloc(1, JUNO_STATE_BYTES);
    if (!st) { printf("alloc failed\n"); return 1; }

    JF(st, 16) = 44100.0f;
    juno_chorus_init(st);                   /* constructor: delay lengths + zero */
    uint32_t rate = juno_engine_init(st);   /* voice coefficients */
    juno_chorus_coeffs_apply(st);           /* chorus float coeffs (no-op until captured) */

    static struct juno_host_shim shim;
    juno_driver_attach_host(st, &shim, 0 /* dry/bypass */);
    printf("init done; rate=%u; chorus mode=0 (dry)\n", rate);
    printf("BBD delay-line length sentinel state[2199956] = 0x%X (expect 0x80000)\n",
           JI(st, 2199956));

    float l = 0.0f, r = 0.0f;
    int nonfinite = 0, ran_master = 0;
    for (int i = 0; i < 2048; ++i) {
        ran_master = juno_driver_render_sample(st, &l, &r);
        if (!isfinite(l) || !isfinite(r)) ++nonfinite;
    }

    printf("ran 2048 samples; last out = (%g, %g); nonfinite = %d\n", l, r, nonfinite);
    printf("path: %s\n", ran_master
           ? "full master/chorus (coeffs loaded)"
           : "dry voice sum (chorus coeffs from sub_180388170 not yet captured)");
    if (nonfinite) { printf("FAIL: non-finite output from master pipeline\n"); free(st); return 1; }
    printf("OK: init + driver + master_render linked & ran clean (finite, no crash)\n");
    free(st);
    return 0;
}
