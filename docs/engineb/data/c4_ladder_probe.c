/* c4_ladder_probe.c — the C4 ONE-FILTER PROTOTYPE (F3): what does fixed-point
 * arithmetic cost, in dB, on the resonant ladder?
 *
 * WHY THIS SHAPE. The ESP32-S3's PIE SIMD has no float lanes and its multiply
 * lanes are 8/16-bit (EE.VMULAS.S16); the only vector route to the promised
 * x2-3 is Q15-class arithmetic, 8 voices across 8 lanes. A 32-bit fixed
 * scalar (Q28 here) has no SIMD carrier on this chip — it is the CONTROL that
 * separates "fixed-point per se" from "16-bit precision", so a Q15 failure
 * can be attributed correctly.
 *
 * The float reference is the trunk's own eb_vcf_tick, byte for byte. The two
 * integer variants reproduce its exact structure — same ZDF resolution, same
 * clip, same quintic, same four sub-steps, same folded FIR, same dither
 * oscillator (whose 24-bit values are EXACT in both Q formats, so the dither
 * cannot be blamed for any difference).
 *
 * The drive program is chosen to be HARD but plausible: a -12 dBFS input
 * sweep, cutoff G swept over the recalled range, resonance k stepped to 3.8
 * (screaming, near self-oscillation). A resonant recursive filter RECYCLES
 * its quantization error through the feedback path; a gentle test would
 * flatter exactly the failure mode under investigation.
 *
 * Reported: global relative residual dB and worst 1024-sample block dB vs
 * the float reference, the trunk's own thresholds (-100 / -80) quoted for
 * scale. This is a NUMERICAL feasibility probe; instruction pricing is a
 * separate measurement in the design doc.
 */
#include <stdio.h>
#include <stdint.h>
#include <math.h>
#include <string.h>
#include <stdlib.h>

#ifndef M_PI
#define M_PI 3.14159265358979323846
#endif

/* ---------------------------------------------------------------- float ref
 * Verbatim reduction of engine_b/eb_vcf_ladder.c (state + tick, coefficient
 * struct flattened to the values used). Kept in this file so the probe is
 * self-contained evidence; the source of truth remains the module. */
typedef struct {
    float nl, y1, y2, y3, y4, s1, s2, drive_prev, dith;
    float h[32]; int hi;
} FSt;

static float fwrap24(float x)
{
    int v1 = (int)(x * 16777216.0f);
    int v2, v5, v6;
    if (v1 == 0) v2 = 1;
    else {
        int v3 = v1 & 0x200000;
        if ((v1 & 0x800000) != 0) v2 = (v3 == 0) ? 2*v1 : 2*v1 + 1;
        else                      v2 = (v3 != 0) ? 2*v1 : 2*v1 + 1;
    }
    v5 = v2 & 0xFFFFFF; v6 = v2 | (int)0xFF000000;
    if ((v2 & 0x1000000) == 0) v6 = v5;
    return (float)v6 * 5.960464477539063e-08f;
}

/* coefficient values: the shape of a real recalled patch; c9536 is 0.0 in the
 * port and stays 0 here. FIR: the port's half-band-like 16; a representative
 * symmetric set normalised to unit DC gain. */
static const float C9520 = 1.0f, C9184 = -0.16666667f, C9088 = 0.35f,
                   C9104 = 0.6f, C9072 = 0.05f, C9136 = 0.9f, C9120 = 3e-5f,
                   C9168 = 0.12f, C9216 = 0.6667f, C9232 = 0.3333f,
                   C9248 = 0.5f, C9200 = 1.0f, C9152 = 0.25f;
static float FIR[16];

