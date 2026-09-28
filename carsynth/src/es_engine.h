/* es_engine.h -- C99 port of the engine-sim piston engine (MIT, Ange Yaghi):
 * CombustionChamber, Intake, ExhaustSystem, CylinderHead + Camshaft +
 * StandardValvetrain, IgnitionModule, Fuel, and PistonEngineSimulator's step
 * and writeToSynthesizer.
 *
 * ONE DELIBERATE DIFFERENCE: upstream moves the crank with a rigid-body
 * solver (simple-2d-constraint-solver) driven by gas forces. Here the crank
 * speed is IMPOSED (the key you play sets it), which is what engine-sim's
 * own dynamometer "hold speed" mode does. Pistons are placed by exact
 * slider-crank geometry (upstream placeCylinder()), so volumes, valve
 * timing, flows, combustion and the exhaust pulses are upstream's model. */
#ifndef ES_ENGINE_H
#define ES_ENGINE_H
#include "es_gas.h"
#include "es_func.h"

#define ES_MAX_CYL    12
#define ES_MAX_BANK   2
#define ES_MAX_EXH    4
#define ES_MAX_INTAKE 2
#define ES_MAX_CAM    4
#define ES_STATE_SAMPLES 256
#define ES_MAX_DELAY  64          /* samples at 10 kHz: 2.2 m of pipe */

typedef struct {
    double plenum_volume, plenum_area, input_k, idle_k, runner_k, runner_length;
    double idle_plate, velocity_decay, molecular_afr;
    /* state */
    es_gas sys, atmos;
    double throttle, flow;
} es_intake;

typedef struct {
    double length, collector_area, outlet_k, primary_tube_length, primary_k;
    double audio_volume, velocity_decay;
    es_gas sys, atmos;
} es_exhaust;

typedef struct {
    int    lobe_profile;             /* index into es_engine.funcs */
    double lobe_angle[ES_MAX_CYL];   /* centerline crank angle / 2 */
    double advance;
} es_cam;

typedef struct {
    double bore, deck_height, angle, dx, dy;
    /* head */
    double chamber_volume, in_runner_vol, in_runner_area, ex_runner_vol, ex_runner_area;
    int    in_flow, ex_flow;         /* es_engine.funcs indices */
    int    cam_in, cam_ex;
} es_bank;

typedef struct {
    int    bank, lobe, intake, exhaust;
    double journal_angle, rod_length, compression_height;
    double sound_att, primary_length, plug_angle, blowby_k;
    /* state */
    es_gas sys, in_runner, ex_runner;
    int    lit;
    struct { double last_volume, travel_x, travel_y, efficiency, flame_speed; es_mix mix; } flame;
    double piston_speed[ES_STATE_SAMPLES], pressure[ES_STATE_SAMPLES];
    double s_prev, s_now, v_s;
    double in_flow_rate, ex_flow_rate, manifold_k, primary_k;
    double cross_area, width_approx;
    double delay[ES_MAX_DELAY]; int delay_len, delay_w;
    int    ignite_event;
} es_cyl;

typedef struct {
    double molecular_mass, energy_density, molecular_afr;
    double max_efficiency, randomness, low_eff_att, max_turb, max_dilution;
    int    flame_func;
} es_fuel;

#define ES_MAX_FUNC 12
typedef struct {
    const char *name;
    int n_cyl, n_bank, n_exh, n_intake, n_cam;
    es_bank    bank[ES_MAX_BANK];
    es_cyl     cyl[ES_MAX_CYL];
    es_intake  intake[ES_MAX_INTAKE];
    es_exhaust exh[ES_MAX_EXH];
    es_cam     cam[ES_MAX_CAM];
    es_fuel    fuel;
    es_func    funcs[ES_MAX_FUNC];
    int        n_funcs, timing_func, turbulence_func;
    double throw_, tdc, redline_rpm, rev_limit, limiter_duration, throttle_gamma;
    double sim_freq, hf_gain, noise, jitter;
    int    ir;                        /* impulse response index */
    double idle_rpm;
    /* crank + control state */
    double theta, v_theta, filtered_rpm;
    double last_cycle_angle, rev_limit_timer;
    double speed_control;             /* pedal 0..1 */
    double exhaust_out[ES_MAX_EXH];   /* synthesizer input for this step */
} es_engine;

/* allocate a function slot */
int  es_engine_func(es_engine *e, double radius);
/* after a preset has filled the definition fields */
void es_engine_init(es_engine *e);
/* one simulation step at 1/sim_freq with crank speed `rpm` */
void es_engine_step(es_engine *e, double rpm);
double es_engine_cycle_angle(const es_engine *e);

#endif
