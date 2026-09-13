/* chain_gate.c -- CHAIN4's law, executed BEFORE any board exists.
 *
 * Question it answers: does the 4-chip merge + injection law
 * (esp32s3/main/s3_chain.h) reproduce the SINGLE-ENGINE render bit-exactly?
 *
 * Method: for every factory patch, recall at chord 6 through the SAME device
 * sequence the firmware runs (eb_devseq, -DEB_DEVCELLS), then render twice:
 *   REF    one engine, voices 2..7 awake, its master -> PCM.
 *   CHAIN  four engines, each awake ONLY in its position's window, their
 *          voice chunks routed through s3_chain_merge (pos 4 -> 3 -> 2) and
 *          s3_chain_inject (pos 1), chip 1's master -> PCM.
 * The two float streams must be BIT-IDENTICAL, sample by sample, L and R.
 * Latency skew is deliberately NOT simulated -- it is a documented property
 * (CHAIN4.md §7), not part of the sum law.
 *
 * Also counted: how often a pre-add slot is -0.0 (the one value chip 1's
 * re-add can flip to +0.0). Nonzero is NOT a failure -- the compare below is
 * on the MASTER OUTPUT, which is where the claim lives.
 *
 * TEETH (each must be SEEN TO FAIL): build with -DCHAIN_TOOTH=1 to misroute
 * slot 1 into slot 2 at injection -- the gate must then report MISMATCH.
 * The topology checks are exercised negatively in main() every run.
 *
 * usage: chain_gate <boot.bin> <bank64.bin> <template.bin>
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
#include "eb_engine.h"
#include "devchord.h"
#include "../../../esp32s3/main/s3_chain.h"

#if DEVCHORD_N != 6
#error "chain_gate is a 6-voice law -- build with -DDEVCHORD_N=6"
#endif

#ifndef NSAMP
#define NSAMP 2048   /* per patch; envelopes + chorus move well inside this.
                      * Overridable: the REFCRC cross-build null needs a
                      * window long enough for the LFO to clear its delay
                      * ramp and reach the audio (its tooth showed 2,048 is
                      * NOT: a broken live wrap moved 0 of 64 keys). */
#endif

static eb_render_coefs RC;
static eb_master_coef  MC;
static eb_render_state RS0;          /* the seeded state, copied per engine */
static eb_master_state MS0;
static unsigned char BANKBUF[EB_DEVSEQ_BANK_BYTES];
static float REFPCM[2 * NSAMP];      /* the REF stream, for the cross-build key */

/* the five render states (ref + four positions) and two master states */
static eb_render_state RSr, RSp[5];
static eb_master_state MSr, MSc;
static eb_engine Er, Ep[5];

/* THE RINGS. Classic build: never ticked, both masters share one zeroed
 * struct. FULL build (scope directive 2026-09-13): the delay/reverb/e5
 * arms read AND WRITE their rings, so the REF master and the CHAIN master
 * must each own a private set or each corrupts the other's tails and the
 * sum law fails for a reason that is not the chain's. Lengths are the
 * firmware's own table (esp32s3/main/s3_listen_meta.h S3L_RING_LEN);
 * content zeroed per patch = the chip's own power-on state (rings_alloc
 * callocs). */
static eb_master_rings RGr, RGc;
#if !EB_CLASSIC
static const int32_t RING_LEN[9] =
    { 524288, 8192, 524288, 524288, 8192, 8192, 1024, 8192, 8192 };
static float *ring_mem[2][9];

static void rings_setup(void)
{
    eb_master_rings *rg[2] = { &RGr, &RGc };
    int s, i;
    for (s = 0; s < 2; ++s) {
        float **dst[9] = { &rg[s]->t1, &rg[s]->t23, &rg[s]->t5_0,
                           &rg[s]->t5_1, &rg[s]->t5_2, &rg[s]->t5_3,
                           &rg[s]->e5, &rg[s]->t4_0, &rg[s]->t4_1 };
        int32_t *len[9] = { &rg[s]->t1_len, &rg[s]->t23_len,
                            &rg[s]->t5_0_len, &rg[s]->t5_1_len,
                            &rg[s]->t5_2_len, &rg[s]->t5_3_len,
                            &rg[s]->e5_len, &rg[s]->t4_0_len,
                            &rg[s]->t4_1_len };
        for (i = 0; i < 9; ++i) {
            if (!ring_mem[s][i])
                ring_mem[s][i] = (float *)malloc((size_t)RING_LEN[i]
                                                 * sizeof(float));
            if (!ring_mem[s][i]) { fprintf(stderr, "ring alloc\n"); exit(2); }
            memset(ring_mem[s][i], 0, (size_t)RING_LEN[i] * sizeof(float));
            *dst[i] = ring_mem[s][i];
            *len[i] = RING_LEN[i];
        }
    }
}
#endif

