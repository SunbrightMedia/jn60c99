/* es_engine.c -- C99 port of engine-sim's piston engine (MIT, Ange Yaghi).
 * Upstream sources, in the order this file follows them:
 *   src/intake.cpp, src/exhaust_system.cpp, src/camshaft.cpp,
 *   src/cylinder_head.cpp, src/fuel.cpp, src/combustion_chamber.cpp,
 *   src/ignition_module.cpp, src/piston_engine_simulator.cpp (simulateStep_,
 *   placeCylinder, writeToSynthesizer), src/simulator.cpp (simulateStep).
 * See es_engine.h for the one deliberate difference (imposed crank speed). */
#include "es_engine.h"
#include "es_math.h"

#define T25 (25.0 + ES_C0K)
#define RPM_TO_RADS 0.104719755   /* units::rpm */

int es_engine_func(es_engine *e, double radius)
{
    es_func_init(&e->funcs[e->n_funcs], radius);
    return e->n_funcs++;
}

/* ------------------------------------------------------------ crank / piston */
static double crank_angle(const es_engine *e) { return e->theta - e->tdc; }
double es_engine_cycle_angle(const es_engine *e)
{
    const double w = es_fmod(-crank_angle(e), 4 * ES_PI);
    return (w < 0) ? w + 4 * ES_PI : w;
}

/* placeCylinder(): distance s of the wrist pin from the bank origin */
static double piston_s(const es_engine *e, const es_cyl *c)
{
    const es_bank *b = &e->bank[c->bank];
    const double ja = c->journal_angle + e->theta;
    const double p_x = es_cos(ja) * e->throw_, p_y = es_sin(ja) * e->throw_;
    const double A = b->dx * b->dx + b->dy * b->dy;
    const double B = -2 * b->dx * p_x - 2 * b->dy * p_y;
    const double C = p_x * p_x + p_y * p_y - c->rod_length * c->rod_length;
    const double det = B * B - 4 * A * C;
    double sq, s0, s1;
    if (det < 0) return c->s_now;
    sq = es_sqrt(det);
    s0 = (-B + sq) / (2 * A);
    s1 = (-B - sq) / (2 * A);
    return es_fmax(s0, s1);
}

/* CombustionChamber::getVolume() (piston displacement 0 in every preset) */
static double chamber_volume(const es_engine *e, const es_cyl *c)
{
    const es_bank *b = &e->bank[c->bank];
    const double area = ES_PI * b->bore * b->bore / 4.0;
    const double sweep = area * (b->deck_height - c->s_now - c->compression_height);
    return sweep + b->chamber_volume - 0.0;
}

/* ------------------------------------------------------------ valvetrain */
static double cam_angle(const es_engine *e, const es_cam *cam)
{
    const double a = es_fmod((crank_angle(e) + cam->advance) * 0.5, 2 * ES_PI);
    return (a < 0) ? a + 2 * ES_PI : a;
}
static double valve_lift(const es_engine *e, int cam_i, int lobe)
{
    const es_cam *cam = &e->cam[cam_i];
    double t = es_fmod(cam_angle(e, cam) + cam->lobe_angle[lobe], 2 * ES_PI);
    if (t < 0) t += 2 * ES_PI;
    if (t >= ES_PI) t -= 2 * ES_PI;
    return es_func_tri(&e->funcs[cam->lobe_profile], t);
}

/* ------------------------------------------------------------ intake */
static void intake_init(es_intake *in)
{
    const double width = es_sqrt(in->plenum_area);
    es_gas_initialize(&in->sys, ES_ATM, in->plenum_volume, T25, ES_MIX_DEFAULT, 5);
    es_gas_set_geometry(&in->sys, width, in->plenum_volume / in->plenum_area, 1.0, 0.0);
    es_gas_initialize(&in->atmos, ES_ATM, 1000.0, T25, ES_MIX_DEFAULT, 5);
    es_gas_set_geometry(&in->atmos, 100.0, 100.0, 1.0, 0.0);
    in->throttle = 1.0;
    in->flow = 0;
}
static void intake_process(es_intake *in, double dt)
{
    const double ideal_afr = 0.8 * in->molecular_afr * 4;
    const double p_air = ideal_afr / (1 + ideal_afr);
    const double idle_afr = 2.0, p_idle_air = idle_afr / (1 + idle_afr);
    es_mix fa, fm;
    es_flow_params fp;
    double throttle, att;
    fa.p_fuel = 1 - p_air; fa.p_inert = p_air * 0.75; fa.p_o2 = p_air * 0.25;
    fm.p_fuel = (1.0 - p_idle_air); fm.p_inert = p_idle_air * 0.75; fm.p_o2 = p_idle_air * 0.25;
    throttle = in->idle_plate * in->throttle;          /* getThrottlePlatePosition */
    att = es_cos(throttle * ES_PI / 2);
    fp.cross0 = 10.0; fp.cross1 = in->plenum_area;
    fp.direction_x = 0.0; fp.direction_y = -1.0; fp.dt = dt;
    es_gas_reset(&in->atmos, ES_ATM, T25, fa);
    fp.s0 = &in->atmos; fp.s1 = &in->sys;
    fp.k_flow = att * in->input_k;
    in->flow = es_gas_flow(&fp);
    es_gas_reset(&in->atmos, ES_ATM, T25, fm);
    fp.k_flow = in->idle_k;
    es_gas_flow(&fp);
    es_gas_dissipate_excess_velocity(&in->sys);
    es_gas_update_velocity(&in->sys, dt, in->velocity_decay);
}

