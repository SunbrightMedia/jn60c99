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
#include "juno_param_luts.h"
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

/* Note gate — protocol verified faithful against the decompile + runtime dump:
 * the render reads M.Gate (320 + v*10512) as a LEVEL gate every sample, and
 * 101504 + v*32 ("Voice N Note Off Notify", param 927+) as a SELF-CLEARING
 * one-shot: while pending=1.0 the render saves the gate, forces it 0 for that
 * one sample, then restores it and clears the flag (decomp_340000.c:28376-80 /
 * 29955-58). The real control layer ARMS the flag at note-off/prune/init —
 * every idle voice in the runtime dump holds it pending — so a fresh note
 * always begins with one forced gate-0 sample (the retrigger). Pulsing it at
 * note-on reproduces that exactly, incl. voice-steal retrigger. (101488
 * "Gate Notify" is a write-only control-layer latch with no reader anywhere
 * in the binary; the driver correctly ignores it.) */
#define JUNO_GATE_OFF(v)   (JUNO_VOICE_MAIN_BASE0 + (v) * JUNO_VOICE_MAIN_STRIDE)  /* 320 */
#define JUNO_PITCH_OFF(v)  (4448            + (v) * JUNO_VOICE_MAIN_STRIDE)        /* 4448 */
#define JUNO_MCV_OFF(v)    (304             + (v) * JUNO_VOICE_MAIN_STRIDE)        /* 304 */
#define JUNO_EDGE_OFF(v)   (JUNO_VOICE_AUX_BASE0  + (v) * JUNO_VOICE_AUX_STRIDE)   /* 101504 */

void juno_note_on_vel(unsigned char *st, int voice, int midi_note, int velocity)
{
    /* DCO pitch — the binary's actual note path (verified against the plugin's own
     * runtime state, state_dump/state_t0.bin + the record-0 capture):
     *
     *   - The voice-trigger writes the KEY CV to M.CV (offset 304), applied through
     *     the tid-32 pitch LUT with step = the MIDI note itself. LUT32 is the
     *     plugin's semitone table WITH per-key analog detune baked in
     *     (LUT32[i] = (i-12)/12 + eps_i, |eps| <= ~2.3 cents):
     *       pad dump  304 = 6.668469 = LUT32[92] bit-exact (held G#6, note 92)
     *       rec0 dump 304 = 2.000303 = LUT32[36] bit-exact (held C2,  note 36)
     *   - 4448 is the STATIC pitch base -4.75 = -57/12 (engine_init writes
     *     0xC0980000; it is NOT a descriptor slot, so it survives the param layer)
     *     and is never touched at note-on.
     *   - voice_render forms the final pitch as JF(4448) + JF(3776), where 3776 is
     *     M.CV through the portamento smoother. So
     *       Hz = 440 * 2^((note-69)/12 + eps_note)
     *     and portamento glides the note CV exactly as the plugin does.
     *
     * (Two earlier formulas here were wrong: one referenced a bogus 22380.1 Hz
     * base, one bypassed M.CV with 4448=(note-69)/12 — frequency-correct but it
     * lost the per-key detune and broke the portamento path.) */
    JF(st, JUNO_MCV_OFF(voice)) = juno_lut_apply(32, midi_note & 127);  /* 304: key CV */
    /* Note velocity — the real trigger writes TWO distinct velocity params
     * (audited vs the decompile; both bit-exact vs the runtime dump at vel 107):
     *  - LINEAR velocity (param id 73) -> 6864 + smoother copies 6880/6896/6912,
     *    = LUT56[vel] = vel/127 (dump 0.842520 = 107/127). Gates the VCA level;
     *    with these at 0 the note is nearly silent.
     *  - CURVE velocity (param id 98, setter sub_180357160) -> 9680 (+copies
     *    9696/9712), = LUT57[vel] (dump 1.154360 = LUT57[107]). The amp combines
     *    v331 = fix(9616) + sens(9600)*(smoothed(9680) - fix); the JUNO-60 panel
     *    has AMP VELOCITY SENS = 0 so this is multiplied out, but it is what the
     *    plugin writes and is live for any velocity-sensitive configuration. */
    {
        int vc = velocity < 0 ? 0 : velocity > 127 ? 127 : velocity;
        float v = (float)vc / 127.0f;
        float cw = juno_lut_apply(57, vc);
        size_t b = (size_t)voice * JUNO_VOICE_MAIN_STRIDE;
        int o;
        for (o = 6864; o <= 6912; o += 16) JF(st, o + b) = v;
        JF(st, 9680 + b) = cw;
        JF(st, 9696 + b) = cw;   /* render copy chain 9680->9696 */
        JF(st, 9712 + b) = cw;   /* smoother history; seeded = settled state */
    }
    JF(st, JUNO_GATE_OFF(voice))  = 1.0f;         /* 320: gate held                        */
    JI(st, JUNO_EDGE_OFF(voice))  = 0x3F800000;   /* 101504: 1.0f one-shot retrigger edge  */
}

void juno_note_on(unsigned char *st, int voice, int midi_note)
{
    juno_note_on_vel(st, voice, midi_note, 100);  /* default velocity */
}

void juno_note_off(unsigned char *st, int voice)
{
    JF(st, JUNO_GATE_OFF(voice)) = 0.0f;
    /* Re-arm the Note Off Notify one-shot, restoring the engine's invariant
     * that every idle voice holds it pending (runtime dump: 1.0 on all
     * non-rendering voices). No audible effect today (with the gate already 0
     * the pulse is a no-op and note-on re-pulses), but it matches the real
     * control layer, which arms it at note-off/prune. */
    JI(st, JUNO_EDGE_OFF(voice)) = 0x3F800000;
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
