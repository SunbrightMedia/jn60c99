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
    int voice_note[JUNO_NUM_VOICES];   /* MIDI note per voice, -1 = free (env done) */
    unsigned char voice_gated[JUNO_NUM_VOICES];/* 1 = note held (gate on), 0 = released */
    unsigned voice_age[JUNO_NUM_VOICES];/* allocation order (LRU; higher = newer)    */
    unsigned age_counter;

    /* Arpeggiator (host-side note sequencer). The JUNO-60's own arp is a simple
     * monophonic step sequencer over the held keys: modes UP / DOWN / UP&DOWN,
     * range 1-3 octaves. The plugin's CArpeggio is host code (not a DSP coeff),
     * and the per-preset arp on/mode/rate live in the un-decodable extended
     * record region, so this reproduces the arp BEHAVIOUR with explicit controls
     * rather than per-preset recall. When off, note-on/off drive the synth
     * directly (unchanged). When on, keys feed the held set and the clock steps
     * the pattern into the voice allocator. */
    int   arp_on;          /* 0/1                                              */
    int   arp_mode;        /* 0=up, 1=down, 2=up&down                          */
    int   arp_oct;         /* octave range 1..3                                */
    float arp_rate_hz;     /* steps per second                                 */
    float arp_gate;        /* note-on fraction of the step (0..1), rest = off  */
    int   arp_held[16];    /* currently held keys, ascending                   */
    int   arp_nheld;
    int   arp_seq[48];     /* expanded step pattern (held x octaves x mode)     */
    int   arp_nseq;
    int   arp_step;        /* index into arp_seq of the sounding step           */
    int   arp_cur;         /* MIDI note currently sounding (-1 = none)          */
    double arp_clk;        /* sample accumulator within the current step        */
    int   arp_gated;       /* 1 while the current step's note is on             */
} juno_ctx;

/* Reset the global REVERB send to its juno_engine_init value (OFF).
 *
 * The runtime_coeffs baseline was CAPTURED from "PD The Juno Pad" — a pad drenched
 * in reverb — so it carries REVERB LEVEL (off 10759408) = 1.0 (fully wet). That is a
 * per-patch FRONT-PANEL value (the runtime_coeffs_data.c header calls these captured
 * front-panel offsets "only a placeholder"), NOT a global default: juno_engine_init
 * leaves it 0.0, and per-patch recall (juno_apply_reverb) sets it from the loaded
 * patch. Left at the pad's 1.0 it drenches EVERY default/unapplied sound, so the wet
 * reverb tank swells on every note — masking the (bit-exact, fast) voice attack as a
 * slow ~240 ms swell, darkening the timbre, and washing the arpeggiator into mush.
 * We restore the init/off default; a bank patch's own reverb still recalls on Apply. */
#define JUNO_REVERB_SEND 10759408u
static void default_fx_off(unsigned char *st)
{
    JF(st, JUNO_REVERB_SEND) = 0.0f;   /* init value; per-patch recall re-enables it */
}

/* Create + fully init an engine. sample_rate should be 96000 to match the
 * captured patch. Returns NULL on alloc failure. */
