/* eb_devseq.c -- see eb_devseq.h. EB_DEVCELLS only, on purpose. */
#ifndef EB_DEVCELLS
#error "eb_devseq.c is the DEVICE recall sequence and must be built with -DEB_DEVCELLS. A flat-array build of it would be a second addressing mode nobody gates."
#endif

#include "eb_devseq.h"
#include "ebdev.h"
#include "juno_engine.h"
#include "juno_apply.h"
#include "juno_driver.h"
#include "juno_note.h"
#include "eb_patch.h"
#include "eb_alloc.h"
#include <string.h>

/* JF/JI ignore their first argument under EB_DEVCELLS, and so do all the port
 * entry points below. Passing a null keeps that visible: if any of them ever
 * dereferences the pointer instead of going through ebdev_at(), the device
 * faults at address 0 with EXCVADDR 0 rather than reading a plausible-looking
 * byte from somewhere else. A crash that names the defect is worth more than a
 * wrong sample. */
#define DEVST  ((unsigned char *)0)

float EB_DEVSEQ_PORTA_BASE = 0.0f;

int eb_devseq_boot_cells(const unsigned char *img, unsigned nv)
{
    if (!img) return 1;
    if (nv != (unsigned)EBDEV_NV) return 2;
    memset(&EBDEV_S, 0, sizeof EBDEV_S);
    memcpy(EBDEV_S.v0, img, EBDEV_VTILE);
    memcpy(EBDEV_S.sg, img + EBDEV_VTILE, EBDEV_SEGBYTES);
    memcpy(EBDEV_S.scat, img + EBDEV_VTILE + EBDEV_SEGBYTES,
           sizeof EBDEV_S.scat);
    return 0;
}

int eb_devseq_install(unsigned char *bank, const unsigned char *tpl,
                      size_t tpl_bytes, const uint8_t *patch_bytes)
{
    if (!bank || !tpl || !patch_bytes) return 1;
    if (tpl_bytes > 20223u) return 2;
    memset(bank, 0, EB_DEVSEQ_BANK_BYTES);
    memcpy(bank + 23u, tpl, tpl_bytes);
    return eb_patch_install(bank + 23u, (const eb_patch *)patch_bytes);
}

void eb_devseq_recall(unsigned char *bank, float bpm)
{
    juno_bank_apply(DEVST, bank, 0);
    /* On the device this IS ebdev_broadcast_scatter(): the voice blocks are
     * not contiguous, so there is nothing for the port's memcpy to copy. The
     * rewrite is inside juno_driver_seed_voices under EB_DEVCELLS so a caller
     * cannot get a silent no-op. */
    juno_driver_seed_voices(DEVST);
    juno_apply_unison_spread(DEVST, juno_bank_assign(bank, 0));
    juno_apply_condition(DEVST, juno_bank_condition(bank, 0));
    juno_apply_lfo_tempo(DEVST, juno_bank_lfo_rate_byte(bank, 0), bpm);
    /* THE RECALL-TIME STASH, and it is one field because that is all the note
     * path needs. gui/juno_bridge.c:361 keeps cell 592 (PORTAMENTO on/off) at
     * recall because juno_note_porta_gate's fourth argument is the value the
     * per-voice gate RESTORES -- it cannot be read back later, since the gate
     * itself overwrites it. Without this the device restores 0 and portamento
     * dies silently on every voice that ever released.
     *
     * The bridge keeps six more (lfo_rate_byte, dly_time/sync/type, hpf_type,
     * last_condition) for the LIVE EDIT path. Those are C6's and are NOT here;
     * naming them is how they stay owed rather than forgotten. */
    EB_DEVSEQ_PORTA_BASE = JF(DEVST, 592);
}

