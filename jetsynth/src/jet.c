/* jet.c -- JETSYNTH engine. See jet.h for the controls.
 *
 * Signal flow, per sample:
 *   white noise -> 24 one-third-octave band-pass filters, each gained to the
 *                  pyNA band power of JET + CORE + FAN broadband       (roar)
 *   + 10 BPF harmonics (fan rotor-stator tones)                          (whine)
 *   + shaft-order comb, band-shaped by pyNA's buzz-saw spectrum          (buzz)
 *   -> JUNO chorus -> JUNO delay -> JUNO reverb -> soft clip
 * Control rate (every JET_BLOCK samples): spool dynamics, table lookup,
 * propagation, and new target gains; gains ramp linearly across the block.
 */
#include "jet.h"
#include "jet_math.h"
#include "../gen/jet_tables.h"
#include "../gen/jet_fx_coefs.h"

#define JET_BLOCK   32
#define JET_NTONE   JT_NH
#define JET_NBUZZ   48            /* shaft orders 1..48, BPF multiples skipped */
#define FAN_D       1.1948f       /* fan diameter, m (deck)                  */
#define C0          340.294f      /* pyNA sea-level speed of sound           */
#define REF_DB      140.0f        /* SPL that maps to digital rms 1.0        */
#define PI_F        3.14159265f

static float SR = 48000.0f;
static float P[JET_NPARAM] = {0.35f, 0.35f, 0.0f, 0.35f, 0.25f, 0.5f, 0.35f, 0.0f, 0.6f};

/* ---------------------------------------------------------------- state */
typedef struct { float b0, a1, a2, x1, x2, y1, y2, g, gstep; } band_t;
typedef struct { float ph, inc, incstep, a, astep; } osc_t;

static band_t  bands[JT_NB];
static osc_t   tone[JET_NTONE], buzz[JET_NBUZZ];
static float   buzz_w[JET_NBUZZ];            /* per-order blade irregularity */
static float   spool = 0.30f;                /* TS the engine is actually at */
static unsigned rng = 0x9E3779B9u;
static float   lf1, lf2;                     /* slow turbulence processes    */
/* CHARACTER layer */
static float   flut, flut_g, flut_step;      /* large-eddy pulsing (AM)      */
static float   rum1, rum2, rum_g, rum_step;  /* sub rumble, 2-pole lowpass   */
static float   crk_env, crk_x1, crk_y, crk_rate, crk_amp;
static osc_t   whine[2];                     /* compressor (N2) stage tones  */
static float   meters[5];

static eb_chorus_state cho;
static eb_delay_state  dly;
static eb_reverb_state rev;
static int32_t         rev_wipe = 256;

static float white(void)                     /* uniform -1..1, var 1/3 */
{
    rng = rng * 1664525u + 1013904223u;
    return (float)(int32_t)rng * (1.0f / 2147483648.0f);
}

/* ------------------------------------------------------------ mapping */
static float map_exp(float v, float lo, float hi) { return lo * jexp2(v * jlog2(hi / lo)); }
static float ts_target(void)  { return P[JET_BOOST] > 0.5f ? 1.05f : 0.30f + 0.75f * P[JET_THROTTLE]; }
static float spool_tau(void)  { return map_exp(P[JET_SPOOL], 0.25f, 12.0f); }
static float mach0(void)      { return 0.4f * P[JET_SPEED]; }
static float theta_deg(void)  { return 180.0f * P[JET_ANGLE]; }
static float dist_m(void)     { return map_exp(P[JET_DISTANCE], 15.0f, 800.0f); }
static float size_x(void)     { return map_exp(P[JET_SIZE], 0.5f, 2.0f); }

/* ------------------------------------------------------ table lookup */
typedef struct { int i0, i1; float f; } lerp_t;
static lerp_t axis(float x, int n)
{
    lerp_t l;
    if (x < 0.0f) x = 0.0f;
    if (x > (float)(n - 1)) x = (float)(n - 1);
    l.i0 = (int)x; if (l.i0 > n - 2) l.i0 = n - 2;
    l.i1 = l.i0 + 1; l.f = x - (float)l.i0;
    return l;
}

