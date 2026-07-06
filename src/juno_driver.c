/* juno_driver.c — offline per-sample driver around the exact DSP transcription.
 *
 * This is the clean host glue (NO plugin threading): it renders the voices into
 * the 8 voice buffers the master expects, supplies the chorus-mode selectors
 * the master reads through a host-params pointer, and calls the master process
 * (juno_master_render = sub_180363380) to produce the final stereo sample.
 *
 * POLYPHONY: the master's input is 8 voice samples. voice_render is now
 * parameterised by voice index using the VERIFIED offset classification (diffing
 * the 8 specialised copies sub_180369070..sub_180383F20 proves every state
 * reference is main +v*10512, shared +0, or aux +v*32 — see docs/POLYPHONY.md).
 * So all 8 voices are rendered by the one exact transcription, in order 0..7 each
 * sample so the shared block chains exactly as the plugin's 8 calls do. Each
 * voice needs its own copy of the per-voice patch coefficients: juno_bank_apply
 * writes voice 0's block, and juno_driver_seed_voices replicates it to voices
 * 1..7 (call after apply). Global coeffs (e.g. VCA level at 101072) stay single.
 */
#include "juno_engine.h"
#include "juno_driver.h"
#include <string.h>

/* Install the host-params shim into the state block. Call once after init.
 * `shim` must outlive all render calls (the state holds a pointer into it). */
void juno_driver_attach_host(unsigned char *st, struct juno_host_shim *shim,
                             int32_t chorus_mode)
{
    int32_t *p39, *p551;
    void *base;

    shim->mode_v39  = chorus_mode;
    shim->mode_v551 = chorus_mode;
    p39  = &shim->mode_v39;
    p551 = &shim->mode_v551;
    /* params+136 -> &mode_v39 ; params+112 -> &mode_v551 (used by the chase) */
    memcpy(shim->params + 136, &p39,  sizeof(void *));
    memcpy(shim->params + 112, &p551, sizeof(void *));
    /* base = &shim->params, stored at state+136 (the chase's first hop) */
    base = shim->params;
    memcpy(st + 136, &base, sizeof(void *));
}

/* Replicate voice 0's per-voice state block [176,84272) to voices 1..7 so every
 * voice carries the same patch coefficients. Call once after juno_bank_apply (and
 * after juno_engine_init). The 8 blocks tile [176,84272) exactly at stride 10512;
 * the shared/global region (>=84272) and the header (<176) are left untouched. */
void juno_driver_seed_voices(unsigned char *st)
{
    const unsigned block = 176;                 /* per-voice block start          */
    int v;
    for (v = 1; v < JUNO_NUM_VOICES; ++v)
        memcpy(st + block + (unsigned)v * JUNO_VOICE_MAIN_STRIDE,
               st + block, JUNO_VOICE_MAIN_STRIDE);
}

/* Render one stereo output sample: 8 voices -> 8 buffers -> master process.
 * Writes the final stereo pair to *outL / *outR. Returns 1 if the full master/
 * chorus path ran, 0 if the dry fallback was used (chorus coeffs not yet loaded). */
int juno_driver_render_sample(unsigned char *st, float *outL, float *outR)
{
    float vbuf[JUNO_NUM_VOICES];     /* one mono sample per voice */
    float scratch = 0.0f;
    float *a2[16];
    int i;

    for (i = 0; i < 16; ++i) a2[i] = &scratch;        /* default: harmless */

    /* All 8 voices, IN ORDER (the shared block at 84272 chains across them, as
     * the plugin's 8 sequential voice calls do). Each voice reads/writes its own
     * main block (+i*10512) and aux edge (+i*32); voice_render selects them. */
    for (i = 0; i < JUNO_NUM_VOICES; ++i) {
        float vr = 0.0f;
        vbuf[i] = 0.0f;
        juno_voice_render(st, i, &vbuf[i], &vr);
        a2[2 * i] = &vbuf[i];                          /* even slots = voices */
    }

    /* Run the full master/chorus only once the float coefficients are captured;
     * with them zero the master's output saturator collapses to silence, so the
     * useful, faithful behaviour is the dry voice sum. (The delay-line lengths
     * from juno_chorus_init are always set, so the master itself won't read out
     * of bounds — the gate here is purely silence-vs-signal.) */
    if (juno_runtime_coeffs_loaded()) {
        float *a3[2] = { outL, outR };
        *outL = 0.0f; *outR = 0.0f;
        juno_master_render(st, a2, a3);
        return 1;
    }

    /* Chorus coefficients not loaded: emit the exact dry voice sum (the genuine
     * pre-chorus signal), duplicated to both channels as the voice path does. */
    {
        float dry = 0.0f;
        for (i = 0; i < JUNO_NUM_VOICES; ++i) dry += vbuf[i];
        *outL = dry;
        *outR = dry;
        return 0;
    }
}
