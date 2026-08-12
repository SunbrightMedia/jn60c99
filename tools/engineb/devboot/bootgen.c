/* bootgen.c -- THE BAKED BOOT IMAGE for the device cell array.
 *
 * The device cell array must start from the state the port is in after
 *   juno_chorus_init -> JF(16)=rate -> juno_engine_init -> juno_engine_prepare
 * On the host that state is 12 MB of flat array. On the device it is the
 * ebdev_state layout, and it is BAKED HERE and flashed.
 *
 * === WHY THIS IS NOT tools/engineb/devrecall/gate.c's GATHER ===
 *
 * gate.c's host half (its main(), argv[3] branch) already gathers a boot image
 * through EBDEV_SEGTAB, and the ALGORITHM is the same four memcpy loops. It is
 * reused here verbatim in shape and deliberately NOT called: it is welded into
 * a gate main() that also runs 1,152 cases and writes a 24 MB comparison file,
 * it emits all three rates concatenated with no way to pick one, it emits no
 * header for embedding -- and it writes `scat[8][NSCAT]` unconditionally while
 * the reader on the other side sizes its buffer `EBDEV_NV * NSCAT * 4`. At the
 * gate's own EBDEV_NV=8 those agree; at the fork's EBDEV_NV=6 they do not, and
 * the reader's short-read check cannot see it because the file is LONGER, not
 * shorter. This generator takes NV as an argument and prints it.
 *
 * The four segment loops are the ONE thing that must stay identical to
 * ebdev.c's map, so this file gathers THROUGH EBDEV_SEGTAB / EBDEV_SCATTAB,
 * the same generated table the map is generated from. Nothing here transcribes
 * an offset by hand.
 *
 * usage: bootgen <out.bin> [<out.h> <symbol>]
 *   env  BOOTGEN_RATES="44100,48000,96000"   (default: 44100 only)
 *   env  BOOTGEN_NV=6                        (default: 6, the fork)
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>

#include "juno_engine.h"
#include "juno_apply.h"
#include "ebdev_seg.h"

#define MAXRATE 8

static unsigned char *ST;

static void boot_state(int rate)
{
    memset(ST, 0, JUNO_STATE_BYTES);
    juno_chorus_init(ST);
    JF(ST, 16) = (float)rate;
    juno_engine_init(ST);
    juno_engine_prepare(ST);
}

/* THE GATHER. Identical in shape to gate.c:488-511, expressed once. */
static size_t gather(unsigned char *dst, int nv)
{
    size_t n = 0;
    int i, v, k;
    memcpy(dst, ST, EBDEV_VTILE);
    n += EBDEV_VTILE;
    for (i = 0; i < EBDEV_NSEG; ++i)
        memcpy(dst + n + EBDEV_SEGTAB[i].at, ST + EBDEV_SEGTAB[i].lo,
               EBDEV_SEGTAB[i].hi - EBDEV_SEGTAB[i].lo);
    n += EBDEV_SEGBYTES;
    for (v = 0; v < nv; ++v)
        for (k = 0; k < EBDEV_NSCAT; ++k) {
            float f = JF(ST, (unsigned)v * JUNO_VOICE_MAIN_STRIDE + EBDEV_SCATTAB[k]);
            memcpy(dst + n, &f, 4);
            n += 4;
        }
    return n;
}

