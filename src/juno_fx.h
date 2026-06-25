/* juno_fx.h — capture-free FX coefficient setup derived from the binary. */
#ifndef JUNO_FX_H
#define JUNO_FX_H
/* JUNO chorus LFO-rate CV (sub_7FF91DFBE590, rva 0x35E590): CV=(step/255)*11-8
 * in float32. step 62 = Chorus I (-5.32549), step 50 = Chorus II (-5.84314). */
float juno_chorus_cv(int step);
/* Write the two fixed JUNO chorus instance rates (I and II) capture-free.
 * The chorus mode selector routes which instance reaches the output. */
void  juno_chorus_set_rates(unsigned char *st);
#endif
