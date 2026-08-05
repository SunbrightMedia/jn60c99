/* harness.c -- QEMU ESP32-S3 instruction-count harness for engine B's hot
 * functions.  Produces the first EXECUTED-XTENSA numbers for the S3 port
 * decision (docs/engineb/S3_ASSESSMENT.md).
 *
 * WHAT IS COUNTED.  QEMU is run with -icount shift=0; under icount the Xtensa
 * CCOUNT special register advances once per EXECUTED INSTRUCTION (scout
 * finding, re-verified by this harness's CAL region: an empty rsr..rsr span
 * measures a small constant).  Every number here is therefore
 * "QEMU-executed Xtensa instructions", NOT cycles: it does not model cache
 * misses, memory waits, FPU latency or dual-issue.  Label: MEASURED
 * (QEMU-executed instructions).
 *
 * HOW IT IS DRIVEN -- the non-silence contract.  This project was caught once
 * by a benchmark whose chain summed to exactly zero (silent voices skip work:
 * the DCO's level gates, the saturator shortcut, the reverb's mute early-out).
 * tools/engineb/standalone_cost.c's invented coefficients ARE that trap: its
 * VCF-CV coefficient block is zeroed, so the ladder's cutoff is 0 and the
 * whole audio chain outputs exactly 0; its reverb is seeded mute=0, so the
 * tank arm never executes (eb_reverb.c:143 early-out).  Found by executing it.
 * This harness therefore drives:
 *   - REAL recalled FX coefficients and REAL envelope rate/ADSR cells, read
 *     from the sealed port (libjuno.so, factory patch 0, 48 kHz) by
 *     gen_fx_coefs.py into fx_coefs.h.  Reverb gate/mute = 1.0, delay on=1.0,
 *     chorus onoff/mute = 1.0 -- the warm, settled state of a playing engine.
 *   - the standalone_cost.c pattern for the remaining voice-module
 *     coefficients, PLUS non-degenerate fills for the two blocks it left
 *     zeroed (modcv, vcf-cv), scaled so the ladder cutoff lands in a sane
 *     range (checked by the finiteness guard below).
 *   - evolving inputs: an LCG dithers the smoother targets and the pitch CV
 *     every call; the note gate cycles 4000 on / 2000 off so attack, decay,
 *     release and re-arm branches all execute; the DCO gets real audible-range
 *     increments so its wrap branches fire.
 *   - a per-region float sink, printed at the end: any region whose sink is
 *     exactly 0.0 or non-finite fails the run (printed as SANITY FAIL).
 *
 * WHAT PER-CALL INCLUDES.  The measured span is argument setup + windowed
 * call + the function body + return.  That is what the shipped engine pays
 * per call unless the compiler inlines the callee; it is the honest per-call
 * figure for a function-per-module engine.
 *
 * MEMORY.  Built with -DEB_DELAY_LEN=16384 (task instruction): the 65536 ring
 * would also have fit QEMU's modeled 1.44 MB DRAM, but the real S3's internal
 * SRAM cannot hold it (it is the allocation that forces PSRAM).  The ring
 * length does not change the per-sample instruction count -- the ring index
 * mask is the same instruction either way.  The reverb state (~200 KB) fits
 * QEMU DRAM beside everything else, so ONE build measures all 13 modules.
 */
#include <stdint.h>

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
#include "fx_coefs.h"

#if defined(EB_HOST) || defined(EB_IDF)
/* EB_IDF: the SAME harness compiled into the S3 firmware (esp32s3/main),
 * printf-backed like the host build but with the REAL CCOUNT -- so on
 * silicon the identical workload reports CYCLES where QEMU reported
 * executed instructions, and c/i is their ratio with nothing else varied.
 * One source; the firmware carries no drifting copy. */
#include <stdio.h>
static void uart_putc(char c)      { putchar(c); }
static void uart_puts(const char *s){ fputs(s, stdout); }
static void uart_u64(uint64_t v)   { printf("%llu", (unsigned long long)v); }
static void uart_hex32(uint32_t v) { printf("0x%08x", v); }
#ifdef EB_IDF
static inline uint32_t ccount(void)
{
    uint32_t r;
    __asm__ volatile ("rsr.ccount %0" : "=a"(r));
    return r;
}
#else
static inline uint32_t ccount(void){ return 0; }
#endif
#else
#include "uart.h"
static inline uint32_t ccount(void)
{
    uint32_t r;
    __asm__ volatile ("rsr.ccount %0" : "=a"(r));
    return r;
}
#endif

