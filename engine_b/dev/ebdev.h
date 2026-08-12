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

/* === THE SCATTER ROW COUNT IS THE PORT'S VOICE COUNT, NOT THE FORK'S =======
 *
 * This was wrong until 2026-08-12 and it was the third fatal finding of the
 * adversarial round. EBDEV_NV read as "voices this build plays", so the fork's
 * six were the obvious value -- and at -DEBDEV_NV=6 the array MISSES, MEASURED,
 * on 22 distinct offsets, among them cell 320, the ADSR gate. Defect 2, back.
 *
 * The reason is structural, not a tuning choice. `ebdev_scatter_slow` derives
 * the row from the PORT offset (`(off - VLO) / VSTRIDE`), so a row index IS a
 * port voice number; and the port's recall writes every port voice
 * unconditionally -- src/juno_apply.c:478 (CONDITION), :500 (UNISON), :814
 * (LFO tempo) all loop `v < 8` and none of them can know what the fork plays.
 * Give the array fewer rows than the port has voices and those writes sink.
 *
 * So the row count is EBDEV_NVPORT, generated from the block geometry in
 * ebdev_seg.h. It costs 96 bytes over a six-row array. In exchange the SAME
 * image is addressable by a board that owns ANY subset of the port's voices,
 * which is what END_GOAL item 2 (two boards, six voices) will need: a chip
 * playing global voices 4 and 5 can reach rows 4 and 5.
 *
 * EB_NUM_VOICES -- how many voices the DSP renders -- is a different number and
 * stays free. It is bounded below the row count here, so a fork that raises it
 * past the array cannot build. */
#ifndef EBDEV_NV
#define EBDEV_NV EBDEV_NVPORT
#endif
#if EBDEV_NV < EBDEV_NVPORT && !defined(EBDEV_TOOTH_SHORT_ROWS)
#error "EBDEV_NV is below the port's voice count: recall writes voices this \
array cannot hold and they sink silently. See the comment above. \
-DEBDEV_TOOTH_SHORT_ROWS builds it anyway, for the gate's tooth."
#endif
#if defined(EB_NUM_VOICES) && (EB_NUM_VOICES > EBDEV_NV)
#error "EB_NUM_VOICES exceeds the scatter row count: the DSP would read voices \
the cell array does not carry."
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

/* ONE cell of scat[0] -> scat[1..NV-1]. `voff` is a VOICE-BLOCK-RELATIVE port
 * offset; if it is not a scatter cell this does nothing, and that is the whole
 * point.
 *
 * THIS IS THE LIVE PANEL EDIT, and it is the second fatal finding of the
 * 2026-08-12 adversarial round. The port's live edit (gui/juno_bridge.c, now
 * juno_apply_param_leaf) writes voice 0's cell and then replicates the
 * IDENTICAL value to voices 1..7 by hand. Replayed literally on the device
 * that is 42 writes to per-voice offsets the map does not carry -- MEASURED,
 * 6 offsets x 7 voices, and eb_recall.c:63's rule mutes the instrument on a
 * non-zero unmapped count. So a knob turn muted it.
 *
 * The fix is not a wider map, it is that the replication is REDUNDANT here:
 * the tile is shared, so writing voice 0 already served every voice. The only
 * per-voice offsets that need anything are the twelve in the scatter, and for
 * those the identical value must reach every row. Hence: broadcast exactly the
 * cell that moved, nothing else.
 *
 * It is deliberately NOT a blanket drop of per-voice writes. A caller that
 * writes DIFFERENT values to different voices at a non-scatter offset is
 * defect 2 all over again, and it must still MISS and still be counted --
 * which it does, because this function never touches the map. */
void  ebdev_broadcast_cell(unsigned long voff);

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
/* THE MISS LIST IS PURE DIAGNOSTIC, and at 8,192 entries it is 32,768 BYTES
 * OF INTERNAL SRAM. MEASURED: with it at that size, linking recall into the
 * shipping firmware fails with `region dram0_0_seg overflowed by 7184 bytes`
 * -- i.e. this array alone is the deficit, five times over. It names the
 * distinct unmapped offsets and nobody has ever read past the first dozen. */
#ifndef EBDEV_MISSLIST_N
#define EBDEV_MISSLIST_N 8192
#endif
extern unsigned long EBDEV_MISSLIST[EBDEV_MISSLIST_N];
extern int           EBDEV_NMISS;

#endif /* EBDEV_H */
