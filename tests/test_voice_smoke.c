/* test_voice_smoke.c — crash/NaN smoke test for the init + voice_render path.
 *
 * Per the handoff, NaN/crash checks are smoke-tests only, NOT a definition of
 * "correct" (that is per-stage validation against the decompile). This confirms
 * the engine initializes with the real coefficients (juno_engine_init) and that
 * voice_render then runs end-to-end without crashing and stays finite.
 */
#include "../src/juno_engine.h"
#include <stdlib.h>
#include <stdio.h>
#include <math.h>

int main(void)
{
    unsigned char *st = calloc(1, JUNO_STATE_BYTES);
    if (!st) { printf("alloc failed\n"); return 1; }

    JF(st, 16) = 44100.0f;                 /* sample rate (read by the init) */
    uint32_t rate = juno_engine_init(st);  /* fill real coefficients */
    printf("init done; rate=%u\n", rate);

    float l = 0.0f, r = 0.0f;
    int nonfinite = 0;
    for (int i = 0; i < 1024; ++i) {
        juno_voice_render(st, 0, &l, &r);
        if (!isfinite(l) || !isfinite(r)) ++nonfinite;
    }

    printf("ran 1024 samples; last out = (%g, %g); nonfinite samples = %d\n",
           l, r, nonfinite);
    if (nonfinite) { printf("FAIL: non-finite output after init\n"); free(st); return 1; }
    printf("OK: init + voice_render ran clean (finite, no crash)\n");
    free(st);
    return 0;
}