void eb_devseq_notes_on(const int *voice, const int *midi, const int *vel, int n)
{
    int i;
    for (i = 0; i < n; ++i)
        juno_note_on(DEVST, voice[i], midi[i], vel[i]);
    /* THE "ANY KEY HELD" BROADCAST, cell 1856, to ALL voices. The port's note
     * events broadcast it (CLAUDE.md, the arp render fix); setting it on the
     * allocated voice only made an idle voice's free-run state diverge, and
     * the at-rest voices are 29 % of this instrument's signal. */
    juno_note_broadcast_held(DEVST, n > 0);
}

void eb_devseq_notes_off(const int *voice, int n)
{
    int i;
    for (i = 0; i < n; ++i)
        juno_note_off(DEVST, voice[i]);
    juno_note_broadcast_held(DEVST, 0);
}

uint32_t eb_devseq_crc32(const void *p, size_t n)
{
    const unsigned char *q = (const unsigned char *)p;
    uint32_t c = 0xFFFFFFFFu;
    size_t i;
    int k;
    for (i = 0; i < n; ++i) {
        c ^= q[i];
        for (k = 0; k < 8; ++k)
            c = (c >> 1) ^ (0xEDB88320u & (uint32_t)(-(int32_t)(c & 1u)));
    }
    return c ^ 0xFFFFFFFFu;
}

/* ---- C4: THE ALLOCATOR SEAM ---------------------------------------------- */

unsigned EB_DEVSEQ_TOUCHED = 0u;
unsigned EB_DEVSEQ_VOICED  = 0u;

