/* sound_test.c — the decisive, faithful sound test.
 *
 * Instead of synthesising a note from scratch (which needs the full control-layer
 * note-on/ramp/voice-allocation transcription), this loads the LIVE PLUGIN'S
 * captured engine state (state_dump/state_t0.bin — the real Roland plugin's 12 MB
 * state while it was actively sounding "PD The Juno Pad" at 96 kHz) and runs our
 * exact DSP transcription FORWARD from there. The oscillators, filter memory and
 * envelope slots are all at their live, sounding values, so the very first sample
 * continues exactly where the plugin was: if our per-sample DSP matches the
 * plugin, real audio comes out.
 *
 * This both (a) gives an audible result and (b) is the per-sample processing
 * validation docs/VALIDATION.md flagged as still-missing — it exercises
 * voice_render + master_render on genuine live state, not a reset engine.
 *
 * Output: a 16-bit stereo WAV per path, plus peak/RMS to stdout.
 *
 *   usage: sound_test <state.bin> <out_prefix> [num_samples]
 */
#include "../src/juno_engine.h"
#include "../src/juno_driver.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

static unsigned char *load_state(const char *path)
{
    FILE *f = fopen(path, "rb");
    if (!f) { perror(path); return NULL; }
    unsigned char *st = malloc(JUNO_STATE_BYTES);
    if (!st) { fclose(f); return NULL; }
    memset(st, 0, JUNO_STATE_BYTES);
    size_t n = fread(st, 1, JUNO_STATE_BYTES, f);
    fclose(f);
    fprintf(stderr, "loaded %zu bytes from %s\n", n, path);
    return st;
}

/* minimal 16-bit PCM stereo WAV writer */
static void write_wav(const char *path, const float *L, const float *R, int n, int sr)
{
    FILE *f = fopen(path, "wb");
    if (!f) { perror(path); return; }
    int data_bytes = n * 2 * 2;          /* stereo, 16-bit */
    int byte_rate  = sr * 2 * 2;
    unsigned int u; unsigned short s;
    fwrite("RIFF", 1, 4, f);
    u = 36 + data_bytes; fwrite(&u, 4, 1, f);
    fwrite("WAVE", 1, 4, f);
    fwrite("fmt ", 1, 4, f);
    u = 16;        fwrite(&u, 4, 1, f);
    s = 1;         fwrite(&s, 2, 1, f);  /* PCM */
    s = 2;         fwrite(&s, 2, 1, f);  /* channels */
    u = sr;        fwrite(&u, 4, 1, f);
    u = byte_rate; fwrite(&u, 4, 1, f);
    s = 4;         fwrite(&s, 2, 1, f);  /* block align */
    s = 16;        fwrite(&s, 2, 1, f);  /* bits */
    fwrite("data", 1, 4, f);
    u = data_bytes; fwrite(&u, 4, 1, f);
    for (int i = 0; i < n; ++i) {
        float l = L[i], r = R[i];
        if (l >  1.0f) l =  1.0f; if (l < -1.0f) l = -1.0f;
        if (r >  1.0f) r =  1.0f; if (r < -1.0f) r = -1.0f;
        short sl = (short)lrintf(l * 32767.0f);
        short sr = (short)lrintf(r * 32767.0f);
        fwrite(&sl, 2, 1, f); fwrite(&sr, 2, 1, f);
    }
    fclose(f);
}

static void stats(const char *tag, const float *L, const float *R, int n)
{
    double sum = 0.0; float peak = 0.0f; int nonfinite = 0;
    for (int i = 0; i < n; ++i) {
        float l = L[i], r = R[i];
        if (!isfinite(l) || !isfinite(r)) { nonfinite++; continue; }
        sum += (double)l * l + (double)r * r;
        if (fabsf(l) > peak) peak = fabsf(l);
        if (fabsf(r) > peak) peak = fabsf(r);
    }
    double rms = sqrt(sum / (2.0 * n));
    printf("  %-12s peak=%.6g  rms=%.6g  (%.1f dBFS)  nonfinite=%d\n",
           tag, peak, rms, 20.0 * log10(rms > 0 ? rms : 1e-30), nonfinite);
}

int main(int argc, char **argv)
{
    if (argc < 3) {
        fprintf(stderr, "usage: %s <state.bin> <out_prefix> [num_samples]\n", argv[0]);
        return 2;
    }
    const char *state_path = argv[1];
    const char *prefix     = argv[2];
    int N = (argc > 3) ? atoi(argv[3]) : 96000;   /* 1 s at 96 kHz */
    const int SR = 96000;

    float *L = malloc(sizeof(float) * N);
    float *R = malloc(sizeof(float) * N);
    if (!L || !R) return 1;
    char path[512];

    /* ---- Path A: dry voice 0, straight from live state ---- */
    {
        unsigned char *st = load_state(state_path);
        if (!st) return 1;
        for (int i = 0; i < N; ++i) {
            float l = 0.0f, r = 0.0f;
            juno_voice_render(st, &l, &r);
            L[i] = l; R[i] = r;
        }
        printf("Path A — dry voice 0 (no chorus), from live state:\n");
        stats("voice0", L, R, N);
        snprintf(path, sizeof path, "%s_dry.wav", prefix);
        write_wav(path, L, R, N, SR);
        printf("  wrote %s\n", path);
        free(st);
    }

    /* ---- Path B: full master/chorus path, from live state ---- */
    {
        unsigned char *st = load_state(state_path);
        if (!st) return 1;
        static struct juno_host_shim shim;
        memset(&shim, 0, sizeof shim);
        /* PD The Juno Pad uses chorus II; the master reads the mode through the
         * pointer chase off state+136. Re-attach our shim (the dump's pointer
         * points into the dead plugin's address space). */
        juno_driver_attach_host(st, &shim, 2);
        int ran_master = 0;
        for (int i = 0; i < N; ++i) {
            float l = 0.0f, r = 0.0f;
            ran_master = juno_driver_render_sample(st, &l, &r);
            L[i] = l; R[i] = r;
        }
        printf("Path B — full master/chorus path (ran_master=%d):\n", ran_master);
        stats("masterLR", L, R, N);
        snprintf(path, sizeof path, "%s_master.wav", prefix);
        write_wav(path, L, R, N, SR);
        printf("  wrote %s\n", path);
        free(st);
    }

    free(L); free(R);
    return 0;
}
