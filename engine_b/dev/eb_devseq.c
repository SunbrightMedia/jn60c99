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
#include <string.h>

/* JF/JI ignore their first argument under EB_DEVCELLS, and so do all the port
 * entry points below. Passing a null keeps that visible: if any of them ever
 * dereferences the pointer instead of going through ebdev_at(), the device
 * faults at address 0 with EXCVADDR 0 rather than reading a plausible-looking
 * byte from somewhere else. A crash that names the defect is worth more than a
 * wrong sample. */
#define DEVST  ((unsigned char *)0)

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
