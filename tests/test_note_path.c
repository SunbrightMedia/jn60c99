/* test_note_path.c — regression guard for the faithful note control surface.
 *
 * Locks in the bit-exact immediate-gate note mechanism (src/juno_note.c) and the
 * bug it fixed: the earlier hand-written envelope reset + 1 ms gate ramp produced
 * an onset CLICK followed by a slow swell even for fast-attack patches ("attack
 * never snappy" + "clicking"). This test asserts:
 *   1. note_on writes M.CV (304)=note/12, M.Gate (320)=1.0, aux latch=1.0 (immediate)
 *   2. note_off writes M.Gate (320)=0.0 (immediate)
 *   3. with a FAST attack coefficient the audio reaches near-full level within a few
 *      ms and has NO large onset transient relative to the steady level (snappy, no
 *      click)
 *   4. note-off then note-on re-attacks cleanly (gate edge drives the envelope)
 */
#include "../src/juno_engine.h"
#include "../src/juno_curve.h"
#include "../src/juno_note.h"
#include <stdlib.h>
#include <stdio.h>
#include <math.h>

#define AMP_ENV 3072

static float win_rms(const float *buf, int a, int b)
{
    double s = 0; int n = 0;
    for (int i = a; i < b; ++i) { s += (double)buf[2*i]*buf[2*i]; ++n; }
    return n ? (float)sqrt(s / n) : 0.0f;
}

int main(void)
{
    unsigned char *st = calloc(1, JUNO_STATE_BYTES);
    JF(st, 16) = 96000.0f;
    juno_engine_init(st);
    juno_runtime_coeffs_apply(st);

    /* 1. control writes (voice 3, note 60) */
    juno_note_on(st, 3, 60, 100);
    unsigned b = 3u * JUNO_VOICE_MAIN_STRIDE;
    unsigned aux = JUNO_VOICE_AUX_BASE0 + 3u * JUNO_VOICE_AUX_STRIDE;
    if (JF(st, b + 304) != 60.0f / 12.0f) { printf("FAIL: M.CV != note/12\n"); return 1; }
    if (JF(st, b + 320) != 1.0f)          { printf("FAIL: M.Gate != 1.0 on note-on\n"); return 1; }
    if (JF(st, aux)     != 1.0f)          { printf("FAIL: aux retrigger latch not set\n"); return 1; }
    juno_note_off(st, 3);
    if (JF(st, b + 320) != 0.0f)          { printf("FAIL: M.Gate != 0.0 on note-off\n"); return 1; }
    printf("OK: note_on/off write M.CV, M.Gate, aux latch immediately (binary en=0)\n");

    /* 2. snappy attack, no onset click (fast attack coeff on voice 0) */
    free(st);
    st = calloc(1, JUNO_STATE_BYTES);
    JF(st, 16) = 96000.0f;
    juno_engine_init(st);
    juno_runtime_coeffs_apply(st);
    float fastA = juno_curve(35, 0);      /* fastest attack */
    JF(st, 2784) = fastA; JF(st, 3264) = fastA;
    /* seed voice 0 only (we render voice 0) */
    juno_note_on(st, 0, 60, 100);

    int N = 9600;                          /* 100 ms */
    float *buf = malloc(sizeof(float) * 2 * N);
    for (int i = 0; i < N; ++i) { float l=0,r=0; juno_voice_render(st, 0, &l, &r); buf[2*i]=l; buf[2*i+1]=r; }

    float onset = win_rms(buf, 0, 192);            /* first 2 ms */
    float steady = win_rms(buf, 96*20, 96*100);    /* 20..100 ms mean */
    /* fast attack => onset should already be a large fraction of steady, and NOT a
     * huge spike above it (the old click made onset >> steady, then collapsed). */
    printf("onset(0-2ms) rms=%.6f  steady(20-100ms) rms=%.6f  ratio=%.2f\n",
           onset, steady, steady > 0 ? onset/steady : 0);
    if (steady <= 0.0f)             { printf("FAIL: no sound after note-on\n"); return 1; }
    if (onset < 0.4f * steady)      { printf("FAIL: attack not snappy (onset << steady => slow swell)\n"); return 1; }
    if (onset > 2.5f * steady)      { printf("FAIL: onset click (onset >> steady)\n"); return 1; }
    printf("OK: fast-attack note is snappy with no onset click\n");

    /* 3. re-attack via gate edge: sustain, note-off (release), note-on (re-attack) */
    float sus = JF(st, AMP_ENV);
    for (int i = 0; i < 48000; ++i) { float l,r; juno_note_off(st, 0); JF(st, 320)=0.0f; juno_voice_render(st, 0, &l, &r); }
    float rel = JF(st, AMP_ENV);
    juno_note_on(st, 0, 60, 100);
    for (int i = 0; i < 4800; ++i) { float l,r; juno_voice_render(st, 0, &l, &r); }
    float re = JF(st, AMP_ENV);
    printf("sustain=%.4f released=%.4f re-attacked=%.4f\n", sus, rel, re);
    if (!(rel < sus))       { printf("FAIL: note-off did not release the envelope\n"); return 1; }
    if (!(re > rel))        { printf("FAIL: note-on did not re-attack the envelope\n"); return 1; }
    printf("OK: gate edge drives release + clean re-attack (no hand reset)\n");

    free(buf); free(st);
    printf("ALL OK: faithful note path verified\n");
    return 0;
}
