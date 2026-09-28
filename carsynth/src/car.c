/* car.c -- CARSYNTH instrument layer. See car.h. */
#include "car.h"
#include "es_presets.h"
#include "es_synth.h"
#include "es_math.h"
#include "../gen/es_ir.h"
#include "../gen/car_fx_coefs.h"

static es_engine E;
static es_synth  S;
static float     P[CAR_NPARAM] = {0.0f, 0.0f, 0.7f, 0.35f, 0.32f, 1.0f, 0.3f};
static int       cur_engine = -1, cur_ir = -1;
static double    rpm, target_rpm, pedal, pedal_target;
static int       held[128], held_n, last_note = -1;
static float     vel;
static float     ir_buf[ES_FC_B * ES_FC_MAXP];

static eb_chorus_state cho;
static eb_delay_state  dly;
static eb_reverb_state rev;
static int32_t         rev_wipe = 256;

static float softclip(float x)      /* linear to ~0.5, never beyond +-1 */
{
    if (x > 3.0f) return 1.0f;
    if (x < -3.0f) return -1.0f;
    return x * (27.0f + x * x) / (27.0f + 9.0f * x * x);
}
static int stepped(float v, int n) { int i = (int)(v * n); return i < 0 ? 0 : (i >= n ? n - 1 : i); }
/* EXHAUST: position 0 = the engine's own impulse response, then the library */
static int ir_choice(void) { int k = stepped(P[CAR_EXHAUST], ES_N_IR + 1); return k == 0 ? E.ir : k - 1; }

static void load_ir(int k)
{
    const es_ir_t *ir = &ES_IRS[k];
    int i;
    for (i = 0; i < ir->n; ++i) ir_buf[i] = ir->volume * ir->s[i] / 32767.0f;
    es_fftconv_init(&S.conv, ir_buf, ir->n);
    cur_ir = k;
}

static void apply_audio_params(void)
{
    float t = P[CAR_TONE], nz = P[CAR_NOISE];
    S.dF_F_mix = 0.1f * t * t;                   /* 0.32 -> 0.0102, the presets' 0.01 */
    S.air_noise = nz * (float)E.noise;
    S.input_noise = nz * (float)E.jitter;
}

static void load_engine(int k)
{
    es_preset_load(&E, k);
    es_synth_init(&S, E.n_exh, E.sim_freq, CAR_SR, ir_buf, 0);
    load_ir(ir_choice());
    apply_audio_params();
    rpm = target_rpm = E.idle_rpm;
    pedal = pedal_target = 0;
    cur_engine = k;
}

void car_init(void)
{
    es_srand(12345u);
    held_n = 0; last_note = -1;
    load_engine(stepped(P[CAR_ENGINE], ES_N_PRESETS));
    eb_chorus_reset(&cho);
    {   unsigned char *p = (unsigned char *)&dly; unsigned long i;
        for (i = 0; i < sizeof dly; ++i) p[i] = 0; }
    eb_reverb_init(&rev);
    rev_wipe = 256;
}

void car_set(int p, float v)
{
    if (p < 0 || p >= CAR_NPARAM) return;
    if (!(v >= 0.0f)) v = 0.0f;
    if (v > 1.0f) v = 1.0f;
    P[p] = v;
    if (p == CAR_ENGINE && stepped(v, ES_N_PRESETS) != cur_engine) load_engine(stepped(v, ES_N_PRESETS));
    if (p == CAR_EXHAUST && ir_choice() != cur_ir) load_ir(ir_choice());
    if (p == CAR_TONE || p == CAR_NOISE) apply_audio_params();
}
float car_get(int p) { return (p >= 0 && p < CAR_NPARAM) ? P[p] : 0.0f; }

