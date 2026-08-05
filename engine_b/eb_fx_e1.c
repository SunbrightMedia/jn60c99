/* eb_fx_e1.c -- GENERATED from src/master_render.c:2381-2497. */
#include "eb_fx_e1.h"

#include "juno_tables.h"
#include <math.h>
#include <string.h>
#include <stdbool.h>

#define LODWORD(x) (*(uint32_t *)&(x))

void eb_fx_e1_tick(eb_fx_e1_state *s, const eb_fx_e1_coef *c,
                   float in84624, float in56, float in58,
                   float *o56, float *o58, float *o593)
{
    double v56;
    float v58;
    float v593;
    float v713;
    float v714;
    float v715;
    float v716;
    float v717;
    double v718;
    float v719;
    float v720;
    float v721;
    float v722;
    float v723;
    float v724;
    float v725;
    float v726;
    float v727;
    float v728;
    float v729;
    float v730;
    float v731;
    float v732;
    float v733;
    float v734;
    float v735;
    float v736;
    float v737;
    float v738;
    float v739;
    float v740;
    float v741;
    float v742;
    float v743;
    float v744;
    float v745;
    float v746;
    float v747;
    float v748;
    float v749;
    float v750;
    float v751;
    float v752;
    float v753;
    float v754;
    double v755;
    float v756;
    float v757;
    float v758;
    float v759;
    v56 = in56;   /* IN-OUT: assigned only on one branch below */
    v58 = in58;
    v713 = in84624;
    s->s86272 = s->s86256;
    s->s86256 = s->s86240;
    s->s86240 = s->s86224;
    s->s86224 = s->s86208;
    s->s86208 = s->s86192;
    s->s86192 = s->s86176;
    s->s86176 = s->s86160;
    s->s86672 = s->s86656;
    s->s86704 = s->s86688;
    s->s86736 = s->s86720;
    s->s86768 = s->s86752;
    s->s86800 = s->s86784;
    s->s86096 = v713;
    s->s86112 = v713;
    v714 = c->k86288;
    v715 = (float)(v713 + v713) * c->k86352;
    v716 = (float)(v714 * (float)(v714 * v714)) * c->k86560;
    v717 = (float)((float)(v714 * c->k86528) + c->k86512)
         + (float)((float)(v714 * v714) * c->k86544);
    v718 = v714;
    v719 = s->s86176;
    v720 = v717 + v716;
    v721 = fmax(v718, 0.19);
    v722 = (float)(v721 * v721) * c->k86448;
    v723 = (float)(v721 * c->k86432) + c->k86416;
    s->s86160 = v715;
    v724 = v723 + v722;
    v725 = (float)((float)(v719 * c->k86384) + (float)(v715 * c->k86368))
         + (float)(c->k86400 * s->s86192);
    if ( v724 >= -1.0 )
      v726 = fminf(v724, 1.0);
    else
      v726 = -1.0;
    v727 = s->s86224;
    s->s86176 = v725;
    v728 = v725 - v727;
    v729 = (float)(v726 * c->k86464) + c->k86480;
    s->s86192 = v728;
    v730 = s->s86240;
    v731 = v729 * v728;
    v732 = v728 * c->k86496;
    s->s86208 = v731 + v727;
    v733 = (float)((float)(v720 + c->k86576) * v732) - v730;
    v734 = c->k86320 * v733;
    s->s86224 = (float)(v733 * c->k86592) + v730;
    v735 = s->s86256;
    s->s86656 = v734;
    v736 = c->k86864;
    v737 = s->s86672;
    if ( (float)(v734 * v736) >= -1.0 )
      v738 = fminf(v734 * v736, 1.0);
    else
      v738 = -1.0;
    v739 = (float)((float)(v737 * c->k86832) + (float)(v734 * c->k86848)) * v736;
    s->s86688 = (float)((float)((float)(v738 * v738) * v738) * c->k86896)
                           + (float)(v738 * c->k86880);
    if ( v739 >= -1.0 )
      v740 = fminf(v739, 1.0);
    else
      v740 = -1.0;
    v741 = s->s86672;
    v742 = (float)((float)(v737 + s->s86656) * c->k86816) * c->k86864;
    s->s86720 = (float)((float)((float)(v740 * v740) * v740) * c->k86896)
                           + (float)(v740 * c->k86880);
    if ( v742 >= -1.0 )
      v743 = fminf(v742, 1.0);
    else
      v743 = -1.0;
    v744 = s->s86688;
    v745 = (float)((float)(v741 * c->k86848) + (float)(c->k86832 * s->s86656))
         * c->k86864;
    s->s86752 = (float)((float)((float)(v743 * v743) * v743) * c->k86896)
                           + (float)(v743 * c->k86880);
    if ( v745 >= -1.0 )
      v58 = fminf(v745, 1.0);
    v746 = s->s86768;
    v747 = (float)((float)(v744 + s->s86800) * c->k86912)
         + (float)(c->k86928 * s->s86720);
    v748 = (float)((float)((float)(v58 * v58) * v58) * c->k86896) + (float)(v58 * c->k86880);
    s->s86784 = v748;
    v749 = (float)((float)((float)(s->s86752 + s->s86736) * c->k86944)
                 + (float)((float)(v746 * c->k86928) + v747))
         + (float)((float)(v748 + s->s86704) * c->k86960);
    s->s86240 = v749;
    v750 = (float)((float)(v735 * c->k86624) + (float)(v749 * c->k86608))
         + (float)(c->k86640 * s->s86272);
    s->s86256 = v750;
    v751 = (float)(v750 * c->k86304) * c->k86320;
    s->s86128 = v751;
    s->s86144 = v751;
    s->s87024 = s->s87008;
    s->s87008 = s->s86992;
    s->s86992 = s->s86976;
    s->s86976 = v751;
    v752 = c->k87056;
    v753 = (float)((float)(s->s86992 * c->k87088) + (float)(v751 * c->k87072))
         + (float)(c->k87104 * s->s87008);
    v754 = (float)((float)(s->s86992 * c->k87136) + (float)(v751 * c->k87120))
         + (float)(c->k87152 * s->s87024);
    if ( v752 <= 0.0 )
      v755 = 0.0;
    else
      v755 = v752;
    v756 = v755;
    s->s86992 = v753;
    s->s87008 = v754;
    v757 = (float)((float)(v756 * v753) - (float)(v756 * v751)) + v751;
    if ( v752 < -0.0 )
      v56 = (float)-v752;
    v758 = v56;
    v759 = v751 + (float)((float)(v758 * v754) - (float)(v758 * v751));
    if ( v752 >= 0.0 )
      v759 = v757;
    s->s87040 = v759;
    s->s84672 = v759;
    v593 = s->s87040;
    *o56 = v56; *o58 = v58; *o593 = v593;
}
