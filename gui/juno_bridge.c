/* juno_bridge.c — flat C ABI for the test GUI (gui/juno_gui.py via ctypes).
 *
 * Thin glue only: owns the state block + host shim, mirrors the exact init
 * sequence from tests/test_master_smoke.c, and exposes raw offset get/set —
 * which IS the plugin's own parameter mechanism (raw store, no curves; see
 * docs/CONTROL_LAYER.md). No DSP logic lives here.
 *
 * Build: make gui  (produces libjuno.so)
 */
#include "../src/juno_engine.h"
#include "../src/juno_driver.h"
#include "../src/juno_apply.h"
#include "../src/juno_note.h"
#include "../src/delay_recall.h"
#include <stdlib.h>

typedef struct {
    unsigned char *st;
    struct juno_host_shim shim;   /* must outlive render calls */
    int chorus_mode;
    int voice_note[JUNO_NUM_VOICES];   /* MIDI note per voice, -1 = free      */
    unsigned voice_age[JUNO_NUM_VOICES];/* allocation order (for LRU stealing) */
    unsigned age_counter;
} juno_ctx;

/* Create + fully init an engine. sample_rate should be 96000 to match the
 * captured patch. Returns NULL on alloc failure. */
juno_ctx *juno_gui_create(float sample_rate, int chorus_mode)
{
    juno_ctx *c = calloc(1, sizeof *c);
    int v;
    if (!c) return NULL;
    c->st = calloc(1, JUNO_STATE_BYTES);
    if (!c->st) { free(c); return NULL; }

    JF(c->st, 16) = sample_rate;
    juno_chorus_init(c->st);
    juno_engine_init(c->st);
    juno_runtime_coeffs_apply(c->st);
    juno_driver_seed_voices(c->st);      /* all 8 voices carry the same coeffs */
    c->chorus_mode = chorus_mode;
    for (v = 0; v < JUNO_NUM_VOICES; ++v) c->voice_note[v] = -1;
    juno_driver_attach_host(c->st, &c->shim, chorus_mode);
    return c;
}

void juno_gui_destroy(juno_ctx *c)
{
    if (!c) return;
    free(c->st);
    free(c);
}

/* Raw parameter store/load — native units, exactly the plugin's raw-store
 * setter (sub_1803C1090 semantics). Offset bounds-checked against the block. */
void juno_gui_set(juno_ctx *c, int off, float v)
{
    if (off >= 0 && (unsigned)off + 4 <= JUNO_STATE_BYTES) JF(c->st, off) = v;
}

float juno_gui_get(juno_ctx *c, int off)
{
    if (off >= 0 && (unsigned)off + 4 <= JUNO_STATE_BYTES) return JF(c->st, off);
    return 0.0f;
}

/* Re-apply the captured factory patch (PD The Juno Pad) — preset recall of
 * the built-in capture, via the same apply path the port already uses.
 * The capture includes offset 136 (a fragment of the LIVE plugin's host-params
 * pointer), which clobbers the shim pointer attach_host installed there — so
 * re-attach the shim afterwards or the master's pointer chase derefs garbage. */
void juno_gui_recall_factory(juno_ctx *c)
{
    juno_runtime_coeffs_apply(c->st);
    /* factory capture is a chorus preset; reset slot-1 (v39) to 0 so the delay
     * slot is a clean pass-through (no stale DELAY TYPE from a prior patch). */
    *(int32_t *)(c->st + JUNO_PROG_DLY) = 0;
    juno_driver_seed_voices(c->st);      /* propagate to all 8 voices */
    juno_driver_attach_host(c->st, &c->shim, c->chorus_mode);
}

/* Switch chorus mode selector (0 = dry/bypass). */
void juno_gui_set_chorus_mode(juno_ctx *c, int mode)
{
    c->chorus_mode = mode;
    juno_driver_attach_host(c->st, &c->shim, mode);
}

/* Poke the voice-0 note-on edge state[101504]. KNOWN LIMITATION: the real
 * note path (ramp-gate engine, control-layer unit #1) is not yet transcribed,
 * so this alone does not open the filter envelope — expect silence. Exposed
 * for experimentation only (see docs/CONTROL_LAYER.md sound-test). */
void juno_gui_gate(juno_ctx *c, float v)
{
    JF(c->st, JUNO_VOICE_AUX_BASE0) = v;
}