/* trilinear read of a [ts][m][th][k] uint16 table (dB x JT_Q) */
static float tri(const uint16_t *t, int nk, int k, lerp_t a, lerp_t b, lerp_t c)
{
    float v = 0.0f;
    int i, j, m;
    for (i = 0; i < 2; i++) for (j = 0; j < 2; j++) for (m = 0; m < 2; m++) {
        int ia = i ? a.i1 : a.i0, ib = j ? b.i1 : b.i0, ic = m ? c.i1 : c.i0;
        float w = (i ? a.f : 1 - a.f) * (j ? b.f : 1 - b.f) * (m ? c.f : 1 - c.f);
        v += w * (float)t[((ia * JT_NM + ib) * JT_NTH + ic) * nk + k];
    }
    return v * (1.0f / JT_Q);
}

/* level of a banded spectrum at fractional band index x (edges clamp, and
 * roll off 3 dB per band beyond them) */
static float band_db(const float *L, float x)
{
    lerp_t l;
    if (x < 0.0f) return L[0] + 3.0f * x;
    if (x > JT_NB - 1) return L[JT_NB - 1] - 3.0f * (x - (JT_NB - 1));
    l = axis(x, JT_NB);
    return L[l.i0] + l.f * (L[l.i1] - L[l.i0]);
}
static float freq_to_band(float f) { return 3.0f * jlog2(f / JT_F[0]); }
static float absorb_db_per_m(float f)
{
    float x = freq_to_band(f);
    lerp_t l;
    if (x <= 0.0f) return JT_ABS[0];
    if (x >= JT_NB - 1) return JT_ABS[JT_NB - 1];
    l = axis(x, JT_NB);
    return JT_ABS[l.i0] + l.f * (JT_ABS[l.i1] - JT_ABS[l.i0]);
}
static float db_to_pow(float db) { return jexp2(db * 0.33219281f); }   /* 10^(db/10) */