/* ------------------------------------------------------------ exhaust */
static void exhaust_init(es_exhaust *x)
{
    const double w = es_sqrt(x->collector_area);
    const double vol = x->collector_area * x->length;
    es_gas_initialize(&x->sys, ES_ATM, vol, T25, ES_MIX_DEFAULT, 5);
    es_gas_set_geometry(&x->sys, x->length, w, 1.0, 0.0);
    es_gas_initialize(&x->atmos, ES_ATM, 1000.0, T25, ES_MIX_DEFAULT, 5);
    es_gas_set_geometry(&x->atmos, 10.0, 10.0, 1.0, 0.0);
}
static void exhaust_process(es_exhaust *x, double dt)
{
    es_mix air = {0.0, 1.0, 0.0};
    es_flow_params fp;
    es_gas_reset(&x->atmos, ES_ATM, T25, air);
    fp.cross0 = x->collector_area; fp.cross1 = 10.0;
    fp.direction_x = 1.0; fp.direction_y = 0.0; fp.dt = dt;
    fp.s0 = &x->atmos; fp.s1 = &x->sys;
    fp.k_flow = x->outlet_k;
    es_gas_flow(&fp);
    es_gas_dissipate_excess_velocity(&x->sys);
    es_gas_update_velocity(&x->sys, dt, x->velocity_decay);
}

/* ------------------------------------------------------------ fuel */
static double laminar_velocity(const es_fuel *f, double afr, double T, double P)
{
    const double er_m = 1.21, B_m = 0.305, B_er = -0.549;
    const double er = afr / f->molecular_afr;
    const double alpha = 2.4 - 0.271 * es_pow(er, 3.51);
    const double beta = -0.357 + 0.14 * es_pow(er, 2.77);
    const double S_L_0 = B_m + B_er * (er - er_m) * (er - er_m);
    return S_L_0 * es_pow(T / 298.0, alpha) * es_pow(P / ES_ATM, beta);
}
static double flame_speed(const es_engine *e, double turb, double afr, double T, double P)
{
    const double S_L = laminar_velocity(&e->fuel, afr, T, P);
    return es_func_tri(&e->funcs[e->fuel.flame_func], (turb / S_L) * 1.0) * S_L;
}

/* ------------------------------------------------------------ chamber */
static void chamber_init(es_engine *e, es_cyl *c)
{
    const es_bank *b = &e->bank[c->bank];
    const es_intake *in = &e->intake[c->intake];
    const es_exhaust *x = &e->exh[c->exhaust];
    const double bore_r = b->bore / 2.0;
    double height, irw, mrl, mrv, tirv, oirl, erw, etl, etv, terv, oerl;
    int i;
    c->manifold_k = in->runner_k;
    c->primary_k = x->primary_k;
    c->cross_area = ES_PI * bore_r * bore_r;
    c->width_approx = es_sqrt(c->cross_area);
    for (i = 0; i < ES_STATE_SAMPLES; ++i) { c->piston_speed[i] = 0; c->pressure[i] = 0; }
    c->lit = 0;
    height = chamber_volume(e, c) / c->cross_area;
    es_gas_set_geometry(&c->sys, c->width_approx, height, 1.0, 0.0);

    irw = es_sqrt(b->in_runner_area);
    mrl = in->runner_length;
    mrv = b->in_runner_area * mrl;
    tirv = b->in_runner_vol + mrv;
    oirl = tirv / b->in_runner_area;
    es_gas_initialize(&c->in_runner, ES_ATM, tirv, T25, ES_MIX_DEFAULT, 5);
    es_gas_set_geometry(&c->in_runner, oirl, irw, 1.0, 0.0);

    erw = es_sqrt(b->ex_runner_area);
    etl = x->primary_tube_length + c->primary_length;
    etv = b->ex_runner_area * etl;
    terv = b->ex_runner_vol + etv;
    oerl = terv / b->ex_runner_area;
    es_gas_initialize(&c->ex_runner, ES_ATM, terv, T25, ES_MIX_DEFAULT, 5);
    es_gas_set_geometry(&c->ex_runner, oerl, erw, 1.0, 0.0);
}

