/* effect_modes.c — EFFECT TYPE mode-1 (Distortion+Pan) and mode-5 (Chorus/Ensemble)
 * per-patch recall, bit-exact from the binary. See effect_modes.h / docs/EFFECT_MODES.md
 * and scratchpad/oracle/effect_modes_1_5_findings.md for the full derivation.
 *
 * Identity (RTTI, from the plugin's mode selector sub_7FF91E018180):
 *   mode 1 = sCDSPSystem8::DlyPan  — cubic hard-clip waveshaper + stereo panner
 *            (engine block 86288..87152; the panner position is EFFECT TONE).
 *   mode 5 = sCDSPSystem8::DlyMfx1 — a second BBD chorus/ensemble, different class &
 *            coefficients than the mode-2/3/4 chorus (engine block 96336..96912).
 *
 * The structural cells (MODE1_STRUCT / MODE5_STRUCT, effect_luts.h) are the plugin's
 * own BUILD -> snap-all -> setSampleRate output dumped under emulation @96 kHz. The
 * per-patch cells are recalled from the value-tree dispatch LUTs. Three multiplicative
 * enable-gates are not written by the value tree (the non-default sub-effects are
 * constructed but never enabled, so their smoother targets stay 0). Their enabled
 * values:
 *   96384 Ip Fc = 0x37ffd974, 96416 Mute = 1.0 (mode 5) — now DIRECTLY OBSERVED from
 *     the binary's own code (static disasm of the setter + the master-read storage
 *     cells under emulation): PROVEN, scratchpad/oracle/mode5_gates_spec.md.
 *   86320 DS Mute = 1.0 (mode 1) — derived: the multiplicative "Mute" gate's enabled
 *     value, matching the block-A chorus twin 91280 = 1.0 and the prepare constant
 *     84560 "Mute SW" = 1.0 (juno_prepare.c); strongly supported but not driven under
 *     emulation (the mode-1 sub-effect is never enabled in the traced path).
 */
#include "juno_engine.h"
#include "effect_modes.h"
#include "chorus_luts.h"     /* CHORUS5_LFORATE_LUT (mode-5 LFO Rate) */
#include "effect_luts.h"
#include <stdint.h>
#include <string.h>
#include "rate_laws.h"
#include "juno_curve.h"

static float efx_bits(uint32_t u) { float f; memcpy(&f, &u, sizeof f); return f; }

/* front-panel blob value at blob position bp (blob = record + 16). */
static int efx_blob_val(const unsigned char *rec, int bp)
{
    const unsigned char *b = rec + 16;
    return ((b[2 * bp] & 0xF) << 4) | (b[2 * bp + 1] & 0xF);
}
/* logical byte from a nibble pair at record offset off. */
static int efx_rec_byte(const unsigned char *rec, int off)
{
    return ((rec[off] & 0xF) << 4) | (rec[off + 1] & 0xF);
}

static void write_struct(unsigned char *state, const juno_efx_cell *tbl, int n)
{
    int i;
    for (i = 0; i < n; ++i)
        *(uint32_t *)JCELL(state, tbl[i].off) = tbl[i].bits;
}

/* EFFECT DEPTH under the EFFECT TYPE field t in force when DEPTH is dispatched.
 * The plugin's DEPTH setter (rva 0x3AE560) switches on that field; for types
 * 0/1 it sends column 0 of a 256-row table the processor constructor fills with
 * min(4*depth, 255) (rva 0x3AC670) to the block method at rva 0x357D60, which
 * stores curve 25 of it. PROVEN cell by cell under Unicorn (DEPTH dispatched
 * with each type 0..6 in force; tools/verify/effect_param_gate.py sweeps all
 * 256 bytes in types 0..5 at 3 rates):
 *   t 0/1  : 84544 = curve 25 of min(4*depth, 255);
 *            85136 (t 0) or 86288 (t 1) = MODE1_DS_DRIVE_LUT[depth]
 *   t 2..4 : 84544 = EFFECT_SW_LUT[depth] (0 -> 0, else 1.0); block-A wet
 *            91232 too, which src/chorus_recall.c writes with the same law
 *   t 5    : 84544 = EFFECT_SW_LUT[depth]; 96400 = depth / 255
 *   t >= 6 : nothing -- the switch has no such case.
 * EFFECT_SW_LUT's 2026-08-25 correction was measured in types 2..5 only and
 * had been applied to every type. */
static void depth_under(unsigned char *state, int t, int depth)
{
    if (t <= 1) {
        JF(state, 84544) = juno_curve(25, depth * 4 > 255 ? 255 : depth * 4);
        JF(state, t == 0 ? 85136 : 86288) = efx_bits(MODE1_DS_DRIVE_LUT[depth & 0xFF]);
    } else if (t <= 5) {
        JF(state, 84544) = efx_bits(EFFECT_SW_LUT[depth & 0xFF]);
        if (t == 5)
            JF(state, 96400) = (float)depth / 255.0f;
    }
}

