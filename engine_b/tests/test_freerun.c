/* test_freerun.c — THE FREE-RUN CONTRACT, tested rather than asserted.
 *
 *   advance(s, n)  ==  n calls of step(s)          EXACTLY, bit for bit
 *
 * for every free-running quantity, at engine level and at component level.
 * "Exactly" is the requirement: an approximate catch-up would leave a voice a
 * fraction of a cycle from where the oracle has it, and the null gates at
 * -100 dB.
 *
 * The test also checks the NEGATIVE case, which is the one that matters: it
 * plants the lockstep bug (skip the advance of a resting voice) and requires the
 * comparison to FAIL. A contract test that only ever passes measures nothing.
 *
 *   cc -std=c99 -O2 -ffp-contract=off -I.. -o t test_freerun.c ../eb_engine.c \
 *      ../eb_patch.c && ./t
 */
#include <stdio.h>
#include <string.h>
#include "eb_engine.h"
#include "eb_freerun.h"

static int fails = 0;
static void chk(int ok, const char *what)
{
    if (!ok) { printf("FAIL: %s\n", what); fails++; }
}

/* Set every free-running increment to something coprime-ish and non-trivial, so
 * a wrap around 2^32 really happens inside the test. */
static void arm(eb_engine *e)
{
    int i;
    e->lfo.inc = 0x00051EB8u;
    e->fx.cho_lfo.inc = 0x0002AAABu;
    for (i = 0; i < EB_NUM_VOICES; ++i) {
        e->v[i].dco.inc = 0x0AB1C3D7u + (uint32_t)i * 0x00100001u;
        e->v[i].sub.inc = 0x0558E1EBu + (uint32_t)i * 0x00080000u;
    }
}

static int engines_equal(const eb_engine *a, const eb_engine *b)
{
    return memcmp(a, b, sizeof(*a)) == 0;
}

int main(void)
{
    static const uint32_t NS[] = {0, 1, 2, 48, 441, 4410, 44100, 100000, 1000000};
    size_t k;

    /* ---- component level: the phase accumulator ------------------------ */
    for (k = 0; k < sizeof(NS) / sizeof(NS[0]); ++k) {
        uint32_t n = NS[k], i;
        eb_phase a, b;
        eb_phase_init(&a, 0x12345678u, 0x0AB1C3D7u);
        b = a;
        for (i = 0; i < n; ++i) (void)eb_phase_step(&a);
        eb_phase_advance(&b, n);
        chk(a.acc == b.acc, "eb_phase: advance(n) != n steps");
    }

    /* ---- component level: the noise LFSR ------------------------------- */
    for (k = 0; k < sizeof(NS) / sizeof(NS[0]); ++k) {
        uint32_t n = NS[k], i;
        eb_noise a, b;
        eb_noise_init(&a); eb_noise_init(&b);
        for (i = 0; i < n; ++i) (void)eb_noise_step(&a);
        eb_noise_advance(&b, n);
        chk(a.x == b.x, "eb_noise: advance(n) != n steps");
    }

    /* ---- engine level -------------------------------------------------- */
    for (k = 0; k < sizeof(NS) / sizeof(NS[0]); ++k) {
        uint32_t n = NS[k], i;
        static eb_engine a, b;
        eb_engine_init(&a, 48000.0f); arm(&a);
        eb_engine_init(&b, 48000.0f); arm(&b);
        chk(eb_engine_all_atrest(&a), "a fresh engine is not at rest");
        for (i = 0; i < n; ++i) eb_engine_step_freerun_public(&a);
        eb_engine_advance(&b, n);
        chk(engines_equal(&a, &b), "eb_engine: advance(n) != n step_freerun");
    }

    /* ---- the same, through the REAL per-sample path --------------------- */
    /* eb_engine_process() on an idle engine must leave exactly the state that
     * eb_engine_advance() would. This is the property the audio path actually
     * relies on; testing only step_freerun would test a function nothing calls. */
    {
        static eb_engine a, b;
        uint32_t i;
        float l, r;
        eb_engine_init(&a, 48000.0f); arm(&a);
        eb_engine_init(&b, 48000.0f); arm(&b);
        for (i = 0; i < 4410; ++i) (void)eb_engine_process(&a, &l, &r);
        eb_engine_advance(&b, 4410);
        chk(engines_equal(&a, &b),
            "eb_engine_process on an idle engine != eb_engine_advance");
    }

    /* ---- NEGATIVE CONTROL: plant the lockstep bug, require a MISMATCH --- */
    {
        static eb_engine a, b;
        uint32_t i;
        eb_engine_init(&a, 48000.0f); arm(&a);
        eb_engine_init(&b, 48000.0f); arm(&b);
        for (i = 0; i < 441; ++i) {
            /* "a" advances properly; "b" skips the state advance of its resting
             * voices, which is exactly the mistake the accuracy standard names.
             * Only the shared state is advanced. */
            eb_engine_step_freerun_public(&a);
            (void)eb_noise_step(&b.noise);
            (void)eb_phase_step(&b.lfo);
            (void)eb_phase_step(&b.fx.cho_lfo);
        }
        chk(!engines_equal(&a, &b),
            "NEGATIVE CONTROL: skipping a resting voice's state advance was NOT "
            "detected -- this test cannot see the one bug it exists for");
    }

    /* ---- a documented cost fact, not a guess --------------------------- */
    printf("eb_phase_advance: one 32-bit multiply-add, O(1) in n.\n"
           "eb_noise_advance: O(n), 6 integer ops per step, shared and never on "
           "the per-voice skip path (eb_freerun.h states this).\n");

    printf("%s\n", fails ? "FREE-RUN CONTRACT: FAIL" : "FREE-RUN CONTRACT: PASS");
    return fails ? 1 : 0;
}
