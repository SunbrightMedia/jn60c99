/* classic_scan.c -- WHICH RECALLED COEFFICIENTS ARE CONSTANT UNDER THE
 * CLASSIC BYTE LAW?
 *
 * THE QUESTION. eb_patch_classicize (engine_b/eb_patch.c) pins every
 * non-1982 parameter at a neutral byte FOREVER, recall included. A
 * coefficient cell whose derivation depends ONLY on pinned bytes is then a
 * compile-time constant of the classic build -- and if that constant is 0.0
 * (or an identity), the arithmetic that consumes it can be deleted under
 * #if EB_CLASSIC exactly the way EB_ZEROCOEF deleted its 13, with the
 * fork-vs-fork null as the proof. This tool MEASURES that set by execution;
 * it does not derive it by reading the recall math, because reading is how
 * five bytes went missing from the compact format (patchbank.c header).
 *
 * METHOD (the proven EB_RECALL_POS scan shape, moved to the compact domain,
 * because the compact patch bytes are the device's ONLY free recall input --
 * every bank, user banks included, reaches coefficients as 134 bytes through
 * eb_patch_install, where the byte law runs):
 *   - 67 bases: the 64 factory compact patches + 3 fully randomised ones
 *     (a parameter can be gated by a byte no factory patch moves).
 *   - Perturb: 13 bases (factory 0,7,...,63 + the 3 random) x each of the
 *     134 compact bytes x probe values {0x00,0x03,0x0C,0x7F,0xFF} (four are
 *     the proven set; 0xFF adds the high-nibble corner the compact cells
 *     can carry).
 *   - A coefficient byte is CLASSIC-CONSTANT iff it is identical across all
 *     67 bases AND no perturbation moved it.
 *
 * WHAT THE VERDICT MEANS: no compact-patch input can move the cell. It does
 * NOT certify edits that bypass recall (live parameter writes); a deletion
 * candidate must still check its cell has no runtime writer, and the
 * fork-vs-fork null over the full battery remains the proof that lands it.
 *
 * THE TOOTH (a scan that cannot fail proves nothing): after the scan, the
 * pinned PORTAMENTO byte pair (blob 108/109 -- record 124/125, both in
 * EB_RECALL_POS) is rewritten DIRECTLY in the record AFTER the law ran,
 * simulating a missing pin. The same diff machinery MUST now see
 * coefficients move on some base. If it does not, the compare is blind or
 * the probe never reaches the coefficients, and the run FAILS.
 *
 * usage: classic_scan <eb_bank64.bin> <eb_template.bin>
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stddef.h>
#include <stdint.h>

#include "juno_engine.h"
#include "juno_apply.h"
#include "juno_driver.h"
#include "eb_coefs.h"
#include "eb_master_coefs.h"
#include "eb_patch.h"

#if !EB_CLASSIC
#error "classic_scan measures the CLASSIC byte law: build with -DEB_CLASSIC=1 (the chain_gate.sh flag set)."
#endif

#define BANK_HEADER 23
#define BANK_STRIDE 20223
#define TEMPLATE_BYTES 4096

static unsigned char *ST;
static unsigned char *fake;
static unsigned char TPL[TEMPLATE_BYTES];
static eb_render_coefs RC;
static eb_master_coef  MC;

#define NB_ALL  67              /* 64 factory + 3 randomised            */
#define NB_PERT 13              /* factory 0,7,...,63 + the 3 randomised */
static unsigned char BASEQ[NB_ALL][EB_PATCH_BYTES];

/* one snapshot per base, for the cross-base equality half */
static eb_render_coefs RC_BASE[NB_ALL];
static eb_master_coef  MC_BASE[NB_ALL];

/* per-byte movement maps */
static unsigned char rc_moved[sizeof(eb_render_coefs)];
static unsigned char mc_moved[sizeof(eb_master_coef)];
static unsigned char rc_vary[sizeof(eb_render_coefs)];   /* differs across bases */
static unsigned char mc_vary[sizeof(eb_master_coef)];