/* ------------------------------------------------------------ control */
static void control(void)
{
    const float dt = (float)JET_BLOCK / SR;
    float tgt = ts_target(), s = size_x(), tau, M = mach0(), th = theta_deg();
    float r = dist_m(), spread, cth, dop, rpm, fshaft, shift, lvl_s;
    float jet[JT_NB], core[JT_NB], fan[JT_NB], bz[JT_NB];
    lerp_t a, b, c;
    float ch = P[JET_CHARACTER];
    float bbpow = 0.0f, lowdb;
    int k;

    /* spool: slower at low power, slower up than down, slower when bigger */
    tau = spool_tau() * s * (tgt > spool ? (0.6f + 1.2f * (1.05f - spool)) : 0.6f);
    spool += (tgt - spool) * (1.0f - jexp2(-1.442695f * dt / tau));

    a = axis((spool - JT_TS0) / JT_TSD, JT_NTS);
    b = axis(M / JT_MD, JT_NM);
    c = axis(th / JT_THD, JT_NTH);
    for (k = 0; k < JT_NB; k++) {
        jet[k]  = tri(JT_JET,  JT_NB, k, a, b, c);
        core[k] = tri(JT_CORE, JT_NB, k, a, b, c);
        fan[k]  = tri(JT_FAN,  JT_NB, k, a, b, c);
        bz[k]   = tri(JT_BUZZ, JT_NB, k, a, b, c);
    }

    /* geometric similarity: rotor + jet frequencies x 1/s, level + 20 log s */
    shift = 3.0f * jlog2(s);                     /* bands to read upward      */
    lvl_s = 20.0f * 0.30103f * jlog2(s);
    spread = 20.0f * 0.30103f * jlog2(r / JT_R0);

    /* slow turbulence: two one-pole random walks */
    lf1 += 0.02f * (white() - lf1);
    lf2 += 0.005f * (white() - lf2);
    flut += 0.12f * (white() - flut);             /* ~30 Hz-ish random, per block */

    for (k = 0; k < JT_NB; k++) {
        float f = JT_F[k];
        float pw = db_to_pow(band_db(jet, (float)k + shift) + lvl_s)
                 + db_to_pow(core[k] + lvl_s)
                 + db_to_pow(band_db(fan, (float)k + shift) + lvl_s);
        float db = 10.0f * 0.30103f * jlog2(pw) - spread - JT_ABS[k] * r - REF_DB - 4.0f * ch;
        /* gain so the filtered white noise carries this band power:
         * noise var 1/3, 2nd-order BPF ENBW = (pi/2) * f/Q, Q = 4.318 */
        float enbw = 1.5708f * f / 4.318f;
        float g = jsqrt(db_to_pow(db) / ((1.0f / 3.0f) * enbw / (0.5f * SR)));
        if (f > 0.45f * SR) g = 0.0f;
        bands[k].gstep = (g - bands[k].g) * (1.0f / JET_BLOCK);
        if (f < 0.45f * SR) bbpow += db_to_pow(db);
    }

    /* rotor */
    {
        lerp_t ra = axis((spool - JT_TS0) / JT_TSD, JT_NTS), rb = axis(M / JT_MD, JT_NM);
        float r00 = JT_RPM[ra.i0 * JT_NM + rb.i0], r01 = JT_RPM[ra.i0 * JT_NM + rb.i1];
        float r10 = JT_RPM[ra.i1 * JT_NM + rb.i0], r11 = JT_RPM[ra.i1 * JT_NM + rb.i1];
        rpm = (1 - ra.f) * ((1 - rb.f) * r00 + rb.f * r01) + ra.f * ((1 - rb.f) * r10 + rb.f * r11);
    }
    rpm /= s;
    cth = jcos_deg(th);
    dop = 1.0f / (1.0f - M * cth);                /* pyNA's own Doppler form   */
    fshaft = rpm / 60.0f * dop * (1.0f + 0.002f * lf1);
    meters[0] = spool; meters[1] = rpm; meters[2] = fshaft * JT_B_FAN;
    meters[3] = PI_F * FAN_D * s * (rpm / 60.0f) / C0;

    for (k = 0; k < JET_NTONE; k++) {             /* BPF harmonics           */
        float f = fshaft * JT_B_FAN * (float)(k + 1);
        float db = tri(JT_TONE, JT_NH, k, a, b, c) + lvl_s - spread
                 - absorb_db_per_m(f) * r - REF_DB + 1.5f * lf2 + 24.0f * ch;
        float amp = (f < 0.45f * SR) ? jsqrt(2.0f * db_to_pow(db)) : 0.0f;
        float inc = f / SR;
        tone[k].astep = (amp - tone[k].a) * (1.0f / JET_BLOCK);
        tone[k].incstep = (inc - tone[k].inc) * (1.0f / JET_BLOCK);
    }

    {   /* buzz-saw: band power shared among the shaft orders in each band */
        float wsum[JT_NB + 8];
        int o;
        for (k = 0; k < JT_NB + 8; k++) wsum[k] = 0.0f;
        for (o = 0; o < JET_NBUZZ; o++) {
            float x = freq_to_band(fshaft * (float)(o + 1)) + 0.5f;
            int bi = (int)(x < 0 ? 0 : x);
            if ((o + 1) % JT_B_FAN && bi < JT_NB + 8) wsum[bi] += buzz_w[o];
        }
        for (o = 0; o < JET_NBUZZ; o++) {
            float f = fshaft * (float)(o + 1);
            float x = freq_to_band(f);
            int bi = (int)(x + 0.5f < 0 ? 0 : x + 0.5f);
            float amp = 0.0f;
            if ((o + 1) % JT_B_FAN && bi < JT_NB + 8 && f < 0.45f * SR && wsum[bi] > 0.0f) {
                float db = band_db(bz, x + shift) + lvl_s - spread
                         - absorb_db_per_m(f) * r - REF_DB + 18.0f * ch;
                amp = jsqrt(2.0f * db_to_pow(db) * buzz_w[o] / wsum[bi]);
            }
            buzz[o].astep = (amp - buzz[o].a) * (1.0f / JET_BLOCK);
            buzz[o].incstep = (f / SR - buzz[o].inc) * (1.0f / JET_BLOCK);
        }
    }

    /* ---- CHARACTER layer ---------------------------------------------- */
    {
        float pw = (spool - 0.55f) * 2.0f;            /* 0 below TS .55, 1 at 1.05 */
        float dth = (th - 140.0f) * (1.0f / 35.0f);   /* crackle beams aft ~140 deg */
        float dir = 0.15f + 0.85f * jexp2(-1.442695f * dth * dth);
        float rms = jsqrt(bbpow);
        if (pw < 0.0f) pw = 0.0f;
        if (pw > 1.0f) pw = 1.0f;
        crk_rate = ch * dir * (pw * pw * 900.0f + (P[JET_BOOST] > 0.5f ? 250.0f : 0.0f)) / SR;
        crk_amp = ch * rms * 5.0f;
        /* rumble rides the jet's lowest bands, +12 dB of character */
        lowdb = band_db(jet, shift) + lvl_s - spread - REF_DB + 12.0f * ch - 6.0f;
        {
            float g = ch * jsqrt(db_to_pow(lowdb)) * 120.0f;
            rum_step = (g - rum_g) * (1.0f / JET_BLOCK);
        }
        {   /* pulsing depth grows with power */
            float g = 1.0f + ch * (0.25f + 0.35f * pw) * flut * 3.0f;
            flut_step = (g - flut_g) * (1.0f / JET_BLOCK);
        }
        for (k = 0; k < 2; k++) {                     /* compressor whine        */
            float f = fshaft * JT_B_FAN * (k ? 5.31f : 2.73f);
            float db = tri(JT_TONE, JT_NH, 0, a, b, c) + lvl_s - spread
                     - absorb_db_per_m(f) * r - REF_DB + ch * 20.0f - 30.0f - 6.0f * (float)k
                     + 8.0f * (1.0f - pw);               /* most audible spooling up */
            float amp = (ch > 0.0f && f < 0.45f * SR) ? jsqrt(2.0f * db_to_pow(db)) : 0.0f;
            whine[k].astep = (amp - whine[k].a) * (1.0f / JET_BLOCK);
            whine[k].incstep = (f / SR - whine[k].inc) * (1.0f / JET_BLOCK);
        }
    }
}

