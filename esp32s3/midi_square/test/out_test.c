/* SPEAKER-SAFE OUTPUT GATE (user 2026-10-01: "not a SINGLE SOUND can distort").
 * Built 32-bit with the real FX stage (test/run.sh). Steps:
 *  1. THE USER'S DATA, MEASURED: replay the v10 chain (voice -> FX dry -> v10
 *     knob law) at the user's distortion points (C4, no FX: sine 75 %, tri
 *     79 %, saw 88 %, square 89 %) and take each wave's DAC peak there.
 *  2. Single notes through the NEW chain at FULL volume: every wave must stay
 *     >= 1.9 dB under its own distortion point, and the limiter must not act.
 *  3. Worst case: 6 notes (C2..A4), 7-osc unison, saw>square morph, chorus and
 *     reverb 255, the startup clip on top, full volume: no sample above
 *     OUT_CEIL, safety clip never used.
 *  4. Volume 0 sends exact zeros.
 * Tooth: -DMSQ_TOOTH_NO_LIMIT must FAIL step 3. */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include "msq_core.h"
#include "fx.h"
#include "outstage.h"
extern const unsigned msq_fx_state_bytes;
static int fails;
#define CHECK(c, ...) do { if (!(c)) { printf("FAIL: " __VA_ARGS__); printf("\n"); fails++; } } while (0)
static void *fxmem;

static float v10_law(float v) { return v <= 0.01f ? 0.0f : powf(10.0f, -48.0f * (1.0f - v) / 20.0f); }

/* one note, 1.5 s; returns the DAC peak after 0.5 s (attack done) */
static int note_peak(int wave, int chain_new, float knob, outstage_stats *st)
{
    static msq_t m; msq_init(&m, 48000); msq_set_wave(&m, (float)wave);
    fx_init(fxmem); fx_set_chorus(0); fx_set_reverb(0);
    msq_byte(&m, 0x90); msq_byte(&m, 60); msq_byte(&m, 100);
    outstage_t o; outstage_init(&o, 48000); o.vol_now = outstage_vol_law(knob);
    float b[240]; int16_t lr[480], out[480]; int pk = 0;
    for (int k = 0; k < 300; ++k) {
        msq_render_f(&m, b, 240); fx_process(b, lr, 240);
        if (chain_new) outstage_block(&o, lr, NULL, 240, outstage_vol_law(knob), out, st);
        else for (int i = 0; i < 480; ++i) { float x = lr[i] * v10_law(knob); out[i] = (int16_t)(x >= 0 ? x + 0.5f : x - 0.5f); }
        if (k >= 100) for (int i = 0; i < 480; ++i) { int a = abs(out[i]); if (a > pk) pk = a; }
    }
    return pk;
}