static void boot(void)
{
    memset(ST, 0, JUNO_STATE_BYTES);
    juno_chorus_init(ST);
    JF(ST, 16) = 44100.0f;
    juno_engine_init(ST);
    juno_engine_prepare(ST);
}

/* the device recall, byte for byte the patchbank.c/devrecall shim order */
static void build_from(const unsigned char *qb, int tooth_v)
{
    eb_patch q;
    memcpy(q.b, qb, EB_PATCH_BYTES);
    memset(fake, 0, BANK_HEADER + BANK_STRIDE);
    memcpy(fake + BANK_HEADER, TPL, TEMPLATE_BYTES);
    eb_patch_install(fake + BANK_HEADER, &q);
    if (tooth_v >= 0) {
        /* BYPASS THE LAW: un-pin PORTAMENTO after install ran it. */
        fake[BANK_HEADER + EB_BANK_BLOB_OFF + 108] = (unsigned char)((tooth_v >> 4) & 0xF);
        fake[BANK_HEADER + EB_BANK_BLOB_OFF + 109] = (unsigned char)(tooth_v & 0xF);
    }
    boot();
    juno_bank_apply(ST, fake, 0);
    juno_driver_seed_voices(ST);
    juno_apply_unison_spread(ST, juno_bank_assign(fake, 0));
    juno_apply_condition(ST, juno_bank_condition(fake, 0));
    juno_apply_lfo_tempo(ST, juno_bank_lfo_rate_byte(fake, 0), 128.0f);
    memset(&RC, 0, sizeof RC);
    memset(&MC, 0, sizeof MC);
    eb_render_coefs_build(ST, &RC);
    eb_master_coefs_build(ST, &MC);
}

static void mark_diff(const void *a, const void *b, size_t n, unsigned char *map)
{
    const unsigned char *x = (const unsigned char *)a;
    const unsigned char *y = (const unsigned char *)b;
    size_t i;
    for (i = 0; i < n; ++i) if (x[i] != y[i]) map[i] = 1;
}

/* ------------------------------------------------------------- naming ----
 * Per-voice members are summarised: a field word is reported once when its
 * verdict agrees across all EB_NUM_VOICES voices (the common case), and per
 * voice otherwise. Names inside eb_lfo_coef / eb_glide_coef are spelled out
 * because those are the deletion hunting grounds; other modules print a raw
 * word offset that eb_render.h resolves. */
typedef struct { const char *name; size_t off, elem; int n; } member_t;
#define M1(f)      { #f, offsetof(eb_render_coefs, f), sizeof(((eb_render_coefs *)0)->f), 1 }
#define MV(f)      { #f, offsetof(eb_render_coefs, f), sizeof(((eb_render_coefs *)0)->f[0]), EB_NUM_VOICES }
#define MV2(f)     { #f, offsetof(eb_render_coefs, f), sizeof(((eb_render_coefs *)0)->f[0]), EB_NUM_VOICES }
static const member_t MEMB[] = {
    MV2(env), MV(mod), MV(cv), MV(vcf), MV(vca), MV(dco), MV(dec), MV(nsv),
    MV(lfo), MV(glide), M1(notecv), MV(nmix), MV(res), MV(dprep),
    MV(cvg_t28), MV(cvg_t29), MV(cvg_k), MV(cvg_p28), MV(cvg_gate_off),
    MV(pitch_off), MV(pitch_gain), MV(kbd), MV(vel),
    MV2(env_lfo_trig), MV(lfo_ext_gate), MV(lfo_ext0), MV(lfo_ext1),
    M1(chorus), M1(delay), M1(reverb),
};
#define NMEMB (sizeof MEMB / sizeof MEMB[0])

static const char *LFO_F[] = {
    "k1056","k1072","k1184","k1200","k1216","k1856","k1872","k1888","k1904",
    "k1920","k1936","k1952","k1968","k1984","k2000","k2016","k2032","k2048",
    "k2064","k2080","k2096","k2112","k2128","k2144","k2160","k2176","k2192",
    "k2208","k2224","k2240","k2256","k2272","k2288","k2304","k2320","k2336",
    "k2352","k2368","k2384","k2400","k2416","k2432","k2448","k2464","k2480",
    "k2496","k2512" };
