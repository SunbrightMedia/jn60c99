/* juno_event.c -- the bounded queue behind juno_event.h.
 *
 * Portable C99. No ESP-IDF, no engine header, no JUNO constant. The host test
 * and the firmware compile THIS FILE, which is the point: a boundary proven on
 * a workstation and a different boundary shipped is two boundaries.
 *
 * ---------------------------------------------------------------------------
 * THE SHAPE: a fixed ring, many producers, ONE consumer.
 *
 *   producers (keybed, panel, DIN, USB, console, link)  -> juno_event_*()
 *   consumer  (the audio block boundary, core 0)        -> juno_event_drain()
 *
 * Producers take JUNO_EVQ_LOCK to claim a slot. THE CONSUMER TAKES NOTHING.
 * That asymmetry is the whole design: rule 1 forbids a lock on the audio path,
 * and drain runs on the audio path.
 *
 * WHY THAT IS SAFE WITHOUT ATOMICS ON THE CONSUMER SIDE. `wr` is written only
 * inside the producer lock and read (unlocked) by the consumer; `rd` is
 * written only by the consumer and read by producers inside the lock. Both are
 * single machine words and `volatile`, so each read sees either the old value
 * or the new one, never a torn one. A consumer that reads a stale `wr` drains
 * fewer events this block and the rest next block -- LATE, NOT LOST, which is
 * the policy this file exists to implement. A producer that reads a stale `rd`
 * believes the queue is fuller than it is and may refuse one event early;
 * that is counted, and erring toward refusing is the safe direction.
 *
 * ⚠ WHAT WOULD BREAK IT: a second consumer. `rd` has exactly one writer by
 * construction and there is no lock protecting it. If a second drainer is ever
 * added, this file needs an atomic, not a comment.
 */
#include "juno_event.h"
#include <string.h>

#define QMASK (JUNO_EVQ_N - 1)
#if (JUNO_EVQ_N & QMASK) != 0
#error "JUNO_EVQ_N must be a power of two: the wrap is a mask, not a modulo."
#endif

static juno_event    Q[JUNO_EVQ_N];
static volatile unsigned QWR = 0;    /* producers write, under the lock */
static volatile unsigned QRD = 0;    /* the consumer writes, alone      */

static juno_event_stats ST;

/* THE ONE SUBMIT PATH. All three public calls funnel here, so there is exactly
 * one place that decides what "full" means and exactly one place that counts.
 * Two entry points deciding separately is how the assigner-mode defect
 * survived for months (docs/ASSIGNER_MODE_FINDING.md). */
static int ev_submit(juno_ev_kind kind, juno_src src, int a, int b)
{
    unsigned wr, rd;
    int ok = 0;

    if ((unsigned)src >= (unsigned)JUNO_SRC__N) src = JUNO_SRC_NONE;

    JUNO_EVQ_LOCK();
    wr = QWR;
    rd = QRD;
    /* FULL means one slot short of wrapping onto the reader. Sacrificing a
     * slot is what keeps wr == rd unambiguously EMPTY, so the consumer needs
     * no third variable and therefore no atomic. */
    if ((unsigned)(wr - rd) < (unsigned)QMASK) {
        Q[wr & QMASK].kind = (unsigned char)kind;
        Q[wr & QMASK].src  = (unsigned char)src;
        Q[wr & QMASK].a    = (unsigned char)(a & 0xFF);
        Q[wr & QMASK].b    = (unsigned char)(b & 0xFF);
        QWR = wr + 1u;
        ++ST.submitted;
        ++ST.by_src[src];
        {   unsigned d = (unsigned)(QWR - rd);
            if ((unsigned long)d > ST.depth_max) ST.depth_max = d; }
        ok = 1;
    } else {
        ++ST.refused;
        ++ST.refused_by_src[src];
    }
    JUNO_EVQ_UNLOCK();
    return ok;
}

int juno_event_note_on(juno_src src, int note, int velocity)
{
    /* RANGE IS CLAMPED, NOT TRUSTED. This is a boundary; the thing on the far
     * side of it may be a panel board nobody here has read. An out-of-range
     * note that reaches the allocator is an array index. */
    if (note < 0)       note = 0;
    if (note > 127)     note = 127;
    if (velocity < 0)   velocity = 0;
    if (velocity > 127) velocity = 127;
    /* A NOTE-ON WITH VELOCITY 0 IS A NOTE-OFF. That rule belongs here, at the
     * one boundary, and not in each parser: it is how most keyboards release,
     * and a second parser that forgot it would disagree with the first. */
    if (velocity == 0) return ev_submit(JUNO_EV_NOTE_OFF, src, note, 64);
    return ev_submit(JUNO_EV_NOTE_ON, src, note, velocity);
}

int juno_event_note_off(juno_src src, int note)
{
    if (note < 0)   note = 0;
    if (note > 127) note = 127;
    return ev_submit(JUNO_EV_NOTE_OFF, src, note, 64);
}

int juno_event_param(juno_src src, int param_id, int value_0_255)
{
    /* param_id is an INDEX INTO A PER-SYNTH TABLE. This file does not know how
     * long that table is and must not pretend to: the consumer validates it
     * against the table it owns. Only the byte width is enforced here, because
     * the queue slot is a byte.
     *
     * ⚠ 8 bits of id is 256 parameters. The JUNO's panel is far short of that
     * and the JX-3P's is too; if a future synth needs more, widen `a` and `b`
     * together -- do NOT steal bits from the value, which is 0..255 precisely
     * so that a CC's 7 bits cannot silently become the ceiling (that is the
     * defect C11 was written to prevent). */
    if (param_id < 0)      param_id = 0;
    if (param_id > 255)    param_id = 255;
    if (value_0_255 < 0)   value_0_255 = 0;
    if (value_0_255 > 255) value_0_255 = 255;
    return ev_submit(JUNO_EV_PARAM, src, param_id, value_0_255);
}

int juno_event_drain(juno_event *out, int max)
{
    unsigned wr, rd;
    int n = 0;
    if (!out || max <= 0) return 0;
    wr = QWR;                     /* ONE unlocked read; see the header note */
    rd = QRD;
    while (n < max && rd != wr) {
        out[n++] = Q[rd & QMASK];
        ++rd;
    }
    QRD = rd;                     /* single writer, no lock, by construction */
    ST.delivered += (unsigned long)n;
    return n;
}

int juno_event_depth(void)
{
    return (int)(unsigned)(QWR - QRD);
}

void juno_event_get_stats(juno_event_stats *out)
{
    if (out) *out = ST;
}

void juno_event_reset(void)
{
    JUNO_EVQ_LOCK();
    QWR = 0;
    QRD = 0;
    memset(&ST, 0, sizeof ST);
    JUNO_EVQ_UNLOCK();
}
