/* eb_fx_e5.c -- GENERATED from src/master_render.c:2633-2748. */
#include "eb_fx_e5.h"
#include "eb_dsp.h"
#include "juno_tables.h"
#include <math.h>
#include <string.h>
#include <stdbool.h>

#define LODWORD(x) (*(uint32_t *)&(x))
#define RINGR(i)   (s->ring[(c->k101028 - 1) & (int32_t)(i)])
#define RINGI(i)   (s->ring[(i)])

void eb_fx_e5_tick(eb_fx_e5_state *s, const eb_fx_e5_coef *c,
                   float in84624, float in56, float in58,
                   float *o56, float *o58, float *o593)
{
    double v56;
    float v58;
    float v552;
    float v553;
    float v554;
    bool v555;
    float v556;
    float v557;
    float v558;
    float v559;
    float v560;
    float v561;
    float v562;
    float v563;
    float v564;
    float v565;
    float v566;
    float v567;
    float v568;
    float v569;
    float v570;
    float v571;
    float v572;
    int v573;
    float v574;
    float v575;
    float v576;
    float v577;
    float v578;
    float v579;
    float v580;
    float v581;
    float v582;
    float v583;
    float v584;
    float v585;
    float v586;
    float v587;
    float v588;
    float v589;
    float v590;
    float v591;
    int v592;
    float v593;
    v56 = in56;   /* IN-OUT: assigned only on one branch below */
    v58 = in58;
        v552 = in84624;
        s->s95952 = s->s95936;
        s->s95936 = s->s95920;
        s->s96112 = s->s96096;
        s->s96096 = s->s96080;
        s->s96080 = s->s96064;
        s->s96064 = s->s96048;
        s->s96048 = s->s96032;
        s->s96032 = s->s96016;
        s->s96016 = s->s96000;
        s->s96000 = s->s95984;
        s->s95984 = s->s95968;
        s->s96144 = s->s96128;
        s->s96176 = s->s96160;
        s->s96208 = s->s96192;
        s->s96256 = s->s96240;
        s->s96240 = s->s96224;
        s->s95888 = v552;
        s->s95904 = v552;
        v553 = eb_wrap_unit((float)((float)( s->s96176 + s->s96144 ) + c->k96352));
        v554 = *(float *)&v553;
        v555 = *(float *)&v553 < 0.0;
        memcpy(&s->s96160, &v553, 4);
        v556 = c->k96784;
        if ( v555 )
          v556 = -v556;
        v557 = fabs(v554);
        s->s96128 = v556;
        s->s96272 = v557;
        v558 = s->s95904;
        s->s96288 = (float)((float)(v557 * c->k96368) * c->k96800)
                               + c->k96816;
        v559 = c->k96416;
        v560 = c->k96400;
        v561 = (float)(v558 + s->s95888) * 0.5;
        s->s95920 = v561;
        v562 = s->s96240;
        v563 = (float)((float)(c->k96448 * s->s95936)
                     + (float)(c->k96464 * s->s95952))
             + (float)(v561 * c->k96432);
        s->s95936 = v563;
        v564 = v562 + c->k96832;
        s->s101040 = (float)(v560 * v559) * v563;
        v565 = fminf(c->k96848, v564) * v559;
        s->s96224 = v565;
        if ( (float)(v565 - s->s96208) >= 0.0 )
          v566 = c->k96864;
        else
          v566 = c->k96880;
        v567 = v566 + s->s96256;
        v568 = c->k96336;
        v569 = s->s96208;
        if ( v567 > 0.0 )
          v56 = v567;
        v570 = v56;
        v571 = (float)((float)(c->k96336 - v569) * c->k96384) + v569;
        if ( v570 >= -1.0 )
          v58 = fminf(v570, 1.0);
        s->s96240 = v58 * c->k96416;
        if ( (float)(v571 - v569) != 0.0 )
          v568 = v571;
        s->s96192 = v568;
        v572 = v568 + s->s96288;
        v573 = (int)(float)(v572 * -16384.0);
        s->s101056 = RINGR(s->s101024 - (v573) + 1);
        s->s101060 = RINGR(s->s101024 - (v573) + 2);
        v574 = (float)(v572 * 16384.0) - (double)(int)(float)(v572 * 16384.0);
        s->s101064 = v574;
        v575 = (float)((float)((float)(v574 * s->s101060) - (float)(v574 * s->s101056))
                     + s->s101056)
             * s->s96256;
        s->s95968 = v575;
        v576 = s->s96016;
        v577 = (float)((float)((float)(c->k96512 * s->s96000)
                             + (float)(c->k96496 * s->s95984))
                     + (float)(v575 * c->k96480))
             + (float)((float)(v576 * c->k96528) + (float)(c->k96544 * s->s96032));
        s->s96000 = v577;
        v578 = (float)((float)(v576 * c->k96576) + (float)(c->k96592 * s->s96048))
             + (float)(v577 * c->k96560);
        s->s96032 = v578;
        v579 = s->s96064;
        v580 = (float)(v578 * c->k96624) + (float)(v577 * c->k96608);
        v581 = s->s96080;
        s->s96048 = (float)((float)(v580 - v579) * c->k96640) + v579;
        v582 = (float)((float)((float)(v580 - v579) * c->k96672) + (float)(v580 * c->k96656))
             - v581;
        v583 = (float)(v582 * c->k96688) + v581;
        v584 = s->s96096;
        v585 = s->s96272 - 1.0;
        s->s96064 = v583;
        v586 = v582 - v584;
        s->s96096 = v586;
        v587 = s->s96112;
        v588 = (float)(1.0 - (float)(v585 * v585)) * c->k96768;
        s->s96080 = (float)(v586 * c->k96704) + v584;
        v589 = (float)(v587 * c->k96736) + (float)(v586 * c->k96720);
        v590 = c->k96400;
        v591 = (float)((float)((float)(v589 * (float)(v588 + c->k96752)) * c->k96912)
                     - (float)(v590 * s->s95904))
             + s->s95904;
        s->s96304 = (float)((float)((float)(c->k96896 * s->s95920) * v590)
                                       - (float)(v590 * s->s95888))
                               + s->s95888;
        s->s96320 = v591;
        v592 = (s->s101024 - 1) & (c->k101028 - 1);
        s->s101024 = v592;
        RINGI(v592) = s->s101040;
        s->s84672 = s->s96304;
        v593 = s->s96320;
    *o56 = v56; *o58 = v58; *o593 = v593;
}
