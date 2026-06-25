/* juno_reverb.h — activate the bit-exact JUNO-60 CDSPRev reverb.
 * Transcription of the retune sub_7FF91E021AC0 (tap-offset builder) + the
 * activation state writes. Call juno_reverb_activate AFTER juno_chorus_init +
 * juno_engine_init + juno_runtime_coeffs_apply. type 3 = HALL2. */
#ifndef JUNO_REVERB_H
#define JUNO_REVERB_H
int  juno_reverb_build_taps(unsigned char *st, int type, int pad);
void juno_reverb_activate  (unsigned char *st, int type, float decay);
#endif
