/* test_atrest_block.c — THE CONTRACT EB_ATREST_BLOCK RESTS ON.
 *
 *   eb_dco_wt_advance(s, c, n)  ==  n calls of eb_dco_wt_advance(s, c, 1)
 *
 * EXACTLY, bit for bit, over the WHOLE state block. Nothing weaker will do:
 * EB_ATREST_BLOCK claims to be an exact restructuring, not an approximation
 * inside a sonic bound, so an "almost" here would be a silently wrong claim
 * rather than a small error.
 *
 * WHY THIS IS THE RIGHT GATE AND THE NULL HARNESS IS NOT. null_b renders one
 * sample per call, so a build with EB_ATREST_BLOCK set and nothing batching
 * the call would leave every at-rest voice frozen and fail for a reason that
 * has nothing to do with the change. The claim is about the two SPELLINGS of
 * the advance being equal, so that is what is tested, directly.
 *
 * AND THE NEGATIVE CASE, because a test that has only ever passed measures
 * nothing: the same comparison is run against a deliberately short block, and
 * it must FAIL.
 *
 *   cc -std=c99 -O2 -ffp-contract=off -I.. -o t test_atrest_block.c \
 *      ../eb_dco_wt.c && ./t
 */
#include <stdio.h>
#include <string.h>
#include "eb_dco_wt.h"

static int fails = 0;
static void chk(int ok, const char *what)
{
    printf("%-46s %s\n", what, ok ? "OK" : "FAIL");
    if (!ok) fails++;
}

/* A pitch a JUNO is actually played at, and a pulse width that is not the
 * degenerate 0.5 -- tprev's sign test is the part of the body most likely to
 * disagree between the two spellings, and it is pw that moves it. */
static void arm(eb_dco_wt_coef *c, float hz)
{
    memset(c, 0, sizeof *c);
    eb_dco_wt_set_pitch(c, (hz / 44100.0f) * 0.25f, 0.37f);
    c->subthr = 0.21f;
}

static int same(const eb_dco_wt_state *a, const eb_dco_wt_state *b)
{
    return memcmp(a, b, sizeof *a) == 0;
}

/* n single-sample advances from a zeroed state. */
static void by_ones(eb_dco_wt_state *s, const eb_dco_wt_coef *c, int n)
{
    int i;
    memset(s, 0, sizeof *s);
    for (i = 0; i < n; ++i) eb_dco_wt_advance(s, c, 1);
}

static void one_case(float hz, int n)
{
    eb_dco_wt_coef c;
    eb_dco_wt_state a, b;
    char what[80];

    arm(&c, hz);
    by_ones(&a, &c, n);
    memset(&b, 0, sizeof b);
    eb_dco_wt_advance(&b, &c, n);           /* the whole block, one call */

    sprintf(what, "%.1f Hz, block of %d", (double)hz, n);
    chk(same(&a, &b), what);
}

int main(void)
{
    eb_dco_wt_coef c;
    eb_dco_wt_state a, b;
    /* Block sizes the firmware really uses, and two that straddle the
     * residual ring's length so the ring's wrap is inside a block. */
    static const int NS[] = { 1, 2, 7, 32, 64, 128, 441, 1024 };
    /* Pitches an octave apart plus one that puts the sub's mip level on a
     * boundary; the sub counter's crossing test is per sample either way and
     * this is where it would show if it were not. */
    static const float HZ[] = { 55.0f, 130.81f, 440.0f, 1760.0f, 7040.0f };
    unsigned i, j;

    for (i = 0; i < sizeof HZ / sizeof HZ[0]; ++i)
        for (j = 0; j < sizeof NS / sizeof NS[0]; ++j)
            one_case(HZ[i], NS[j]);

    /* THE PLANTED NEGATIVE. One sample short is the smallest wrong answer the
     * hoist could produce -- an off-by-one in the caller's block count -- and
     * the comparison must catch it. If this reads OK, every row above is
     * vacuous. */
    arm(&c, 440.0f);
    by_ones(&a, &c, 256);
    memset(&b, 0, sizeof b);
    eb_dco_wt_advance(&b, &c, 255);
    chk(!same(&a, &b), "PLANTED: a block one sample short is CAUGHT");

    printf("%s (%d failure%s)\n", fails ? "FAILED" : "PASS", fails,
           fails == 1 ? "" : "s");
    return fails != 0;
}
