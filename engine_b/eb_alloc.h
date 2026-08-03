/* eb_alloc.h — the voice allocator: CAssignJu60's law, engine B's copy.
 *
 * WHY THIS FILE EXISTS. engine_b/eb_engine.c shipped a SKELETON allocator --
 * "first free voice, else oldest" -- and said so in its own comment. That is
 * not the instrument's law, and the consequence is not subtle: the port itself
 * ran a POLY-only allocator for months, and 16 of the 64 factory patches
 * (14 MONO, 2 UNISON) played in the wrong voice-assign mode the whole time,
 * through every green gate. See docs/ASSIGNER_MODE_FINDING.md. This module
 * replaces the skeleton with the real law and is gated against it.
 *
 * PROVENANCE. Transcribed from gui/juno_bridge.c's allocator, which is itself a
 * faithful transcription of the plugin's CAssignJu60 (ctor sub_7FF91DFB59D0,
 * poly alloc sub_7FF91DFB3150, mono sub_7FF91DFB38F0, unison sub_7FF91DFB3B60)
 * and is PROVEN 34/34 against the plugin's own assigner by
 * tools/verify/assigner_ab.py in `make verify`. Every non-obvious rule below
 * carries the reason the bridge records for it, because each one was found by a
 * divergence and would be "simplified" back out by anyone who did not know.
 *
 * WHAT IT DOES AND DOES NOT DO. It decides BINDINGS -- which voice plays which
 * note, which voices are gated, and the age ordering -- and it emits the events
 * the port performs as juno_note_* cell writes (trigger, glide, velocity,
 * note-off, retrigger latch, portamento gate). It performs NO cell writes
 * itself: those belong to the CV modules. That split is what makes it gateable
 * on its own, by comparing bindings after every event against the port's.
 *
 * THE FOUR RULES MOST LIKELY TO BE "TIDIED" WRONG:
 *
 *  1. POLY's gate-off scan runs 7 -> 0, NOT 0 -> 7. The plugin keeps a
 *     voice-priority list initialised [0..7] and scans it from the TOP, so from
 *     a fresh state it allocates 7,6,5,...  PROVEN by a running-code diff
 *     against CAssignJu60: 10 notes land on slots 7..0.
 *
 *  2. THE NOTE->VOICE BINDING IS PERSISTENT and must never be reaped when an
 *     envelope decays. MEASURED (fuzz seed 7, the plugin's own assigner): a
 *     re-struck note returns to its previous voice even after a full second of
 *     silence. An earlier port version reaped it and diverged audibly.
 *
 *  3. MONO and UNISON arm the DCO phase-reset latch on retrigger; POLY does
 *     not. Missing it cost fuzz seed 15 (MONO) and -34.6 dB on patch 61
 *     (UNISON). For UNISON the arm belongs in the was-idle branch ONLY -- the
 *     glide branch is bit-exact without it and breaks with it.
 *
 *  4. MONO/UNISON note-off falls back to the LOWEST still-held note, not the
 *     most recent. Last-note priority on press, lowest-held on release.
 */
#ifndef ENGINEB_EB_ALLOC_H
#define ENGINEB_EB_ALLOC_H

#include <stdint.h>

#define EB_ALLOC_VOICES 8

/* The cell-writing actions the port performs. The allocator emits them in the
 * port's order; the caller applies them. */
enum {
    EB_EV_TRIGGER = 0,   /* juno_note_on: full gate edge          (note, vel) */
    EB_EV_GLIDE,         /* juno_note_glide: pitch move, no gate  (note)      */
    EB_EV_VELOCITY,      /* juno_note_velocity: refresh, no gate  (vel)       */
    EB_EV_NOTE_OFF,      /* juno_note_off: gate release                       */
    EB_EV_RETRIG,        /* juno_note_retrig: arm the DCO latch               */
    EB_EV_PORTA_GATE,    /* juno_note_porta_gate                  (arg = off) */
    EB_EV_HELD           /* juno_note_broadcast_held              (arg)       */
};

typedef struct {
    uint8_t kind;
    int8_t  voice;       /* -1 for engine-wide events */
    int16_t a, b;        /* note/arg, velocity */
} eb_alloc_ev;

#define EB_ALLOC_MAX_EV 40

typedef struct {
    int      voice_note[EB_ALLOC_VOICES];   /* -1 = never assigned */
    uint8_t  voice_gated[EB_ALLOC_VOICES];
    uint32_t voice_age[EB_ALLOC_VOICES];
    uint32_t age_counter;
    uint32_t held_notes[4];                 /* the assigner's a1[20..23] */
    uint32_t legato_mask;
    /* recalled configuration */
    int  assign_mode;                       /* 0 POLY, 1 MONO, 2 UNISON, 3 variant */
    int  legato;
    int  portamento_on;
} eb_alloc;

void eb_alloc_init(eb_alloc *a);

/* Both return the number of events written to `ev` (at most EB_ALLOC_MAX_EV). */
int eb_alloc_note_on(eb_alloc *a, int midi_note, int velocity, eb_alloc_ev *ev);
int eb_alloc_note_off(eb_alloc *a, int midi_note, eb_alloc_ev *ev);

#endif /* ENGINEB_EB_ALLOC_H */
