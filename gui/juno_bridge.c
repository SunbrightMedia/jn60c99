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
#include "../src/juno_curve.h"
#include "../src/juno_note.h"
#include "../src/delay_recall.h"
#include "../src/carp.h"
#include <stdlib.h>

typedef struct {
    unsigned char *st;
    struct juno_host_shim shim;   /* must outlive render calls */
    int chorus_mode;
    int voice_note[JUNO_NUM_VOICES];   /* MIDI note per voice, -1 = free (env done) */
    unsigned char voice_gated[JUNO_NUM_VOICES];/* 1 = note held (gate on), 0 = released */
    unsigned voice_age[JUNO_NUM_VOICES];/* allocation order (LRU; higher = newer)    */
    unsigned age_counter;

    /* Arpeggiator — the plugin's CArpeggio transcribed BIT-EXACTLY in src/carp.c
     * (UP / UP&DOWN / DOWN ordering, octave range, 24-PPQN tempo clock, gate — all
     * traced to the binary; see docs/ARP_PROVENANCE.md). `arp_on` is a driver
     * flag: when set, note-on/off feed the arp's held set and carp_tick sequences
     * steps into the voice allocator once per rendered sample; when clear, notes
     * drive the synth directly. The JUNO arp is host-tempo-synced (no per-patch
     * rate), so the standalone supplies a BPM + note division. */
    int   arp_on;          /* 0/1 (driver routes notes through the arp when set) */
    int   arp_cur;         /* MIDI note currently sounding via the arp (-1 none) */
    carp  arp;             /* bit-exact CArpeggio state machine                 */
} juno_ctx;

/* FX power-on default for the UNAPPLIED sound.
 *
 * The ENV-attack part of the old default_patch is gone: juno_engine_prepare now
 * writes the binary's genuine power-on envelope coefficients (attack 3.555611,
 * etc.), so the default speaks with the plugin's real default envelope — no more
 * hand fast-attack.
 *
 * The one remaining reset is the REVERB SEND (10759408). The captured baseline
 * (from "PD The Juno Pad", a fully-wet reverb pad) carries 1.0 here, washing every
 * unapplied note. The plugin's genuine power-on value is 0.0: the effect-parameter
 * storage cells are all zero after BUILD + setSampleRate (verified under emulation —
 * see scratchpad/oracle/effect_prepare_findings.md; the FX params are only written
 * by per-patch recall). So 0.0 is the binary default, not a hand-fitted taste value,
 * and a loaded patch's own reverb still recalls exactly on Apply. */
