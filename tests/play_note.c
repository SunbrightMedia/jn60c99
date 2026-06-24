/* play_note.c — play an actual note through the full engine and write a WAV.
 *
 * Fresh init (chorus_init + engine_init + captured patch coefficients), then a
 * note: hold the gate, let voice_render generate the LFO + both ADSRs + the
 * filter sweep internally, run the stereo BBD chorus, and write the output. This
 * is the faithful audible test — every sample comes from the transcribed DSP and
 * the only host action is setting the note gate the way the plugin's host does.
 *
 *   usage: play_note <out.wav> [seconds] [release_seconds]
 */
#include "../src/juno_engine.h"
#include "../src/juno_driver.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

static void write_wav(const char *path, const float *L, const float *R, int n, int sr)
{
    FILE *f = fopen(path, "wb");
    if (!f) { perror(path); return; }
    int data_bytes = n * 2 * 2, byte_rate = sr * 2 * 2;
    unsigned int u; unsigned short s;
    fwrite("RIFF", 1, 4, f); u = 36 + data_bytes; fwrite(&u, 4, 1, f);
    fwrite("WAVE", 1, 4, f); fwrite("fmt ", 1, 4, f);
    u = 16; fwrite(&u, 4, 1, f); s = 1; fwrite(&s, 2, 1, f); s = 2; fwrite(&s, 2, 1, f);
    u = sr; fwrite(&u, 4, 1, f); u = byte_rate; fwrite(&u, 4, 1, f);
    s = 4; fwrite(&s, 2, 1, f); s = 16; fwrite(&s, 2, 1, f);
    fwrite("data", 1, 4, f); u = data_bytes; fwrite(&u, 4, 1, f);
    for (int i = 0; i < n; ++i) {
        float l = L[i], r = R[i];
        if (l >  1.0f) l =  1.0f; if (l < -1.0f) l = -1.0f;
        if (r >  1.0f) r =  1.0f; if (r < -1.0f) r = -1.0f;
        short sl = (short)lrintf(l * 32767.0f), sr = (short)lrintf(r * 32767.0f);
        fwrite(&sl, 2, 1, f); fwrite(&sr, 2, 1, f);
    }
    fclose(f);
}

int main(int argc, char **argv)
{
    const char *out = (argc > 1) ? argv[1] : "/tmp/juno_note.wav";
    const int SR = 96000;
    double hold_s    = (argc > 2) ? atof(argv[2]) : 4.0;
    double release_s = (argc > 3) ? atof(argv[3]) : 1.5;
    int n_hold = (int)(hold_s * SR), n_rel = (int)(release_s * SR), N = n_hold + n_rel;

    unsigned char *st = malloc(JUNO_STATE_BYTES);
    if (!st) return 1;
    memset(st, 0, JUNO_STATE_BYTES);
    juno_chorus_init(st);
    juno_engine_init(st);
    juno_runtime_coeffs_apply(st);

    static struct juno_host_shim shim;
    memset(&shim, 0, sizeof shim);
    juno_driver_attach_host(st, &shim, 2);          /* chorus II */

    float *L = malloc(sizeof(float) * N), *R = malloc(sizeof(float) * N);
    if (!L || !R) return 1;

    printf("patch pitch (oct) = %.4f ; LPF cutoff = %.4f ; LFO rate = %.4f\n",
           JF(st, 4448), JF(st, 6736), JF(st, 1088));

    juno_note_on(st, 0);
    int ran_master = 0;
    double sum = 0; float peak = 0;
    for (int i = 0; i < N; ++i) {
        if (i == n_hold) juno_note_off(st, 0);      /* release */
        float l = 0, r = 0;
        ran_master = juno_driver_render_sample(st, &l, &r);
        L[i] = l; R[i] = r;
        sum += (double)l * l + (double)r * r;
        if (fabsf(l) > peak) peak = fabsf(l);
        if (fabsf(r) > peak) peak = fabsf(r);
    }
    double rms = sqrt(sum / (2.0 * N));
    printf("played %.1fs (hold %.1fs + release %.1fs) ; master_path=%d\n",
           (double)N / SR, hold_s, release_s, ran_master);
    printf("peak=%.5g  rms=%.5g (%.1f dBFS)\n", peak, rms, 20.0 * log10(rms + 1e-30));
    write_wav(out, L, R, N, SR);
    printf("wrote %s\n", out);
    free(L); free(R); free(st);
    return 0;
}