static double mean_piston_speed(const es_cyl *c)
{
    double avg = 0; int i;
    for (i = 0; i < ES_STATE_SAMPLES; ++i) avg += c->piston_speed[i];
    return avg / ES_STATE_SAMPLES;
}
static double firing_pressure(const es_cyl *c)
{
    double fp = 0; int i;
    for (i = 0; i < ES_STATE_SAMPLES; ++i) if (c->pressure[i] > fp) fp = c->pressure[i];
    return fp;
}

static void chamber_ignite(es_engine *e, es_cyl *c)
{
    const es_fuel *f = &e->fuel;
    double afr, er, ideal_inert, dilution, turb, mixing, rand_s, eff_att;
    if (c->lit) return;
    if (c->sys.mix.p_fuel == 0) return;
    afr = c->sys.mix.p_o2 / c->sys.mix.p_fuel;
    er = afr / f->molecular_afr;
    if (er < 0.5) return;
    else if (er > 1.9) return;
    ideal_inert = c->sys.mix.p_o2 / 0.7;
    dilution = (c->sys.mix.p_inert / ideal_inert) - 1;
    c->flame.last_volume = chamber_volume(e, c);
    c->flame.travel_x = 0;
    c->flame.travel_y = 0;
    c->flame.mix = c->sys.mix;
    c->lit = 1;
    turb = es_func_tri(&e->funcs[e->turbulence_func], mean_piston_speed(c));
    mixing = 1.0 - (es_clamp(turb / f->max_turb, 0.0, 1.0)
                    * es_clamp(1 - dilution / f->max_dilution, 0.0, 1.0));
    rand_s = f->low_eff_att * ((1 - f->randomness) + f->randomness * es_rand01());
    eff_att = (mixing * rand_s + (1 - mixing));
    c->flame.efficiency = eff_att * f->max_efficiency;
    c->flame.flame_speed = flame_speed(e, turb, afr, es_gas_temperature(&c->sys),
                                       es_gas_pressure(&c->sys));
    (void)firing_pressure;   /* upstream passes it to flameSpeed, which ignores it */
}

static void chamber_update(es_engine *e, es_cyl *c)
{
    const es_bank *b = &e->bank[c->bank];
    int i;
    double ca;
    es_gas_set_volume(&c->sys, chamber_volume(e, c));
    ca = es_engine_cycle_angle(e);
    if (ca != ca) ca = 0.0;
    i = (int)es_round((ca / (4 * ES_PI)) * (ES_STATE_SAMPLES - 1.0));
    c->piston_speed[i] = es_fabs(c->v_s);
    c->pressure[i] = es_gas_pressure(&c->sys);
    c->in_flow_rate = es_func_tri(&e->funcs[b->in_flow], valve_lift(e, b->cam_in, c->lobe));
    c->ex_flow_rate = es_func_tri(&e->funcs[b->ex_flow], valve_lift(e, b->cam_ex, c->lobe));
}

