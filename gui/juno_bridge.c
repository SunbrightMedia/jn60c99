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
#include "../src/hpf_type_lut.h"
#include "../src/juno_curve.h"
#include "../src/juno_note.h"
#include "../src/delay_recall.h"
#include "../src/carp.h"
#include <stdlib.h>
#include <string.h>

typedef struct {
    unsigned char *st;
    struct juno_host_shim shim;   /* must outlive render calls */
    int chorus_mode;
    int voice_note[JUNO_NUM_VOICES];   /* MIDI note per voice, -1 = free (env done) */
    unsigned char voice_gated[JUNO_NUM_VOICES];/* 1 = note held (gate on), 0 = released */
    unsigned voice_age[JUNO_NUM_VOICES];/* allocation order (LRU; higher = newer)    */
    unsigned age_counter;

    /* Voice-assign modes (CAssignJu60, transcribed from the binary — see
     * docs/VOICE_MODES.md / scratchpad/oracle/assign_modes_findings.md). Recalled
     * per patch by juno_bank_voice_modes():
     *   assign_mode 0 = POLY, 1 = MONO (voice 0), 2 = UNISON (all 8), 3 = POLY-variant.
     *   legato + portamento_on gate the poly legato-glide (§4.3) and the mono/unison
     *   overlap-legato / low-note-release fallback. held_notes = 128-bit MIDI held
     *   mask (scanned lowest-first for the mono/unison release fallback). */
    int assign_mode;                    /* 0..3 */
    int legato;                         /* 0/1  */
    int portamento_on;                  /* 0/1 (PORTAMENTO byte != 0) */
    unsigned held_notes[4];             /* bit n = MIDI note n currently held */

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

    /* LFO RATE front-panel byte of the loaded patch (blob 8), stashed so a host
     * tempo change can recompute the tempo-synced LFO rate (cell 1072). The
     * plugin feeds 1072 = curve48[byte] x curve53[BPM*10] from host tempo; 34/64
     * factory patches sync the LFO to it. See juno_apply_lfo_tempo. */
    int   lfo_rate_byte;

    /* DELAY tempo-sync inputs of the loaded patch (DELAY TIME byte blob 53, TEMPO
     * SYNC blob 59 != 0, DELAY TYPE record 650), stashed so a host tempo change can
     * recompute the tempo-synced delay time (102352 + the type-1/5 instance cell)
     * via juno_apply_delay_tempo — the delay sibling of the LFO plumbing above. */
    int   dly_time_byte;
    int   dly_sync;
    int   dly_type;

    /* Recalled HPF TYPE (record 618). The 4 HPF cells are a JOINT function of
     * (cutoff byte, TYPE); the plugin's LIVE blob-38 leaf dispatch recomputes them
     * with the patch's current TYPE (fuzz seeds 49/52/58 — the port's TYPE=0 panel
     * curves were wrong on the 10 TYPE=1 patches). Used by juno_gui_set_param. */
    int   hpf_type;

    /* Last CONDITION byte applied (128 at power-on, patch value on recall). Used by
     * apply_bank recall; a live per-parameter edit (juno_gui_set_param) does NOT
     * re-apply it — the plugin's live param dispatch writes only the target cell. */
    int   last_condition;

    /* Host tempo in BPM. 128 = the plugin's recall-default TEMPO (param default
     * 880 -> 40+88.0); updated when the host pushes a tempo via juno_gui_arp_config.
     * Distinct from the arp clock's own bpm (carp_init powers on at 120): the
     * plugin re-times tempo-synced FX at the HOST tempo, not the arp power-on
     * value (fuzz seed 57 — a live TEMPO SYNC flip on a non-arp patch must be
     * value-neutral at 128 BPM, not jump to the arp's 120). */
    float host_bpm;

    /* Debug-only arp-event trace (Phase 4 direct arp-audio A/B). When
     * arp_trace_cap > 0, arp_tick appends each fired event as
     * (sample, kind, note, velocity) so a verifier can replay the EXACT
     * schedule the port renders into the plugin oracle (e2e_emu) and A/B the
     * audio. Zero effect on the audio path when arp_trace_cap == 0 (calloc
     * zero-inits it), so shipped builds are unaffected. arp_trace_smp is the
     * running render-sample index. */
    long  arp_trace_smp;
    int   arp_trace_cap;   /* 0 = disabled */
    int   arp_trace_n;
    int  *arp_trace_buf;   /* 4*cap ints: smp, kind, note, vel */

    /* Loaded-patch bank retained (malloc'd copy) so the host-parameter panel can
     * edit a record byte and re-run the EXACT recall (juno_gui_host_set). bank is
     * the whole KoaBankFile00003 image; patch_idx selects the record. NULL until a
     * patch is applied. See juno_bank_record / juno_host_param_encode. */
    unsigned char *bank;
    int   bank_len;
    int   patch_idx;
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
    juno_apply_condition(c->st, 128);    /* default CONDITION -> per-voice analog scatter  */
    c->last_condition = 128;
    c->chorus_mode = chorus_mode;
    for (v = 0; v < JUNO_NUM_VOICES; ++v) c->voice_note[v] = -1;
    /* arp: bit-exact CArpeggio, off by default. carp_init seeds the plugin's
     * power-on arp state exactly: UP, 1 octave, 120 BPM, and — the binary defaults —
     * the RATE table at rate_index 4 (sixteenth notes) and gate index 7 (100%). No
     * override here: the earlier gate-index 3 (60%) was wrong (arp_rate_findings.md). */
    carp_init(&c->arp);
    c->arp_on = 0;
    c->arp_cur = -1;
    c->host_bpm = 128.0f;   /* plugin recall-default TEMPO (880 -> 40+88.0) */
    juno_driver_attach_host(c->st, &c->shim, chorus_mode);
    return c;
}

