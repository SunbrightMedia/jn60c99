/* eb_glide.c — see eb_glide.h for scope, state classification and what is
 * deliberately not reproduced.
 *
 * A TRANSCRIPTION of src/voice_render.c:682-796 with the cell accesses renamed
 * and nothing else changed. The port's variable numbers are kept so the two
 * can be read side by side. The decompiler's goto ladder for the two exponent
 * lookups is kept as a goto ladder ON PURPOSE: rewriting it as structured
 * control flow is exactly the kind of "obviously equivalent" edit that this
 * project has repeatedly found not to be, and the null is what decides.
 *
 * The `(float)` casts are the port's and are load-bearing under
 * -ffp-contract=off.
 */
#include "eb_glide.h"
#include "juno_tables.h"
#include <math.h>

/* ---------------------------------------------------------------- prepare
 * THE TWO EXPONENT LADDERS, LIFTED. Their operands are k1168 and k912, both
 * recall constants, so the ladder below is byte for byte the port's :757-796
 * with `v59` and `v58` renamed and nothing else changed. Lifting it cannot
 * change a float, which is why the null stays EXACTLY 0 rather than merely
 * quiet.
 *
 * The goto ladder is KEPT as a goto ladder, for the reason the file header
 * gives: rewriting it as structured control flow is the kind of "obviously
 * equivalent" edit this project has repeatedly found not to be.
 */
void eb_glide_prepare(eb_glide_coef *c)
{
    float v58 = c->k1168, v59 = c->k912;
    int v63 = (int)v58, v66;

    if ((int)v58 < -32) {
        v59 = v59 * 2.3283064e-10f;
        goto LABEL_38;
    }
    if (v63 > 32) { v63 = 32; goto LABEL_37; }
    if (v63 < 0) { v59 = v59 * juno_exp_acc0[~v63]; goto LABEL_38; }
    if (v63 > 0) goto LABEL_37;
    goto LABEL_38;
LABEL_37:
    v59 = v59 * juno_exp_ad3c[v63];
LABEL_38:
    v66 = (int)(float)-v58;
    if (v66 < -32) { v59 = v59 * 2.3283064e-10f; goto LABEL_46; }
    if (v66 > 32) { v66 = 32; goto LABEL_45; }
    if (v66 < 0) { v59 = v59 * juno_exp_acc0[~v66]; goto LABEL_46; }
    if (v66 > 0) goto LABEL_45;
    goto LABEL_46;
LABEL_45:
    v59 = v59 * juno_exp_ad3c[v66];
LABEL_46:
    c->d_exp = v59;
}

float eb_glide_tick(eb_glide_state *s, const eb_glide_coef *c,
                    float gate_sign, float kbd, float vel, float pitch_in,
                    float *out752)
{
    float v35, v36, v37, v38, v39, v40, v41, v43, v44, v45, v46, v47, v48;
    float v49, v50, v51, v52, v53, v54, v55, v56, v57, v59, v61, v65;
    float v67, v68, v69, v70, v71, v72, v73;

    v35 = c->k608;
    v36 = gate_sign + 1.0f;
    v37 = c->k768;
    v38 = c->k624;
    v39 = s->s560;
    v40 = s->s704;
    v41 = v38 + c->k784;
    (void)v39;                      /* the port loads 560 into the dead 576 */
    s->s560 = v36;
    v43 = (float)(v36 * v35) - v35;
    v44 = c->k816;
    v45 = (float)(v43 + 1.0f) * c->k592;
    v46 = (float)(s->s672 / (float)((float)(v37 * v38) + c->k800)) * v37;
    v47 = s->s656;
    v48 = v47 - v46;
    v49 = s->s688;
    v50 = (float)(v48 + pitch_in) - v40;
    s->s656 = v50;
    v51 = v50 * v41;
    s->s672 = v51;
    v52 = v51 + v40;
    if ((float)(v44 - fabsf(v40 - pitch_in)) < 0.0f) {
        v53 = 0.0f;
        goto LABEL_25;
    }
    v53 = v49 + c->k832;
    if (v53 < 1.0f)
        goto LABEL_25;
    v54 = 1.0f;
    goto LABEL_26;
LABEL_25:
    v54 = v53;
LABEL_26:
    v55 = v54;
    s->s688 = v55;
    v56 = (float)((float)(v55 * pitch_in) - (float)(v55 * v52)) + v52;
    if (v45 == 0.0f)
        v56 = pitch_in;
    v57 = vel * c->k864;
    v59 = c->d_exp;                 /* was two table ladders; see prepare */
    v61 = v57 + (float)(kbd * c->k848);
    s->s880 = v61;
    s->s704 = v56;
    *out752 = v56;
    v65 = s->s1104;

    v67 = c->k1040;
    v68 = (float)((float)(v59 - v65) * c->k1152) + v65;
    v69 = c->k1088;
    s->s1104 = v68;
    v70 = (float)((float)(v68 * v67) - (float)(v67 * v69)) + v69;
    if (v70 <= 0.0f)
        v71 = 0.0f;
    else
        v71 = v70;
    v72 = v71;
    if (v72 < 1.0f)
        v73 = v72;
    else
        v73 = 1.0f;
    return v73;
}
