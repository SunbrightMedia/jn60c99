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
#include "../src/juno_mod.h"
#include "../src/carp.h"
#include "../src/host_edit.h"
#include "../src/recall_ramp.h"
#include "../src/reverb_recall.h"
#include "../src/juno_state_tables.h"
#include "../src/juno_conv.h"
#include "../src/juno_midi.h"
#include <stdlib.h>
#include <string.h>
#include <math.h>

/* a host note event as the plugin's process() reads it (VST3 Event: sample
 * offset, type 0 note-on / 1 note-off, channel, pitch, velocity 0..1) */
typedef struct { int offset, type, channel, pitch; float velocity; } juno_host_note;
/* the last point of one host parameter queue as the plugin's process() reads it
 * (VST3 IParamValueQueue: the parameter id, the point's sample offset and its
 * normalized value) */
typedef struct { uint32_t id; int offset; double value; } juno_host_param;

/* the keyboard object's key lists (count, then the keys: rva 0x3C4700 add,
 * 0x3C4730 test, 0x3C4650 remove) */
typedef struct { int n; int k[128]; } kb_list;

#define DRV_QMAX 1024             /* queued MIDI records per block (the plugin's vector grows; 1024 is
                                   * far above any host's events per block) */

typedef struct {
    unsigned char *st;
    struct juno_host_shim shim;   /* must outlive render calls */
    int chorus_mode;
    int voice_note[JUNO_NUM_VOICES];   /* MIDI note per voice, -1 = free (env done) */
    unsigned char voice_gated[JUNO_NUM_VOICES];/* 1 = note held (gate on), 0 = released */
    unsigned voice_age[JUNO_NUM_VOICES];/* allocation order (LRU; higher = newer)    */
    unsigned age_counter;
    /* THE ASSIGNER'S VOICE COUNT (CLAIMS B10): CAssignJu60 +8 (getter rva
     * 0x355A60), 8 after construction. Every allocator scan runs over voices
     * [0, asg_count) as the plugin's do (a1[2], mask a1[3], list length a1[38]).
     * The render syncs it to the engine's count (juno_voice_count) before each
     * block, as the engine render does per voice unit (rva 0x3C7400 ->
     * setVoiceCount rva 0x355940): see asg_set_count. */
    int asg_count;

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
    unsigned legato_mask;               /* assigner+68: voices the LEGATO arm still drags */
    float porta_base;                   /* recalled cell 592 (PORTAMENTO on/off), the value
                                           leaf 467+v restores — read back after recall */
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
    /* The keyboard object's fields the arp switch reads (CLAIMS B11, rva 0x3C42D0
     * / 0x3C49F0 / 0x3C4ED0): every key's last velocity (+1320), the keys in
     * order of their last press, newest first (+1448, -1 = empty), the key-trig
     * mode byte the LFO KEY TRIG entry sets (+12) with its pending flag (+11),
     * and the flag the next note-on derives from them (+8), which picks the
     * order a switch-off plays the arp's keys back in. */
    unsigned char kb_vel[128];
    int   kb_order[128];
    unsigned char kb_trig_mode, kb_trig_pending, kb_flag8;
    /* ... and its sustain (CLAIMS B16b, rva 0x3C42D0 / 0x3C4230 / 0x3C4E90): the
     * keys down on the voices, each with the note it plays (+1048), and the notes
     * the sustain holds after their key went up (+1176), 0xFF = none -- ONE array,
     * as in the plugin, whose press-order walks test and clear +1176 at index -1
     * (an empty slot of the press list), which is +1048's key 127; the keys in the
     * arp (+16) and the arp keys the sustain holds (+532); the arp sustain byte
     * (+9) and the note sustain byte (+10); and the controller's sustain byte
     * (+12 of the arp controller, engine +136 + 64u) that CC 64 sets. */
    unsigned char kb_map[256];
    kb_list kb_arp, kb_arp_latch;
    unsigned char kb_sus_arp, kb_sus_note, ctl_sus;
    int   host_role;       /* 1 while a host edit runs its allocator half: the
                            * recall model's arp block stays out (the host entry
                            * calls the controller's own setter instead) */

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

    /* The recall model's last ARPEGGIO TYPE / STEP (raw), so a live edit runs a
     * setter only for a changed value (ctx_alloc_recall). calloc zero-init ==
     * the controller as built. */
    int   rm_arp_type;
    int   rm_arp_step;
    int   kbd_velocity_sw;   /* the wrapper velocity switch (vm.vs.velSense): 0 = force vel 100
                              * (the wrapper's rule, see juno_gui_midi_note_on) */
    int   live_recall;       /* 1 while juno_gui_apply_bank_live runs: the recall
                              * leaves the plugin's recall ramps armed (CLAIMS B1) */
    int   host_only[3];      /* LFO RATE H, VCF CUTOFF FREQ H: the host-only float
                              * parameters' values (bits), not in the record (CLAIMS B6);
                              * MASTER TUNE: a SYSTEM parameter the recall never sets (A20);
                              * 0 = not set since create (the getter then reports the default) */
    int   host_only_set[3];

    /* THE RENDER DRIVER (rva 0x320B20, docs/HOST_RENDER_LAYER.md): the MIDI
     * records the wrapper's push queued for the next block (core+440) and the
     * ones a block defers to the next (core+488), the arp tick clock in 1e-8
     * host samples (core+560), the count of note-on minus note-off records
     * that restarts it (core+568), the tempo x 10 last given to the engine
     * (core+580, -1 at boot), the host tempo of the next blocks (process()
     * gives 120.0 when the host has none) and its valid flag, the host rate. */
    struct drv_rec { int off, kind, host; int32_t v; unsigned char m[3]; uint32_t id; float f; } drv_q[DRV_QMAX], drv_carry[DRV_QMAX];
    int   drv_nq, drv_ncarry;
    int   drv_queue_mode;       /* 1: apply_event queues a kind-2 record instead */
    long long drv_phase;
    int   drv_notes;
    int   drv_tempo_last;
    double drv_tempo;
    int   drv_tempo_valid;
    int   drv_rate;

    /* The render object (core +96; CLAIMS B13, src/juno_conv.c) and the engine
     * rate the setting vm.vs.sampleRate asks for (core +588, +592). ro_model: the
     * engine model juno_gui_create makes -- the engine renders the host block
     * itself at the rate it was made with, no table (every engine gate grades
     * that); juno_gui_plugin_init makes the plugin's: its engine at the
     * constructor's 96000 and the table's object for (96000, host rate). */
    juno_ro ro;
    int   ro_model;
    int   eng_req;
    int   eng_auto;
    void *ro_out;              /* the block's drv_out, for the converter's engine render */
    float *ro_tmp;             /* the converter's host samples of one segment (2 x ro_tmp_cap) */
    int   ro_tmp_cap;
    int   ro_unported;         /* a rate switch on a running engine was asked: B13b, not ported */
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

/* ENGINE B COEFFICIENT GENERATION COUNTER.
 *
 * The engine B shims cache each module's coefficients and check them against
 * the port's cells with a memcmp every sample. MEASURED over the 30-scenario
 * set: those checks miss 272 times in 30,494,720 (envelopes), 128 in
 * 15,247,360 (mod CV) and 8 in 15,247,360 (ladder, decimator). So the cells are
 * recall-rate, and the check -- not the work -- is what costs.
 *
 * This counter lets a shim skip the check while nothing can have changed. It is
 * bumped by every bridge entry point EXCEPT the plain render calls.
 *
 * IT IS NOT TRUSTED ON ITS OWN. Building with -DEB_VERIFY_GEN makes every shim
 * run the full memcmp anyway and abort if the counter said "clean" while the
 * cells had in fact changed. That build is run over all 30 scenarios, so the
 * claim "no other writer exists" is PROVEN by execution rather than by reading
 * the call graph. This file is compiled into BOTH sides of the null, so the
 * counter itself cannot cause a divergence.
 */
unsigned long eb_coef_gen = 1;

/* the render driver's state as the core builds it: no records, the clock at 0,
 * no notes, no tempo sent (core+580 = -1), process()'s default tempo 120.0 */
static void drv_init(juno_ctx *c, float sample_rate)
{
    c->drv_nq = c->drv_ncarry = 0;
    c->drv_phase = 0;
    c->drv_notes = 0;
    c->drv_tempo_last = -1;
    c->drv_tempo = 120.0;
    c->drv_tempo_valid = 0;
    c->drv_rate = (int)sample_rate;
    juno_ro_init(&c->ro, (int)sample_rate, (int)sample_rate);
    c->ro_model = 1;
    c->eng_req = (int)sample_rate;
}

/* The engine as its construction + setSampleRate leave it, at `rate`: what
 * juno_gui_create makes (coldstate_ab.py grades it against the plugin's build
 * + setSampleRate at 18 rates). */
static void st_build(unsigned char *st, float rate, struct juno_host_shim *shim, int chorus_mode)
{
    memset(st, 0, JUNO_STATE_BYTES);
    JF(st, 16) = rate;
    juno_chorus_init(st);
    juno_engine_init(st);
    juno_engine_prepare(st);
    default_patch(st);
    juno_driver_seed_voices(st);
    juno_apply_condition(st, 128);
    juno_driver_attach_host(st, shim, chorus_mode);
}

static juno_ctx *ctx_create(float sample_rate, int chorus_mode);

juno_ctx *juno_gui_create(float sample_rate, int chorus_mode)
{
    juno_enable_hw_ftz();                /* run in the plugin's SSE FTZ/DAZ mode (x86) */
    return ctx_create(sample_rate, chorus_mode);
}

/* juno_gui_create without the FP mode (the rate switch's scratch reference) */
static juno_ctx *ctx_create(float sample_rate, int chorus_mode)
{
    ++eb_coef_gen;
    juno_ctx *c = calloc(1, sizeof *c);
    int v;
    if (!c) return NULL;
    c->st = calloc(1, JUNO_STATE_BYTES);
    if (!c->st) { free(c); return NULL; }

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
    c->asg_count = JUNO_NUM_VOICES;
    for (v = 0; v < JUNO_NUM_VOICES; ++v) c->voice_note[v] = -1;
    /* arp: bit-exact CArpeggio, off by default. carp_init seeds the plugin's
     * power-on arp state exactly: UP, 1 octave, 120 BPM, and — the binary defaults —
     * the RATE table at rate_index 4 (sixteenth notes) and gate index 7 (100%). No
     * override here: the earlier gate-index 3 (60%) was wrong (arp_rate_findings.md). */
    carp_init(&c->arp);
    c->arp_on = 0;
    c->arp_cur = -1;
    for (v = 0; v < 128; ++v) c->kb_order[v] = -1;
    memset(c->kb_map, 0xFF, sizeof c->kb_map);
    c->kb_arp.n = c->kb_arp_latch.n = 0;
    c->kb_sus_arp = c->kb_sus_note = c->ctl_sus = 0;
    c->host_bpm = 128.0f;   /* plugin recall-default TEMPO (880 -> 40+88.0) */
    drv_init(c, sample_rate);
    juno_driver_attach_host(c->st, &c->shim, chorus_mode);
    return c;
}

/* Reset an existing context to the exact COLD state of a fresh juno_gui_create,
 * WITHOUT freeing/reallocating the 12 MB state. Equivalent to destroy+create
 * (calloc zeros everything, then the same init runs), but reuses the buffers so
 * a test that sweeps thousands of patches does not churn the heap. The output is
 * bit-identical to a fresh create: the only thing that differs is the shim base
 * POINTER stored at st+136, which lives in the excluded header region [0,176)
 * and never enters the audio (juno_ftz excludes it; the render reads it only as
 * an address). Tools that create one engine and sweep with this get identical
 * hashes to per-patch create/destroy — proven by the bit-exact gate. */
void juno_gui_reinit(juno_ctx *c, float sample_rate, int chorus_mode)
{
    int v;
    unsigned char *st;
    if (!c) return;
    ++eb_coef_gen;
    st = c->st;
    free(c->bank);                      /* the model record (a fresh create has none) */
    juno_ro_free(&c->ro);
    free(c->ro_tmp);
    memset(c, 0, sizeof *c);            /* match calloc's zero of the whole ctx */
    c->st = st;
    memset(st, 0, JUNO_STATE_BYTES);    /* match calloc's zero of the state     */

    juno_enable_hw_ftz();
    JF(c->st, 16) = sample_rate;
    juno_chorus_init(c->st);
    juno_engine_init(c->st);
    juno_engine_prepare(c->st);
    default_patch(c->st);
    juno_driver_seed_voices(c->st);
    juno_apply_condition(c->st, 128);
    c->last_condition = 128;
    c->chorus_mode = chorus_mode;
    c->asg_count = JUNO_NUM_VOICES;
    for (v = 0; v < JUNO_NUM_VOICES; ++v) c->voice_note[v] = -1;
    carp_init(&c->arp);
    c->arp_on = 0;
    c->arp_cur = -1;
    for (v = 0; v < 128; ++v) c->kb_order[v] = -1;
    memset(c->kb_map, 0xFF, sizeof c->kb_map);
    c->kb_arp.n = c->kb_arp_latch.n = 0;
    c->kb_sus_arp = c->kb_sus_note = c->ctl_sus = 0;
    c->host_bpm = 128.0f;
    drv_init(c, sample_rate);
    juno_driver_attach_host(c->st, &c->shim, chorus_mode);
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
    juno_ro_free(&c->ro);
    free(c->ro_tmp);
    free(c->st);
    free(c);
}

/* Raw state pointer + size — for the split-vs-single-core bit-exact gate only,
 * which drives the driver-level render (juno_driver_render_sample) directly and
 * snapshots the whole state to prove a per-core voice split leaves it
 * byte-identical. Not for audio use. Returns NULL/0 on a null context. */
unsigned char *juno_gui_state(juno_ctx *c) { return c ? c->st : 0; }
unsigned juno_gui_state_bytes(void) { return JUNO_STATE_BYTES; }

/* Raw parameter store/load — native units, exactly the plugin's raw-store
 * setter (sub_1803C1090 semantics). Offset bounds-checked against the block. */
void juno_gui_set(juno_ctx *c, int off, float v)
{
    ++eb_coef_gen;
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
    ++eb_coef_gen;
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
    ++eb_coef_gen;
    juno_engine_init(c->st);             /* constructor state                    */
    juno_engine_prepare(c->st);          /* binary prepared baseline (no capture) */
    default_patch(c->st);
    /* Clean slot-1 (v39): no stale DELAY TYPE from a prior patch.
     *
     * DECIDED, NOT INHERITED. The juno_engine_prepare three lines up already
     * writes 0 into BOTH of these (src/juno_prepare.c:279,291), so today this
     * pair is redundant — and that is exactly the trap: it was correct only
     * because something else had run first. A writer that leaves the routing
     * cell and its shadow (src/juno_engine.h JUNO_PREV_DLY) out of step is a
     * defect whatever the preceding lines happen to do, so this site keeps the
     * PAIR itself and stops depending on the accident. Power-on DELAY TYPE = 0
     * has the same provenance as the seed: PROVEN under Unicorn from the
     * plugin's own state cell 11022056 (src/juno_prepare.c:270-279).
     *
     * Since CLAIMS B1 (2026-10-05) the next recall READS JUNO_PREV_DLY: it is
     * the block in force that DELAY LEVEL/TIME land on and DELAY TYPE switches
     * off (src/delay_recall.c slot1_stale / slot1_off), so a desync here is a
     * wrong patch change, graded by tools/verify/warm_chain_gate.py. The pair
     * is also held statically, by tools/verify/shadow_sync_gate.py check S,
     * which fails such a site on ORDER rather than on luck. */
    JI(c->st, JUNO_PROG_DLY) = 0;
    JI(c->st, JUNO_PREV_DLY) = 0;
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
    ++eb_coef_gen;
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
     * makes every consumer (GUI, fuzzer, MIDI CC mapping) faithful by default.
     *
     * THE EXPANSION MOVED to juno_apply_param_leaf (src/juno_apply.c), verbatim,
     * on 2026-08-12. It was here only, and gui/ is a file no target compiles, so
     * the device-recall gate had grown its own copy — which was broken and made
     * a third of that gate's cases silent duplicates. One rule, one place. */
    n = juno_param_count(); (void)n; (void)i;
    w = juno_apply_param_leaf(c->st, param_index, byte, Hr);
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
    /* PORTAMENTO leaf (blob 54): the plugin's POLY allocator does NOT cache this —
     * sub_7FF91DFB3870 re-reads param 798 through the value getter on EVERY note
     * and passes (v != 0) to sub_7FF91DFB3150 as its steal rule (newest voice when
     * portamento is engaged, oldest otherwise). A live edit therefore takes effect
     * on the next note in the real plugin, so mirror it here instead of leaving the
     * bank-apply value stale. (LEGATO/ASSIGN MODE are not panel leaves — they reach
     * the allocator only through recall; see docs/ASSIGNER_MODE_FINDING.md.) */
    if (blob == 54) {
        c->portamento_on = ((byte & 0xFF) != 0);
        c->porta_base = JF(c->st, 592);   /* the value leaf 467+v restores */
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
        juno_live_delay_sync(c->st, c->dly_time_byte, c->dly_sync, c->dly_type);
    }
    return w;
}

/* --- LIVE MODULATION layer (#112) ------------------------------------------
 * The plugin's value tree carries six dispatch indices (312..317) that a patch
 * RECALL never applies — they are no-ops in the recall role — but that a real VST3
 * host's parameter changes DO drive: each lays a signed percentage offset over a
 * front-panel parameter's recalled base byte and re-drives that parameter.
 *
 * This is the ONE place where the plugin's host-driven parameter path differs from
 * its recall path; every other recalled index behaves identically under both roles
 * (tools/verify/hostpath_roles.py re-derives that from the binary every run). The
 * offset law in juno_mod_byte() is proven bit-exact against the plugin's own
 * modulation setters — 308736 comparisons over every base byte 0..255 x every
 * offset -100..100 x all six slots, 0 mismatch (tools/verify/hostmod_gate.py).
 *
 * The caller supplies the base byte (the loaded patch's value for that parameter,
 * which is what the plugin's own base cache holds) so no hidden state is
 * introduced: modulation is applied on top of the patch, never accumulated.
 *
 * SCOPE, stated plainly: the offset LAW is proven for all six slots, but only five
 * are wired end-to-end here. Slot 5 (EFFECT DEPTH) has no row in juno_apply.c's
 * BINDINGS table — it is an FX leaf applied by the chorus/effect recall path, not
 * by the panel-parameter path — so juno_gui_mod_param_index(5) returns -1 and
 * juno_gui_set_mod() on it returns 0 without touching the engine. Routing slot 5
 * needs an FX-leaf live applier; it is NOT silently approximated.
 */
int juno_gui_mod_count(void) { return JUNO_MOD_COUNT; }

const char *juno_gui_mod_name(int slot) { return juno_mod_base_name(slot); }

/* Panel-parameter index (juno_apply.c BINDINGS order) the slot modulates, -1 if
 * the slot is out of range or the name is not exposed. */
int juno_gui_mod_param_index(int slot)
{
    const char *nm = juno_mod_base_name(slot);
    int i, n;
    if (!nm || !*nm) return -1;
    n = juno_param_count();
    for (i = 0; i < n; ++i)
        if (!strcmp(juno_param_name(i), nm)) return i;
    return -1;
}

/* Apply modulation `off` (percent, -100..100) over `base_byte` (the patch's value
 * for the slot's parameter). Returns the engine float written, 0 if unavailable. */
float juno_gui_set_mod(juno_ctx *c, int slot, int base_byte, int off)
{
    int i = juno_gui_mod_param_index(slot);
    if (!c || i < 0) return 0.0f;
    return juno_gui_set_param(c, i, juno_mod_byte(base_byte, off));
}

/* Legacy slot-2 override (0 = Pan arm = effectively dry). attach_host no longer
 * seeds the routing cell (juno_engine_prepare owns the power-on default 2), so
 * this writes the EFFECT TYPE program cell directly — same effect the old
 * attach-time seed had for callers of this API. A subsequent patch apply
 * overrides it with the patch's own EFFECT TYPE, exactly as before.
 *
 * THIS SETTER PUTS AN EFFECT TYPE IN FORCE, so it must move BOTH cells a recall
 * moves — the routing cell AND its port-owned shadow (src/juno_engine.h
 * JUNO_PREV_EFX) — by the same law juno_apply_effect_modes + juno_bank_apply use:
 *     routing cell = the CLAMPED type. The plugin's own EFFECT TYPE setter writes
 *                    clamp(v, <=5) for every value 0..255, PROVEN under Unicorn by
 *                    the setter spot sweep (src/effect_modes.h JUNO_PROG_EFX,
 *                    src/effect_modes.c:63). Writing a raw 9 here parked the port
 *                    in a routing state the plugin can never hold.
 *     shadow       = the RAW leaf, never clamped — that is the whole reason the
 *                    shadow exists, the routing cell cannot answer "what was in
 *                    force" once it has been clamped.
 *
 * IT DID NEITHER, AND THAT WAS A REAL BREAK, NOT A THEORETICAL ONE. The shadow's
 * first written contract said "any FUTURE setter outside juno_bank_apply must
 * update these"; this setter already existed on that day — a shipped WASM export
 * (gui/web/build.sh), wrapped by gui/juno_gui.py + gui/juno_web.py and driven in a
 * loop by tools/verify/cov_replay.py. src/chorus_recall.c gates the chorus WET cell
 * 91232 on the type in force BEFORE the next recall and reads it from the shadow,
 * so a stale shadow made the SAME EFFECT TYPE in force produce two different
 * engines. MEASURED (ctypes, 44100, factory bank; the path-independence cases in
 * tools/verify/shadow_sync_gate.py):
 *     p39 -> p40                  type 5 in force, 91232 = 0x3f95c28f (carried)
 *     set_chorus_mode(5) -> p40   type 5 in force, 91232 = 0x3eb1bcd3 (written)
 * and the same split at type 2 (p39,set(2) -> p40 vs p0 -> p40). The desync fired
 * at EVERY mode except 2 — mode 2 only re-synced because 2 is the power-on seed —
 * and mode 0 is the Pan arm the shipping web app passes at startup
 * (gui/web/index.html). Caught by the writer-set audit, not by any A/B: every
 * whole-state gate recalled COLD, where the shadow is always the power-on 2.
 * Guarded from now on by tools/verify/shadow_sync_gate.py, wired into `make
 * verify`; it covers mode 0, the clamped bound and out-of-range values. */
void juno_gui_set_chorus_mode(juno_ctx *c, int mode)
{
    int route = mode > 5 ? 5 : mode;
    ++eb_coef_gen;
    c->chorus_mode = mode;
    juno_driver_attach_host(c->st, &c->shim, mode);
#ifdef JUNO_TOOTH_STALE_EFX_SHADOW
    /* THE TOOTH: the pre-repair writer, verbatim — raw into the routing cell,
     * shadow untouched. Rebuild with -DJUNO_TOOTH_STALE_EFX_SHADOW and
     * tools/verify/shadow_sync_gate.py check B MUST go RED on every
     * set_chorus_mode row except mode 2, on the OUT OF RANGE rows, and on the
     * path-independence cases. If it stays green the gate is not testing this
     * writer. Same device as src/chorus_recall.c JUNO_TOOTH_NO_PREV_EFX. */
    *(int32_t *)(c->st + JUNO_PROG_EFX) = mode;
    (void)route;
#else
    JI(c->st, JUNO_PROG_EFX) = route;   /* routing: CLAMPED, as the applier writes it   */
    JI(c->st, JUNO_PREV_EFX) = mode;    /* shadow:  RAW leaf, as juno_bank_apply writes it */
#endif
}

/* Poke the voice-0 note-on edge state[101504]. KNOWN LIMITATION: the real
 * note path (ramp-gate engine, control-layer unit #1) is not yet transcribed,
 * so this alone does not open the filter envelope — expect silence. Exposed
 * for experimentation only (see docs/CONTROL_LAYER.md sound-test). */
void juno_gui_gate(juno_ctx *c, float v)
{
    ++eb_coef_gen;
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
    for (v = 0; v < c->asg_count && v < JUNO_NUM_VOICES; ++v) {
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
    for (v = 0; v < c->asg_count && v < JUNO_NUM_VOICES; ++v) {
        int assigned = c->voice_note[v] >= 0;
        if (assigned != want_assigned) continue;
        if (assigned && (int)c->voice_gated[v] != want_gated) continue;
        if (pick < 0 || c->voice_age[v] > newest) { newest = c->voice_age[v]; pick = v; }
    }
    return pick;
}

/* 128-bit held-note bitmask (mirrors the assigner's a1[20..23]). */
static void held_set(juno_ctx *c, int n)   { if (n>=0 && n<128) c->held_notes[n>>5] |=  (1u<<(n&31)); }
/* The assigner's note-off clears bit n of its held mask a1[20..23] (rva
 * 0x355780) with no range check. The only note above 127 that reaches it is 255
 * (the keyboard's press-order walk at an empty slot, rva 0x3C3FA0): bit 31 of
 * a1[27], the top bit of slot 5's note byte (+111) -- a slot without a note
 * (0xFF) then holds note 127. */
static void held_clear(juno_ctx *c, int n)
{
    if (n >= 0 && n < 128) c->held_notes[n >> 5] &= ~(1u << (n & 31));
    else if (n == 255 && c->voice_note[5] < 0) c->voice_note[5] = 127;
}
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
            for (w = 0; (int)w < c->asg_count && w < JUNO_NUM_VOICES; ++w)
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
            for (w = (c->asg_count < JUNO_NUM_VOICES ? c->asg_count : JUNO_NUM_VOICES) - 1; w >= 0; --w)
                if (!c->voice_gated[w] && (pick < 0 || c->voice_age[w] < oldest))
                    { oldest = c->voice_age[w]; pick = w; }
        }
    } else {
        /* MODE 3 (sub_7FF91DFB35C0, READ): scan voices UPWARD from 0 and take
         * the first one that is not gated (or released under hold, a flag the
         * port does not model: without hold it is never set). The port scanned
         * top-down, so from silence it played voice 7 where the plugin plays
         * voice 0, and per-voice CONDITION scatter changed the sound from
         * sample 2 (docs/ASSIGN_MODE_3_FINDING.md; 22 of 22 user mode-3
         * patches; tools/verify/seed_recall_gate.py legal seeds). */
        for (v = 0; v < c->asg_count && v < JUNO_NUM_VOICES; ++v)
            if (c->voice_note[v] < 0 || !c->voice_gated[v]) { pick = v; break; }
    }
    if (pick < 0)                                       /* steal: newest if porta, else oldest */
        pick = c->portamento_on ? pick_newest(c, 1, 1) : pick_oldest(c, 1, 1);
    if (pick < 0) pick = 0;

    /* LEGATO arm — the ONE place the binary reads the LEGATO field, and only in
     * POLY with portamento engaged (sub_7FF91DFB3150 LABEL_21:
     * `if (a1[5] && a4 == 1)`, a4 = the freshly-read PORTAMENTO != 0):
     *
     *   silent = no voice currently gated
     *   if (silent) { every voice: leaf 467+v := 1 ; legato_mask := all voices }
     *   else        { every voice: leaf 467+v := 0 }
     *   for i != pick with bit i of legato_mask: move voice i to the new note
     *   ...trigger pick...
     *   legato_mask &= ~(1 << pick)
     *
     * Leaf 467+v is the per-voice PORTAMENTO GATE (juno_note_porta_gate, cells
     * 592/9824 — PROVEN by dispatching the plugin's own setter, see that function).
     * So the FIRST note after silence bypasses the glide conditioner on every voice
     * (you do not glide from nothing) and every later note re-arms it — which is
     * exactly what makes a legato+portamento line glide only between overlapping
     * notes.
     *
     * The pitch drag covers every voice still in legato_mask, GATED OR NOT. The
     * previous version dragged only GATED voices and never touched leaf 467, which
     * diverged from the plugin on the very first note (assigner_ab patch 55, first
     * differing sample at index 2). */
    if (!variant && c->legato && c->portamento_on) {
        int silent = 1, i;
        int nv = c->asg_count < JUNO_NUM_VOICES ? c->asg_count : JUNO_NUM_VOICES;
        for (v = 0; v < nv; ++v)
            if (c->voice_gated[v]) { silent = 0; break; }
        for (v = 0; v < nv; ++v)
            juno_note_porta_gate(c->st, v, silent, c->porta_base);
        if (silent) c->legato_mask = nv > 0 ? (1u << nv) - 1u : 0u;   /* the assigner's mask a1[3] */
        for (i = 0; i < nv; ++i)
            if (i != pick && ((c->legato_mask >> i) & 1u)) {
                if (c->voice_note[i] != midi_note) juno_note_glide(c->st, i, midi_note);
                c->voice_note[i] = midi_note;
            }
    }

    /* A chosen voice that is STILL GATED is gated OFF first. The plugin's POLY
     * allocator tail (sub_7FF91DFB3150, after the legato arm; MODE 3
     * sub_7FF91DFB35C0 the same) does `if (gated[v]) setparam(450+v, 0)` and only
     * then the pitch leaf and the gate leaf with the velocity. That happens on a
     * STEAL (every voice held) and on a same-note re-strike. The gate-off arms the
     * DCO retrigger latch (Array A, juno_note_off), so a stolen voice re-phases
     * its DCO on the next sample -- the port did not, and 12 of 16 seeds of
     * tools/verify/steal_gate.py failed on exactly that cell (CLAIMS B2).
     * PROVEN by tracing the plugin's dispatches on a 9th held note: (456,0),
     * (439,66), (456,113). */
    if (c->voice_gated[pick]) juno_note_off(c->st, pick);
    voice_trigger(c, pick, midi_note, velocity);        /* chosen voice always retriggers */
    c->legato_mask &= ~(1u << pick);
}

