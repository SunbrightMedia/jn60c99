/* eb_fx_e0.c -- GENERATED from src/master_render.c:2504-2626. */
#include "eb_fx_e0.h"

#include "juno_tables.h"
#include <math.h>
#include <string.h>
#include <stdbool.h>

#define LODWORD(x) (*(uint32_t *)&(x))

void eb_fx_e0_tick(eb_fx_e0_state *s, const eb_fx_e0_coef *c,
                 float in84624, float in56, float in58, float *o56, float *o58, float *o593)
{
    double v56;
    float v58;
    float v593;
    float v664;
    float v665;
    float v666;
    float v667;
    float v668;
    float v669;
    float v670;
    float v671;
    float v672;
    float v673;
    float v674;
    float v675;
    float v676;
    float v677;
    float v678;
    float v679;
    float v680;
    float v681;
    float v682;
    float v683;
    float v684;
    float v685;
    float v686;
    float v687;
    float v688;
    float v689;
    float v690;
    float v691;
    float v692;
    float v693;
    float v694;
    float v695;
    float v696;
    float v697;
    float v698;
    float v699;
    float v700;
    float v701;
    float v702;
    float v703;
    float v704;
    float v705;
    float v706;
    float v707;
    double v708;
    float v709;
    float v710;
    float v711;
    float v712;
    /* IN-OUT: the port assigns these only on one branch. */
    v56 = in56;
    v58 = in58;
      v664 = in84624;
      s->s85088 = s->s85072;
      s->s85072 = s->s85056;
      s->s85056 = s->s85040;
      s->s85040 = s->s85024;
      s->s85024 = s->s85008;
      s->s85008 = s->s84992;
      s->s84992 = s->s84976;
      s->s84976 = s->s84960;
      s->s85120 = s->s85104;
      s->s85600 = s->s85584;
      s->s85632 = s->s85616;
      s->s85664 = s->s85648;
      s->s85696 = s->s85680;
      s->s85728 = s->s85712;
      s->s84896 = v664;
      s->s84912 = v664;
      v665 = c->k85136;
      v666 = c->k85360;
      v667 = s->s84976;
      v668 = (float)(v664 + v664) * c->k85200;
      v669 = (float)(v665 * c->k85328) + c->k85312;
      v670 = fminf(c->k85568 + s->s85120, c->k85184);
      v671 = (float)(v665 * v665) * v665;
      v672 = (float)(v665 * v665) * c->k85344;
      s->s84960 = v668;
      v673 = v667 * c->k85232;
      v674 = v668 * c->k85216;
      v675 = s->s84992;
      v676 = s->s85008;
      s->s85104 = v670;
      v677 = v676 * c->k85296;
      v678 = (float)(v673 + v674) + (float)(v675 * c->k85248);
      s->s84976 = v678;
      v679 = (float)((float)(v675 * c->k85280) + (float)(v678 * c->k85264)) + v677;
      s->s84992 = v679;
      v680 = s->s85040;
      v681 = c->k85168;
      v682 = (float)((float)((float)((float)((float)(v666 * v671) + (float)(v669 + v672)) + c->k85376)
                           * v679)
                   + (float)(v678 * c->k85392))
           - v680;
      s->s85008 = v682;
      s->s85024 = (float)(v682 * c->k85408) + v680;
      v683 = s->s84976;
      v684 = (float)((float)(v670 * c->k85424) * 0.125) + (float)(v681 * v682);
      s->s85584 = v684;
      v685 = c->k85792;
      v686 = s->s85600;
      if ( (float)(v684 * v685) >= -1.0 )
        v687 = fminf(v684 * v685, 1.0);
      else
        v687 = -1.0;
      v688 = (float)((float)(v684 * c->k85776) + (float)(v686 * c->k85760)) * v685;
      s->s85616 = (float)((float)((float)(v687 * v687) * v687) * c->k85824)
                             + (float)(v687 * c->k85808);
      if ( v688 >= -1.0 )
        v689 = fminf(v688, 1.0);
      else
        v689 = -1.0;
      v690 = s->s85600;
      v691 = (float)((float)(v686 + s->s85584) * c->k85744) * c->k85792;
      s->s85648 = (float)((float)((float)(v689 * v689) * v689) * c->k85824)
                             + (float)(v689 * c->k85808);
      if ( v691 >= -1.0 )
        v692 = fminf(v691, 1.0);
      else
        v692 = -1.0;
      v693 = s->s85616;
      v694 = (float)((float)(v690 * c->k85776) + (float)(c->k85760 * s->s85584))
           * c->k85792;
      s->s85680 = (float)((float)((float)(v692 * v692) * v692) * c->k85824)
                             + (float)(v692 * c->k85808);
      if ( v694 >= -1.0 )
        v58 = fminf(v694, 1.0);
      v695 = s->s85696;
      v696 = (float)((float)(v693 + s->s85728) * c->k85840)
           + (float)(c->k85856 * s->s85648);
      v697 = (float)((float)((float)(v58 * v58) * v58) * c->k85824) + (float)(v58 * c->k85808);
      s->s85712 = v697;
      v698 = (float)((float)(s->s85680 + s->s85664) * c->k85872)
           + (float)((float)(v695 * c->k85856) + v696);
      v699 = s->s85056;
      v700 = (float)((float)(v698 + (float)((float)(v697 + s->s85632) * c->k85888))
                   * c->k85440)
           + (float)(v683 * c->k85456);
      s->s85040 = v700;
      v701 = s->s85072;
      v702 = (float)((float)(v699 * c->k85488) + (float)(v700 * c->k85472))
           + (float)(v701 * c->k85504);
      s->s85056 = v702;
      v703 = (float)((float)(v701 * c->k85536) + (float)(v702 * c->k85520))
           + (float)(c->k85552 * s->s85088);
      s->s85072 = v703;
      v704 = (float)(v703 * c->k85152) * c->k85168;
      s->s84928 = v704;
      s->s84944 = v704;
      s->s85952 = s->s85936;
      s->s85936 = s->s85920;
      s->s85920 = s->s85904;
      s->s85904 = v704;
      v705 = c->k85984;
      v706 = (float)((float)(s->s85920 * c->k86016) + (float)(v704 * c->k86000))
           + (float)(c->k86032 * s->s85936);
      v707 = (float)((float)(s->s85920 * c->k86064) + (float)(v704 * c->k86048))
           + (float)(c->k86080 * s->s85952);
      if ( v705 <= 0.0 )
        v708 = 0.0;
      else
        v708 = v705;
      v709 = v708;
      s->s85920 = v706;
      s->s85936 = v707;
      v710 = (float)((float)(v709 * v706) - (float)(v709 * v704)) + v704;
      if ( v705 < -0.0 )
        v56 = (float)-v705;
      v711 = v56;
      v712 = v704 + (float)((float)(v711 * v707) - (float)(v711 * v704));
      if ( v705 >= 0.0 )
        v712 = v710;
      s->s85968 = v712;
      s->s84672 = v712;
      v593 = s->s85968;
    *o56 = v56; *o58 = v58; *o593 = v593;
}
