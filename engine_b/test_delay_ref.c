/* test_delay_ref.c -- engine_b/eb_delay.c against the LITERAL transcription
 * docs/engineb/data/eb_delay_ref.c, over the CONFIGURATIONS the factory bank
 * does not reach.
 *
 * WHY THIS EXISTS. tools/engineb/null_b.py --module delay nulls EXACTLY 0 on
 * all 30 scenarios, but those 30 scenarios play factory patches, and a factory
 * patch does not exercise HIGH CUT byte 14 (the bypass, cell 102496 = 0.0), or
 * DELAY LEVEL below 2 (the OFF gate, 102576 = 0.0), or MUTE, or a DELAY TIME
 * that MOVES while the line is running, or the effect-routing click
 * suppressor. Those are branches of this module, and a branch no gate enters is
 * a branch that is not gated. Here they are driven directly.
 *
 * The reference is the same transcription that nulled bit-exact against the
 * sealed engine, so a pass here has the same standing as the null: EXACTLY 0 or
 * it failed. Build:
 *   cc -std=c99 -O2 -ffp-contract=off -fno-strict-aliasing -DEB_DELAY_LEN=524288 \
 *      -Iengine_b -o /tmp/t engine_b/test_delay_ref.c engine_b/eb_delay.c \
 *      docs/engineb/data/eb_delay_ref.c -lm
 * EB_DELAY_LEN MUST be 524288 for this test: the reference's ring is 524288
 * long, and a shorter engine B ring wraps at a different index. The shipping
 * default (65536) is checked instead by the shim's overrun guard.
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "eb_delay.h"

void eb_delay_ref(unsigned char *a1, float v36, float v38);

#if EB_DELAY_LEN != 524288
#error "build this test with -DEB_DELAY_LEN=524288 (see the header comment)"
#endif

static unsigned char *ctx;
static eb_delay_state *st;

static void poke(const eb_delay_cfg *c)
{
#define S(o, v) (*(float *)(ctx + (o)) = (v))
    S(102368, c->b0);   S(102384, c->b1);   S(102400, c->b2);
    S(102416, c->a1);   S(102432, c->a2);   S(102448, c->mixA);
    S(102464, c->svf_g);S(102480, c->svf_r);S(102496, c->mixB);
    S(102512, c->dry);  S(102528, c->wet);  S(102560, c->fb);
    S(102576, c->on);   S(102592, c->mute); S(102608, c->lp_g);
    S(102624, c->k624); S(102640, c->lf_damp); S(102656, c->hp_g);
    S(102672, c->hf_damp); S(102688, c->k688); S(102704, c->dc_g);
    S(102720, c->fade_k); S(102752, c->fade_up); S(102768, c->fade_dn);
    S(102784, c->slew); S(102352, c->time_target); S(84496, c->fade_gain);
#undef S
}

static eb_delay_cfg base(void)
{
    eb_delay_cfg c;
    memset(&c, 0, sizeof c);
    c.b0 = 0.12f; c.b1 = 0.24f; c.b2 = 0.11f; c.a1 = 0.7f; c.a2 = -0.21f;
    c.mixA = 1.0f; c.svf_g = 0.13f; c.svf_r = 1.414427161f; c.mixB = 1.0f;
    c.dry = 0.8f; c.wet = 0.6f; c.fb = 0.705882f; c.on = 1.0f; c.mute = 1.0f;
    c.lp_g = 0.02f; c.k624 = 1.0f; c.lf_damp = 0.4f; c.hp_g = 0.05f;
    c.hf_damp = 0.3f; c.k688 = 1.0f; c.dc_g = 0.007836152f;
    c.fade_k = 1.0f / 16384.0f; c.fade_up = 0.0078125f; c.fade_dn = -0.0078125f;
    c.slew = 0.000725624f; c.time_target = 0.0122f; c.fade_gain = 1.0f;
    return c;
}

/* one case: N samples of pseudo-random stereo, optional mid-run target move and
 * routing change. Returns the index of the first differing sample, or -1. */