static void chamber_flow(es_engine *e, es_cyl *c, double dt)
{
    const es_bank *b = &e->bank[c->bank];
    es_intake *in = &e->intake[c->intake];
    es_exhaust *x = &e->exh[c->exhaust];
    const double volume = chamber_volume(e, c);
    const double h = volume / c->cross_area;
    const double sa = h * ES_PI * b->bore + c->cross_area * 2;
    const double dT = (90.0 + ES_C0K) - es_gas_temperature(&c->sys);
    es_flow_params fp;
    double intake_flow;
    es_gas_change_energy(&c->sys, dT * sa * 100 * dt);
    es_gas_flow_env(&c->sys, c->blowby_k, dt, ES_ATM, T25, ES_MIX_DEFAULT);

    fp.dt = dt;
    fp.k_flow = c->manifold_k;
    fp.cross0 = in->plenum_area; fp.cross1 = b->in_runner_area;
    fp.direction_x = 1.0; fp.direction_y = 0.0;
    fp.s0 = &in->sys; fp.s1 = &c->in_runner;
    es_gas_flow(&fp);
    es_gas_dissipate_excess_velocity(&c->in_runner);

    fp.k_flow = c->in_flow_rate;
    fp.cross0 = b->in_runner_area; fp.cross1 = volume / h;
    fp.s0 = &c->in_runner; fp.s1 = &c->sys;
    intake_flow = es_gas_flow(&fp);
    es_gas_dissipate_excess_velocity(&c->in_runner);
    es_gas_dissipate_excess_velocity(&c->sys);

    fp.k_flow = c->ex_flow_rate;
    fp.cross0 = volume / h; fp.cross1 = b->ex_runner_area;
    fp.s0 = &c->sys; fp.s1 = &c->ex_runner;
    es_gas_flow(&fp);
    es_gas_dissipate_excess_velocity(&c->sys);
    es_gas_dissipate_excess_velocity(&c->ex_runner);

    fp.k_flow = c->primary_k;
    fp.cross0 = b->ex_runner_area; fp.cross1 = x->collector_area;
    fp.s0 = &c->ex_runner; fp.s1 = &x->sys;
    es_gas_flow(&fp);

    es_gas_update_velocity(&c->in_runner, dt, in->velocity_decay);
    es_gas_update_velocity(&c->sys, dt, 0.5);
    es_gas_update_velocity(&c->ex_runner, dt, x->velocity_decay);

    if (es_fabs(intake_flow) > 1E-9 && c->lit) c->lit = 0;

    if (c->lit) {
        const double ttx = b->bore / 2;
        const double tty = volume / (ES_PI * b->bore * b->bore / 4.0);
        const double expansion = volume / c->flame.last_volume;
        const double ltx = c->flame.travel_x;
        const double lty = c->flame.travel_y * expansion;
        const double fs = c->flame.flame_speed;
        c->flame.travel_x = es_fmin(ltx + dt * fs, ttx);
        c->flame.travel_y = es_fmin(lty + dt * fs, tty);
        if (ltx < c->flame.travel_x || lty < c->flame.travel_y) {
            const double burned = c->flame.travel_x * c->flame.travel_x * ES_PI * c->flame.travel_y;
            const double prev = ltx * ltx * ES_PI * lty;
            const double lit_v = burned - prev;
            const double n = (lit_v / volume) * c->sys.n_mol;
            const double fuel_burned = es_gas_react(&c->sys, n * c->flame.efficiency, c->flame.mix);
            const double mass_burned = fuel_burned * e->fuel.molecular_mass;
            es_gas_change_energy(&c->sys, mass_burned * e->fuel.energy_density);
        } else {
            c->lit = 0;
        }
        c->flame.last_volume = volume;
    }
}

/* ------------------------------------------------------------ ignition */
static void ignition_update(es_engine *e, double dt)
{
    const double ca = es_engine_cycle_angle(e);
    int i;
    if (e->rev_limit_timer == 0) {
        const double four_pi = 4 * ES_PI;
        const double advance = es_func_tri(&e->funcs[e->timing_func], -e->v_theta);
        for (i = 0; i < e->n_cyl; ++i) {
            double adj = es_positive_mod(e->cyl[i].plug_angle - advance, four_pi);
            const double r0 = e->last_cycle_angle;
            double r1 = ca;
            if (e->v_theta < 0) {
                if (r1 < r0) { r1 += four_pi; adj += four_pi; }
                if (adj >= r0 && adj < r1) e->cyl[i].ignite_event = 1;
            } else {
                if (r1 > r0) { r1 -= four_pi; adj -= four_pi; }
                if (adj >= r1 && adj < r0) e->cyl[i].ignite_event = 1;
            }
        }
    }
    e->rev_limit_timer -= dt;
    if (es_fabs(e->v_theta) > e->rev_limit) e->rev_limit_timer = e->limiter_duration;
    if (e->rev_limit_timer < 0) e->rev_limit_timer = 0;
    e->last_cycle_angle = ca;
}

