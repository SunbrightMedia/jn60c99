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

    /* Last raw SCATTER TYPE/DEPTH handed to carp_set_scatter, so a live edit can
     * skip the arp reconfig when the patch's arp settings are unchanged (the
     * reconfig resets the pattern selector to step 0 — audible restart on every
     * slider move otherwise). calloc zero-init == carp_init's (0,0) default. */
    int   last_scatter_type;
    int   last_scatter_depth;
    int   kbd_velocity_sw;   /* SYSTEM "Keyboard Velocity SW": 0 = force vel 100
                              * (the wrapper's rule, see juno_gui_midi_note_on) */
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

juno_ctx *juno_gui_create(float sample_rate, int chorus_mode)
{
    ++eb_coef_gen;
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
        juno_live_delay_sync(c->st, c->dly_time_byte, c->dly_sync, c->dly_type,
                             c->host_bpm);
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
 * overrides it with the patch's own EFFECT TYPE, exactly as before. */
void juno_gui_set_chorus_mode(juno_ctx *c, int mode)
{
    ++eb_coef_gen;
    c->chorus_mode = mode;
    juno_driver_attach_host(c->st, &c->shim, mode);
    *(int32_t *)(c->st + JUNO_PROG_EFX) = mode;
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
        for (v = 0; v < JUNO_NUM_VOICES; ++v)
            if (c->voice_gated[v]) { silent = 0; break; }
        for (v = 0; v < JUNO_NUM_VOICES; ++v)
            juno_note_porta_gate(c->st, v, silent, c->porta_base);
        if (silent) c->legato_mask = (1u << JUNO_NUM_VOICES) - 1u;
        for (i = 0; i < JUNO_NUM_VOICES; ++i)
            if (i != pick && ((c->legato_mask >> i) & 1u)) {
                if (c->voice_note[i] != midi_note) juno_note_glide(c->st, i, midi_note);
                c->voice_note[i] = midi_note;
            }
    }

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
        }
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
        /* THE ARPEGGIATOR'S EVENTS ARE NOTE EVENTS, so they bump the
         * coefficient generation counter like every other note event does.
         *
         * They did not until now, and the consequence was total: engine B
         * mirrors the port's event-written cells on a generation bump, so an
         * arp-driven note was invisible to it and an arpeggiated patch played
         * SILENCE. Seven of the sixty-four factory patches use the arpeggiator.
         *
         * It survived because no null scenario used an arp patch. It was found
         * the moment one was added -- for EFFECT TYPE 1, whose only patch in
         * the bank happens to have the arp on. Coverage added for one reason
         * found a defect of another. */
        ++eb_coef_gen;
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

/* Public note-on: feeds the arp's held-key set when enabled, else the synth.
 * This is the ENGINE/router-level entry (the oracle's NOTEON equivalent) — the
 * verification gates drive it directly with raw velocities, exactly as they
 * drive the plugin's engine under emulation. Hosts/UIs must enter through
 * juno_gui_midi_note_on below (the wrapper layer), like a DAW does. */
void juno_gui_note_on(juno_ctx *c, int midi_note, int velocity)
{
    ++eb_coef_gen;
    if (!c) return;
    if (!c->arp_on) { synth_note_on(c, midi_note, velocity); return; }
    carp_add_key(&c->arp, midi_note, velocity);
}

/* Public note-off. midi_note < 0 releases everything. */
void juno_gui_note_off(juno_ctx *c, int midi_note)
{
    ++eb_coef_gen;
    if (!c) return;
    if (!c->arp_on) { synth_note_off(c, midi_note); return; }
    carp_remove_key(&c->arp, midi_note);     /* midi_note < 0 => release all */
}

