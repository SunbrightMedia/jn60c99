/* IS THE DECOMPOSITION EVEN TRUE?
 *
 * The module assumes  port_1x(t) = naive_1x(t) + SUM of compact corrections,
 * one per edge. Every refinement so far has assumed that and tuned the
 * correction. This prints the DIFFERENCE directly: if it is localised at the
 * edges the premise holds and the table is wrong; if it is spread over the
 * whole period the premise is wrong and no table fixes it.
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include "eb_fork_config.h"
#include "eb_dco.h"
#include "eb_decim.h"
#include "c6_realcoefs.h"
static const int TAP[32] = {3,2,0,1,7,6,5,4,11,10,9,8,15,14,13,12,
                            12,13,14,15,8,9,10,11,4,5,6,7,1,0,2,3};
int main(int argc, char **argv)
{
    float inc4 = argc > 1 ? (float)atof(argv[1]) : 0.005f;
    eb_dco_coef c; eb_dco_state s; float hist[64]; int hp = 0, i;
    memset(&s,0,sizeof s); memset(&c,0,sizeof c); memset(hist,0,sizeof hist);
    c.inc=inc4; c.g=0.00390625f/inc4;
    c.pw=RC_pw; c.pwm1=c.pw-1.0f; c.pwp1=c.pw+1.0f;
    c.rm1=1.0f/c.pwm1; c.rp1=1.0f/c.pwp1;
    c.lvl_saw=0.0f; c.lvl_pulse=1.0f; c.lvl_sub=0.0f;   /* PULSE ALONE */
    c.gn_saw=RC_gn_saw; c.gn_pulse=RC_gn_pulse; c.gn_sub=RC_gn_sub;
    c.amp_saw=RC_amp_saw; c.amp_pulse=RC_amp_pulse; c.amp_sub=RC_amp_sub;
    c.sat_in=RC_sat_in; c.subthr=RC_subthr;
    c.k3=RC_k3;c.k5=RC_k5;c.k7=RC_k7;c.k9=RC_k9;c.k11=RC_k11;
    {float x=c.sat_in,x2=x*x,x3=x*x2,x5=x3*x2,x7=x5*x2,x9=x7*x2,x11=x9*x2;
     c.sat_hi=x+x3*c.k3+x5*c.k5+x7*c.k7+x9*c.k9+x11*c.k11;}
    {float x=-c.sat_in,x2=x*x,x3=x*x2,x5=x3*x2,x7=x5*x2,x9=x7*x2,x11=x9*x2;
     c.sat_lo=x+x3*c.k3+x5*c.k5+x7*c.k7+x9*c.k9+x11*c.k11;}
    eb_dco_set_edge_thresholds(&c);
    printf("PULSE ARM ALONE, f0 %.0f Hz.  |port_1x - naive_1x| per sample:\n",
           inc4/2*4*44100.0);
    for (i = 0; i < 260; ++i) {
        float q[4], t, naive, y; int d; double acc = 0.0;
        q[0]=eb_dco_step(&s,&c); q[1]=eb_dco_step(&s,&c);
        q[2]=eb_dco_step(&s,&c); q[3]=eb_dco_step(&s,&c);
        hist[hp&63]=q[0]; hist[(hp+1)&63]=q[1];
        hist[(hp+2)&63]=q[2]; hist[(hp+3)&63]=q[3]; hp+=4;
        for (d=0; d<32; ++d) acc += (double)hist[(hp-1-d)&63]*RC_fir[TAP[d]];
        y = (float)acc;
        t = c.pw + s.phase;
        naive = (t<0.0f ? -c.gn_pulse : c.gn_pulse) * c.sat_hi;
        if (i >= 120 && i < 180)
            printf("  %3d  port %+8.5f  naive %+8.5f  diff %+9.6f\n",
                   i, y, naive, y - naive);
    }
    return 0;
}
