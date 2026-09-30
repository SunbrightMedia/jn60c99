/* fxgen.c -- the minisynth's JUNO chorus + hall reverb, taken from the PROVEN
 * recall path (the port's own juno_bank_apply -> eb_master_coefs_build /
 * eb_master_state_seed, exactly tools/engineb/devboot/patchbank.c's order).
 * Nothing here computes a coefficient: every number is read out of the recall.
 *
 *   1. find a factory patch with the chorus arm, DELAY TYPE 0 and the delay OFF
 *      (dcore.on == 0 && dcore.wet == 0, so the delay core passes x exactly)
 *   2. force EFFECT TYPE = JUNO CHORUS (TYPE_CHO), EFFECT TONE = 0 (no BBD
 *      hiss, so silence is reachable), REVERB TYPE = 2 (HALL 1)
 *   3. for every EFFECT DEPTH byte 0..255 and every REVERB LEVEL byte 0..255,
 *      recall again and REQUIRE that only the named fields moved:
 *        depth -> cho.wet, in.k84544          level -> rev.send
 *      Anything else moving is a FAIL (the table would then be a lie).
 *   4. emit main/gen/msq_fx.h: the base eb_master_coef image, the seeded state
 *      as a sparse word list, and the three 256-entry tables.
 * usage: fxgen <truth/presetbankog1.bin> <out.h> */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <stddef.h>

#include "fx_recall.h"

static uint32_t crc32(const void *d, size_t n)
{
    const uint8_t *p = d; uint32_t c = 0xFFFFFFFFu;
    for (size_t i = 0; i < n; ++i) { c ^= p[i]; for (int k = 0; k < 8; ++k) c = (c >> 1) ^ (0xEDB88320u & (0u - (c & 1u))); }
    return ~c;
}

static uint32_t bits(float f) { uint32_t u; memcpy(&u, &f, 4); return u; }

/* every differing 4-byte word must be one of the allowed offsets */
static int only_moved(const void *a, const void *b, size_t n, const size_t *ok, int nok, const char *what, int val)
{
    const uint32_t *x = a, *y = b;
    for (size_t w = 0; w < n / 4; ++w) if (x[w] != y[w]) {
        int allowed = 0;
        for (int k = 0; k < nok; ++k) if (ok[k] == w * 4) allowed = 1;
        if (!allowed) { printf("FAIL: %s=%d moved coef byte %zu (not a named field)\n", what, val, w * 4); return 0; }
    }
    return 1;
}