#define NV 8
#ifndef NSAMP
#define NSAMP  12500      /* measured samples: 8 voices -> 100,000 calls per
                           * per-voice tick, 200,000 env calls, 12,500 FX
                           * calls.  icount execution is deterministic, so
                           * more samples average branch-path mix, not noise. */
#endif
#define NWARM  18000      /* unmeasured warm-up.  MUST EXCEED the delay's tap
                           * depth: patch 0's real DELAY TIME is a 16,872-
                           * sample tap (time_target 1.0298 x 16384), and until
                           * the ring has filled that deep the wet path
                           * processes zeros -- the first host run of this
                           * harness was caught doing exactly that (delay sink
                           * bit-identical to chorus sink).  18,000 > 16,874. */

/* ------------------------------------------------------------- regions */
enum {
    R_ENV, R_CVGATE, R_MODCV, R_PITCH, R_VCFCV, R_DCO, R_DECIM, R_NSVF,
    R_VCF, R_VCA, R_NOISE, R_CHORUS, R_DELAY, R_REVERB, R_TOTAL, R_CAL,
    R_N
};
static const char *rname[R_N] = {
    "env", "cvgate", "modcv", "pitch_dbl", "vcf_cv", "dco_step4", "decim",
    "nsvf", "vcf", "vca", "noise_lfsr", "chorus", "delay", "reverb",
    "sample_total", "cal"
};
static uint64_t rtot[R_N];
static uint32_t rcnt[R_N];
static float    rsink[R_N];

/* variadic so a measured expression may contain unparenthesised commas */
#define MEAS(k, ...) do {                        \
        uint32_t _t0 = ccount();                 \
        __VA_ARGS__;                             \
        uint32_t _t1 = ccount();                 \
        rtot[k] += (uint32_t)(_t1 - _t0);        \
        rcnt[k]++;                               \
    } while (0)

/* ------------------------------------------------------------- LCG drive */
static uint32_t lcg = 0x1234567u;
static inline uint32_t lnext(void) { lcg = lcg * 1103515245u + 12345u; return lcg; }
/* uniform-ish in [0,1) from the top 24 bits */
static inline float lfrac(void) { return (float)(lnext() >> 8) * (1.0f / 16777216.0f); }

/* ------------------------------------------------------------- state */
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

static vstate           V[NV];
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
static int32_t          rv_wipe;

static volatile float g_acc;      /* defeats dead-code elimination */

static void fill_pattern(float *f, int n, float base, float step, int mod)
{
    int k;
    for (k = 0; k < n; ++k) f[k] = base + step * (float)(k % mod);
}

