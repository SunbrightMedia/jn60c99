/* juno_driver.h — offline per-sample driver around the exact DSP transcription.
 * Renders the voices into the master's 8 voice buffers, supplies the chorus-mode
 * selectors, and calls juno_master_render to produce the final stereo sample.
 * This is clean host glue (no plugin threading) — see src/juno_driver.c.
 */
#ifndef JUNO_DRIVER_H
#define JUNO_DRIVER_H

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

/* Shim that satisfies the master's host-params pointer chase off state+136.
 * The master reads two effect-slot selectors:
 *   base = *(void**)(state+136);
 *   v39  = *(int*)*(void**)((char*)base + 136);   // slot 1 (DELAY TYPE)
 *   v551 = *(int*)*(void**)((char*)base + 112);   // slot 2 (EFFECT TYPE)
 * juno_driver_attach_host points params+136 at the ENGINE cell state[JUNO_PROG_DLY]
 * (written per-patch by juno_apply_delay) so slot 1 follows the loaded patch's
 * DELAY TYPE, and points params+112 at mode_v551 (a fixed chorus selector). Each
 * selector picks the slot algorithm: 0 delay, 2/3 chorus, 4/5 reverb. */
struct juno_host_shim {
    int32_t mode_v39;            /* legacy; not read by the master any more */
    int32_t mode_v551;           /* slot-2 EFFECT selector (fixed chorus)   */
    unsigned char params[160];   /* +112 and +136 hold pointers to the selectors */
};

/* Wire the shim into the state block. Call once after juno_engine_init.
 * `shim` must outlive all subsequent render calls. */
void juno_driver_attach_host(unsigned char *st, struct juno_host_shim *shim,
                             int32_t chorus_mode);

/* Replicate voice 0's per-voice patch coefficients to voices 1..7. Call once
 * after juno_bank_apply (which writes voice 0 only) so all 8 voices play the same
 * patch. Global coefficients (>=84272) are left as the applier set them. */
void juno_driver_seed_voices(unsigned char *st);

/* Render one stereo output sample (8 voices -> 8 buffers -> master process).
 * Returns 1 if the full master/chorus path ran, 0 if the dry fallback was used
 * (effect coefficients from the prepare/setSampleRate baseline not loaded — see
 * juno_driver.c and src/runtime_coeffs_data.c). */
int juno_driver_render_sample(unsigned char *st, float *outL, float *outR);

#ifdef __cplusplus
}
#endif

#endif /* JUNO_DRIVER_H */
