/* wav_compare.c — audio A/B: compare the port's note against a plugin bounce.
 *
 * Sample-exact equality is not the bar (note-on phase/timing differ between hosts);
 * a faithful transcription matches in the ways that define the sound:
 *   1. ENVELOPE  — per-window RMS contour (attack / sustain / release timing+shape)
 *   2. PITCH     — fundamental frequency at sustain (autocorrelation)
 *   3. TIMBRE    — normalized magnitude spectrum at sustain (filter + harmonic shape),
 *                  reported as spectral centroid and a cosine similarity vs the ref.
 *
 * Both inputs must be 16-bit PCM WAV (any sample rate; mono or stereo -> L used).
 *   usage: wav_compare <reference_plugin.wav> <port.wav>
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#ifndef M_PI
#define M_PI 3.14159265358979323846
#endif

typedef struct { float *x; int n; int sr; } Sig;

static int load_wav(const char *path, Sig *s)
{
    FILE *f = fopen(path, "rb"); if (!f) { perror(path); return 0; }
    unsigned char h[44];
    if (fread(h,1,44,f)!=44) { fclose(f); return 0; }
    int ch = h[22] | (h[23]<<8);
    int sr = h[24]|(h[25]<<8)|(h[26]<<16)|(h[27]<<24);
    int bits = h[34]|(h[35]<<8);
    /* find 'data' chunk (h[36..39] usually "data") */
    long data_bytes = h[40]|(h[41]<<8)|(h[42]<<16)|((long)h[43]<<24);
    if (memcmp(h+36,"data",4)!=0) { /* re-scan from 12 for fmt/data */
        fseek(f,12,SEEK_SET); unsigned char c[8];
        while (fread(c,1,8,f)==8) {
            long sz = c[4]|(c[5]<<8)|(c[6]<<16)|((long)c[7]<<24);
            if (memcmp(c,"data",4)==0) { data_bytes = sz; break; }
            fseek(f,sz,SEEK_CUR);
        }
    }
    if (bits != 16) { fprintf(stderr,"%s: need 16-bit PCM (got %d)\n",path,bits); fclose(f); return 0; }
    int frames = (int)(data_bytes / (2*ch));
    s->x = malloc(sizeof(float)*frames); s->n = frames; s->sr = sr;
    for (int i=0;i<frames;i++){
        short v; if (fread(&v,2,1,f)!=1){ s->n=i; break; }
        s->x[i] = v/32768.0f;
        for (int c=1;c<ch;c++){ short d; if(fread(&d,2,1,f)!=1) break; }   /* drop R */
    }
    fclose(f);
    return 1;
}

static double rms(const float *x,int a,int b){ double s=0; for(int i=a;i<b;i++) s+=(double)x[i]*x[i]; return sqrt(s/(b-a>0?b-a:1)); }

/* fundamental via autocorrelation over [a,b) */
static double pitch_hz(const float *x,int a,int b,int sr){
    int maxlag = sr/50, minlag = sr/1500;   /* 50..1500 Hz */
    double best=-1; int bl=0;
    for (int lag=minlag; lag<maxlag; ++lag){
        double s=0; for(int i=a;i+lag<b;i++) s+=(double)x[i]*x[i+lag];
        if (s>best){ best=s; bl=lag; }
    }
    return bl>0 ? (double)sr/bl : 0;
}

/* naive DFT magnitude over [a,a+N), N power of two-ish; returns centroid + fills mag[] */
static double spectrum(const float *x,int a,int N,int sr,double *mag,int bins){
    double num=0,den=0;
    for (int k=0;k<bins;k++){
        double re=0,im=0; double w=2*M_PI*k/N;
        for (int n=0;n<N;n++){ double s=x[a+n]*(0.5-0.5*cos(2*M_PI*n/N)); re+=s*cos(w*n); im-=s*sin(w*n); }
        double m=sqrt(re*re+im*im); mag[k]=m;
        double hz=(double)k*sr/N; num+=hz*m; den+=m;
    }
    return den>0?num/den:0;
}

int main(int argc,char**argv){
    if (argc<3){ printf("usage: %s reference_plugin.wav port.wav\n",argv[0]); return 2; }
    Sig ref,prt;
    if (!load_wav(argv[1],&ref)||!load_wav(argv[2],&prt)) return 1;
    printf("ref: %d frames @ %d Hz (%.2fs)   port: %d frames @ %d Hz (%.2fs)\n",
           ref.n,ref.sr,(double)ref.n/ref.sr, prt.n,prt.sr,(double)prt.n/prt.sr);

    /* 1. envelope contour, 50 ms windows, peak-normalized */
    double wsec=0.05; int wr=(int)(wsec*ref.sr), wp=(int)(wsec*prt.sr);
    double pr=0,pp=0; for(int i=0;i<ref.n;i++) if(fabsf(ref.x[i])>pr) pr=fabsf(ref.x[i]);
    for(int i=0;i<prt.n;i++) if(fabsf(prt.x[i])>pp) pp=fabsf(prt.x[i]);
    printf("\nenvelope (50ms windows, dB below each file's peak):\n  t(s)   ref    port\n");
    for (double t=0; t< fmin((double)ref.n/ref.sr,(double)prt.n/prt.sr); t+=0.25){
        int ar=(int)(t*ref.sr), ap=(int)(t*prt.sr);
        double rr=rms(ref.x,ar,ar+wr)/ (pr>0?pr:1), rp=rms(prt.x,ap,ap+wp)/(pp>0?pp:1);
        printf("  %4.2f  %6.1f %6.1f\n", t, 20*log10(rr+1e-9), 20*log10(rp+1e-9));
    }

    /* 2 + 3 at sustain (35% into each file) */
    int sr_a=(int)(ref.n*0.35), sp_a=(int)(prt.n*0.35);
    double fr=pitch_hz(ref.x,sr_a,sr_a+ref.sr/4,ref.sr);
    double fp=pitch_hz(prt.x,sp_a,sp_a+prt.sr/4,prt.sr);
    printf("\npitch @ sustain: ref=%.2f Hz  port=%.2f Hz  (ratio %.4f, %.2f semitones)\n",
           fr,fp, fp>0?fr/fp:0, fr>0&&fp>0?12*log2(fp/fr):0);

    int N=4096, bins=N/2;
    double *mr=malloc(sizeof(double)*bins), *mp=malloc(sizeof(double)*bins);
    double cr = (sr_a+N<ref.n)? spectrum(ref.x,sr_a,N,ref.sr,mr,bins):0;
    double cp = (sp_a+N<prt.n)? spectrum(prt.x,sp_a,N,prt.sr,mp,bins):0;
    /* cosine similarity of magnitude spectra (resampled to common bins by index) */
    double dot=0,nr=0,np=0; for(int k=0;k<bins;k++){ dot+=mr[k]*mp[k]; nr+=mr[k]*mr[k]; np+=mp[k]*mp[k]; }
    double cos = (nr>0&&np>0)? dot/(sqrt(nr)*sqrt(np)) : 0;
    printf("spectral centroid: ref=%.0f Hz  port=%.0f Hz\n", cr, cp);
    printf("magnitude-spectrum cosine similarity: %.4f  (1.0 = identical timbre)\n", cos);
    printf("\nNOTE: pitch ratio reveals the MIDI-note->4448 mapping; match it, then\n"
           "centroid+cosine judge the filter/harmonic transcription.\n");
    return 0;
}