/* ------------------------------------------------------------- public */
void jet_init(float sample_rate)
{
    int k;
    SR = sample_rate;
    for (k = 0; k < JT_NB; k++) {                 /* RBJ band-pass, 0 dB peak */
        float w = 2.0f * PI_F * JT_F[k] / SR, q = 4.318f;
        float al = jsin(w) / (2.0f * q), a0 = 1.0f + al;
        bands[k].b0 = al / a0;
        bands[k].a1 = -2.0f * jcos(w) / a0;
        bands[k].a2 = (1.0f - al) / a0;
        bands[k].x1 = bands[k].x2 = bands[k].y1 = bands[k].y2 = 0.0f;
        bands[k].g = bands[k].gstep = 0.0f;
    }
    for (k = 0; k < JET_NBUZZ; k++) {             /* fixed per-engine scatter */
        float u = 0.5f * (white() + 1.0f);
        buzz_w[k] = 0.15f + u * u * 1.7f;
        buzz[k].ph = 0.5f * (white() + 1.0f);
        buzz[k].a = buzz[k].inc = 0.0f;
    }
    for (k = 0; k < JET_NTONE; k++) { tone[k].ph = 0; tone[k].a = tone[k].inc = 0; }
    spool = 0.30f;
    flut = flut_step = 0.0f; flut_g = 1.0f;
    rum1 = rum2 = rum_g = rum_step = 0.0f;
    crk_env = crk_x1 = crk_y = crk_rate = crk_amp = 0.0f;
    for (k = 0; k < 2; k++) { whine[k].ph = 0; whine[k].a = whine[k].inc = 0; }
    eb_chorus_reset(&cho);
    jmemset(&dly, 0, sizeof dly);
    eb_reverb_init(&rev);
    rev_wipe = 256;
}

