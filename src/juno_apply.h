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

/* Decode the per-patch ARPEGGIATOR settings (NAME1 leaves 89/90/91 at record bytes
 * 298/306/314 — derived from the same value-tree leaf enumeration that lands the 5
 * oracle-anchored leaves exactly). Returns 1 if the arp is ON for patch idx; writes
 * *mode (0=up,1=down,2=up&down) and *oct (1..3). Rate is host-tempo-synced in the
 * plugin (no per-patch value), so it is not returned. */
int juno_bank_arp(const unsigned char *bank, int idx, int *mode, int *oct);

/* Decode the per-patch VOICE-ASSIGN settings (CTRL leaves 57/58 at front-panel
 * blob positions 55/56). Writes *legato (0/1) and *assign (ASSIGN MODE 0..3).
 * Returns 1 on success (valid idx). The allocation semantics these select are
 * applied in the note driver (see gui/juno_bridge.c). */
int juno_bank_voice_modes(const unsigned char *bank, int idx, int *legato, int *assign);

#ifdef __cplusplus
}
#endif
#endif
