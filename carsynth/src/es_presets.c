/* es_presets.c -- engine definitions transcribed from engine-sim's .mr
 * scripts (assets/engines, MIT, Ange Yaghi) and the es/ library defaults
 * they rely on. Every number cites its script. Units as es/constants/units.mr. */
#include "es_presets.h"
#include "es_math.h"
#include <string.h>

#define INCH   0.0254
#define THOU   (INCH / 1000.0)
#define MM     0.001
#define CM     0.01
#define CC     1e-6
#define LITRE  1e-3
#define CM2    1e-4
#define DEG    (ES_PI / 180)
#define RPM    0.104719755

/* es/objects/objects.mr fuel() defaults */
static void fuel_defaults(es_fuel *f)
{
    f->molecular_mass = 0.100;              /* 100 g */
    f->energy_density = 48.1e3 / 1e-3;      /* 48.1 kJ/g -> J/kg */
    f->molecular_afr = 25 / 2.0;
    f->max_efficiency = 0.8;
    f->randomness = 0.5;
    f->low_eff_att = 0.6;
    f->max_turb = 2.0;
    f->max_dilution = 10.0;
}
/* objects.mr turbulence_to_flame_speed_ratio_default: (0,3), (5k, 1.5*5k) */
static int flame_default(es_engine *e)
{
    int f = es_engine_func(e, 5.0), k;
    es_func_add(&e->funcs[f], 0.0, 3.0);
    for (k = 1; k <= 9; ++k) es_func_add(&e->funcs[f], 5.0 * k, 1.5 * 5.0 * k);
    return f;
}
/* engine_node.h meanPistonSpeedToTurbulence: s -> 0.5 s, s = 0..29, radius 1 */
static int turbulence_func(es_engine *e)
{
    int f = es_engine_func(e, 1.0), i;
    for (i = 0; i < 30; ++i) es_func_add(&e->funcs[f], (double)i, i * 0.5);
    return f;
}
/* heads.mr add_flow_sample: lift in thou, flow in CFM @ 28 inH2O */
static int flow_func(es_engine *e, const double *lift, const double *cfm, int n)
{
    int f = es_engine_func(e, 50 * THOU), i;
    for (i = 0; i < n; ++i) es_func_add(&e->funcs[f], lift[i] * THOU, es_k_28inH2O(cfm[i]));
    return f;
}
static int timing_func(es_engine *e, const double *rpm, const double *deg, int n, double radius_rpm)
{
    int f = es_engine_func(e, radius_rpm * RPM), i;
    for (i = 0; i < n; ++i) es_func_add(&e->funcs[f], rpm[i] * RPM, deg[i] * DEG);
    return f;
}

/* ---------------------------------------------------------------- GM LS V8
 * assets/engines/atg-video-2/07_gm_ls.mr */
