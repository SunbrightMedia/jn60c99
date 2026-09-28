/* fx_emit.c -- decode one eb_master_coef blob (dumped by the certified
 * standalone shim through ebsh_dump_blob) and print the three FX coefficient
 * sets jetsynth reuses: chorus, delay core, reverb (+ its tap table).
 *
 * This is PLUMBING ONLY. It copies bytes the proven recall produced into C
 * initialisers; it computes nothing. Floats are printed with %a (hex float),
 * so the header holds the recall's bits exactly.
 *
 * usage: fx_emit <mc.bin> <taps.bin> <sizeof_mc> summary
 *        fx_emit <mc.bin> <taps.bin> <sizeof_mc> emit <NAME>
 * Built with the same CFLAGS and include paths as the shim library, and it
 * refuses a blob whose size is not sizeof(eb_master_coef) of this build. */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "eb_master.h"

static void pf(const char *n, float v) { printf("    .%s = %a,\n", n, (double)v); }

static void emit_cho(const char *nm, const eb_chorus_coef *k)
{
    int i;
    printf("static const eb_chorus_coef JS_FX_CHO_%s = {\n", nm);
#define F(x) pf(#x, k->x)
    F(dtime); F(depth_r); F(rate); F(phase_off); F(depth); F(noise); F(dry);
    F(wet); F(smco); F(onoff); F(mute); F(b0); F(b1); F(b2); F(a1); F(a2);
    F(hb0); F(hb1); F(ha1); F(svf_f); F(svf_d); F(eps); F(mod_scale);
    F(mod_off); F(ramp_inc); F(ramp_max); F(slew_up); F(slew_dn); F(n_gain);
    F(n_off);
#undef F
    printf("    .nf = {");
    for (i = 0; i < 8; i++) printf("%a%s", (double)k->nf[i], i < 7 ? ", " : "");
    printf("},\n    .ring_len = %d\n};\n", k->ring_len);
}

static void emit_dly(const char *nm, const eb_delay_cfg *c)
{
    printf("static const eb_delay_cfg JS_FX_DLY_%s = {\n", nm);
#define F(x) pf(#x, c->x)
    F(b0); F(b1); F(b2); F(a1); F(a2); F(mixA); F(svf_g); F(svf_r); F(mixB);
    F(dry); F(wet); F(fb); F(on); F(mute); F(lp_g); F(k624); F(lf_damp);
    F(hp_g); F(hf_damp); F(k688); F(dc_g); F(fade_k); F(fade_up); F(fade_dn);
    F(slew); F(time_target); F(fade_gain);
#undef F
    printf("};\n");
}

static void emit_rev(const char *nm, const eb_reverb_cfg *c, const int32_t *taps)
{
    int i, j;
    printf("static const eb_reverb_cfg JS_FX_REV_%s = {\n", nm);
#define F(x) pf(#x, c->x)
    F(send); F(gate); F(dry); F(wet); F(ap);
#undef F
    printf("    .f_in = {");
    for (i = 0; i < 8; i++) printf("%a%s", (double)c->f_in[i], i < 7 ? ", " : "");
    printf("},\n    .damp = {");
    for (i = 0; i < 4; i++) {
        printf("{");
        for (j = 0; j < 3; j++) printf("%a%s", (double)c->damp[i][j], j < 2 ? ", " : "");
        printf("}%s", i < 3 ? ", " : "");
    }
    printf("},\n");
    pf("lfo_inc", c->lfo_inc); pf("lfo_depth", c->lfo_depth);
    printf("};\nstatic const int32_t JS_FX_REVTAPS_%s[EB_REV_NTAP] = {", nm);
    for (i = 0; i < EB_REV_NTAP; i++) printf("%d%s", taps[i], i < EB_REV_NTAP - 1 ? ", " : "");
    printf("};\n");
}

int main(int argc, char **argv)
{
    static eb_master_coef mc;
    int32_t taps[EB_REV_NTAP];
    FILE *f;
    if (argc < 5) { fprintf(stderr, "usage: see header\n"); return 2; }
    if ((size_t)atoi(argv[3]) != sizeof mc) {
        fprintf(stderr, "LAYOUT MISMATCH: blob %s B, this build %zu B\n",
                argv[3], sizeof mc);
        return 3;
    }
    f = fopen(argv[1], "rb");
    if (!f || fread(&mc, 1, sizeof mc, f) != sizeof mc) return 4;
    fclose(f);
    f = fopen(argv[2], "rb");
    if (!f || fread(taps, 1, sizeof taps, f) != sizeof taps) return 5;
    fclose(f);
    if (!strcmp(argv[4], "summary")) {
        printf("dly_type=%d efx_type=%d | cho wet=%.4g dry=%.4g rate=%.4g "
               "depth=%.4g | dly on=%.3g wet=%.4g dry=%.4g fb=%.4g t=%.5g "
               "mixB=%.3g | rev send=%.4g wet=%.4g dry=%.4g gate=%.3g "
               "lfo=%.3g\n",
               mc.delay_type, mc.effect_type, mc.cho.wet, mc.cho.dry,
               mc.cho.rate, mc.cho.depth, mc.dcore.on, mc.dcore.wet,
               mc.dcore.dry, mc.dcore.fb, mc.dcore.time_target, mc.dcore.mixB,
               mc.rev.send, mc.rev.wet, mc.rev.dry, mc.rev.gate,
               mc.rev.lfo_depth);
        return 0;
    }
    if (!strcmp(argv[4], "emit") && argc > 5) {
        emit_cho(argv[5], &mc.cho);
        emit_dly(argv[5], &mc.dcore);
        emit_rev(argv[5], &mc.rev, taps);
        return 0;
    }
    return 2;
}
