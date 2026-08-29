/* eb_master.c — see eb_master.h. The dispatch structure below is the port's,
 * read off src/master_render.c and not inferred from the arm numbering:
 *
 *   if (v39 == 1)          -> the TYPE 1 algorithm, complete           (:890)
 *   else if (v39 <= 1)     -> the shared core, i.e. TYPE 0            (:1055)
 *   else if (v39 <= 3)     -> the TYPE 2/3 algorithm                  (:1271)
 *   else if (v39 == 5)     -> the TYPE 5 algorithm                    (:1459)
 *   else if (v39 == 4)     -> the TYPE 4 algorithm  (NOT TRANSCRIBED) (:1870)
 *   else (v39 >= 6)        -> the shared core again, via goto LABEL_69
 *
 * TYPE 1 DOES NOT FALL THROUGH INTO THE CORE. :1049-1050 is `}` followed by
 * `else`. An earlier reading of this project's had types 0, 1 and >= 6 sharing
 * the core, which would have made the type-1 arm's outputs dead; they are not.
 *
 * The EFFECT dispatch has the same shape around v551:
 *   == 1 -> the e1 arm (:2381) | <= 1 -> LABEL_164 (NOT TRANSCRIBED, :2503)
 *   == 5 -> the e5 arm (:2633) | >= 6 -> LABEL_164 | else (2,3,4) -> chorus
 */
#include "eb_master.h"
#include "eb_ring_probe.h"

#if EB_RING_PROBE
/* THE PROBE'S STORAGE. One definition, in the one module that owns the rings.
 * Not built by any gate: tools/verify and tools/engineb never define
 * EB_RING_PROBE, so the shipping object has neither the counters nor the
 * compare. */
#include <stdio.h>
int eb_rp_maxlag[EB_RP_N];
int eb_rp_len[EB_RP_N];


/* A FILE, not stderr, for the reason eb_vcf_ladder.c records: the null
 * harness runs its scenarios in worker subprocesses whose stderr is captured
 * and discarded, so a stderr report would print nothing and read as "no ring
 * was ever used". */
static void eb_rp_report(void) __attribute__((destructor));
static void eb_rp_report(void)
{
    static const char *N[EB_RP_N] = { "t1", "t23", "t5_0", "t5_1", "t5_2",
                                      "t5_3", "e5", "t4_0", "t4_1" };
    FILE *f; int i;
    for (i = 0; i < EB_RP_N; ++i) if (eb_rp_len[i]) break;
    if (i == EB_RP_N) return;
    f = fopen("/tmp/eb_ring.log", "a");
    if (!f) return;
    for (i = 0; i < EB_RP_N; ++i)
        if (eb_rp_len[i])
            fprintf(f, "%s maxlag=%d len=%d\n", N[i], eb_rp_maxlag[i],
                    eb_rp_len[i]);
    fclose(f);
}
#endif

/* ================= O4: THE MASTER-CHAIN STAGE PROFILER =================
 *
 * WHY. b6 and b15 both put the whole remaining deadline deficit in ONE place:
 * core 1's FX pass. b15's run measured `FXP: fx` swinging 2,432 -> 4,374
 * cyc/sample across patches while `v1` sat flat at ~2,600 and `wait=5`. So the
 * variance -- about 1,900 cyc/sample, against a total deficit of 259 -- is
 * entirely inside eb_master_render, and closing it would close O4 outright.
 *
 * ⚠ AND THE OBVIOUS CULPRIT WAS ALREADY RULED OUT. The delay rings look like
 * the answer, and b4_second_run attributed it to PSRAM latency -- an
 * attribution b6 WITHDREW: the moving-tap probe reads 29.8 cyc/tap against the
 * scattered probe's 228.8, and a delay tap walks the ring nearly sequentially.
 * A ring-placement test then moved four of nine rings into internal SRAM and
 * the engine got 94 cycles WORSE. So "it is the rings" has been asserted,
 * measured, and refuted, and the honest state is that NOBODY KNOWS which stage
 * costs the 1,900.
 *
 * This answers it by construction rather than by argument: five stages, five
 * counters, one per sample. The next board run names the stage.
 *
 * ⚠ OFF BY DEFAULT AND FREE WHEN OFF. Every macro below compiles to nothing
 * unless EB_MSPROF is 1, so the shipping build is byte-identical and the trunk
 * stays bit-exact. It reads the cycle counter, which is why it may never be
 * left on in a build whose block timings are quoted: six reads per sample is
 * itself a cost, and a profiler that changes what it measures is a defect
 * (this file's own FXPROF tooth exists for that reason).
 */
