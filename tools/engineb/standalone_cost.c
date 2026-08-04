/* standalone_cost.c — engine B's DSP cost with NO HARNESS IN IT.
 *
 * WHAT QUESTION THIS ANSWERS, and what it does NOT.
 *
 * Every cost figure this project has quoted for engine B was measured through
 * the null harness, where each module keeps its state in the PORT's memory
 * cells and reloads it every sample so one module can be substituted at a time.
 * MEASURED, host, 8 voices, 48 kHz: that marshalling is 27,585 of the whole
 * engine's 48,748 executed instructions per sample -- 56.6 %. Two lines that
 * copy the ladder history in and out are 9,088 of it on their own.
 *
 * So the harness numbers are inflated by roughly 24,000 instructions per sample
 * of glue that the shipped engine will not contain, and engine B's real cost
 * has never been measured. This program measures it: every module is driven
 * directly, with its state in an ordinary struct that stays in the program, and
 * no port cell is touched anywhere.
 *
 * WHAT IT DOES NOT INCLUDE, stated plainly so the number is not over-read:
 *   - voice allocation, note handling and the free-run advance of idle voices
 *   - patch recall and the per-patch coefficient computation (a control-rate
 *     cost, not a per-sample one, but not zero)
 *   - whatever inter-module plumbing the finished standalone engine adds
 * It is therefore a FLOOR for the DSP, not the finished engine's cost. The
 * finished number needs eb_engine_render(), which is still a skeleton: every
 * DSP call inside eb_engine.c is a stub today.
 *
 * WHAT IT DOES INCLUDE: all thirteen gated modules, at their real per-sample
 * invocation counts for 8 voices -- two envelopes, the mod CV, the VCF cutoff
 * CV, the CV/gate block, the pitch polynomial, the DCO's four sub-samples, the
 * ladder, the VCA/HPF, the noise SVF and the decimator per voice; the chorus,
 * the delay and the reverb once.
 *
 * ACCURACY IS NOT THE POINT HERE. The coefficients are plausible but arbitrary:
 * this program measures WORK, and it is the gates that decide correctness. It
 * deliberately does not claim to produce the right samples.
 *
 * Build:  cc -std=c99 -O2 -ffp-contract=off -Iengine_b -o t \
 *              tools/engineb/standalone_cost.c engine_b/eb_*.c -lm
 * Count:  valgrind --tool=callgrind ./t <samples>
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "eb_types.h"
#include "eb_envgen.h"
#include "eb_pwm_cv.h"
#include "eb_vcf_cv.h"
#include "eb_vcf_ladder.h"
#include "eb_vca_hpf.h"
#include "eb_dco.h"
#include "eb_decim.h"
#include "eb_noise_svf.h"
#include "eb_pitch.h"
#include "eb_cvgate.h"
#include "eb_chorus.h"
#include "eb_delay.h"
#include "eb_reverb.h"
#include "noise_lfsr.h"
#include "juno_tables.h"

#define NV 8

/* One voice's engine-B-resident state. This is the layout the standalone
 * engine will use: no cells, no reload. */
typedef struct {
    eb_env_state    env[2];
    eb_modcv_state  mod;
    eb_vcf_cv_state cv;
    eb_vcf_state    vcf;
    eb_vca_state    vca;
    eb_dco_state    dco;
    eb_decim_state  dec;
    eb_nsvf_state   nsv;
} vstate;

