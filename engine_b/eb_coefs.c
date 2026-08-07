/* eb_coefs.c — see eb_coefs.h. Every cell is copied from the shim that owns
 * the module; nothing is re-derived from the port source. */
#include "eb_coefs.h"
#ifdef EB_DUMP_SHAPE
#include <stdio.h>
#include <stdlib.h>
#endif
#include "eb_chorus_shim.h"
#include <string.h>

#define VBASE(b, v)  ((const unsigned char *)(b) + (unsigned)(v) * 10512u)
#define CF(p, off)   (*(const float *)((const unsigned char *)(p) + (off)))

void eb_render_coefs_build(const unsigned char *base, eb_render_coefs *c)
{
    int v, ei, i;
    memset(c, 0, sizeof *c);

    for (v = 0; v < EB_NUM_VOICES; ++v) {
        const unsigned char *a1 = VBASE(base, v);

        /* ---- envelopes (shim env): ENV2 = ENV1 + 480 ---------------------- */
        for (ei = 0; ei < 2; ++ei) {
            unsigned off = (unsigned)ei * 480u;
            eb_env_set_rate_consts(&c->env[v][ei],
                CF(a1, 2864 + off), CF(a1, 2880 + off), CF(a1, 2896 + off),
                CF(a1, 2912 + off), CF(a1, 2928 + off), CF(a1, 2944 + off),
                CF(a1, 2960 + off), CF(a1, 2848 + off), CF(a1, 2976 + off),
                CF(a1, 2992 + off), CF(a1, 3008 + off));
            eb_env_set_adsr(&c->env[v][ei],
                CF(a1, 2784 + off), CF(a1, 2800 + off),
                CF(a1, 2816 + off), CF(a1, 2832 + off));
        }

        /* ---- mod CV (shim pwm_cv), the shim's own 24-cell order ----------- */
        {
            static const int M[24] = { 3584, 3600, 3856, 3872, 3888, 3904,
                                       3920, 3936, 3952, 3968, 3984, 4000,
                                       4016, 4032, 4048, 4064, 4080, 4096,
                                       4112, 4128, 4144, 4160, 4176, 3552 };
            float r[24];
            for (i = 0; i < 24; ++i) r[i] = CF(a1, M[i]);
            eb_modcv_set(&c->mod[v], r[0], r[1], r[2], r[3], r[4], r[5], r[6],
                         r[7], r[8], r[9], r[10], r[11], r[12], r[13], r[14],
                         r[15], r[16], r[17], r[18], r[19], r[20], r[21],
                         r[22], r[23]);
        }

        /* ---- VCF cutoff CV (shim vcf_cv) + its derived form --------------- */
        {
            eb_vcf_cv_coef k;
            k.x6576 = CF(a1, 6576); k.x6608 = CF(a1, 6608);
            k.x6640 = CF(a1, 6640); k.x6672 = CF(a1, 6672);
            k.k6720 = CF(a1, 6720); k.k6736 = CF(a1, 6736);
            k.k6752 = CF(a1, 6752); k.k6768 = CF(a1, 6768);
            k.k6784 = CF(a1, 6784); k.k6800 = CF(a1, 6800);
            k.k6816 = CF(a1, 6816); k.x6832 = CF(a1, 6832);
            k.k6864 = CF(a1, 6864); k.k6928 = CF(a1, 6928);
            k.k6944 = CF(a1, 6944); k.k6960 = CF(a1, 6960);
            k.k7008 = CF(a1, 7008); k.k7024 = CF(a1, 7024);
            k.k7120 = CF(a1, 7120); k.k7136 = CF(a1, 7136);
            k.k7152 = CF(a1, 7152); k.k7200 = CF(a1, 7200);
            k.k7216 = CF(a1, 7216); k.k7232 = CF(a1, 7232);
            k.k7296 = CF(a1, 7296); k.k7312 = CF(a1, 7312);
            k.k7328 = CF(a1, 7328); k.k7344 = CF(a1, 7344);
            k.k7360 = CF(a1, 7360); k.k7376 = CF(a1, 7376);
            k.k7392 = CF(a1, 7392); k.k7408 = CF(a1, 7408);
            k.k7424 = CF(a1, 7424); k.k7440 = CF(a1, 7440);
            k.k7456 = CF(a1, 7456); k.k7472 = CF(a1, 7472);
            k.k7488 = CF(a1, 7488); k.k7504 = CF(a1, 7504);
            eb_vcf_cv_prepare(&c->cv[v], &k);
        }

        /* ---- VCF ladder (shim vcf_ladder) -------------------------------- */
        {
            eb_vcf_coef *q = &c->vcf[v];
            q->c9520 = CF(a1, 9520); q->c9536 = CF(a1, 9536);
            q->c9184 = CF(a1, 9184); q->c9072 = CF(a1, 9072);
            q->c9088 = CF(a1, 9088); q->c9104 = CF(a1, 9104);
            q->c9200 = CF(a1, 9200); q->c9216 = CF(a1, 9216);
            q->c9232 = CF(a1, 9232); q->c9248 = CF(a1, 9248);
            q->c9120 = CF(a1, 9120); q->c9136 = CF(a1, 9136);
            q->c9168 = CF(a1, 9168); q->c9152 = CF(a1, 9152);
            for (i = 0; i < 16; ++i) q->fir[i] = CF(a1, 9504 - 16 * i);
        }

        /* ---- VCA + HPF (shim vca_hpf) ------------------------------------ */
        {
            eb_vca_coef *q = &c->vca[v];
            q->c9552  = CF(a1, 9552);  q->c9584  = CF(a1, 9584);
            q->c9600  = CF(a1, 9600);  q->c9616  = CF(a1, 9616);
            q->c9680  = CF(a1, 9680);  q->c9744  = CF(a1, 9744);
            q->c9808  = CF(a1, 9808);  q->c9824  = CF(a1, 9824);
            q->c9888  = CF(a1, 9888);  q->c9952  = CF(a1, 9952);
            q->c9968  = CF(a1, 9968);  q->c9984  = CF(a1, 9984);
            q->c10000 = CF(a1, 10000); q->c10016 = CF(a1, 10016);
            q->c10032 = CF(a1, 10032); q->c10176 = CF(a1, 10176);
            q->c10192 = CF(a1, 10192); q->c10208 = CF(a1, 10208);
            q->c10224 = CF(a1, 10224); q->c10240 = CF(a1, 10240);
            q->c10256 = CF(a1, 10256); q->c10272 = CF(a1, 10272);
            q->c10288 = CF(a1, 10288); q->c10304 = CF(a1, 10304);
            q->c10320 = CF(a1, 10320); q->c10336 = CF(a1, 10336);
            q->c10352 = CF(a1, 10352); q->c10368 = CF(a1, 10368);
            q->c10384 = CF(a1, 10384); q->c10400 = CF(a1, 10400);
            q->c10464 = CF(a1, 10464); q->c10560 = CF(a1, 10560);
            q->c10576 = CF(a1, 10576); q->c10592 = CF(a1, 10592);
            q->c10608 = CF(a1, 10608); q->c10624 = CF(a1, 10624);
            q->c10640 = CF(a1, 10640);
        }

        /* ---- DCO (shim dco). set_shape derives sat_hi/sat_lo; the PITCH
         * fields are per sample and are set by eb_dcoprep's outputs. -------- */
        {
            eb_dco_coef *q = &c->dco[v];
            /* THE OSCILLATOR LEVELS ARE NOT WHERE THE SHIM READS THEM.
             *
             * The dco shim gathers cells 4736/4752/4768, and that is correct
             * FOR THE SHIM, which runs inside the port at a point where those
             * cells have already been written this sample. They are not
             * coefficients: src/voice_render.c writes all three every sample,
             * at :1702-1707, with JI -- which is why the audit that built this
             * file did not see them. It grepped `JF(a1, N) =` only, and every
             * one of these three cells is copied as an INT.
             *
             * MEASURED, and this is how it was found: with the copies cached
             * from a power-on state they are 0, the DCO emits exactly 0 on
             * every sub-sample, and the whole voice chain nulls at 0.0 dB rel
             * -- silence. The first run of the 1b-0 gate reported it.
             *
             * The real chain is same-sample and lag-free: recall cell 4192 ->
             * 4240 (:1126) -> v393 (:1667) -> 4736 (:1702), all before the DCO
             * reads it. 4192/4208/4224 have NO writer anywhere in the voice
             * function, so THEY are the coefficients. */
            q->lvl_saw   = CF(a1, 4192); q->lvl_pulse = CF(a1, 4208);
            q->lvl_sub   = CF(a1, 4224);
            q->gn_saw    = CF(a1, 5648); q->gn_pulse  = CF(a1, 5664);
            q->gn_sub    = CF(a1, 5680);
            q->amp_saw   = CF(a1, 5600); q->amp_pulse = CF(a1, 5616);
            q->amp_sub   = CF(a1, 5632);
            q->sat_in    = CF(a1, 5552);
            q->k3        = CF(a1, 5952); q->k5        = CF(a1, 5968);
            q->k7        = CF(a1, 5984); q->k9        = CF(a1, 6000);
            q->k11       = CF(a1, 6016); q->subthr    = CF(a1, 5584);
            eb_dco_set_shape(q);
#ifdef EB_DUMP_SHAPE
            /* THE SHAPE COEFFICIENTS, PER RECALL. eb_dco_wt.h finding 4 says
             * the per-VOICE spread of every DCO shape and gain coefficient is
             * exactly 0 over all 51 factory patches -- per voice WITHIN a
             * patch. It says nothing about ACROSS patches, and the residual
             * tables are built from ONE patch's values. The edge width goes as
             * 1/amp, so if amp moves between patches one table set cannot
             * serve them all. */
            {   static FILE *f;
                const char *p = getenv("EB_DUMP_SHAPE");
                if (!f && p) f = fopen(p, "a");
                if (f && v == 0)
                    fprintf(f, "%.9g %.9g %.9g %.9g %.9g %.9g %.9g %.9g %.9g\n",
                            (double)q->amp_saw, (double)q->amp_pulse,
                            (double)q->amp_sub, (double)q->sat_in,
                            (double)q->k3, (double)q->k5, (double)q->k7,
                            (double)q->k9, (double)q->k11);
            }
#endif
        }

        /* ---- decimator (shim decim) -------------------------------------- */
        {
            static const int CC[16] = {5712,5696,5728,5744,5760,5776,5792,5808,
                                       5824,5840,5856,5872,5888,5904,5920,5936};
            for (i = 0; i < 16; ++i) c->dec[v].c[i] = CF(a1, CC[i]);
            c->dec[v].k6256 = CF(a1, 6256); c->dec[v].k6272 = CF(a1, 6272);
            c->dec[v].k6336 = CF(a1, 6336);
        }

        /* ---- noise SVF (shim noise_svf) ---------------------------------- */
        c->nsv[v].k36 = CF(a1, 4336); c->nsv[v].k52 = CF(a1, 4352);
        c->nsv[v].k68 = CF(a1, 4368); c->nsv[v].k84 = CF(a1, 4384);
        c->nsv[v].k00 = CF(a1, 4400);

        /* ---- noise mix (shim noisemix). 3536 is PER SAMPLE and is NOT here. */
        c->nmix[v].k6416 = CF(a1, 6416); c->nmix[v].k6448 = CF(a1, 6448);
        c->nmix[v].k6512 = CF(a1, 6512); c->nmix[v].k6528 = CF(a1, 6528);

        /* ---- VCF resonance shaper (shim vcf_res). 8192 is the raw-pointer
         * cell; same address, ordinary load here. -------------------------- */
        {
            eb_vcf_res_coef *q = &c->res[v];
            q->k7600 = CF(a1, 7600); q->k7616 = CF(a1, 7616);
            q->k7632 = CF(a1, 7632); q->k7648 = CF(a1, 7648);
            q->k7664 = CF(a1, 7664); q->k7680 = CF(a1, 7680);
            q->k7696 = CF(a1, 7696); q->k7712 = CF(a1, 7712);
            q->k7728 = CF(a1, 7728); q->k7744 = CF(a1, 7744);
            q->k7760 = CF(a1, 7760); q->k7776 = CF(a1, 7776);
            q->k7792 = CF(a1, 7792); q->k7824 = CF(a1, 7824);
            q->k7840 = CF(a1, 7840); q->k7856 = CF(a1, 7856);
            q->k7872 = CF(a1, 7872); q->k7888 = CF(a1, 7888);
            q->k7904 = CF(a1, 7904); q->k7920 = CF(a1, 7920);
            q->k7936 = CF(a1, 7936); q->k7952 = CF(a1, 7952);
            q->k7968 = CF(a1, 7968); q->k7984 = CF(a1, 7984);
            q->k8000 = CF(a1, 8000); q->k8016 = CF(a1, 8016);
            q->k8032 = CF(a1, 8032); q->k8048 = CF(a1, 8048);
            q->k8064 = CF(a1, 8064); q->k8080 = CF(a1, 8080);
            q->k8096 = CF(a1, 8096); q->k8112 = CF(a1, 8112);
            q->k8128 = CF(a1, 8128); q->k8144 = CF(a1, 8144);
            q->k8160 = CF(a1, 8160); q->k8176 = CF(a1, 8176);
            q->k8192 = CF(a1, 8192);
#if EB_VCF_RES_LUT
            eb_vcf_res_prepare(q);
#endif
        }

        /* ---- DCO prep (shim dcoprep) ------------------------------------- */
        c->dprep[v].k5520 = CF(a1, 5520); c->dprep[v].k5536 = CF(a1, 5536);
        c->dprep[v].k5568 = CF(a1, 5568); c->dprep[v].k6288 = CF(a1, 6288);
        c->dprep[v].k6304 = CF(a1, 6304); c->dprep[v].k6320 = CF(a1, 6320);

        /* ---- glide (shim glide) ------------------------------------------ */
        c->glide[v].k592  = CF(a1, 592);  c->glide[v].k608  = CF(a1, 608);
        c->glide[v].k624  = CF(a1, 624);  c->glide[v].k768  = CF(a1, 768);
        c->glide[v].k784  = CF(a1, 784);  c->glide[v].k800  = CF(a1, 800);
        c->glide[v].k816  = CF(a1, 816);  c->glide[v].k832  = CF(a1, 832);
        c->glide[v].k848  = CF(a1, 848);  c->glide[v].k864  = CF(a1, 864);
        c->glide[v].k912  = CF(a1, 912);  c->glide[v].k1040 = CF(a1, 1040);
        c->glide[v].k1088 = CF(a1, 1088); c->glide[v].k1152 = CF(a1, 1152);
        c->glide[v].k1168 = CF(a1, 1168);
        eb_glide_prepare(&c->glide[v]);

        /* ---- LFO (shim lfo) ---------------------------------------------- */
        {
            eb_lfo_coef *q = &c->lfo[v];
            q->k1056 = CF(a1, 1056); q->k1072 = CF(a1, 1072);
            q->k1184 = CF(a1, 1184); q->k1200 = CF(a1, 1200);
            q->k1216 = CF(a1, 1216); q->k1856 = CF(a1, 1856);
            q->k1872 = CF(a1, 1872); q->k1888 = CF(a1, 1888);
            q->k1904 = CF(a1, 1904); q->k1920 = CF(a1, 1920);
            q->k1936 = CF(a1, 1936); q->k1952 = CF(a1, 1952);
            q->k1968 = CF(a1, 1968); q->k1984 = CF(a1, 1984);
            q->k2000 = CF(a1, 2000); q->k2016 = CF(a1, 2016);
            q->k2032 = CF(a1, 2032); q->k2048 = CF(a1, 2048);
            q->k2064 = CF(a1, 2064); q->k2080 = CF(a1, 2080);
            q->k2096 = CF(a1, 2096); q->k2112 = CF(a1, 2112);
            q->k2128 = CF(a1, 2128); q->k2144 = CF(a1, 2144);
            q->k2160 = CF(a1, 2160); q->k2176 = CF(a1, 2176);
            q->k2192 = CF(a1, 2192); q->k2208 = CF(a1, 2208);
            q->k2224 = CF(a1, 2224); q->k2240 = CF(a1, 2240);
            q->k2256 = CF(a1, 2256); q->k2272 = CF(a1, 2272);
            q->k2288 = CF(a1, 2288); q->k2304 = CF(a1, 2304);
            q->k2320 = CF(a1, 2320); q->k2336 = CF(a1, 2336);
            q->k2352 = CF(a1, 2352); q->k2368 = CF(a1, 2368);
            q->k2384 = CF(a1, 2384); q->k2400 = CF(a1, 2400);
            q->k2416 = CF(a1, 2416); q->k2432 = CF(a1, 2432);
            q->k2448 = CF(a1, 2448); q->k2464 = CF(a1, 2464);
            q->k2480 = CF(a1, 2480); q->k2496 = CF(a1, 2496);
            q->k2512 = CF(a1, 2512);
        }
        c->lfo_ext_gate[v] = CF(a1, 944);
        c->lfo_ext0[v]     = CF(a1, 976);
        c->lfo_ext1[v]     = CF(a1, 1008);

        /* ---- eb_cvgate's inputs: cells 176/208/272*240/304/544 ----------- */
        c->cvg_t28[v]      = CF(a1, 176);
        c->cvg_t29[v]      = CF(a1, 208);
        c->cvg_k[v]        = CF(a1, 272) * CF(a1, 240);
        c->cvg_p28[v]      = CF(a1, 304);
        c->cvg_gate_off[v] = CF(a1, 544);

        /* ---- key follow / velocity (cells 368/384) ----------------------- */
        c->pitch_off[v]  = CF(a1, 4448);
        c->pitch_gain[v] = CF(a1, 3840);
        c->kbd[v] = CF(a1, 368);
        c->vel[v] = CF(a1, 384);

        /* ---- per-envelope LFO TRIG switch (2560 + 480*ei) ---------------- */
        c->env_lfo_trig[v][0] = CF(a1, 2560);
        c->env_lfo_trig[v][1] = CF(a1, 2560 + 480);
    }

    /* ---- the shared noise generator (base cells) ------------------------- */
    c->notecv.n84272 = CF(base, 84272); c->notecv.n84304 = CF(base, 84304);
    c->notecv.n84400 = CF(base, 84400); c->notecv.n84416 = CF(base, 84416);

    /* ---- FX. The chorus already has a proven loader in eb_chorus_shim. --- */
    ebsh_load_coef(&c->chorus, base);
    {   /* delay cfg -- shim delay's own gather */
        eb_delay_cfg *k = &c->delay;
        k->b0 = CF(base, 102368); k->b1 = CF(base, 102384);
        k->b2 = CF(base, 102400); k->a1 = CF(base, 102416);
        k->a2 = CF(base, 102432); k->mixA = CF(base, 102448);
        k->svf_g = CF(base, 102464); k->svf_r = CF(base, 102480);
        k->mixB = CF(base, 102496); k->dry = CF(base, 102512);
        k->wet = CF(base, 102528); k->fb = CF(base, 102560);
        k->on = CF(base, 102576); k->mute = CF(base, 102592);
        k->lp_g = CF(base, 102608); k->k624 = CF(base, 102624);
        k->lf_damp = CF(base, 102640); k->hp_g = CF(base, 102656);
        k->hf_damp = CF(base, 102672); k->k688 = CF(base, 102688);
        k->dc_g = CF(base, 102704); k->fade_k = CF(base, 102720);
        k->fade_up = CF(base, 102752); k->fade_dn = CF(base, 102768);
        k->slew = CF(base, 102784); k->time_target = CF(base, 102352);
        k->fade_gain = CF(base, 84496);
    }
    {   /* reverb cfg -- shim reverb's own gather */
        eb_reverb_cfg *k = &c->reverb;
        int rk;
        k->send = CF(base, 10759408); k->gate = CF(base, 10759376);
        k->dry  = CF(base, 10759424); k->wet  = CF(base, 10759440);
        k->ap   = CF(base, 10759392);
        for (rk = 0; rk < 8; ++rk)
            k->f_in[rk] = CF(base, 10759520 + 16 * rk);
        for (rk = 0; rk < 4; ++rk) {
            k->damp[rk][0] = CF(base, 10759648 + 48 * rk);
            k->damp[rk][1] = CF(base, 10759664 + 48 * rk);
            k->damp[rk][2] = CF(base, 10759680 + 48 * rk);
        }
        k->lfo_inc   = CF(base, 10759504);
        k->lfo_depth = CF(base, 10759488);
    }
}