int main(int argc, char **argv)
{
    if (argc < 3) { fprintf(stderr, "usage: %s <bank.bin> <out.h>\n", argv[0]); return 2; }
    FILE *f = fopen(argv[1], "rb"); if (!f) { perror(argv[1]); return 2; }
    fseek(f, 0, SEEK_END); long bl = ftell(f); fseek(f, 0, SEEK_SET);
    BANK = malloc((size_t)bl); if (fread(BANK, 1, (size_t)bl, f) != (size_t)bl) return 2; fclose(f);
    ST = malloc(JUNO_STATE_BYTES);
    static eb_master_coef mc, base, t; static eb_master_state ms, zero;
    int bad = 0, pick = -1;

    boot(48000);
    for (int p = 0; p < 64 && pick < 0; ++p) {
        recall(p, &mc, NULL);
        if (mc.delay_type == 0 && mc.dcore.on == 0.0f && mc.dcore.wet == 0.0f &&
            (mc.effect_type == 2 || mc.effect_type == 3)) pick = p;
    }
    if (pick < 0) { printf("FAIL: no factory patch with the chorus arm and the delay off\n"); return 1; }
    printf("base patch %d: EFFECT TYPE %d DEPTH %d TONE %d, DELAY TYPE %d, REVERB TYPE %d LEVEL %d\n", pick,
           getp(pick, R_EFX_TYPE), getp(pick, R_EFX_DEPTH), getp(pick, R_EFX_TONE), getp(pick, R_DLY_TYPE),
           getp(pick, R_REV_TYPE), getp(pick, R_REV_LEVEL));
    setp(pick, R_EFX_TYPE, TYPE_CHO); setp(pick, R_EFX_TONE, 0); setp(pick, R_REV_TYPE, 2);
    setp(pick, R_EFX_DEPTH, 0); setp(pick, R_REV_LEVEL, 0);
    boot(48000);
    recall(pick, &base, &ms);
    printf("after forcing: effect_type %d delay_type %d dcore.on %g wet %g cho.noise %g rev.send %g\n",
           base.effect_type, base.delay_type, base.dcore.on, base.dcore.wet, base.cho.noise, base.rev.send);
    if (base.effect_type != TYPE_CHO || base.delay_type != 0 || base.dcore.on != 0.0f || base.dcore.wet != 0.0f ||
        base.cho.noise != 0.0f) { printf("FAIL: forced patch is not chorus / delay-off / noise-off\n"); bad = 1; }

    static float WET[256], K84544[256], SEND[256];
    size_t ok_d[2] = { offsetof(eb_master_coef, cho) + offsetof(eb_chorus_coef, wet),
                       offsetof(eb_master_coef, in) + offsetof(eb_master_in_coef, k84544) };
    size_t ok_l[1] = { offsetof(eb_master_coef, rev) + offsetof(eb_reverb_cfg, send) };
    for (int v = 0; v < 256; ++v) {
        setp(pick, R_EFX_DEPTH, v); boot(48000); recall(pick, &t, NULL);
        if (!only_moved(&base, &t, sizeof t, ok_d, 2, "EFFECT DEPTH", v)) bad = 1;
        WET[v] = t.cho.wet; K84544[v] = t.in.k84544;
    }
    setp(pick, R_EFX_DEPTH, 0);
    for (int v = 0; v < 256; ++v) {
        setp(pick, R_REV_LEVEL, v); boot(48000); recall(pick, &t, NULL);
        if (!only_moved(&base, &t, sizeof t, ok_l, 1, "REVERB LEVEL", v)) bad = 1;
        SEND[v] = t.rev.send;
    }
    setp(pick, R_REV_LEVEL, 0);
    printf("depth: wet[0]=%g wet[128]=%g wet[255]=%g k84544[0]=%g [1]=%g; level: send[0]=%g send[128]=%g send[255]=%g\n",
           WET[0], WET[128], WET[255], K84544[0], K84544[1], SEND[0], SEND[128], SEND[255]);

    /* the seeded state as a sparse word list over a zero struct */
    const uint32_t *sw = (const uint32_t *)&ms, *zw = (const uint32_t *)&zero;
    int nseed = 0;
    for (size_t w = 0; w < sizeof ms / 4; ++w) if (sw[w] != zw[w]) nseed++;

    FILE *o = fopen(argv[2], "w"); if (!o) { perror(argv[2]); return 2; }
    fprintf(o, "/* GENERATED by esp32s3/midi_square/tools/fxgen.c -- DO NOT EDIT.\n"
               " * Base = factory patch %d via the proven recall, forced EFFECT TYPE %d (JUNO CHORUS %d),\n"
               " * EFFECT TONE 0, REVERB TYPE 2 (HALL 1), DELAY OFF, 48 kHz. Tables: EFFECT DEPTH -> cho.wet,\n"
               " * in.k84544; REVERB LEVEL -> rev.send, each recalled byte by byte (256 recalls each). */\n",
            pick, TYPE_CHO, TYPE_CHO - 1);
    fprintf(o, "#define MSQ_FX_BASE_PATCH %d\n#define MSQ_FX_COEF_BYTES %zu\n#define MSQ_FX_STATE_BYTES %zu\n",
            pick, sizeof base, sizeof ms);
    /* CRC of the base coefficient image with depth 0 / level 0 (what fx_init
     * leaves in RAM), and of the whole seeded state: the device recomputes both
     * after fx_init and must match. */
    fprintf(o, "#define MSQ_FX_COEF_CRC 0x%08xu\n#define MSQ_FX_STATE_CRC 0x%08xu\n",
            crc32(&base, sizeof base), crc32(&ms, sizeof ms));
    fprintf(o, "#define MSQ_FX_OFF_CHO_WET %zu\n#define MSQ_FX_OFF_IN_K84544 %zu\n#define MSQ_FX_OFF_REV_SEND %zu\n",
            ok_d[0], ok_d[1], ok_l[0]);
    fprintf(o, "static const uint32_t MSQ_FX_COEF[%zu] = {", sizeof base / 4);
    const uint32_t *bw = (const uint32_t *)&base;
    for (size_t w = 0; w < sizeof base / 4; ++w) fprintf(o, "%s0x%08x", w % 8 ? "," : ",\n  " + (w == 0), bw[w]);
    fprintf(o, "\n};\n#define MSQ_FX_NSEED %d\nstatic const uint32_t MSQ_FX_SEED[%d][2] = {", nseed, nseed);
    int k = 0;
    for (size_t w = 0; w < sizeof ms / 4; ++w) if (sw[w] != zw[w])
        fprintf(o, "%s{%zu,0x%08x}", k++ % 6 ? "," : ",\n  " + (k == 1), w * 4, sw[w]);
    fprintf(o, "\n};\n");
    const char *tn[3] = { "MSQ_FX_WET", "MSQ_FX_K84544", "MSQ_FX_SEND" }; float *tv[3] = { WET, K84544, SEND };
    for (int q = 0; q < 3; ++q) {
        fprintf(o, "static const uint32_t %s[256] = {", tn[q]);
        for (int v = 0; v < 256; ++v) fprintf(o, "%s0x%08x", v % 8 ? "," : ",\n  " + (v == 0), bits(tv[q][v]));
        fprintf(o, "\n};\n");
    }
    fclose(o);
    printf("%s: %s (coef %zu B, state %zu B, %d seed words)\n", bad ? "FXGEN FAIL" : "FXGEN PASS", argv[2],
           sizeof base, sizeof ms, nseed);
    return bad;
}