int main(int argc, char **argv)
{
    long n = (argc > 1) ? atol(argv[1]) : 20000, i;
    int v;

    static vstate V[NV];
    static eb_env_coef      EC[NV][2];
    static eb_modcv_coef    MC[NV];
    static eb_vcf_cv_coef   CC[NV];
    static eb_vcf_cv_derived CD[NV];
    static eb_vcf_coef      FC[NV];
    static eb_vca_coef      AC[NV];
    static eb_dco_coef      DC[NV];
    static eb_decim_coef    XC[NV];
    static eb_nsvf_coef     NC[NV];
    static eb_chorus_state  CH;
    static eb_delay_state   DL;
    static eb_reverb_state  RV;
    static eb_chorus_coef   CHC;
    static eb_delay_cfg     DLC;
    static eb_reverb_cfg    RVC;
    static eb_noise         NS;

    float acc = 0.0f;
    const int32_t *RVtaps = 0; int32_t *RVwipe = 0;

    memset(V, 0, sizeof V);
    memset(EC, 0, sizeof EC);   memset(MC, 0, sizeof MC);
    memset(CC, 0, sizeof CC);   memset(CD, 0, sizeof CD);
    memset(FC, 0, sizeof FC);   memset(AC, 0, sizeof AC);
    memset(DC, 0, sizeof DC);   memset(XC, 0, sizeof XC);
    memset(NC, 0, sizeof NC);
    memset(&CHC, 0, sizeof CHC); memset(&DLC, 0, sizeof DLC);
    memset(&RVC, 0, sizeof RVC);
    eb_chorus_reset(&CH);
    eb_reverb_init(&RV);
    /* The reverb reads a 33-entry pending-tap array and writes a wipe arm; both
     * must be real storage, not NULL. Seeded with the port's own tap depths so
     * the tank runs at a realistic length rather than a degenerate one. */
    {
        static int32_t taps[33], wipe;
        int t;
        for (t = 0; t < 33; ++t) taps[t] = 1000 + 300 * t;
        eb_reverb_seed(&RV, taps, 0.0f, 0);
        RVtaps = taps; RVwipe = &wipe;
    }
    eb_noise_init(&NS);

    /* Plausible non-degenerate coefficients. The DCO's three levels are
     * non-zero on purpose: its level gates skip a waveform whose level is
     * exactly 0, and a benchmark that let them skip would measure a cheaper
     * engine than the one that ships. */
    for (v = 0; v < NV; ++v) {
        int j;
        for (j = 0; j < 2; ++j) {
            /* Rate constants FIRST: without them the envelope never leaves
             * zero, the VCA multiplies by zero and the whole chain is silent.
             * A silent chain still does most of this work, but "the numbers
             * are all zero" is not a state a cost benchmark should be in. */
            eb_env_set_rate_consts(&EC[v][j], 0.01f, 0.99f, 1.0f, 1.0f, 1.0f,
                                   0.5f, 0.002f, 0.5f, 0.9f, 1.0f, 1.0f);
            eb_env_set_adsr(&EC[v][j], 0.3f, 0.5f, 0.4f, 0.6f);
        }
        DC[v].lvl_saw = 0.6f; DC[v].lvl_pulse = 0.5f; DC[v].lvl_sub = 0.4f;
        DC[v].amp_saw = DC[v].amp_pulse = DC[v].amp_sub = 0.5f;
        DC[v].gn_saw = DC[v].gn_pulse = DC[v].gn_sub = 0.8f;
        DC[v].sat_in = 0.7f;  DC[v].subthr = 0.25f;
        DC[v].k3 = -0.16f; DC[v].k5 = 0.008f; DC[v].k7 = -1.9e-4f;
        DC[v].k9 = 2.7e-6f; DC[v].k11 = -2.5e-8f;
        eb_dco_set_shape(&DC[v]);
        eb_dco_set_pitch(&DC[v], 0.01f + 0.001f * (float)v, 0.3f);
        for (j = 0; j < 16; ++j) XC[v].c[j] = 0.03f + 0.001f * (float)j;
        XC[v].k6256 = 0.5f; XC[v].k6272 = 0.25f;
        XC[v].k6336 = 0.9f;
        NC[v].k36 = 0.2f; NC[v].k52 = 0.3f; NC[v].k68 = 0.4f;
        NC[v].k84 = 0.5f; NC[v].k00 = 0.6f;
        /* The VCF and VCA coefficient structs are pure float (checked), so
         * they are filled with a varied non-degenerate pattern. Zeroed
         * coefficients would produce a silent chain, and a silent chain can
         * skip work that the shipped engine does -- which would make this
         * benchmark report a cheaper engine than the real one. */
        { float *f = (float *)&FC[v]; size_t k, nf = sizeof FC[v] / sizeof(float);
          for (k = 0; k < nf; ++k) f[k] = 0.2f + 0.01f * (float)(k % 17); }
        { float *f = (float *)&AC[v]; size_t k, nf = sizeof AC[v] / sizeof(float);
          for (k = 0; k < nf; ++k) f[k] = 0.3f + 0.01f * (float)(k % 13); }
        eb_vcf_cv_prepare(&CD[v], &CC[v]);
    }

    for (i = 0; i < n; ++i) {
        float noise = eb_noise_step(&NS);
        float mixL = 0.0f, mixR = 0.0f, oL, oR;

        for (v = 0; v < NV; ++v) {
            vstate *s = &V[v];
            float e1, e2, pit, pwm, cut, o6704, o6848, dcoq[4], nsv04, nsvo;
            float vcfo, vcao, decimo, cv;
            eb_cvgate_in gi; eb_cvgate_out go;

            /* control blocks */
            e1 = eb_env_tick(&s->env[0], &EC[v][0], 1.0f);
            e2 = eb_env_tick(&s->env[1], &EC[v][1], 1.0f);

            gi.t28 = 0.5f; gi.t29 = 0.4f; gi.k = 0.02f;
            gi.p28 = e1;   gi.p29 = e2;   gi.gate_off = -0.1f;
            eb_cvgate(&gi, &go);

            eb_modcv_tick(&MC[v], go.c464, go.c480, 0.1f, 0.2f, e1, e2,
                          &pit, &pwm);
            (void)eb_modcv_tap(&s->mod);
            eb_modcv_latch(&s->mod, pwm);

            cv = pit + 0.01f * (float)v;
            (void)eb_pitch_eval(cv, 1.0f);

            cut = eb_vcf_cv_tick(&s->cv, &CD[v], pit, pwm, 0.1f, 0.2f, e1, e2,
                                 &o6704, &o6848);

            /* audio blocks */
            eb_dco_step4(&s->dco, &DC[v], dcoq);
            decimo = eb_decim_tick(&s->dec, &XC[v], 0.1f,
                                   dcoq[0], dcoq[1], dcoq[2], dcoq[3]);
            nsvo = eb_nsvf_tick(&s->nsv, &NC[v], noise, &nsv04);
            vcfo = eb_vcf_tick(&s->vcf, &FC[v], decimo + nsvo * 0.05f,
                               cut, o6848);
            vcao = eb_vca_tick(&s->vca, &AC[v], vcfo, e1, e2, o6704, go.sign);
            mixL += vcao;
            mixR += vcao;
        }

        eb_chorus_tick_x(&CH, &CHC, mixL, &oL, &oR, 0, 0.0f);
        eb_delay_process(&DLC, &DL, 0, oL, oR, &oL, &oR);
        eb_reverb_process(&RVC, &RV, RVtaps, RVwipe, oL, oR, &oL, &oR);
        acc += mixL + oL + oR;
    }

    printf("samples=%ld acc=%g\n", n, (double)acc);
    if (acc == 0.0f) {
        fprintf(stderr,
            "REFUSING TO REPORT: the whole chain summed to EXACTLY 0, so this\n"
            "run measured a SILENT engine. Several modules skip work on a zero\n"
            "signal -- the DCO's level gates and its saturator shortcut are the\n"
            "obvious ones -- so a silent run reports a CHEAPER engine than the\n"
            "one that ships, which is the class of quiet wrongness this project\n"
            "keeps being caught by.\n"
            "WHAT TO DO: the coefficients here are placeholders and at least one\n"
            "of them leaves the chain dead. Drive it from a real recalled patch\n"
            "(tools/engineb/patch_roundtrip.py decodes one) instead of from\n"
            "invented constants, then this guard will pass on its own.\n");
        return 2;
    }
    return 0;
}
