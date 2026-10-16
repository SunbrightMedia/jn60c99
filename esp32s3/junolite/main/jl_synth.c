/* jl_synth.c -- JUNO LITE engine (see jl_synth.h). NOT bit-exact: a quick
 * JUNO-60-style voice that fits one ESP32-S3 core with 6 voices.
 *   DCO   one band-limited saw table per octave (mip-map, 11 x 2048), linear
 *         interpolation; pulse = saw(p) - saw(p + w) (zero DC, PWM free);
 *         sub = square an octave down, the same trick at half phase; one noise.
 *   VCF   4 one-pole ladder at 1x rate, soft-clipped feedback, cutoff per block.
 *   ENV   ADSR (linear attack, exponential decay/release), one per voice.
 *   FX    HPF on the sum; chorus I / II / I+II at half rate (22.05 kHz). */
#include <math.h>
#include <string.h>
#include "jl_synth.h"
#include "jl_bank.h"

#define TL   2048
#define NT   11
#define F0   20.0f                     /* table k holds fundamentals <= F0 * 2^k */
static float tab[NT][TL + 1];

typedef struct {
    int note, gate, stage, age, held;  /* stage 0 idle, 1 A, 2 D/S, 3 R */
    float env, ph, y1, y2, y3, y4, g, ltime;
} voice;
static voice V[JL_VOICES];
static jl_patch P;
static float bend, modw, cc_cut, cc_res, lfo_ph, hp_y, hp_x, vol = 0.15f;            /* ~ -14..-22 dBFS peaks: the HP amp has gain 2 */
static uint32_t rnd = 22222;
static int agec;
/* chorus */
#define CL 1024
static float cbuf[CL], c_lfo, c_prevL, c_prevR, c_curL, c_curR, c_acc;
static int cw, c_half;

const jl_patch jl_presets[] = {   /* hand-set panels (not the factory bank) */
  { .name = "Strings",  .lfo_rate = .45f, .saw = 1, .cutoff = .62f, .res = .1f, .env_amt = .1f, .kybd = .5f,
    .hpf = .2f, .level = .8f, .a = .45f, .d = .5f, .s = .9f, .r = .5f, .chorus = 2 },
  { .name = "Brass",    .lfo_rate = .5f, .saw = 1, .cutoff = .4f, .res = .15f, .env_amt = .45f, .kybd = .5f,
    .level = .8f, .a = .2f, .d = .45f, .s = .6f, .r = .3f, .chorus = 1 },
  { .name = "PWM Pad",  .lfo_rate = .35f, .pulse = 1, .pwm = .6f, .pwm_lfo = 1, .sub = .3f, .cutoff = .55f,
    .res = .1f, .kybd = .5f, .level = .8f, .a = .4f, .d = .5f, .s = .8f, .r = .55f, .chorus = 1 },
  { .name = "Bass",     .lfo_rate = .5f, .pulse = 1, .pwm = .2f, .sub = .7f, .cutoff = .22f, .res = .45f,
    .env_amt = .4f, .kybd = .3f, .level = .9f, .a = 0, .d = .35f, .s = .2f, .r = .15f, .chorus = 0 },
  { .name = "Organ",    .lfo_rate = .6f, .pulse = 1, .saw = 1, .sub = .5f, .cutoff = .7f, .kybd = .5f,
    .vca_gate = 1, .level = .7f, .a = 0, .d = 0, .s = 1, .r = 0, .chorus = 3 },
};
const int jl_npresets = sizeof jl_presets / sizeof jl_presets[0];

void jl_init(void)
{
    static float sn[TL];
    for (int i = 0; i < TL; ++i) sn[i] = sinf(6.2831853f * i / TL);
    for (int k = 0; k < NT; ++k) {
        int H = (int)(JL_SR / 2 / (F0 * (1 << k)));
        if (H > TL / 2 - 1) H = TL / 2 - 1;
        if (H < 1) H = 1;
        for (int i = 0; i < TL; ++i) {
            float s = 0;
            for (int h = H; h >= 1; --h) s += sn[(h * i) & (TL - 1)] / h;
            tab[k][i] = s * 0.63661977f;               /* 2/pi: descending saw, +-1 */
        }
        tab[k][TL] = tab[k][0];
    }
    memset(V, 0, sizeof V);
    cc_cut = cc_res = 0; bend = modw = 0;
    jl_set_patch(&jl_presets[0]);
}