static void preset_gm_ls(es_engine *e)
{
    static const double lift[10] = {0, 50, 100, 150, 200, 250, 300, 350, 400, 450};
    static const double in_cfm[10] = {0, 1, 103, 156, 214, 249, 268, 280, 280, 281};
    static const double ex_cfm[10] = {0, 1, 72, 113, 160, 196, 222, 235, 245, 246};
    static const double t_rpm[9] = {0, 1000, 2000, 3000, 4000, 5000, 6000, 7000, 8000};
    static const double t_deg[9] = {12, 12, 20, 30, 40, 40, 40, 40, 40};
    /* camshaft lobes, crank-angle multiples of 90 deg, per bank (script order) */
    static const int ex0[4] = {0, 7, 5, 2}, ex1[4] = {3, 6, 4, 1};
    /* firing: wire -> angle (x 90 deg); global cylinder order b0 c0..3, b1 c0..3
     * wires b0: 1,3,5,7  b1: 2,4,6,8; connect_wire 1:0 8:1 7:2 2:3 6:4 5:5 4:6 3:7 */
    static const double plug90[8] = {0, 7, 5, 2, 3, 6, 4, 1};
    static const double jr[4] = {0, 270, 90, 180};
    static const double prim0[4] = {3 * 2 * INCH + 2 * CM, 2 * 2 * INCH + 1 * CM, 1 * 2 * INCH + 3 * CM, 5 * CM};
    static const double prim1[4] = {3 * 2 * INCH + 1 * CM, 2 * 2 * INCH + 5 * CM, 1 * 2 * INCH + 7 * CM, 0};
    const double stroke = 3.622 * INCH, bore = 3.78 * INCH, rod = 160 * MM, comp = 1.0 * INCH;
    const double v_angle = 90 * DEG;
    int b, i, lobe_in, lobe_ex, fin, fex;

    e->name = "GM LS V8";
    e->n_cyl = 8; e->n_bank = 2; e->n_exh = 2; e->n_intake = 1; e->n_cam = 4;
    e->redline_rpm = 6500; e->rev_limit = 6800 * RPM; e->limiter_duration = 0.2;
    e->throttle_gamma = 2.0;
    e->sim_freq = 10000; e->hf_gain = 0.01; e->noise = 1.0; e->jitter = 0.6;
    e->throw_ = stroke / 2; e->tdc = 90 * DEG - (v_angle / 2.0);
    e->ir = 0; e->idle_rpm = 750;
    fuel_defaults(&e->fuel);
    e->fuel.max_efficiency = 1.0;
    {   /* custom turbulence_to_flame_speed_ratio */
        int f = es_engine_func(e, 5.0), k;
        es_func_add(&e->funcs[f], 0.0, 3.0);
        es_func_add(&e->funcs[f], 5.0, 1.5 * 5.0);
        es_func_add(&e->funcs[f], 10.0, 1.75 * 10.0);
        for (k = 3; k <= 9; ++k) es_func_add(&e->funcs[f], 5.0 * k, 2.0 * 5.0 * k);
        e->fuel.flame_func = f;
    }
    e->turbulence_func = turbulence_func(e);
    e->timing_func = timing_func(e, t_rpm, t_deg, 9, 1000);
    fin = flow_func(e, lift, in_cfm, 10);
    fex = flow_func(e, lift, ex_cfm, 10);
    lobe_in = es_engine_func(e, 1.0);
    es_func_harmonic_cam_lobe(&e->funcs[lobe_in], 234 * DEG, 1.1, 551 * THOU, 256);
    lobe_ex = es_engine_func(e, 1.0);
    es_func_harmonic_cam_lobe(&e->funcs[lobe_ex], 235 * DEG, 1.1, 551 * THOU, 256);

    /* intake intake(...) */
    e->intake[0].plenum_volume = 1.325 * LITRE;
    e->intake[0].plenum_area = 20.0 * CM2;
    e->intake[0].input_k = es_k_carb(700.0);
    e->intake[0].runner_k = es_k_carb(100.0);
    e->intake[0].runner_length = 12.0 * INCH;
    e->intake[0].idle_k = es_k_carb(0.0);
    e->intake[0].idle_plate = 0.996;
    e->intake[0].velocity_decay = 0.5;
    e->intake[0].molecular_afr = 25.0 / 2.0;
    /* exhaust_system_parameters es_params + exhaust0/1 */
    for (i = 0; i < 2; ++i) {
        es_exhaust *x = &e->exh[i];
        x->outlet_k = es_k_carb(1000.0);
        x->primary_tube_length = 29.0 * INCH;
        x->primary_k = es_k_carb(500.0);
        x->velocity_decay = 1.0;
        x->collector_area = ES_PI * (2.0 * INCH) * (2.0 * INCH);   /* circle_area(2 in) */
        x->audio_volume = 4.0;
        x->length = (i == 0 ? 100 : 172) * INCH;
    }
    /* camshafts: 0 = intake bank0, 1 = exhaust bank0, 2 = intake bank1, 3 = exhaust bank1 */
    for (b = 0; b < 2; ++b) {
        es_cam *ci = &e->cam[b * 2 + 0], *cx = &e->cam[b * 2 + 1];
        const int *ex = b ? ex1 : ex0;
        ci->lobe_profile = lobe_in; cx->lobe_profile = lobe_ex;
        ci->advance = cx->advance = 0;
        for (i = 0; i < 4; ++i) {
            cx->lobe_angle[i] = ((360 * DEG) - 116 * DEG + ex[i] * 90 * DEG) / 2;
            ci->lobe_angle[i] = ((360 * DEG) + 116 * DEG + ex[i] * 90 * DEG) / 2;
        }
    }
    for (b = 0; b < 2; ++b) {
        es_bank *k = &e->bank[b];
        k->bore = bore;
        k->deck_height = stroke / 2 + rod + comp;
        k->angle = b ? v_angle / 2.0 : -v_angle / 2.0;
        k->chamber_volume = 90 * CC;
        k->in_runner_vol = 149.6 * CC;
        k->in_runner_area = 2.2 * INCH * 2.2 * INCH;
        k->ex_runner_vol = 50.0 * CC;
        k->ex_runner_area = 1.75 * INCH * 1.75 * INCH;
        k->in_flow = fin; k->ex_flow = fex;
        k->cam_in = b * 2 + 0; k->cam_ex = b * 2 + 1;
    }
    for (i = 0; i < 8; ++i) {
        es_cyl *c = &e->cyl[i];
        b = i / 4;
        c->bank = b; c->lobe = i % 4; c->intake = 0; c->exhaust = b;
        c->journal_angle = jr[i % 4] * DEG;
        c->rod_length = rod; c->compression_height = comp;
        c->sound_att = 1.0;
        c->primary_length = b ? prim1[i % 4] : prim0[i % 4];
        c->plug_angle = plug90[i] * 90 * DEG;
        c->blowby_k = es_k_28inH2O(0.0);
    }
}