void jet_set(int p, float v)
{
    if (p < 0 || p >= JET_NPARAM) return;
    if (!(v >= 0.0f)) v = 0.0f;                   /* also catches NaN */
    if (v > 1.0f) v = 1.0f;
    P[p] = v;
}
float jet_get(int p) { return (p >= 0 && p < JET_NPARAM) ? P[p] : 0.0f; }
float jet_meter(int w) { return (w >= 0 && w < 5) ? meters[w] : 0.0f; }

void jet_render(float *L, float *R, int n)
{
    static int blk = 0;
    int i, k;
    float d01 = P[JET_DISTANCE], sp = P[JET_SPACE];
    float wc = sp * (0.35f + 0.65f * d01);        /* chorus = air turbulence  */
    float wd = sp * 0.45f;                        /* delay  = far-wall echo   */
    float wr = sp * (0.3f + 0.7f * d01);          /* reverb = the surroundings */
    float peak = 0.0f;
    for (i = 0; i < n; i++) {
        float x = 0.0f, nz, cl, cr, dl, dr, ra, rb, l, r;
        if (blk == 0) control();
        blk = (blk + 1) % JET_BLOCK;

        nz = white();
        flut_g += flut_step;
        for (k = 0; k < JT_NB; k++) {
            band_t *b = &bands[k];
            float y = b->b0 * (nz - b->x2) - b->a1 * b->y1 - b->a2 * b->y2;
            b->x2 = b->x1; b->x1 = nz; b->y2 = b->y1; b->y1 = y;
            b->g += b->gstep;
            x += b->g * y;
        }
        x *= flut_g;
        {   /* sub rumble */
            rum_g += rum_step;
            rum1 += 0.004f * (white() - rum1);
            rum2 += 0.004f * (rum1 - rum2);
            x += rum_g * rum2;
        }
        {   /* crackle: Poisson-triggered noise bursts, differentiated */
            float u = 0.5f * (white() + 1.0f), y;
            if (u < crk_rate) {
                float m = 0.5f * (white() + 1.0f);
                crk_env = crk_amp * (0.25f + 2.5f * m * m * m);
            }
            y = crk_env * white();
            crk_env *= 0.9f;
            x += y - crk_x1;
            crk_x1 = y;
        }
        for (k = 0; k < 2; k++) {
            osc_t *o = &whine[k];
            o->inc += o->incstep; o->a += o->astep;
            o->ph += o->inc; o->ph -= (float)(int)o->ph;
            x += o->a * jsin_turn(o->ph);
        }
        for (k = 0; k < JET_NTONE; k++) {
            osc_t *o = &tone[k];
            o->inc += o->incstep; o->a += o->astep;
            o->ph += o->inc; o->ph -= (float)(int)o->ph;
            x += o->a * jsin_turn(o->ph);
        }
        for (k = 0; k < JET_NBUZZ; k++) {
            osc_t *o = &buzz[k];
            o->inc += o->incstep; o->a += o->astep;
            o->ph += o->inc; o->ph -= (float)(int)o->ph;
            x += o->a * jsin_turn(o->ph);
        }

        /* JUNO FX, each blended by its own send */
        eb_chorus_tick(&cho, &JS_FX_CHO_P0, x, &cl, &cr);
        cl *= 1.0f / 1.3f; cr *= 1.0f / 1.3f;     /* chorus dry gain is 1.3   */
        l = x + wc * (cl - x);
        r = x + wc * (cr - x);
        eb_delay_process(&JS_FX_DLY_P13, &dly, 0, l, r, &dl, &dr);
        l += wd * (dl - l);
        r += wd * (dr - r);
        eb_reverb_process(&JS_FX_REV_P63, &rev, JS_FX_REVTAPS_P63, &rev_wipe,
                          l, r, &ra, &rb);
        l += wr * (rb - l);                       /* outA carries dry*inB     */
        r += wr * (ra - r);

        l = jsoftclip(l); r = jsoftclip(r);
        if (jabs(l) > peak) peak = jabs(l);
        L[i] = l; R[i] = r;
    }
    meters[4] = peak;
}