void jl_set_patch(const jl_patch *p) { P = *p; cc_cut = cc_res = 0; }
void jl_bend(float s) { bend = s; }
void jl_mod(float a) { modw = a; }
void jl_cc_cutoff(float v) { cc_cut = v - P.cutoff; }
void jl_cc_res(float v) { cc_res = v - P.res; }
void jl_volume(float v) { vol = v; }

void jl_note_on(int note, int vel)
{
    (void)vel;                                          /* the JUNO-60 has no velocity */
    voice *v = 0;
    for (int i = 0; i < JL_VOICES; ++i) if (V[i].stage && V[i].note == note) v = &V[i];
    for (int i = 0; !v && i < JL_VOICES; ++i) if (!V[i].stage) v = &V[i];
    if (!v) {                                           /* steal: oldest released, else oldest */
        int best = -1;
        for (int pass = 0; pass < 2 && best < 0; ++pass)
            for (int i = 0; i < JL_VOICES; ++i)
                if ((pass || !V[i].gate) && (best < 0 || V[i].age < V[best].age)) best = i;
        v = &V[best];
    }
    if (!v->stage) { v->y1 = v->y2 = v->y3 = v->y4 = 0; v->ph = 0; }
    v->note = note; v->gate = 1; v->stage = 1; v->age = ++agec; v->ltime = 0;
}

void jl_note_off(int note)
{
    for (int i = 0; i < JL_VOICES; ++i) if (V[i].gate && V[i].note == note) { V[i].gate = 0; V[i].stage = 3; }
}
void jl_all_off(void) { for (int i = 0; i < JL_VOICES; ++i) if (V[i].stage) { V[i].gate = 0; V[i].stage = 3; } }

void jl_panic(void) { memset(V, 0, sizeof V); }
int jl_active(void) { int n = 0; for (int i = 0; i < JL_VOICES; ++i) n += V[i].stage != 0; return n; }

static inline float lut(const float *t, float p)       /* p in [0,1) */
{
    float x = p * TL; int i = (int)x; float f = x - i;
    return t[i] + (t[i + 1] - t[i]) * f;
}
static inline const float *mip(float hz)
{
#ifdef JL_TOOTH_NOMIP
    (void)hz; return tab[NT - 1 - 10];          /* tooth: the full-band table for every note */
#endif
    int k = 0; float f = F0;
    while (k < NT - 1 && hz > f) { f *= 2; ++k; }
    return tab[k];
}
static inline float sclip(float x)                     /* x - 4x^3/27, flat beyond +-1.5 */
{
    if (x > 1.5f) return 1;
    if (x < -1.5f) return -1;
    return x - x * x * x * 0.14814815f;
}
static float coef(float t) { return 1.0f - expf(-4.6f / (t * JL_SR)); }   /* 1 % in t */

