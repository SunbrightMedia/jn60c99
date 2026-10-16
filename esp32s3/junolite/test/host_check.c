/* host_check.c -- JUNO LITE on the host: renders the demo (all presets) to a WAV
 * and checks it (finite, never clips, every preset sounds, 6 voices sound, silent
 * after release); then the DCO aliasing of a 2.2 kHz saw by DFT.
 * Usage: host_check [out.wav]. Exit 0 = pass. Build with -DJL_TOOTH_NOMIP: must FAIL. */
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include "../main/jl_synth.h"
#include "../main/jl_demo.h"
static int fails;
#define CHECK(c, ...) do { if (!(c)) { printf("FAIL "); printf(__VA_ARGS__); printf("\n"); ++fails; } } while (0)

int main(int argc, char **argv)
{
    jl_init();
    long nb = (long)JL_DEMO_PRESET_BLOCKS * jl_npresets;
    int16_t *w = malloc(nb * JL_BLOCK * 4);
    int peak[8] = { 0 }, maxv[8] = { 0 }, tailpk = 0, hard = 0;
    for (long t = 0; t < nb; ++t) {
        int pr = jl_demo_step(t), b = (int)(t % JL_DEMO_PRESET_BLOCKS);
        int16_t *o = w + t * JL_BLOCK * 2;
        jl_render(o);
        if (jl_active() > maxv[pr]) maxv[pr] = jl_active();
        for (int i = 0; i < 2 * JL_BLOCK; ++i) {
            int a = abs(o[i]);
            if (a > peak[pr]) peak[pr] = a;
            if (a >= 16000) ++hard;
            if (b > JL_DEMO_PRESET_BLOCKS - 30 && a > tailpk) tailpk = a;   /* last ~45 ms of each preset */
        }
    }
    for (int p = 0; p < jl_npresets; ++p) {
        printf("%-8s peak %5d (%.1f dBFS)  max voices %d\n", jl_presets[p].name, peak[p], 20 * log10(peak[p] / 32768.0), maxv[p]);
        CHECK(peak[p] > 1000, "%s silent", jl_presets[p].name);
        CHECK(maxv[p] == 6, "%s: %d voices, want 6", jl_presets[p].name, maxv[p]);
    }
    printf("end-of-preset tail peak %d, samples at the clip ceiling %d\n", tailpk, hard);
    CHECK(hard == 0, "output reached the soft-clip ceiling");
    CHECK(tailpk <= 2, "not silent after release (tail peak %d)", tailpk);
    if (argc > 1) {
        FILE *f = fopen(argv[1], "wb"); uint32_t d = nb * JL_BLOCK * 4, v; uint16_t h[2];
        fwrite("RIFF", 1, 4, f); v = 36 + d; fwrite(&v, 4, 1, f); fwrite("WAVEfmt ", 1, 8, f);
        v = 16; fwrite(&v, 4, 1, f); h[0] = 1; h[1] = 2; fwrite(h, 2, 2, f);
        v = JL_SR; fwrite(&v, 4, 1, f); v = JL_SR * 4; fwrite(&v, 4, 1, f);
        h[0] = 4; h[1] = 16; fwrite(h, 2, 2, f); fwrite("data", 1, 4, f); fwrite(&d, 4, 1, f);
        fwrite(w, 1, d, f); fclose(f);
    }
    /* aliasing: one saw voice, filter open, no FX; note 97 = 2217 Hz */
    jl_patch a = { .name = "alias", .saw = 1, .cutoff = 1, .level = 1, .s = 1, .a = 0, .d = 0, .r = 0 };
    jl_set_patch(&a); jl_all_off();
    for (int i = 0; i < 2000; ++i) jl_render(w);                /* let everything die */
    jl_note_on(97, 100);
    enum { N = 8192 };
    static float x[N]; int16_t blk[2 * JL_BLOCK];
    for (int i = 0; i < 100; ++i) jl_render(blk);               /* settle */
    for (int n = 0; n < N; n += JL_BLOCK) { jl_render(blk); for (int i = 0; i < JL_BLOCK; ++i) x[n + i] = blk[2 * i]; }
    double f0 = 440 * pow(2, (97 - 69) / 12.0), ph = 0, sig = 0, noi = 0;
    for (int k = 1; k < N / 2; ++k) {                           /* Blackman-Harris DFT */
        double re = 0, im = 0;
        for (int n = 0; n < N; ++n) {
            double wn = 0.35875 - 0.48829 * cos(2 * M_PI * n / N) + 0.14128 * cos(4 * M_PI * n / N) - 0.01168 * cos(6 * M_PI * n / N);
            ph = 2 * M_PI * k * n / N; re += x[n] * wn * cos(ph); im -= x[n] * wn * sin(ph);
        }
        double fk = (double)k * JL_SR / N, pw = re * re + im * im, hn = fk / f0, d = fabs(hn - floor(hn + 0.5)) * f0;
        if (d <= 5.0 * JL_SR / N) sig += pw; else noi += pw;
    }
    double snr = 10 * log10(sig / noi);
    printf("saw 2217 Hz aliasing SNR %.1f dB (want >= 30; naive saw ~12)\n", snr);
    CHECK(snr >= 30, "aliasing SNR %.1f", snr);
    printf(fails ? "HOST CHECK FAIL (%d)\n" : "HOST CHECK PASS\n", fails);
    return fails != 0;
}