static float ftick(FSt *st, float in, float G, float k)
{
    float A, R, Rk, d, drive, prev, acc;
    float *h = st->h; int hi = st->hi; int j, s;
    d = st->dith;
    drive = (((k * C9168) + 1.0f) * (in * C9136)) + ((-d) * C9120);
    st->dith = fwrap24(-d);
    prev = st->drive_prev; st->drive_prev = drive;
    A = 1.0f - (G + G);
    R = 1.0f / ((((G*G)*(G*G))*k) + 1.0f);
    Rk = R * k;
    for (s = 0; s < 4; ++s) {
        float ins = s==0 ? ((prev*C9216)+(drive*C9232))*R
                  : s==1 ? ((prev+drive)*C9248)*R
                  : s==2 ? ((prev*C9232)+(drive*C9216))*R
                  :        (drive*C9200)*R;
        float x, nl, y1, y2, y3, y4, t, p2, S;
        float xz=st->nl, y1z=st->y1, y2z=st->y2, y3z=st->y3, y4z=st->y4;
        x = ins - (((st->s1 * C9520) + (st->s2 * 0.0f)) * Rk);
        if (x >= -1.0f) { if (x > 1.0f) x = 1.0f; } else x = -1.0f;
        nl = x + ((((x*x)*x)*x)*(x*C9184));
        y1 = (G*(nl+xz)) + (y1z*A);
        t  = G*(y1+y1z);
        p2 = G*(((G*nl)+(A*y1))+y1);
        y2 = t + (y2z*A);
        y3 = (G*(y2+y2z)) + (y3z*A);
        y4 = ((y3z+y3)*G) + (A*y4z);
        S  = (G*(((G*((p2+(A*y2))+y2))+(A*y3))+y3)) + (A*y4);
        st->nl=nl; st->y1=y1; st->y2=y2; st->y3=y3; st->y4=y4;
        st->s2=st->s1; st->s1=S;
        hi = (hi+1)&31;
        h[hi] = ((y3*C9088)+(y4*C9104)) + (C9072*y2);
    }
    st->hi = hi;
    acc = (h[(hi-15)&31] + h[(hi-16)&31]) * FIR[0];
    for (j = 1; j < 16; ++j)
        acc += (h[(hi-(15-j))&31] + h[(hi-(16+j))&31]) * FIR[j];
    return acc * C9152;
}

/* ------------------------------------------------------------ Q fixed point
 * One implementation, parameterised by FRAC bits. Products through int64 then
 * rounded back to Q(FRAC) — the best case for the format; a real Q15 SIMD
 * pipeline could only be WORSE (lane accumulators saturate at 32 bits), so a
 * failure here is conclusive and a pass here is only a licence to prototype
 * further. Coefficients quantised to the same format.
 */
typedef struct {
    int64_t nl, y1, y2, y3, y4, s1, s2, drive_prev;
    float dith;                 /* exact multiples of 2^-24; kept float */
    int64_t h[32]; int hi;
} QSt;

static int FRAC;
static int64_t QC(float v) { return (int64_t)llrintf(v * (float)(1ll << FRAC)); }
static int64_t qmul(int64_t a, int64_t b)
{
    __int128 p = (__int128)a * (__int128)b;
    return (int64_t)((p + ((__int128)1 << (FRAC-1))) >> FRAC);
}

