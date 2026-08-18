/* juno_event.h -- THE ONE BOUNDARY EVERY INPUT CROSSES.
 *
 * FINAL_GUIDE step O1 (was C11), USER-BINDING 2026-08-12:
 *   "Keybed, panel, DIN, USB all submit events through one small header.
 *    Nothing else may reach the engine."
 *
 * ---------------------------------------------------------------------------
 * WHY A BOUNDARY AND NOT JUST A FUNCTION CALL
 *
 * The boundary is WHERE THE CAP LIVES. Anything behind it -- including a panel
 * board a user solders in later, whose firmware nobody here has read -- may
 * only SUBMIT. It never renders, never touches the cell array, never blocks,
 * never allocates. So a misbehaving add-on cannot break the audio: it can only
 * fill a bounded queue, and a full queue means its events land LATE.
 *
 * That is THE INVARIANT's rule 3 -- LATENCY DEGRADES, CONTINUITY DOES NOT --
 * extended to code that does not exist yet.
 *
 * ---------------------------------------------------------------------------
 * WHAT THIS FIXES TODAY, and it is not hypothetical
 *
 * Before this header, `s3_midi_event()` was the single note entry and it did
 * this when a second key arrived inside one 5.8 ms block:
 *
 *     if (note_pending) { ++notes_dropped;
 *         health_fail("a note was DROPPED rather than delayed"); return; }
 *
 * A DROPPED note is not a late note. Rule 3 says the change ARRIVES LATER; it
 * does not say the change may be discarded. The firmware was honest about it
 * -- it counted the drop and reddened the health line -- and its own comment
 * said "A real queue is owed". This is that queue. Playing a two-note chord
 * fast enough was a guaranteed lost note, on an instrument whose whole point
 * is that it never breaks.
 *
 * ---------------------------------------------------------------------------
 * ⚠ ITEM-7 TOOL. A keybed sends notes and an encoder sends parameter values on
 * ANY synth. This header carries straight to the JX-3P and to whatever comes
 * after it. NOTHING IN IT MAY BE JUNO-SPECIFIC:
 *   - `param_id` is an INDEX INTO A PER-SYNTH TABLE, never a JUNO constant.
 *   - note and velocity are 0..127 because that is MIDI's range, which is a
 *     property of other people's keyboards, not of this instrument.
 *   - no engine type, no cell offset, and no coefficient struct appears here.
 * A JUNO constant added to this file is a defect against END_GOAL item 7 in
 * exactly the way a wrong coefficient is a defect against item 1.
 *
 * It is also free of ESP-IDF: the queue's only platform hook is a lock, which
 * the port supplies (see JUNO_EVQ_LOCK below). That is what lets the host test
 * drive the identical code the firmware runs.
 */
#ifndef JUNO_EVENT_H
#define JUNO_EVENT_H

/* THE PORT'S OWN SETTINGS, if it has any. Pass
 * -DJUNO_EVQ_PORT_HEADER='"juno_event_port.h"' and that file supplies the lock
 * and any size override BEFORE the defaults below are chosen. A port that
 * needs nothing passes nothing and gets the no-op lock, which is correct for a
 * single-threaded host test and NOT correct on the device -- so the device
 * build MUST pass it, and esp32s3/main/CMakeLists.txt does. */
#ifdef JUNO_EVQ_PORT_HEADER
#include JUNO_EVQ_PORT_HEADER
#endif

