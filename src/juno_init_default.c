/* juno_init_default.c - construction-time parameter-default initialization.
 * See juno_init_default.h for the derivation. Faithful: every value comes from
 * the binary (registry sub_388170 defaults + the decompiled apply transforms).
 * No fitted or invented coefficients; the one genuinely unrecoverable piece (the
 * per-param scale[idx] of the scale+offset family) is flagged, not guessed. */
#include "juno_init_default.h"
#include "juno_params.h"
#include "juno_engine.h"
#include "juno_init_default_data.h"
#include <string.h>

/* Voice-region main block: param-applied coefficients written to voice 0's base
 * are broadcast to all 8 voices at +10512*v by the parameter system. Outside this
 * range (global/master/chorus/reverb) the coefficient is written once. Matches the
 * broadcast rule in runtime_coeffs_data.c / juno_param_apply_lut. */
static void def_write(unsigned char *st, int off, float c)
{
    JF(st, off) = c;
    if (off >= 176 && off <= 10672) {
        int v;
        for (v = 1; v < JUNO_NUM_VOICES; ++v)
            JF(st, off + v * JUNO_VOICE_MAIN_STRIDE) = c;
    }
}

int juno_init_default(unsigned char *st)
{
    int i, written = 0;

    /* LUT-denormalized family (param has a tableId): sub_356380 lookup.
     * juno_param_apply_lut writes voice 0 + broadcasts to voices 1..7. */
    for (i = 0; i < JUNO_DEF_LUT_N; ++i) {
        const juno_def_lut_ent *e = &JUNO_DEF_LUT[i];
        juno_param_apply_lut(st, e->offset, e->tableId, e->step, 1);
        ++written;
    }

    /* scale+offset family params whose default the registry carries as an explicit
     * float immediate (movss cs:dword_18098xxxx -> desc+8). Faithful .rdata floats. */
    for (i = 0; i < JUNO_DEF_VAL_N; ++i) {
        const juno_def_val_ent *e = &JUNO_DEF_VAL[i];
        float c; memcpy(&c, &e->bits, sizeof c);
        def_write(st, e->offset, c);
        ++written;
    }

    /* scale+offset family criticals with NO tableId (4064/4080/7600). The full
     * transform is value*scale[idx] + offset (sub_356150) with offset const
     * dword_7FF91E7450B4 = 1.0 and value = default step = 1. scale[idx] lives in
     * the controller apply-object (obj+0x2C) reached only via a per-parameter
     * vtable and is NOT statically recoverable (refs/default_patch.json boundary).
     * We write the +offset additive base (1.0) -- the one faithful binary-sourced
     * term -- so these read NONZERO and finite. FLAGGED: scale term missing; this
     * is the additive base, not the exact coefficient. */
    for (i = 0; i < JUNO_DEF_SCALEOFF_N; ++i) {
        const juno_def_scaleoff_ent *e = &JUNO_DEF_SCALEOFF[i];
        def_write(st, e->offset, e->offset_const);
        ++written;
    }

    return written;
}