int eb_devseq_events(const eb_alloc_ev *ev, int n)
{
    int i;
    if (!ev) return -1;
    EB_DEVSEQ_TOUCHED = 0u;
    EB_DEVSEQ_VOICED  = 0u;
    for (i = 0; i < n; ++i) {
        /* THE VOICE MASK, built HERE and not inferred by the caller. A caller
         * that under-states it gets seven stale voices and no error -- see
         * eb_recall_build_voices. Every arm below writes the voice it names;
         * the one that does NOT is EB_EV_HELD, which is the port's own
         * engine-wide broadcast of cell 1856. Its contribution is decided in
         * its own case below, BEFORE it writes, for the reason stated there.
         * Getting that single case wrong is the whole risk. */
        EB_DEVSEQ_TOUCHED |= (ev[i].kind == EB_EV_HELD)
                             ? 0u : (1u << ev[i].voice);
        /* THE PRIORITY SET, built from the SAME expression so it cannot drift
         * from TOUCHED. EB_EV_HELD names no voice; every other kind names the
         * one the player is waiting to hear. See the header for why this is a
         * publish ORDER and never a mask to build alone. */
        EB_DEVSEQ_VOICED |= (ev[i].kind == EB_EV_HELD)
                             ? 0u : (1u << ev[i].voice);
        switch (ev[i].kind) {
        case EB_EV_TRIGGER:
            juno_note_on(DEVST, ev[i].voice, ev[i].a, ev[i].b);
            break;
        case EB_EV_GLIDE:
            juno_note_glide(DEVST, ev[i].voice, ev[i].a);
            break;
        case EB_EV_VELOCITY:
            juno_note_velocity(DEVST, ev[i].voice, ev[i].b);
            break;
        case EB_EV_NOTE_OFF:
            juno_note_off(DEVST, ev[i].voice);
            break;
        case EB_EV_RETRIG:
            juno_note_retrig(DEVST, ev[i].voice);
            break;
        case EB_EV_PORTA_GATE:
            juno_note_porta_gate(DEVST, ev[i].voice, ev[i].a,
                                 EB_DEVSEQ_PORTA_BASE);
            break;
        case EB_EV_HELD:
            /* ⚑ WIDEN TO ALL EIGHT VOICES ONLY WHEN THE BROADCAST ACTUALLY
             * MOVES A COEFFICIENT. MEASURED consequence of not doing so
             * (b9_held_broadcast.md): eb_alloc emits this on EVERY note-on
             * and EVERY note-off, so an unconditional ~0u made every single
             * note rebuild all eight voices -- the full 1.12 M-cycle voice
             * build, 7.9x the ~135,000 the plan assumed, and the largest
             * single-block cost in the firmware.
             *
             * WHAT THE BROADCAST MEANS, from the port's own semantics
             * (src/juno_note.c:204-211, measured under Unicorn): cell 1856 is
             * (held-note count > 0). Note-on writes 1.0 to every voice -- but
             * if a key was already held it was ALREADY 1.0. Note-off writes
             * 0.0 only when no key remains. So it transitions on the FIRST key
             * down and the LAST key up, and on nothing else. In between, the
             * other seven voices' cells are untouched and rebuilding them
             * recomputes identical values.
             *
             * ⚠ IT READS THE CELL RATHER THAN REMEMBERING THE STATE, and that
             * is the whole design. A remembered flag goes STALE the moment a
             * patch reseed rewrites 1856 -- it would then skip a widen that
             * was needed, leaving seven voices carrying a wrong k1856 into the
             * LFO: audible, and invisible to any test that only plays chords.
             * The cell is self-synchronising: after a reseed it holds whatever
             * the reseed put there, so the comparison is right by
             * construction and there is no resync to forget.
             *
             * Voice 0's copy is enough: broadcast_held writes all voices
             * identically, and VBASE(0) is 0, so the cell is at offset 1856.
             *
             * Held bit-identical to the unconditional widen by
             * tools/engineb/held_gate.py over a note sequence, with teeth. */
            /* ⚠ DEFAULT OFF, AND THE GATE IS WHY. tools/engineb/held_gate.py
             * runs a note sequence on patches 0, 5 and 21 and compares the
             * live coefficients against a full rebuild from the current cells.
             * With the narrowing ON, PATCH 5 FAILS: 14 bytes differ, and a
             * WIDE build from the same starting point MATCHES the full
             * rebuild. So the narrowing drops a voice whose coefficients
             * really did change -- the reasoning in b9_held_broadcast.md §3 is
             * necessary but NOT sufficient, and cell 1856 is not the only
             * thing a note moves that reaches another voice.
             *
             * Patches 0 and 21 pass, which is exactly why this is behind a
             * flag rather than deleted: the idea is worth 7.9x and the gate
             * now says precisely what would have to be true for it to be safe.
             * Patch 5 is MONO and emits a different event set (glide, retrig,
             * porta gate) than the POLY patches -- that is where to look next.
             *
             * DO NOT ENABLE THIS WITHOUT held_gate.py GREEN. */
#ifdef EB_DEVSEQ_NARROW_HELD
            {   const float want = ev[i].a ? 1.0f : 0.0f;
                if (JF(DEVST, 1856u) != want) EB_DEVSEQ_TOUCHED = ~0u;
            }
#else
            EB_DEVSEQ_TOUCHED = ~0u;   /* the safe, measured-correct behaviour */
#endif
            juno_note_broadcast_held(DEVST, ev[i].a);
            break;
        default:
            /* An unknown event is a note the instrument did not play. Refuse
             * rather than skip -- see the header. */
            return -1;
        }
    }
    return n;
}

void eb_devseq_alloc_config(eb_alloc *a, const unsigned char *bank)
{
    int mode;
    if (!a || !bank) return;
    /* juno_bank_assign returns the ASSIGN MODE nibble: 0 POLY, 1 MONO,
     * 2 UNISON. eb_alloc carries LEGATO and PORTAMENTO separately; the bank
     * reader for those is not exposed, so they stay at their init defaults
     * here and are OWED. Stated rather than silently defaulted, because
     * "the allocator sat in POLY for every patch" is this project's most
     * expensive single defect (docs/ASSIGNER_MODE_FINDING.md): the port AND
     * the oracle were wrong together, so every render A/B compared two copies
     * of the same mistake. */
    mode = juno_bank_assign(bank, 0);
    a->assign_mode = (mode < 0 || mode > 3) ? 0 : mode;
}