#define JUNO_REVERB_SEND 10759408u
static void default_patch(unsigned char *st)
{
    JF(st, JUNO_REVERB_SEND) = 0.0f;          /* binary power-on default (FX cell = 0) */
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
    juno_engine_init(c->st);             /* constructor state (sub_1803990C0)              */
    juno_engine_prepare(c->st);          /* setSampleRate + snap-all prepared state — the
                                          * complete binary-derived voice + master/FX
                                          * baseline (no capture; see src/juno_prepare.c) */
    default_patch(c->st);                /* FX power-on default (reverb off)               */
    juno_driver_seed_voices(c->st);      /* all 8 voices carry the same coeffs             */
    c->chorus_mode = chorus_mode;
    for (v = 0; v < JUNO_NUM_VOICES; ++v) c->voice_note[v] = -1;
    /* arp: bit-exact CArpeggio, off by default. carp_init seeds power-on state
     * (empty keyboard, UP, 1 octave, 120 BPM, eighth-note clock); give it a
     * musical 60% gate default (index 3). */
    carp_init(&c->arp);
    carp_set_gate_index(&c->arp, 3);
    c->arp_on = 0;
    c->arp_cur = -1;
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

/* Reset to the engine's binary power-on state (the plugin's own default patch):
 * re-run the constructor + the setSampleRate/snap-all prepared baseline. No
 * capture is involved — this is the genuine default the plugin boots into. */
void juno_gui_recall_factory(juno_ctx *c)
{
    juno_engine_init(c->st);             /* constructor state                    */
    juno_engine_prepare(c->st);          /* binary prepared baseline (no capture) */
    default_patch(c->st);
    /* clean slot-1 (v39): no stale DELAY TYPE from a prior patch */
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

/* --- arpeggiator (bit-exact CArpeggio, src/carp.c) -------------------------- */
/* The step ordering, octave fold, insertion-sorted held-note list, velocity math
 * and 24-PPQN clock are all transcribed from the plugin (see src/carp.c and
 * docs/ARP_PROVENANCE.md). This bridge only routes MIDI into the arp's held
 * set and drains the events carp_tick emits into the 8-voice allocator. */

/* Map a 0..1 gate fraction to the nearest entry of the plugin's GATE table
 * {30,40,50,60,70,80,90,100,120,0}% — the arp reads a table INDEX, not a
 * fraction, so the UI's continuous gate is quantised to the machine's steps. */
static int gate_frac_to_index(float g)
{
    int pct = (int)(g * 100.0f + 0.5f), best = 0, bestd = 1000, i;
    for (i = 0; i < 10; ++i) {
        int d = pct - (int)CARP_GATE_TABLE[i];
        if (d < 0) d = -d;
        if (d < bestd) { bestd = d; best = i; }
    }
    return best;
}

/* Drain one sample's worth of arp events into the voice allocator. Called once
 * per rendered sample when the arp is enabled: carp_tick emits note-offs before
 * note-ons at each gate/step boundary, exactly as the plugin's clock does. */
static void arp_tick(juno_ctx *c)
{
    double sr = JF(c->st, 16); if (sr <= 0.0) sr = 96000.0;
    carp_event ev[4];
    int i, n = carp_tick(&c->arp, sr, ev, 4);
    for (i = 0; i < n; ++i) {
        if (ev[i].kind == 0) {                          /* note-off */
            synth_note_off(c, ev[i].note);
            if (ev[i].note == c->arp_cur) c->arp_cur = -1;
        } else {                                        /* note-on  */
            synth_note_on(c, ev[i].note, ev[i].velocity);
            c->arp_cur = ev[i].note;
        }
    }
}

/* Public note-on: feeds the arp's held-key set when enabled, else the synth. */
void juno_gui_note_on(juno_ctx *c, int midi_note, int velocity)
{
    if (!c) return;
    if (!c->arp_on) { synth_note_on(c, midi_note, velocity); return; }
    carp_add_key(&c->arp, midi_note, velocity);
}

/* Public note-off. midi_note < 0 releases everything. */
void juno_gui_note_off(juno_ctx *c, int midi_note)
{
    if (!c) return;
    if (!c->arp_on) { synth_note_off(c, midi_note); return; }
    carp_remove_key(&c->arp, midi_note);     /* midi_note < 0 => release all */
}

/* Configure the arpeggiator. on: 0/1. mode: 0=up,1=down,2=up&down (the UI/patch
 * convention). oct: 1..3. bpm: host tempo (<=0 keeps the current tempo — the
 * plugin's arp is host-synced, so BPM is a host input, not a patch value). gate:
 * note-on fraction 0..1, quantised to the machine's GATE table (<0 keeps current).
 * Toggling on/off flushes held keys + any sounding step so play stays clean. */
void juno_gui_arp_config(juno_ctx *c, int on, int mode, int oct, float bpm, float gate)
{
    int was, type;
    if (!c) return;
    was = c->arp_on;
    /* UI mode (0=up,1=down,2=up&down) -> CArpeggio TYPE (0=UP,1=UP&DOWN,2=DOWN). */
    type = (mode == 1) ? CARP_TYPE_DOWN : (mode == 2) ? CARP_TYPE_UPDOWN : CARP_TYPE_UP;
    carp_set_mode(&c->arp, type);
    /* UI octaves 1..3 -> ARPEGGIO STEP 0..2 (carp_set_range maps step->range). */
    carp_set_range(&c->arp, (oct < 1 ? 1 : (oct > 3 ? 3 : oct)) - 1);
    if (bpm > 0.0f) carp_set_bpm(&c->arp, (double)bpm);
    if (gate >= 0.0f) carp_set_gate_index(&c->arp, gate_frac_to_index(gate));
    c->arp_on = on ? 1 : 0;
    if (was != c->arp_on) {                  /* on the toggle: flush everything */
        synth_note_off(c, -1);
        carp_remove_key(&c->arp, -1);
        c->arp_cur = -1;
    }
}

/* Apply bank patch `idx` (raw KoaBankFile00003 bytes in `bank`, `len` bytes)
 * into this engine's coefficient slots via the bit-exact applier
 * (src/juno_apply.c). Returns # coefficients set. The bound subset is
 * reproduced EXACTLY (curve LUTs proven vs the real machine code); unbound
 * params keep their current (engine-default) value. */
int juno_gui_apply_bank(juno_ctx *c, const unsigned char *bank, int len, int idx)
{
    int n, mode = 0, oct = 1, on;
    if (!c || !bank || len <= 0) return 0;
    n = juno_bank_apply(c->st, bank, idx);
    juno_driver_seed_voices(c->st);      /* all 8 voices play the applied patch */
    /* Per-patch ARPEGGIATOR recall: on/mode/range come from the patch (bit-exact,
     * see juno_bank_arp); rate stays local (the plugin's arp is host-tempo-synced,
     * no per-patch rate). This makes "arp presets" arpeggiate on load. */
    on = juno_bank_arp(bank, idx, &mode, &oct);
    juno_gui_arp_config(c, on, mode, oct, -1.0f, -1.0f);  /* keep UI bpm/gate */
    return n;
}

/* Packed arp state for the UI to read back after apply: bit0 = on, bits1-2 = mode
 * (0=up,1=down,2=up&down), bits3-4 = oct-1 (0..2). Lets the web UI sync its arp
 * toggle/mode/octave controls to a recalled patch. */
int juno_gui_get_arp(juno_ctx *c)
{
    int mode, oct;
    if (!c) return 0;
    /* CArpeggio TYPE -> UI mode (0=up,1=down,2=up&down); range -> octaves. */
    mode = (c->arp.type == 0) ? 0 : (c->arp.type == 1) ? 2 : 1;
    oct  = c->arp.range + 1;
    return (c->arp_on ? 1 : 0) | ((mode & 3) << 1) | (((oct - 1) & 3) << 3);
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
