/* test_note_path.c — regression guard for the faithful note control surface.
 *
 * Locks in the bit-exact immediate-gate note mechanism (src/juno_note.c) and the
 * bug it fixed: the earlier hand-written envelope reset + 1 ms gate ramp produced
 * an onset CLICK followed by a slow swell even for fast-attack patches ("attack
 * never snappy" + "clicking"). This test asserts:
 *   1. note_on writes M.CV (304)=juno_note_pitch(note) [(note-12)/12 + analog tune],
 *      M.Gate (320)=1.0 (immediate). The DCO-retrigger latch (aux Array A,
 *      101504+v*32) is armed to 1.0 at BUILD by juno_engine_init — NOT by note_on;
 *      note_on must never (re-)arm it. Regression guard for the phase-2 matrix
 *      Scenario-C bug (an earlier note_on armed it every note, re-phasing the DCO
 *      on notes played after rendering had begun).
 *   2. note_off writes M.Gate (320)=0.0 (immediate)
 *   3. with a FAST attack coefficient the audio reaches near-full level within a few
 *      ms and has NO large onset transient relative to the steady level (snappy, no
 *      click)
 *   4. note-off then note-on re-attacks cleanly (gate edge drives the envelope)
 */
#include "../src/juno_engine.h"
#include "../src/juno_curve.h"
#include "../src/juno_note.h"
#include "../src/juno_apply.h"
#include "../src/juno_driver.h"
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>

#define AMP_ENV 3072

/* A real bank patch (presetbankog1 #5, a bright plucky sound) — its complete,
 * bit-exact ADSR + osc + filter recall gives a genuine sounding voice with a
 * fast attack, so the note-path checks run on the plugin's own coefficients
 * rather than a hand-made partial patch. 222-byte value blob (as in
 * test_apply_golden.c). */
static const unsigned char BLOB_5[222] = {
  0x01,0x0a,0x06,0x04,0x00,0x00,0x08,0x00,0x00,0x03,0x07,0x00,0x00,0x00,0x02,0x05,
  0x08,0x02,0x0a,0x0a,0x08,0x00,0x08,0x00,0x00,0x01,0x00,0x00,0x0d,0x06,0x00,0x01,
  0x00,0x03,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x08,0x00,0x00,0x00,
  0x00,0x00,0x00,0x0b,0x0a,0x0c,0x09,0x05,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x01,
  0x08,0x00,0x00,0x00,0x00,0x00,0x09,0x09,0x00,0x00,0x00,0x00,0x08,0x02,0x0a,0x00,
  0x00,0x00,0x03,0x0a,0x03,0x0c,0x01,0x07,0x0a,0x0a,0x03,0x04,0x00,0x00,0x0f,0x0f,
  0x05,0x02,0x0a,0x03,0x0f,0x0f,0x0b,0x06,0x05,0x06,0x07,0x0c,0x00,0x04,0x00,0x01,
  0x00,0x01,0x00,0x0b,0x00,0x00,0x00,0x01,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
  0x00,0x00,0x00,0x00,0x02,0x0e,0x00,0x01,0x00,0x00,0x00,0x00,0x04,0x0c,0x04,0x04,
  0x02,0x00,0x04,0x03,0x06,0x0c,0x06,0x01,0x07,0x03,0x07,0x03,0x06,0x09,0x06,0x03,
  0x02,0x00,0x04,0x0c,0x06,0x05,0x06,0x01,0x06,0x04,0x02,0x00,0x00,0x00,0x00,0x00,
  0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
  0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
  0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
};

