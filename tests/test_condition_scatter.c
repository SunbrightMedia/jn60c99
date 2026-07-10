/* test_condition_scatter.c — guard for CONDITION analog voice-scatter
 * (juno_apply_condition). Per-voice-distinct detune (5520) / fine (7600) / gain
 * (10320), bit-exact vs the plugin's per-voice setter methods (240/240,
 * scratchpad/oracle/condition_scatter_spec.md). The C=0 values are the plugin's own
 * baseline (also what BUILD+setSampleRate leaves per voice); C=128 is the default
 * patch's full scatter. This is the property test_poly_consistency canNOT assert
 * (CONDITION deliberately makes the 8 voices non-identical).
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "../src/juno_engine.h"
#include "../src/juno_apply.h"

#define ST 10512u   /* JUNO_VOICE_MAIN_STRIDE */
static unsigned u32(unsigned char *s, unsigned off) { float f=JF(s,off); unsigned b; memcpy(&b,&f,4); return b; }

/* plugin C=0 baseline (spec §"TUNE/FINE/GAIN v0..7") */
static const unsigned TUNE0[8] = {0x392291e6,0x38a291e6,0x394b3660,0x38f3dad9,0xb82291e6,0xb8f3dad9,0x00000000,0xb8a291e6};
static const unsigned FINE0[8] = {0x00000000,0x310561f8,0x306f0594,0xb041235c,0x308561f8,0xb0d5698d,0xb0a00f29,0x2fd5698d};
static const unsigned GAIN0[8] = {0x3f800000,0x3f800000,0x3f800000,0x3f800000,0x3f800000,0x3f800000,0x3f800000,0x3f800000};

int main(void)
{
    unsigned char *st = calloc(1, JUNO_STATE_BYTES);
    int fails = 0, v;

    /* C=0 baseline: exact per-voice match */
    juno_apply_condition(st, 0);
    for (v = 0; v < 8; ++v) {
        unsigned b = (unsigned)v * ST;
        if (u32(st,5520+b)  != TUNE0[v]) { printf("  C0 v%d TUNE %08x != %08x\n",v,u32(st,5520+b),TUNE0[v]); ++fails; }
        if (u32(st,7600+b)  != FINE0[v]) { printf("  C0 v%d FINE %08x != %08x\n",v,u32(st,7600+b),FINE0[v]); ++fails; }
        if (u32(st,10320+b) != GAIN0[v]) { printf("  C0 v%d GAIN %08x != %08x\n",v,u32(st,10320+b),GAIN0[v]); ++fails; }
    }

    /* C=128 default: ramps=1.0, so TUNE v0 = 0.02 = 0x3ca3d70a, GAIN v0 = 1.0. */
    memset(st, 0, JUNO_STATE_BYTES);
    juno_apply_condition(st, 128);
    if (u32(st,5520)  != 0x3ca3d70au) { printf("  C128 v0 TUNE %08x != 3ca3d70a\n", u32(st,5520)); ++fails; }
    if (u32(st,10320) != 0x3f800000u) { printf("  C128 v0 GAIN %08x != 3f800000\n", u32(st,10320)); ++fails; }
    /* the whole point: at C=128 the 8 voices' tune are DISTINCT (analog scatter) */
    {
        int distinct = 0;
        for (v = 1; v < 8; ++v) if (u32(st,5520+(unsigned)v*ST) != u32(st,5520)) ++distinct;
        if (distinct < 6) { printf("  C128 voices not scattered (only %d/7 differ from v0)\n", distinct); ++fails; }
    }

    free(st);
    if (fails) { printf("FAIL: %d condition-scatter check(s)\n", fails); return 1; }
    printf("OK: CONDITION per-voice analog scatter bit-exact (C=0 baseline + C=128 default, 8 voices)\n");
    return 0;
}
