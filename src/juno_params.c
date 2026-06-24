#include "juno_params.h"

void juno_param_apply_lut(unsigned char *st, int offset, int tableId, int step, int broadcast){
    float c = juno_lut_apply(tableId, step);
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