/* --- Wrapper-level MIDI note path (what a DAW's events actually go through) ---
 *
 * The real plugin's VST3 wrapper converts host note events to 3-byte MIDI and
 * applies the SYSTEM setting "fm.SYSTEM.COM.Keyboard Velocity SW" BEFORE the
 * engine ever sees the note. READ (static decomp, three independent sites all
 * implementing the identical rule: the event->MIDI queue push rva 0x31F4E0,
 * the all-sound-off injector rva 0x3208E0, and the connect-path forwarder rva
 * 0x320A30; the flag byte lives at wrapperqueue+572 and is refreshed from the
 * settings object at rva 0x320420):
 *   - note-on with velocity 0  -> converted to note-off, off-velocity 64
 *   - Keyboard Velocity SW OFF -> every note-on velocity is REPLACED with 100
 *                                 and every note-off velocity with 64
 *   - Keyboard Velocity SW ON  -> velocities pass through unchanged
 * So by default the real instrument IGNORES how hard you play — faithful to
 * the velocity-insensitive JUNO-60 keyboard — while the port used to pass raw
 * velocities through, making every patch's brightness/level vary per keystroke
 * where the plugin is rock-steady (the user's "always sounded wrong" report;
 * velocity-sens cells scale both VCF and VCA). Every A/B gate was blind to
 * this: both gate sides drive the engine BELOW the wrapper.
 *
 * Default kbd_velocity_sw = 0 (forcing ON). Label: READ (upgraded from INFERRED
 * 2026-07-28, probes/hostpath/system_velocity_defaults.py). The plugin's own
 * descriptor table (rva 0x98c040 + 16*idx) read against its own name table
 * (rva 0x9a0030) gives, for the fm.SYSTEM.COM keyboard family:
 *     idx 12 'Keyboard Velocity SW'      min 0  max 1    default 0   <- OFF
 *     idx 13 'Keyboard Fixed Velocity'   min 0  max 126  default 126
 *     idx 14 'Keyboard Velocity Curve'   min 0  max 2    default 1
 *     idx 15 'Keyboard Velocity Offset'  min -10 max 10  default 0
 * so a fresh instance really does default to SW OFF, i.e. every note forced to
 * the constant 100 that the three decompiled wrapper sites hardcode. (Each range
 * matches its own name — a 0..1 "SW", a +-10 "Offset" — which self-validates that
 * this is the right table.) Velocity Curve and Velocity Offset are separate
 * SYSTEM settings the port does not model; both sit at an identity default
 * (curve 1 = the middle of 0..2, offset 0), so a default instance is unaffected.
 * Deriving their laws is only needed if those settings are ever exposed.
 * The policy itself is READ from the binary. The engine below is untouched. */
void juno_gui_set_kbd_velocity(juno_ctx *c, int on)
{
    if (c) c->kbd_velocity_sw = (on != 0);
}

void juno_gui_midi_note_off(juno_ctx *c, int midi_note)
{
    /* off-velocity (64 forced / raw) is inert in the engine: the assigner's
     * noteOff zeroes velocity (oracle NOTEOFF, e2e_emu.py) and the port's
     * note-off path carries none — so no velocity parameter here. */
    juno_gui_note_off(c, midi_note);
}