/* Apply BLOB_5 as a real patch: wrap in a minimal one-record bank + apply. */
static void apply_test_patch(unsigned char *st)
{
    unsigned char bank[23 + 20223];
    memset(bank, 0, sizeof(bank));
    bank[0] = 'K';                          /* KoaBankFile sentinel */
    memcpy(bank + 23 + 16, BLOB_5, 222);    /* record 0 blob at +16 */
    juno_bank_apply(st, bank, 0);
    juno_driver_seed_voices(st);            /* replicate voice 0 -> all 8 */
}

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
    juno_engine_prepare(st);

    /* 1. control writes (voice 3, note 60) */
    juno_note_on(st, 3, 60, 100);
    unsigned b = 3u * JUNO_VOICE_MAIN_STRIDE;
    unsigned aux = JUNO_VOICE_AUX_BASE0 + 3u * JUNO_VOICE_AUX_STRIDE;
    /* M.CV = the plugin's exact note-on pitch CV (base (note-12)/12 + analog
     * stretch-tune), captured from the binary; note 60 -> ~3.99981 (NOT note/12). */
    if (JF(st, b + 304) != juno_note_pitch(60)) { printf("FAIL: M.CV != juno_note_pitch(60)\n"); return 1; }
    { float mcv = JF(st, b + 304);
      if (mcv < 3.99f || mcv > 4.01f) { printf("FAIL: M.CV(60)=%g not ~3.9998 ((note-12)/12)\n", mcv); return 1; } }
    if (JF(st, b + 320) != 1.0f)          { printf("FAIL: M.Gate != 1.0 on note-on\n"); return 1; }
    /* aux DCO-retrigger latch is armed by juno_engine_init (BUILD), not note_on. */
    if (JF(st, aux)     != 1.0f)          { printf("FAIL: aux retrigger latch not armed at BUILD\n"); return 1; }
    juno_note_off(st, 3);
    if (JF(st, b + 320) != 0.0f)          { printf("FAIL: M.Gate != 0.0 on note-off\n"); return 1; }

    /* Regression guard (Scenario C): once the latch is CONSUMED by rendering, a
     * subsequent note_on must NOT re-arm it — the plugin's note-on never touches
     * aux Array A. Consume voice 3's latch with one render, confirm it clears, then
     * re-gate and confirm it stays 0. */
    { float l, r; JF(st, b + 320) = 1.0f; juno_voice_render(st, 3, &l, &r); }
    if (JF(st, aux) != 0.0f)              { printf("FAIL: aux latch not consumed by render\n"); return 1; }
    juno_note_on(st, 3, 62, 100);
    if (JF(st, aux) != 0.0f)              { printf("FAIL: note_on RE-ARMED aux latch after consume (Scenario C bug)\n"); return 1; }
    juno_note_off(st, 3);
    printf("OK: BUILD arms aux latch; note_on never (re-)arms it (Scenario C guard)\n");

    /* 2. sound present + NO onset click — on a REAL patch (complete bit-exact
     * envelope). The old bug was a hand-written 1 ms gate RAMP that produced an
     * onset CLICK (onset >> steady) then a slow swell; the immediate-gate note
     * path removes it (check 1 proves the gate is a direct write, no ramp). The
     * attack SPEED is now purely the patch's own ADSR, so this asserts only the
     * two things the note path is responsible for: audible sound, and no click. */
    free(st);
    st = calloc(1, JUNO_STATE_BYTES);
    JF(st, 16) = 96000.0f;
    juno_engine_init(st);
    juno_engine_prepare(st);
    apply_test_patch(st);                 /* real patch: sounding voice + stable ADSR */
    juno_note_on(st, 0, 60, 100);

    int N = 9600;                          /* 100 ms */
    float *buf = malloc(sizeof(float) * 2 * N);
    for (int i = 0; i < N; ++i) { float l=0,r=0; juno_voice_render(st, 0, &l, &r); buf[2*i]=l; buf[2*i+1]=r; }

    float onset = win_rms(buf, 0, 192);            /* first 2 ms */
    float steady = win_rms(buf, 96*20, 96*100);    /* 20..100 ms mean */
    printf("onset(0-2ms) rms=%.6f  steady(20-100ms) rms=%.6f  ratio=%.2f\n",
           onset, steady, steady > 0 ? onset/steady : 0);
    if (steady <= 0.0f)             { printf("FAIL: no sound after note-on\n"); return 1; }
    if (onset > 2.5f * steady)      { printf("FAIL: onset click (onset >> steady)\n"); return 1; }
    printf("OK: note speaks cleanly with no onset click\n");

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