static void setup(void)
{
    int v, j;

    /* --- envelopes: REAL recalled cells (factory patch 0, 48 kHz) --- */
    for (v = 0; v < NV; ++v) {
        const uint32_t *raw;
        float r[15];
        for (j = 0; j < 2; ++j) {
            int i;
            raw = (j == 0) ? EBQ_ENV1_RAW : EBQ_ENV2_RAW;
            for (i = 0; i < 15; ++i) {
                uint32_t b = raw[i];
                __builtin_memcpy(&r[i], &b, 4);
            }
            eb_env_set_rate_consts(&EC[v][j], r[4], r[5], r[6], r[7], r[8],
                                   r[9], r[10], r[11], r[12], r[13], r[14]);
            eb_env_set_adsr(&EC[v][j], r[0], r[1], r[2], r[3]);
        }

        /* --- DCO: standalone_cost.c values (non-zero levels on purpose:
         * the level gates skip a waveform whose level is exactly 0) --- */
        DC[v].lvl_saw = 0.6f; DC[v].lvl_pulse = 0.5f; DC[v].lvl_sub = 0.4f;
        DC[v].amp_saw = DC[v].amp_pulse = DC[v].amp_sub = 0.5f;
        DC[v].gn_saw = DC[v].gn_pulse = DC[v].gn_sub = 0.8f;
        DC[v].sat_in = 0.7f;  DC[v].subthr = 0.25f;
        DC[v].k3 = -0.16f; DC[v].k5 = 0.008f; DC[v].k7 = -1.9e-4f;
        DC[v].k9 = 2.7e-6f; DC[v].k11 = -2.5e-8f;
        eb_dco_set_shape(&DC[v]);
        /* real audible increments so the wrap branches fire (period 59..100) */
        eb_dco_set_pitch(&DC[v], 0.01f + 0.001f * (float)v, 0.3f);

        for (j = 0; j < 16; ++j) XC[v].c[j] = 0.03f + 0.001f * (float)j;
        XC[v].k6256 = 0.5f; XC[v].k6272 = 0.25f;
        XC[v].k6336 = 0.9f;
        /* k5456 was a COEF here when this harness was written; task 1b-0
         * proved it is a PER-SAMPLE value (eb_dcoprep's third output) and
         * made it an argument so the type system refuses the cache. The
         * harness passes the same 0.1f it used to seed. */
        NC[v].k36 = 0.2f; NC[v].k52 = 0.3f; NC[v].k68 = 0.4f;
        NC[v].k84 = 0.5f; NC[v].k00 = 0.6f;
        fill_pattern((float *)&FC[v], (int)(sizeof FC[v] / sizeof(float)),
                     0.2f, 0.01f, 17);
        fill_pattern((float *)&AC[v], (int)(sizeof AC[v] / sizeof(float)),
                     0.3f, 0.01f, 13);

        /* --- the two blocks standalone_cost.c left ZEROED (its silent-chain
         * root cause).  Small magnitudes: the vcf-cv output is the ladder
         * cutoff, and the finiteness guard below rejects a blow-up. --- */
        fill_pattern((float *)&MC[v], (int)(sizeof MC[v] / sizeof(float)),
                     0.05f, 0.02f, 11);
        fill_pattern((float *)&CC[v], (int)(sizeof CC[v] / sizeof(float)),
                     0.02f, 0.005f, 13);
        eb_vcf_cv_prepare(&CD[v], &CC[v]);
    }

    /* --- FX: REAL recalled coefficients (fx_coefs.h, MEASURED) --- */
    eb_chorus_reset(&CH);
    CHC.dtime = EBQ_CH_DTIME;   CHC.depth_r = EBQ_CH_DEPTHR;
    CHC.rate = EBQ_CH_RATE;     CHC.phase_off = EBQ_CH_PHOFF;
    CHC.depth = EBQ_CH_DEPTH;   CHC.noise = EBQ_CH_NOISE;
    CHC.dry = EBQ_CH_DRY;       CHC.wet = EBQ_CH_WET;
    CHC.smco = EBQ_CH_SMCO;     CHC.onoff = EBQ_CH_ONOFF;
    CHC.mute = EBQ_CH_MUTE;
    CHC.b0 = EBQ_CH_B0; CHC.b1 = EBQ_CH_B1; CHC.b2 = EBQ_CH_B2;
    CHC.a1 = EBQ_CH_A1; CHC.a2 = EBQ_CH_A2;
    CHC.hb0 = EBQ_CH_HB0; CHC.hb1 = EBQ_CH_HB1; CHC.ha1 = EBQ_CH_HA1;
    CHC.svf_f = EBQ_CH_SVFF; CHC.svf_d = EBQ_CH_SVFD;
    CHC.eps = EBQ_CH_EPS;
    CHC.mod_scale = EBQ_CH_MODSCALE; CHC.mod_off = EBQ_CH_MODOFF;
    CHC.ramp_inc = EBQ_CH_RAMPINC;   CHC.ramp_max = EBQ_CH_RAMPMAX;
    CHC.slew_up = EBQ_CH_SLEWUP;     CHC.slew_dn = EBQ_CH_SLEWDN;
    CHC.n_gain = EBQ_CH_NGAIN;       CHC.n_off = EBQ_CH_NOFF;
    for (j = 0; j < 8; ++j) {
        uint32_t b = EBQ_CH_NF[j];
        __builtin_memcpy(&CHC.nf[j], &b, 4);
    }
    CHC.ring_len = EBQ_CH_RINGLEN;

    DLC.b0 = EBQ_DL_B0; DLC.b1 = EBQ_DL_B1; DLC.b2 = EBQ_DL_B2;
    DLC.a1 = EBQ_DL_A1; DLC.a2 = EBQ_DL_A2;
    DLC.mixA = EBQ_DL_MIXA;
    DLC.svf_g = EBQ_DL_SVFG; DLC.svf_r = EBQ_DL_SVFR;
    DLC.mixB = EBQ_DL_MIXB;
    DLC.dry = EBQ_DL_DRY; DLC.wet = EBQ_DL_WET; DLC.fb = EBQ_DL_FB;
    DLC.on = EBQ_DL_ON;   DLC.mute = EBQ_DL_MUTE;
    DLC.lp_g = EBQ_DL_LPG; DLC.k624 = EBQ_DL_K624;
    DLC.lf_damp = EBQ_DL_LFD;
    DLC.hp_g = EBQ_DL_HPG; DLC.hf_damp = EBQ_DL_HFD;
    DLC.k688 = EBQ_DL_K688; DLC.dc_g = EBQ_DL_DCG;
    DLC.fade_k = EBQ_DL_FADEK;
    DLC.fade_up = EBQ_DL_FADEUP; DLC.fade_dn = EBQ_DL_FADEDN;
    DLC.slew = EBQ_DL_SLEW; DLC.time_target = EBQ_DL_TT;
    DLC.fade_gain = EBQ_DL_FADEG;

    RVC.send = EBQ_RV_SEND; RVC.gate = EBQ_RV_GATE;
    RVC.dry = EBQ_RV_DRY;   RVC.wet = EBQ_RV_WET;
    RVC.ap = EBQ_RV_AP;
    for (j = 0; j < 8; ++j) {
        uint32_t b = EBQ_RV_FIN[j];
        __builtin_memcpy(&RVC.f_in[j], &b, 4);
    }
    for (j = 0; j < 4; ++j) {
        int i;
        for (i = 0; i < 3; ++i) {
            uint32_t b = EBQ_RV_DAMP[j][i];
            __builtin_memcpy(&RVC.damp[j][i], &b, 4);
        }
    }
    RVC.lfo_inc = EBQ_RV_LFOINC; RVC.lfo_depth = EBQ_RV_LFODEPTH;

    eb_reverb_init(&RV);
    /* the warm state of a playing engine: working taps latched, mute 1.0,
     * wipe finished -- so the tank arm executes from sample 0 */
    eb_reverb_seed(&RV, EBQ_RV_TAPS, EBQ_RV_MUTE, 0);
    rv_wipe = 0;

    eb_noise_init(&NS);
}