#ifndef EB_MSPROF
#define EB_MSPROF 0
#endif
#if EB_MSPROF
/* ⚠ THE CLOCK IS A PORT DETAIL, AND MAKING IT ONE IS WHAT LETS THE GATE RUN
 * WITH THE PROFILER ON. The first version called xthal_get_ccount() directly,
 * which is Xtensa-only -- so `make engineb` could only ever prove the OFF
 * path, and the build actually flashed would have been the UNGATED one. That
 * is the wrong way round: the configuration that ships is the configuration
 * that must be proven.
 *
 * The device uses its cycle counter; the host falls back to a plain counter,
 * which is useless as a TIME but exercises every line of the accumulation, so
 * the trunk gate can assert the null is still EXACTLY 0 with the profiler
 * compiled in.
 *
 * ⚠ THE CHOICE IS MADE HERE, IN THIS TRANSLATION UNIT, AND THAT IS THE WHOLE
 * POINT. The first device build put `#define EB_MSPROF_TICK() ...` in
 * juno_s3_listen.c. A macro cannot cross a translation unit. eb_master.c never
 * saw it, fell back to the counter below, and every stage read EXACTLY 1
 * cyc/sample for 52 minutes on the board -- the signature of a counter that
 * steps by one. The instrument did not measure its subject. Select the clock
 * from the TARGET, never from a caller. */
#ifndef EB_MSPROF_TICK
#if defined(__XTENSA__)
/* CCOUNT read inline, with NO <xtensa/hal.h>. The header lives in an ESP-IDF
 * component, and pulling IDF into an engine_b file would make the trunk depend
 * on the device tree. One special register, one instruction. */
static unsigned long eb_msprof_ccount(void)
{ unsigned long c; __asm__ __volatile__("rsr.ccount %0" : "=a"(c)); return c; }
#define EB_MSPROF_TICK() eb_msprof_ccount()
#else
static unsigned long eb_msprof_fake;
#define EB_MSPROF_TICK() (++eb_msprof_fake)
#endif
#endif
unsigned long long eb_msprof[5];      /* in, delay, reverb, out, effect */
unsigned long      eb_msprof_n;
#define MSP_T0()   unsigned long _p = (unsigned long)EB_MSPROF_TICK(), _q
#define MSP_HIT(k) do { _q = (unsigned long)EB_MSPROF_TICK();                 \
                        eb_msprof[k] += (unsigned long long)(_q - _p);        \
                        _p = _q; } while (0)
#define MSP_END()  (++eb_msprof_n)
#else
#define MSP_T0()   do { } while (0)
#define MSP_HIT(k) do { } while (0)
#define MSP_END()  do { } while (0)
#endif

#include <string.h>

/* EB_FXPROBE_DLY_HALF / EB_FXPROBE_REV_HALF -- HALF-RATE PRICE PROBES ONLY.
 *
 * WHAT THEY DO: on every second sample, skip the delay stage (or the reverb
 * stage) entirely and HOLD the previous output. This deliberately produces
 * WRONG audio -- echo times double, tails stutter -- and must NEVER ship or
 * reach a listening test presented as real.
 *
 * WHY THEY EXIST (b33): the half-rate FX lever needs its CYCLE price measured
 * on silicon BEFORE the real version (internal time constants rebuilt for
 * 22,050 Hz) is designed. Playbook 11b: measure first; the decision rule is
 * written before the flash. The MSPP per-stage lines price each stage
 * SEPARATELY: with a probe on, that stage's cyc/sample must drop ~45-50%.
 * If it does not, the stage's cost is not where the arithmetic says, and the
 * lever dies cheaply.
 *
 * Both default 0; the trunk object is byte-identical with them off. */
#ifndef EB_FXPROBE_DLY_HALF
#define EB_FXPROBE_DLY_HALF 0
#endif
#ifndef EB_FXPROBE_REV_HALF
#define EB_FXPROBE_REV_HALF 0
#endif

