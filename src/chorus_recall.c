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
    /* The EFFECT TYPE in force BEFORE this recall — a PORT-OWNED shadow of the
     * raw leaf, seeded to the power-on 2 by juno_engine_prepare and updated at
     * the END of juno_bank_apply (src/juno_engine.h JUNO_PREV_EFX). This
     * function NEVER writes it. */
    int prev_etype = JI(state, JUNO_PREV_EFX);
#ifdef JUNO_TOOTH_NO_PREV_EFX
    prev_etype = etype;   /* THE TOOTH: kill the shadow. Rebuild with
                           * -DJUNO_TOOTH_NO_PREV_EFX and
                           * tools/verify/warm_recall_gate.py --port --seq 39,40
                           * --cells 91232 MUST go RED again. If it stays green
                           * the gate is not testing the shadow. */
#endif

    /* ★ THE WET CELL IS GATED ON THE PREVIOUS TYPE AS WELL, AND ON {2,3,4} —
     * NOT {2,3,4,5}. The port's old gate was one value too wide and looked at
     * the NEW type only, so warm it OVERWROTE a value the plugin CARRIES.
     *
     * The plugin's law, measured under Unicorn on ONE engine with two recalls
     * (tools/verify/warm_recall_gate.py, factory bank, 44100):
     *     prev 2, new 5  (p0 -> p40)  plugin WRITES  WET[144] = 0x3eb1bcd3
     *     prev 5, new 5  (p39 -> p40) plugin CARRIES WET[255] = 0x3f95c28f
     *     prev 5, new 5  (p40 -> p41) plugin CARRIES WET[144] = 0x3eb1bcd3
     *     prev 2, new 1  (p1 -> p9)   plugin WRITES  WET[68]  = 0x3de1bb45
     *     prev 1, new 1  (p9 -> p9)   plugin CARRIES WET[68]  = 0x3de1bb45
     * i.e. the write happens iff the type in force BEFORE the recall is in
     * {2,3,4} OR the new type is. Type 5 routes slot 2 to block B (96336), so
     * a 5 -> 5 change never touches block A's Wet.
     *
     * WHY NO GATE EVER SAW IT: every gate in tools/verify/ recalled COLD (a
     * fresh plugin engine per patch), where prev is always the power-on 2 and
     * the left arm is always true. The EFFECT TYPE histogram of the SHIPPING
     * factory bank is {1:1, 2:33, 3:22, 5:8} — 9 patches sit outside {2,3,4}
     * (7,9,21,28,39,40,41,44,55). Simulating both laws over the bank:
     * 89 of the 4032 ORDERED factory pairs end with a different Wet, 81 of
     * them purely warm (the first recall already agrees), SIX of them
     * ADJACENT — 8->9, 10->9, 39->40, 40->39, 40->41, 41->40 — plus ONE
     * cold single patch, p9. (An earlier written claim of "42 of 4032" does
     * NOT reproduce; playbook 46.) The Noise gate below moves 281 ordered
     * pairs. PROVEN(executed), truth.verify() + a direct bank decode.
     *
     * The old `etype == 0` arm is SUBSUMED, not dropped: its evidence (the
     * chillwave state diff and the doctored-depth full recalls at 0/128/255)
     * was all COLD, i.e. prev == 2, where this gate writes exactly as that arm
     * did. Cold behaviour changes at ONE type only: type 1, which the old
     * gate skipped and this one writes (factory p9 — and p9 COLD was RED at
     * 91232 on the old tree, plugin 0x3de1bb45 vs port 0x00000000). Type 1
     * does not take the block-A chorus arm in src/master_render.c:2916, so no
     * render moves; the cell gates do, in the correct direction. */
    if ((prev_etype >= 2 && prev_etype <= 4) || (etype >= 2 && etype <= 4))
        JF(state, 91232) = cr_bits(CHORUS_WET_LUT[depth & 0xFF]);   /* Wet */

    if (etype >= 2 && etype <= 4) {                 /* block A (91120) — chorus modes 2/3/4 */
        JF(state, 91216) = 1.3f;                                    /* Dry (const) */
        JF(state, 91200) = cr_bits(CHORUS_NOISE_LUT[tone & 0xFF]);  /* Noise       */
        /* Noise is gated on the NEW type ALONE — not the Wet law above. Same
         * two-recall runs: prev 2, new 5 (p0 -> p7 and p0 -> p40) leaves the
         * plugin holding p0's NOISE[78] = 0x3ac8768b, so neither arm of an OR
         * fires here. Both rows were RED on the old tree. Dry is a constant
         * 1.3 and is also the prepare seed, so its gate is unobservable; it
         * stays with Noise because that is the arm the dispatch shares. */
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
#ifndef JUNO_TOOTH_NO_ET2_LFO
        /* ★ EFFECT TYPE 2 (chorus I) WRITES 91152 TOO, AND THE PORT DID NOT.
         *
         * PROVEN by isolated single-dispatch of the plugin's OWN EFFECT TYPE
         * setter (value-tree index 873) under Unicorn, fresh engine per trial,
         * two different base patches so "unchanged" cannot be confused with
         * "written the same value" (docs/engineb/data/devrecall/probes/
         * iso873.py, rates873.py):
         *
         *      873 <- 0, 1, 5   no write to 91152
         *      873 <- 2         91152 = f32(0.96f) / f32(H)
         *      873 <- 3         the chorus II arm above
         *      873 <- 4         the flanger arm below
         *
         * bit-exact at 44100/48000/88200/96000 (0x37b69bf1 / 0x37a7c5ac /
         * 0x37369bf1 / 0x3727c5ac) -- the SAME expression as juno_prepare.c:111.
         *
         * WHY NO GATE EVER SAW IT: from a fresh engine, 91152 already holds
         * 0.96/H, so the missing write is the identity and every COLD gate in
         * this repo passes. It only shows WARM: load an EFFECT TYPE 3 patch,
         * then an EFFECT TYPE 2 patch, and the chorus LFO stays at chorus II's
         * rate -- 3.7188209e-05 instead of 2.1768707e-05 at 44.1 kHz, 1.71x --
         * and src/master_render.c:2783 reads 91152 every sample. Ten factory
         * pairs are ET3 -> ET2 and nine of them render differently. This is a
         * plain patch change on the shipping engine, so it affects the DAW.
         *
         * Cold renders are BIT-IDENTICAL with and without this line (it is the
         * identity from a fresh engine), so the 57/57 seal is untouched.
         * MEASURED: tools/engineb/devrecall_gate.py's ET3->ET2 check, and its
         * tooth is -DJUNO_TOOTH_NO_ET2_LFO. */
        if (etype == 2) {
            float Hf = JF(state, 16); if (!(Hf > 0.0f)) Hf = 96000.0f;
            JF(state, 91152) = 0.96f / Hf;
        }
#endif
        /* EFFECT TYPE 4 (FLANGER) re-shapes block A's structural cells to the flanger
         * coefficients — the OLD "2/3/4 write bit-identical block A" reading was wrong
         * for mode 4. Four cells, DEPTH/TONE-independent (verified across base patches
         * 0/7/40), from the plugin's OWN EFFECT TYPE setter (idx 873) under Unicorn
         * (scratchpad/w3_flanger_struct.py): 91168=0 and 91184=0x399d4952 constant;
         * 91120/91152 rate-armed (4 distinct rate arms). No factory patch reaches
         * mode 4, so this has zero factory-render reach — it is recall-correctness for
         * any preset. NB: the flanger PARAMETER leaves (1242-1248 MANUAL/RESONANCE/…)
         * write NO engine cell via dispatch 0x3B9A30 (controller-path, engine dispatch
         * is a no-op) and remain GAP pending the #112 controller lifecycle. */
        if (etype == 4) {
            int Hr = (int)JF(state, 16); if (Hr <= 0) Hr = 96000;
            JF(state, 91120) = cr_bits(Hr == 44100 ? 0x3c0f87aeu : Hr == 48000 ? 0x3c1c6666u :
                                       Hr == 88200 ? 0x3c9087aeu : 0x3c9d6666u);
            JF(state, 91152) = cr_bits(Hr == 44100 ? 0x39dac024u : Hr == 48000 ? 0x39c8fa21u :
                                       Hr == 88200 ? 0x395ac024u : 0x3948fa21u);
            JF(state, 91168) = cr_bits(0x00000000u);
            JF(state, 91184) = cr_bits(0x399d4952u);
        }
    }
    /* EFFECT TYPE mode 5 drives block B (96336..) — structural + On/Off + LFO
     * Rate + enable gates — via src/effect_modes.c (juno_apply_effect_modes).
     * It does NOT write block A's Dry/Noise: the old "block A is written for
     * mode 5 too" reading was a COLD artefact and is corrected above. Mode 5
     * touches block A's Wet only through the previous-type arm. */
}