/* MODE 1 MONO (sub_7FF91DFB38F0): one fixed voice (0). Overlapping (still-gated)
 * note = legato (pitch+gate refresh, no gate-off retrigger); idle/releasing = full
 * retrigger. Voices 1..7 forced off. */
static void mono_note_on(juno_ctx *c, int midi_note, int velocity)
{
    int v;
    if (!c->voice_gated[0]) {                            /* idle/releasing -> retrigger */
        /* MONO retrigger arms the DCO phase-reset latch; POLY note-on does not.
         * Measured on a warm engine, both modes (probes/assigner/mono_stack_*).
         * Without this the port's first sample after any MONO note that follows
         * rendering differs from the plugin — fuzz_diff seed 15. */
        juno_note_retrig(c->st, 0);
        voice_trigger(c, 0, midi_note, velocity);
    } else {                                             /* legato: pitch move, keep envelope */
        /* No voice_age update: a legato key does not move voice 0 in the
         * plugin's voice-priority list (MEASURED, see unison_note_on). */
        juno_note_glide(c->st, 0, midi_note);
        juno_note_velocity(c->st, 0, velocity);          /* refresh VCF/VCA vel, no gate edge */
        c->voice_note[0] = midi_note;
    }
    for (v = 1; v < c->asg_count && v < JUNO_NUM_VOICES; ++v)   /* force mono: release the rest */
        if (c->voice_note[v] >= 0) { juno_note_off(c->st, v); c->voice_gated[v] = 0; }
}