void eb_render_state_seed(const unsigned char *base, eb_render_state *s)
{
    int v, ei, i;
    memset(s, 0, sizeof *s);
    for (v = 0; v < EB_NUM_VOICES; ++v) {
        const unsigned char *a1 = VBASE(base, v);
        for (ei = 0; ei < 2; ++ei) {
            unsigned off = (unsigned)ei * 480u;
            s->env[v][ei].y = CF(a1, 2592 + off);
            s->env[v][ei].h = CF(a1, 2624 + off);
            s->env[v][ei].p = CF(a1, 2640 + off);
            s->env[v][ei].t = CF(a1, 2672 + off);
            s->env[v][ei].r = CF(a1, 2720 + off);
        }
        s->cv[v].s_env = CF(a1, 6896);
        s->cv[v].s_a   = CF(a1, 7088);
        s->cv[v].s_b   = CF(a1, 7168);
        s->vca[v].sm      = CF(a1, 9712);  s->vca[v].g1  = CF(a1, 9776);
        s->vca[v].g2      = CF(a1, 9856);  s->vca[v].gate_y = CF(a1, 9904);
        s->vca[v].lp      = CF(a1, 10096); s->vca[v].lp2 = CF(a1, 10128);
        s->vca[v].dcacc   = CF(a1, 10432);
        s->vca[v].x1      = CF(a1, 10480); s->vca[v].yA = CF(a1, 10496);
        s->vca[v].yB      = CF(a1, 10512);
        s->res[v].s7520 = CF(a1, 7520); s->res[v].s7536 = CF(a1, 7536);
        s->res[v].s7552 = CF(a1, 7552); s->res[v].s7568 = CF(a1, 7568);
        s->lfo[v].s1488 = CF(a1, 1488); s->lfo[v].s1504 = CF(a1, 1504);
        s->lfo[v].s1536 = CF(a1, 1536); s->lfo[v].s1568 = CF(a1, 1568);
        s->lfo[v].s1600 = CF(a1, 1600);
        s->glide[v].s560  = CF(a1, 560);  s->glide[v].s656  = CF(a1, 656);
        s->glide[v].s672  = CF(a1, 672);  s->glide[v].s688  = CF(a1, 688);
        s->glide[v].s704  = CF(a1, 704);  s->glide[v].s880  = CF(a1, 880);
        s->glide[v].s1104 = CF(a1, 1104);
        s->gate_cell320[v] = CF(a1, 320);
        s->aux_edge[v] = (CF(base, 101504u + (unsigned)v * 32u) == 1.0f);
        (void)i;
    }
    s->notecv.n84336 = CF(base, 84336);
    s->notecv.n84368 = CF(base, 84368);
    ebsh_snapshot(&s->chorus, base);
}