void jl_render(int16_t *lr)
{
    float mix[JL_BLOCK];
    memset(mix, 0, sizeof mix);
    /* global LFO: triangle */
    float lrate = 0.1f * powf(200.0f, P.lfo_rate);
    lfo_ph += lrate * JL_BLOCK / JL_SR; if (lfo_ph >= 1) lfo_ph -= 1;
    float lfo = lfo_ph < 0.5f ? 4 * lfo_ph - 1 : 3 - 4 * lfo_ph;
    float ta = 0.001f * powf(3000.0f, P.a), td = 0.002f * powf(6000.0f, P.d), tr = 0.002f * powf(6000.0f, P.r);
    float ainc = 1.0f / (ta * JL_SR), dc = coef(td), rc = coef(P.vca_gate ? 0.004f : tr);
    float cut = P.cutoff + cc_cut, res = P.res + cc_res;
    float k = 4.2f * (res < 0 ? 0 : res > 1 ? 1 : res);
    float w = 0.5f - 0.45f * (P.pwm_lfo ? P.pwm * (0.5f + 0.5f * lfo) : P.pwm);
    if (w < 0.03f) w = 0.03f;
    float noise_amt = P.noise * 0.5f, sub_amt = P.sub * 0.5f;
    float gsaw = P.saw ? 0.5f * (P.saw_lv > 0 ? P.saw_lv : 1) : 0, gpul = P.pulse ? 0.5f * (P.pul_lv > 0 ? P.pul_lv : 1) : 0;

    for (int vi = 0; vi < JL_VOICES; ++vi) {
        voice *v = &V[vi];
        if (!v->stage) continue;
        float ld = P.lfo_delay > 0 ? v->ltime / (3.0f * P.lfo_delay) : 1;
        if (ld > 1) ld = 1;
        v->ltime += (float)JL_BLOCK / JL_SR;
        float semis = v->note - 69 + bend + lfo * ld * (P.dco_lfo + modw) * 1.0f;
        float hz = 440.0f * exp2f(semis / 12.0f);
        float inc = hz / JL_SR;
        const float *t1 = mip(hz), *t2 = mip(hz * 0.5f);
        float oct = cut * 10 + (P.env_neg ? -1 : 1) * P.env_amt * v->env * 9
                  + P.vcf_lfo * lfo * ld * 2 + P.kybd * (v->note - 60) / 12.0f;
        float fc = F0 * exp2f(oct); if (fc > 18000) fc = 18000;
        float g1 = 1.0f - expf(-6.2831853f * fc / JL_SR), g0 = v->g, dg = (g1 - g0) / JL_BLOCK;
        float ph = v->ph, env = v->env, y1 = v->y1, y2 = v->y2, y3 = v->y3, y4 = v->y4;
        int stage = v->stage;
        for (int i = 0; i < JL_BLOCK; ++i) {
            float p = ph >= 1 ? ph - 1 : ph;                   /* ph in [0,2): sub = ph/2 */
            float s = lut(t1, p), q = p + w; if (q >= 1) q -= 1;
            float x = gsaw * s + gpul * (s - lut(t1, q));
            if (sub_amt > 0) { float h = ph * 0.5f, h2 = h + 0.5f; if (h2 >= 1) h2 -= 1;
                               x += sub_amt * (lut(t2, h) - lut(t2, h2)); }
            if (noise_amt > 0) { rnd = rnd * 1664525u + 1013904223u; x += noise_amt * ((int32_t)rnd * 4.656613e-10f); }
            ph += inc; if (ph >= 2) ph -= 2;
            float g = g0 + dg * i;
            float u = sclip(x - k * y4);
            y1 += g * (u - y1); y2 += g * (y1 - y2); y3 += g * (y2 - y3); y4 += g * (y3 - y4);
            if (stage == 1) { env += ainc; if (env >= 1) { env = 1; stage = 2; } }
            else if (stage == 2) env += (P.s - env) * dc;
            else if (stage == 3) env -= env * rc;
            float amp = P.vca_gate ? (stage == 3 ? env : 1.0f) : env;
            mix[i] += y4 * (1 + 0.3f * k) * amp;
        }
        v->g = g1;
        if (stage == 3 && env < 1e-4f) { stage = 0; y1 = y2 = y3 = y4 = 0; }
        v->ph = ph; v->env = env; v->stage = stage; v->y1 = y1; v->y2 = y2; v->y3 = y3; v->y4 = y4;
    }

    /* HPF, level, chorus at half rate, out */
    float ha = P.hpf > 0 ? expf(-6.2831853f * 700.0f * P.hpf / JL_SR) : 1.0f;
    float lv = P.level * 0.35f, crate = P.chorus == 1 ? 0.513f : P.chorus == 2 ? 0.863f : 8.0f;
    float cmin = P.chorus == 3 ? 3.3f : 1.66f, cmax = P.chorus == 3 ? 3.7f : 5.35f;   /* ms */
    for (int i = 0; i < JL_BLOCK; ++i) {
        float x = mix[i] * lv;
        if (P.hpf > 0) { float y = ha * (hp_y + x - hp_x); hp_x = x; hp_y = y; x = y; }
        float L = x, R = x;
        if (P.chorus) {
            c_acc += x;
            if (++c_half == 2) {                                /* one chorus step per 2 samples */
                c_half = 0;
                cbuf[cw] = c_acc * 0.5f; c_acc = 0;
                c_lfo += crate * 2 / JL_SR; if (c_lfo >= 1) c_lfo -= 1;
                float tri = c_lfo < 0.5f ? 4 * c_lfo - 1 : 3 - 4 * c_lfo;
                float mid = (cmin + cmax) * 0.5f, dep = (cmax - cmin) * 0.5f, sr2 = JL_SR / 2000.0f;
                float dl = (mid + dep * tri) * sr2, dr = (mid - dep * tri) * sr2;
                float pl = cw - dl, pr = cw - dr; if (pl < 0) pl += CL; if (pr < 0) pr += CL;
                int il = (int)pl, ir = (int)pr; float fl = pl - il, fr = pr - ir;
                c_prevL = c_curL; c_prevR = c_curR;
                c_curL = cbuf[il] + (cbuf[(il + 1) & (CL - 1)] - cbuf[il]) * fl;
                c_curR = cbuf[ir] + (cbuf[(ir + 1) & (CL - 1)] - cbuf[ir]) * fr;
                cw = (cw + 1) & (CL - 1);
            }
            float a = c_half ? 0.5f : 0.0f;                     /* linear upsample */
            float wl = c_prevL + (c_curL - c_prevL) * a, wr = c_prevR + (c_curR - c_prevR) * a;
            L = 0.7f * (x + wl); R = 0.7f * (x + wr);
        }
        L = sclip(L * vol * 2) * 16000; R = sclip(R * vol * 2) * 16000;
        lr[2 * i] = (int16_t)L; lr[2 * i + 1] = (int16_t)R;
    }
    if (fabsf(hp_y) < 1e-20f) hp_y = 0;
}

