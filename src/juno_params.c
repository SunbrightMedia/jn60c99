#include "juno_params.h"

void juno_param_apply_lut(unsigned char *st, int offset, int tableId, int step, int broadcast){
    float c = juno_lut_apply(tableId, step);
    /* (A former special-case gated tableId 12 step 0 to 0.0 for Osc Noise Level.
     * The decompile audit disproved it: NO call site in the whole binary uses
     * table 12 — the real OscVoice noise setter (sub_7FF91DFBC4B0) applies LUT54,
     * whose step 0 is natively 0.0, and the "PD Juno Pad" captured value
     * 0x3e340000 is LUT54[45] (that patch's noise byte was 45, not 230). The map
     * binds DB773 with tableId 54 now; no gate needed.) */
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
