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
        *(uint32_t *)(state + tbl[i].off) = tbl[i].bits;
}

void juno_apply_effect_modes(unsigned char *state, const unsigned char *rec)
{
    int depth = efx_blob_val(rec, 50);    /* EFFECT DEPTH 0..255 */
    int tone  = efx_rec_byte(rec, 642);   /* EFFECT TONE  0..255 */
    int etype = efx_rec_byte(rec, 634);   /* EFFECT TYPE  0..5   */

    /* Route slot 2 to the patch's EFFECT TYPE (the driver points params+112 here). */
    *(int32_t *)(state + JUNO_PROG_EFX) = (int32_t)etype;

    /* Shared slot-2 wet control (read by master_render for EVERY mode at 84544). */
    JF(state, 84544) = efx_bits(EFFECT_SW_LUT[depth & 0xFF]);

    if (etype == 1) {                     /* DISTORTION + PANNER (block 86288..87152) */
        write_struct(state, MODE1_STRUCT, MODE1_STRUCT_N);
        JF(state, 86288) = efx_bits(MODE1_DS_DRIVE_LUT[depth & 0xFF]);  /* DS Drive   */
        JF(state, 86304) = efx_bits(0x41008081u);                      /* DS Level (const) */
        JF(state, 87056) = efx_bits(MODE1_DS_TONE_LUT[tone & 0xFF]);    /* DS TONE (pan)    */
        JF(state, 86320) = 1.0f;                                       /* DS Mute gate     */
    } else if (etype == 5) {              /* CHORUS/ENSEMBLE variant (block 96336..96912) */
        write_struct(state, MODE5_STRUCT, MODE5_STRUCT_N);
        JF(state, 96400) = (float)depth / 255.0f;                      /* On/Off           */
        {
            int Hr = (int)JF(state, 16); if (Hr <= 0) Hr = 96000;
            /* LFO Rate (96352): the CHORUS5_LFORATE_LUT is the 96 kHz reference; the
             * host-rate value is LUT * (96000/SR) (verified 2.0x @48k vs the captured
             * mode-5 master states). */
            JF(state, 96352) = efx_bits(CHORUS5_LFORATE_LUT[tone & 0xFF])
                               * (96000.0f / (float)Hr);
            /* Ip Fc gate (96384) — SR-dependent 3-class (mode5_gates_spec.md). */
            JF(state, 96384) = efx_bits(Hr == 44100 ? 0x388b3cdfu :
                                        Hr == 48000 ? 0x387fd974u : 0x37ffd974u);
            /* Structural cell 96336 is rate-dependent and MODE5_STRUCT holds the 96 kHz
             * value; the plugin's 48 kHz value is 0x3b98bc15 (const across mode-5 patches,
             * captured direct — not a clean scale of the 96k value). Override at 48 kHz;
             * 96k keeps the struct value; other rates approximate. See FX_COLDLOAD_TODO. */
            if (Hr == 48000) { JF(state, 96336) = efx_bits(0x3b98bc15u); }
        }
        JF(state, 96416) = 1.0f;                                       /* Mute gate        */
    }
}
