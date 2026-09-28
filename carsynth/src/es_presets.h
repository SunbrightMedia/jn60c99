#ifndef ES_PRESETS_H
#define ES_PRESETS_H
#include "es_engine.h"
#define ES_N_PRESETS 3
extern const char *const ES_PRESET_NAMES[ES_N_PRESETS];
void es_preset_load(es_engine *e, int which);
#endif
