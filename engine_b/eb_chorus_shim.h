/* eb_chorus_shim.h — the ONLY thing engine_b/shim/chorus/master_render.c adds.
 * See engine_b/eb_chorus_shim.c for what it does and why it is a shim and not
 * the engine. */
#ifndef ENGINEB_EB_CHORUS_SHIM_H
#define ENGINEB_EB_CHORUS_SHIM_H
#include "eb_chorus.h"
void ebsh_snapshot(eb_chorus_state *s, const unsigned char *b);
void ebsh_load_coef(eb_chorus_coef *k, const unsigned char *b);
void ebsh_forget(const unsigned char *base);
void ebsh_chorus(unsigned char *base, float in, float *outL, float *outR,
                 float v56, float v58);
#endif
