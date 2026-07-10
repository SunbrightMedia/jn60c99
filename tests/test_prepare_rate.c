/* test_prepare_rate.c — regression guard for the rate-parameterized prepare.
 *
 * juno_engine_prepare reproduces the plugin's CWaveGen::setSampleRate BIT-EXACTLY
 * at any host rate (src/juno_prepare.c). This test freezes a representative offset
 * from each of the 5 rate mechanisms (A C/H, B affine, C 3-class select, D 2-class,
 * E reverb-tap generator) at 44100 / 48000 / 96000. The expected bit patterns are
 * the binary's OWN setSampleRate output (scratchpad/oracle/prepare_rate_spec.md,
 * verified bit-for-bit against BUILD+setSampleRate under Unicorn). If a compiler
 * FP change or an edit drifts any coefficient, this fails.
 *
 * At 96000 every value equals the previously-hardcoded 96k constant (regression
 * anchor); 48000/44100 assert the genuine per-rate coefficients.
 */
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include "../src/juno_engine.h"
#include "../src/juno_driver.h"

typedef struct { int off; uint32_t v44, v48, v96; const char *cls; } expect;

/* one representative per class + voice-replication + a couple of tap entries. */
static const expect E[] = {
    {   624, 0x3d8cb89d, 0x3d81499d, 0x3d01499d, "A C/H (porta/env time)" },
    { 91152, 0x37b69bf1, 0x37a7c5ac, 0x3727c5ac, "A C/H 0.96/H (chorus LFO)" },
    {102608, 0x3c3abeea, 0x3c2b929a, 0x3bab929a, "A C/H (LF-damp Fc)" },
    { 91120, 0x3b804ccd, 0x3b8c0000, 0x3c0e0000, "B affine (chorus dly time)" },
    { 96336, 0x3b8c0000, 0x3b98bc15, 0x3c1abc15, "B affine" },
    {102352, 0x3f0a7867, 0x3f16b800, 0x3f96bc00, "B affine (out dly time)" },
    {  2784, 0x40f7ad09, 0x40e38db9, 0x40638f21, "C 3-class (ENV1 attack)" },
    {  2816, 0x4139c0c1, 0x412aa9ad, 0x40aaac0b, "C 3-class (ENV1 decay)" },
    { 10240, 0x3b9a10b5, 0x3b8d8c28, 0x3b0d8c2e, "C 3-class (HPF dflt)" },
    {  1920, 0x3cb9c172, 0x3caaa9e0, 0x3c2aaa78, "C 3-class (LFO delay)" },
    {102448, 0x3f800000, 0x00000000, 0x00000000, "D 2-class (High-Cut Sw)" },
    {102656, 0x3f800000, 0x3f4ba5b0, 0x3f4ba5b0, "D 2-class (HF-damp Fc)" },
    /* reverb tap generator: tap[1] (predelay) and a shifted stage tap */
    { 11022212, 881, 959, 1919, "E reverb tap[1] predelay" },
    { 11022340, 22358, 46551, 47511, "E reverb tap[33]" },
};
enum { NE = (int)(sizeof(E) / sizeof(E[0])) };

static const int RATES[3] = { 44100, 48000, 96000 };

static uint32_t expect_at(const expect *e, int rate)
{
    return rate == 44100 ? e->v44 : rate == 48000 ? e->v48 : e->v96;
}

int main(void)
{
    unsigned char *st = calloc(1, JUNO_STATE_BYTES);
    int fails = 0;
    for (int ri = 0; ri < 3; ++ri) {
        int rate = RATES[ri];
        for (unsigned b = 0; b < JUNO_STATE_BYTES; ++b) st[b] = 0;
        JF(st, 16) = (float)rate;
        juno_engine_init(st);
        juno_engine_prepare(st);
        juno_driver_seed_voices(st);
        for (int k = 0; k < NE; ++k) {
            uint32_t got = *(uint32_t *)(st + E[k].off), want = expect_at(&E[k], rate);
            if (got != want) {
                printf("  rate %d off %d [%s]: got %08x want %08x\n",
                       rate, E[k].off, E[k].cls, got, want);
                ++fails;
            }
        }
        /* voice-block class-C offset must be replicated to all 8 voices */
        for (int v = 1; v < 8; ++v) {
            uint32_t v0 = *(uint32_t *)(st + 2784), vv = *(uint32_t *)(st + 2784 + v * 10512);
            if (v0 != vv) { printf("  rate %d voice %d ENV1 attack not replicated (%08x != %08x)\n",
                                   rate, v, vv, v0); ++fails; }
        }
    }
    free(st);
    if (fails) { printf("FAIL: %d prepare-rate coefficient(s) drifted\n", fails); return 1; }
    printf("OK: rate-parameterized prepare bit-exact at 44100/48000/96000 (5 mechanism classes)\n");
    return 0;
}