/* one sample of the whole chain; `measure` 0 during warm-up */
static void run_sample(long i, int measure)
{
    float noise = 0.0f, mixL = 0.0f, mixR = 0.0f, oL, oR;
    int v;
    /* note gate: 4000 on / 2000 off so attack/decay/release/re-arm all run */
    float gate = ((i % 6000) < 4000) ? 1.0f : 0.0f;
    uint32_t ts = ccount();

    if (measure) MEAS(R_NOISE, noise = eb_noise_step(&NS));
    else noise = eb_noise_step(&NS);

    for (v = 0; v < NV; ++v) {
        vstate *s = &V[v];
        float e1 = 0, e2 = 0, pit = 0, pwm = 0, cut = 0;
        float o6704 = 0, o6848 = 0, dcoq[4], nsv04, nsvo = 0;
        float vcfo = 0, vcao = 0, decimo = 0, cv, pev = 0;
        eb_cvgate_in gi; eb_cvgate_out go;

        if (measure) {
            MEAS(R_ENV, e1 = eb_env_tick(&s->env[0], &EC[v][0], gate));
            MEAS(R_ENV, e2 = eb_env_tick(&s->env[1], &EC[v][1], gate));
        } else {
            e1 = eb_env_tick(&s->env[0], &EC[v][0], gate);
            e2 = eb_env_tick(&s->env[1], &EC[v][1], gate);
        }

        gi.t28 = 0.4f + 0.2f * lfrac();     /* dithered smoother targets */
        gi.t29 = 0.3f + 0.2f * lfrac();
        gi.k = 0.02f;
        gi.p28 = e1;   gi.p29 = e2;
        gi.gate_off = gate - 0.1f;          /* crosses the gate threshold */
        if (measure) MEAS(R_CVGATE, eb_cvgate(&gi, &go));
        else eb_cvgate(&gi, &go);

        if (measure) {
            MEAS(R_MODCV,
                 { eb_modcv_tick(&MC[v], go.c464, go.c480, 0.1f, 0.2f, e1, e2,
                                 &pit, &pwm);
                   g_acc += eb_modcv_tap(&s->mod);
                   eb_modcv_latch(&s->mod, pwm); });
        } else {
            eb_modcv_tick(&MC[v], go.c464, go.c480, 0.1f, 0.2f, e1, e2,
                          &pit, &pwm);
            g_acc += eb_modcv_tap(&s->mod);
            eb_modcv_latch(&s->mod, pwm);
        }

        /* pitch CV: per-voice spread across the table's rows plus dither;
         * 1 call in 64 is pushed out of range so both clamps execute */
        cv = pit + (-18.0f + 3.4f * (float)v) + (lfrac() - 0.5f);
        if ((lnext() & 63u) == 0u) cv += (lnext() & 1u) ? 40.0f : -40.0f;
        if (measure)
            MEAS(R_PITCH,
                 pev = eb_pitch_eval(cv, 1.0f));
        else
            pev = eb_pitch_eval(cv, 1.0f);
        rsink[R_PITCH] += pev;

        if (measure)
            MEAS(R_VCFCV,
                 cut = eb_vcf_cv_tick(&s->cv, &CD[v], pit, pwm, 0.1f, 0.2f,
                                      e1, e2, &o6704, &o6848));
        else
            cut = eb_vcf_cv_tick(&s->cv, &CD[v], pit, pwm, 0.1f, 0.2f,
                                 e1, e2, &o6704, &o6848);

        if (measure) MEAS(R_DCO, eb_dco_step4(&s->dco, &DC[v], dcoq));
        else eb_dco_step4(&s->dco, &DC[v], dcoq);

        if (measure)
            MEAS(R_DECIM, decimo = eb_decim_tick(&s->dec, &XC[v], 0.1f,
                                                 dcoq[0], dcoq[1], dcoq[2],
                                                 dcoq[3]));
        else
            decimo = eb_decim_tick(&s->dec, &XC[v], 0.1f, dcoq[0], dcoq[1],
                                   dcoq[2], dcoq[3]);

        if (measure) MEAS(R_NSVF, nsvo = eb_nsvf_tick(&s->nsv, &NC[v], noise,
                                                      &nsv04));
        else nsvo = eb_nsvf_tick(&s->nsv, &NC[v], noise, &nsv04);

        if (measure)
            MEAS(R_VCF, vcfo = eb_vcf_tick(&s->vcf, &FC[v],
                                           decimo + nsvo * 0.05f, cut, o6848));
        else
            vcfo = eb_vcf_tick(&s->vcf, &FC[v], decimo + nsvo * 0.05f,
                               cut, o6848);

        if (measure)
            MEAS(R_VCA, vcao = eb_vca_tick(&s->vca, &AC[v], vcfo, e1, e2,
                                           o6704, go.sign));
        else
            vcao = eb_vca_tick(&s->vca, &AC[v], vcfo, e1, e2, o6704, go.sign);

        mixL += vcao;
        mixR += vcao;
        rsink[R_ENV] += e1 + e2;
        rsink[R_CVGATE] += go.c464;
        rsink[R_MODCV] += pit + pwm;
        rsink[R_VCFCV] += cut;
        rsink[R_DCO] += dcoq[0];
        rsink[R_DECIM] += decimo;
        rsink[R_NSVF] += nsvo;
        rsink[R_VCF] += vcfo;
        rsink[R_VCA] += vcao;
    }
    rsink[R_NOISE] += noise;

    /* chorus input: MEASURED 12.0 x the voice sum (eb_chorus.h) */
    if (measure)
        MEAS(R_CHORUS, eb_chorus_tick_x(&CH, &CHC, 12.0f * mixL, &oL, &oR,
                                        0.0f, 0.0f));
    else
        eb_chorus_tick_x(&CH, &CHC, 12.0f * mixL, &oL, &oR, 0.0f, 0.0f);
    rsink[R_CHORUS] += oL;

    if (measure)
        MEAS(R_DELAY, eb_delay_process(&DLC, &DL, 0, oL, oR, &oL, &oR));
    else
        eb_delay_process(&DLC, &DL, 0, oL, oR, &oL, &oR);
    rsink[R_DELAY] += oL;

    if (measure)
        MEAS(R_REVERB, eb_reverb_process(&RVC, &RV, EBQ_RV_TAPS, &rv_wipe,
                                         oL, oR, &oL, &oR));
    else
        eb_reverb_process(&RVC, &RV, EBQ_RV_TAPS, &rv_wipe, oL, oR, &oL, &oR);
    rsink[R_REVERB] += oL;

    g_acc += mixL + oL + oR;

    if (measure) {
        uint32_t te = ccount();
        rtot[R_TOTAL] += (uint32_t)(te - ts);
        rcnt[R_TOTAL]++;
        /* two empty calibration spans per sample */
        MEAS(R_CAL, (void)0);
        MEAS(R_CAL, (void)0);
    }
}