/* Diagnostic: copy the current per-voice allocation into caller arrays (each of
 * length JUNO_NUM_VOICES). notes[v] = MIDI note or -1 (free); gated[v] = 1 if the
 * gate is on. Returns the number of currently-gated voices. For tests/UI only. */
int juno_gui_debug_voices(juno_ctx *c, int *notes, unsigned char *gated)
{
    int v, ng = 0;
    if (!c) return 0;
    for (v = 0; v < JUNO_NUM_VOICES; ++v) {
        if (notes) notes[v] = c->voice_note[v];
        if (gated) gated[v] = c->voice_gated[v];
        if (c->voice_gated[v]) ++ng;
    }
    return ng;
}

void juno_gui_destroy(juno_ctx *c)
{
    if (!c) return;
    free(c->bank);
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

/* Raw 32-bit cell access — exact bit patterns, no float conversion. Needed by
 * the verification harness: integer counters, denormals and NaN payloads do not
 * survive a float round-trip through juno_gui_set/get. */
void juno_gui_poke(juno_ctx *c, int off, unsigned int bits)
{
    if (off >= 0 && (unsigned)off + 4 <= JUNO_STATE_BYTES)
        memcpy(c->st + off, &bits, 4);
}

unsigned int juno_gui_peek(juno_ctx *c, int off)
{
    unsigned int bits = 0;
    if (off >= 0 && (unsigned)off + 4 <= JUNO_STATE_BYTES)
        memcpy(&bits, c->st + off, 4);
    return bits;
}

/* Bulk-copy the raw engine state (verification harness only — the cold-state A/B
 * gate reads the whole state in one shot instead of millions of peek() calls).
 * Copies min(nbytes, JUNO_STATE_BYTES) bytes starting at byte offset `off`. */
int juno_gui_dump(juno_ctx *c, int off, unsigned char *out, int nbytes)
{
    unsigned int end;
    if (!c || !out || off < 0 || nbytes <= 0) return 0;
    end = (unsigned)off + (unsigned)nbytes;
    if (end > JUNO_STATE_BYTES) end = JUNO_STATE_BYTES;
    if ((unsigned)off >= end) return 0;
    memcpy(out, c->st + off, end - (unsigned)off);
    return (int)(end - (unsigned)off);
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
    juno_apply_condition(c->st, 128);    /* default CONDITION -> per-voice analog scatter */
    c->last_condition = 128;
    juno_driver_attach_host(c->st, &c->shim, c->chorus_mode);
}

/* --- Per-parameter "0..255 byte -> parameter" setter (the interface for the final
 * port: a raw panel value goes in, the engine coefficient changes bit-exactly). ---
 * juno_gui_param_count / _name / _offset enumerate the exposed panel parameters (the
 * juno_apply.c BINDINGS table); juno_gui_set_param applies a raw 0..255 byte to one of
 * them through the plugin's own value-tree dispatch and makes it audible on all voices.
 */
int juno_gui_param_count(void) { return juno_param_count(); }

const char *juno_gui_param_name(int i) { return juno_param_name(i); }

int juno_gui_param_offset(int i) { return juno_param_offset(i); }

/* Value-tree blob position of exposed panel param `i`. The patch record stores each
 * leaf as a nibble-pair, so the raw 0..255 byte for this param lives at record byte
 * 2*blob_pos — the web panel uses this to show each slider at the LOADED patch's
 * value (dec(record, 2*blob)) and to dedupe params that share a blob (HPF, PORTA). */
int juno_gui_param_blob(int i) { return juno_param_blob(i); }

/* Apply raw byte (0..255) to panel parameter `param_index`, bit-exact via the recall
 * dispatch, then propagate to all 8 voices as the plugin's LIVE param dispatch does:
 * write the SAME engine float into every voice's copy of that ONE cell and touch
 * NOTHING else. Returns the engine float written.
 *
 * A live param move is NOT a recall. Measured from the plugin's own dispatch under
 * emulation (phase-2 matrix Scenario E): a live parameter change writes only the
 * target cell — 8 per-voice copies at stride JUNO_VOICE_MAIN_STRIDE for a per-voice
 * param, or the single master cell for a master param (e.g. VCA LEVEL @101072) —
 * with 0 smoothers armed, and does NOT re-seed the voices or re-apply CONDITION.
 * The former seed_voices() (whole-block copy voice0->1..7) + apply_condition() reset
 * every voice's evolved runtime state (envelope/LFO phase, drift tables) to voice 0's
 * / recall-time values, so any live move mid-note snapped the sound; this replicates
 * only the changed cell, leaving each voice's independent evolution intact. */
float juno_gui_set_param(juno_ctx *c, int param_index, int byte)
{
    int Hr, blob, i, n;
    float w = 0.0f;
    if (!c) return 0.0f;
    Hr = (int)JF(c->st, 16); if (Hr <= 0) Hr = 96000;
    blob = juno_param_blob(param_index);
    if (blob < 0) return 0.0f;
    /* LEAF semantics: the plugin's value tree dispatches whole leaves — one panel
     * change writes EVERY binding row sharing the blob byte (HPF blob 38 = 4 rows,
     * PORTAMENTO blob 54 = 2 rows; measured under emulation: a single HPF dispatch
     * writes 4 cells x 8 voice strides, and the port's per-row values reproduce the
     * plugin's bits exactly — Phase-3 fuzz triage, seeds 0/1/2). Expanding here
     * makes every consumer (GUI, fuzzer, MIDI CC mapping) faithful by default. */
    n = juno_param_count();
    for (i = 0; i < n; ++i) {
        if (juno_param_blob(i) == blob) {
            int off = juno_param_offset(i), v;
            float wi = juno_apply_param(c->st, i, byte, Hr); /* voice-0 / master cell */
            /* Per-voice cell (voice-0 block): replicate the identical value to
             * voices 1..7. Master cells are written once by juno_apply_param. */
            if (off >= 176 && off < 176 + JUNO_VOICE_MAIN_STRIDE)
                for (v = 1; v < JUNO_NUM_VOICES; ++v)
                    JF(c->st, (unsigned)off + (unsigned)v * JUNO_VOICE_MAIN_STRIDE) = wi;
            if (i == param_index) w = wi;
        }
    }
    /* HPF leaf (blob 38): the 4 cells are a JOINT function of (cutoff byte, HPF
     * TYPE). The rows above wrote the TYPE=0 panel-curve values; recompute with the
     * patch's recalled TYPE exactly as the plugin's live dispatch does (fuzz seeds
     * 49/52/58: plugin's written 10240 bits == juno_apply_hpf_type(byte, TYPE=1)
     * bit-for-bit; probe made all three seeds bit-exact end-to-end). TYPE=0 makes
     * this a no-op re-write of the same values. */
    if (blob == 38) {
        static const int HPF_CELLS[4] = { 10240, 10256, 10272, 10288 };
        int k, v;
        juno_apply_hpf_type(c->st, byte & 0xFF, c->hpf_type);   /* voice-0 cells */
        for (k = 0; k < 4; ++k)
            for (v = 1; v < JUNO_NUM_VOICES; ++v)
                JF(c->st, (unsigned)HPF_CELLS[k] + (unsigned)v * JUNO_VOICE_MAIN_STRIDE) =
                    JF(c->st, (unsigned)HPF_CELLS[k]);
    }
    /* TEMPO SYNC leaf (blob 59): a live flip re-times the ACTIVE slot-1 delay
     * instance (synced at host BPM on engage, the patch's manual time on
     * disengage) — measured law in juno_live_delay_sync; the base cell 102352 is
     * deliberately NOT touched on a live flip (fuzz seed 70). Host BPM = the HOST
     * tempo (recall default 128), NOT the arp clock's power-on 120 (fuzz seed 57:
     * the plugin's flip at 128 BPM is value-neutral on a division that matches the
     * patch's manual time; re-timing at 120 re-points the delay read head). */
    if (blob == 59) {
        c->dly_sync = (byte != 0);
        juno_live_delay_sync(c->st, c->dly_time_byte, c->dly_sync, c->dly_type,
                             c->host_bpm);
    }
    return w;
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
/* NOTE->VOICE BINDING IS PERSISTENT — do NOT reap it on envelope decay.
 *
 * An earlier synth_reap() cleared voice_note[v] once a released voice's amp
 * envelope decayed below 1e-3, assuming the plugin's assigner frees the slot.
 * Measured FALSE (fuzz seed 7, plugin's own assigner under emulation): the
 * plugin keeps a last-note-per-voice memory INDEFINITELY — a re-struck note
 * returns to its previous voice even after a full second of silence, while
 * other notes take LRU gate-off voices around it; the binding lives until the
 * voice is reassigned. The port's reap sent the re-strike to a different voice
 * (different CONDITION scatter + free-run DCO phase => audible divergence);
 * removing it makes the seed-7 stream bit-exact (causally proven by forcing
 * the plugin's voice pick). Consumers are safe without the reap: the LRU
 * free-voice scan and by-key note-off classify by voice_gated, not by binding
 * (a released-then-silent voice remains eligible for LRU reuse); only the
 * same-note-reuse scan sees the persistent binding — which is the point. */

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

/* pick the NEWEST (max age) voice matching predicate class, or -1. */
static int pick_newest(juno_ctx *c, int want_assigned, int want_gated)
{
    int v, pick = -1; unsigned newest = 0;
    for (v = 0; v < JUNO_NUM_VOICES; ++v) {
        int assigned = c->voice_note[v] >= 0;
        if (assigned != want_assigned) continue;
        if (assigned && (int)c->voice_gated[v] != want_gated) continue;
        if (pick < 0 || c->voice_age[v] > newest) { newest = c->voice_age[v]; pick = v; }
    }
    return pick;
}

/* 128-bit held-note bitmask (mirrors the assigner's a1[20..23]). */
static void held_set(juno_ctx *c, int n)   { if (n>=0 && n<128) c->held_notes[n>>5] |=  (1u<<(n&31)); }
static void held_clear(juno_ctx *c, int n) { if (n>=0 && n<128) c->held_notes[n>>5] &= ~(1u<<(n&31)); }
static int  held_lowest(juno_ctx *c)       /* lowest still-held MIDI note, or -1 */
{
    int w, b;
    for (w = 0; w < 4; ++w)
        if (c->held_notes[w])
            for (b = 0; b < 32; ++b)
                if (c->held_notes[w] & (1u << b)) return (w << 5) | b;
    return -1;
}

/* Trigger one voice with a full gate edge (retrigger) and LRU/bookkeeping update. */
static void voice_trigger(juno_ctx *c, int v, int midi_note, int velocity)
{
    c->voice_note[v]  = midi_note;
    c->voice_gated[v] = 1;
    c->voice_age[v]   = ++c->age_counter;
    juno_note_on(c->st, v, midi_note, velocity);
}

/* MODE 0 POLY (sub_7FF91DFB3150) + MODE 3 POLY-variant (sub_7FF91DFB35C0). The
 * two differ only in voice selection: MODE 0 = same-note reuse (newest) ->
 * oldest-free -> oldest-release -> steal(oldest, or newest if portamento); MODE 3 =
 * first free/release by linear index -> steal, no same-note reuse, no legato glide. */
static void poly_note_on(juno_ctx *c, int midi_note, int velocity, int variant)
{
    int v, pick = -1;
    if (!variant) {                                     /* MODE 0 selection */
        pick = pick_newest(c, 1, 1);                    /* same-note: search gated */
        if (pick >= 0 && c->voice_note[pick] != midi_note) pick = -1;
        if (pick < 0) {                                 /* same-note among any assigned */
            int best = -1; unsigned age = 0, w;
            for (w = 0; w < JUNO_NUM_VOICES; ++w)
                if (c->voice_note[w] == midi_note && (best < 0 || c->voice_age[w] > age))
                    { age = c->voice_age[w]; best = w; }
            pick = best;
        }
        if (pick < 0) {                                 /* least-recently-used GATE-OFF voice.
                                                           The plugin's CAssignJu60 keeps a
                                                           voice-priority list initialised
                                                           [0,1,..,7] and scans it from the TOP
                                                           (slot 7) DOWN, taking the first
                                                           gate-off voice — so from a fresh
                                                           state it allocates 7,6,5,..,0, NOT
                                                           0,1,.. (proven by a running-code diff
                                                           vs CAssignJu60 sub_7FF91DFB3150: 10
                                                           notes -> slots 7..0). Its LRU rule is
                                                           the same "oldest free" as ours; only
                                                           the tie-break differs — highest slot
                                                           index wins, so we scan 7->0. */
            int w; unsigned oldest = 0;
            for (w = JUNO_NUM_VOICES - 1; w >= 0; --w)
                if (!c->voice_gated[w] && (pick < 0 || c->voice_age[w] < oldest))
                    { oldest = c->voice_age[w]; pick = w; }
        }
    } else {                                            /* MODE 3: first free/release, top-down */
        for (v = JUNO_NUM_VOICES - 1; v >= 0; --v)
            if (c->voice_note[v] < 0 || !c->voice_gated[v]) { pick = v; break; }
    }
    if (pick < 0)                                       /* steal: newest if porta, else oldest */
        pick = c->portamento_on ? pick_newest(c, 1, 1) : pick_oldest(c, 1, 1);
    if (pick < 0) pick = 0;

    /* MODE 0 legato+portamento poly-glide (§4.3): drag every OTHER still-gated
     * voice's pitch to the new note without a gate edge. */
    if (!variant && c->legato && c->portamento_on)
        for (v = 0; v < JUNO_NUM_VOICES; ++v)
            if (v != pick && c->voice_gated[v] && c->voice_note[v] >= 0) {
                juno_note_glide(c->st, v, midi_note);
                c->voice_note[v] = midi_note;
            }

    voice_trigger(c, pick, midi_note, velocity);        /* chosen voice always retriggers */
}

/* MODE 1 MONO (sub_7FF91DFB38F0): one fixed voice (0). Overlapping (still-gated)
 * note = legato (pitch+gate refresh, no gate-off retrigger); idle/releasing = full
 * retrigger. Voices 1..7 forced off. */
static void mono_note_on(juno_ctx *c, int midi_note, int velocity)
{
    int v;
    if (!c->voice_gated[0]) {                            /* idle/releasing -> retrigger */
        voice_trigger(c, 0, midi_note, velocity);
    } else {                                             /* legato: pitch move, keep envelope */
        juno_note_glide(c->st, 0, midi_note);
        juno_note_velocity(c->st, 0, velocity);          /* refresh VCF/VCA vel, no gate edge */
        c->voice_note[0] = midi_note;
        c->voice_age[0]  = ++c->age_counter;
    }
    for (v = 1; v < JUNO_NUM_VOICES; ++v)               /* force mono: release the rest */
        if (c->voice_note[v] >= 0) { juno_note_off(c->st, v); c->voice_gated[v] = 0; }
}

/* MODE 2 UNISON (sub_7FF91DFB3B60): all 8 voices on the same note. Whole stack
 * retriggers only when idle; overlapping notes glide the stack. */
static void unison_note_on(juno_ctx *c, int midi_note, int velocity)
{
    int v, was_idle = !c->voice_gated[0];
    for (v = 0; v < JUNO_NUM_VOICES; ++v) {
        if (was_idle) voice_trigger(c, v, midi_note, velocity);
        else { juno_note_glide(c->st, v, midi_note); juno_note_velocity(c->st, v, velocity);
               c->voice_note[v] = midi_note; c->voice_age[v] = ++c->age_counter; }
    }
}

static void synth_note_on(juno_ctx *c, int midi_note, int velocity)
{
    held_set(c, midi_note);
    switch (c->assign_mode) {
        case 1:  mono_note_on(c, midi_note, velocity);      break;
        case 2:  unison_note_on(c, midi_note, velocity);    break;
        case 3:  poly_note_on(c, midi_note, velocity, 1);   break;
        default: poly_note_on(c, midi_note, velocity, 0);   break;
    }
    /* Plugin note-on writes the global "any key held" flag (1856) to EVERY voice,
     * not just the allocated one (see juno_note_broadcast_held). */
    juno_note_broadcast_held(c->st, 1);
}

/* Release all voices playing `key` (or every voice if key < 0). Used by POLY. */
static void poly_release_key(juno_ctx *c, int key)
{
    int v;
    for (v = 0; v < JUNO_NUM_VOICES; ++v)
        if ((c->voice_note[v] == key && c->voice_gated[v]) ||
            (key < 0 && c->voice_note[v] >= 0)) {
            juno_note_off(c->st, v);
            c->voice_gated[v] = 0;                          /* keep assigned until env decays */
        }
}

/* MONO/UNISON note-off: if the released key is the sounding note and another key is
 * still held, glide the voice(s) to the LOWEST held note (low-note priority, no
 * re-gate); else release. `all` = apply to the whole stack (unison) vs voice 0 (mono). */
static void mono_note_off(juno_ctx *c, int key, int all)
{
    int lo, v, last = all ? JUNO_NUM_VOICES : 1;
    if (key >= 0 && c->voice_note[0] != key) return;        /* stale key */
    lo = held_lowest(c);
    if (lo >= 0) {                                          /* fall back to lowest held */
        for (v = 0; v < last; ++v)
            if (c->voice_note[v] >= 0) { juno_note_glide(c->st, v, lo); c->voice_note[v] = lo; }
    } else {                                                /* nothing held -> release */
        for (v = 0; v < last; ++v)
            if (c->voice_note[v] >= 0) { juno_note_off(c->st, v); c->voice_gated[v] = 0; }
    }
}

static void synth_note_off(juno_ctx *c, int midi_note)
{
    held_clear(c, midi_note);
    if (midi_note < 0) { c->held_notes[0]=c->held_notes[1]=c->held_notes[2]=c->held_notes[3]=0; }
    switch (c->assign_mode) {
        case 1:  mono_note_off(c, midi_note, 0);            break;   /* mono: voice 0     */
        case 2:  mono_note_off(c, midi_note, 1);            break;   /* unison: all voices */
        default: poly_release_key(c, midi_note);            break;   /* poly / variant    */
    }
    /* Plugin note-off clears the global held flag (1856) on EVERY voice only when
     * NO key remains held (chord release keeps it at 1.0 everywhere). */
    juno_note_broadcast_held(c->st,
        (c->held_notes[0] | c->held_notes[1] | c->held_notes[2] | c->held_notes[3]) != 0);
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
    /* A dense SCATTER pattern can fire many slots on one tick (each up to a
     * steal-off + self-off + on), plus the pre-step scheduled offs — well over 4.
     * Size for the worst case (16 slots) so no events are dropped. */
    carp_event ev[64];
    int i, n = carp_tick(&c->arp, sr, ev, 64);
    for (i = 0; i < n; ++i) {
        if (c->arp_trace_cap && c->arp_trace_n < c->arp_trace_cap) {
            int *r = c->arp_trace_buf + 4 * c->arp_trace_n++;
            r[0] = (int)c->arp_trace_smp; r[1] = ev[i].kind;
            r[2] = ev[i].note; r[3] = ev[i].velocity;
        }
        if (ev[i].kind == 0) {                          /* note-off */
            synth_note_off(c, ev[i].note);
            if (ev[i].note == c->arp_cur) c->arp_cur = -1;
        } else {                                        /* note-on  */
            synth_note_on(c, ev[i].note, ev[i].velocity);
            c->arp_cur = ev[i].note;
        }
    }
}

/* Debug-only: enable arp-event tracing into caller-owned buf (4*cap ints:
 * sample,kind,note,vel). Returns nothing; read count with juno_gui_arp_trace_count.
 * No audio effect (Phase 4 arp-audio A/B). */
void juno_gui_arp_trace(juno_ctx *c, int *buf, int cap)
{
    if (!c) return;
    c->arp_trace_buf = buf; c->arp_trace_cap = cap;
    c->arp_trace_n = 0; c->arp_trace_smp = 0;
}
int juno_gui_arp_trace_count(juno_ctx *c) { return c ? c->arp_trace_n : 0; }

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
    if (bpm > 0.0f) {
        c->host_bpm = bpm;               /* host tempo, also used by live TEMPO SYNC flips */
        carp_set_bpm(&c->arp, (double)bpm);
        /* Host tempo drives the synced LFO rate (cell 1072) AND the synced delay
         * time (102352 + instance cells) too, not just the arp. Both are inert
         * while the patch's TEMPO SYNC is off. */
        juno_apply_lfo_tempo(c->st, c->lfo_rate_byte, (float)c->arp.bpm);
        juno_apply_delay_tempo(c->st, c->dly_time_byte, c->dly_sync, c->dly_type,
                               (float)c->arp.bpm);
    }
    if (gate >= 0.0f) carp_set_gate_index(&c->arp, gate_frac_to_index(gate));
    c->arp_on = on ? 1 : 0;
    if (was != c->arp_on) {                  /* on the toggle: flush everything */
        synth_note_off(c, -1);
        carp_remove_key(&c->arp, -1);
        c->arp_cur = -1;
        /* Enabling the arp arms the one-shot beat-quantize re-latch (plugin sets
         * router+6 at the controller SW method): the first 24-PPQN beat boundary
         * re-quantizes the step grid to the beat. Matches the plugin's own arp
         * schedule for the factory arp presets (tools/verify/arp_sched_ab.py). */
        if (c->arp_on) carp_arm_beat_requant(&c->arp);
    }
}

/* Core recall: apply patch `idx` from `bank` into the engine coefficient slots
 * via the bit-exact applier (src/juno_apply.c), then re-derive the per-patch
 * voice/arp/FX driver state. `flush` controls sounding voices: 1 = release them
 * first (a fresh patch LOAD starts clean); 0 = leave held notes ringing (a live
 * host-parameter EDIT — the voices are reseeded with the new coefficients but the
 * gate stays on). Returns # coefficients set. */
static int ctx_recall(juno_ctx *c, const unsigned char *bank, int idx, int flush)
{
    int n, mode = 0, oct = 1, on, porta = 0;
    n = juno_bank_apply(c->st, bank, idx);
    juno_driver_seed_voices(c->st);      /* all 8 voices play the applied patch */
    /* CONDITION analog voice-scatter: per-voice detune/level, applied AFTER seed (it
     * makes the 8 voices deliberately non-identical — the plugin's component-tolerance
     * emulation). Default patch value 128 -> full scatter. */
    /* UNISON (ASSIGN==2) per-voice 3968 detune spread — after seed_voices, which
     * would replicate voice 0's 0.0 over it (fuzz seeds 93/83/61/27, patches 61+63). */
    juno_apply_unison_spread(c->st, juno_bank_assign(bank, idx));
    c->last_condition = juno_bank_condition(bank, idx);
    c->hpf_type = juno_bank_hpf_type(bank, idx);   /* joint HPF recompute context */
    juno_apply_condition(c->st, c->last_condition);
    /* Per-patch VOICE-ASSIGN recall (CAssignJu60): ASSIGN MODE (poly/mono/unison/
     * poly-variant), LEGATO, and PORTAMENTO-engaged drive the note allocator above. */
    juno_bank_voice_modes(bank, idx, &c->legato, &c->assign_mode, &porta);
    /* KEY ASSIGN (blob 56) — the port originally read this as POLY(0)/MONO(1)/UNISON(2),
     * but a full-play-path running-code A/B vs the plugin's own render (all 64 patches,
     * note 60 vel 105) proves ALL THREE VALUES ARE POLYPHONIC: value 1 (14 patches:
     * Rip Lead, Ouch Bass, ...) played mono was 8x wrong; value 2 (patches 61/63) played
     * unison (8 stacked voices) was ~8x too loud. Both matched the plugin bit-for-bit
     * only when routed to POLY. The JUNO-60's mono/unison, if present, are NOT this byte.
     * So map every value -> POLY. (Any sub-mode difference between the three only affects
     * chord voice-cycling, not the single-note render this A/B measures — documented
     * follow-up.) mono_note_on / unison_note_on are retained for a future real selector. */
    c->assign_mode = 0;   /* all KEY ASSIGN values -> POLY (proven vs plugin, 64 patches) */
    /* LEGATO: neutralized for the same reason as KEY ASSIGN above. The plugin's
     * assigner cache provably stays legato=0 through the committed recall path
     * (fuzz seed 57: on a LEGATO=1+PORTA patch the plugin's second overlapping
     * note-on writes ONLY the new voice's cells — it never glides the previous
     * voice — while the blob-armed port poly-glide dragged v7's M.CV, audible to
     * ~0.19 abs; restoring just the glided cells made the seed bit-exact).
     * portamento_on is intentionally KEPT: the plugin reads param 798 fresh from
     * the processor getter, which recall DOES populate (steal-newest rule). */
    c->legato = 0;
    c->portamento_on = (porta != 0);
    /* Switching assign mode flushes sounding voices so the new allocator starts
     * clean (the plugin's mode-change reader flushes hold + all-notes-off). Release
     * ALL voices directly (mode-agnostic) and clear the held-note mask. Skipped for
     * a live host-parameter edit (flush=0) so a held note keeps ringing. */
    if (flush) {
        int v;
        for (v = 0; v < JUNO_NUM_VOICES; ++v)
            if (c->voice_note[v] >= 0) { juno_note_off(c->st, v); c->voice_gated[v] = 0; }
        c->held_notes[0] = c->held_notes[1] = c->held_notes[2] = c->held_notes[3] = 0;
        juno_note_broadcast_held(c->st, 0);   /* nothing held after the flush */
    }
    /* Per-patch ARPEGGIATOR recall: on/mode/range come from the patch (bit-exact,
     * see juno_bank_arp); rate stays local (the plugin's arp is host-tempo-synced,
     * no per-patch rate). This makes "arp presets" arpeggiate on load. */
    on = juno_bank_arp(bank, idx, &mode, &oct);
    juno_gui_arp_config(c, on, mode, oct, -1.0f, -1.0f);  /* keep UI bpm/gate */
    /* Per-patch SCATTER pattern grid: SCATTER TYPE/DEPTH (proven leaf 92/93 ->
     * record byte 322/330) select the arp's STEP x SLOT grid via carp_set_scatter.
     * All 64 factory patches decode to (0,0) = the default slab0/sub7 grid, so this
     * is inert for the stock bank but recalls correctly for any non-default patch.
     * Applied AFTER arp_config (which resets the selector) so the pattern load lands
     * last. See scratchpad/oracle/scatter_recall_spec.md. */
    {
        int stype = 0, sdepth = 0;
        juno_bank_scatter(bank, idx, &stype, &sdepth);
        carp_set_scatter(&c->arp, stype, sdepth);
    }
    /* Per-patch TEMPO-SYNCED LFO rate (cell 1072): stash the LFO RATE byte so a later
     * host tempo change (juno_gui_arp_config with bpm > 0) recomputes 1072 =
     * curve48[byte] x curve53[BPM*10]. We do NOT compute it here at cold-load: the
     * plugin holds 1072 at juno_engine_prepare's default (8.735357) until the host
     * transport actively drives the tempo — every captured post-recall state has
     * 1072 = 8.735357 for all 64 patches, with no transport. Computing it at load from
     * a placeholder BPM diverged from that reference. See docs/COLDLOAD_AB.md. */
    c->lfo_rate_byte = juno_bank_lfo_rate_byte(bank, idx);
    /* Stash the DELAY tempo-sync inputs too (same host-tempo-change contract as the
     * LFO byte above; the cold-load cells were already written by juno_bank_apply at
     * the plugin's baked 128-BPM default). */
    juno_bank_delay_modes(bank, idx, &c->dly_time_byte, &c->dly_sync, &c->dly_type);
    return n;
}

/* Apply bank patch `idx` (raw KoaBankFile00003 bytes in `bank`, `len` bytes) into
 * this engine's coefficient slots. Retains a mutable copy of the bank so the
 * host-parameter panel can edit a record byte and re-run the EXACT same recall.
 * Returns # coefficients set. */
int juno_gui_apply_bank(juno_ctx *c, const unsigned char *bank, int len, int idx)
{
    if (!c || !bank || len <= 0) return 0;
    if (c->bank_len != len) {
        free(c->bank);
        c->bank = malloc((size_t)len);
        c->bank_len = c->bank ? len : 0;
    }
    if (c->bank) memcpy(c->bank, bank, (size_t)len);
    c->patch_idx = idx;
    /* Recall from the retained copy when we have it (so later edits persist); fall
     * back to the caller's buffer if the copy failed to allocate. */
    return ctx_recall(c, c->bank ? c->bank : bank, idx, 1);
}

/* --- Host-parameter panel bridge (the 79 Ableton-visible parameters) ----------
 * The panel enumerates juno_gui_host_count() params, each a named slider in range
 * [0, juno_gui_host_max(i)]. get() decodes the current value from the loaded
 * patch's record; set() edits that record byte via the plugin's own leaf
 * serialization (juno_host_param_encode) and re-runs the recall with flush=0, so
 * a held note keeps ringing with the new coefficients. A patch must have been
 * applied first (juno_gui_apply_bank retains the bank). */
int         juno_gui_host_count(void)        { return juno_host_param_count(); }
const char *juno_gui_host_name(int i)        { return juno_host_param_name(i); }
const char *juno_gui_host_section(int i)     { return juno_host_param_section(i); }
int         juno_gui_host_max(int i)         { return juno_host_param_max(i); }

int juno_gui_host_get(juno_ctx *c, int i)
{
    if (!c || !c->bank) return -1;
    return juno_host_param_decode(juno_bank_record(c->bank, c->patch_idx), i);
}

void juno_gui_host_set(juno_ctx *c, int i, int v)
{
    unsigned char *rec;
    if (!c || !c->bank) return;
    rec = juno_bank_record(c->bank, c->patch_idx);
    if (!rec) return;
    juno_host_param_encode(rec, i, v);
    ctx_recall(c, c->bank, c->patch_idx, 0);
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
    for (i = 0; i < nframes; ++i) {
        if (c->arp_on) arp_tick(c);        /* step the arp pattern in real time */
        juno_note_tick(c->st);
        full = juno_driver_render_sample(c->st, &out[2 * i], &out[2 * i + 1]);
        if (c->arp_trace_cap) c->arp_trace_smp++;
    }
    return full;
}

/* Warm the engine to its steady idle state, exactly as a DAW does by rendering
 * silence continuously from the moment the plugin is activated. A freshly
 * prepared engine holds ~190 smoothed control cells at 0 that only converge
 * toward their targets WHILE rendering (the per-sample smoother pump inside the
 * voice/master renders); until they converge (~1.5-2 s) the first played note
 * audibly swells (measured: first 250 ms ~7x quieter on Rip Lead). In a DAW the
 * host has always rendered long before the user plays, so the swell is never
 * heard there — the browser app must warm up at boot to match. Renders idle
 * into a scratch buffer; no arp ticks (nothing is held). */
void juno_gui_warmup(juno_ctx *c, int nsamples)
{
    float buf[2 * 512];
    if (!c) return;
    while (nsamples > 0) {
        int b = nsamples > 512 ? 512 : nsamples, i;
        for (i = 0; i < b; ++i) {
            juno_note_tick(c->st);
            juno_driver_render_sample(c->st, &buf[2 * i], &buf[2 * i + 1]);
        }
        nsamples -= b;
    }
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
        float mix = 0.0f, vbuf[JUNO_NUM_VOICES];
        if (c->arp_on) arp_tick(c);        /* keep the arp advancing in the dry path too */
        juno_note_tick(c->st);
        juno_driver_render_voices(c->st, vbuf);   /* 8 voices; noise block stepped once */
        for (v = 0; v < JUNO_NUM_VOICES; ++v) mix += vbuf[v];
        out[2 * i]     = mix;                     /* mono mix -> both channels */
        out[2 * i + 1] = mix;
    }
    return 1;
}