void juno_gui_midi_note_on(juno_ctx *c, int midi_note, int velocity)
{
    if (!c) return;
    if (velocity == 0) { juno_gui_midi_note_off(c, midi_note); return; }
    if (!c->kbd_velocity_sw) velocity = 100;
    juno_gui_note_on(c, midi_note, velocity);
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
    if (!c || bpm <= 0.0f) return;
    c->host_bpm = bpm;
    carp_set_bpm(&c->arp, (double)bpm);
    juno_apply_lfo_tempo(c->st, c->lfo_rate_byte, (float)c->arp.bpm);
    juno_apply_delay_tempo(c->st, c->dly_time_byte, c->dly_sync, c->dly_type,
                           (float)c->arp.bpm);
}

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
static int ctx_recall(juno_ctx *c, const unsigned char *bank, int idx, int flush)
{
    int n, mode = 0, oct = 1, on, porta = 0;
    {
        unsigned char *pre = malloc(JUNO_VOICE_MAIN_STRIDE);
        const unsigned char *v0 = c->st + 176;
        int v;
        unsigned i;
        if (!pre) {
            if (!flush) return 0;
            n = juno_bank_apply(c->st, bank, idx);
            juno_driver_seed_voices(c->st);  /* degraded fallback: full seed */
        } else {
            memcpy(pre, c->st + 176, JUNO_VOICE_MAIN_STRIDE);
            n = juno_bank_apply(c->st, bank, idx);
            for (v = 1; v < JUNO_NUM_VOICES; ++v) {
                unsigned char *dst = c->st + 176 + (unsigned)v * JUNO_VOICE_MAIN_STRIDE;
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
    juno_apply_unison_spread(c->st, juno_bank_assign(bank, idx));
    c->last_condition = juno_bank_condition(bank, idx);
    c->hpf_type = juno_bank_hpf_type(bank, idx);   /* joint HPF recompute context */
    juno_apply_condition(c->st, c->last_condition);
    /* Per-patch VOICE-ASSIGN recall (CAssignJu60): ASSIGN MODE (poly/mono/unison/
     * poly-variant), LEGATO, and PORTAMENTO-engaged drive the note allocator above. */
    juno_bank_voice_modes(bank, idx, &c->legato, &c->assign_mode, &porta);
    c->portamento_on = (porta != 0);
    /* The value leaf 467+v restores into cell 592 is the PORTAMENTO on/off the
     * recall above just wrote there, so read it back rather than recomputing it. */
    c->porta_base = JF(c->st, 592);
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
        c->legato_mask = 0;                   /* assigner+68, zeroed by the mode-change
                                                 path sub_7FF91DFB49F0 */
    }
    /* Per-patch ARPEGGIATOR recall: on/mode/range come from the patch (bit-exact,
     * see juno_bank_arp); rate stays local (the plugin's arp is host-tempo-synced,
     * no per-patch rate). This makes "arp presets" arpeggiate on load.
     * On a LIVE EDIT (flush=0) the reconfig is SKIPPED when the recalled arp
     * settings equal the running state: juno_gui_arp_config -> carp_set_mode
     * unconditionally resets the pattern selector to step 0, so re-running it on
     * every slider move audibly restarted the arpeggio mid-pattern. When the edit
     * DID change an arp setting (SW/TYPE/STEP sliders), the reset is the correct
     * mode-change semantics and runs as before. */
    {
        int stype = 0, sdepth = 0;
        int cur_mode = (c->arp.type == 0) ? 0 : (c->arp.type == 1) ? 2 : 1;
        int cur_oct  = c->arp.range + 1;
        on = juno_bank_arp(bank, idx, &mode, &oct);
        juno_bank_scatter(bank, idx, &stype, &sdepth);
        if (flush || on != c->arp_on || mode != cur_mode || oct != cur_oct
                  || stype != c->last_scatter_type || sdepth != c->last_scatter_depth) {
            juno_gui_arp_config(c, on, mode, oct, -1.0f, -1.0f);  /* keep UI bpm/gate */
            /* Per-patch SCATTER pattern grid: SCATTER TYPE/DEPTH (proven leaf 92/93
             * -> record byte 322/330) select the arp's STEP x SLOT grid. All 64
             * factory patches decode to (0,0) = the default slab0/sub7 grid. Applied
             * AFTER arp_config (which resets the selector) so the pattern load lands
             * last. See scratchpad/oracle/scatter_recall_spec.md. */
            carp_set_scatter(&c->arp, stype, sdepth);
            c->last_scatter_type = stype;
            c->last_scatter_depth = sdepth;
        }
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
 * Returns # coefficients set. Rejects any idx whose full record does not fit in
 * len (juno_bank_num_patches): recall READS and the host-param panel WRITES
 * record bytes, so applying a truncated bank would be an out-of-bounds access
 * (native: segfault; WASM: silent heap corruption). */
int juno_gui_apply_bank(juno_ctx *c, const unsigned char *bank, int len, int idx)
{
    ++eb_coef_gen;
    if (!c || !bank || len <= 0) return 0;
    if (idx < 0 || idx >= juno_bank_num_patches(bank, (unsigned long)len)) return 0;
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
int         juno_gui_host_min(int i)         { return juno_host_param_min(i); }
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
