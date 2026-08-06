/* eb_delay_t1.c -- GENERATED from src/master_render.c:890-1048, the DELAY
 * TYPE 1 ALGORITHM -- the whole of it, not a pre-stage.
 *
 * :1049-1050 is `}` followed by `else`, so type 1 does NOT fall through to
 * the shared core at LABEL_69; that core serves type 0 and (via goto) types
 * >= 6. An earlier revision of this comment claimed the opposite and called
 * v176/v177 dead. They are the arm OUTPUTS. MEASURED: perturbing them is
 * caught by 10 of the 33 scenarios.
 *
 * v56/v58 are returned too. A POISON TEST measured them dead on this path
 * in all 33 scenarios -- writing 98765.0 into the caller's copies changed
 * no sample -- because the chorus consumes them only in sub-modes these
 * patches do not select. They are returned anyway: the port computes them
 * here and the other three arms return them, and dropping a value because
 * todays scenario set cannot tell the difference is how a gate quietly
 * becomes the specification.
 */
#include "eb_delay_t1.h"
#include "eb_ring_probe.h"

#include "juno_tables.h"
#include <math.h>
#include <string.h>

#define LODWORD(x)  (*(uint32_t *)&(x))
#define RINGR(i)    (s->ring[EB_RP_R(EB_RP_T1, c->k6395252, (i), s->s6395248)])
#define RINGI(i)    (s->ring[(i)])