/* The plugin's factory bank -> JUNO LITE's panel. The bytes are the plugin's (jl_bank.h, generated); this
 * mapping is glue and approximate: levels and sliders scale 0..255 -> 0..1, VCF ENV MOD is taken as bipolar
 * around 128 (INFERRED), the single ADSR takes ENV2 (the amp envelope), the chorus mode from EFFECT TYPE when
 * EFFECT DEPTH > 0 (INFERRED). The plugin's PWM width, LFO and delay / reverb have no JUNO LITE control. */
void jl_bank_patch(int i, jl_patch *p)
{
    const unsigned char *v = jl_bank[i & 63].v;
    float f[JL_BANK_F];
    for (int k = 0; k < JL_BANK_F; ++k) f[k] = v[k] / 255.0f;
    jl_patch q = { 0 };
    q.name = jl_bank[i & 63].name;
    q.saw = v[0] > 0; q.saw_lv = f[0];
    q.pulse = v[1] > 0; q.pul_lv = f[1];
    q.sub = f[2]; q.noise = f[3];
    q.cutoff = f[4]; q.res = f[5];
    q.env_amt = (v[6] - 128) / 127.0f; if (q.env_amt < 0) { q.env_neg = 1; q.env_amt = -q.env_amt; }
    q.kybd = f[7]; q.hpf = f[8];
    q.a = f[9]; q.d = f[10]; q.s = f[11]; q.r = f[12];
    q.level = 0.5f + 0.5f * f[13];
    q.chorus = v[15] ? 1 + (v[14] % 3) : 0;
    q.lfo_rate = 0.5f;
    *p = q;
}