static long run_case(const char *name, eb_delay_cfg c, long n,
                     float t2, long t2_at, long route_at)
{
    unsigned s = 22222u;
    long k, first = -1;
    memset(ctx, 0, 12u << 20);
    memset(st, 0, sizeof *st);
    *(int *)(ctx + 2199956) = 524288;
    *(int *)(ctx + 4297124) = 524288;
    poke(&c);
    for (k = 0; k < n; ++k) {
        float xl, xr, rl, rr, bl, br;
        int rc = (k == route_at);
        if (k == t2_at) { c.time_target = t2; poke(&c); }
        s = s * 1103515245u + 12345u; xl = ((int)(s >> 9) - 4194304) / 4194304.0f;
        s = s * 1103515245u + 12345u; xr = ((int)(s >> 9) - 4194304) / 4194304.0f;
        if (rc) *(int *)(ctx + 11022348) = 1;
        eb_delay_ref(ctx, xl, xr);
        rl = *(float *)(ctx + 102320); rr = *(float *)(ctx + 102336);
        eb_delay_process(&c, st, rc, xl, xr, &bl, &br);
        if ((rl != bl || rr != br) && first < 0) {
            first = k;
            printf("  %-22s FAIL at %ld: ref %.9g/%.9g  B %.9g/%.9g\n",
                   name, k, rl, rr, bl, br);
        }
    }
    if (first < 0) printf("  %-22s EXACTLY 0 over %ld samples\n", name, n);
    return first;
}

int main(void)
{
    eb_delay_cfg c;
    int bad = 0;
    ctx = (unsigned char *)calloc(1, 12u << 20);
    st  = (eb_delay_state *)calloc(1, sizeof *st);
    if (!ctx || !st) return 2;
    printf("eb_delay.c vs docs/engineb/data/eb_delay_ref.c\n");

    c = base();                       bad |= run_case("nominal", c, 8000, 0, -1, -1) >= 0;
    c = base(); c.mixA = 0.0f;        bad |= run_case("mixA=0 (48k topology)", c, 8000, 0, -1, -1) >= 0;
    c = base(); c.mixB = 0.0f;        bad |= run_case("HIGH CUT byte 14", c, 8000, 0, -1, -1) >= 0;
    c = base(); c.on = 0.0f;          bad |= run_case("OFF gate (LEVEL<2)", c, 8000, 0, -1, -1) >= 0;
    c = base(); c.mute = 0.0f;        bad |= run_case("MUTE", c, 8000, 0, -1, -1) >= 0;
    c = base(); c.fb = 0.9f;          bad |= run_case("FEEDBACK max", c, 8000, 0, -1, -1) >= 0;
    c = base(); c.fb = 0.0f;          bad |= run_case("FEEDBACK 0", c, 8000, 0, -1, -1) >= 0;
    c = base(); c.time_target = 0.0006f;
                                      bad |= run_case("shortest time", c, 8000, 0, -1, -1) >= 0;
    c = base(); c.time_target = 2.1533f;  /* 800 ms @44.1k */
                                      bad |= run_case("longest time (800 ms)", c, 8000, 0, -1, -1) >= 0;
    c = base();                       bad |= run_case("time MOVES up", c, 12000, 0.0500f, 3000, -1) >= 0;
    c = base(); c.time_target = 0.05f;bad |= run_case("time MOVES down", c, 12000, 0.0122f, 3000, -1) >= 0;
    c = base();                       bad |= run_case("routing change", c, 8000, 0, -1, 2500) >= 0;
    c = base(); c.wet = 0.0f; c.dry = 1.0f;
                                      bad |= run_case("wet 0", c, 8000, 0, -1, -1) >= 0;
    c = base(); c.lf_damp = 1.0f; c.hf_damp = 1.0f; c.lp_g = 0.5f; c.hp_g = 0.5f;
                                      bad |= run_case("damping extremes", c, 8000, 0, -1, -1) >= 0;

    printf("%s\n", bad ? "FAIL" : "PASS: 14/14 configurations EXACTLY 0");
    return bad ? 1 : 0;
}
