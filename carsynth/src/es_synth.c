/* es_synth.c -- C99 port of engine-sim src/synthesizer.cpp and its filters
 * (butterworth_low_pass_filter.h, jitter_filter.h, low_pass_filter.h,
 * derivative_filter.cpp, leveling_filter.cpp). See es_synth.h. */
#include "es_synth.h"
#include "es_math.h"

/* ButterworthLowPassFilter<T>::setCutoffFrequency / fast_f */
static void bw_set(es_bw *b, double fc, double sr, int is_float)
{
    const double f = es_tan(ES_PI * fc / sr);
    const double f2 = f * f, f3 = f2 * f, f4 = f2 * f2;
    const double m = -2.0 * es_cos(5.0 * ES_PI / 8.0);
    const double n = -2.0 * es_cos(7.0 * ES_PI / 8.0);
    int i;
    b->a[0] = 1.0 + (m + n) * f + (2.0 + n * m) * f2 + (m + n) * f3 + f4;
    b->a[1] = (-4.0 - 2.0 * (n + m) * f + 2.0 * (m + n) * f3 + 4.0 * f4) / b->a[0];
    b->a[2] = (6.0 - 2.0 * (2.0 + m * n) * f2 + 6.0 * f4) / b->a[0];
    b->a[3] = (-4.0 + 2.0 * (m + n) * f - 2.0 * (m + n) * f3 + 4.0 * f4) / b->a[0];
    b->a[4] = (1.0 - (n + m) * f + (2.0 + m * n) * f2 - (m + n) * f3 + f4) / b->a[0];
    b->f4 = f4;
    b->is_float = is_float;
    if (is_float) for (i = 0; i < 5; ++i) b->a[i] = (float)b->a[i];
    if (is_float) b->f4 = (float)b->f4;
    for (i = 0; i < 4; ++i) b->x[i] = b->y[i] = 0;
}
static double bw_f(es_bw *b, double x)
{
    /* x[0] = newest ... x[3] = oldest (upstream reads read(3)..read(0)) */
    double n = b->f4 / b->a[0] * (x + 4 * b->x[0] + 6 * b->x[1] + 4 * b->x[2] + b->x[3]);
    double d = -b->a[1] * b->y[0] - b->a[2] * b->y[1] - b->a[3] * b->y[2] - b->a[4] * b->y[3];
    double y = n + d;
    if (b->is_float) y = (float)((float)n + (float)d);
    b->x[3] = b->x[2]; b->x[2] = b->x[1]; b->x[1] = b->x[0]; b->x[0] = x;
    b->y[3] = b->y[2]; b->y[2] = b->y[1]; b->y[1] = b->y[0]; b->y[0] = y;
    return y;
}

void es_synth_init(es_synth *s, int nch, double in_rate, double out_rate,
                   const float *ir, int ir_len)
{
    int i, k;
    /* AudioParameters defaults (synthesizer.h); engine presets override
     * dF_F_mix / air_noise / input_noise (engine_sim_application.cpp) */
    s->volume = 1.0f; s->convolution = 1.0f; s->dF_F_mix = 0.01f;
    s->input_noise = 0.5f; s->input_noise_cut = 10000.0f;
    s->air_noise = 1.0f; s->air_noise_cut = 2000.0f;
    s->leveler_target = 30000.0f; s->leveler_max = 1.9f; s->leveler_min = 0.00001f;
    s->nch = nch; s->in_rate = in_rate; s->out_rate = out_rate;
    s->write_offset = 0; s->last_offset = 0; s->write_index = 0; s->fifo_n = 0;
    for (i = 0; i < nch; ++i) {
        s->last_input[i] = 0;
        bw_set(&s->aa_in[i], 1900.0, out_rate, 0);
        bw_set(&s->jit_lp[i], s->input_noise_cut, out_rate, 1);
        for (k = 0; k < 10; ++k) s->jit_hist[i][k] = 0;
        s->jit_off[i] = 0;
        s->dc_y[i] = 0;
        s->deriv_prev[i] = 0;
    }
    s->dc_rc = 1.0f / (10.0f * 2.0f * (float)ES_PI);
    bw_set(&s->air_lp, s->air_noise_cut, out_rate, 1);
    bw_set(&s->aa_out, out_rate * 0.45, out_rate, 1);
    s->lev_peak = 30000.0f; s->lev_att = 1.0f;
    es_fftconv_init(&s->conv, ir, ir_len);
}

static double in_dist(double s1, double s0)
{
    return (s1 < s0) ? (double)ES_SYN_INBUF - s0 + s1 : s1 - s0;
}

