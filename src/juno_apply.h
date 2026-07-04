/* juno_apply.h — apply a decoded JUNO-60 bank patch to the engine coefficients.
 * See juno_apply.c for the binding provenance + coverage (honest: the confirmed
 * filter + filter-ADSR subset; DCO levels / ENV2 / FX pending binding). */
#ifndef JUNO_APPLY_H
#define JUNO_APPLY_H
#ifdef __cplusplus
extern "C" {
#endif

/* bank = raw KoaBankFile00003 bytes. */
int juno_bank_num_patches(const unsigned char *bank, unsigned long len);
int juno_bank_patch_name(const unsigned char *bank, int idx, char out[17]);
/* Set engine coefficient slots for patch idx. Returns # params applied. */
int juno_bank_apply(unsigned char *state, const unsigned char *bank, int idx);

#ifdef __cplusplus
}
#endif
#endif
