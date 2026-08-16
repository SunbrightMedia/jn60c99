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

void juno_apply_effect_modes(unsigned char *state, const unsigned char *rec)
{
    int depth = efx_blob_val(rec, 50);    /* EFFECT DEPTH 0..255 */
    int tone  = efx_rec_byte(rec, 642);   /* EFFECT TONE  0..255 */
    int etype = efx_rec_byte(rec, 634);   /* EFFECT TYPE  0..5   */

    /* Route slot 2 to the patch's EFFECT TYPE (the driver points params+112 here).
     *
     * OUT OF RANGE MEANS NO STORE, NOT A CLAMPED STORE. The old comment here
     * said the plugin clamps types above 5 to 5, from a COLD spot sweep — and
     * cold that is unfalsifiable, because the power-on routing value and a
     * clamped write can be the same number. Warm it is plainly false.
     *
     * PROVEN two-sided (tools/verify/warm_recall_gate.py, synthetic bank, one
     * engine): with EFFECT TYPE 3 in force, a recall at type 6 leaves the cell
     * at 3; with type 5 in force it leaves 5; type 7 and 255 behave as 6. The
     * result always equals the incoming value, so the plugin performs NO STORE.
     * The port clamped and stored 5, which is right only when the previous type
     * happened to be 5 — 7 of 30 legal random seeds caught it.
     *
     * The CLAMP ITSELF STAYS for the mode arms below: only the routing store is
     * skipped. The arms at a clamped 5 matched the plugin on every one of those
     * seeds; changing them is the unlanded seventh-class work, not this fix. */
    if (etype <= 5)
        *(int32_t *)JCELL(state, JUNO_PROG_EFX) = (int32_t)etype;
    if (etype > 5) etype = 5;

    /* Shared slot-2 wet control (read by master_render for EVERY mode at 84544). */
    JF(state, 84544) = efx_bits(EFFECT_SW_LUT[depth & 0xFF]);

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
            int Hr = (int)JF(state, 16); if (Hr <= 0) Hr = 96000;
            /* LFO Rate (96352): the CHORUS5_LFORATE_LUT is the 96 kHz reference; the
             * host-rate value is LUT * (96000/SR) computed in DOUBLE precision then
             * rounded to float — a float32 multiply is +1 ULP off for some LUT
             * entries (e.g. tone 128, LUT 0x37e6c674: plugin 0x387b2f14 @44.1k, the
             * float op gives ..15). Proven against the plugin's own recall at
             * 44100/88200 (2.0x @48k is exact either way). */
            JF(state, 96352) = (float)((double)efx_bits(CHORUS5_LFORATE_LUT[tone & 0xFF])
                               * (96000.0 / (double)Hr));
            /* Ip Fc gate (96384) — SR-dependent 3-class (mode5_gates_spec.md). */
            JF(state, 96384) = efx_bits(Hr == 44100 ? 0x388b3cdfu :
                                        Hr == 48000 ? 0x387fd974u : 0x37ffd974u);
            /* Structural cell 96336 is rate-dependent with FOUR distinct arms (all
             * measured from the plugin's own recall; MODE5_STRUCT holds the 96k arm). */
            JF(state, 96336) = efx_bits(Hr == 44100 ? 0x3b8c0000u :
                                        Hr == 48000 ? 0x3b98bc15u :
                                        Hr == 88200 ? 0x3c0e0000u : 0x3c1abc15u);
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
