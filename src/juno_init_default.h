/* juno_init_default.h - construction-time parameter-default initialization.
 *
 * The plugin fills ~340 "runtime" coefficient slots at construction by applying
 * EVERY registered parameter's DEFAULT through the param-apply path (the layer
 * between the static engine_init and a loaded preset). The C port previously
 * faked these with an incomplete live capture (src/runtime_coeffs_data.c), which
 * left 237 slots at 0.0 -- including the critical read-as-zero offsets 4208 (JU
 * OSC Sqr level), 7616 (Resonance Tune), 7600 (Cutoff Tune), 4064/4080 (ENV1/ENV2
 * mod level). juno_init_default reproduces the construction default-apply:
 *
 *   - Each param's DEFAULT is read from the registry sub_388170 descriptor: the
 *     40-byte descriptor's default block at desc+12 is the 16-byte immediate the
 *     registry stores before calling the registrar sub_180387F80. For 798 params
 *     it is xmmword_18098C030 = {i32:1,0,0,0} (default step 1); for 323 it is
 *     xorps (default step 0). param_id = the registration index in sub_388170.
 *   - LUT family (has tableId, param_table_full.json): coeff = lut[tableId][step]
 *     (sub_356380), applied + broadcast to all 8 voices via juno_param_apply_lut.
 *   - scale+offset family (no tableId, sub_356150): coeff = value*scale[idx]+1.0.
 *     See juno_init_default_data.h for the recoverable subset and the flagged
 *     unrecoverable scale[] terms.
 *
 * Call AFTER juno_chorus_init + juno_engine_init. This is the new path that
 * replaces runtime_coeffs_data.c (kept as an oracle/fallback for now).
 */
#ifndef JUNO_INIT_DEFAULT_H
#define JUNO_INIT_DEFAULT_H

#ifdef __cplusplus
extern "C" {
#endif

/* Apply every registry param's construction-time default to the engine state.
 * Returns the number of coefficient slots written (LUT + scalar + scale-offset). */
int juno_init_default(unsigned char *st);

#ifdef __cplusplus
}
#endif

#endif /* JUNO_INIT_DEFAULT_H */
