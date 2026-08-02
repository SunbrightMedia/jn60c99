/* eb_cvgate.h — the per-voice CV smoothing and the gate sign.
 *
 * SCOPE: src/voice_render.c:654-680. The boundary was not chosen for tidiness.
 * It is where the block stops producing values anyone else uses: MEASURED by
 * search, none of v28, v29, v30, v34 appears anywhere after line 693, so this
 * block's ONLY outputs are the cells it writes -- 336, 448, 464, 480, 496 --
 * plus the gate sign it hands to the line that follows.
 *
 * STATELESS. Both smoothers read their previous output from a cell the caller
 * supplies rather than carrying it, so like eb_pitch this block needs no home
 * for state and no power-on marker.
 *
 * THE GATE SIGN IS NOT copysign AND NOT (x>0)-(x<0). The port's three-way form
 * maps exactly zero to ZERO, not to +1, and the next line adds 1.0 to it, so a
 * zero gate produces 1.0 where a +1 would produce 2.0. Getting that wrong would
 * be silent on every key-down and wrong at every release.
 *
 * OBSERVABILITY, MEASURED before writing: a 0.1 % error here moves 30 of the 30
 * scenarios and lands at +3.6 dB. No risk of a blind gate.
 */
#ifndef ENGINEB_EB_CVGATE_H
#define ENGINEB_EB_CVGATE_H

typedef struct {
    float t28, t29;      /* the two smoother TARGETS: the port's v12 and v11  */
    float k;             /* the smoother coefficient: the port's v26         */
    float p28, p29;      /* the two previous outputs: cell 304, and v2       */
    float gate_off;      /* cell 544, added before the gate test             */
} eb_cvgate_in;

typedef struct {
    float c336, c448, c464, c480, c496;   /* the cells the port writes */
    float sign;                           /* the three-way gate sign   */
} eb_cvgate_out;

void eb_cvgate(const eb_cvgate_in *in, eb_cvgate_out *out);

#endif /* ENGINEB_EB_CVGATE_H */