int main(int argc, char **argv)
{
    fxmem = malloc(msq_fx_state_bytes);
    static const char *NAME[4] = { "sine", "triangle", "saw", "square" };
    static const float USER_KNOB[4] = { 0.75f, 0.79f, 0.88f, 0.89f };   /* the user's distortion points (v10) */
    printf("wave      distorts at (v10)   new full-volume peak   margin   limiter\n");
    int thr_min = 1 << 30;
    for (int w = 0; w < 4; ++w) {
        outstage_stats d = { 0, 1.0f, 0 };
        int thr = note_peak(w, 0, USER_KNOB[w], &d);
        if (thr < thr_min) thr_min = thr;
        outstage_stats st = { 0, 1.0f, 0 };
        int pk = note_peak(w, 1, 1.0f, &st);
        float margin = 20.0f * log10f((float)thr / pk);
        printf("%-9s %4.0f%% = peak %4d     %4d                 %4.1f dB  %s\n", NAME[w], USER_KNOB[w] * 100, thr, pk,
               margin, st.min_gain == 1.0f ? "untouched" : "ACTED");
        CHECK(margin >= 1.9f, "%s at full volume is only %.1f dB under its distortion point", NAME[w], margin);
        CHECK(st.min_gain == 1.0f, "%s: the limiter acted on a single note", NAME[w]);
    }
    CHECK(fabsf(20.0f * log10f(thr_min / OUT_CEIL) - 1.0f) < 0.1f,
          "OUT_CEIL %.0f is not 1 dB under the measured worst distortion point %d", OUT_CEIL, thr_min);

    /* worst case: chord + unison + morph + chorus + reverb + the startup clip, full volume */
    {
        static msq_t m; msq_init(&m, 48000); msq_set_wave(&m, 2.5f); msq_set_unison(&m, 1.0f);
        fx_init(fxmem); fx_set_chorus(255); fx_set_reverb(255);
        static const uint8_t N[6] = { 36, 48, 55, 60, 64, 69 };
        for (int k = 0; k < 6; ++k) { msq_byte(&m, 0x90); msq_byte(&m, N[k]); msq_byte(&m, 127); }
        FILE *cf = fopen("main/snd/startup_48k_s16le.raw", "rb");
        static int16_t clip[48000 * 3 * 2]; int nclip = cf ? (int)fread(clip, 4, 48000 * 3, cf) : 0; if (cf) fclose(cf);
        CHECK(nclip > 48000, "startup clip not found (%d frames)", nclip);
        outstage_t o; outstage_init(&o, 48000); o.vol_now = 1.0f;
        outstage_stats st = { 0, 1.0f, 0 };
        float b[240]; int16_t lr[480], out[480];
        for (int k = 0; k < 600; ++k) {                    /* 3 s */
            msq_render_f(&m, b, 240); fx_process(b, lr, 240);
            const int16_t *cp = (k + 1) * 240 <= nclip ? clip + 2 * 240 * k : NULL;
            outstage_block(&o, lr, cp, 240, 1.0f, out, &st);
        }
        printf("worst case (6 notes C2-A4, 7-osc unison, morph, chorus+reverb 255, startup clip, full volume):\n"
               "  peak %d (ceiling %.0f), limiter down to %.1f dB, safety clip used %d times\n",
               st.peak, OUT_CEIL, 20.0f * log10f(st.min_gain), st.hard);
        CHECK(st.peak <= (int)OUT_CEIL && st.hard == 0, "worst case: peak %d over the ceiling %.0f, safety clip %d", st.peak, OUT_CEIL, st.hard);
    }
    /* the startup clip alone, full volume: how loud, how much limiting */
    {
        FILE *cf = fopen("main/snd/startup_48k_s16le.raw", "rb");
        static int16_t clip[48000 * 3 * 2], zero[480]; int nclip = cf ? (int)fread(clip, 4, 48000 * 3, cf) : 0; if (cf) fclose(cf);
        outstage_t o; outstage_init(&o, 48000); o.vol_now = 1.0f;
        outstage_stats st = { 0, 1.0f, 0 };
        int16_t out[480]; double win = 0, best = 0; int wn = 0;
        for (int k = 0; (k + 1) * 240 <= nclip; ++k) {
            outstage_block(&o, zero, clip + 2 * 240 * k, 240, 1.0f, out, &st);
            for (int i = 0; i < 480; ++i) win += (double)out[i] * out[i];
            if (++wn == 10) { double r = sqrt(win / 4800); if (r > best) best = r; win = 0; wn = 0; }
        }
        printf("startup clip at full volume: peak %d, loudest 50 ms RMS %.0f (one sine note: %.0f), limiter down to %.1f dB\n",
               st.peak, best, OUT_KNEE / sqrtf(2.0f), 20.0f * log10f(st.min_gain));
        CHECK(st.peak <= (int)OUT_CEIL && st.hard == 0, "startup clip over the ceiling");
    }
    /* volume 0 = exact zeros */
    {
        outstage_t o; outstage_init(&o, 48000);
        outstage_stats st = { 0, 1.0f, 0 };
        int16_t in[480], out[480];
        for (int i = 0; i < 480; ++i) in[i] = (int16_t)(i * 97 % 4000 - 2000);
        outstage_block(&o, in, in, 240, 0.0f, out, &st);
        outstage_block(&o, in, in, 240, outstage_vol_law(0.0f), out, &st);
        CHECK(st.peak == 0, "volume 0 is not silent (peak %d)", st.peak);
    }
    printf("%s: %d failure(s)\n", fails ? "OUTPUT GATE FAIL" : "OUTPUT GATE PASS", fails);
    return fails != 0;
}