/* ---- THE FRONT/BACK SPLIT (REV-PIPE) --------------------------------------
 *
 * The per-sample chain is in -> delay -> reverb -> out -> effect, but the
 * FEEDBACK pair fb84672/fb84704 is written ONLY by the effect stage and the
 * reverb+out pair reads NOTHING the effect stage writes (reverb consumes
 * v176/v177 from the delay; out consumes the reverb). So the loop b22 priced
 * as unsplittable is in -> delay -> effect; reverb+out is a FEED-FORWARD TAIL.
 *
 * eb_master_render_front runs the loop (in, delay, effect); it emits the
 * delay's v176/v177. eb_master_render_back runs the tail (reverb, out) on
 * them. Composed front-then-back in one call they compute the SAME floats as
 * the old monolith -- the effect stage's inputs (v32, v56, v58) and the
 * reverb's (v176, v177) are all produced before either runs, and their state
 * is disjoint -- and the trunk null gate re-proves that, it is not assumed.
 * Composed a CHUNK apart on two cores, the output is the identical bit
 * stream one chunk later: pure latency, the S3L_FX_PIPE class, no sonic
 * change. */

#if EB_FXPROBE_DLY_HALF || EB_FXPROBE_REV_HALF
static unsigned fxprobe_ph;
static float hold_v176, hold_v177, hold_v56, hold_v58;
static float hold_v529, hold_v530;
#endif

int eb_master_render_front(eb_master_state *s, const eb_master_coef *c,
                           const eb_master_rings *r, const float *voices,
                           float *o176, float *o177)
{
#if EB_FXPROBE_DLY_HALF || EB_FXPROBE_REV_HALF
    fxprobe_ph++;
#endif
    float v36, v38, v32, v176, v177, v56, v58, v593;
    float dL, dR;

    MSP_T0();

    /* No refusals left: task 1b-3 gave DELAY TYPE 4 and the EFFECT LABEL_164
     * core their modules, so every value either dispatch can take is covered. */

    /* ---- 1. the input stage. The feedback pair is LAST sample's. -------- */
    eb_master_in_tick(&s->in, &c->in, voices, s->fb84672, s->fb84704,
                      &v36, &v38, &v32);

    MSP_HIT(0);
    /* ---- 2. the DELAY dispatch ------------------------------------------ */
    v56 = 0.0f;
    v58 = -1.0f;
#if EB_FXPROBE_DLY_HALF
    /* PRICE PROBE: odd samples reuse the held delay output. WRONG AUDIO. */
    if (fxprobe_ph & 1u) {
        v176 = hold_v176; v177 = hold_v177;
        v56 = hold_v56;   v58 = hold_v58;
    } else
#endif
    if (c->delay_type == 1) {
        s->d1.ring = r->t1;
        eb_dly1_tick(&s->d1, &c->d1, v36, v38, c->in.k84496,
                     &v176, &v177, &v56, &v58);
    } else if (c->delay_type <= 1 || c->delay_type >= 6) {
        /* the shared core, which the port reaches for TYPE 0 and, through
         * `goto LABEL_69`, for anything >= 6. It sets v56/v58 to the constants
         * initialised above -- the port's :1177 and :1182. */
        /* ★ THE CORE'S OUTPUTS ARE CROSSED AND GAINED, and they are the only
         * delay path where that happens outside the module. The port:
         *     cell102320 = ebL;  cell102336 = ebR;
         *     v176 = v418 * cell102336;   <- v176 takes the RIGHT output
         *     v177 = v418 * cell102320;   <- v177 takes the LEFT
         * Passing the core's outputs straight through, as the first version
         * did, swaps the stereo image: MEASURED, the standalone gate showed
         * portL == ebR and portR == ebL exactly, on every sample of every
         * DELAY-TYPE-0 scenario. The four arm modules each end with this same
         * multiply internally, which is why only the core needs it here. */
        eb_delay_process(&c->dcore, &s->dcore, s->route_change, v36, v38,
                         &dL, &dR);
        s->route_change = 0;
        v176 = c->k101744 * dR;
        v177 = c->k101744 * dL;
    } else if (c->delay_type <= 3) {
        s->d23.ring = r->t23;
        eb_dly23_tick(&s->d23, &c->d23, v36, v38, c->in.k84496,
                      &v176, &v177, &v56, &v58);
    } else if (c->delay_type == 4) {
        s->d4.ring0 = r->t4_0; s->d4.ring1 = r->t4_1;
        eb_dly_t4_tick(&s->d4, &c->d4, v36, v38, c->in.k84496,
                       &v176, &v177, &v56, &v58);
    } else {                                        /* delay_type == 5 */
        s->d5.ring0 = r->t5_0; s->d5.ring1 = r->t5_1;
        s->d5.ring2 = r->t5_2; s->d5.ring3 = r->t5_3;
        eb_dly5_tick(&s->d5, &c->d5, v36, v38, c->in.k84496,
                     &v176, &v177, &v56, &v58);
    }

#if EB_FXPROBE_DLY_HALF
    hold_v176 = v176; hold_v177 = v177; hold_v56 = v56; hold_v58 = v58;
#endif
    MSP_HIT(1);
    /* ---- 5. the EFFECT dispatch, which feeds the NEXT sample ------------ */
    if (c->effect_type == 0 || c->effect_type >= 6) {
        /* the LABEL_164 core */
        eb_fx_e0_tick(&s->e0, &c->e0, v32, v56, v58, &v56, &v58, &v593);
        s->fb84672 = s->e0.s84672;
    } else if (c->effect_type == 1) {
        eb_fx_e1_tick(&s->e1, &c->e1, v32, v56, v58, &v56, &v58, &v593);
        s->fb84672 = s->e1.s84672;
    } else if (c->effect_type == 5) {
        s->e5.ring = r->e5;
        eb_fx_e5_tick(&s->e5, &c->e5, v32, v56, v58, &v56, &v58, &v593);
        s->fb84672 = s->e5.s84672;
        /* v56/v58 go IN as well as out: the port assigns them only on one
         * branch of this arm, so on the other branch they keep what the DELAY
         * stage left. See eb_fx_e1.h. */
    } else {                                        /* 2, 3, 4 -> chorus */
        float chL, chR;
        eb_chorus_tick_x(&s->cho, &c->cho, v32, &chL, &chR, v56, v58);
        /* the port's :2936-2937: 84672 takes the LEFT output and v593 the
         * RIGHT one. They are not interchangeable -- 84672 feeds the input
         * stage's v29 and 84704 its v19, which are different coefficients. */
        s->fb84672 = chL;
        v593 = chR;
    }
    s->fb84704 = v593;                              /* the port's LABEL_205 */
    MSP_HIT(4);
    *o176 = v176;
    *o177 = v177;
    return EB_MASTER_OK;
}