void eb_render_events_mirror(unsigned char *base, eb_render_state *s)
{
    int v;
    for (v = 0; v < EB_NUM_VOICES; ++v) {
        unsigned char *a1 = (unsigned char *)VBASE(base, v);
        unsigned aux = 101504u + (unsigned)v * 32u;
        /* Cell 320 is written ONLY by note events (src/juno_note.c); inside
         * src/voice_render.c its only two writers are the save/restore pair at
         * :593 and :2177, which leave it unchanged. So re-reading it at an event
         * boundary is exact, and re-reading it PER SAMPLE would be neither
         * necessary nor honest. */
        s->gate_cell320[v] = CF(a1, 320);
        if (CF(base, aux) == 1.0f) {
            s->aux_edge[v] = 1;
            /* CONSUME IT ON THE PORT'S SIDE TOO. The port clears this one-shot
             * at :2178 when its voice function runs; under this gate that
             * function does not run, so an uncleared 1.0 would be re-armed by
             * every later event and the retrigger would fire repeatedly. */
            *(float *)(base + aux) = 0.0f;
        }
    }
    /* the DCO's live coefficient copy is seeded from the recall coefficients,
     * so a coefficient rebuild must invalidate it or the voice keeps last
     * patch's non-pitch DCO fields. */
    memset(s->dco_live_seeded, 0, sizeof s->dco_live_seeded);
}