void eb_dly1_tick(eb_dly1_state *s, const eb_dly1_coef *c,
                  float in36, float in38, float k5,
                  float *o176, float *o177, float *o56, float *o58)
{
    float v5;
    float v36;
    float v38;
    double v56;
    float v58;
    float v176;
    float v177;
    float v419;
    float v420;
    float v421;
    float v422;
    float v423;
    float v424;
    float v425;
    float v426;
    float v427;
    float v428;
    float v429;
    float v430;
    float v431;
    float v432;
    float v433;
    double v434;
    float v435;
    float v436;
    float v437;
    double v438;
    int v439;
    float v440;
    float v441;
    int v442;
    float v443;
    float v444;
    float v445;
    float v446;
    float v447;
    float v448;
    float v449;
    float v450;
    float v451;
    float v452;
    float v453;
    float v454;
    float v455;
    float v456;
    float v457;
    float v458;
    float v459;
    float v460;
    float v461;
    float v462;
    float v463;
    float v464;
    float v465;
    float v466;
    float v467;
    float v468;
    float v469;
    float v470;
    float v471;
    int v472;
    float v473;
    (void)k5;
    if ( s->s11022348 != 1 )
    {
      s->s4297504 = 0;
      s->s4297520 = 0;
      s->s4297536 = 0;
    }
    s->s11022348 = 1;
    s->s4297344 = s->s4297328;
    s->s4297328 = s->s4297312;
    s->s4297312 = s->s4297296;
    s->s4297296 = s->s4297280;
    s->s4297280 = s->s4297264;
    s->s4297264 = s->s4297248;
    s->s4297248 = s->s4297232;
    s->s4297424 = s->s4297408;
    s->s4297408 = s->s4297392;
    s->s4297392 = s->s4297376;
    s->s4297376 = s->s4297360;
    s->s4297488 = s->s4297472;
    s->s4297472 = s->s4297456;
    s->s4297456 = s->s4297440;
    s->s4297536 = s->s4297520;
    s->s4297520 = s->s4297504;
    s->s4297200 = in36;
    s->s4297216 = in38;
    v419 = (float)(in38 + in36) * 0.5;
    s->s4297360 = v419;
    v420 = (float)((float)((float)((float)(c->k4297616 * s->s4297376)
                                 + (float)(v419 * c->k4297600))
                         + (float)(c->k4297632 * s->s4297392))
                 + (float)(c->k4297648 * s->s4297408))
         + (float)(c->k4297664 * s->s4297424);
    s->s4297392 = v420;
    s->s4297232 = (float)((float)((float)(v419
                                                     - (float)(s->s4297248 * c->k4297712))
                                             - s->s4297264)
                                     * c->k4297696)
                             + s->s4297248;
    v421 = (float)(c->k4297696 * s->s4297248) + s->s4297264;
    s->s4297248 = v421;
    v422 = c->k4298016 + s->s4297520;
    s->s6395264 = (float)((float)((float)((float)((float)((float)((float)(1.0 - c->k4297680)
                                                                             * v421)
                                                                     + (float)(c->k4297680 * v420))
                                                             * c->k4297728)
                                                     + (float)((float)(1.0 - c->k4297728) * v419))
                                             * c->k4297824)
                                     + (float)(c->k4297808 * s->s4297328))
                             * c->k4297840;
    v423 = fminf(c->k4298032, v422) * k5;
    s->s4297504 = v423;
    if ( (float)(v423 - s->s4297488) >= 0.0 )
      v424 = c->k4298048;
    else
      v424 = c->k4298064;
    v425 = c->k4297584;
    v426 = s->s4297536 + v424;
    s->s4297440 = v425;
    v427 = s->s4297488;
    v428 = s->s4297472;
    v429 = v425 - v427;
    v430 = c->k4298080;
    if ( (float)(v425 - s->s4297456) != 0.0 )
      v428 = v425 - v427;
    s->s4297456 = v428;
    v431 = fabs(v428) * v430;
    v432 = v427 + v431;
    v433 = fmaxf(v427 - v431, v425);
    if ( v429 > 0.0 )
      v433 = fminf(v432, v425);
    s->s4297472 = v433;
    v56 = 0.0;
    if ( v426 <= 0.0 )
      v434 = 0.0;
    else
      v434 = v426;
    v58 = -1.0;
    v435 = v434;
    if ( v435 >= -1.0 )
      v436 = fminf(v435, 1.0);
    else
      v436 = -1.0;
    s->s4297520 = v436 * c->k4297840;
    v437 = v433 * c->k4297792;
    if ( v437 <= 0.00012207031 )
      v438 = 0.0001220703125;
    else
      v438 = v437;
    v439 = (int)(float)(v433 * -16384.0);
    s->s6395280 = RINGR(s->s6395248 - (v439) + 1);
    s->s6395284 = RINGR(s->s6395248 - (v439) + 2);
    v440 = v438;
    v441 = (float)(v433 * 16384.0) - (double)(int)(float)(v433 * 16384.0);
    v442 = (int)(float)(v440 * -16384.0);
    s->s6395288 = v441;
    v443 = s->s6395280;
    s->s6395296 = RINGR(s->s6395248 - (v442) + 1);
    s->s6395300 = RINGR(s->s6395248 - (v442) + 2);
    v444 = (float)(v440 * 16384.0) - (double)(int)(float)(v440 * 16384.0);
    s->s6395304 = v444;
    v445 = s->s4297296;
    v446 = (float)((float)((float)(v441 * s->s6395284) - (float)(v441 * v443)) + v443)
         * s->s4297536;
    s->s4297264 = v446;
    v447 = s->s6395296;
    v448 = s->s4297312;
    v449 = c->k4297920 * (float)(v446 - v445);
    v450 = (float)((float)(v446 - v445) * c->k4297904) + v445;
    v451 = c->k4297936 * v450;
    s->s4297280 = v450;
    v452 = s->s4297344;
    v453 = (float)(v449 - v451) - v448;
    v454 = c->k4297968 * v453;
    v455 = (float)(v453 * c->k4297952) + v448;
    v456 = c->k4297984;
    s->s4297296 = v455;
    v457 = (float)((float)(v456 * v455) - v454) - v452;
    s->s4297312 = v457;
    s->s4297328 = (float)(v457 * c->k4298000) + v452;
    v458 = c->k4297856;
    v459 = s->s4297264;
    v460 = (float)(1.0 - v458) * v459;
    v461 = (float)((float)(v444 * s->s6395300) - (float)(v444 * v447)) + v447;
    v462 = s->s4297216;
    v463 = c->k4297824;
    v464 = (float)((float)(v461 * s->s4297536) * v458) - (float)(c->k4297872 * v460);
    v465 = c->k4297760;
    v466 = v464 + v460;
    v467 = c->k4297888;
    v468 = (float)(v459 * v465) * v467;
    v469 = v466 * v465;
    v470 = c->k4297744;
    v471 = (float)((float)(1.0 - c->k4297872) * v462) * v470;
    s->s4297552 = (float)((float)(v463
                                             * (float)((float)((float)(c->k4297872 * v462)
                                                             + s->s4297200)
                                                     * v470))
                                     + (float)((float)(1.0 - v463) * s->s4297200))
                             + v468;
    s->s4297568 = (float)((float)(v463 * v471) + (float)((float)(1.0 - v463) * v462))
                             + (float)(v469 * v467);
    v472 = (s->s6395248 - 1) & (c->k6395252 - 1);
    s->s6395248 = v472;
    RINGI(v472) = s->s6395264;
    v473 = c->k101744;
    v176 = v473 * s->s4297568;
    v177 = v473 * s->s4297552;
    *o176 = v176; *o177 = v177; *o56 = v56; *o58 = v58;
}
