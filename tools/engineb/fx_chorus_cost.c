/* fx_chorus_cost.c — executed-instruction driver for the MASTER stage, so the
 * chorus arm's share can be MEASURED (callgrind) instead of modelled.
 *
 * argv[1] = number of samples, argv[2] = EFFECT TYPE routing (engine cell
 * 11022052): 2 = chorus arm, 0 = pan arm (chorus not executed).
 * The same master function runs in both arms, so the DIFFERENCE in executed
 * instructions inside juno_master_render is the chorus arm's cost.
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void *juno_gui_create(float, int);
void juno_gui_poke(void *, int, unsigned);
float *juno_master_render(unsigned char *, float **, float **);

int main(int argc, char **argv)
{
    int n = argc > 1 ? atoi(argv[1]) : 20000;
    unsigned et = argc > 2 ? (unsigned)atoi(argv[2]) : 2u;
    void *c = juno_gui_create(48000.0f, 0);
    unsigned char *st = *(unsigned char **)c;
    float vb[8], scratch = 0.0f, oL = 0.0f, oR = 0.0f;
    float *a2[16], *a3[2];
    int i, k;
    double acc = 0.0;
    juno_gui_poke(c, 11022052, et);
    for (k = 0; k < 16; ++k) a2[k] = &scratch;
    for (k = 0; k < 8; ++k) a2[2 * k] = &vb[k];
    a3[0] = &oL; a3[1] = &oR;
    for (i = 0; i < n; ++i) {
        for (k = 0; k < 8; ++k) vb[k] = 0.0f;
        vb[0] = (float)((i % 97) - 48) * 0.01f;
        scratch = 0.0f;
        juno_master_render(st, a2, a3);
        acc += oL + oR;
    }
    printf("%d samples, et=%u, acc=%g\n", n, et, acc);
    return 0;
}
