/* test_poly_consistency.c — proves the parameterised voice_render is faithful.
 *
 * The 8 plugin voice functions (sub_180369070..sub_180383F20) are byte-identical
 * modulo three region strides (main +v*10512, shared +0, aux +v*32), derived by
 * diffing their decompiled offset constants (docs/POLYPHONY.md). This test
 * VERIFIES that classification empirically: render each voice v IN ISOLATION with
 * the same note in its own region, and require its per-sample output to be
 * BIT-IDENTICAL to voice 0's. If any region were mis-classified (a per-voice
 * offset left unshifted, or a shared offset shifted), the voices would diverge.
 *
 * Isolation: only one voice's gate is opened per run, and only that voice is
 * rendered, so the shared block at 84272 evolves identically in every run (both
 * start from the same init and apply the same shared-block ops). Thus voice v
 * alone must equal voice 0 alone, sample for sample.
 */
#include "../src/juno_engine.h"
#include "../src/juno_driver.h"
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#define NFRAMES 4096
#define NOTE    60          /* MIDI C4 */

/* Render `voice` in isolation for NFRAMES samples into out[] (bit patterns). */
static void render_isolated(int voice, uint32_t *out)
{
    unsigned char *st = calloc(1, JUNO_STATE_BYTES);
    unsigned mb, aux;
    int i;
    if (!st) { printf("alloc failed\n"); exit(1); }

    JF(st, 16) = 96000.0f;
    juno_chorus_init(st);
    juno_engine_init(st);
    juno_runtime_coeffs_apply(st);            /* patch coeffs -> voice 0's block */
    juno_driver_seed_voices(st);              /* every voice gets voice 0's coeffs */

    mb  = (unsigned)voice * JUNO_VOICE_MAIN_STRIDE;
    aux = JUNO_VOICE_AUX_BASE0 + (unsigned)voice * JUNO_VOICE_AUX_STRIDE;
    JF(st, mb + 304) = (float)NOTE / 12.0f;   /* per-voice DCO note pitch  */
    JF(st, mb + 320) = 1.0f;                  /* per-voice gate (v29 input)*/
    JF(st, aux)      = 1.0f;                   /* one-shot DCO retrigger    */

    for (i = 0; i < NFRAMES; ++i) {
        float l = 0.0f, r = 0.0f;
        juno_voice_render(st, voice, &l, &r);
        memcpy(&out[i], &l, 4);
    }
    free(st);
}

int main(void)
{
    static uint32_t ref[NFRAMES], cur[NFRAMES];
    int v, i, nonzero = 0, fails = 0;

    render_isolated(0, ref);
    for (i = 0; i < NFRAMES; ++i) if (ref[i] != 0) ++nonzero;
    printf("voice 0: %d/%d nonzero samples\n", nonzero, NFRAMES);
    if (nonzero == 0) {
        printf("FAIL: voice 0 produced pure silence — test is meaningless\n");
        return 1;
    }

    for (v = 1; v < JUNO_NUM_VOICES; ++v) {
        int diffs = 0, first = -1;
        render_isolated(v, cur);
        for (i = 0; i < NFRAMES; ++i)
            if (cur[i] != ref[i]) { if (first < 0) first = i; ++diffs; }
        if (diffs) {
            printf("FAIL: voice %d differs from voice 0 in %d/%d samples "
                   "(first at %d: v%d=%08x v0=%08x)\n",
                   v, diffs, NFRAMES, first, v, cur[first], ref[first]);
            ++fails;
        } else {
            printf("voice %d: bit-identical to voice 0 (%d samples)\n", v, NFRAMES);
        }
    }

    if (fails) { printf("FAIL: %d voice(s) diverged\n", fails); return 1; }
    printf("OK: all 8 voices are bit-identical — region classification verified\n");
    return 0;
}
