/* juno_curve.h — bit-exact JUNO-60 parameter curve evaluator.
 * Exact C99 port of the plugin's sub_1803B6380 (rva 0x356380): a 66-arm
 * switch(curve_id) that clamps `value` and returns a baked .rdata LUT[value]
 * (float32). Verified bit-exact vs Unicorn emulation of the real machine code
 * over every valid (curve_id, value) — 31,514 comparisons, 0 mismatches.
 * This is the core math of the patch->coefficient applier (unit #2). */
#ifndef JUNO_CURVE_H
#define JUNO_CURVE_H
#ifdef __cplusplus
extern "C" {
#endif
/* curve_id 0..65; value is the raw programmer value (clamped per-arm).
 * Returns the coefficient float the plugin would store. */
float juno_curve(int curve_id, int value);
#ifdef __cplusplus
}
#endif
#endif
