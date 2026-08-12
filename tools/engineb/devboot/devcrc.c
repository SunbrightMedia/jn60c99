/* devcrc.c -- THE HOST ORACLE FOR THE BOARD'S OWN ARITHMETIC.
 *
 * The firmware recalls a patch on the chip and prints a CRC32 of the
 * coefficients it built. That number is worth nothing unless something says
 * what it SHOULD be. This program produces that table, by running the SAME
 * SEQUENCE -- engine_b/dev/eb_devseq.c, one source, compiled into both -- on
 * the host, through the SAME rebased addressing (-DEB_DEVCELLS), from the SAME
 * baked boot image the firmware flashes.
 *
 * So the comparison the board prints is host-vs-chip on identical code and
 * identical inputs. What it can therefore catch: a wrong float result on
 * Xtensa, a struct that lays out differently, a boot image that did not
 * survive the flash, a patch byte the compact format drops on one side only.
 * What it CANNOT catch: an error both sides make, because both sides are this
 * source. The 1,152-case devrecall gate is what covers that, and this is not a
 * substitute for it.
 *
 * IT ALSO ANSWERS A QUESTION THE 1,152-CASE GATE DOES NOT. That gate calls
 * eb_render_coefs_build / eb_master_coefs_build / eb_render_state_seed /
 * eb_render_events_mirror, and it checks EBDEV_S.miss at the end -- but it
 * never calls eb_master_state_seed(), which the firmware must. Any cell that
 * function reads outside the map would be a SINK read on the device: a wrong
 * FX state, silently. This program calls it and reports the miss count, per
 * patch, before anybody flashes anything.
 *
 * usage: devcrc <boot.bin> <bank64.bin> <template.bin> <out.h>
 *   env  DEVCRC_NV=8   (must match EBDEV_NV the firmware is built at)
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>

#include "ebdev.h"
#include "eb_devseq.h"
#include "eb_patch.h"
#include "eb_coefs.h"
#include "eb_master_coefs.h"
#include "eb_render.h"
#include "eb_master.h"

/* the chord the listen firmware plays, and the voices it plays it on. Both are
 * shared with the firmware through this header so the two cannot drift. */
#include "devchord.h"

static eb_render_coefs RC;
static eb_master_coef  MC;
static eb_render_state RS;
static eb_master_state MS;

static unsigned char BANKBUF[EB_DEVSEQ_BANK_BYTES];

int main(int argc, char **argv)
{
    FILE *f;
    unsigned char *boot;
    unsigned char *bank64;
    unsigned char *tpl;
    long bootn, bankn, tpln;
    unsigned nv = 8;
    int p, i, bad = 0;
    unsigned long miss_total = 0;
    uint32_t rcc[EB_BANK_COUNT], mcc[EB_BANK_COUNT];
    unsigned long missp[EB_BANK_COUNT];
    const char *e = getenv("DEVCRC_NV");

    if (argc < 5) {
        fprintf(stderr, "usage: %s <boot.bin> <bank64.bin> <template.bin> <out.h>\n",
                argv[0]);
        return 2;
    }
    if (e) nv = (unsigned)atoi(e);
    if (nv != (unsigned)EBDEV_NV) {
        fprintf(stderr, "DEVCRC_NV=%u but this build is EBDEV_NV=%d\n",
                nv, EBDEV_NV);
        return 2;
    }

#define SLURP(path, buf, len) do {                                         \
        f = fopen(path, "rb"); if (!f) { perror(path); return 2; }          \
        fseek(f, 0, SEEK_END); len = ftell(f); fseek(f, 0, SEEK_SET);       \
        buf = (unsigned char *)malloc((size_t)len);                        \
        if (!buf || fread(buf, 1, (size_t)len, f) != (size_t)len) return 2; \
        fclose(f);                                                          \
    } while (0)
    SLURP(argv[1], boot, bootn);
    SLURP(argv[2], bank64, bankn);
    SLURP(argv[3], tpl, tpln);