static void wake(eb_engine *E, int lo, int hi)
{
    int k;
    for (k = 0; k < EB_NUM_VOICES; ++k)
        E->v[k].atrest = !(k >= lo && k < hi);
}

int main(int argc, char **argv)
{
    FILE *f;
    unsigned char *boot, *bank64, *tpl;
    long bootn, bankn, tpln;
    int p, i, k, pos, bad = 0;
    unsigned long negzero = 0, mism_patches = 0;
    s3_chain_cfg cfg[5];

    if (argc < 4) {
        fprintf(stderr, "usage: %s <boot.bin> <bank64.bin> <template.bin>\n",
                argv[0]);
        return 2;
    }
#define SLURP(path, buf, len) do {                                          \
        f = fopen(path, "rb"); if (!f) { perror(path); return 2; }          \
        fseek(f, 0, SEEK_END); len = ftell(f); fseek(f, 0, SEEK_SET);       \
        buf = (unsigned char *)malloc((size_t)len);                         \
        if (!buf || fread(buf, 1, (size_t)len, f) != (size_t)len) return 2; \
        fclose(f);                                                          \
    } while (0)
    SLURP(argv[1], boot, bootn);
    SLURP(argv[2], bank64, bankn);
    SLURP(argv[3], tpl, tpln);
#undef SLURP
    (void)bootn; (void)bankn;

    /* ---- the topology teeth run FIRST, every invocation ------------------ */
    for (pos = 1; pos <= 4; ++pos) cfg[pos] = s3_chain_config(pos);
    /* windows tile [2,8) */
    if (!(cfg[4].v_lo == 2 && cfg[4].v_hi == cfg[3].v_lo &&
          cfg[3].v_hi == cfg[2].v_lo && cfg[2].v_hi == cfg[1].v_lo &&
          cfg[1].v_hi == 8)) {
        printf("CHAIN: *** the position windows do not tile [2,8) ***\n");
        return 1;
    }
    /* every real hop passes; every corruption is REFUSED */
    for (pos = 2; pos <= 4; ++pos) {
        int alo, ahi;
        s3_chain_down_window(pos - 1, &alo, &ahi);
        if (s3_chain_hop_check(alo, ahi, cfg[pos].adv_lo, cfg[pos].adv_hi)) {
            printf("CHAIN: *** hop %d->%d refused its own true windows ***\n",
                   pos, pos - 1);
            return 1;
        }
        if (!s3_chain_hop_check(alo, ahi, cfg[pos].adv_lo, cfg[pos].adv_hi + 1)
            || !s3_chain_hop_check(alo + 1, ahi, cfg[pos].adv_lo,
                                   cfg[pos].adv_hi)
            || !s3_chain_hop_check(alo, ahi, cfg[pos].adv_lo,
                                   cfg[pos].adv_hi - 1)) {
            printf("CHAIN: *** hop check PASSED an overlap/gap -- toothless ***\n");
            return 1;
        }
    }
    printf("CHAIN: topology OK (windows tile, hop check refuses overlap+gap)\n");

    /* ---- the marker law (review 2026-09-06) ------------------------------
     * CHAIN_TOOTH_MARK substitutes the OLD law (training-pattern tag shared,
     * index unbounded): every check below must then FAIL, or the gate has no
     * reach over the defect it exists to hold down. */
#ifdef CHAIN_TOOTH_MARK
#define REALIGN_CI(w, n) (((((uint32_t)(w)) & 0xFF000000u) == 0xA5000000u) \
                              ? (((uint32_t)(w)) & 0x1FFu) : 0u)
#else
#define REALIGN_CI(w, n) s3_chain_realign_ci((w), (n))
#endif
    /* a true marker heals its exact rotation */
    if (REALIGN_CI(s3_chain_mark(7, 5), 256) != 5) {
        printf("CHAIN: *** marker law: a true rotation of 5 not healed ***\n");
        return 1;
    }
    /* frame 0 of an ALIGNED marked chunk asks for nothing */
    if (REALIGN_CI(s3_chain_mark(7, 0), 256) != 0) {
        printf("CHAIN: *** marker law: an aligned chunk 'realigned' ***\n");
        return 1;
    }
    /* an aligned TRAINING-PATTERN chunk (slot-3 word = counter 3) must not
     * realign: the shared tag broke the alignment it had, every lock */
    if (REALIGN_CI(0xA5000003u, 256) != 0) {
        printf("CHAIN: *** marker law: a pattern word bought a realign ***\n");
        return 1;
    }
    /* an out-of-range index must not buy a discard: unsigned (n - ci)
     * once meant HOURS of silence off one corrupted word */
    if (REALIGN_CI(s3_chain_mark(7, 503), 256) != 0) {
        printf("CHAIN: *** marker law: index 503 >= n=256 accepted ***\n");
        return 1;
    }
