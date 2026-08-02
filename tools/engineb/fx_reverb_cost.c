/* fx_reverb_cost.c -- executed-instruction driver so the REVERB arm's share of
 * juno_master_render can be MEASURED (callgrind) instead of modelled.
 *
 * argv[1] = samples, argv[2] = mode.
 *   mode 1 = reverb tank RUNS (the engine is warmed so the lazy wipe has expired
 *            and the mute crossfade 11022032 has reached 1.0)
 *   mode 0 = reverb tank does NOT run: the gate cell 10759376 is forced to 0, which
 *            takes master_render's `if (mute <= 0 || gate <= 0)` early arm.
 * Everything else in the master (chorus, delay, output stage) is identical, so the
 * DIFFERENCE in executed instructions inside juno_master_render is the reverb arm.
 *
 * The warm-up loop is OUTSIDE the measured region only in the sense that both modes
 * run the same warm-up; callgrind counts it in both and it cancels in the difference.
 */
#include <stdio.h>
#include <stdlib.h>

void *juno_gui_create(float, int);
void juno_gui_poke(void *, int, unsigned);
void juno_gui_set(void *, int, float);
float *juno_master_render(unsigned char *, float **, float **);

int main(int argc, char **argv)
{
    int n = argc > 1 ? atoi(argv[1]) : 20000;
    int mode = argc > 2 ? atoi(argv[2]) : 1;
    void *c = juno_gui_create(48000.0f, 0);
    unsigned char *st = *(unsigned char **)c;
    float vb[8], scratch = 0.0f, oL = 0.0f, oR = 0.0f;
    float *a2[16], *a3[2];
    int i, k;
    double acc = 0.0;
    for (k = 0; k < 16; ++k) a2[k] = &scratch;
    for (k = 0; k < 8; ++k) a2[2 * k] = &vb[k];
    a3[0] = &oL; a3[1] = &oR;
    for (i = 0; i < 6000; ++i) {          /* wipe (256) + mute ramp (2500) */
        for (k = 0; k < 8; ++k) vb[k] = 0.0f;
        scratch = 0.0f;
        juno_master_render(st, a2, a3);
    }
    if (!mode) juno_gui_set(c, 10759376, 0.0f);   /* reverb gate off */
    for (i = 0; i < n; ++i) {
        for (k = 0; k < 8; ++k) vb[k] = 0.0f;
        vb[0] = (float)((i % 97) - 48) * 0.01f;
        scratch = 0.0f;
        juno_master_render(st, a2, a3);
        acc += oL + oR;
    }
    printf("%d samples, mode=%d, acc=%g\n", n, mode, acc);
    return 0;
}
