/* juno_driver.c — offline per-sample driver around the exact DSP transcription.
 *
 * This is the clean host glue (NO plugin threading): it renders the voices into
 * the 8 voice buffers the master expects, supplies the chorus-mode selectors
 * the master reads through a host-params pointer, and calls the master process
 * (juno_master_render = sub_180363380) to produce the final stereo sample.
 *
 * SCOPE / HONESTY: the master's input is 8 voice samples. We have ONE exact voice
 * render (juno_voice_render = sub_180369070, voice 0's absolute offsets). The
 * plugin compiled 8 specialised copies; voices differ across THREE regions with
 * DIFFERENT strides (main +10512, shared +0, aux +32), so a single uniform base
 * shift cannot serve voices 1-7 correctly. Faking it would be a wrong
 * approximation (forbidden). Until the per-voice renders exist (dump asm for
 * sub_18036CE00..sub_180383F20 and transcribe each, or build a verified offset
 * classification to parameterise the one render), voices 1-7 are rendered as
 * silence. Voice 0 is exact. See docs/PORT_STATUS.md.
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

/* Render one stereo output sample: voices -> 8 buffers -> master process.
 * Writes the final stereo pair to *outL / *outR. Returns 1 if the full master/
 * chorus path ran, 0 if the dry fallback was used (chorus coeffs not yet loaded). */
int juno_driver_render_sample(unsigned char *st, float *outL, float *outR)
{
    float vbuf[JUNO_NUM_VOICES];     /* one mono sample per voice */
    float scratch = 0.0f;
    float *a2[16];
    int i;

    for (i = 0; i < 16; ++i) a2[i] = &scratch;        /* default: harmless */
    for (i = 0; i < JUNO_NUM_VOICES; ++i) {
        vbuf[i] = 0.0f;
        a2[2 * i] = &vbuf[i];                          /* even slots = voices */
    }

    /* Voice 0 — the one exact render we have. */
    {
        float vr = 0.0f;
        juno_voice_render(st, &vbuf[0], &vr);
    }
    /* Voices 1..7 stay 0.0f (see SCOPE note above). */

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