void juno_apply_effect_modes(unsigned char *state, const unsigned char *rec)
{
    int depth = efx_blob_val(rec, 50);    /* EFFECT DEPTH 0..255 */
    int tone  = efx_rec_byte(rec, 642);   /* EFFECT TONE  0..255 */
    int etype = efx_rec_byte(rec, 634);   /* EFFECT TYPE  0..5   */

    /* THE RECALL ORDER DECIDES WHICH TYPE EACH LEAF SEES. The plugin recalls in
     * ascending index order (its enumerator, rva 0x3B48A0, executed:
     * probes in tools/verify/plugin_recall_set.py): EFFECT DEPTH (794) runs
     * BEFORE EFFECT TYPE (873), EFFECT TONE (874) after it. So DEPTH first acts
     * under the type field in force BEFORE this recall -- the raw previous leaf,
     * JUNO_PREV_EFX, which can be >= 6 (the plugin's field at processor +1472
     * stores the raw value, PROVEN: 6 after a type-6 recall). */
    depth_under(state, JI(state, JUNO_PREV_EFX), depth);

    /* OUT OF RANGE (type >= 6): the TYPE setter stores the raw value in its
     * field but routes nothing, selects no mode and replays nothing; TONE then
     * sees the raw value and its switch writes nothing. So no arm below runs.
     * PROVEN two ways: the routing cell keeps the type in force (with 3 in
     * force a type-6 recall leaves 3; tools/verify/warm_recall_gate.py), and a
     * cold type-6/255 recall leaves block B (96352/96384/96400/96416) at 0
     * where the old port ran the type-5 arm (a clamp to 5 that no gate had
     * compared on the whole object; tools/verify/effect_param_gate.py). */
    if (etype > 5)
        return;
    *(int32_t *)JCELL(state, JUNO_PROG_EFX) = (int32_t)etype;

    /* A valid TYPE re-routes slot 2 and replays DEPTH under the NEW type:
     * a cold type-0 recall ends at curve 25 of min(4*depth, 255) although
     * DEPTH first ran under the power-on type 2 (effect_param_gate.py, fresh
     * recalls). The arms below then write their own cells. */
    depth_under(state, etype, depth);

    /* EFFECT TYPE 0 — the slot-2 "Pan" arm (the render's v551<=1 branch, block
     * 84960..85968): a clean level+pan stage sharing mode-1's laws (the DlyPan
     * class without the distortion stage). The factory bank contains NO type-0
     * patch, so this arm was invisible to every factory gate — the port left its
     * two multiplicative enable gates at 0.0, muting the entire slot-2 output
     * (the master chain is in series, so every type-0 patch rendered SILENT;
     * found via a user bank with 8 type-0 patches). PROVEN from the plugin's own
     * recall + 256-value DEPTH/TONE setter sweeps under Unicorn (state diff +
     * scratchpad mode0 sweeps, 2026-07-19):
     *   85136 = MODE1_DS_DRIVE_LUT[depth]  (bit-equal at all 256 depth values)
     *   85984 = MODE1_DS_TONE_LUT[tone]    (bit-equal at all 256 tone values)
     *   85168 = 85184 = 1.0                (enable gates)
     * GUARDED to etype==0: the plugin's own recall of a TYPE-2 patch leaves all
     * four cells at the prepare default 0 (chillwave patch-3 state dump — the
     * live setters route by the CURRENT type, so the earlier "written for every
     * type" reading of the type-sweep was staleness, not recall behavior). */
    if (etype == 0) {
        JF(state, 85136) = efx_bits(MODE1_DS_DRIVE_LUT[depth & 0xFF]);
        JF(state, 85984) = efx_bits(MODE1_DS_TONE_LUT[tone & 0xFF]);
        JF(state, 85168) = 1.0f;
        JF(state, 85184) = 1.0f;
    }

    if (etype == 1) {                     /* DISTORTION + PANNER (block 86288..87152) */
        write_struct(state, MODE1_STRUCT, MODE1_STRUCT_N);
        JF(state, 86288) = efx_bits(MODE1_DS_DRIVE_LUT[depth & 0xFF]);  /* DS Drive   */
        JF(state, 86304) = efx_bits(0x41008081u);                      /* DS Level (const) */
        JF(state, 87056) = efx_bits(MODE1_DS_TONE_LUT[tone & 0xFF]);    /* DS TONE (pan)    */
        JF(state, 86320) = 1.0f;                                       /* DS Mute gate     */
        /* 19 mode-1 filter cells are RATE-DEPENDENT, 2-class {44100 / else}: the
         * MODE1_STRUCT capture (48 kHz) coincides with the 96 kHz values, so the
         * single arm was invisible until the 44.1 kHz state diff. The 44.1 arm is
         * measured bit-for-bit from the plugin's own recall of patch 9 (the only
         * factory v551==1 patch) at 44100; 48000/96000 hold the struct values
         * (scratchpad/oracle/ p9 fullscan). */
        if ((int)JF(state, 16) == 44100) {
            static const uint32_t M1_44[] = {
                86368,0x407e0000u, 86384,0xc07e0000u, 86400,0x3f7e0000u,
                86464,0x3dbcc000u, 86480,0x3c000000u, 86592,0x3a000000u,
                86608,0x3d8178abu, 86624,0xbd8178abu, 86640,0x3f7f0000u,
                86912,0x3c80135bu, 86928,0x3d708c41u, 86944,0x3e29e7b6u,
                86960,0x3e84f967u, 87072,0x4054945cu, 87088,0xc03842f0u,
                87104,0x3f0eba50u, 87120,0x3f86b818u, 87136,0xbf698bc4u,
                87152,0x3f76fbf8u
            };
            unsigned k;
            for (k = 0; k < sizeof(M1_44)/sizeof(M1_44[0]); k += 2)
                JF(state, (int)M1_44[k]) = efx_bits(M1_44[k + 1]);
        }
    } else if (etype == 5) {              /* CHORUS/ENSEMBLE variant (block 96336..96912) */
        write_struct(state, MODE5_STRUCT, MODE5_STRUCT_N);
        JF(state, 96400) = (float)depth / 255.0f;                      /* On/Off           */
        {
            int Hr = (int)JF(state, 16);
            /* LFO Rate (96352), READ from the mode-5 method (rva 0x3573ab): curve 22 of
             * the tone byte, r = c * 1.9667f (f32 0x3ffbbcd3, rva 0x988120) + 0.3333f
             * (f32 0x3eaaa64c, rva 0x988110), then (r + r) / H -- all float.
             * PROVEN 256/256 tone bytes at 44100, 32000 and 96001 by sweeping the
             * plugin's own EFFECT TONE setter (dispatch 874) under Unicorn,
             * 2026-10-05. It replaces "the 96 kHz LUT times 96000/H in double",
             * an inferred form that matched the factory patches' tone values but
             * was wrong for 65..72 of the 256 tone bytes at EVERY rate, 44.1k
             * included (no gate swept EFFECT TONE at EFFECT TYPE 5). */
            {
                float r = juno_curve(22, tone & 0xFF) * efx_bits(0x3ffbbcd3u)
                          + efx_bits(0x3eaaa64cu);
                JF(state, 96352) = (r + r) / (float)Hr;
            }
            /* Ip Fc gate (96384) — SR-dependent 3-class (mode5_gates_spec.md). */
            JF(state, 96384) = efx_bits(Hr == 44100 ? 0x388b3cdfu :
                                        Hr == 48000 ? 0x387fd974u : 0x37ffd974u);
            /* Structural cell 96336: (H * C3) - C2, C3 = f32 0x33d5febf (rva
             * 0x9880f0), C2 = f32 0x39000000 (rva 0x988104), read from the
             * mode-5 method at rva 0x357310. CONTINUOUS in H (CLAIMS B4); it was
             * four measured arms (this law at 44100/48000/88200/96000, the 96k
             * word at every other rate -- wrong at 32000, rate_sweep_gate.py). */
            JF(state, 96336) = rl_mode5_time(Hr);
            /* 17 further block-B cells are RATE-DEPENDENT, 2-class {44100 / else}
             * (48000 == 88200 == 96000 hold the MODE5_STRUCT values). The single-arm
             * struct capture broke every v551==5 patch cold at 44.1 kHz (divergence
             * from ~frame 7; the 44.1k warm sweep flagged all 8 of them, right-channel
             * corr collapse). 44.1 arms measured bit-for-bit from the plugin's own
             * recall of patches 40/21 at 44100; 88200 confirmed on the else arm
             * (scratchpad/oracle/ rate fullscan p40/p21 + 88.2 dump). */
            if (Hr == 44100) {
                static const uint32_t M5_44[] = {
                    96432,0x3f7fb563u, 96448,0xbf7fb563u, 96464,0x3f7f6ac6u,
                    96480,0x3da89881u, 96496,0x3e289881u, 96512,0x3da89881u,
                    96528,0x3f6d4cfcu, 96544,0xbe833278u, 96560,0x3f7204f1u,
                    96576,0xbf7204f1u, 96592,0x3f6409e3u, 96640,0x3ba05e31u,
                    96688,0x3a001b94u, 96704,0x3b001b93u, 96784,0x35921658u,
                    96800,0x402c4400u, 96848,0x3d000000u
                };
                unsigned k5;
                for (k5 = 0; k5 < sizeof(M5_44)/sizeof(M5_44[0]); k5 += 2)
                    JF(state, (int)M5_44[k5]) = efx_bits(M5_44[k5 + 1]);
            }
        }
        JF(state, 96416) = 1.0f;                                       /* Mute gate        */
    }
}