/* MODE 2 UNISON (sub_7FF91DFB3B60): all 8 voices on the same note. Whole stack
 * retriggers only when idle; overlapping notes glide the stack.
 *
 * THE VOICE-PRIORITY LIST (CAssignJu60, the 8 ints at assigner +0x78) moves ONLY
 * voice 0 to the front on a UNISON or MONO retrigger, and nothing at all on a
 * legato/glide key; a POLY or mode-3 allocation moves the chosen voice. MEASURED
 * by dumping the list across unison/mono/mode-3 notes and back to POLY
 * (tools/verify/warm_render_gate.py found it: after a unison patch the plugin's
 * next POLY note took voice 7, the port's voice 0, because the port aged all 8
 * unison voices). voice_age is the port's image of that list, so here only
 * voice 0 is aged. */
static void unison_note_on(juno_ctx *c, int midi_note, int velocity)
{
    int v, was_idle = !c->voice_gated[0];
    for (v = 0; v < c->asg_count && v < JUNO_NUM_VOICES; ++v) {
        unsigned keep_age = c->voice_age[v];
        if (was_idle) {
            /* UNISON retrigger arms the DCO phase-reset latch on ALL EIGHT
             * voices, exactly as MONO arms it on voice 0. Its absence made the
             * port diverge from the plugin by -34.6 dB global / -16.3 dB block
             * on patch 61 after ANY idle -- one single idle frame was enough.
             *
             * Cold it matched by accident: juno_init arms Array A at BUILD, the
             * first rendered sample consumes the one-shot, and from then on the
             * port left all 8 DCOs un-rephased while the plugin re-phased them.
             * UNISON is 8 detuned copies of one note, so 8 wrong phases is a
             * large error. Every cold gate was structurally blind to it.
             *
             * PROVEN: after note-on the port/plugin state diff is exactly the 8
             * cells 101504+32v (plugin 1.0f, port 0.0f) plus the inert Array B
             * twin, and nothing else. Arming them makes patch 61 and patch 63 --
             * the bank's only ASSIGN=2 patches -- BIT-EXACT warm.
             *
             * The arm belongs in the was_idle branch ONLY: the glide branch is
             * bit-exact without it, and arming there breaks it. Same law and
             * same defect class as the MONO latch above (e611f7d). */
            juno_note_retrig(c->st, v);
            voice_trigger(c, v, midi_note, velocity);
            if (v) c->voice_age[v] = keep_age;           /* only voice 0 moves */
        }
        else { juno_note_glide(c->st, v, midi_note); juno_note_velocity(c->st, v, velocity);
               c->voice_note[v] = midi_note; }         /* a glide moves nothing */
    }
}

/* THE ASSIGNER'S setVoiceCount (rva 0x355940, CLAIMS B10), which the engine
 * render calls on every voice unit's assigner whose count differs from the
 * engine's (rva 0x3C7400). READ, transcribed in order:
 *   hold-off (0x354C70, a2 = 0) and all-notes-off (0x3530B0 -> 0x355270): a
 *     gate-off for every voice of the OLD count whose slot is GATED -- a voice
 *     already released gets nothing (its DCO latch is not armed);
 *   the count body (0x354D30): count = min(n, 8) (no lower clamp), every note
 *     slot "no note" (0xFF), the voice-priority list rebuilt as [0..count-1]
 *     (fresh ages: the top-down LRU scan then starts at count-1), the legato
 *     mask and the held-note mask cleared;
 *   the mode reader (0x3549F0) and LEGATO re-read: the patch's cached mode and
 *     legato, unchanged here.
 * The engine's held flag (1856) follows as in the ASSIGN MODE change flush
 * below, which runs the same two plugin functions. */
static void asg_set_count(juno_ctx *c, int n)
{
    int v, old = c->asg_count < JUNO_NUM_VOICES ? c->asg_count : JUNO_NUM_VOICES;
    for (v = 0; v < old; ++v)
        if (c->voice_gated[v]) juno_note_off(c->st, v);
    c->asg_count = n > JUNO_NUM_VOICES ? JUNO_NUM_VOICES : n;
    for (v = 0; v < JUNO_NUM_VOICES; ++v) {
        c->voice_note[v] = -1;
        c->voice_gated[v] = 0;
        c->voice_age[v] = 0;
    }
    c->legato_mask = 0;
    c->held_notes[0] = c->held_notes[1] = c->held_notes[2] = c->held_notes[3] = 0;
    juno_note_broadcast_held(c->st, 0);
}

/* The engine render's per-block preamble (rva 0x3C7400): the assigners follow
 * the engine's voice count before anything renders. The comparison is with the
 * RAW engine count, as the plugin's is (a count above 8 resets every block). */
static void asg_sync(juno_ctx *c)
{
    int nv = juno_voice_count(c->st);
    if (c->asg_count != nv) asg_set_count(c, nv);
}

/* The host's vm.vs.voiceCount (id 0x0FFFC00E): the plugin's host entry stores
 * the raw value at engine +0x38 and nothing else (rva 0x3C7AE0); the next render
 * applies it. The plugin's default state sends 6 (Script.xml range 2..8). */
void juno_gui_set_voice_count(juno_ctx *c, int n)
{
    if (c) juno_set_voice_count(c->st, n);
}
int juno_gui_voice_count(juno_ctx *c) { return c ? juno_voice_count(c->st) : 0; }

/* The paths this context reached that the port does not model (each one an
 * open claim): bit 0 an engine-rate switch on a running engine (CLAIMS B13b).
 * A gate that sees a bit set must not report its chain as graded. */
int juno_gui_unported(juno_ctx *c)
{
    return c ? (c->ro_unported ? 1 : 0) : 0;
}
/* voice v's own noise block (gates): see juno_driver_unit_noise */
const void *juno_gui_unit_noise(juno_ctx *c, int v) { return c ? (const void *)juno_driver_unit_noise(c->st, v) : 0; }

/* The held flag every gate leaf leaves on all voices (rva 0x3B1C58, the
 * processor's gate leaf: any of its voices' gate values nonzero after the
 * leaf's own) -- "a voice still gated". An event without a gate leaf writes
 * nothing, but the flag then already equals this (only gate leaves move it). */
static int any_gated(const juno_ctx *c)
{
    int v;
    for (v = 0; v < JUNO_NUM_VOICES; ++v)
        if (c->voice_gated[v]) return 1;
    return 0;
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
    /* the held flag (1856) on EVERY voice, after the gate leaves (see
     * juno_note_broadcast_held) */
    juno_note_broadcast_held(c->st, any_gated(c));
}