/* ------------------------------------------------------------ public */
void es_engine_init(es_engine *e)
{
    int i;
    e->theta = 0; e->v_theta = 0; e->filtered_rpm = 0; e->rev_limit_timer = 0;
    for (i = 0; i < e->n_bank; ++i) {
        es_bank *b = &e->bank[i];
        b->dx = es_cos(b->angle + ES_PI / 2);
        b->dy = es_sin(b->angle + ES_PI / 2);
    }
    for (i = 0; i < e->n_intake; ++i) intake_init(&e->intake[i]);
    for (i = 0; i < e->n_exh; ++i) exhaust_init(&e->exh[i]);
    for (i = 0; i < e->n_cyl; ++i) {
        es_cyl *c = &e->cyl[i];
        const es_exhaust *x = &e->exh[c->exhaust];
        double len;
        /* upstream initializes the chambers BEFORE placeAndInitialize() puts
         * the pistons in place: the chamber gas height is taken with the
         * piston body still at the bank origin (s = 0). Kept as upstream. */
        c->s_now = 0;
        c->ignite_event = 0;
        chamber_init(e, c);
        c->s_now = piston_s(e, c);
        c->s_prev = c->s_now;
        c->v_s = 0;
        es_gas_initialize(&c->sys, ES_ATM, chamber_volume(e, c), T25, ES_MIX_DEFAULT, 5);
        len = c->primary_length + x->length;
        c->delay_len = (int)es_round((len / 343.0) * e->sim_freq);
        if (c->delay_len > ES_MAX_DELAY) c->delay_len = ES_MAX_DELAY;
        for (c->delay_w = 0; c->delay_w < ES_MAX_DELAY; c->delay_w++) c->delay[c->delay_w] = 0;
        c->delay_w = 0;
    }
    e->last_cycle_angle = es_engine_cycle_angle(e);
    for (i = 0; i < e->n_exh; ++i) e->exhaust_out[i] = 0;
}

void es_engine_step(es_engine *e, double rpm)
{
    const double dt = 1.0 / e->sim_freq;
    const double fdt = dt / 8;                   /* m_fluidSimulationSteps = 8 */
    double alpha, att, att3;
    int i, k;

    /* rigid-body step, replaced by the imposed speed (see header) */
    e->v_theta = -rpm * RPM_TO_RADS;             /* engines spin clockwise */
    e->theta += e->v_theta * dt;
    for (i = 0; i < e->n_cyl; ++i) {
        es_cyl *c = &e->cyl[i];
        c->s_prev = c->s_now;
        c->s_now = piston_s(e, c);
        c->v_s = (c->s_now - c->s_prev) / dt;
    }
    /* DirectThrottleLinkage: plate = 1 - s^gamma, Engine::setThrottle */
    for (i = 0; i < e->n_intake; ++i)
        e->intake[i].throttle = 1 - es_pow(e->speed_control, e->throttle_gamma);
    /* Simulator::updateFilteredEngineSpeed */
    alpha = dt / (100 + dt);
    e->filtered_rpm = alpha * e->filtered_rpm + (1 - alpha) * es_fabs(rpm);
    /* Crankshaft::resetAngle */
    e->theta = es_fmod(e->theta, 4 * ES_PI);

    /* PistonEngineSimulator::simulateStep_ */
    ignition_update(e, dt);
    for (i = 0; i < e->n_cyl; ++i) {
        if (e->cyl[i].ignite_event) chamber_ignite(e, &e->cyl[i]);
        chamber_update(e, &e->cyl[i]);
    }
    for (k = 0; k < 8; ++k) {
        for (i = 0; i < e->n_exh; ++i) exhaust_process(&e->exh[i], fdt);
        for (i = 0; i < e->n_intake; ++i) intake_process(&e->intake[i], fdt);
        for (i = 0; i < e->n_cyl; ++i) chamber_flow(e, &e->cyl[i], fdt);
    }
    for (i = 0; i < e->n_cyl; ++i) e->cyl[i].ignite_event = 0;

    /* writeToSynthesizer */
    for (i = 0; i < e->n_exh; ++i) e->exhaust_out[i] = 0;
    att = es_fmin(es_fabs(e->filtered_rpm), 40.0) / 40.0;
    att3 = att * att * att;
    for (i = 0; i < e->n_cyl; ++i) {
        es_cyl *c = &e->cyl[i];
        const es_exhaust *x = &e->exh[c->exhaust];
        const double len = c->primary_length + x->length;
        const double flow = att3 * 1600 * (
            1.0 * (es_gas_pressure(&c->ex_runner) - ES_ATM)
            + 0.1 * es_gas_dynamic_pressure(&c->ex_runner, 1.0, 0.0)
            + 0.1 * es_gas_dynamic_pressure(&c->ex_runner, -1.0, 0.0));
        double delayed;
        if (c->delay_len > 0) {                   /* DelayFilter: y[n] = x[n-L] */
            delayed = c->delay[c->delay_w];
            c->delay[c->delay_w] = flow;
            c->delay_w = (c->delay_w + 1) % c->delay_len;
        } else {
            delayed = flow;
        }
        e->exhaust_out[c->exhaust] +=
            c->sound_att * (x->audio_volume * delayed / e->n_cyl) * (1 / (len * len));
    }
}
