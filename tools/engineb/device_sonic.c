/* device_sonic.c — RENDER THE FORK UNDER THE DEVICE'S OWN CONDITIONS.
 *
 * WHY THIS EXISTS. Every gate in this repo renders engine B through
 * engine_b/shim/standalone/juno_driver.c, which contains:
 *
 *     for (v = 0; v < JUNO_NUM_VOICES; ++v) EBE.v[v].atrest = 0;
 *
 * -- every voice held awake. The DEVICE does the opposite: it sets atrest from
 * a wake mask (esp32s3/main/juno_s3_listen.c), and no mask but 0xff has bit 0
 * set. So the certified fork and the shipping firmware differ in a flag, and on
 * 2026-08-11 that difference turned out to hide a defect that silenced the
 * entire instrument's LFO below eight-note polyphony
 * (docs/engineb/data/lfo_dead.md).
 *
 * A gate that cannot be configured like the device cannot see what the device
 * does. This probe closes that hole: it drives engine B from the FIRMWARE'S OWN
 * coefficient blob, at the FIRMWARE'S OWN wake masks, so the thing measured is
 * the thing that ships.
 *
 * WHAT IT REPORTS, and why these two numbers rather than a null:
 *
 *   RESIDUAL   this build against a reference render, in dB. Answers "did the
 *              audio change at all". A correctness fix that moves nothing has
 *              fixed nothing, and that is not detectable by reading code.
 *
 *   MODDEPTH   the spread of windowed RMS across the note, in dB. This is the
 *              LFO detector. An unmodulated voice holds a near-constant
 *              envelope through its sustain; vibrato, PWM sweep and filter
 *              modulation all make it breathe. A build with a dead LFO reports
 *              a small number here no matter how correct its arithmetic looks.
 *
 * MODDEPTH IS A DETECTOR, NOT A GATE. It cannot prove the modulation is the
 * RIGHT modulation -- only that modulation exists. The audible standard remains
 * tools/engineb/sonic_gate.py plus the user's ear on the WAVs. This answers the
 * narrower question the gates structurally cannot: is the device's own
 * configuration producing a moving signal.
 *
 * Build it twice at different flags and diff the report. See device_sonic.sh.
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include "eb_engine.h"
#include "eb_render.h"
#include "s3_listen_meta.h"

#define SR   44100
#define NSA  (SR * 2)          /* two seconds: the blob's hold is 1.5 s */
#define WIN  2048              /* ~46 ms -- short against a slow LFO, long
                                * against the audio period, so the window RMS
                                * follows the modulation and not the waveform */

static eb_engine        EBE;
static eb_render_coefs  RC;
static eb_render_state *RS;
static unsigned char   *BLOB;
static const unsigned char *B_COEF;

static void load_coefs(int chord, int gate)
{
    const unsigned char *p = B_COEF + ((size_t)chord * 2u + (size_t)gate)
        * (S3L_COEF_SZ + S3L_MCOEF_SZ + S3L_VOICE_SZ);
    memcpy(&RC, p, S3L_COEF_SZ);
    memcpy(RS, p + S3L_COEF_SZ + S3L_MCOEF_SZ, S3L_VOICE_SZ);
}

/* Render one chord at the DEVICE's wake mask, summing the voice bus the way
 * the firmware's NOFX path does. voice indices outside the mask are at rest,
 * exactly as on the board. */
static void render(int chord, float *out)
{
    unsigned wake = S3L_MASK[chord];
    float vb[EB_NUM_VOICES];
    int i, v;

    eb_engine_init(&EBE, (float)SR);
    EBE.render_ok = 1;
    load_coefs(chord, 0);
    for (v = 0; v < EB_NUM_VOICES; ++v)
        EBE.v[v].atrest = !((wake >> v) & 1u);

    for (i = 0; i < NSA; ++i) {
        float s = 0.0f;
        for (v = 0; v < EB_NUM_VOICES; ++v) vb[v] = 0.0f;
        eb_engine_render_voices(&EBE, RS, &RC, (const eb_render_needs *)0, vb);
        for (v = 0; v < EB_NUM_VOICES; ++v) s += vb[v];
        out[i] = s;
    }
}

/* THE LFO SPAN -- the detector that actually works, and the one this file got
 * wrong on its first attempt.
 *
 * eb_lfo_tick returns THREE outputs: the delayed one (its return value), the
 * undelayed one and the pulse. The first version of this probe watched only
 * the delayed output and reported it flat at zero even with voice 0 awake --
 * which read like "the LFO does nothing" and was instead "you are watching the
 * wrong wire". For this blob's patch the delayed output is zero BY
 * CONSTRUCTION: eb_lfo.c's own comment records k2096 == 0 and k2112 == 0, so
 * that path carries nothing. The modulation is on the other two.
 *
 * Watching one of three outputs and concluding the LFO is dead is the same
 * mistake as the bug being hunted -- a measurement that cannot see its
 * subject. Report all three. */