int main(int argc, char **argv)
{
    int rates[MAXRATE], nr = 0, nv = 6, i, j;
    const char *rs = getenv("BOOTGEN_RATES");
    const char *nvs = getenv("BOOTGEN_NV");
    unsigned char *img[MAXRATE];
    size_t per;
    FILE *f;

    if (argc < 2) { fprintf(stderr, "usage: %s <out.bin> [<out.h> <sym>]\n", argv[0]); return 2; }
    if (nvs) nv = atoi(nvs);
    if (nv < 1 || nv > 8) { fprintf(stderr, "BOOTGEN_NV must be 1..8\n"); return 2; }
    if (!rs) rs = "44100";
    {   char buf[128], *p; strncpy(buf, rs, sizeof buf - 1); buf[sizeof buf - 1] = 0;
        for (p = strtok(buf, ","); p && nr < MAXRATE; p = strtok(NULL, ","))
            rates[nr++] = atoi(p); }

    ST = (unsigned char *)malloc(JUNO_STATE_BYTES);
    if (!ST) return 2;
    per = (size_t)EBDEV_VTILE + EBDEV_SEGBYTES + (size_t)nv * EBDEV_NSCAT * 4;

    printf("BOOT IMAGE  NV=%d  tile %u + segments %u + scatter %dx%d floats %u"
           "  = %u B PER RATE\n",
           nv, EBDEV_VTILE, EBDEV_SEGBYTES, nv, EBDEV_NSCAT,
           (unsigned)(nv * EBDEV_NSCAT * 4), (unsigned)per);

    for (i = 0; i < nr; ++i) {
        img[i] = (unsigned char *)calloc(1, per);
        boot_state(rates[i]);
        if (gather(img[i], nv) != per) { fprintf(stderr, "gather size\n"); return 1; }
    }

    /* HOW MUCH DOES THE RATE ACTUALLY MOVE? The firmware is 44,100 only; this
     * is the measurement that says whether carrying one rate is a decision or
     * a gamble. */
    for (i = 1; i < nr; ++i) {
        size_t d = 0, k;
        size_t dv = 0, dg = 0, ds = 0;
        for (k = 0; k < per; ++k)
            if (img[0][k] != img[i][k]) {
                ++d;
                if (k < EBDEV_VTILE) ++dv;
                else if (k < (size_t)EBDEV_VTILE + EBDEV_SEGBYTES) ++dg;
                else ++ds;
            }
        printf("  rate %d vs %d: %lu of %lu bytes differ  (tile %lu, segments %lu,"
               " scatter %lu)\n", rates[0], rates[i], (unsigned long)d,
               (unsigned long)per, (unsigned long)dv, (unsigned long)dg,
               (unsigned long)ds);
    }

    f = fopen(argv[1], "wb");
    if (!f) { perror(argv[1]); return 2; }
    for (i = 0; i < nr; ++i) fwrite(img[i], 1, per, f);
    fclose(f);
    printf("wrote %s: %d rate(s) x %u B = %u B\n", argv[1], nr,
           (unsigned)per, (unsigned)(per * (size_t)nr));

    if (argc >= 4) {
        f = fopen(argv[2], "w");
        if (!f) { perror(argv[2]); return 2; }
        fprintf(f, "/* GENERATED by tools/engineb/devboot/bootgen.c -- DO NOT EDIT.\n"
                   " * The port's post-init+prepare state, gathered through\n"
                   " * EBDEV_SEGTAB into the ebdev_state layout. */\n");
        fprintf(f, "#ifndef EBDEV_BOOT_H\n#define EBDEV_BOOT_H\n");
        fprintf(f, "#define EBDEV_BOOT_NV     %d\n", nv);
        fprintf(f, "#define EBDEV_BOOT_NRATE  %d\n", nr);
        fprintf(f, "#define EBDEV_BOOT_BYTES  %uu\n", (unsigned)per);
        fprintf(f, "static const int %s_rate[%d] = {", argv[3], nr);
        for (i = 0; i < nr; ++i) fprintf(f, "%s%d", i ? "," : "", rates[i]);
        fprintf(f, "};\n");
        fprintf(f, "static const unsigned char %s[%d][%u] = {\n", argv[3], nr, (unsigned)per);
        for (i = 0; i < nr; ++i) {
            fprintf(f, "{");
            for (j = 0; j < (int)per; ++j)
                fprintf(f, "%s%u", (j % 20) ? "," : (j ? ",\n" : ""), img[i][j]);
            fprintf(f, "},\n");
        }
        fprintf(f, "};\n#endif\n");
        fclose(f);
        printf("wrote %s (symbol %s)\n", argv[2], argv[3]);
    }
    return 0;
}