/* ---------------------------------------------------------------- Toyota 2JZ I6
 * assets/engines/atg-video-2/03_2jz.mr */
static void preset_2jz(es_engine *e)
{
    static const double lift[10] = {0, 50, 100, 150, 200, 250, 300, 350, 400, 450};
    static const double in_cfm[10] = {0, 58, 103, 156, 214, 249, 268, 280, 280, 281};
    static const double ex_cfm[10] = {0, 37, 72, 113, 160, 196, 222, 235, 245, 246};
    static const double t_rpm[8] = {0, 1000, 2000, 3000, 4000, 5000, 6000, 7000};
    static const double t_deg[8] = {12, 12, 20, 26, 30, 34, 38, 38};
    static const int lobe_k[6] = {0, 4, 2, 5, 1, 3};                 /* x 120 deg */
    static const double jr[6] = {0, 480, 240, 600, 120, 360};
    /* cylinder i uses wire i+1; wires 1,5,3,6,2,4 fire at k/6 cycle */
    static const double plug[6] = {0, 480, 240, 600, 120, 360};
    static const double prim[6] = {5, 4, 3, 3, 4, 5};                /* x 0.5 in */
    static const double att[6] = {0.9, 0.95, 0.9, 0.97, 0.98, 0.93};
    static const double bb[6] = {0.1, 0.05, 0.1, 0.05, 0.1, 0.05};
    const double stroke = 86.0 * MM, bore = 86.0 * MM, rod = 142 * MM, comp = 32.8 * MM;
    double in_a[10], ex_a[10];
    int i, lobe_in, lobe_ex, fin, fex;

    e->name = "Toyota 2JZ I6";
    e->n_cyl = 6; e->n_bank = 1; e->n_exh = 2; e->n_intake = 1; e->n_cam = 2;
    e->redline_rpm = 6000; e->rev_limit = 6500 * RPM; e->limiter_duration = 0.1;
    e->throttle_gamma = 1.0;                       /* engine() default */
    e->sim_freq = 10000; e->hf_gain = 0.01; e->noise = 1.0; e->jitter = 0.23;
    e->throw_ = stroke / 2; e->tdc = ES_PI / 2;
    e->ir = 2;                                     /* ir_lib.mild_exhaust_0_reverb */
    e->idle_rpm = 800;
    fuel_defaults(&e->fuel);
    e->fuel.max_efficiency = 1.0;
    e->fuel.flame_func = flame_default(e);
    e->turbulence_func = turbulence_func(e);
    e->timing_func = timing_func(e, t_rpm, t_deg, 8, 1000);
    for (i = 0; i < 10; ++i) { in_a[i] = in_cfm[i] * 0.9; ex_a[i] = ex_cfm[i] * 0.9; } /* flow_attenuation 0.9 */
    fin = flow_func(e, lift, in_a, 10);
    fex = flow_func(e, lift, ex_a, 10);
    lobe_in = es_engine_func(e, 1.0);
    es_func_harmonic_cam_lobe(&e->funcs[lobe_in], 220 * DEG, 1.1, 9.78 * MM, 100);
    lobe_ex = es_engine_func(e, 1.0);
    es_func_harmonic_cam_lobe(&e->funcs[lobe_ex], 220 * DEG, 1.1, 9.60 * MM, 100);

    e->intake[0].plenum_volume = 1.0 * LITRE;
    e->intake[0].plenum_area = 10.0 * CM2;
    e->intake[0].input_k = es_k_carb(500.0);
    e->intake[0].runner_k = es_k_carb(200.0);
    e->intake[0].runner_length = 40.0 * INCH;
    e->intake[0].idle_k = es_k_carb(0.0);
    e->intake[0].idle_plate = 0.9965;
    e->intake[0].velocity_decay = 0.25;            /* intake_parameters default */
    e->intake[0].molecular_afr = 25.0 / 2.0;
    for (i = 0; i < 2; ++i) {
        es_exhaust *x = &e->exh[i];
        x->outlet_k = es_k_carb(1000.0);
        x->primary_tube_length = 40.0 * INCH;
        x->primary_k = es_k_carb(400.0);
        x->velocity_decay = 1.0;
        x->collector_area = ES_PI * (2.0 * INCH) * (2.0 * INCH);
        x->audio_volume = 0.2;
        x->length = 100.0 * INCH;
    }
    e->cam[0].lobe_profile = lobe_in; e->cam[1].lobe_profile = lobe_ex;
    e->cam[0].advance = e->cam[1].advance = 0;
    for (i = 0; i < 6; ++i) {
        e->cam[1].lobe_angle[i] = ((360 * DEG - 116 * DEG) + lobe_k[i] * 120 * DEG) / 2;
        e->cam[0].lobe_angle[i] = ((360 * DEG) + 116 * DEG + lobe_k[i] * 120 * DEG) / 2;
    }
    e->bank[0].bore = bore;
    e->bank[0].deck_height = stroke / 2 + rod + comp;
    e->bank[0].angle = 0;
    e->bank[0].chamber_volume = 50 * CC;
    e->bank[0].in_runner_vol = 149.6 * CC;
    e->bank[0].in_runner_area = 1.9 * INCH * 1.9 * INCH;
    e->bank[0].ex_runner_vol = 50.0 * CC;
    e->bank[0].ex_runner_area = 1.25 * INCH * 1.25 * INCH;
    e->bank[0].in_flow = fin; e->bank[0].ex_flow = fex;
    e->bank[0].cam_in = 0; e->bank[0].cam_ex = 1;
    for (i = 0; i < 6; ++i) {
        es_cyl *c = &e->cyl[i];
        c->bank = 0; c->lobe = i; c->intake = 0; c->exhaust = i < 3 ? 0 : 1;
        c->journal_angle = jr[i] * DEG;
        c->rod_length = rod; c->compression_height = comp;
        c->sound_att = att[i];
        c->primary_length = prim[i] * 0.5 * INCH;
        c->plug_angle = plug[i] * DEG;
        c->blowby_k = es_k_28inH2O(bb[i]);
    }
}