static double note_rpm(int note)
{
    const double f = 440.0 * es_pow(2.0, (note - 69) / 12.0);
    double r = 120.0 * f / E.n_cyl;              /* firing frequency = key pitch */
    const double lo = 0.6 * E.idle_rpm, hi = 1.08 * E.redline_rpm;
    while (r > hi) r *= 0.5;                     /* fold into the engine's range */
    while (r < lo) r *= 2.0;
    return r;
}

void car_note_on(int note, float v)
{
    int i;
    if (note < 0 || note > 127) return;
    for (i = 0; i < held_n; ++i) if (held[i] == note) break;
    if (i == held_n && held_n < 128) held[held_n++] = note;
    last_note = note;
    vel = v < 0.05f ? 0.05f : (v > 1 ? 1 : v);
    target_rpm = note_rpm(note);
    pedal_target = P[CAR_LOAD] * vel;
}

void car_note_off(int note)
{
    int i, j;
    for (i = 0; i < held_n; ++i) if (held[i] == note) {
        for (j = i + 1; j < held_n; ++j) held[j - 1] = held[j];
        held_n--;
        break;
    }
    if (held_n > 0) {
        last_note = held[held_n - 1];
        target_rpm = note_rpm(last_note);
    } else {
        last_note = -1;
        target_rpm = E.idle_rpm;
        pedal_target = 0;
    }
}

/* one engine-sim step: control, physics, write to the synthesizer */
static void sim_step(void)
{
    const double dt = 1.0 / E.sim_freq;
    const double tau = 0.02 * es_pow(100.0, P[CAR_REV]);        /* 20 ms .. 2 s */
    const double up = (target_rpm > rpm) ? 1.0 : 0.7;            /* revs fall a bit faster */
    rpm += (target_rpm - rpm) * (1.0 - es_exp(-dt / (tau * up)));
    pedal += (pedal_target - pedal) * (1.0 - es_exp(-dt / 0.03));
    E.speed_control = pedal;
    es_engine_step(&E, rpm);
    es_synth_write_input(&S, E.exhaust_out);
}

void car_render(float *L, float *R, int n)
{
    const float sp = P[CAR_SPACE];
    const float wc = sp * 0.8f, wd = sp * 0.35f, wr = sp * 0.6f;
    int i;
    for (i = 0; i < n; ++i) {
        float x, cl, cr, l, r, dl, dr, ra, rb;
        while (S.fifo_n == 0) sim_step();
        x = 0.45f * es_synth_render_one(&S);
        eb_chorus_tick(&cho, &JS_FX_CHO_P0, x, &cl, &cr);
        cl *= 1.0f / 1.3f; cr *= 1.0f / 1.3f;
        l = x + wc * (cl - x);
        r = x + wc * (cr - x);
        eb_delay_process(&JS_FX_DLY_P13, &dly, 0, l, r, &dl, &dr);
        l += wd * (dl - l); r += wd * (dr - r);
        eb_reverb_process(&JS_FX_REV_P63, &rev, JS_FX_REVTAPS_P63, &rev_wipe, l, r, &ra, &rb);
        l += wr * (rb - l); r += wr * (ra - r);
        l = softclip(l); r = softclip(r);
        L[i] = l; R[i] = r;
    }
}

float car_meter(int w)
{
    switch (w) {
    case 0: return (float)rpm;
    case 1: return (float)target_rpm;
    case 2: return (float)pedal;
    case 3: return (float)(rpm / 60.0 * E.n_cyl / 2.0);
    case 4: return (float)E.n_cyl;
    case 5: return (float)ES_N_PRESETS;
    case 6: return (float)(ES_N_IR + 1);
    case 7: return (float)cur_engine;
    }
    return 0.0f;
}
const char *car_engine_name(int i) { return (i >= 0 && i < ES_N_PRESETS) ? ES_PRESET_NAMES[i] : ""; }
const char *car_exhaust_name(int i) { return i == 0 ? "Stock" : (i > 0 && i <= ES_N_IR) ? ES_IRS[i - 1].label : ""; }
