/* test_rate_laws.c -- every continuous rate law in src/rate_laws.h must
 * reproduce, bit for bit, every 4-arm word it replaced (CLAIMS B4).
 *
 * The 4-arm tables (finefx_tables.h) and the old ARM_* words were MEASURED from
 * the plugin at 44100 / 48000 / 88200 / 96000. They are kept as anchors: a law
 * that disagrees with one of them is wrong at a rate the plugin was measured
 * at. The plugin itself grades the laws at 18 rates in
 * tools/verify/rate_sweep_gate.py and finefx_pillar3_gate.py; this test is the
 * fast self-consistency check that runs in `make test`. */
#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include "../src/rate_laws.h"
#include "../src/finefx_tables.h"

static const int RATES[4] = { 44100, 48000, 88200, 96000 };
static int fails = 0, checks = 0;

static uint32_t bits(float f) { uint32_t b; memcpy(&b, &f, sizeof b); return b; }

static void expect(const char *what, int arm, int idx, float got, uint32_t want)
{
    ++checks;
    if (bits(got) != want) {
        if (fails < 20)
            printf("FAIL %s @%d [%d]: law %08x anchor %08x\n",
                   what, RATES[arm], idx, bits(got), want);
        ++fails;
    }
}

/* juno_reverb_predelay, restated here so the test needs no other object */
static int predelay(int pd, int Hr) { long v = (long)pd * Hr / 1000L - 2L; return v < 0 ? 0 : (int)v; }

int main(void)
{
    int a, i;
    /* the old 4-arm words, verbatim from the code they were removed from */
    static const uint32_t ARM_LFX2[4]  = { 0x3c3abeeau, 0x3c2b929au, 0x3bbabeeau, 0x3bab929au };
    static const uint32_t ARM_CHDEP[4] = { 0x3cdb8001u, 0x3cef0001u, 0x3d5c0001u, 0x3d6f8001u };
    static const uint32_t ARM_CHLF[4]  = { 0x3b696eb3u, 0x3b56774fu, 0x3ae96eb3u, 0x3ad6774fu };
    static const uint32_t ET3_91152[4] = { 0x381bfa89u, 0x380f4e2eu, 0x379bfa89u, 0x378f4e2eu };
    static const uint32_t ET4_91120[4] = { 0x3c0f87aeu, 0x3c1c6666u, 0x3c9087aeu, 0x3c9d6666u };
    static const uint32_t ET4_91152[4] = { 0x39dac024u, 0x39c8fa21u, 0x395ac024u, 0x3948fa21u };
    static const uint32_t PD_10759360[4] = { 0x445c0000u, 0x446f8000u, 0x44dc4000u, 0x44efc000u };
    static const int OLD_RATES_SHIFT[5] = { 48000, 88200, 96000, 192000, 22050 };

    for (a = 0; a < 4; ++a) {
        int H = RATES[a];
        for (i = 0; i < 11; ++i) expect("DLY_LFDF", a, i, rl_scale96(DLY_LFDF[3][i], H), DLY_LFDF[a][i]);
        for (i = 0; i < 128; ++i) expect("CHO1_LC", a, i, rl_scale96(CHO1_LC[3][i][0], H), CHO1_LC[a][i][0]);
        for (i = 0; i <= 80; ++i) expect("CHO1_PD", a, i, rl_chorus_predelay(i, H), CHO1_PD[a][i]);
        expect("ARM_LFX2", a, 0, rl_scale96(0x3bab929au, H), ARM_LFX2[a]);
        expect("ARM_CHDEP", a, 0, rl_chorus_predelay(20, H), ARM_CHDEP[a]);
        expect("ARM_CHLF", a, 0, rl_scale96(0x3ad6774fu, H), ARM_CHLF[a]);
        expect("ET3 91152", a, 0, rl_chorus_mode_rate(1, H), ET3_91152[a]);
        expect("ET4 91120", a, 0, rl_chorus_mode_time(2, H), ET4_91120[a]);
        expect("ET4 91152", a, 0, rl_chorus_mode_rate(2, H), ET4_91152[a]);
        expect("ET2 91152", a, 0, rl_chorus_mode_rate(0, H), bits(0.96f / (float)H));
        expect("10759360", a, 0, (float)predelay(20, H), PD_10759360[a]);
    }
    /* the reverb tap shift: the old fitted form and the law agree at the rates
     * the old form was checked at (and differ at 11025, where the plugin
     * sided with the law -- rate_sweep_gate.py). */
    for (i = 0; i < 5; ++i) {
        int H = OLD_RATES_SHIFT[i];
        int old_shift = (int)(0.019995f * (float)H) - 1919;
        int law = predelay(20, H) - predelay(20, 96000);
        ++checks;
        if (old_shift != law) { printf("FAIL tap shift @%d: old %d law %d\n", H, old_shift, law); ++fails; }
    }
    /* the two prepare laws: the old ((H*T) - 2)/16384 forms agree with the
     * plugin's orders at the five rates the cold gate had run (and not at
     * 32000, where the plugin sided with the new form -- coldstate_ab.py). */
    {
        static const int COLD5[5] = { 44100, 48000, 88200, 96000, 192000 };
        for (i = 0; i < 5; ++i) {
            int H = COLD5[i];
            float old96336 = ((float)H * rl_f32(0x3ad5febfu) - 2.0f) * (1.0f / 16384.0f);
            float old102352 = ((float)H * rl_f32(0x3e4dd2f2u) - 2.0f) * (1.0f / 16384.0f);
            ++checks; if (bits(rl_mode5_time(H)) != bits(old96336)) { printf("FAIL 96336 @%d\n", H); ++fails; }
            ++checks; if (bits(rl_ms_time((float)201, H)) != bits(old102352)) { printf("FAIL 102352 @%d\n", H); ++fails; }
        }
    }
    if (fails) { printf("FAIL: %d of %d rate-law anchors\n", fails, checks); return 1; }
    printf("OK: every rate law reproduces its %d measured 4-rate anchors bit for bit\n", checks);
    return 0;
}