/* ---------------------------------------------------------------- Subaru EJ25 H4
 * assets/engines/atg-video-2/01_subaru_ej25_eh.mr */
static void preset_ej25(es_engine *e)
{
    static const double lift[10] = {0, 50, 100, 150, 200, 250, 300, 350, 400, 450};
    static const double in_cfm[10] = {0, 58, 103, 156, 214, 249, 268, 280, 280, 281};
    static const double ex_cfm[10] = {0, 37, 72, 113, 160, 196, 222, 235, 245, 246};
    static const double t_rpm[5] = {0, 1000, 2000, 3000, 4000};
    static const double t_deg[5] = {25, 25, 30, 40, 40};
    /* global cylinders: b0c0 (rj0, wire1), b0c1 (rj3, wire3), b1c0 (rj1, wire2), b1c1 (rj2, wire4)
     * wires 1,3,2,4 fire at 0, 1/4, 2/4, 3/4 cycle */
    static const double jr[4] = {0, 180, 180, 0};
    static const double plug[4] = {0, 180, 360, 540};
    static const double prim[4] = {2.0, 3.0, 3.0, 5.0};             /* inch */
    static const double att[4] = {0.9, 1.0, 1.1, 0.9};
    static const double bb[4] = {0.001, 0.002, 0.001, 0.002};
    const double stroke = 79 * MM, bore = 99.5 * MM, rod = 5.142 * INCH, comp = 1.0 * INCH;
    int b, i, lobe_in, lobe_ex, fin, fex;

    e->name = "Subaru EJ25 H4";
    e->n_cyl = 4; e->n_bank = 2; e->n_exh = 1; e->n_intake = 1; e->n_cam = 4;
    e->redline_rpm = 6500; e->rev_limit = 6800 * RPM; e->limiter_duration = 0.16;
    e->throttle_gamma = 2.0;
    e->sim_freq = 20000; e->hf_gain = 0.01; e->noise = 1.0; e->jitter = 0.5;
    e->throw_ = stroke / 2; e->tdc = 180 * DEG;
    e->ir = 4;                                     /* ir_lib.minimal_muffling_02 */
    e->idle_rpm = 800;
    fuel_defaults(&e->fuel);
    e->fuel.max_efficiency = 0.9;
    {
        static const double m[10] = {1.0, 1.0, 1.0, 1.1, 1.25, 1.25, 1.25, 1.25, 1.25, 1.25};
        int f = es_engine_func(e, 5.0), k;
        es_func_add(&e->funcs[f], 0.0, 1.0 * 3.0);
        for (k = 1; k <= 9; ++k) es_func_add(&e->funcs[f], 5.0 * k, m[k] * 1.5 * 5.0 * k);
        e->fuel.flame_func = f;
    }
    e->turbulence_func = turbulence_func(e);
    e->timing_func = timing_func(e, t_rpm, t_deg, 5, 1000);
    fin = flow_func(e, lift, in_cfm, 10);
    fex = flow_func(e, lift, ex_cfm, 10);
    lobe_in = es_engine_func(e, 1.0);
    es_func_harmonic_cam_lobe(&e->funcs[lobe_in], 232 * DEG, 2.0, 9.78 * MM, 100);
    lobe_ex = es_engine_func(e, 1.0);
    es_func_harmonic_cam_lobe(&e->funcs[lobe_ex], 236 * DEG, 2.0, 9.60 * MM, 100);

    e->intake[0].plenum_volume = 1.325 * LITRE;
    e->intake[0].plenum_area = 20.0 * CM2;
    e->intake[0].input_k = es_k_carb(400.0);
    e->intake[0].runner_k = es_k_carb(100.0);
    e->intake[0].runner_length = 12.0 * INCH;
    e->intake[0].idle_k = es_k_carb(0.0);
    e->intake[0].idle_plate = 0.9978;
    e->intake[0].velocity_decay = 1.0;
    e->intake[0].molecular_afr = 25.0 / 2.0;
    e->exh[0].outlet_k = es_k_carb(1000.0);
    e->exh[0].primary_tube_length = 40.0 * INCH;
    e->exh[0].primary_k = es_k_carb(400.0);
    e->exh[0].velocity_decay = 1.0;
    e->exh[0].collector_area = ES_PI * (2.0 * INCH) * (2.0 * INCH);
    e->exh[0].audio_volume = 0.5 * 0.02;
    e->exh[0].length = 500 * MM;
    for (b = 0; b < 2; ++b) {                      /* cam 2b = intake, 2b+1 = exhaust */
        es_cam *ci = &e->cam[b * 2], *cx = &e->cam[b * 2 + 1];
        ci->lobe_profile = lobe_in; cx->lobe_profile = lobe_ex;
        ci->advance = cx->advance = 0;
        for (i = 0; i < 2; ++i) {
            const double k = (b * 2 + i) / 4.0 * 720 * DEG;
            cx->lobe_angle[i] = (360 * DEG - 112 * DEG + k) / 2;
            ci->lobe_angle[i] = (360 * DEG + 117 * DEG + k) / 2;
        }
        e->bank[b].bore = bore;
        e->bank[b].deck_height = stroke / 2 + rod + comp;
        e->bank[b].angle = b ? -90 * DEG : 90 * DEG;
        e->bank[b].chamber_volume = 67 * CC;
        e->bank[b].in_runner_vol = 149.6 * CC;
        e->bank[b].in_runner_area = 1.75 * INCH * 1.75 * INCH;
        e->bank[b].ex_runner_vol = 50.0 * CC;
        e->bank[b].ex_runner_area = 1.25 * INCH * 1.25 * INCH;
        e->bank[b].in_flow = fin; e->bank[b].ex_flow = fex;
        e->bank[b].cam_in = b * 2; e->bank[b].cam_ex = b * 2 + 1;
    }
    for (i = 0; i < 4; ++i) {
        es_cyl *c = &e->cyl[i];
        c->bank = i / 2; c->lobe = i % 2; c->intake = 0; c->exhaust = 0;
        c->journal_angle = jr[i] * DEG;
        c->rod_length = rod; c->compression_height = comp;
        c->sound_att = att[i];
        c->primary_length = prim[i] * INCH;
        c->plug_angle = plug[i] * DEG;
        c->blowby_k = es_k_28inH2O(bb[i]);
    }
}

const char *const ES_PRESET_NAMES[ES_N_PRESETS] = {"GM LS V8", "Toyota 2JZ I6", "Subaru EJ25 H4"};

void es_preset_load(es_engine *e, int which)
{
    memset(e, 0, sizeof *e);
    switch (which) {
    case 1: preset_2jz(e); break;
    case 2: preset_ej25(e); break;
    default: preset_gm_ls(e); break;
    }
    es_engine_init(e);
}