static int finite_nonzero(float f)
{
    if (f != f) return 0;                       /* NaN  */
    if (f > 1e30f || f < -1e30f) return 0;      /* blow-up */
    return f != 0.0f;
}

#ifdef EB_IDF
int harness_main(void)
#else
int main(void)
#endif
{
    long i;
    int k, fail = 0;

    uart_puts("=EBQ START=\n");
    setup();

    for (i = 0; i < NWARM; ++i) run_sample(i, 0);
    for (i = 0; i < NSAMP; ++i) run_sample(NWARM + i, 1);

    uart_puts("NSAMP ");   uart_u64((uint64_t)NSAMP);
    uart_puts(" NVOICE "); uart_u64(NV);
    uart_puts(" DELAYLEN "); uart_u64(EB_DELAY_LEN);
    uart_puts("\n");
    uart_puts("SIZEOF reverb_state "); uart_u64(sizeof(eb_reverb_state));
    uart_puts(" delay_state ");        uart_u64(sizeof(eb_delay_state));
    uart_puts(" chorus_state ");       uart_u64(sizeof(eb_chorus_state));
    uart_puts(" vstate8 ");            uart_u64(sizeof V);
    uart_puts("\n");

    for (k = 0; k < R_N; ++k) {
        uart_puts("REGION ");
        uart_puts(rname[k]);
        uart_puts(" CALLS ");
        uart_u64(rcnt[k]);
        uart_puts(" TOT ");
        uart_u64(rtot[k]);
        uart_puts("\n");
    }

    /* non-silence proof, per region */
    for (k = 0; k < R_N; ++k) {
        uint32_t bits;
        float f = rsink[k];
        __builtin_memcpy(&bits, &f, 4);
        uart_puts("SINK ");
        uart_puts(rname[k]);
        uart_putc(' ');
        uart_hex32(bits);
        if (k <= R_REVERB && !finite_nonzero(f)) {
            uart_puts(" SANITY-FAIL");
            fail = 1;
        }
        uart_puts("\n");
    }
    {
        uint32_t bits; float f = g_acc;
        __builtin_memcpy(&bits, &f, 4);
        uart_puts("ACC "); uart_hex32(bits);
        if (!finite_nonzero(f)) { uart_puts(" SANITY-FAIL"); fail = 1; }
        uart_puts("\n");
    }
    /* teeth for the two silent-wet-path traps this harness was caught by:
     * an overrun tap reads unwritten zeros without any other symptom, and a
     * dead delay wet path makes delay output bit-identical to its input. */
    uart_puts("OVERRUN delay "); uart_u64((uint64_t)(uint32_t)DL.overrun);
    uart_puts(" reverb ");       uart_u64((uint64_t)(uint32_t)RV.overrun);
    if (DL.overrun || RV.overrun) { uart_puts(" SANITY-FAIL"); fail = 1; }
    uart_puts("\n");
    {
        uint32_t bc, bd;
        __builtin_memcpy(&bc, &rsink[R_CHORUS], 4);
        __builtin_memcpy(&bd, &rsink[R_DELAY], 4);
        if (bc == bd) {
            uart_puts("DELAY-WET-DEAD SANITY-FAIL\n");
            fail = 1;
        }
    }

    uart_puts(fail ? "=EBQ FAIL=\n" : "=EBQ DONE=\n");
    return fail;
}