#undef REALIGN_CI
    printf("CHAIN: marker law OK (tag distinct from pattern, index bounded)\n");

    /* ---- the in-band CRC law (2026-09-13) --------------------------------
     * Frame 1's slot-3 word carries the chunk's own CRC (advert/pend
     * redemption retired after three churn runs). CHAIN_TOOTH_INBAND
     * substitutes a check that skips the zeroing -- self-referential, it
     * can never pass -- and every positive check below must then FAIL. */
    {
        enum { GW = 4 * 256 };              /* one TDM4 chunk of words */
        static uint32_t gbuf[GW];
        uint32_t gi;
#ifdef CHAIN_TOOTH_INBAND
#define CRC_CHECK(w, nw, sl) \
        (eb_devseq_crc32((w), (size_t)(nw) * 4u) == (w)[S3_CHAIN_CRCW(sl)])
#else
#define CRC_CHECK(w, nw, sl) s3_chain_crc_check((w), (nw), 4, \
                                                eb_devseq_crc32)
#endif
        for (gi = 0; gi < GW; ++gi)         /* audio-ish filler + markers */
            gbuf[gi] = 0x3f000000u + gi * 2654435761u;
        for (gi = 0; gi < 256; ++gi)
            gbuf[4 * gi + 3] = s3_chain_mark(9, gi);
        s3_chain_crc_seal(gbuf, GW, 4, eb_devseq_crc32);
        if (!CRC_CHECK(gbuf, GW, 4)) {
            printf("CHAIN: *** in-band law: a sealed chunk failed its own "
                   "check ***\n");
            return 1;
        }
        /* check() zeroed the crc word: a second check must FAIL (proves
         * the word participates and the check is not a tautology) */
        if (CRC_CHECK(gbuf, GW, 4)) {
            printf("CHAIN: *** in-band law: a chunk with a ZEROED crc word "
                   "passed ***\n");
            return 1;
        }
        s3_chain_crc_seal(gbuf, GW, 4, eb_devseq_crc32);
        gbuf[777] ^= 0x00000100u;           /* one flipped bit, one word */
        if (CRC_CHECK(gbuf, GW, 4)) {
            printf("CHAIN: *** in-band law: a corrupted chunk passed ***\n");
            return 1;
        }
        gbuf[777] ^= 0x00000100u;
        s3_chain_crc_seal(gbuf, GW, 4, eb_devseq_crc32);
        gbuf[S3_CHAIN_CRCW(4)] ^= 1u;       /* the crc word itself */
        if (CRC_CHECK(gbuf, GW, 4)) {
            printf("CHAIN: *** in-band law: a corrupted CRC WORD passed "
                   "***\n");
            return 1;
        }