/* Note driver (src/juno_note.c) with an 8-voice allocator. note-on picks a free
 * voice (else steals the oldest) and sets its per-voice DCO pitch (state[V*10512+
 * 304] = note/12), opens its shared ADSR gate (ramps state[V*10512+320]) and
 * fires its DCO retrigger edge — the plugin's own note writes, one voice each.
 * All 8 voices are rendered every sample (juno_gui_render), so chords sound.
 * Faithful port from the binary + live-plugin state; MIDI 60 = concert C4. */
void juno_gui_note_on(juno_ctx *c, int midi_note, int velocity)
{
    int v, pick = -1;
    unsigned oldest;
    if (!c) return;
    for (v = 0; v < JUNO_NUM_VOICES; ++v)          /* prefer a voice already   */
        if (c->voice_note[v] == midi_note) { pick = v; break; }  /* on this note*/
    if (pick < 0)
        for (v = 0; v < JUNO_NUM_VOICES; ++v)      /* then a free voice         */
            if (c->voice_note[v] < 0) { pick = v; break; }
    if (pick < 0) {                                /* else steal the oldest     */
        pick = 0; oldest = c->voice_age[0];
        for (v = 1; v < JUNO_NUM_VOICES; ++v)
            if (c->voice_age[v] < oldest) { oldest = c->voice_age[v]; pick = v; }
    }
    c->voice_note[pick] = midi_note;
    c->voice_age[pick]  = ++c->age_counter;
    juno_note_on(c->st, pick, midi_note, velocity);
}

/* Release the voice(s) playing `midi_note`. midi_note < 0 releases all voices. */
void juno_gui_note_off(juno_ctx *c, int midi_note)
{
    int v;
    if (!c) return;
    for (v = 0; v < JUNO_NUM_VOICES; ++v)
        if (c->voice_note[v] == midi_note || (midi_note < 0 && c->voice_note[v] >= 0)) {
            juno_note_off(c->st, v);
            c->voice_note[v] = -1;
        }
}

/* Apply bank patch `idx` (raw KoaBankFile00003 bytes in `bank`, `len` bytes)
 * into this engine's coefficient slots via the bit-exact applier
 * (src/juno_apply.c). Returns # coefficients set. The bound subset is
 * reproduced EXACTLY (curve LUTs proven vs the real machine code); unbound
 * params keep their current (engine-default) value. */
int juno_gui_apply_bank(juno_ctx *c, const unsigned char *bank, int len, int idx)
{
    int n;
    if (!c || !bank || len <= 0) return 0;
    n = juno_bank_apply(c->st, bank, idx);
    juno_driver_seed_voices(c->st);      /* all 8 voices play the applied patch */
    return n;
}

/* Render nframes stereo samples into out (interleaved L,R). Advances the note
 * driver's gate ramp once per sample (matches the control-tick rate the ramp
 * math assumes). Returns 1 if the full master/chorus path ran, 0 if the dry
 * fallback was used. */
int juno_gui_render(juno_ctx *c, float *out, int nframes)
{
    int i, full = 0;
    for (i = 0; i < nframes; ++i) {
        juno_note_tick(c->st);
        full = juno_driver_render_sample(c->st, &out[2 * i], &out[2 * i + 1]);
    }
    return full;
}

/* Render the DRY voice signal (voice 0 = the one exact per-sample render),
 * bypassing the master/chorus/output stage. This is the genuine pre-FX signal
 * and carries the bit-exact timbre of whatever coefficients are loaded (osc +
 * VCF + VCA + both ADSRs). We use it for the note preview because the master's
 * output/chorus stage depends on ~250 coefficients Hex-Rays could not decompile
 * (see src/master_render.c) — with them zero the master's dry & chorus-I output
 * collapse to silence. So the dry voice is the most faithful AUDIBLE signal the
 * port can currently produce. Ticks the note driver once per sample. */
int juno_gui_render_dry(juno_ctx *c, float *out, int nframes)
{
    int i, v;
    if (!c) return 0;
    for (i = 0; i < nframes; ++i) {
        float mix = 0.0f;
        juno_note_tick(c->st);
        for (v = 0; v < JUNO_NUM_VOICES; ++v) {   /* all 8 voices, in order */
            float vb = 0.0f, vr = 0.0f;
            juno_voice_render(c->st, v, &vb, &vr);
            mix += vb;
        }
        out[2 * i]     = mix;                     /* mono mix -> both channels */
        out[2 * i + 1] = mix;
    }
    return 1;
}
