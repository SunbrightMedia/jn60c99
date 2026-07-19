/* chorus_recall.c — per-patch JUNO-60 chorus level recall, bit-exact from the
 * binary's own value-tree dispatch (sub_7FF91E019A30).
 *
 * The JUNO-60 chorus is the master's slot-2 (v551 = EFFECT TYPE) effect. Three
 * front-panel bytes drive it per patch:
 *   EFFECT DEPTH (blob 50) -> Wet level      (CHORUS_WET_LUT)
 *   EFFECT TONE  (rec 642) -> Noise level    (CHORUS_NOISE_LUT)
 *   EFFECT TYPE  (rec 634) -> mode / routing (2/3/4 -> block 91120; 5 -> 96336)
 * The Dry level is a constant 1.3. The 256-entry LUTs are the exact byte->float
 * bit-patterns the dispatch produces; they reproduce the independent runtime
 * baseline bit-for-bit (EFFECT DEPTH=255 -> Wet 0x3f95c28f, TONE=55 -> Noise
 * 0x3a8d5a27). Derivation + verification: docs/CHORUS_RECALL.md and
 * scratchpad/oracle/fx_recall_findings.md.
 *
 * The block's STRUCTURAL constants (LFO rate/phase/depth, BBD delay time) are
 * mode-selected PREPARE outputs, supplied by juno_engine_prepare. EFFECT TYPE 2, 3
 * and 4 write BIT-IDENTICAL block A (91120) — proven three independent ways in
 * scratchpad/oracle/chorus_structural_findings.md: the master-read cells are the
 * same for all three, so these level writes are bit-exact for Chorus I / II / I+II
 * (the I/II/I+II distinction is NOT carried in the master-read block-A cells). Mode 5
 * (block B, 96336) and mode 1 (distortion+pan) are handled fully by effect_modes.c;
 * the driver routes slot-2 to the recalled EFFECT TYPE (juno_apply_effect_modes
 * writes JUNO_PROG_EFX), so mode-5 patches read block B, not block A.
 */
#include "juno_engine.h"
#include "chorus_recall.h"
#include <stdint.h>
#include <string.h>

#include "chorus_luts.h"   /* CHORUS_WET_LUT / CHORUS_NOISE_LUT / CHORUS5_LFORATE_LUT */

/* front-panel blob value at blob position `bp` (blob = record + 16). */
static int cr_blob_val(const unsigned char *rec, int bp)
{
    const unsigned char *b = rec + 16;
    return ((b[2 * bp] & 0xF) << 4) | (b[2 * bp + 1] & 0xF);
}
/* logical byte from a nibble pair at record offset `off`. */
static int cr_rec_byte(const unsigned char *rec, int off)
{
    return ((rec[off] & 0xF) << 4) | (rec[off + 1] & 0xF);
}
static float cr_bits(uint32_t u) { float f; memcpy(&f, &u, sizeof f); return f; }

void juno_apply_chorus(unsigned char *state, const unsigned char *rec)
{
    int depth = cr_blob_val(rec, 50);    /* EFFECT DEPTH 0..255 */
    int tone  = cr_rec_byte(rec, 642);   /* EFFECT TONE  0..255 */
    int etype = cr_rec_byte(rec, 634);   /* EFFECT TYPE  0..5   */

    if (etype == 0) {
        /* EFFECT TYPE 0 (the slot-2 Pan arm): the plugin's post-recall state
         * carries block-A Wet = CHORUS_WET_LUT[depth] here too, and ONLY Wet —
         * Dry/Noise stay at their prepare values (PROVEN: chillwave state diff +
         * doctored-depth full recalls at 0/128/255, bit-equal; the type-0 render
         * branch does not read block A, so this is state-faithfulness). */
        JF(state, 91232) = cr_bits(CHORUS_WET_LUT[depth & 0xFF]);
    }
    if (etype >= 2 && etype <= 5) {                 /* block A (91120) — chorus modes 2/3/4/5 */
        JF(state, 91216) = 1.3f;                                    /* Dry (const) */
        JF(state, 91232) = cr_bits(CHORUS_WET_LUT[depth & 0xFF]);   /* Wet         */
        JF(state, 91200) = cr_bits(CHORUS_NOISE_LUT[tone & 0xFF]);  /* Noise       */
        /* Mode 3 (chorus II) runs block A's LFO at a DIFFERENT rate than modes 2/4/5
         * (which use the prepare default 91152=1.92e-05). The plugin holds mode 3 at
         * a RATE-DEPENDENT value (continuous C/H family — the 44.1k/88.2k bits are
         * exact x2 pairs of each other). Arms measured bit-for-bit from the plugin's
         * own build+recall at 44100/48000/88200/96000 (scratchpad/oracle/
         * rate_fullscan.py + the 88.2 probe); the old single 48k capture was one
         * seed of the 44.1 kHz cold-render drift. */
        if (etype == 3) {
            int Hr = (int)JF(state, 16); if (Hr <= 0) Hr = 96000;
            unsigned int b = (Hr == 44100) ? 0x381bfa89u : (Hr == 48000) ? 0x380f4e2eu
                           : (Hr == 88200) ? 0x379bfa89u : 0x378f4e2eu;
            float f; memcpy(&f, &b, 4);
            JF(state, 91152) = f;
        }
    }
    /* EFFECT TYPE mode 5 also drives block B (96336..) — structural + On/Off + LFO
     * Rate + enable gates — via src/effect_modes.c (juno_apply_effect_modes). Block A
     * above (levels) is written for mode 5 too (the plugin recalls both). */
}
