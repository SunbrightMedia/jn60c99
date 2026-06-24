/* juno_params.h — parameter→coefficient APPLY engine (Phase 2).
 * Transcribed from the VST3 apply path (docs/PARAM_APPLY_MAP.md): a preset stores a
 * per-parameter step (0..255); the coefficient is denormalized via a LUT
 * (coefficient = lut[tableId][step], sub_356380) or read as a switch (0/1), then
 * stored to the engine-state slot and broadcast to the 8 voices. Validated bit-exact
 * against the PD Juno Pad capture (tests/test_apply.c: 88/88 LUT members). */
#ifndef JUNO_PARAMS_H
#define JUNO_PARAMS_H
#include "juno_engine.h"
#include "juno_param_luts.h"

/* Apply a LUT-denormalized parameter: state[offset] = lut[tableId][step], broadcast to
 * all voices if broadcast!=0 (per-voice main-block stride). */
void juno_param_apply_lut(unsigned char *st, int offset, int tableId, int step, int broadcast);

/* Apply a switch/level parameter directly (value already plain, e.g. 0.0/1.0). */
void juno_param_apply_value(unsigned char *st, int offset, float value, int broadcast);

#endif

#include "juno_param_table.h"
/* Apply a whole preset: steps[] indexed by paramId (0..maxId), -1 = "not set/skip".
 * Walks JUNO_PARAM_TABLE, denormalizes each via its tableId, writes + broadcasts.
 * Returns the number of params applied. Covers the LUT-denormalized synth params;
 * switches and FX-derived coefficients are handled separately. */
int juno_apply_preset(unsigned char *st, const int *steps, int n);
