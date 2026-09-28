/* es_fftconv.h -- uniformly partitioned overlap-save FFT convolution.
 *
 * Replaces engine-sim's direct-form ConvolutionFilter (up to 10,000 taps per
 * sample -- 440 M multiply-adds a second, out of reach of an ESP32-S3). Same
 * linear operator, different summation order, plus ES_FC_B samples of
 * latency. tests/test_fftconv.c holds it to the direct form. No malloc:
 * storage is static and sized at compile time. */
#ifndef ES_FFTCONV_H
#define ES_FFTCONV_H

#define ES_FC_B      256                 /* block (latency), samples */
#define ES_FC_N      (2 * ES_FC_B)       /* FFT size */
#define ES_FC_MAXP   40                  /* 40 x 256 = 10,240 taps >= upstream 10,000 */

typedef struct { float re, im; } es_cpx;

typedef struct {
    int    parts, pos, fdl_head;
    float  in[ES_FC_N];                  /* previous block | current block */
    float  out[ES_FC_B];
    es_cpx H[ES_FC_MAXP][ES_FC_N];       /* partition spectra */
    es_cpx X[ES_FC_MAXP][ES_FC_N];       /* frequency-domain delay line */
} es_fftconv;

/* ir: taps (already scaled), n <= ES_FC_B * ES_FC_MAXP */
void  es_fftconv_init(es_fftconv *c, const float *ir, int n);
/* one sample in, one sample out (delayed by ES_FC_B) */
float es_fftconv_tick(es_fftconv *c, float x);

#endif