void es_synth_write_input(es_synth *s, const double *data)
{
    int i, start = s->fifo_n, count = 0;
    double dist, s0;
    s->write_offset += s->out_rate / s->in_rate;
    if (s->write_offset >= (double)ES_SYN_INBUF) s->write_offset -= (double)ES_SYN_INBUF;
    dist = in_dist(s->write_offset, s->last_offset);
    s0 = in_dist((double)s->write_index, s->last_offset);
    for (i = 0; i < s->nch; ++i) {
        double p = s0;
        int w = start;
        count = 0;
        for (; p <= dist; p += 1.0) {
            double f, smp;
            if (p >= ES_SYN_INBUF) p -= ES_SYN_INBUF;
            f = p / dist;
            smp = s->last_input[i] * (1 - f) + data[i] * f;
            if (w < ES_SYN_FIFO) s->fifo[i][w++] = (float)bw_f(&s->aa_in[i], (float)smp);
            ++count;
        }
        s->last_input[i] = data[i];
    }
    s->fifo_n = start + count;
    if (s->fifo_n > ES_SYN_FIFO) s->fifo_n = ES_SYN_FIFO;
    s->write_index = (s->write_index + count) % ES_SYN_INBUF;
    s->last_offset = s->write_offset;
}

static float render_sample(es_synth *s, int idx)
{
    const float air = s->air_noise, mix = s->dF_F_mix, conv = s->convolution;
    const float dt = (float)(1.0 / s->out_rate);
    float vsum = 0, signal, v, lev, att, raw;
    int i;
    for (i = 0; i < s->nch; ++i) {
        float in = s->fifo[i][idx], jit, f_dc, f, f_p, noise, r, r_mixed, v_in;
        /* JitterFilter::fast_f */
        {
            float sj, i0f, i1f, frac, v0, v1;
            int i0, i1;
            s->jit_hist[i][s->jit_off[i]] = in;
            if (++s->jit_off[i] >= 10) s->jit_off[i] = 0;
            sj = (float)bw_f(&s->jit_lp[i], (float)(es_rand01() * 9.0) * s->input_noise * 1.0f);
            i0f = (float)es_clamp(es_floor(sj), 0.0, 9.0);
            i1f = (float)es_clamp(es_ceil(sj), 0.0, 9.0);
            frac = sj - i0f;
            i0 = (int)i0f + s->jit_off[i];
            i1 = (int)i1f + s->jit_off[i];
            v0 = s->jit_hist[i][i0 >= 10 ? i0 - 10 : i0];
            v1 = s->jit_hist[i][i1 >= 10 ? i1 - 10 : i1];
            jit = v1 * frac + v0 * (1 - frac);
        }
        /* LowPassFilter (DC, 10 Hz) */
        {
            const float alpha = dt / (s->dc_rc + dt);
            s->dc_y[i] = alpha * jit + (1 - alpha) * s->dc_y[i];
            f_dc = s->dc_y[i];
        }
        f = jit - f_dc;
        f_p = (jit - s->deriv_prev[i]) / dt;            /* DerivativeFilter */
        s->deriv_prev[i] = jit;
        noise = (float)(2.0 * es_rand01() - 1.0);
        r = (float)bw_f(&s->air_lp, noise);
        r_mixed = air * r + (1 - air);
        v_in = f_p * mix + f * r_mixed * (1 - mix);
        if (v_in != 0 && v_in < 1.17549435e-38f && v_in > -1.17549435e-38f) v_in = 0;
        vsum += v_in;
    }
    v = conv * es_fftconv_tick(&s->conv, vsum) + (1 - conv) * vsum;
    signal = (float)bw_f(&s->aa_out, v);
    /* LevelingFilter::f */
    s->lev_peak = 0.999f * s->lev_peak;
    if ((signal < 0 ? -signal : signal) > s->lev_peak) s->lev_peak = signal < 0 ? -signal : signal;
    if (s->lev_peak == 0) lev = 0;
    else {
        att = s->leveler_target / s->lev_peak;
        if (att < s->leveler_min) att = s->leveler_min;
        else if (att > s->leveler_max) att = s->leveler_max;
        s->lev_att = 0.9f * s->lev_att + 0.1f * att;
        lev = signal * s->lev_att;
    }
    raw = lev * s->volume;
    /* upstream clamps to int16 here; the leveler overshoots on fresh peaks,
     * so that clamp is hard clipping. The instrument soft-limits at its
     * output instead (car.c), so the float is returned unclamped. */
    return raw * (1.0f / 32768.0f);
}

float es_synth_render_one(es_synth *s)
{
    float y;
    int i, k;
    if (s->fifo_n <= 0) return 0.0f;
    y = render_sample(s, 0);
    for (i = 0; i < s->nch; ++i)
        for (k = 1; k < s->fifo_n; ++k) s->fifo[i][k - 1] = s->fifo[i][k];
    s->fifo_n--;
    return y;
}
