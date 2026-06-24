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