#ifdef __cplusplus
extern "C" {
#endif

/* ---------------------------------------------------------------- the tag */
/* EVERY EVENT CARRIES A SOURCE. One byte. It costs nothing and it is what
 * lets the health line say WHICH input caused a fault instead of only that one
 * occurred -- rule 4, no silent failure. Add sources at the END; the numbers
 * appear in logs. */
typedef enum {
    JUNO_SRC_NONE   = 0,
    JUNO_SRC_KEYBED = 1,   /* the instrument's own keys */
    JUNO_SRC_PANEL  = 2,   /* encoders, switches, the front panel */
    JUNO_SRC_DIN    = 3,   /* 5-pin MIDI in */
    JUNO_SRC_USB    = 4,   /* USB MIDI */
    JUNO_SRC_CONSOLE= 5,   /* the debug console acting as a keyboard */
    JUNO_SRC_LINK   = 6,   /* the other chip (O6) */
    JUNO_SRC__N     = 7
} juno_src;

typedef enum {
    JUNO_EV_NOTE_ON  = 0,
    JUNO_EV_NOTE_OFF = 1,
    JUNO_EV_PARAM    = 2
} juno_ev_kind;

/* 4 bytes. Deliberately small: the queue is a fixed array and its size is a
 * memory decision that has to be defensible on a chip with 74 KB free. */
typedef struct {
    unsigned char kind;    /* juno_ev_kind */
    unsigned char src;     /* juno_src */
    unsigned char a;       /* note 0..127        | param_id low 8 bits */
    unsigned char b;       /* velocity 0..127    | value 0..255 */
} juno_event;

/* ------------------------------------------------------------- submitting */
/* THE ONLY THREE CALLS ANY INPUT MAY MAKE.
 *
 * All three are SUBMIT-ONLY: they enqueue and return. They never render,
 * never block, never allocate, and they are safe to call from any task.
 *
 * RETURN: 1 if the event was queued, 0 if the queue was FULL. A 0 is a
 * refusal, it is counted (juno_event_stats), and the caller must not retry in
 * a loop -- a full queue means the consumer is behind, and spinning on it is
 * how a submit-only boundary turns into a blocking one. */
int juno_event_note_on (juno_src src, int note, int velocity);
int juno_event_note_off(juno_src src, int note);
int juno_event_param   (juno_src src, int param_id, int value_0_255);

/* ---------------------------------------------------------------- draining */
/* Called by the engine side at a block boundary. Copies up to `max` events out
 * of the queue into `out` and returns how many.
 *
 * `max` IS THE CAP, and the cap is rule 2: a fixed amount of work per block,
 * more blocks when there is more to do. The caller sizes it from what its
 * burst can afford, NOT from how many events are waiting. Events beyond the
 * cap stay queued in order and arrive next block -- late, not lost. */
int juno_event_drain(juno_event *out, int max);

/* How many are waiting. For reporting and for a consumer that wants to know
 * whether it is behind. Never required to drain. */
int juno_event_depth(void);

/* ------------------------------------------------------------------ counts */
/* Rule 4: every refusal, every deferral, every queue that fills is COUNTED and
 * reported. A system that copes quietly cannot be proven to cope. */
typedef struct {
    unsigned long submitted;          /* accepted into the queue           */
    unsigned long refused;            /* queue was full -- THE fault count */
    unsigned long delivered;          /* handed to the engine by drain     */
    unsigned long depth_max;          /* high-water mark, ever             */
    unsigned long by_src[JUNO_SRC__N];/* submitted, per source             */
    unsigned long refused_by_src[JUNO_SRC__N];
} juno_event_stats;

void juno_event_get_stats(juno_event_stats *out);
void juno_event_reset(void);          /* clears the queue AND the counters */

/* ------------------------------------------------------------- the lock -- */
/* THE ONE PLATFORM HOOK. Producers may run on either core and in any task, so
 * the claim of a queue slot needs mutual exclusion between PRODUCERS.
 *
 * THE CONSUMER NEVER TAKES IT. That is the property that matters: drain runs
 * on the audio path, and the audio path takes no lock (rule 1). A producer
 * holding this while drain runs costs the audio nothing -- drain simply sees
 * the write index as it was and takes the rest next block.
 *
 * Define both before including, or accept the no-op default (correct for a
 * single-threaded host test, and NOT correct on the device). */
#ifndef JUNO_EVQ_LOCK
#define JUNO_EVQ_LOCK()   ((void)0)
#define JUNO_EVQ_UNLOCK() ((void)0)
#endif

/* Queue length. A power of two so the wrap is a mask. 64 events x 4 bytes =
 * 256 bytes, which at 44.1 kHz and a 256-sample block is over five blocks of
 * the fastest MIDI stream a DIN cable can carry (31,250 baud = ~1 note per
 * 0.96 ms = ~6 per block), so a burst that would have dropped notes now
 * arrives late instead. Override per port. */
#ifndef JUNO_EVQ_N
#define JUNO_EVQ_N 64
#endif

#ifdef __cplusplus
}
#endif
#endif /* JUNO_EVENT_H */