static const char *GLIDE_F[] = {
    "k592","k608","k624","k768","k784","k800","k816","k832","k848","k864",
    "k912","k1040","k1088","k1152","k1168","d_exp" };

static const char *fieldname(const member_t *m, size_t w, char *buf, size_t bn)
{
    size_t nf = m->elem / 4;
    if (strcmp(m->name, "lfo") == 0 && w < sizeof LFO_F / sizeof *LFO_F)
        return LFO_F[w];
    if (strcmp(m->name, "glide") == 0 && w < sizeof GLIDE_F / sizeof *GLIDE_F)
        return GLIDE_F[w];
    if (nf <= 1) return "";
    snprintf(buf, bn, "+%02zu", w * 4);
    return buf;
}

int main(int argc, char **argv)
{
    static const unsigned char VAL[5] = { 0x00u, 0x03u, 0x0Cu, 0x7Fu, 0xFFu };
    static const int PBASE[NB_PERT] =
        { 0, 7, 14, 21, 28, 35, 42, 49, 56, 63, 64, 65, 66 };
    FILE *f;
    unsigned s = 20260913u;
    int b, i, k;
    long nbuild = 0;
    size_t w;

    if (argc < 3) {
        fprintf(stderr, "usage: %s <eb_bank64.bin> <eb_template.bin>\n", argv[0]);
        return 2;
    }
    f = fopen(argv[1], "rb");
    if (!f) { perror(argv[1]); return 2; }
    if (fread(BASEQ, 1, 64 * EB_PATCH_BYTES, f) != 64 * (size_t)EB_PATCH_BYTES)
        { fprintf(stderr, "short bank64\n"); return 2; }
    fclose(f);
    f = fopen(argv[2], "rb");
    if (!f) { perror(argv[2]); return 2; }
    if (fread(TPL, 1, TEMPLATE_BYTES, f) != TEMPLATE_BYTES)
        { fprintf(stderr, "short template\n"); return 2; }
    fclose(f);
    for (b = 64; b < NB_ALL; ++b)
        for (i = 0; i < EB_PATCH_BYTES; ++i) {
            s = s * 1103515245u + 12345u;
            BASEQ[b][i] = (unsigned char)((s >> 16) & 0xFF);
        }

    ST   = (unsigned char *)malloc(JUNO_STATE_BYTES);
    fake = (unsigned char *)malloc(BANK_HEADER + BANK_STRIDE);
    if (!ST || !fake) return 2;

    /* ---- 1: the 67 base builds + cross-base variability ---- */
    for (b = 0; b < NB_ALL; ++b) {
        build_from(BASEQ[b], -1); ++nbuild;
        memcpy(&RC_BASE[b], &RC, sizeof RC);
        memcpy(&MC_BASE[b], &MC, sizeof MC);
        if (b) {
            mark_diff(&RC_BASE[0], &RC, sizeof RC, rc_vary);
            mark_diff(&MC_BASE[0], &MC, sizeof MC, mc_vary);
        }
    }

    /* ---- 2: the perturbation scan ---- */
    for (b = 0; b < NB_PERT; ++b) {
        const unsigned char *qb = BASEQ[PBASE[b]];
        const eb_render_coefs *r0 = &RC_BASE[PBASE[b]];
        const eb_master_coef  *m0 = &MC_BASE[PBASE[b]];
        unsigned char q[EB_PATCH_BYTES];
        long moved_here = 0;
        memcpy(q, qb, EB_PATCH_BYTES);
        for (i = 0; i < EB_PATCH_BYTES; ++i) {
            unsigned char orig = q[i];
            for (k = 0; k < 5; ++k) {
                size_t j;
                if (VAL[k] == orig) continue;
                q[i] = VAL[k];
                build_from(q, -1); ++nbuild;
                for (j = 0; j < sizeof RC; ++j)
                    if (((unsigned char *)r0)[j] != ((unsigned char *)&RC)[j])
                        { rc_moved[j] = 1; ++moved_here; }
                for (j = 0; j < sizeof MC; ++j)
                    if (((unsigned char *)m0)[j] != ((unsigned char *)&MC)[j])
                        { mc_moved[j] = 1; ++moved_here; }
            }
            q[i] = orig;
        }
        printf("perturb base %2d (patch %2d%s): %ld coefficient-byte moves\n",
               b, PBASE[b], PBASE[b] >= 64 ? " RANDOM" : "", moved_here);
        /* half of the tooth, per base: a base on which NOTHING moves means
         * the diff never ran or recall ignored the compact bytes. */
        if (moved_here == 0) {
            printf("*** SCAN BLIND on base %d: no perturbation moved anything ***\n", b);
            return 1;
        }
    }

    /* ---- 3: the verdict ---- */
    {
        long nconst = 0, nzero = 0, nmov = 0;
        char fb[16];
        printf("\n=== CLASSIC-CONSTANT eb_render_coefs WORDS "
               "(no compact byte can move them) ===\n");
        for (w = 0; w < NMEMB; ++w) {
            const member_t *m = &MEMB[w];
            size_t nw = m->elem / 4, fw;
            for (fw = 0; fw < nw; ++fw) {
                int allc = 1, anyc = 0, v;
                for (v = 0; v < m->n; ++v) {
                    size_t off = m->off + (size_t)v * m->elem + fw * 4, j;
                    int c = 1;
                    for (j = 0; j < 4; ++j)
                        if (rc_moved[off + j] || rc_vary[off + j]) c = 0;
                    if (c) anyc = 1; else allc = 0;
                }
                if (!anyc) { nmov += m->n; continue; }
                for (v = 0; v < m->n; ++v) {
                    size_t off = m->off + (size_t)v * m->elem + fw * 4, j;
                    int c = 1;
                    float fv;
                    for (j = 0; j < 4; ++j)
                        if (rc_moved[off + j] || rc_vary[off + j]) c = 0;
                    if (!c) continue;
                    memcpy(&fv, (unsigned char *)&RC_BASE[0] + off, 4);
                    ++nconst;
                    if (fv == 0.0f) ++nzero;
                    if (allc && v > 0) continue;      /* summarised below */
                    printf("  %-12s %-6s %s = %.9g%s\n",
                           m->name, fieldname(m, fw, fb, sizeof fb),
                           allc ? "[all v]" : (m->n > 1 ? "[one v]" : ""),
                           (double)fv, fv == 0.0f ? "   ZERO" : "");
                    if (allc) break;
                }
            }
        }
        printf("render words: %ld classic-constant (%ld of them ZERO), "
               "%ld movable\n", nconst, nzero, nmov);
    }
    {
        long nconst = 0, nmov = 0;
        for (w = 0; w + 4 <= sizeof MC; w += 4) {
            int c = 1; size_t j;
            for (j = 0; j < 4; ++j) if (mc_moved[w + j] || mc_vary[w + j]) c = 0;
            if (c) ++nconst; else ++nmov;
        }
        printf("master words: %ld classic-constant, %ld movable "
               "(map via eb_master_coef; classic already drops delay/reverb)\n",
               nconst, nmov);
    }

    /* ---- 4: THE TOOTH -- bypass the PORTAMENTO pin post-install ---- */
    {
        long bite = 0;
        for (b = 0; b < NB_PERT && !bite; ++b) {
            const eb_render_coefs *r0 = &RC_BASE[PBASE[b]];
            for (k = 0; k < 5 && !bite; ++k) {
                size_t j;
                build_from(BASEQ[PBASE[b]], VAL[k]); ++nbuild;
                for (j = 0; j < sizeof RC; ++j)
                    if (((unsigned char *)r0)[j] != ((unsigned char *)&RC)[j])
                        ++bite;
            }
        }
        printf("\nTOOTH (un-pin PORTAMENTO in the record, post-law): %s\n",
               bite ? "BITES -- the bypass moved coefficients, the compare sees it"
                    : "*** DID NOT BITE -- the scan proves nothing ***");
        printf("%ld recall builds total\n", nbuild);
        if (!bite) return 1;
    }
    return 0;
}