#undef SLURP

    if ((size_t)bootn < (size_t)(EBDEV_VTILE + EBDEV_SEGBYTES
                                 + EBDEV_NV * EBDEV_NSCAT * 4)) {
        fprintf(stderr, "boot image is %ld B, need %u\n", bootn,
                (unsigned)(EBDEV_VTILE + EBDEV_SEGBYTES
                           + EBDEV_NV * EBDEV_NSCAT * 4));
        return 2;
    }
    if (bankn != (long)EB_BANK_COUNT * EB_PATCH_BYTES) {
        fprintf(stderr, "bank is %ld B, need %d x %d = %d\n", bankn,
                EB_BANK_COUNT, EB_PATCH_BYTES,
                EB_BANK_COUNT * EB_PATCH_BYTES);
        return 2;
    }

    printf("DEVCRC  EBDEV_NV=%d  cell array %u B  patch %d B  template %ld B\n",
           EBDEV_NV, (unsigned)sizeof(ebdev_state), EB_PATCH_BYTES, tpln);
    printf("        sizeof eb_render_coefs %u  eb_master_coef %u\n",
           (unsigned)sizeof(eb_render_coefs), (unsigned)sizeof(eb_master_coef));

    for (p = 0; p < EB_BANK_COUNT; ++p) {
        ebdev_reset_counters();
        if (eb_devseq_boot_cells(boot, nv)) { fprintf(stderr, "boot load\n"); return 2; }
        if (eb_devseq_install(BANKBUF, tpl, (size_t)tpln,
                              bank64 + (size_t)p * EB_PATCH_BYTES)) {
            fprintf(stderr, "install patch %d\n", p); return 2;
        }
        eb_devseq_recall(BANKBUF, 128.0f);
        eb_devseq_notes_on(DEVCHORD_VOICE, DEVCHORD_NOTE, DEVCHORD_VEL,
                           DEVCHORD_N);
        eb_render_coefs_build((const unsigned char *)0, &RC);
        eb_master_coefs_build((const unsigned char *)0, &MC);
        /* the two the 1,152-case gate does not both run. See the header. */
        eb_render_state_seed((const unsigned char *)0, &RS);
        eb_master_state_seed((const unsigned char *)0, &MS);
        eb_render_events_mirror((unsigned char *)0, &RS);

        rcc[p] = eb_devseq_crc32(&RC, sizeof RC);
        mcc[p] = eb_devseq_crc32(&MC, sizeof MC);
        missp[p] = EBDEV_S.miss;
        miss_total += EBDEV_S.miss;
        if (EBDEV_S.miss) {
            printf("  patch %2d: *** %lu UNMAPPED CELL ACCESSES, last offset %lu ***\n",
                   p, EBDEV_S.miss, EBDEV_S.lastmiss);
            for (i = 0; i < EBDEV_NMISS && i < 12; ++i)
                printf("      UNMAPPED %lu\n", EBDEV_MISSLIST[i]);
            bad = 1;
        }
    }

    /* NON-VACUITY. If every patch produced the same CRC the table would be
     * decoration and the board's comparison would pass on a stuck recall. */
    {
        int distinct = 0;
        for (p = 1; p < EB_BANK_COUNT; ++p)
            if (rcc[p] != rcc[0]) ++distinct;
        printf("        %d of %d patches differ from patch 0 (voice coefficients)\n",
               distinct, EB_BANK_COUNT - 1);
        if (distinct < EB_BANK_COUNT - 8) {
            printf("*** THE CRC TABLE IS NEARLY CONSTANT -- it would not detect a "
                   "stuck recall ***\n");
            bad = 1;
        }
    }
    printf("        unmapped cell accesses over all %d patches: %lu%s\n",
           EB_BANK_COUNT, miss_total,
           miss_total ? "  *** THE MAP IS INCOMPLETE ***" : "  (map complete)");

    f = fopen(argv[4], "w");
    if (!f) { perror(argv[4]); return 2; }
    fprintf(f, "/* GENERATED by tools/engineb/devboot/devcrc.c -- DO NOT EDIT.\n"
               " * What the board's own recall must produce, per patch, computed\n"
               " * by the SAME sequence (engine_b/dev/eb_devseq.c) on the host.\n"
               " * A mismatch on the board means the CHIP disagrees with the host,\n"
               " * which is the one thing no host gate can test. */\n");
    fprintf(f, "#ifndef DEVCRC_H\n#define DEVCRC_H\n");
    fprintf(f, "#define DEVCRC_NPATCH   %d\n", EB_BANK_COUNT);
    fprintf(f, "#define DEVCRC_CHORD_N  %d\n", DEVCHORD_N);
    fprintf(f, "#define DEVCRC_NV       %d\n", EBDEV_NV);
    fprintf(f, "#define DEVCRC_PATCH_B  %d\n", EB_PATCH_BYTES);
    fprintf(f, "#define DEVCRC_RC_SZ    %uu\n", (unsigned)sizeof(eb_render_coefs));
    fprintf(f, "#define DEVCRC_MC_SZ    %uu\n", (unsigned)sizeof(eb_master_coef));
    fprintf(f, "static const unsigned long devcrc_rc[DEVCRC_NPATCH] = {\n");
    for (p = 0; p < EB_BANK_COUNT; ++p)
        fprintf(f, "%s0x%08lxul", (p % 6) ? ", " : (p ? ",\n  " : "  "),
                (unsigned long)rcc[p]);
    fprintf(f, "\n};\n");
    fprintf(f, "static const unsigned long devcrc_mc[DEVCRC_NPATCH] = {\n");
    for (p = 0; p < EB_BANK_COUNT; ++p)
        fprintf(f, "%s0x%08lxul", (p % 6) ? ", " : (p ? ",\n  " : "  "),
                (unsigned long)mcc[p]);
    fprintf(f, "\n};\n");
    fprintf(f, "static const unsigned long devcrc_miss[DEVCRC_NPATCH] = {\n");
    for (p = 0; p < EB_BANK_COUNT; ++p)
        fprintf(f, "%s%luul", (p % 10) ? ", " : (p ? ",\n  " : "  "), missp[p]);
    fprintf(f, "\n};\n#endif\n");
    fclose(f);
    printf("wrote %s\n", argv[4]);
    return bad;
}
