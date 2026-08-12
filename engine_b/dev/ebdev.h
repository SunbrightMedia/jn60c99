/* ebdev.h -- THE DEVICE CELL ARRAY.
 *
 * The port addresses its engine state as ONE flat 11,022,352-byte array and
 * reaches into it with `JF(state, off)` / `JI(state, off)`. Recall touches
 * about 900 distinct cells in that array. The device carries those cells and
 * nothing else:
 *
 *      v0[]    ONE voice block at NATIVE offsets, [0, EBDEV_VTILE)
 *      sg[]    the non-voice cells, packed into EBDEV_NSEG dense segments
 *      scat[]  the cells that are genuinely PER VOICE, one row per voice
 *
 * `ebdev_at(off)` is the whole interface. A device build defines JF/JI (and
 * eb_coefs.c's CF, and the raw pointer casts named in DESIGN_full.md 1.5) to
 * go through it.
 *
 * IT IS `static inline` ON PURPOSE, and that is load-bearing. At a
 * compile-time-constant `off` -- which almost every recall site is -- the
 * literal chain in ebdev_map.h folds to ONE load: MEASURED on
 * xtensa-esp-elf-gcc -O2 as `entry / l32r / l32i / retw.n`, four instructions,
 * the same code a flat 11 MB array gives. Out of line it does not fold at all;
 * as a loop over EBDEV_SEGTAB it costs 27 instructions and 14.2 probes.
 *
 * === THE PER-VOICE RULE, and it is defect 2 of DEVICE_RECALL.md ===
 *
 * The FIRST design carried five per-voice cells. It could not sound a chord.
 * The note path (src/juno_note.c) writes SEVEN more, six of which the
 * coefficient builder reads back per voice, and one of which -- cell 320, the
 * ADSR gate -- engine B reads EVERY SAMPLE (engine_b/eb_render.c:484-488).
 * With a shared tile, voices 1..N-1 are not addressable at those offsets at
 * all: the write lands in a sink and the read returns voice 0's value.
 *
 * The scatter is now TWELVE cells. `ebdev_at` routes them for every voice,
 * INCLUDING voice 0 -- voice 0's copies live in `scat[0]`, never in the tile.
 * They must, because `ebdev_voice_select(v)` pokes voice v's values INTO the
 * tile before the builder reads voice v, so anything left in the tile at a
 * scatter offset is transient. (That was the fourth tooth of the 2026-08-11
 * gate, and it was a defect the gate FOUND, not one anybody planted.)
 *
 * The aux DCO-retrigger latch at 101504+32v is deliberately NOT in the
 * scatter: all eight voices' copies already live inside a non-voice segment.
 */
#ifndef EBDEV_H
#define EBDEV_H

#include <stdint.h>
#include <stddef.h>
#include "ebdev_seg.h"
#include "ebdev_map.h"

/* Voices this build carries. 6 is the fork; 8 is the trunk and the host gate. */
#ifndef EBDEV_NV
#define EBDEV_NV 8
#endif

typedef struct {
    unsigned char v0[EBDEV_VTILE];        /* one voice block, native offsets   */
    unsigned char sg[EBDEV_SEGBYTES];     /* the non-voice segments, dense     */
    float         scat[EBDEV_NV][EBDEV_NSCAT];
    unsigned long miss;                   /* offsets the map could not place   */
    unsigned long lastmiss;
} ebdev_state;

/* ONE static instance, named so the chain folds against a link-time constant
 * address. Through a pointer it would not fold. */
extern ebdev_state EBDEV_S;
extern ebdev_state *const EBDEV;          /* the same object, for harnesses */

/* voices 1..NV-1, and the miss path. Out of line: they are the cold paths and
 * inlining them would bloat every call site for nothing. Never NULL -- a
 * recall site dereferences the result unconditionally, and a counter tells you
 * more than a crash. */
void *ebdev_scatter_slow(unsigned long off);
void *ebdev_miss(unsigned long off);

#ifdef EBDEV_INSTRUMENT
/* The instrumented build replaces the inline chain with an out-of-line form
 * that ALSO looks the offset up in EBDEV_SEGTAB and compares. It counts
 * segment coverage and it is how the gate reports which segments are cold.
 * It is never shipped -- the fold is the point of the other form. */
void *ebdev_at(unsigned long off);
#else
static inline void *ebdev_at(unsigned long off)
{
    if (off < EBDEV_VTILE) {
        /* per-voice cells first: voice 0's copies live in scat[0], NOT in the
         * shared tile. ebdev_voice_select() overwrites the tile's copy with
         * voice v's value, so a value left in the tile is transient.
         * EBDEV_TOOTH_SCAT0_IN_TILE is the 2026-08-11 gate's fourth tooth,
         * kept as a compile flag so it can still be fired. */
#ifndef EBDEV_TOOTH_SCAT0_IN_TILE
        EBDEV_SCAT0_BODY
      tile:
#endif
        return EBDEV_S.v0 + off;
    }
    if (off < EBDEV_VHI) return ebdev_scatter_slow(off);
    EBDEV_MAP_BODY
  miss:
    return ebdev_miss(off);
}
#endif

/* The TABLE form. Slow, obvious, never shipped -- it exists so the gate can
 * prove the generated chain agrees with the generated table at EVERY offset.
 * A generator that emits a chain disagreeing with its own table is exactly the
 * failure a hand-read header hides. */
void *ebdev_at_ref(unsigned long off);

/* Voice v's copy of a per-voice cell. `off` is voice-block-relative. */
void *ebdev_at_v(int v, unsigned long off);

/* Poke voice v's scatter values into the shared tile. Call before reading
 * voice v's cells through the tile (that is what eb_coefs.c's VBASE does). */
void  ebdev_voice_select(int v);

/* scat[0] -> scat[1..NV-1]. This is the device's juno_driver_seed_voices:
 * on the host, recall writes voice 0 and a memcpy replicates the block; here
 * the block is not contiguous, so the scatter must be broadcast explicitly.
 * Omitting it was measured to fail 24 of 192 cases, first at glide[1].k592. */
void  ebdev_broadcast_scatter(void);

/* Exhaustive chain-vs-table equivalence over every offset the map can name.
 * Returns the number of disagreements; 0 is the only acceptable answer. */
long  ebdev_selftest(void);

void  ebdev_reset_counters(void);

extern unsigned long EBDEV_SEGHIT[EBDEV_NSEG];
extern unsigned long EBDEV_VHIT, EBDEV_SHIT, EBDEV_GHIT;
extern unsigned long EBDEV_MISSLIST[8192];
extern int           EBDEV_NMISS;

#endif /* EBDEV_H */