int eb_master_render_back(eb_master_state *s, const eb_master_coef *c,
                          float v176, float v177, float *outL, float *outR)
{
    float v529, v530;

    MSP_T0();
    *outL = 0.0f;
    *outR = 0.0f;

    /* ---- 3. the reverb. It CROSSES its channels; see eb_reverb.h. ------- */
#if EB_FXPROBE_REV_HALF
    /* PRICE PROBE: odd samples reuse the held reverb output. WRONG AUDIO. */
    if (fxprobe_ph & 1u) {
        v529 = hold_v529; v530 = hold_v530;
    } else
#endif
#if EB_REVERB_HALF
    /* THE REAL HALF-RATE REVERB: tank clocked at half rate, depths halved,
     * coefficients rescaled, input decimated 2:1, output interpolated 1:2. A
     * SONIC TRADE (not bit-exact); the cfg was passed through
     * eb_reverb_halfrate_cfg at seed time. */
    eb_reverb_process_half(&c->rev, &s->rev, s->rev_pending, &s->rev_wipe,
                           v176, v177, &v529, &v530);
#else
    eb_reverb_process(&c->rev, &s->rev, s->rev_pending, &s->rev_wipe,
                      v176, v177, &v529, &v530);
#endif
#if EB_FXPROBE_REV_HALF
    hold_v529 = v529; hold_v530 = v530;
#endif

    MSP_HIT(2);
    /* ---- 4. the output stage. THE SAMPLE IS FINISHED HERE. -------------- */
    {
        /* cells 101264/101280 are the port's pre-doubling pair; the module
         * reports them and the already-doubled output separately. Nothing in
         * engine B reads the cells, so they are discarded here rather than
         * stored -- and named, so the discard is visible. */
        float cell101264, cell101280;
        eb_master_out_tick(&c->out, v529, v530,
                           &cell101264, &cell101280, outL, outR);
        (void)cell101264; (void)cell101280;
    }

    MSP_HIT(3);
    MSP_END();
    return EB_MASTER_OK;
}

int eb_master_render(eb_master_state *s, const eb_master_coef *c,
                     const eb_master_rings *r, const float *voices,
                     float *outL, float *outR)
{
    float v176, v177;
    (void)eb_master_render_front(s, c, r, voices, &v176, &v177);
    return eb_master_render_back(s, c, v176, v177, outL, outR);
}