static int64_t qtick(QSt *st, int64_t in, int64_t G, int64_t k, float Rf)
{
    int64_t ONE = (int64_t)1 << FRAC;
    int64_t A, R, Rk, drive, prev, acc; int j, s;
    int64_t d = QC(st->dith);
    int64_t c9168=QC(C9168), c9136=QC(C9136), c9120=QC(C9120);
    drive = qmul(qmul(k, c9168) + ONE, qmul(in, c9136)) + qmul(-d, c9120);
    st->dith = fwrap24(-st->dith);
    prev = st->drive_prev; st->drive_prev = drive;
    A = ONE - 2*G;
    R = QC(Rf);                 /* the reciprocal, quantised like a coef */
    Rk = qmul(R, k);
    for (s = 0; s < 4; ++s) {
        int64_t ins =
            s==0 ? qmul(qmul(prev,QC(C9216)) + qmul(drive,QC(C9232)), R)
          : s==1 ? qmul(qmul(prev + drive, QC(C9248)), R)
          : s==2 ? qmul(qmul(prev,QC(C9232)) + qmul(drive,QC(C9216)), R)
          :        qmul(qmul(drive, QC(C9200)), R);
        int64_t x, nl, y1, y2, y3, y4, t, p2, S;
        int64_t xz=st->nl, y1z=st->y1, y2z=st->y2, y3z=st->y3, y4z=st->y4;
        x = ins - qmul(qmul(st->s1, QC(C9520)), Rk);
        if (x >  ONE) x =  ONE;
        if (x < -ONE) x = -ONE;
        nl = x + qmul(qmul(qmul(qmul(x,x),x),x), qmul(x,QC(C9184)));
        y1 = qmul(G, nl + xz) + qmul(y1z, A);
        t  = qmul(G, y1 + y1z);
        p2 = qmul(G, qmul(G,nl) + qmul(A,y1) + y1);
        y2 = t + qmul(y2z, A);
        y3 = qmul(G, y2 + y2z) + qmul(y3z, A);
        y4 = qmul(y3z + y3, G) + qmul(A, y4z);
        S  = qmul(G, qmul(G, p2 + qmul(A,y2) + y2) + qmul(A,y3) + y3)
           + qmul(A, y4);
        st->nl=nl; st->y1=y1; st->y2=y2; st->y3=y3; st->y4=y4;
        st->s2=st->s1; st->s1=S;
        st->hi = (st->hi+1)&31;
        st->h[st->hi] = qmul(y3,QC(C9088)) + qmul(y4,QC(C9104))
                      + qmul(QC(C9072), y2);
    }
    acc = qmul(st->h[(st->hi-15)&31] + st->h[(st->hi-16)&31], QC(FIR[0]));
    for (j = 1; j < 16; ++j)
        acc += qmul(st->h[(st->hi-(15-j))&31] + st->h[(st->hi-(16+j))&31],
                    QC(FIR[j]));
    return qmul(acc, QC(C9152));
}

int main(int argc, char **argv)
{
    const int N = 480000;               /* 10 s at 48 kHz */
    static FSt fs; static QSt qs;
    double se = 0, sr = 0, bse = 0, bsr = 0, wblk = -999;
    int i, frac;
    /* a plausible normalised symmetric FIR */
    {
        double sum = 0; int j;
        for (j = 0; j < 16; ++j) { FIR[j] = (float)(0.5*(1+cos(M_PI*(15-j+0.5)/16.0))); sum += 2*FIR[j]; }
        for (j = 0; j < 16; ++j) FIR[j] = (float)(FIR[j]/sum);
    }
    frac = argc > 1 ? atoi(argv[1]) : 14;
    FRAC = frac;
    memset(&fs, 0, sizeof fs); fs.hi = 31; fs.dith = 3.0f/16777216.0f;
    memset(&qs, 0, sizeof qs); qs.hi = 31; qs.dith = fs.dith;
    for (i = 0; i < N; ++i) {
        double ph = (double)i / N;
        float in = 0.25f * sinf((float)(2*M_PI*(20.0*i/48000.0 * pow(200.0, ph))));
        float G  = 0.02f + 0.33f * (0.5f + 0.5f*sinf((float)(2*M_PI*0.21*i/48000.0)));
        float k  = 3.8f * (float)ph;
        float Rf = 1.0f / ((((G*G)*(G*G))*k) + 1.0f);
        float yf = ftick(&fs, in, G, k);
        double yq = (double)qtick(&qs, QC(in), QC(G), QC(k), Rf)
                    / (double)(1ll << FRAC);
        double e = (double)yf - yq;
        se += e*e; sr += (double)yf*(double)yf;
        bse += e*e; bsr += (double)yf*(double)yf;
        if ((i & 1023) == 1023) {
            if (bsr > 1e-12) {
                double b = 10*log10(bse/bsr);
                if (b > wblk) wblk = b;
            }
            bse = bsr = 0;
        }
    }
    printf("Q%d: global %7.1f dB rel   worst block %7.1f dB rel   "
           "(trunk gates: -100 / -80)\n",
           frac, 10*log10(se/sr), wblk);
    return 0;
}