juno_ctx *juno_gui_create(float sample_rate, int chorus_mode)
{
    juno_ctx *c = calloc(1, sizeof *c);
    int v;
    if (!c) return NULL;
    c->st = calloc(1, JUNO_STATE_BYTES);
    if (!c->st) { free(c); return NULL; }

    juno_enable_hw_ftz();                /* run in the plugin's SSE FTZ/DAZ mode (x86) */
    JF(c->st, 16) = sample_rate;
    juno_chorus_init(c->st);
    juno_engine_init(c->st);
    juno_runtime_coeffs_apply(c->st);
    default_fx_off(c->st);               /* dry default (see default_fx_off) */
    juno_driver_seed_voices(c->st);      /* all 8 voices carry the same coeffs */
    c->chorus_mode = chorus_mode;
    for (v = 0; v < JUNO_NUM_VOICES; ++v) c->voice_note[v] = -1;
    /* arp defaults: off, UP, 1 octave, 1/8-note-ish at ~120 BPM, 50% gate */
    c->arp_mode = 0; c->arp_oct = 1; c->arp_rate_hz = 8.0f; c->arp_gate = 0.5f;
    c->arp_cur = -1; c->arp_step = 0;
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
    default_fx_off(c->st);
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

/* --- internal synth triggers (drive the 8-voice allocator directly) --------- */
/* Faithful transcription of the plugin's voice allocator CAssignJu60/CAssignB
 * (ctor sub_7FF91DFB59D0, poly alloc sub_7FF91DFB3150; see docs/CONTROL_LAYER_PORT.md).
 * 8 voices, LRU (age = allocation order, higher = newer). Note-on picks a voice in
 * strict priority: (1) a voice already playing this note (re-strike), (2) the OLDEST
 * FREE voice (envelope finished), (3) the OLDEST voice in RELEASE (gate off but still
 * ringing), (4) STEAL the oldest voice. This "prefer free over release" ordering is
 * what preserves release tails until a voice is genuinely needed. The picked voice
 * gets M.CV / M.Gate / DCO-latch written immediately by juno_note_on (all en=0). */
#define VCA_ENV_OFF 3072          /* per-voice amp-ADSR integrator (voice base rel.) */
#define REAP_EPS    1.0e-3f       /* below this the release is over -> voice is free */

/* Free any released voice whose amp envelope has decayed to silence (the plugin's
 * assigner clears a voice once its envelope completes). Call once per render block. */
static void synth_reap(juno_ctx *c)
{
    int v;
    for (v = 0; v < JUNO_NUM_VOICES; ++v)
        if (c->voice_note[v] >= 0 && !c->voice_gated[v]) {
            unsigned b = (unsigned)v * JUNO_VOICE_MAIN_STRIDE;
            float env = JF(c->st, b + VCA_ENV_OFF);
            if (env < REAP_EPS && env > -REAP_EPS) c->voice_note[v] = -1;
        }
}

/* Pick the lowest-age (oldest) voice matching predicate class, or -1. */
static int pick_oldest(juno_ctx *c, int want_assigned, int want_gated)
{
    int v, pick = -1; unsigned oldest = 0;
    for (v = 0; v < JUNO_NUM_VOICES; ++v) {
        int assigned = c->voice_note[v] >= 0;
        if (assigned != want_assigned) continue;
        if (assigned && (int)c->voice_gated[v] != want_gated) continue;
        if (pick < 0 || c->voice_age[v] < oldest) { oldest = c->voice_age[v]; pick = v; }
    }
    return pick;
}

static void synth_note_on(juno_ctx *c, int midi_note, int velocity)
{
    int v, pick = -1;
    /* 1. same-note reuse */
    for (v = 0; v < JUNO_NUM_VOICES; ++v)
        if (c->voice_note[v] == midi_note) { pick = v; break; }
    /* 2. oldest FREE (env done)  3. oldest RELEASE (gate off, ringing)  4. steal oldest active */
    if (pick < 0) pick = pick_oldest(c, 0, 0);          /* free: unassigned */
    if (pick < 0) pick = pick_oldest(c, 1, 0);          /* release: assigned, not gated */
    if (pick < 0) pick = pick_oldest(c, 1, 1);          /* steal: assigned, gated */
    if (pick < 0) pick = 0;                             /* fallback */
    c->voice_note[pick]  = midi_note;
    c->voice_gated[pick] = 1;
    c->voice_age[pick]   = ++c->age_counter;
    juno_note_on(c->st, pick, midi_note, velocity);
}
static void synth_note_off(juno_ctx *c, int midi_note)
{
    int v;
    for (v = 0; v < JUNO_NUM_VOICES; ++v)
        if ((c->voice_note[v] == midi_note && c->voice_gated[v]) ||
            (midi_note < 0 && c->voice_note[v] >= 0)) {
            juno_note_off(c->st, v);           /* M.Gate -> 0 immediate (release) */
            c->voice_gated[v] = 0;             /* keep the note assigned until the env decays */
        }
}

/* --- arpeggiator ------------------------------------------------------------ */
/* Rebuild the step pattern from the currently-held keys, octave range and mode.
 * UP: keys low->high across the octave range; DOWN: reverse; UP&DOWN: up then
 * down without repeating the top/bottom (the JUNO-60's own up-and-down feel). */
static void arp_rebuild_seq(juno_ctx *c)
{
    int n = 0, o, i;
    int up[48], nup = 0;
    for (o = 0; o < c->arp_oct; ++o)
        for (i = 0; i < c->arp_nheld; ++i)
            if (nup < 48) up[nup++] = c->arp_held[i] + 12 * o;
    if (c->arp_mode == 1) {                 /* DOWN */
        for (i = nup - 1; i >= 0; --i) c->arp_seq[n++] = up[i];
    } else if (c->arp_mode == 2) {          /* UP & DOWN */
        for (i = 0; i < nup; ++i) c->arp_seq[n++] = up[i];
        for (i = nup - 2; i >= 1; --i) if (n < 48) c->arp_seq[n++] = up[i];
    } else {                                /* UP (default) */
        for (i = 0; i < nup; ++i) c->arp_seq[n++] = up[i];
    }
    c->arp_nseq = n;
    if (c->arp_step >= n) c->arp_step = 0;
}
/* silence any sounding arp note */
static void arp_note_off(juno_ctx *c)
{
    if (c->arp_cur >= 0) { synth_note_off(c, c->arp_cur); c->arp_cur = -1; }
    c->arp_gated = 0;
}
/* Advance the arp clock by one sample; trigger/release steps as the clock rolls.
 * Called once per rendered sample when the arp is enabled. */
static void arp_tick(juno_ctx *c)
{
    double sr = JF(c->st, 16); if (sr <= 0.0) sr = 96000.0;
    double step_samples = sr / (c->arp_rate_hz > 0.1f ? c->arp_rate_hz : 0.1f);
    double gate_samples = step_samples * (double)c->arp_gate;
    if (c->arp_nseq == 0) { arp_note_off(c); c->arp_clk = 0.0; return; }
    /* note-off partway through the step (gate), then next note at the boundary */
    if (c->arp_gated && c->arp_clk >= gate_samples) arp_note_off(c);
    if (c->arp_clk >= step_samples || c->arp_cur < 0) {
        c->arp_clk = 0.0;
        arp_note_off(c);
        if (c->arp_step >= c->arp_nseq) c->arp_step = 0;
        c->arp_cur = c->arp_seq[c->arp_step];
        synth_note_on(c, c->arp_cur, 100);
        c->arp_gated = 1;
        c->arp_step = (c->arp_step + 1) % c->arp_nseq;
    }
    c->arp_clk += 1.0;
}

/* Public note-on: routes to the arp held-set when enabled, else the synth. */
void juno_gui_note_on(juno_ctx *c, int midi_note, int velocity)
{
    int i, j;
    if (!c) return;
    if (!c->arp_on) { synth_note_on(c, midi_note, velocity); return; }
    for (i = 0; i < c->arp_nheld; ++i) if (c->arp_held[i] == midi_note) return; /* dup */
    if (c->arp_nheld >= 16) return;
    for (i = 0; i < c->arp_nheld && c->arp_held[i] < midi_note; ++i) ;   /* insert sorted */
    for (j = c->arp_nheld; j > i; --j) c->arp_held[j] = c->arp_held[j-1];
    c->arp_held[i] = midi_note; c->arp_nheld++;
    arp_rebuild_seq(c);
}

/* Public note-off. midi_note < 0 releases everything. */
void juno_gui_note_off(juno_ctx *c, int midi_note)
{
    int i, j;
    if (!c) return;
    if (!c->arp_on) { synth_note_off(c, midi_note); return; }
    if (midi_note < 0) { c->arp_nheld = 0; }
    else for (i = 0; i < c->arp_nheld; ++i)
        if (c->arp_held[i] == midi_note) {
            for (j = i; j < c->arp_nheld - 1; ++j) c->arp_held[j] = c->arp_held[j+1];
            c->arp_nheld--; break;
        }
    arp_rebuild_seq(c);
    if (c->arp_nheld == 0) arp_note_off(c);
}

/* Configure the arpeggiator. on: 0/1. mode: 0=up,1=down,2=up&down. oct: 1..3.
 * rate_hz: steps/sec. gate: note-on fraction of a step (0..1). Toggling off
 * flushes held keys + any sounding step so the synth returns to direct play. */
void juno_gui_arp_config(juno_ctx *c, int on, int mode, int oct, float rate_hz, float gate)
{
    int was;
    if (!c) return;
    was = c->arp_on;
    c->arp_mode = mode < 0 ? 0 : (mode > 2 ? 2 : mode);
    c->arp_oct  = oct  < 1 ? 1 : (oct  > 3 ? 3 : oct);
    if (rate_hz > 0.1f) c->arp_rate_hz = rate_hz;
    if (gate >= 0.0f && gate <= 1.0f) c->arp_gate = gate;
    c->arp_on = on ? 1 : 0;
    if (was && !c->arp_on) {                 /* turning off: clear everything */
        arp_note_off(c); c->arp_nheld = 0; c->arp_nseq = 0; c->arp_step = 0;
        synth_note_off(c, -1);
    }
    if (!was && c->arp_on) {                  /* turning on: silence direct notes */
        synth_note_off(c, -1);
        c->arp_nheld = 0; c->arp_nseq = 0; c->arp_step = 0; c->arp_cur = -1; c->arp_clk = 0.0;
    }
    arp_rebuild_seq(c);
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
    synth_reap(c);                         /* free voices whose release has decayed */
    for (i = 0; i < nframes; ++i) {
        if (c->arp_on) arp_tick(c);        /* step the arp pattern in real time */
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
    synth_reap(c);                         /* free voices whose release has decayed */
    for (i = 0; i < nframes; ++i) {
        float mix = 0.0f;
        if (c->arp_on) arp_tick(c);        /* keep the arp advancing in the dry path too */
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
