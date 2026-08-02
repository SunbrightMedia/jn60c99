/* test_modcv_block.c — eb_modcv_block must be BIT-IDENTICAL to eb_modcv_tick.
 * The block form is what the engine calls (it hoists the coefficient loads and
 * the global LFO arms out of the eight-voice loop); the tick form is what the
 * null gate ran. If they ever differ, the gate stops covering the shipped path.
 * 2,000,000 random coefficient sets x 8 voices, all-bit-pattern floats drawn
 * from a range that spans the recalled values and well past them. */
#include <stdio.h>
#include <stdint.h>
#include "eb_pwm_cv.h"

static uint32_t st = 2463534242u;
static float rf(void)
{
    st ^= st << 13; st ^= st >> 17; st ^= st << 5;
    return ((float)(int32_t)st / 2147483648.0f) * 8.0f;
}

int main(void)
{
    long i; long bad = 0;
    for ( i = 0; i < 2000000; ++i )
    {
        eb_modcv_coef c;
        float pcv[8], kbd[8], e1[8], e2[8], po[8], wo[8];
        float ld = rf(), lu = rf();
        int v;
        eb_modcv_set(&c, rf(), rf(), rf(), rf(), rf(), rf(), rf(), rf(), rf(),
                     rf(), rf(), rf(), rf(), rf(), rf(), rf(), rf(), rf(),
                     rf(), rf(), rf(), rf(), rf(), rf());
        for ( v = 0; v < 8; ++v ) { pcv[v]=rf(); kbd[v]=rf(); e1[v]=rf(); e2[v]=rf(); }
        eb_modcv_block(&c, 8, pcv, kbd, ld, lu, e1, e2, po, wo);
        for ( v = 0; v < 8; ++v )
        {
            float p, w;
            eb_modcv_tick(&c, pcv[v], kbd[v], ld, lu, e1[v], e2[v], &p, &w);
            if ( *(uint32_t *)&p != *(uint32_t *)&po[v] ||
                 *(uint32_t *)&w != *(uint32_t *)&wo[v] ) ++bad;
        }
    }
    printf("eb_modcv_block vs eb_modcv_tick: %ld mismatches of 16,000,000\n", bad);
    return bad != 0;
}
