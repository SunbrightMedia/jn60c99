/* juno_driver.c — offline per-sample driver around the exact DSP transcription.
 *
 * This is the clean host glue (NO plugin threading): it renders the voices into
 * the 8 voice buffers the master expects, supplies the chorus-mode selectors
 * the master reads through a host-params pointer, and calls the master process
 * (juno_master_render = sub_180363380) to produce the final stereo sample.
 *
 * POLYPHONY: the master's input is 8 voice samples. The plugin compiled 8
 * specialised copies of the voice render; diffing all 8 decompiles
 * (sub_18036CE00..sub_180383F20) proves each is voice 0's identical code with its
 * state offsets shifted by region (main +10512*v, shared +0, aux +32*v) — verified
 * EXACTLY for all 622 offsets. So one parameterised render (juno_voice_render_v +
 * juno_voff) serves all 8 voices faithfully; we render each into its buffer and let
 * the master sum them. Per-voice patch coefficients are broadcast to all voices in
 * juno_runtime_coeffs_apply. See docs/PORT_STATUS.md / docs/POLYPHONY.md.
 */
#include "juno_engine.h"
#include "juno_driver.h"
#include <string.h>
#include <math.h>

/* Install the host-params shim into the state block. Call once after init.
 * `shim` must outlive all render calls (the state holds a pointer into it). */
/* FX-A (Prog_ID_EFX, the v551 slot) thru-bypass. The System-8 FX-A is a separate
 * effect in series BEFORE the JUNO chorus; its off/delay paths need runtime-only
 * coefficients we don't have, so by default we route its input (state+84624) to
 * its output taps (state+84672 / state+84704) each sample — a clean thru — rather
 * than letting it run as a stray modulator. Set to 0 once real FX-A coeffs exist. */
static int g_fxa_bypass = 1;

void juno_driver_set_fxa_bypass(int on) { g_fxa_bypass = on; }

void juno_driver_attach_host(unsigned char *st, struct juno_host_shim *shim,
                             int32_t chorus_mode)
{
    int32_t *p39, *p551;
    void *base;

    shim->mode_v39  = chorus_mode;
    shim->mode_v551 = 0;            /* FX-A off; the thru-bypass supplies the signal */
    p39  = &shim->mode_v39;
    p551 = &shim->mode_v551;
    /* params+136 -> &mode_v39 ; params+112 -> &mode_v551 (used by the chase) */
    memcpy(shim->params + 136, &p39,  sizeof(void *));
    memcpy(shim->params + 112, &p551, sizeof(void *));
    /* base = &shim->params, stored at state+136 (the chase's first hop) */
    base = shim->params;
    memcpy(st + 136, &base, sizeof(void *));
}

/* Note gate. The host holds the per-voice "M.Gate" param (offset 320 + v*10512)
 * at 1.0 for the duration of the note and pulses the note-on edge (offset 101504
 * + v*32). voice_render consumes the edge once, then runs its internal LFO/ADSR/
 * filter-envelope generators off the held gate. */
#define JUNO_GATE_OFF(v)   (JUNO_VOICE_MAIN_BASE0 + (v) * JUNO_VOICE_MAIN_STRIDE)  /* 320 */
#define JUNO_PITCH_OFF(v)  (4448            + (v) * JUNO_VOICE_MAIN_STRIDE)        /* 4448 */
#define JUNO_MCV_OFF(v)    (304             + (v) * JUNO_VOICE_MAIN_STRIDE)        /* 304 */
#define JUNO_EDGE_OFF(v)   (JUNO_VOICE_AUX_BASE0  + (v) * JUNO_VOICE_AUX_STRIDE)   /* 101504 */

void juno_note_on(unsigned char *st, int voice, int midi_note)
{
    /* pitch in octaves so Hz = JUNO_DCO_REF_HZ*2^pitch == 440*2^((note-69)/12) */
    float pitch = (float)(log2(440.0 / JUNO_DCO_REF_HZ) + (midi_note - 69) / 12.0);
    JF(st, JUNO_PITCH_OFF(voice)) = pitch;
    /* M.CV (offset 304) is the per-voice pitch BASE. It sits 16 bytes below the
     * voice block, so the parameter broadcast (which copies voice-0 params across
     * voices at +10512) lands voice v's M.CV slot inside voice v-1's nominal block
     * and overwrites it with the wrong value — leaving voices 1..7 mistuned (only
     * voice 0, seeded by the capture, was correct). Re-seat each played voice's
     * M.CV base from voice 0's so all voices share the correct pitch reference. */
    JF(st, JUNO_MCV_OFF(voice)) = JF(st, JUNO_MCV_OFF(0));
    JF(st, JUNO_GATE_OFF(voice))  = 1.0f;
    JI(st, JUNO_EDGE_OFF(voice))  = 0x3F800000;  /* 1.0f — one-shot retrigger */
}

void juno_note_off(unsigned char *st, int voice)
{
    JF(st, JUNO_GATE_OFF(voice)) = 0.0f;
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

    /* Render all 8 voices via the verified per-voice offset remap (juno_voff). */
    for (i = 0; i < JUNO_NUM_VOICES; ++i) {
        float vr = 0.0f;
        juno_voice_render_v(st, &vbuf[i], &vr, i);
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
        /* FX-A thru-bypass: overwrite the EFX output taps (read by next sample's
         * chorus input mix at master_render.c:813/830) with the EFX input
         * (state+84624 = the mixed voice signal), so the JUNO chorus processes the
         * dry voice with no stray FX-A modulation. One-sample latency; from the 2nd
         * sample on the chorus always sees the thru signal. See juno_driver.h. */
        if (g_fxa_bypass) {
            JF(st, 84672) = JF(st, 84624);
            JF(st, 84704) = JF(st, 84624);
        }
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