/* Release all voices playing `key` (or every voice if key < 0). Used by POLY. */
static void poly_release_key(juno_ctx *c, int key)
{
    int v;
    for (v = 0; v < c->asg_count && v < JUNO_NUM_VOICES; ++v)
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
    int lo, v, last = all ? (c->asg_count < JUNO_NUM_VOICES ? c->asg_count : JUNO_NUM_VOICES) : 1;
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
    /* the held flag (1856) on EVERY voice: a voice still gated -- a key held
     * with no voice (stolen) does not keep it up */
    juno_note_broadcast_held(c->st, any_gated(c));
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

/* The arp's events into the voice allocator, in the order the arp made them
 * (its note sink is the keyboard's: rva 0x3C35A0 / 0x3C3580). */
static void arp_dispatch(juno_ctx *c, const carp_event *ev, int n)
{
    int i;
    for (i = 0; i < n; ++i) {
        if (c->arp_trace_cap && c->arp_trace_n < c->arp_trace_cap) {
            int *r = c->arp_trace_buf + 4 * c->arp_trace_n++;
            r[0] = (int)c->arp_trace_smp; r[1] = ev[i].kind;
            r[2] = ev[i].note; r[3] = ev[i].velocity;
        }
        /* THE ARPEGGIATOR'S EVENTS ARE NOTE EVENTS, so they bump the
         * coefficient generation counter like every other note event does
         * (engine B mirrors the port's event-written cells on a bump; an
         * arp-driven note was once invisible to it). */
        ++eb_coef_gen;
        if (ev[i].kind == 0) {
            synth_note_off(c, ev[i].note);
            if (ev[i].note == c->arp_cur) c->arp_cur = -1;
        } else {
            synth_note_on(c, ev[i].note, ev[i].velocity);
            c->arp_cur = ev[i].note;
        }
    }
}

/* One engine tick (CWaveGen vt+184, rva 0x3C6750): the arp's keyboard object
 * and state machine, whether the arp is on or not. */
static void drv_tick(juno_ctx *c)
{
    carp_event ev[64];
    arp_dispatch(c, ev, carp_engine_tick(&c->arp, c->kb_vel, ev, 64));
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

/* Debug: the arp's fields in the plugin's CKbdArp / keyboard-object order, for
 * the render-driver diagnostic (probes/host_render/diag_driver.py). out[32]. */
int juno_gui_arp_debug(juno_ctx *c, int *out)
{
    const carp *e;
    int s;
    if (!c || !out) return 0;
    e = &c->arp;
    out[0] = (int)e->kb_ctr;          out[1] = e->beat_requant_armed;   out[2] = e->division;
    out[3] = e->clk_on;               out[4] = (int)e->clk20;           out[5] = (int)e->tick_counter;
    out[6] = e->state;                out[7] = (int)e->next_step_tick; out[8] = e->pat_step;
    out[9] = e->count;                out[10] = e->sel_step;            out[11] = e->started;
    out[12] = e->ud_dir;              out[13] = e->oct_adv_flag;        out[14] = e->oct_shift;
    out[15] = e->range;               out[16] = e->selector;            out[17] = e->field56;
    for (s = 0; s < 4; ++s) { out[18 + s] = e->sorted[s]; out[22 + s] = e->slot_pitch[s] < 0 ? 0x80 : e->slot_pitch[s];
                              out[26 + s] = (int)e->slot_offtick[s]; }
    out[30] = e->pat_nslots;          out[31] = e->pat_len;
    return 32;
}

/* ---- THE KEYBOARD OBJECT (engine +120 + 64u: one per unit, all alike -- the
 * port keeps one; CLAIMS B11, B16b). READ, transcribed in the plugin's order.
 * Its transpose (+7) is 0: no plugin path writes it. ---- */
enum { KB_DOWN = 0, KB_LATCH = 128 };

static int  kbl_has(const kb_list *l, int k)      /* rva 0x3C4730 */
{
    int i;
    for (i = 0; i < l->n; ++i) if (l->k[i] == k) return 1;
    return 0;
}
static void kbl_add(kb_list *l, int k)            /* rva 0x3C4700: at the end, once */
{
    if (!kbl_has(l, k) && l->n < 128) l->k[l->n++] = k;
}
static void kbl_del(kb_list *l, int k)            /* rva 0x3C4650: the rest move down */
{
    int i;
    for (i = 0; i < l->n && l->k[i] != k; ++i) ;
    if (i == l->n) return;
    for (--l->n; i < l->n; ++i) l->k[i] = l->k[i + 1];
}
/* the key maps (rva 0x3C48D0 test, 0x3C48B0 put if empty, 0x3C4810 take,
 * 0x3C4800 clear, 0x3C48E0 any); k may be -1 in KB_LATCH (key 127 of KB_DOWN) */
static int  kbm_has(const juno_ctx *c, int m, int k) { return c->kb_map[m + k] != 0xFF; }
static void kbm_put(juno_ctx *c, int m, int k, int v) { if (c->kb_map[m + k] == 0xFF) c->kb_map[m + k] = (unsigned char)v; }
static void kbm_take(juno_ctx *c, int m, int k, int *out)
{
    if (c->kb_map[m + k] == 0xFF) return;
    *out = c->kb_map[m + k];
    c->kb_map[m + k] = 0xFF;
}
static void kbm_clear(juno_ctx *c, int m, int k) { c->kb_map[m + k] = 0xFF; }
static int  kbm_any(const juno_ctx *c, int m)
{
    int k;
    for (k = 0; k < 128; ++k) if (c->kb_map[m + k] != 0xFF) return 1;
    return 0;
}

/* rva 0x3C3AD0: the arp keys the sustain held (+532) leave the arp, key order */
static void kb_free_arp_latch(juno_ctx *c)
{
    carp_event ev[64];
    int k;
    for (k = 0; k < 128; ++k)
        if (kbl_has(&c->kb_arp_latch, k)) {
            arp_dispatch(c, ev, carp_key_off(&c->arp, k, ev, 64));   /* rva 0x3BF290 -> 0x3BF110 */
            kbl_del(&c->kb_arp_latch, k);
        }
}

/* rva 0x3C3FA0: the notes the sustain held (+1176) leave the voices: mode 1
 * from key 127 down, mode 2 from key 0 up, any other mode through the press
 * list, oldest first, an empty slot (-1) included (index -1, note 255) */
static void kb_free_note_latch(juno_ctx *c, int mode)
{
    int i;
    if (mode == 1) {
        for (i = 127; i >= 0; --i)
            if (kbm_has(c, KB_LATCH, i)) { synth_note_off(c, i); kbm_clear(c, KB_LATCH, i); }
    } else if (mode == 2) {
        for (i = 0; i < 128; ++i)
            if (kbm_has(c, KB_LATCH, i)) { synth_note_off(c, i); kbm_clear(c, KB_LATCH, i); }
    } else {
        for (i = 127; i >= 0; --i) {
            int k = c->kb_order[i];
            if (kbm_has(c, KB_LATCH, k)) { synth_note_off(c, k & 0xFF); kbm_clear(c, KB_LATCH, k); }
        }
    }
}

/* rva 0x3C4120 (and the voices half of 0x3C42D0): a key onto the voices. With
 * the note sustain on and no key down, the held notes go first; a held note
 * pressed again leaves the hold and plays again. */
static void kb_note_key_on(juno_ctx *c, int k, int vel)
{
    int v = k;
    if (c->kb_sus_note && !kbm_any(c, KB_DOWN)) {
        int i;
        for (i = 127; i >= 0; --i) {
            int o = c->kb_order[i];
            if (kbm_has(c, KB_LATCH, o)) { synth_note_off(c, o & 0xFF); kbm_clear(c, KB_LATCH, o); }
        }
    }
    kbm_put(c, KB_DOWN, k, k);
    if (c->kb_sus_note && kbm_has(c, KB_LATCH, v)) kbm_take(c, KB_LATCH, v, &v);
    if (!kbm_has(c, KB_LATCH, v)) synth_note_on(c, v & 0xFF, vel);
}

/* rva 0x3C40A0 (and the voices half of 0x3C4230): a key off the voices; with
 * the note sustain on its note is held instead */
static void kb_note_key_off(juno_ctx *c, int k)
{
    int v = k;
    kbm_take(c, KB_DOWN, k, &v);
    if (c->kb_sus_note) kbm_put(c, KB_LATCH, v, v);
    if (!kbm_has(c, KB_LATCH, v)) synth_note_off(c, v & 0xFF);
}

/* rva 0x3C3BB0 (and the arp half of 0x3C42D0): a key into the arp. With the arp
 * sustain on and no key in the arp, the held arp keys go first; a key the arp
 * already has is not given again; a held arp key pressed again only leaves the
 * hold. */
static void kb_arp_key_on(juno_ctx *c, int k, int vel)
{
    if (c->kb_sus_arp && c->kb_arp.n <= 0) kb_free_arp_latch(c);
    if (kbl_has(&c->kb_arp, k)) return;
    kbl_add(&c->kb_arp, k);
    if (!kbl_has(&c->kb_arp_latch, k)) carp_add_key(&c->arp, k, vel);   /* rva 0x3C3440 */
    kbl_del(&c->kb_arp_latch, k);
}

/* rva 0x3C3B40: a key out of the arp; with the arp sustain on it is held */
static void kb_arp_key_off(juno_ctx *c, int k)
{
    carp_event ev[64];
    if (!kbl_has(&c->kb_arp, k)) return;
    kbl_del(&c->kb_arp, k);
    if (c->kb_sus_arp) kbl_add(&c->kb_arp_latch, k);
    else arp_dispatch(c, ev, carp_key_off(&c->arp, k, ev, 64));         /* rva 0x3BF290 */
}

/* rva 0x3C4550 / 0x3C4520: the note / arp sustain byte; a release frees what it held */
static void kb_sus_note_set(juno_ctx *c, int on)
{
    if (on == c->kb_sus_note) return;
    c->kb_sus_note = (unsigned char)on;
    if (!on) kb_free_note_latch(c, (signed char)c->kb_flag8);
}
static void kb_sus_arp_set(juno_ctx *c, int on)
{
    if (on == c->kb_sus_arp) return;
    c->kb_sus_arp = (unsigned char)on;
    if (!on) kb_free_arp_latch(c);
}

/* The engine's note-on (CWaveGen vt+128, rva 0x3C7330 -> the keyboard's rva
 * 0x3C42D0): a pending key-trig mode becomes the flag; the key into the arp or
 * onto the voices; then the key's velocity and its place in the press order.
 * This is the ENGINE-level entry the verification gates drive; hosts and UIs
 * enter through juno_gui_midi_note_on below (the wrapper), as a DAW does. */
void juno_gui_note_on(juno_ctx *c, int midi_note, int velocity)
{
    int k;
    ++eb_coef_gen;
    if (!c) return;
    if (c->kb_trig_pending) {
        c->kb_flag8 = (unsigned char)(c->kb_trig_mode - 1) <= 1;
        c->kb_trig_pending = 0;
    }
    if (midi_note < 0 || midi_note > 127) return;
    if (c->arp_on) kb_arp_key_on(c, midi_note, velocity);
    else kb_note_key_on(c, midi_note, velocity);
    c->kb_vel[midi_note] = (unsigned char)velocity;
    for (k = 0; k < 128 && c->kb_order[k] != midi_note && c->kb_order[k] != -1; ++k) ;
    if (k == 128) return;
    for (; k > 0; --k) c->kb_order[k] = c->kb_order[k - 1];
    c->kb_order[0] = midi_note;
}

/* The engine's note-off (CWaveGen vt+120, rva 0x3C72D0 -> the keyboard's rva
 * 0x3C4230): the key out of the arp or off the voices. (Port convenience, no
 * plugin path: midi_note < 0 takes every key the keyboard has down or in the
 * arp off, key order.) */
void juno_gui_note_off(juno_ctx *c, int midi_note)
{
    ++eb_coef_gen;
    if (!c) return;
    if (midi_note < 0) {
        int k;
        for (k = 0; k < 128; ++k)
            if (kbm_has(c, KB_DOWN, k) || kbl_has(&c->kb_arp, k)) juno_gui_note_off(c, k);
        return;
    }
    if (midi_note > 127) return;
    if (c->arp_on) kb_arp_key_off(c, midi_note);
    else kb_note_key_off(c, midi_note);
}

/* CC 64 (CWaveGen vt+288, rva 0x3C7E20 -> the arp controller's rva 0x3C4E90):
 * only a change acts; the keyboard's note sustain, then its arp sustain, follow
 * the controller's byte (a HOLD: keys released under it keep sounding until the
 * pedal is released or a new key is pressed with no key down) */
static void kb_sustain(juno_ctx *c, int on)
{
    if (c->ctl_sus == on) return;
    c->ctl_sus = (unsigned char)on;
    kb_sus_note_set(c, on);
    kb_sus_arp_set(c, c->ctl_sus);
}

/* --- Wrapper-level MIDI note path (what a DAW's events actually go through) ---
 *
 * The real plugin's VST3 wrapper converts host note events to 3-byte MIDI and
 * applies its velocity switch BEFORE the engine ever sees the note. READ
 * (three sites with the identical rule: the event->MIDI queue push rva
 * 0x31F4E0, the all-sound-off injector rva 0x3208E0, the connect-path
 * forwarder rva 0x320A30); the push is graded byte for byte against the plugin
 * (juno_gui_wrapper_midi, tools/verify/wrapper_velocity_gate.py):
 *   - note-on with velocity 0  -> converted to note-off, off-velocity 64
 *   - switch OFF -> every note-on velocity is REPLACED with 100 (the converted
 *                   note-off's too) and every note-off velocity with 64
 *   - switch ON  -> velocities pass through unchanged
 * A fresh instance has the switch ON (below). Every engine A/B gate drives the
 * engine BELOW the wrapper, so none of them sees this layer.
 *
 * The switch (wrapper core +572) is vm.vs.velSense, a value of the plugin's
 * own view state (processor +184, bound by name in rva 0x34E3E0),
 * Script.xml default 1. EXECUTED (probes/b6/kbd_vel_default.py): the core's
 * setup inside IComponent::initialize (rva 0x320420, instruction 0x32079F)
 * writes 1; no setState payload moves it (velSense is not one of the 95 state
 * entries), nor setupProcessing / setActive; the plugin's own switch does,
 * through the model listener (rva 0x321B30, READ: flag = value != 0).
 * juno_gui_create leaves 0 (the core after createInstance, EXECUTED);
 * juno_gui_plugin_init sets 1. The old default (0, forcing 100) came from a
 * READ match of the getter to the SYSTEM table's 'Keyboard Velocity SW'
 * (idx 12, default 0): a different setting the wrapper never reads
 * (playbook 139). Velocity Curve / Offset / Fixed Velocity (SYSTEM idx 13-15)
 * are not read by this path either.
 * The policy itself is READ from the binary. The engine below is untouched. */
void juno_gui_set_kbd_velocity(juno_ctx *c, int on)
{
    if (c) c->kbd_velocity_sw = (on != 0);
}

void juno_gui_wrapper_midi(const juno_ctx *c, unsigned char m[3]);

/* The wrapper's push (rva 0x31F4E0) of one 3-byte message at a sample offset
 * of the next block: a CC the plugin's default map assigns to a parameter (rva
 * 0x319A60, src/midi_tables.h) first queues that parameter's record (kind 1:
 * its id and the CC byte over its range, rva 0x31A850); then, for every
 * message, an assigned CC too, the velocity policy (juno_gui_wrapper_midi) and
 * the message's own record (kind 0) into the queue the render driver applies. */
static void drv_push(juno_ctx *c, unsigned char m[3], int offset)
{
    if ((m[0] & 0xF0) == 0xB0) {
        int e = juno_midi_cc_entry(m[1]);
        if (e >= 0 && c->drv_nq < DRV_QMAX) {
            struct drv_rec *r = &c->drv_q[c->drv_nq++];
            memset(r, 0, sizeof *r);
            r->off = offset;
            r->kind = 1;
            r->id = juno_midi_entry_id(e);
            r->f = juno_midi_cc_value(e, m[2]);
        }
    }
    juno_gui_wrapper_midi(c, m);
    if (c->drv_nq < DRV_QMAX) {
        struct drv_rec *r = &c->drv_q[c->drv_nq++];
        memset(r, 0, sizeof *r);
        r->off = offset;
        r->m[0] = m[0]; r->m[1] = m[1]; r->m[2] = m[2];
    }
}

void juno_gui_midi_note_off(juno_ctx *c, int midi_note)
{
    unsigned char m[3];
    if (!c) return;
    m[0] = 0x80; m[1] = (unsigned char)(midi_note & 0x7F); m[2] = 64;
    drv_push(c, m, 0);
}

/* The wrapper's MIDI intake for one 3-byte message, in place (rva 0x31F4E0,
 * graded byte for byte against the plugin's own push by
 * tools/verify/wrapper_velocity_gate.py): a note-on at velocity 0 becomes a
 * note-off at 64; with the velocity switch off, a note-on's velocity -- the
 * converted note-off's too -- becomes 100 and a note-off's 64. Other
 * messages are not touched here. */
void juno_gui_wrapper_midi(const juno_ctx *c, unsigned char m[3])
{
    int sw = c && c->kbd_velocity_sw;
    if ((m[0] & 0xF0) == 0x90) {
        if (!m[2]) { m[0] = (unsigned char)((m[0] & 0x0F) | 0x80); m[2] = 64; }
        if (!sw) m[2] = 100;
    } else if ((m[0] & 0xF0) == 0x80) {
        if (!sw) m[2] = 64;
    }
}

/* A host note at the start of the next block (offset 0), through the wrapper. */
void juno_gui_midi_note_on(juno_ctx *c, int midi_note, int velocity)
{
    unsigned char m[3];
    if (!c) return;
    m[0] = 0x90; m[1] = (unsigned char)(midi_note & 0x7F); m[2] = (unsigned char)(velocity & 0x7F);
    drv_push(c, m, 0);
}

/* Configure the arpeggiator. on: 0/1. mode: 0=up,1=down,2=up&down (the UI/patch
 * convention). oct: 1..3. bpm: host tempo (<=0 keeps the current tempo — the
 * plugin's arp is host-synced, so BPM is a host input, not a patch value). gate:
 * note-on fraction 0..1, quantised to the machine's GATE table (<0 keeps current).
 * Toggling on/off flushes held keys + any sounding step so play stays clean. */
/* Host transport tempo push: re-time everything tempo-synced (arp clock, synced
 * LFO rate cell 1072, synced delay time 102352 + instance cells) WITHOUT touching
 * the arp pattern/selector state — the plugin's response to a DAW tempo change.
 * The web host calls this after EVERY recall (patch apply AND live host-param
 * edit): the recall re-bakes the synced delay cells at the plugin's 128-BPM
 * recall default (proven: juno_apply_delay_tempo(128) reproduces the baked cells
 * bit-identically), so without a re-push the tempo-synced echoes land 128/120 =
 * 6.7% off the arp's step grid — audibly "off-time" on delay-heavy arp presets.
 * Both appliers are patch-gated (inert while the patch's sync flags are off), so
 * non-synced presets are byte-identical with or without the push. */
void juno_gui_set_tempo(juno_ctx *c, float bpm)
{
    /* the host's tempo for the next blocks (the ProcessContext tempo with
     * kTempoValid): the render driver gives the engine round(tempo x 10) when it
     * changes (40..300 BPM) and times the arp ticks from it */
    if (!c || bpm <= 0.0f) return;
    c->drv_tempo = (double)bpm;
    c->drv_tempo_valid = 1;
}

/* The arp controller's switch, rva 0x3C49F0 (ARPEGGIO SW: dispatch 831 with
 * v != 0; TYPE and STEP re-run it with force when their value changes). Only a
 * change acts, or force. ON runs the config twice (for TYPE, for STEP) before
 * anything moves; then the keyboard's route (+4, rva 0x3C4540) and the arp's
 * own switch (rva 0x3C3450 -> 0x3BE3B0); then the keys. ON: with the pedal
 * down the arp sustain first; the notes the sustain holds go into the arp and
 * out again (so the arp sustain holds them), the note sustain off (its notes
 * leave the voices), then every key down leaves the voices and goes into the
 * arp at its velocity. OFF (the arp idle and reset): with the pedal down the
 * note sustain first; the arp keys the sustain holds go onto the voices and off
 * again (held by the note sustain), the arp sustain off, then every key in the
 * arp leaves it and goes onto the voices -- with the key-trig flag 1 from key
 * 127 down and 2 from key 0 up at velocity 100, else in press order, oldest
 * first, at the key's own velocity. */
static void arp_sw(juno_ctx *c, int on, int force)
{
    carp *e = &c->arp;
    int k, was = c->arp_on, mode;
    if (e->ctl_on == on && !force) return;
    e->ctl_on = on;
    if (on) {
        if ((unsigned)e->ctl_type <= 5) carp_ctl_config(e);
        if ((unsigned)e->ctl_step <= 5) carp_ctl_config(e);
    }
    c->arp_on = on;
    if (on) {
        carp_enable(e);
        if (c->ctl_sus) kb_sus_arp_set(c, 1);
        for (k = 0; k < 128; ++k)
            if (kbm_has(c, KB_LATCH, k)) kb_arp_key_on(c, k, c->kb_vel[k]);
        for (k = 0; k < 128; ++k)
            if (kbm_has(c, KB_LATCH, k)) kb_arp_key_off(c, k);
        if (c->ctl_sus) kb_sus_note_set(c, 0);
        for (k = 0; k < 128; ++k)
            if (kbm_has(c, KB_DOWN, k)) {
                kb_note_key_off(c, k);
                kb_arp_key_on(c, k, c->kb_vel[k]);
            }
    } else {
        carp_event ev[64];
        arp_dispatch(c, ev, carp_disable(e, ev, 64));
        mode = c->kb_flag8;
        if (c->ctl_sus) kb_sus_note_set(c, 1);
        if (mode == 1 || mode == 2) {
            int i;
            for (i = 0; i < 128; ++i) {
                k = mode == 1 ? 127 - i : i;
                if (kbl_has(&c->kb_arp_latch, k)) kb_note_key_on(c, k, 100);
            }
            for (i = 0; i < 128; ++i) {
                k = mode == 1 ? 127 - i : i;
                if (kbl_has(&c->kb_arp_latch, k)) kb_note_key_off(c, k);
            }
            if (c->ctl_sus) kb_sus_arp_set(c, 0);
            for (i = 0; i < 128; ++i) {
                k = mode == 1 ? 127 - i : i;
                if (kbl_has(&c->kb_arp, k)) { kb_arp_key_off(c, k); kb_note_key_on(c, k, 100); }
            }
        } else {
            int i;
            for (i = 127; i >= 0; --i) {
                k = c->kb_order[i];
                if (k != -1 && kbl_has(&c->kb_arp_latch, k)) kb_note_key_on(c, k, c->kb_vel[k]);
            }
            for (i = 127; i >= 0; --i) {
                k = c->kb_order[i];
                if (k != -1 && kbl_has(&c->kb_arp_latch, k)) kb_note_key_off(c, k);
            }
            if (c->ctl_sus) kb_sus_arp_set(c, 0);
            for (i = 127; i >= 0; --i) {
                k = c->kb_order[i];
                if (k != -1 && kbl_has(&c->kb_arp, k)) { kb_arp_key_off(c, k); kb_note_key_on(c, k, c->kb_vel[k]); }
            }
        }
    }
    if (was != on) c->arp_cur = -1;
}

/* ARPEGGIO TYPE (rva 0x3C4E50, dispatch 832) and ARPEGGIO STEP (rva 0x3C49B0,
 * dispatch 833): 0..5 only; a new value re-runs the switch with force; while the
 * arp is on, the config once more. While it is off the value only waits for the
 * next switch-on. The config never touches the selector's index, its "started"
 * flag or the UP&DOWN direction: a new TYPE swaps the selector and the pattern
 * reloads at the next step (PROVEN, probes/host_render/arp_cfg_probe.py). */
static void arp_type_set(juno_ctx *c, int v)
{
    carp *e = &c->arp;
    if ((unsigned)v > 5) return;
    if (e->ctl_type != v) { e->ctl_type = v; arp_sw(c, e->ctl_on, 1); }
    if (e->ctl_on) carp_ctl_config(e);
}

static void arp_step_set(juno_ctx *c, int v)
{
    carp *e = &c->arp;
    if ((unsigned)v > 5) return;
    if (e->ctl_step != v) { e->ctl_step = v; arp_sw(c, e->ctl_on, 1); }
    if (e->ctl_on) carp_ctl_config(e);
}

/* Configure the arpeggiator (UI convenience). on: 0/1. mode: 0=up,1=down,
 * 2=up&down (the UI/patch convention). oct: 1..3. bpm: host tempo (<=0 keeps
 * the current tempo). gate: note-on fraction 0..1, quantised to the machine's
 * GATE table (<0 keeps current; the next config takes the pattern's gate
 * again). Goes through the plugin's own controller: TYPE, STEP, then the
 * switch. Outside a host edit a toggle first flushes every voice and the arp's
 * keys (the recall model's toggle). */
void juno_gui_arp_config(juno_ctx *c, int on, int mode, int oct, float bpm, float gate)
{
    if (!c) return;
    if (bpm > 0.0f) juno_gui_set_tempo(c, bpm);   /* the host tempo (render driver) */
    if ((on != 0) != c->arp_on && !c->host_role) {
        synth_note_off(c, -1);
        carp_remove_key(&c->arp, -1);
        c->arp_cur = -1;
    }
    /* UI mode (0=up,1=down,2=up&down) -> ARPEGGIO TYPE (0=UP,1=UP&DOWN,2=DOWN);
     * UI octaves 1..3 -> ARPEGGIO STEP 0..2 */
    arp_type_set(c, (mode == 1) ? CARP_TYPE_DOWN : (mode == 2) ? CARP_TYPE_UPDOWN : CARP_TYPE_UP);
    arp_step_set(c, (oct < 1 ? 1 : (oct > 3 ? 3 : oct)) - 1);
    arp_sw(c, on != 0, 0);
    if (gate >= 0.0f) carp_set_gate_index(&c->arp, gate_frac_to_index(gate));
}

/* Core recall: apply patch `idx` from `bank` into the engine coefficient slots
 * via the bit-exact applier (src/juno_apply.c), then re-derive the per-patch
 * voice/arp/FX driver state. `flush`: 1 = a patch LOAD (release sounding voices,
 * reset the arp selector); 0 = live host-parameter EDIT (held notes keep
 * ringing, unchanged-arp reconfig skipped).
 *
 * BOTH paths replicate the recall to voices 1..7 as a byte DELTA: snapshot
 * voice 0's block, run the recall (it writes ONLY voice-0 coefficient cells +
 * master/FX cells — never note runtime), then copy exactly the changed voice-0
 * bytes across. That is the plugin's own recall semantics: its per-unit
 * dispatch writes coefficient cells and leaves every voice's evolved RUNTIME
 * (converged smoother outputs/history — e.g. the per-voice CONDITION-target
 * smoothers at rel 4640/4752/5296.., which idle to per-voice-distinct values)
 * untouched. The old load path instead memcpy'd voice 0's ENTIRE block over
 * voices 1..7: invisible from a cold state (all runtime still identical, so
 * every cold gate stayed green) but on a WARM engine — the DAW/webapp case —
 * it falsified the rotation voice's smoother seeds, so the first warm note
 * diverged from the plugin (BS Solid user report; proven by the per-unit
 * idle_units state diff, 2026-07-19). Cells the recall left identical are
 * already correct on the other voices (the last load/edit put them there);
 * per-voice CONDITION/UNISON scatter is re-applied below on all 8 voices.
 * Returns # coefficients set; on snapshot alloc failure the LOAD path falls
 * back to full apply+seed (cold-equivalent, never skips the recall) while the
 * EDIT path returns 0 unapplied. */
/* The STATE half of a recall: the appliers, the voice propagation, the UNISON
 * spread and the CONDITION scatter, into `st` (c->st, or a scratch copy for a
 * host-role edit, juno_gui_host_set). Touches no allocator field of c; the
 * bank-derived caches it sets (last_condition, hpf_type) are the same for any
 * st. Returns # coefficients set, or -1 when the EDIT path could not allocate. */
static int ctx_state_recall(juno_ctx *c, unsigned char *st, const unsigned char *bank, int idx, int flush)
{
    int n;
    {
        unsigned char *pre = malloc(JUNO_VOICE_MAIN_STRIDE);
        const unsigned char *v0 = st + 176;
        int v;
        unsigned i;
        if (!pre) {
            if (!flush) return -1;
            n = c->live_recall ? juno_bank_apply_live(st, bank, idx)
                               : juno_bank_apply(st, bank, idx);
            juno_driver_seed_voices(st);  /* degraded fallback: full seed */
        } else {
            memcpy(pre, st + 176, JUNO_VOICE_MAIN_STRIDE);
            n = c->live_recall ? juno_bank_apply_live(st, bank, idx)
                               : juno_bank_apply(st, bank, idx);
            for (v = 1; v < JUNO_NUM_VOICES; ++v) {
                unsigned char *dst = st + 176 + (unsigned)v * JUNO_VOICE_MAIN_STRIDE;
                for (i = 0; i < JUNO_VOICE_MAIN_STRIDE; ++i)
                    if (v0[i] != pre[i]) dst[i] = v0[i];
            }
            free(pre);
        }
    }
    /* CONDITION analog voice-scatter: per-voice detune/level, applied AFTER seed (it
     * makes the 8 voices deliberately non-identical — the plugin's component-tolerance
     * emulation). Default patch value 128 -> full scatter. */
    /* UNISON (ASSIGN==2) per-voice 3968 detune spread — after seed_voices, which
     * would replicate voice 0's 0.0 over it (fuzz seeds 93/83/61/27, patches 61+63). */
    juno_apply_unison_spread(st, juno_bank_assign(bank, idx));
    c->last_condition = juno_bank_condition(bank, idx);
    c->hpf_type = juno_bank_hpf_type(bank, idx);   /* joint HPF recompute context */
    juno_apply_condition(st, c->last_condition);
    return n;
}

/* The ALLOCATOR half of a recall: ASSIGN MODE / LEGATO / PORTAMENTO into the
 * note allocator (with the plugin's flush on a mode change), the arpeggiator
 * and the tempo-sync stashes, on c and c->st. `settled` is the state the
 * recall left (c->st, or the host edit's scratch copy): the PORTAMENTO on/off
 * the porta gate restores is read from there, never from the live cell, which
 * a note's porta gate may have zeroed (host_edit_gate seed chain 22). */
static void ctx_alloc_recall(juno_ctx *c, const unsigned char *bank, int idx, int flush,
                             const unsigned char *settled)
{
    int porta = 0, old_mode;
    old_mode = c->assign_mode;
    juno_bank_voice_modes(bank, idx, &c->legato, &c->assign_mode, &porta);
    c->portamento_on = (porta != 0);
    /* The value leaf 467+v restores into cell 592 is the PORTAMENTO on/off the
     * recall above just wrote there, so read it back rather than recomputing it. */
    c->porta_base = JF(settled, 592);
    /* HISTORY — why ASSIGN MODE and LEGATO were forced to 0 here, and why that was
     * wrong (docs/ASSIGNER_MODE_FINDING.md). An earlier full-play-path A/B against
     * "the plugin's own render" concluded that all three KEY ASSIGN values are
     * polyphonic. That A/B was measuring an ORACLE WHOSE ALLOCATOR HAD NEVER BEEN
     * TOLD THE MODE. The plugin's allocator (CAssignJu60) caches ASSIGN MODE at
     * assigner+16 and LEGATO at assigner+20, and the ONLY thing that fills them is
     * sub_7FF91DFB49B0(assigner, 4) — which the engine's HOST parameter entry
     * (0x3C7AE0) calls after EVERY parameter write, right after the 0x3B9A30
     * dispatch, but which a bare recall dispatch never calls. So the oracle stayed
     * in POLY for every patch, the port was "corrected" to match it, and both were
     * wrong together — a textbook shared blind spot.
     * Executed proof (probes/assigner/laneX_audio_impact.py): running the plugin's
     * OWN refresh after its OWN recall, changing nothing else, moves its OWN audio
     * by +16.65 dB on BS Solid (Chillwave 3, ASSIGN=2) and +17.43 dB on BS Glide,
     * with every sample differing; ASSIGN=0 patches stay bit-identical (control).
     * The patch's real values are therefore used, and the allocator modes below
     * (mono_note_on / unison_note_on, transcribed from sub_7FF91DFB38F0 /
     * sub_7FF91DFB3B60) are live. Gated by tools/verify/assigner_ab.py. */
    /* A CHANGE of ASSIGN MODE flushes the sounding voices so the new allocator
     * starts clean: the plugin's mode reader (rva 0x3549F0, called by the assigner
     * refresh after every parameter write) compares the new mode with its cached
     * one (assigner +0x10) and ONLY when they differ calls hold-off (0x354C70) and
     * all-notes-off (0x3530B0: release every gated voice, clear the note slots and
     * the legato mask). READ. The port flushed on EVERY patch load, so a key held
     * across a same-mode patch change was released here and kept sounding in the
     * plugin (tools/verify/warm_render_gate.py, rapid family). The same rule holds
     * for a live edit of ASSIGN MODE. */
    if (c->assign_mode != old_mode) {
        int v;
        /* all-notes-off also clears the assigner's note slots (+0x60..+0x74 :=
         * 0xff "no note", rva 0x3530C7), so no voice keeps its old note: a MONO
         * note-on after the change must not gate voices 1..7 off again (it did,
         * arming their DCO latches; warm_render_gate rapid family). */
        for (v = 0; v < JUNO_NUM_VOICES; ++v)
            if (c->voice_note[v] >= 0) { juno_note_off(c->st, v); c->voice_gated[v] = 0; c->voice_note[v] = -1; }
        c->held_notes[0] = c->held_notes[1] = c->held_notes[2] = c->held_notes[3] = 0;
        juno_note_broadcast_held(c->st, 0);   /* nothing held after the flush */
        c->legato_mask = 0;                   /* assigner+68, zeroed by the mode-change
                                                 path sub_7FF91DFB49F0 */
    }
    /* Per-patch ARPEGGIATOR recall (the recall MODEL; a host-role edit drives the
     * controller itself, juno_gui_host_set): the record's ARPEGGIO SW / TYPE /
     * STEP through the plugin's controller in the order the arp gates' oracle
     * calls it (tools/verify/arp_sched_ab.py), every one on a patch LOAD, only a
     * changed one on a live edit (a TYPE / STEP setter run while the arp is on
     * clears the octave offset and reloads the pattern: an unrelated slider must
     * not). A toggle first flushes every voice and the arp's keys. SCATTER TYPE /
     * DEPTH (leaf 92/93, record byte 322/330) through their setters (dispatch
     * 834/835) -- INFERRED for the recall model: the plugin's state and patch
     * loads never send them (src/juno_state_tables.h), and all 64 factory
     * patches hold (0,0), which the setters leave as built. */
    if (!c->host_role) {
        int on, sw = 0, typ = 0, step = 0, stype = 0, sdepth = 0;
        juno_bank_arp_raw(bank, idx, &sw, &typ, &step);
        juno_bank_scatter(bank, idx, &stype, &sdepth);
        on = sw != 0;
        if (on != c->arp_on) {
            synth_note_off(c, -1);
            carp_remove_key(&c->arp, -1);
            c->arp_cur = -1;
        }
        if (flush || on != c->arp.ctl_on) arp_sw(c, on, 0);
        if (flush || typ != c->rm_arp_type) arp_type_set(c, typ);
        if (flush || step != c->rm_arp_step) arp_step_set(c, step);
        carp_ctl_scatter_type(&c->arp, stype, 0);
        carp_ctl_scatter_depth(&c->arp, sdepth, 0);
        c->rm_arp_type = typ;
        c->rm_arp_step = step;
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
}

static int ctx_recall(juno_ctx *c, const unsigned char *bank, int idx, int flush)
{
    int n = ctx_state_recall(c, c->st, bank, idx, flush);
    if (n < 0) return 0;
    ctx_alloc_recall(c, bank, idx, flush, c->st);
    return n;
}

/* The MODEL record: what the plugin's model holds for the patch, as a one-record
 * bank (the bank header + one record) in c->bank, c->patch_idx 0. Every host
 * edit (juno_gui_host_set) changes it and runs its recall; the plugin's own
 * preset paths (juno_gui_plugin_init / _state_load / _load_patch) change it only
 * through host edits, starting from the model at boot (JUNO_DEFAULT_REC, the
 * plugin's own serialization of its defaults). NULL until the first use. */
#define MODEL_BANK_BYTES (23 + JUNO_REC_BYTES)
static int ctx_model(juno_ctx *c, const unsigned char *hdr)
{
    static const unsigned char HDR[23] = { 'K','o','a','B','a','n','k','F','i','l','e',
                                           '0','0','0','0','3','P','G','-','J','U','6','0' };
    if (!c->bank) {
        c->bank = malloc(MODEL_BANK_BYTES);
        if (!c->bank) return 0;
        c->bank_len = MODEL_BANK_BYTES;
        memcpy(c->bank + 23, JUNO_DEFAULT_REC, JUNO_REC_BYTES);
    }
    memcpy(c->bank, hdr ? hdr : HDR, 23);
    c->patch_idx = 0;
    return 1;
}

/* Apply bank patch `idx` (raw KoaBankFile00003 bytes in `bank`, `len` bytes) into
 * this engine's coefficient slots by the RECALL the gates model (the engine's
 * own recall enumerator, flag 1: CLAIMS A17-A19); the plugin's own patch load is
 * juno_gui_load_patch. The record becomes the model record, so the host-parameter
 * panel can edit a byte and re-run the EXACT same recall. Returns # coefficients
 * set. Rejects any idx whose full record does not fit in len
 * (juno_bank_num_patches): recall READS record bytes, so applying a truncated
 * bank would be an out-of-bounds access (native: segfault; WASM: silent heap
 * corruption). */
int juno_gui_apply_bank(juno_ctx *c, const unsigned char *bank, int len, int idx)
{
    ++eb_coef_gen;
    if (!c || !bank || len <= 0) return 0;
    if (idx < 0 || idx >= juno_bank_num_patches(bank, (unsigned long)len)) return 0;
    if (!ctx_model(c, bank)) return ctx_recall(c, bank, idx, 1);   /* no model copy: recall the caller's */
    memcpy(c->bank + 23, bank + 23 + (size_t)idx * JUNO_REC_BYTES, JUNO_REC_BYTES);
    return ctx_recall(c, c->bank, 0, 1);
}

/* A patch change on a RUNNING engine as the plugin does it (CLAIMS B1): the
 * recall's ramped cells (slot switches, voice mutes, reverb send and decay
 * coefficients) glide over 4 ms instead of jumping; juno_gui_apply_bank is the
 * same recall settled, which is what every gate compares against the harness
 * snap. Graded by tools/verify/warm_render_gate.py live. */
int juno_gui_apply_bank_live(juno_ctx *c, const unsigned char *bank, int len, int idx)
{
    int n;
    if (!c) return 0;
    c->live_recall = 1;
    n = juno_gui_apply_bank(c, bank, len, idx);
    c->live_recall = 0;
    return n;
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
int         juno_gui_host_min(int i)         { return juno_host_param_min(i); }
int         juno_gui_host_max(int i)         { return juno_host_param_max(i); }

static int host_only_slot(int i)
{
    const char *n = juno_host_param_name(i);
    if (juno_host_param_type(i) == 4) return 2;          /* MASTER TUNE */
    if (juno_host_param_type(i) != 3) return -1;
    return strcmp(n, "LFO RATE H") ? 1 : 0;
}

int juno_gui_host_get(juno_ctx *c, int i)
{
    int k;
    if (!c || !c->bank) return -1;
    k = host_only_slot(i);
    if (k >= 0) return c->host_only_set[k] ? c->host_only[k] : juno_host_param_default(i);
    return juno_host_param_decode(juno_bank_record(c->bank, c->patch_idx), i);
}

#ifndef EB_DEVCELLS
/* host parameter index of a panel name (src/juno_hostparams.c), -1 if none */
static int host_index(const char *name)
{
    int k, n = juno_host_param_count();
    for (k = 0; k < n; ++k)
        if (!strcmp(juno_host_param_name(k), name)) return k;
    return -1;
}

static int host_val(const unsigned char *rec, const char *name)
{
    int k = host_index(name);
    return k < 0 ? 0 : juno_host_param_decode(rec, k);
}

/* A HOST-ROLE edit as the plugin's host parameter entry makes it (CLAIMS B7):
 * the settled recall of the edited record runs on a scratch copy of the state
 * (so its values are the setters' values), then the plugin's own set list for
 * this parameter (src/host_edit.c) ramps / writes those values into the live
 * state; nothing else moves, as in the plugin. The allocator half of the
 * recall (ASSIGN MODE flush, arpeggiator) then runs on the live context.
 * Returns 0 (nothing done, record untouched) when the scratch copy cannot be
 * allocated or the census did not cover the key. */
static int host_edit_live(juno_ctx *c, unsigned char *rec, int i, int v)
{
    juno_host_feat f;
    unsigned char *tmp;
    unsigned char keep[2];
    int roff = juno_host_param_roff(i);
    if (roff < 0) return 0;
    f.from = juno_gui_host_get(c, i);
    if (i == host_index("VCF CUTOFF FREQ")) f.from = juno_rr_cut_last(c->st);   /* the object's last value */
    f.et = host_val(rec, "EFFECT TYPE");
    f.dt = host_val(rec, "DELAY TYPE");
    f.pl = host_val(rec, "ASSIGN MODE") == 0 && host_val(rec, "LEGATO") == 1;
    f.arpon = juno_rr_arp_on(c->st);
    f.cutbyte = host_val(rec, "VCF CUTOFF FREQ");
    f.ron0 = juno_reverb_level_on(host_val(rec, "REVERB LEVEL"));
    keep[0] = rec[roff]; keep[1] = rec[roff + 1];
    juno_host_param_encode(rec, i, v);
    f.to = host_only_slot(i) >= 0 ? v : juno_host_param_decode(rec, i);
    f.ron1 = juno_reverb_level_on(host_val(rec, "REVERB LEVEL"));
    tmp = (unsigned char *)malloc(JUNO_STATE_BYTES);
    if (tmp) {
        juno_ctx t = *c;
        memcpy(tmp, c->st, JUNO_STATE_BYTES);
        /* settle the live ramps on the copy first, so the recall meets the
         * cells at their targets (a recall arm whose target is already stored
         * early-outs and leaves the cell where it was: unsettled, a glide in
         * flight would read as the recall's value; host_edit_gate fx chain 13) */
        juno_rr_settle(tmp);
        t.live_recall = 0;
        if (ctx_state_recall(&t, tmp, c->bank, c->patch_idx, 0) >= 0) {
            f.don1 = JI(tmp, JUNO_DLY_ON) != 0;
            if (juno_host_edit_covered(i, &f)) {
                juno_host_edit(c->st, tmp, i, &f);
                /* the processor state the setters keep */
                JI(c->st, JUNO_PREV_EFX)  = JI(tmp, JUNO_PREV_EFX);
                JI(c->st, JUNO_PREV_DLY)  = JI(tmp, JUNO_PREV_DLY);
                JI(c->st, JUNO_DLY_ON)    = JI(tmp, JUNO_DLY_ON);
                JI(c->st, JUNO_PREV_FB)   = JI(tmp, JUNO_PREV_FB);
                JI(c->st, JUNO_PREV_RESO) = JI(tmp, JUNO_PREV_RESO);
                juno_rr_copy_proc(c->st, tmp);
                if (i == host_index("ARPEGGIO SW")) juno_rr_set_arp_on(c->st, f.to != 0);
                if (host_only_slot(i) >= 0) {
                    c->host_only[host_only_slot(i)] = v;
                    c->host_only_set[host_only_slot(i)] = 1;
                }
                /* the cutoff object's last value (rva 0x3597F0's step law reads it):
                 * the byte, or the H float as (int)(H * 255.0f) (rva 0x359890:
                 * mulss, cvttss2si) */
                if (i == host_index("VCF CUTOFF FREQ")) juno_rr_set_cut_last(c->st, v);
                if (i == host_index("VCF CUTOFF FREQ H")) {
                    float h;
                    memcpy(&h, &v, 4);
                    juno_rr_set_cut_last(c->st, (int)(h * 255.0f));
                }
                c->last_condition = t.last_condition;
                c->hpf_type = t.hpf_type;
                c->host_role = 1;
                ctx_alloc_recall(c, c->bank, c->patch_idx, 0, tmp);
                c->host_role = 0;
                free(tmp);
                return 1;
            }
        }
        free(tmp);
    }
    rec[roff] = keep[0]; rec[roff + 1] = keep[1];
    return 0;
}
#endif

/* A host parameter change as the plugin's host entry (rva 0x3C7AE0) takes it.
 * A value outside the parameter's database range reaches no setter and is
 * dropped (EXECUTED: EFFECT/DELAY/REVERB TYPE 6..255, VCF CUTOFF 256, DELAY TAP
 * TIME 101, MASTER TUNE 201 -> no setter call); HPF TYPE is mapped to (v != 0)
 * first. OCTAVE SHIFT reaches its setter but writes no engine cell (EXECUTED,
 * fresh engines: identical state and audio): it changes the record only.
 * MASTER TUNE ramps every voice's tune cell (its own program, host-only value).
 * CLAIMS A20 / B8. */
void juno_gui_host_set(juno_ctx *c, int i, int v)
{
    unsigned char *rec;
    if (!c || !c->bank) return;
    rec = juno_bank_record(c->bank, c->patch_idx);
    if (!rec) return;
    /* LFO KEY TRIG (dispatch 756): the entry first sets the keyboard object's
     * key-trig mode byte, whatever the value, while that byte is 0..2 (rva
     * 0x3C4ED0; a wild value therefore sticks), then range-checks as usual */
    if (i >= 0 && i < juno_host_param_count() && !strcmp(juno_host_param_name(i), "LFO KEY TRIG") &&
        c->kb_trig_mode <= 2 && (int)(signed char)c->kb_trig_mode != v) {
        c->kb_trig_mode = (unsigned char)v;
        c->kb_trig_pending = 1;
    }
    /* mapped before the range check (rva 0x3C7AE0: dispatch 871 HPF TYPE, and
     * 831 ARPEGGIO SW, whose switch the entry calls with (v != 0) directly) */
    if (i >= 0 && i < juno_host_param_count() &&
        (!strcmp(juno_host_param_name(i), "HPF TYPE") || !strcmp(juno_host_param_name(i), "ARPEGGIO SW"))) v = (v != 0);
    if (v < juno_host_param_min(i) || v > juno_host_param_max(i)) return;
#ifndef EB_DEVCELLS
    if (i == host_index("ARPEGGIO SW") || i == host_index("ARPEGGIO TYPE") || i == host_index("ARPEGGIO STEP")) {
        /* the arp row: the host entry calls the controller's own setter (rva
         * 0x3C7AE0, dispatch 831..833); its engine cells are the apply's sends
         * (dispatch 312..318, src/host_edit.c), the record keeps the value */
        if (!(juno_host_edit_known(i) && host_edit_live(c, rec, i, v))) {
            juno_host_param_encode(rec, i, v);
            c->host_role = 1;
            ctx_recall(c, c->bank, c->patch_idx, 0);
            c->host_role = 0;
        }
        if (i == host_index("ARPEGGIO SW")) arp_sw(c, v != 0, 0);
        else if (i == host_index("ARPEGGIO TYPE")) arp_type_set(c, v);
        else arp_step_set(c, v);
        c->rm_arp_type = host_val(rec, "ARPEGGIO TYPE");
        c->rm_arp_step = host_val(rec, "ARPEGGIO STEP");
        return;
    }
    if (juno_host_edit_known(i) && host_edit_live(c, rec, i, v)) return;
    if (!strcmp(juno_host_param_name(i), "OCTAVE SHIFT")) {
        juno_host_param_encode(rec, i, v);
        return;
    }
#endif
    juno_host_param_encode(rec, i, v);
    ctx_recall(c, c->bank, c->patch_idx, 0);
}

static int ro_switch(juno_ctx *c);

/* vm.vs.sampleRate (id 0x0FFFC015, in the DAW state, value & 0x7F): the core's
 * listener (rva 0x3222F0) sets the engine rate the next block switches to: the
 * value indexes the table at rva 0x94AB80 (0..4: 96000, 88200, 48000, 44100,
 * 32000; 6..127: the bytes that follow it -- EXECUTED, 6 -> 0, 127 ->
 * 1634624882: no render object, silence); 5 is automatic, the engine's
 * current rate (rva 0x34B260). Script.xml's range 0..3 is not applied. */
void juno_gui_set_engine_rate_setting(juno_ctx *c, int value)
{
    double r;
    int cur;
    if (!c) return;
    r = (double)JF(c->st, 16);                       /* rva 0x34B260: round, clamp */
    r = r >= 0.0 ? floor(r + 0.5) : ceil(r - 0.5);
    cur = !(r >= -2147483647.0) ? (int)0x80000001u : (r > 2147483647.0 ? 0x7FFFFFFF : (int)r);
    c->eng_req = juno_ro_setting_rate(value, cur, &c->eng_auto);
    ro_switch(c);              /* a fresh start switches at once; else the next block */
}

/* --- The plugin's own preset paths (CLAIMS B6, src/juno_state_tables.h) -------
 * EXECUTED in the booted plugin (probes/b6/): IComponent::initialize, setState
 * and the patch browser's load all set model values, and the core queues one
 * engine event (id, value) per value; the render driver applies the queue at the
 * start of the next block through the host entry, in order. So each is a list
 * of host edits: a panel parameter through juno_gui_host_set (which drops a
 * value outside the database range), vm.vs.voiceCount stored for the render
 * (A21), everything else (patch name, view state) reaches no engine cell. */
static void engine_host_entry(juno_ctx *c, int host, int32_t v);

static void apply_event(juno_ctx *c, int host, int32_t v)
{
    if (host == JUNO_SE_SRATE) {         /* the core's listener, at once (rva 0x3222F0) */
        juno_gui_set_engine_rate_setting(c, v);
        return;
    }
    /* while records wait for the next block, a preset path queues behind them:
     * the plugin applies every one of its paths' events in that order */
    if (c->drv_queue_mode || c->drv_nq > 0) {               /* the model's record for the next block */
        if (c->drv_nq < DRV_QMAX) {
            struct drv_rec *r = &c->drv_q[c->drv_nq++];
            memset(r, 0, sizeof *r);
            r->kind = 2; r->host = host; r->v = v;
        }
        return;
    }
    engine_host_entry(c, host, v);
}

/* The engine's host entry (CWaveGen vt+112, rva 0x3C7AE0): the voice count
 * (vm.vs.voiceCount) to the engine's field; an id of its map to the units;
 * any other id (the engine-rate setting among them) nothing. */
static void engine_host_entry(juno_ctx *c, int host, int32_t v)
{
    if (host >= 0) juno_gui_host_set(c, host, v);
    else if (host == JUNO_SE_VOICES) juno_gui_set_voice_count(c, v);
}

/* The start-up mute and initialize's 95 defaults, applied at once, ahead of any
 * record already queued (the plugin queues them for its first block; nothing
 * renders before it). `setting`: the engine-rate setting's entry too -- the
 * core's listener, at initialize; it is no engine event, so the replay after a
 * rate switch leaves it out. */
static void plugin_defaults(juno_ctx *c, int setting)
{
    int k, q = c->drv_queue_mode, nq = c->drv_nq;
    juno_driver_arm_latch(c->st);
    c->drv_queue_mode = 0;
    c->drv_nq = 0;
    for (k = 0; k < JUNO_STATE_N; ++k)
        if (setting || JUNO_STATE_ENT[k].host != JUNO_SE_SRATE)
            apply_event(c, JUNO_STATE_ENT[k].host, JUNO_STATE_ENT[k].dflt);
    c->drv_queue_mode = q;
    c->drv_nq = nq;
}

/* The engine-rate switch (rva 0x320BA2: setSampleRate, then the render object's
 * lookup; found, the tick phase and note count start again). Exact here when
 * nothing has happened since the start -- the state byte-equal to a fresh
 * create + plugin_init at this host rate: the plugin switches its built engine
 * before its first block's queue (the defaults, the DAW's events), so the
 * result is the build at the new rate (the cold state coldstate_ab.py grades),
 * the mute and the defaults. A switch on an engine that has run is the
 * plugin's setSampleRate in place: CLAIMS B13b, not ported -- ro_unported is
 * set, the port keeps its rate and object. Returns 1 when it switched. */
int juno_gui_plugin_init(juno_ctx *c);

static int ro_switch(juno_ctx *c)
{
    if (c->ro_model || c->ro.engine == c->eng_req || c->ro_unported) return 0;
    if ((float)c->eng_req != JF(c->st, 16)) {
        juno_ctx *ref = ctx_create((float)c->drv_rate, c->chorus_mode);
        int same;
        if (!ref) return 0;
        juno_gui_plugin_init(ref);
        same = !memcmp(ref->st + 176, c->st + 176, JUNO_STATE_BYTES - 176);
        juno_gui_destroy(ref);
        if (!same) { c->ro_unported = 1; return 0; }
        st_build(c->st, (float)c->eng_req, &c->shim, c->chorus_mode);
        plugin_defaults(c, 0);
    }
    c->ro.engine = c->eng_req;
    if (juno_ro_lookup(&c->ro) > 0) { c->drv_phase = 0; c->drv_notes = 0; }
    return 1;
}

/* The plugin as shipped: its engine built at the constructor's 96000 with the
 * render object for (96000, host rate) -- the converter at a 44100 / 48000
 * host, silence at a rate outside the table (CLAIMS B13); the construction
 * mutes every unit for its first 960 engine samples (juno_driver_arm_latch);
 * the 95 defaults IComponent::initialize queues (e.g. six voices) apply at the
 * first block. Call once, right after create. */
int juno_gui_plugin_init(juno_ctx *c)
{
    if (!c || !ctx_model(c, 0)) return 0;
    /* the plugin's engine: built at the constructor's 96000 (rva 0x3C5A50 ->
     * the build; no setSampleRate follows while the setting is the default),
     * and the core's render object for (96000, the host rate) -- setupProcessing
     * (rva 0x321AC0) looks it up and, found, zeroes the tick phase and note count */
    if (JF(c->st, 16) != 96000.0f) st_build(c->st, 96000.0f, &c->shim, c->chorus_mode);
    c->ro_model = 0;
    c->eng_req = 96000;
    c->eng_auto = 0;
    juno_ro_free(&c->ro);
    juno_ro_init(&c->ro, 96000, c->drv_rate);
    if (juno_ro_lookup(&c->ro) > 0) { c->drv_phase = 0; c->drv_notes = 0; }
    juno_engine_no_setsr(c->st);
    plugin_defaults(c, 1);
    /* initialize's core setup (rva 0x320420) sets the wrapper's velocity switch
     * from vm.vs.velSense, whose default is 1 (Script.xml; EXECUTED:
     * probes/b6/kbd_vel_default.py): a fresh instance plays the key's own
     * velocity. velSense is not in the state list, so no preset changes it;
     * only the plugin's own switch does (juno_gui_set_kbd_velocity). */
    c->kbd_velocity_sw = 1;
    return JUNO_STATE_N;
}

/* initialize on the ENGINE MODEL: the defaults and the start-up mute on the
 * engine juno_gui_create made, which renders the host block itself at that
 * rate, any rate (no table, no 96 kHz build). Not a plugin configuration where
 * the rates differ from the table's (host 96001: the plugin plays silence);
 * the configuration of the gates whose oracle is an engine fed the plugin's
 * queues at the gate's rate (state_load_gate.py). */
int juno_gui_plugin_init_model(juno_ctx *c)
{
    if (!c || !ctx_model(c, 0)) return 0;
    plugin_defaults(c, 1);
    c->kbd_velocity_sw = 1;
    return JUNO_STATE_N;
}

static uint32_t be(const unsigned char *p, int n)
{
    uint32_t v = 0;
    while (n--) v = (v << 8) | *p++;      /* the deserializer keeps the low 32 bits */
    return v;
}

/* IComponent::setState: `data` is the stream the plugin's getState writes -- a
 * big-endian byte count, then (id, value) entries, 4-byte big-endian fields (8
 * when the count exceeds (95 + 128) * 64 / 5: rva 0x321F20). Each entry whose
 * id is in the parameter list takes value & its storage mask (EXECUTED: 8, 7 or
 * 16 bits, or the value as given) and is applied in PAYLOAD order; other ids
 * (the 128 MIDI-assign entries, unknown ids) reach no engine cell. Returns the
 * number of parameter entries applied, -1 for an empty or short stream (the
 * plugin returns kResultFalse and sets nothing). */
int juno_gui_state_load(juno_ctx *c, const unsigned char *data, int len)
{
    uint32_t n, off, w;
    int k, applied = 0;
    if (!c || !data || len < 4 || !ctx_model(c, 0)) return -1;
    n = be(data, 4);
    if (n == 0 || n > (uint32_t)len - 4) return -1;
    w = ((JUNO_STATE_N + 128) << 6) / 5 < (int)n ? 8 : 4;
    for (off = 0; off + 2 * w <= n; off += 2 * w) {
        uint32_t id = be(data + 4 + off, (int)w);
        int32_t v = (int32_t)be(data + 4 + off + w, (int)w);
        for (k = 0; k < JUNO_STATE_N && JUNO_STATE_ENT[k].id != id; ++k) ;
        if (k == JUNO_STATE_N) continue;
        if (JUNO_STATE_ENT[k].mask) v = (int32_t)((uint32_t)v & JUNO_STATE_ENT[k].mask);
        apply_event(c, JUNO_STATE_ENT[k].host, v);
        ++applied;
    }
    return applied;
}

/* the model's set-from-bytes (EXECUTED, probes/b6/patch_load_census.py --craft):
 * nibble fields are the bytes OR-ed in place, nothing masked */
static int32_t rec_value(const unsigned char *r, const juno_patch_ev *e)
{
    uint32_t v = 0;
    int i, n;
    switch (e->dec) {
    case JUNO_DEC_INT1X7: return r[e->roff];
    case JUNO_DEC_INT2X4: return (r[e->roff] << 4) | r[e->roff + 1];
    case JUNO_DEC_INT8X4: n = 8; break;
    default:              n = 4; break;
    }
    for (i = 0; i < n; ++i) v |= (uint32_t)r[e->roff + i] << (4 * (n - 1 - i));
    return (int32_t)v;
}

/* The plugin's own patch load (its patch browser, rva 0x335850): every value
 * of record `idx` in the patch tree's order -- MASTER TUNE first, then the
 * panel parameters, the name, the extended leaves -- as host edits. Leaves
 * outside the parameter list (e.g. the LFO / OSC waves) never reach the engine:
 * the model record keeps the defaults there. Returns the events applied, 0 for
 * an idx whose record is not in `bank`. */
int juno_gui_load_patch(juno_ctx *c, const unsigned char *bank, int len, int idx)
{
    const unsigned char *r;
    int k;
    if (!c || !bank || len <= 0) return 0;
    if (idx < 0 || idx >= juno_bank_num_patches(bank, (unsigned long)len)) return 0;
    if (!ctx_model(c, bank)) return 0;
    r = bank + 23 + (size_t)idx * JUNO_REC_BYTES;
    memcpy(c->bank + 23, r, 16);          /* the patch's name: display only */
    for (k = 0; k < JUNO_PATCH_EV_N; ++k)
        apply_event(c, JUNO_PATCH_EV[k].host, rec_value(r, &JUNO_PATCH_EV[k]));
    return JUNO_PATCH_EV_N;
}

/* The same three model paths as the PLUGIN orders them for the engine: the
 * core queues one record per value (rva 0x347050) and the render driver applies
 * them at offset 0 of the next block, after any arp tick due there. */
int juno_gui_queue_state(juno_ctx *c, const unsigned char *data, int len)
{
    int r;
    if (!c) return -1;
    c->drv_queue_mode = 1;
    r = juno_gui_state_load(c, data, len);
    c->drv_queue_mode = 0;
    return r;
}
int juno_gui_queue_patch(juno_ctx *c, const unsigned char *bank, int len, int idx)
{
    int r;
    if (!c) return 0;
    c->drv_queue_mode = 1;
    r = juno_gui_load_patch(c, bank, len, idx);
    c->drv_queue_mode = 0;
    return r;
}
void juno_gui_queue_host(juno_ctx *c, int host, int v)
{
    if (!c) return;
    c->drv_queue_mode = 1;
    apply_event(c, host, v);
    c->drv_queue_mode = 0;
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

/* ---- THE RENDER DRIVER (rva 0x320B20, docs/HOST_RENDER_LAYER.md) --------- */

/* One queued record through the engine (the consumer's switch, rva 0x3211D6).
 * Kind 2, a preset path's value: the engine's host entry (vt+112). Kind 1, a
 * parameter record (a CC the map assigns; a host parameter through process()):
 * the id map (rva 0x319AB0) gives its entry -- none, nothing -- and the host
 * entry takes the entry's value (rva 0x31A940). Kind 0, a MIDI message by its
 * status: note-off (vt+120) and note-on (vt+128) count down / up the note count
 * core+568; CC (vt+136: rva 0x34AE90 -- 1 the mod wheel, 11 the expression,
 * 64 the sustain, 123 all notes off, others nothing); pitch bend (vt+152: the
 * 14 bits less 8192, as 16 bits); poly and channel aftertouch, program change
 * (vt+160 / +168 / +144): empty functions. */
static void apply_event(juno_ctx *c, int host, int32_t v);
static void engine_host_entry(juno_ctx *c, int host, int32_t v);

/* CC 123 (CWaveGen vt+296, rva 0x3C7DA0 -> the keyboard's rva 0x3C3A00 -> the
 * assigner's controller vt+32 with 123, rva 0x354A90 -> its all-notes-off, rva
 * 0x3530B0; the assigner's hold +24 is never set through the engine): a
 * gate-off for every voice of the count whose slot is gated (rva 0x355270) --
 * each gate leaf ends with the held flag 1856 = "a voice still gated", so the
 * last one leaves 0 -- then every slot "no note", the held-note mask and +68
 * cleared. The keyboard's maps and the arp stay as they are. */
static void kb_all_notes_off(juno_ctx *c)
{
    int v, n = c->asg_count < JUNO_NUM_VOICES ? c->asg_count : JUNO_NUM_VOICES, any = 0;
    for (v = 0; v < n; ++v)
        if (c->voice_gated[v]) { juno_note_off(c->st, v); any = 1; }
    for (v = 0; v < JUNO_NUM_VOICES; ++v) {
        c->voice_note[v] = -1;
        c->voice_gated[v] = 0;
    }
    c->held_notes[0] = c->held_notes[1] = c->held_notes[2] = c->held_notes[3] = 0;
    c->legato_mask = 0;
    if (any) juno_note_broadcast_held(c->st, 0);
}

static void drv_cc(juno_ctx *c, int n, int v)
{
    switch (n) {
    case 1:   juno_midi_mod(c->st, v); break;
    case 11:  juno_midi_expression(c->st, v); break;
    case 64:  kb_sustain(c, v != 0); break;
    case 123: kb_all_notes_off(c); break;
    default:  break;                       /* 10 (vt+272) and the rest: nothing */
    }
}

static void drv_apply(juno_ctx *c, const struct drv_rec *r)
{
    const unsigned char *m = r->m;
    if (r->kind == 2) { apply_event(c, r->host, r->v); return; }   /* the engine's host entry (vt+112) */
    if (r->kind == 1) {
        int e = juno_midi_entry(r->id);
        if (e >= 0) engine_host_entry(c, juno_midi_entry_host(e), juno_midi_record_value(e, r->f));
        return;
    }
    switch (m[0] & 0xF0) {
    case 0x80: juno_gui_note_off(c, m[1]); c->drv_notes--; break;
    case 0x90: juno_gui_note_on(c, m[1], m[2]); c->drv_notes++; break;
    case 0xB0: drv_cc(c, m[1], m[2]); break;
    case 0xE0: juno_midi_bend(c->st, (uint16_t)(m[1] + ((m[2] - 64) << 7))); break;
    default: break;
    }
}

/* The tempo the engine is given (CWaveGen vt+176, rva 0x3C7F10): x10 in
 * 400..3000 dispatches the tempo leaf (375) to every unit, any other value
 * nothing. */
static void drv_engine_tempo(juno_ctx *c, int t10)
{
    if ((unsigned)(t10 - 400) > 0xA28u) return;
    juno_rr_set_tempo(c->st, t10);                   /* processor +1056 (rva 0x3B9710) */
    c->host_bpm = (float)t10 / 10.0f;
    juno_apply_lfo_tempo_t10(c->st, c->lfo_rate_byte, t10);
    juno_apply_delay_tempo_t10(c->st, c->dly_time_byte, c->dly_sync, c->dly_type);
}

typedef struct { float *il, *L, *R; int dry, full; } drv_out;

/* One engine sample (the engine render's per-sample body). */
static void drv_engine_sample(juno_ctx *c, drv_out *o, float *l, float *r)
{
    juno_note_tick(c->st);
    if (o->dry) {
        float vbuf[JUNO_NUM_VOICES];
        int v;
        juno_driver_render_voices(c->st, vbuf);   /* 8 voices; noise block stepped once */
        *l = 0.0f;
        for (v = 0; v < JUNO_NUM_VOICES; ++v) *l += vbuf[v];
        *r = *l;
        o->full = 1;
    } else {
        o->full = juno_driver_render_sample(c->st, l, r);
    }
}

static void drv_out_sample(juno_ctx *c, drv_out *o, int t, float l, float r)
{
    if (o->il) { o->il[2 * t] = l; o->il[2 * t + 1] = r; }
    if (o->L) o->L[t] = l;
    if (o->R) o->R[t] = r;
    if (c->arp_trace_cap) c->arp_trace_smp++;
}

static void drv_render_sample(juno_ctx *c, drv_out *o, int t)
{
    float l, r;
    drv_engine_sample(c, o, &l, &r);
    drv_out_sample(c, o, t, l, r);
}

/* The engine render (CWaveGen vt+56, rva 0x3C7400) the converter calls: its
 * preamble (the voice count sync), then `count` samples into ptrs. */
static void ro_engine_render(void *user, float *const *ptrs, int nch, int count)
{
    juno_ctx *c = (juno_ctx *)user;
    int i;
    asg_sync(c);
    for (i = 0; i < count; ++i) {
        float l, r;
        drv_engine_sample(c, (drv_out *)c->ro_out, &l, &r);
        ptrs[0][i] = l;
        if (nch > 1) ptrs[1][i] = r;
    }
}

/* One segment of the host block, samples [t0, t0 + n), through the render
 * object (CWaveGen vt+48, rva 0x34B070: n >= 1): IDENTITY, the engine render
 * of the n samples; CONVERTER (rva 0x343E30), the engine renders what the
 * filter needs, the filter makes the n host samples; SILENCE (rva 0x344280),
 * zeros and no engine render. The engine model (juno_gui_create) renders as
 * IDENTITY. */
static void ro_render(juno_ctx *c, drv_out *o, int t0, int n)
{
    int kind, t;
    if (n <= 0) return;
    kind = c->ro_model ? JUNO_RO_IDENTITY : juno_ro_kind(&c->ro);
    if (kind == JUNO_RO_IDENTITY) {
        asg_sync(c);
        for (t = t0; t < t0 + n; ++t) drv_render_sample(c, o, t);
        return;
    }
    if (kind == JUNO_RO_CONVERTER) {
        float *out[2];
        if (n > c->ro_tmp_cap) {
            float *p = (float *)realloc(c->ro_tmp, (size_t)(2 * n) * sizeof(float));
            if (p) { c->ro_tmp = p; c->ro_tmp_cap = n; }
        }
        if (n <= c->ro_tmp_cap) {
            out[0] = c->ro_tmp;
            out[1] = c->ro_tmp + c->ro_tmp_cap;
            c->ro_out = o;
            if (juno_ro_convert(&c->ro, out, 2, n, ro_engine_render, c) == 0) {
                for (t = 0; t < n; ++t) drv_out_sample(c, o, t0 + t, out[0][t], out[1][t]);
                return;
            }
        }
    }
    for (t = t0; t < t0 + n; ++t) drv_out_sample(c, o, t, 0.0f, 0.0f);   /* SILENCE (or out of memory) */
}

/* One host block of n samples: the driver's tempo, the queued records at
 * their offsets, the arp tick clock, the engine render with its preamble at
 * the start of every segment. */
static void drv_block(juno_ctx *c, int n, drv_out *o)
{
    static struct drv_rec rec[2 * DRV_QMAX];
    int nrec = 0, i, k, t, cut, T, s0;
    long long P, ph;
    /* the engine rate (rva 0x320BA2): a setting that asks another rate switches
     * the engine (setSampleRate) and the render object; the object found, the
     * tick phase and the note count start again */
    ro_switch(c);
    /* the tempo (rva 0x320C04): round(tempo x 10.0), half away from zero (rva
     * 0x3F2050), clamped to an int; given to the engine only when the host's
     * tempo is valid and it changed */
    {
        double r = c->drv_tempo * 10.0;
        r = r >= 0.0 ? floor(r + 0.5) : ceil(r - 0.5);
        if (!(r >= -2147483647.0)) T = -2147483647;
        else if (r > 2147483647.0) T = 0x7FFFFFFF;
        else T = (int)r;
    }
    if (T != c->drv_tempo_last && c->drv_tempo_valid) {
        c->drv_tempo_last = T;
        drv_engine_tempo(c, T);
    }
    /* the tick period (rva 0x320C93): (60e9 x host rate / T) / 24, in 1e-8
     * host samples. T <= 0 divides by zero or never advances in the plugin (no
     * host sends such a tempo): the port then ticks no more. */
    P = T > 0 ? (60000000000LL * (long long)c->drv_rate / T) / 24 : (long long)1 << 62;
    if (P <= 0) P = (long long)1 << 62;
    /* the records: last block's deferred ones first (rva 0x31E7E0), then this
     * block's. A note-on at or before the block's last note-off moves one
     * sample after it; offsets never go down; from the first record at or after
     * n on, every record waits for the next block, at offset 0 */
    for (i = 0; i < c->drv_ncarry; ++i) rec[nrec++] = c->drv_carry[i];
    for (i = 0; i < c->drv_nq; ++i) rec[nrec++] = c->drv_q[i];
    c->drv_ncarry = c->drv_nq = 0;
    {
        int last = -1, lastoff = -1;
        cut = nrec;
        for (i = 0; i < nrec; ++i) {
            int st = rec[i].kind ? 0 : rec[i].m[0] & 0xF0, off = rec[i].off;
            if (st == 0x90) {
                if (off <= lastoff) { off = lastoff + 1; rec[i].off = off; }
            } else if (st == 0x80) {
                lastoff = off;
            }
            if (off <= last) { rec[i].off = last; off = last; }
            last = off;
            if (n <= off) { cut = i; break; }
        }
        for (i = cut; i < nrec && c->drv_ncarry < DRV_QMAX; ++i) {
            c->drv_carry[c->drv_ncarry] = rec[i];
            c->drv_carry[c->drv_ncarry++].off = 0;
        }
    }
    /* sample by sample: the ticks due at or before the sample's start, the
     * records at the sample (the first key restarts the clock with a tick),
     * the ticks inside the sample; each of them ends the segment before the
     * sample, which renders first through the render object (ro_render) */
    ph = c->drv_phase;
    k = 0;
    s0 = 0;
    for (t = 0; t < n; ++t) {
        int seg = (t == 0);
        if (ph <= 100000000LL * t) {
            if (!seg) { ro_render(c, o, s0, t - s0); s0 = t; seg = 1; }
            while (ph <= 100000000LL * t) { drv_tick(c); ph += P; }
        }
        if (k < cut && rec[k].off == t) {
            int before = c->drv_notes;
            if (!seg) { ro_render(c, o, s0, t - s0); s0 = t; seg = 1; }
            while (k < cut && rec[k].off == t) { drv_apply(c, &rec[k]); ++k; }
            if (!before && c->drv_notes > 0) { ph = 100000000LL * t + P; drv_tick(c); }
        }
        if (ph < 100000000LL * (t + 1)) {
            if (!seg) { ro_render(c, o, s0, t - s0); s0 = t; seg = 1; }
            while (ph < 100000000LL * (t + 1)) { drv_tick(c); ph += P; }
        }
    }
    ro_render(c, o, s0, n - s0);
    c->drv_phase = ph - 100000000LL * n;
}

/* Render nframes stereo samples into out (interleaved L,R): one host block
 * through the render driver, with the records queued since the last call.
 * Returns 1 if the full master/chorus path ran, 0 if the dry fallback was used. */
int juno_gui_render(juno_ctx *c, float *out, int nframes)
{
    drv_out o;
    if (!c || nframes <= 0) return 0;
    memset(&o, 0, sizeof o);
    o.il = out;
    drv_block(c, nframes, &o);
    return o.full;
}

/* The plugin's IAudioProcessor::process for one block (rva 0x34A380): host
 * note events (type 0 on, 1 off; velocity 0..1 as the host gives it) become
 * MIDI -- status = channel | 0x90 / 0x80, data1 = pitch & 0x7F, data2 =
 * (int)(float)(velocity x 127.0) & 0x7F -- pushed through the wrapper at their
 * sample offsets; the host tempo (tempo_valid = the ProcessContext's
 * kTempoValid) and the block through the render driver. outL / outR: n each. */
int juno_gui_process_ex(juno_ctx *c, const juno_host_note *ev, int nev, const juno_host_param *par, int npar,
                        int tempo_valid, double tempo, float *outL, float *outR, int n);
int juno_gui_process(juno_ctx *c, const juno_host_note *ev, int nev, int tempo_valid, double tempo,
                     float *outL, float *outR, int n)
{
    return juno_gui_process_ex(c, ev, nev, 0, 0, tempo_valid, tempo, outL, outR, n);
}

/* One host parameter queue's last point through the plugin's process() (rva
 * 0x34A380): an id below the MIDI-mapping base (core +48) becomes a parameter
 * record (kind 1, rva 0x31F2C0: the value as a float); base + n becomes a MIDI
 * message through the push -- n 0..127 the CC n with round(value x 127), 128
 * channel aftertouch the same, 129 the pitch bend round(value x 16383) as two
 * 7-bit bytes (rounded half away from zero, rva 0x3F2050; below 0 or NaN 0,
 * above 255 / 65535 that), any other n three zero bytes. */
static void proc_param(juno_ctx *c, const juno_host_param *p)
{
    int32_t id = (int32_t)p->id, base = (int32_t)juno_midi_base();
    unsigned char m[3] = { 0, 0, 0 };
    if (base > id) {
        if (c->drv_nq < DRV_QMAX) {
            struct drv_rec *r = &c->drv_q[c->drv_nq++];
            memset(r, 0, sizeof *r);
            r->off = p->offset;
            r->kind = 1;
            r->id = p->id;
            r->f = (float)p->value;
        }
        return;
    }
    {
        uint32_t d = (uint32_t)id - (uint32_t)base;
        if (d <= 128u) {
            double x = p->value * 127.0;
            unsigned char b;
            x = (x >= 0.0 || x != x) ? floor(x + 0.5) : ceil(x - 0.5);
            b = !(x >= 0.0) ? 0 : (x > 255.0 ? 0xFF : (unsigned char)(int)x);
            if (d < 128u) { m[0] = 0xB0; m[1] = (unsigned char)d; m[2] = b; }
            else { m[0] = 0xD0; m[1] = b; }
        } else if (d == 129u) {
            double x = p->value * 16383.0;
            unsigned w;
            x = (x >= 0.0 || x != x) ? floor(x + 0.5) : ceil(x - 0.5);
            w = !(x >= 0.0) ? 0u : (x > 65535.0 ? 0xFFFFu : (unsigned)(int)x & 0xFFFFu);
            m[0] = 0xE0; m[1] = (unsigned char)(w & 0x7F); m[2] = (unsigned char)((w >> 7) & 0x7F);
        }
    }
    drv_push(c, m, p->offset);
}

/* juno_gui_process with the host's parameter queues (one entry per queue: its
 * last point, the one the plugin reads), after the note events, in queue
 * order. */
int juno_gui_process_ex(juno_ctx *c, const juno_host_note *ev, int nev, const juno_host_param *par, int npar,
                        int tempo_valid, double tempo, float *outL, float *outR, int n)
{
    drv_out o;
    int i;
    if (!c || n <= 0) return 0;
    for (i = 0; i < nev; ++i) {
        unsigned char m[3];
        float v = ev[i].velocity;
        m[0] = (unsigned char)((ev[i].channel & 0x0F) | (ev[i].type == 0 ? 0x90 : 0x80));
        m[1] = (unsigned char)(ev[i].pitch & 0x7F);
        m[2] = (unsigned char)((int)(float)((double)v * 127.0) & 0x7F);
        drv_push(c, m, ev[i].offset);
    }
    for (i = 0; i < npar; ++i) proc_param(c, &par[i]);
    c->drv_tempo_valid = tempo_valid != 0;
    c->drv_tempo = tempo_valid ? tempo : 120.0;
    memset(&o, 0, sizeof o);
    o.L = outL; o.R = outR;
    drv_block(c, n, &o);
    return o.full;
}

/* One sample of the driver's control half without the render: the multi-core
 * split (pi/) runs it on every core's copy, then each core renders its voices.
 * A one-sample block: the queued records at offset 0, the ticks of the sample. */
void juno_gui_tick(juno_ctx *c)
{
    static struct drv_rec rec[2 * DRV_QMAX];
    int i, nrec = 0, T;
    long long P, ph;
    if (!c) return;
    {
        double r = c->drv_tempo * 10.0;
        r = r >= 0.0 ? floor(r + 0.5) : ceil(r - 0.5);
        T = !(r >= -2147483647.0) ? -2147483647 : (r > 2147483647.0 ? 0x7FFFFFFF : (int)r);
    }
    if (T != c->drv_tempo_last && c->drv_tempo_valid) { c->drv_tempo_last = T; drv_engine_tempo(c, T); }
    P = T > 0 ? (60000000000LL * (long long)c->drv_rate / T) / 24 : (long long)1 << 62;
    if (P <= 0) P = (long long)1 << 62;
    for (i = 0; i < c->drv_ncarry; ++i) rec[nrec++] = c->drv_carry[i];
    for (i = 0; i < c->drv_nq; ++i) rec[nrec++] = c->drv_q[i];
    c->drv_ncarry = c->drv_nq = 0;
    ph = c->drv_phase;
    while (ph <= 0) { drv_tick(c); ph += P; }
    if (nrec) {
        int before = c->drv_notes;
        for (i = 0; i < nrec; ++i) drv_apply(c, &rec[i]);
        if (!before && c->drv_notes > 0) { ph = P; drv_tick(c); }
    }
    while (ph < 100000000LL) { drv_tick(c); ph += P; }
    c->drv_phase = ph - 100000000LL;
    juno_note_tick(c->st);
    if (c->arp_trace_cap) c->arp_trace_smp++;
}

/* Warm the engine to its steady idle state, exactly as a DAW does by rendering
 * silence continuously from the moment the plugin is activated: blocks of 512
 * through the render driver (its ticks run as they do in the plugin), output
 * discarded. A freshly prepared engine holds ~190 smoothed control cells that
 * converge only WHILE rendering; until they do the first note audibly swells.
 * In a DAW the host has always rendered long before the user plays, so the
 * browser app warms up at boot to match. */
void juno_gui_warmup(juno_ctx *c, int nsamples)
{
    float buf[2 * 512];
    if (!c) return;
    while (nsamples > 0) {
        int b = nsamples > 512 ? 512 : nsamples;
        juno_gui_render(c, buf, b);
        nsamples -= b;
    }
}

/* Render the DRY voice signal (the sum of the 8 voices, the master/chorus/output
 * stage bypassed) through the same driver: the note preview of the old app. */
int juno_gui_render_dry(juno_ctx *c, float *out, int nframes)
{
    drv_out o;
    if (!c || nframes <= 0) return 0;
    memset(&o, 0, sizeof o);
    o.il = out; o.dry = 1;
    drv_block(c, nframes, &o);
    return 1;
}
