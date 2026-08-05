/* C4 FEED-FORWARD probe (F3 §5 item 4): the decimator FIR in fixed point.
 * The ladder probe closed 16-bit SIMD for RECURSIVE modules because their
 * quantization error recycles through feedback. A FIR has no feedback, so the
 * error should stay at the quantization floor and not accumulate -- that is
 * the hypothesis, and this measures it instead of assuming it.
 * Same 32-tap folded structure and accumulation order as eb_vcf_ladder.c. */
#include <stdio.h>
#include <stdint.h>
#include <math.h>
#include <stdlib.h>
#include <string.h>
#ifndef M_PI
#define M_PI 3.14159265358979323846
#endif
static float FIR[16];
int main(int argc, char **argv)
{
    int FRAC = argc > 1 ? atoi(argv[1]) : 15;
    const int N = 2000000;
    float h[32]; int64_t qh[32]; int hi = 31, i, j;
    double se = 0, sr = 0, wblk = -999, bse = 0, bsr = 0;
    int64_t QF[16];
    double sum = 0;
    for (j = 0; j < 16; ++j) { FIR[j] = (float)(0.5*(1+cos(M_PI*(15-j+0.5)/16.0))); sum += 2*FIR[j]; }
    for (j = 0; j < 16; ++j) { FIR[j] = (float)(FIR[j]/sum);
                               QF[j] = (int64_t)llrintf(FIR[j]*(float)(1ll<<FRAC)); }
    memset(h,0,sizeof h); memset(qh,0,sizeof qh);
    for (i = 0; i < N; ++i) {
        /* full-scale-ish sub-sample stream, the ladder's own output range */
        float x = 0.9f*sinf((float)(2*M_PI*i*0.11f)) * (0.5f+0.5f*sinf((float)(2*M_PI*i*0.0003f)));
        int64_t qx = (int64_t)llrintf(x*(float)(1ll<<FRAC));
        float acc; int64_t qacc;
        hi = (hi+1)&31; h[hi] = x; qh[hi] = qx;
        acc = (h[(hi-15)&31] + h[(hi-16)&31]) * FIR[0];
        qacc = ((qh[(hi-15)&31] + qh[(hi-16)&31]) * QF[0]) >> FRAC;
        for (j = 1; j < 16; ++j) {
            acc += (h[(hi-(15-j))&31] + h[(hi-(16+j))&31]) * FIR[j];
            qacc += ((qh[(hi-(15-j))&31] + qh[(hi-(16+j))&31]) * QF[j]) >> FRAC;
        }
        { double e = (double)acc - (double)qacc/(double)(1ll<<FRAC);
          se += e*e; sr += (double)acc*(double)acc;
          bse += e*e; bsr += (double)acc*(double)acc;
          if ((i & 1023) == 1023) { if (bsr>1e-12){ double b=10*log10(bse/bsr); if(b>wblk) wblk=b; } bse=bsr=0; } }
    }
    printf("FIR Q%d: global %7.1f dB rel   worst block %7.1f dB rel\n",
           FRAC, 10*log10(se/sr), wblk);
    return 0;
}
