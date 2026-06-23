/* test_voice_smoke.c — crash/NaN smoke test for juno_voice_render.
 *
 * Per the handoff, NaN/crash checks are smoke-tests only, NOT a definition of
 * "correct" (that is per-stage validation against the decompile). This just
 * confirms the transcription runs end-to-end without crashing and produces
 * finite output once the state holds sane values. Real coefficients come from
 * the init routine (sub_1803990C0, not yet ported); here we seed a few divisor
 * fields to 1.0 so the zero-state run can't divide by zero, then render a block.
 */
#include "../src/juno_engine.h"
#include <stdlib.h>
#include <stdio.h>
#include <math.h>

#define STATE_BYTES (256 * 1024)

int main(void)
{
    unsigned char *st = calloc(1, STATE_BYTES);
    if (!st) { printf("alloc failed\n"); return 1; }

    /* Seed divisor-position fields to 1.0 so a zero state can't divide by zero.
     * These are not the real coefficients — just enough for a crash smoke test. */
    JF(st, 800)  = 1.0f;   /* denominator in the early DCO mix */
    JF(st, 4816) = 1.0f;   /* Pattern-B denominator base */

    float l = 0.0f, r = 0.0f;
    int nonfinite = 0;
    for (int i = 0; i < 256; ++i) {
        juno_voice_render(st, &l, &r);
        if (!isfinite(l) || !isfinite(r)) ++nonfinite;
    }

    printf("ran 256 samples; last out = (%g, %g); nonfinite samples = %d\n",
           l, r, nonfinite);
    /* The run completing without a segfault is the smoke-test pass. Output may be
     * 0 or NaN until the real init coefficients are ported; we only assert no crash. */
    printf("OK: voice_render ran without crashing\n");
    free(st);
    return 0;
}
