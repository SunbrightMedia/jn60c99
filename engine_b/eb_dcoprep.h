/* eb_dcoprep.h — the DCO's per-sample pitch and pulse-width preparation.
 *
 * SCOPE. src/voice_render.c:1702-1717 exactly. It turns the modulated pitch CV
 * and PWM CV into the three values the DCO's sub-sample loop consumes: the
 * phase increment, its reciprocal-scaled edge gain, and the pulse width.
 *
 * WHY THIS RANGE AND NOT ALSO :1665-1671. That neighbouring region is the last
 * unclaimed one in the voice function, and it is left in the port ON PURPOSE:
 * it contains NO arithmetic. It is four cell loads and three delayed copies
 * (4848 <- 4832, 4880 <- 4864, and the 4416 store, which is dead). Wrapping
 * pure cell motion in a module function would add a call and move nothing into
 * engine B; it would make the "blocks claimed" count look better and the
 * engine no more portable. Recorded rather than quietly counted.
 *
 * THE THREE PROMOTED SCRATCH LOCALS. The port writes 4784, 4800 and 4816 to
 * BOTH the cell and a register-promoted local (_s4784/_s4800/_s4816, the pilot-2
 * scratch promotion at the top of voice_render.c). The CELLS are dead -- no
 * reader anywhere in voice_render -- but the LOCALS are read by the DCO block
 * below. So these are genuine outputs even though a cell-level dead-store scan
 * calls them dead, and the shim assigns both.
 *
 * NO STATE. Every input is either a coefficient or a value computed earlier in
 * the same sample. Cell 3808 is the one input that IS written inside
 * voice_render -- at :1117, EARLIER in the same sample -- so it is this
 * sample's value and is passed per sample rather than cached with the
 * coefficients.
 *
 * THE DIVISION `0.00390625f / v398` is the same one eb_dco_set_pitch performs,
 * and it is the target of EB_DCO_RECIP. It stays a division here: this module
 * must null at EXACTLY 0.
 */
#ifndef ENGINEB_EB_DCOPREP_H
#define ENGINEB_EB_DCOPREP_H

typedef struct {
    float k5520, k5536, k5568, k6288, k6304, k6320;
} eb_dcoprep_coef;

/* One sample. `pitch` is the port's v391 and `pwmcv` its v392. Returns the
 * phase increment (the port's v398, and its cell/local 4784). */
float eb_dcoprep_tick(const eb_dcoprep_coef *c, float pitch, float pwmcv,
                      float in3808,
                      float *out4800, float *out4816, float *out5456);

#endif /* ENGINEB_EB_DCOPREP_H */
