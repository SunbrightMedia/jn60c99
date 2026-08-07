/* Does the per-voice CONDITION scatter factor out of the DCO's waveform SHAPE?
 *
 * A wavetable's memory cost is per PATCH if the eight voices share one table
 * set and per VOICE if they do not -- 125 KB against 750 KB, which is the
 * difference between fitting the S3's internal RAM and not.
 *
 * The shape depends on `pw` (pulse duty), `g` (edge width, set by pitch),
 * `subthr` (sub-oscillator timing) and the three `amp_*` (edge width per arm).
 * The three `lvl_*` and three `gn_*` are pure multiplicative gains applied
 * OUTSIDE the shaping, so they may differ per voice for free. This prints the
 * per-voice spread of both groups over all 64 factory patches, so the question
 * is answered by what the recall actually produces.
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include "juno_apply.h"
#include "juno_engine.h"
#include "juno_driver.h"
#include "eb_render.h"
#include "eb_coefs.h"

static void spread(const char *name, const float *v, int n, double *worst)
{
    double lo = v[0], hi = v[0];
    int i;
    for (i = 1; i < n; ++i) { if (v[i] < lo) lo = v[i]; if (v[i] > hi) hi = v[i]; }
    if (fabs(hi) > 1e-12 || fabs(lo) > 1e-12) {
        double rel = fabs(hi - lo) / (fabs(hi) > fabs(lo) ? fabs(hi) : fabs(lo));
        if (rel > *worst) *worst = rel;
        (void)name;
    }
}

int main(int argc, char **argv)
{
    FILE *f = fopen(argv[1], "rb");
    static unsigned char bank[1 << 20];
    size_t n = fread(bank, 1, sizeof bank, f);
    unsigned char *st = malloc(JUNO_STATE_BYTES);
    static eb_render_coefs C;
    int p, v, np;
    double shape_worst = 0.0, gain_worst = 0.0;
    (void)argc;
    np = juno_bank_num_patches(bank, (unsigned long)n);
    for (p = 0; p < np; ++p) {
        float t[8];
        memset(st, 0, JUNO_STATE_BYTES);
        juno_engine_init(st);
        juno_engine_prepare(st);
        juno_bank_apply(st, bank, p);
        /* THE THREE CALLS THAT MAKE THE VOICES DIFFERENT. juno_bank_apply
         * writes VOICE 0 ONLY; seed_voices replicates it to the other seven;
         * and only THEN does apply_condition lay the per-voice analog scatter
         * over the result. The first version of this probe omitted all three
         * and reported zero spread in every field -- which is what eight
         * copies of the power-on value look like, not what CONDITION does. */
        juno_driver_seed_voices(st);
        juno_apply_condition(st, juno_bank_condition(bank, p));
        juno_apply_unison_spread(st, juno_bank_assign(bank, p));
        eb_render_coefs_build(st, &C);
#define SH(field) do { for (v = 0; v < 8; ++v) t[v] = C.dco[v].field; \
                       spread(#field, t, 8, &shape_worst); } while (0)
#define GN(field) do { for (v = 0; v < 8; ++v) t[v] = C.dco[v].field; \
                       spread(#field, t, 8, &gain_worst); } while (0)
        SH(amp_saw); SH(amp_pulse); SH(amp_sub); SH(subthr);
        SH(sat_in); SH(k3); SH(k5); SH(k7); SH(k9); SH(k11);
        GN(lvl_saw); GN(lvl_pulse); GN(lvl_sub);
        GN(gn_saw);  GN(gn_pulse);  GN(gn_sub);
#undef SH
#undef GN
    }
    /* NON-VACUITY CONTROL. Both spreads came out EXACTLY zero, and a
     * measurement that reports zero is the one that most needs proof it ran.
     * If CONDITION genuinely scatters the voices, the raw voice blocks must
     * DIFFER somewhere -- voice v lives at 176 + v*10512. If they are
     * byte-identical, this probe applied nothing and its zero means nothing. */
    {
        int diff = 0, off;
        memset(st, 0, JUNO_STATE_BYTES);
        juno_engine_init(st); juno_engine_prepare(st);
        juno_bank_apply(st, bank, 0);
        juno_driver_seed_voices(st);
        juno_apply_condition(st, juno_bank_condition(bank, 0));
        for (off = 0; off < 10512; ++off)
            if (st[176 + off] != st[176 + 10512 + off]) ++diff;
        printf("control: voice 0 vs voice 1 differ in %d of 10512 bytes\n",
               diff);
        if (!diff) {
            printf("  -> CONDITION APPLIED NOTHING. The spreads below are "
                   "VACUOUS.\n");
            return 1;
        }
    }
    printf("over %d patches, worst per-voice relative spread\n", np);
    printf("  SHAPE (amp_*, subthr, saturator) : %.6f  (%.4f %%)\n",
           shape_worst, 100.0 * shape_worst);
    printf("  GAIN  (lvl_*, gn_*)              : %.6f  (%.4f %%)\n",
           gain_worst, 100.0 * gain_worst);
    return 0;
}
/* Harness stubs. eb_coefs.c reaches two hooks that belong to the null shims
 * and one to the master; none of them touches the DCO coefficients this probe
 * reads, so stubbing them keeps the probe honest rather than convenient. */
void ebsh_load_coef(void) {}
void ebsh_snapshot(void) {}
