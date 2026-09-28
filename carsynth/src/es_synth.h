/* es_synth.h -- C99 port of engine-sim Synthesizer (src/synthesizer.cpp,
 * MIT, Ange Yaghi): the audio path from exhaust flow to output sample.
 *   writeInput   linear resample sim rate -> audio rate, per-channel
 *                4th-order Butterworth at 1,900 Hz
 *   renderAudio  jitter, DC removal, d/dt ("hf gain") vs low-passed air
 *                noise, impulse-response convolution, 0.45 fs Butterworth,
 *                peak leveler.
 * Differences from upstream, all stated:
 *   - the two exhaust channels share one impulse response in every preset,
 *     so their pre-convolution signals are summed and convolved ONCE
 *     (convolution is linear; only the summation order changes);
 *   - convolution is FFT-partitioned (es_fftconv.h), +256 samples latency;
 *   - rand() / std::default_random_engine are a 32-bit LCG;
 *   - no int16 clamp at the end (the instrument soft-limits instead). */
#ifndef ES_SYNTH_H
#define ES_SYNTH_H
#include "es_fftconv.h"

#define ES_SYN_MAXCH  4
#define ES_SYN_FIFO   64          /* audio samples produced per input sample: 4.41 */
#define ES_SYN_INBUF  44100       /* upstream inputBufferSize */

typedef struct { double a[5], f4, x[4], y[4]; int is_float; } es_bw;

typedef struct {
    /* AudioParameters */
    float volume, convolution, dF_F_mix, input_noise, input_noise_cut, air_noise,
          air_noise_cut, leveler_target, leveler_max, leveler_min;
    double in_rate, out_rate;
    int    nch;
    /* writeInput */
    double write_offset, last_offset, last_input[ES_SYN_MAXCH];
    long   write_index;
    float  fifo[ES_SYN_MAXCH][ES_SYN_FIFO];
    int    fifo_n;
    es_bw  aa_in[ES_SYN_MAXCH];
    /* renderAudio */
    float  jit_hist[ES_SYN_MAXCH][10]; int jit_off[ES_SYN_MAXCH];
    es_bw  jit_lp[ES_SYN_MAXCH];
    float  dc_y[ES_SYN_MAXCH], dc_rc, deriv_prev[ES_SYN_MAXCH];
    es_bw  air_lp;                 /* upstream uses m_filters[0]'s for every channel */
    es_bw  aa_out;
    float  lev_peak, lev_att;
    es_fftconv conv;
} es_synth;

void es_synth_init(es_synth *s, int nch, double in_rate, double out_rate,
                   const float *ir, int ir_len);
void es_synth_write_input(es_synth *s, const double *data);
/* pop one rendered output sample (FIFO must be non-empty); returns -1..1 */
float es_synth_render_one(es_synth *s);

#endif
