#include "juno_params.h"

void juno_param_apply_lut(unsigned char *st, int offset, int tableId, int step, int broadcast){
    float c = juno_lut_apply(tableId, step);
    /* Osc Noise Level (tableId 12 — used ONLY by engine offset 6528) carries a
     * setter-level byte-0 gate: step 0 writes 0.0 (noise OFF), NOT lut[12][0]=2.177.
     * The noise LUT is descending with floor 0.125, so "fully off" is unreachable
     * through the table; the engine special-cases it in the param's +120 setter.
     * Verified bit-exact against two live-engine captures: SY Poly Synth (byte 0 ->
     * 0x00000000, src/captured_patch.c) and PD Juno Pad (byte 230 -> lut[12][230] =
     * 0x3e340000, src/runtime_coeffs_data.c). See docs/PARAM_APPLY_MAP.md. */
    if (tableId == 12 && step == 0) c = 0.0f;
    JF(st, offset) = c;
    if (broadcast)
        for (int v = 1; v < JUNO_NUM_VOICES; ++v)
            JF(st, offset + v * JUNO_VOICE_MAIN_STRIDE) = c;
}

void juno_param_apply_value(unsigned char *st, int offset, float value, int broadcast){
    JF(st, offset) = value;
    if (broadcast)
        for (int v = 1; v < JUNO_NUM_VOICES; ++v)
            JF(st, offset + v * JUNO_VOICE_MAIN_STRIDE) = value;
}

int juno_apply_preset(unsigned char *st, const int *steps, int n){
    int applied = 0;
    for (int i = 0; i < JUNO_PARAM_TABLE_N; ++i){
        const juno_param_ent *e = &JUNO_PARAM_TABLE[i];
        if (e->paramId < 0 || e->paramId >= n) continue;
        int step = steps[e->paramId];
        if (step < 0) continue;                 /* not set */
        juno_param_apply_lut(st, e->offset, e->tableId, step, 1);
        applied++;
    }
    return applied;
}
