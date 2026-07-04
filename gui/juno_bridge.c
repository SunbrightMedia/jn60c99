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
#include <stdlib.h>

typedef struct {
    unsigned char *st;
    struct juno_host_shim shim;   /* must outlive render calls */
    int chorus_mode;
} juno_ctx;

/* Create + fully init an engine. sample_rate should be 96000 to match the
 * captured patch. Returns NULL on alloc failure. */
juno_ctx *juno_gui_create(float sample_rate, int chorus_mode)
{
    juno_ctx *c = calloc(1, sizeof *c);
    if (!c) return NULL;
    c->st = calloc(1, JUNO_STATE_BYTES);
    if (!c->st) { free(c); return NULL; }

    JF(c->st, 16) = sample_rate;
    juno_chorus_init(c->st);
    juno_engine_init(c->st);
    juno_runtime_coeffs_apply(c->st);
    c->chorus_mode = chorus_mode;
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

/* Note driver (src/juno_note.c). Opens the ADSR gate + sets DCO pitch on voice
 * 0. NOTE: the gate mechanism and pitch value are the honest HACK/calibration
 * documented in juno_note.c — timbre coefficients loaded by apply_bank ARE
 * bit-exact, but the note-on write itself is not yet a faithful port. */
void juno_gui_note_on(juno_ctx *c, int midi_note, int velocity)
{
    if (c) juno_note_on(c->st, 0, midi_note, velocity);
}
void juno_gui_note_off(juno_ctx *c)
{
    if (c) juno_note_off(c->st, 0);
}

/* Apply bank patch `idx` (raw KoaBankFile00003 bytes in `bank`, `len` bytes)
 * into this engine's coefficient slots via the bit-exact applier
 * (src/juno_apply.c). Returns # coefficients set. The bound subset is
 * reproduced EXACTLY (curve LUTs proven vs the real machine code); unbound
 * params keep their current (engine-default) value. */
int juno_gui_apply_bank(juno_ctx *c, const unsigned char *bank, int len, int idx)
{
    if (!c || !bank || len <= 0) return 0;
    return juno_bank_apply(c->st, bank, idx);
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
    int i;
    if (!c) return 0;
    for (i = 0; i < nframes; ++i) {
        float vb = 0.0f, vr = 0.0f;
        juno_note_tick(c->st);
        juno_voice_render(c->st, &vb, &vr);   /* voice 0, exact */
        out[2 * i]     = vb;                   /* mono voice -> both channels */
        out[2 * i + 1] = vb;
    }
    return 1;
}