#undef CRC_CHECK
    }
    printf("CHAIN: in-band crc law OK (seal round-trips, any corruption "
           "refused)\n");

    /* ---- the sum law, on the real engine, all %d patches ----------------- */
    for (p = 0; p < EB_BANK_COUNT; ++p) {
        int mism = 0;
        if (eb_devseq_boot_cells(boot, EBDEV_NV)) { fprintf(stderr, "boot\n"); return 2; }
        if (eb_devseq_install(BANKBUF, tpl, (size_t)tpln,
                              bank64 + (size_t)p * EB_PATCH_BYTES)) {
            fprintf(stderr, "install %d\n", p); return 2;
        }
        eb_devseq_recall(BANKBUF, 128.0f);
        eb_devseq_notes_on(DEVCHORD_VOICE, DEVCHORD_NOTE, DEVCHORD_VEL,
                           DEVCHORD_N);
        eb_render_coefs_build((const unsigned char *)0, &RC);
        eb_master_coefs_build((const unsigned char *)0, &MC);
        eb_render_state_seed((const unsigned char *)0, &RS0);
        eb_master_state_seed((const unsigned char *)0, &MS0);
        eb_render_events_mirror((unsigned char *)0, &RS0);

#if EB_CLASSIC
        memset(&RGr, 0, sizeof RGr);            /* CLASSIC: no rings */
        memset(&RGc, 0, sizeof RGc);
#else
        rings_setup();          /* private zeroed rings per master, per patch */
#endif
        RSr = RS0; MSr = MS0; MSc = MS0;
        eb_engine_init(&Er, 44100.0f); Er.render_ok = 1;
        wake(&Er, S3_CHAIN_V_LO, S3_CHAIN_V_HI);
        for (pos = 1; pos <= 4; ++pos) {
            RSp[pos] = RS0;
            eb_engine_init(&Ep[pos], 44100.0f); Ep[pos].render_ok = 1;
            wake(&Ep[pos], cfg[pos].v_lo, cfg[pos].v_hi);
        }

        for (i = 0; i < NSAMP; ++i) {
            float vr[EB_NUM_VOICES], Lr = 0, Rr = 0, Lc = 0, Rc = 0;
            float vp[5][EB_NUM_VOICES];
            float w4[4], w3[4], w2[4], m[EB_NUM_VOICES];
            eb_shared_tick shr, shp;
            /* THE PROLOGUE RUNS HERE, AS THE FIRMWARE RUNS IT (2026-09-13).
             * This gate used to call eb_engine_render_voices (sh == NULL):
             * voice 0 is at rest in every window, its LFO arm never ran, and
             * the WHOLE GATE RENDERED WITH A SILENT LFO -- found because the
             * REFCRC tooth refused to bite on a broken live LFO edit (0 of
             * 64 keys moved). The firmware free-runs the prologue every
             * sample (EB_LFO_FREERUN); now the gate does too, one private
             * shared-tick per engine, exactly the four-chips reality where
             * every chip derives the identical LFO from identical seeds. */
            /* REF */
            for (k = 0; k < EB_NUM_VOICES; ++k) vr[k] = 0.0f;
            shr.ready = 0;
            eb_engine_render_shared(&Er, &RSr, &RC, &shr);
            eb_engine_render_range(&Er, &RSr, &RC, (const eb_render_needs *)0,
                                   S3_CHAIN_V_LO, S3_CHAIN_V_HI, &shr, vr);
            (void)eb_master_render(&MSr, &MC, &RGr, vr, &Lr, &Rr);
            /* CHAIN */
            for (pos = 1; pos <= 4; ++pos) {
                for (k = 0; k < EB_NUM_VOICES; ++k) vp[pos][k] = 0.0f;
                shp.ready = 0;
                eb_engine_render_shared(&Ep[pos], &RSp[pos], &RC, &shp);
                eb_engine_render_range(&Ep[pos], &RSp[pos], &RC,
                                       (const eb_render_needs *)0,
                                       cfg[pos].v_lo, cfg[pos].v_hi,
                                       &shp, vp[pos]);
            }
            s3_chain_merge(&cfg[4], vp[4], (const float *)0, 0, w4);
            s3_chain_merge(&cfg[3], vp[3], w4, 1, w3);
            s3_chain_merge(&cfg[2], vp[2], w3, 1, w2);
            s3_chain_inject(vp[1], w2, 1, m);
#if CHAIN_TOOTH
            /* the tooth: misroute the v18 pre-add into the raw-voice slot */
            m[6] = w2[1]; m[5] = w2[2];
#endif
            {   uint32_t z0, z1;
                memcpy(&z0, &w2[0], 4); memcpy(&z1, &w2[1], 4);
                if (z0 == 0x80000000u) ++negzero;
                if (z1 == 0x80000000u) ++negzero;
            }
            (void)eb_master_render(&MSc, &MC, &RGc, m, &Lc, &Rc);
            if (memcmp(&Lr, &Lc, 4) || memcmp(&Rr, &Rc, 4)) {
                if (!mism)
                    printf("  patch %2d: FIRST MISMATCH at sample %d "
                           "(L %08lx vs %08lx)\n", p, i,
                           (unsigned long)*(uint32_t *)&Lr,
                           (unsigned long)*(uint32_t *)&Lc);
                mism = 1;
            }
            REFPCM[2 * i] = Lr; REFPCM[2 * i + 1] = Rr;
        }
        if (mism) { ++mism_patches; bad = 1; }
        /* THE REF-STREAM KEY. The sum law above compares fork-vs-fork
         * WITHIN one build and is blind to an ENGINE edit (both sides
         * change identically). This line is the cross-build null: an
         * EXACTLY-0 engine change must leave all 64 keys byte-identical
         * between the before and after runs, and a tooth edit must move
         * them. Print-only -- diff two runs, never assert one. */
        printf("REFCRC: patch %2d %08lx\n", p,
               (unsigned long)eb_devseq_crc32(REFPCM, sizeof REFPCM));
    }
    printf("CHAIN: %s -- %lu of %d patches mismatched over %d samples each; "
           "-0.0 pre-adds seen %lu\n",
           bad ? "*** SUM LAW BROKEN ***" : "sum law EXACTLY 0",
           mism_patches, EB_BANK_COUNT, NSAMP, negzero);
    return bad;
}