static void lfo_spans(int chord, double *d, double *u, double *p)
{
    unsigned wake = S3L_MASK[chord];
    double lo[3] = { 1e30, 1e30, 1e30 }, hi[3] = { -1e30, -1e30, -1e30 };
    eb_shared_tick sh;
    int i, v;
    eb_engine_init(&EBE, (float)SR);
    EBE.render_ok = 1;
    load_coefs(chord, 0);
    for (v = 0; v < EB_NUM_VOICES; ++v)
        EBE.v[v].atrest = !((wake >> v) & 1u);
    for (i = 0; i < SR; ++i) {
        float o[3];
        sh.ready = 0;
        eb_engine_render_shared(&EBE, RS, &RC, &sh);
        o[0] = sh.lfo_del; o[1] = sh.lfo_und; o[2] = sh.lfo_pul;
        for (v = 0; v < 3; ++v) {
            if (o[v] < lo[v]) lo[v] = o[v];
            if (o[v] > hi[v]) hi[v] = o[v];
        }
    }
    *d = hi[0] - lo[0]; *u = hi[1] - lo[1]; *p = hi[2] - lo[2];
}

/* Spread of windowed RMS, in dB, over the windows that carry signal. Windows
 * below -60 dBFS are skipped so the release tail cannot masquerade as
 * modulation -- a decaying note is not a modulated one. */
static double moddepth(const float *x)
{
    double lo = 1e30, hi = 0.0;
    int w;
    for (w = 0; w + WIN <= NSA; w += WIN) {
        double s = 0.0;
        int i;
        for (i = 0; i < WIN; ++i) s += (double)x[w + i] * x[w + i];
        s = sqrt(s / WIN);
        if (s < 1e-3) continue;
        if (s < lo) lo = s;
        if (s > hi) hi = s;
    }
    if (hi <= 0.0 || lo >= 1e30) return 0.0;
    return 20.0 * log10(hi / lo);
}

static double rms(const float *x)
{
    double s = 0.0; int i;
    for (i = 0; i < NSA; ++i) s += (double)x[i] * x[i];
    return sqrt(s / NSA);
}

int main(int argc, char **argv)
{
    static float cur[NSA], ref[NSA];
    const char *refpath = (argc > 1) ? argv[1] : NULL;
    const char *outpath = (argc > 2) ? argv[2] : NULL;
    FILE *f;
    long n;
    int chord;
    float *store = NULL;

    f = fopen("/home/user/jn60c99/esp32s3/main/s3_listen.bin", "rb");
    if (!f) { fprintf(stderr, "no blob\n"); return 2; }
    fseek(f, 0, SEEK_END); n = ftell(f); fseek(f, 0, SEEK_SET);
    BLOB = malloc((size_t)n);
    if (fread(BLOB, 1, (size_t)n, f) != (size_t)n) return 2;
    fclose(f);
    B_COEF = BLOB + 32 + S3L_RSTATE_SZ + S3L_MSTATE_SZ;
    RS = malloc(sizeof *RS);

    if (outpath) store = malloc((size_t)S3L_NNOTE * NSA * sizeof(float));

    printf("EB_LFO_SHARED=%d EB_LFO_FREERUN=%d   (device wake masks, NOFX bus)\n",
           EB_LFO_SHARED, EB_LFO_FREERUN);
    printf("%-6s %-6s %10s %8s %8s %8s %8s  %s\n",
           "chord", "wake", "rms", "moddep", "lfo_del", "lfo_und", "lfo_pul",
           "residual vs ref");

    f = refpath ? fopen(refpath, "rb") : NULL;

    for (chord = 0; chord < S3L_NNOTE; ++chord) {
        double md, r;
        char res[40];
        render(chord, cur);
        md = moddepth(cur);
        r  = rms(cur);
        strcpy(res, "--");
        if (f && fread(ref, sizeof(float), NSA, f) == (size_t)NSA) {
            double s = 0.0, q = 0.0; int i, nd = 0;
            for (i = 0; i < NSA; ++i) {
                double d = (double)cur[i] - ref[i];
                s += d * d; q += (double)ref[i] * ref[i];
                if (cur[i] != ref[i]) ++nd;
            }
            if (!nd)            strcpy(res, "EXACTLY 0");
            else if (q > 0.0)   snprintf(res, sizeof res, "%.1f dB (%d/%d)",
                                         10.0 * log10(s / q), nd, NSA);
        }
        if (store) memcpy(store + (size_t)chord * NSA, cur, sizeof cur);
        {   double ld, lu, lp;
            lfo_spans(chord, &ld, &lu, &lp);
            printf("%-6d 0x%02x   %10.3e %8.2f %8.4f %8.4f %8.4f  %s\n",
                   chord + 1, S3L_MASK[chord], r, md, ld, lu, lp, res);
        }
    }
    if (f) fclose(f);
    if (store) {
        FILE *o = fopen(outpath, "wb");
        if (o) { fwrite(store, sizeof(float), (size_t)S3L_NNOTE * NSA, o); fclose(o); }
    }
    return 0;
}
