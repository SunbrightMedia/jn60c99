/* eb_delay_t23.c -- GENERATED SKELETON, see the .c header note */
#include "eb_delay_t23.h"
#include "juno_dsp.h"
#include "juno_tables.h"
#include <math.h>
#include <string.h>

#define LODWORD(x)  (*(uint32_t *)&(x))
#define RINGR(i)    (s->ring[(c->k6429412 - 1) & (int32_t)(i)])
#define RINGI(i)    (s->ring[(i)])

void eb_dly23_tick(eb_dly23_state *s, const eb_dly23_coef *c,
                   float in36, float in38, float k5,
                   float *o176, float *o177, float *o56, float *o58)
{
    float v36;
    float v38;
    double v56;
    float v58;
    float v176;
    float v177;
    int v253;
    float v254;
    float v255;
    float v256;
    float v257;
    float v258;
    float v259;
    float v260;
    float v261;
    float v262;
    float v263;
    float v264;
    float v265;
    float v266;
    float v267;
    float v268;
    float v269;
    float v270;
    float v271;
    float v272;
    float v273;
    float v274;
    float v275;
    float v276;
    float v277;
    float v278;
    float v279;
    float v280;
    float v281;
    float v282;
    float v283;
    float v284;
    float v285;
    float v286;
    float v287;
    double v288;
    float v289;
    float v290;
    float v291;
    float v292;
    float v293;
    int v294;
    float v295;
    float v296;
    float v297;
    float v298;
    int v299;
    float v300;
    float v301;
    float v302;
    float v303;
    float v304;
    float v305;
    float v306;
    float v307;
    float v308;
    float v309;
    float v310;
    float v311;
    float v312;
    float v313;
    float v314;
    float v315;
    float v316;
    float v317;
    float v318;
    float v319;
    float v320;
    int v321;
    float v322;
    (void)k5;
    {
      if ( s->s11022348 != 2 )
      {
        s->s6395984 = 0;
        s->s6396000 = 0;
        s->s6396016 = 0;
      }
      s->s11022348 = 2;
      v253 = c->k6395328;
      s->s6395344 = c->k6395312;
      s->s6395360 = v253;
      v254 = juno_pitch_poly((double)(float)( c->k6395312 + c->k6395408 ));
      v255 = fmaxf(fminf(v254, 512.0), -512.0);
      s->s6395376 = v255;
      v256 = s->s6395600;
      v257 = s->s6395360;
      s->s6395616 = LODWORD(v256);
      v258 = v255 * c->k6395648;
      if ( v258 < 4.0 )
      {
        if ( v258 >= 2.0 )
          v258 = v258 + -2.0;
      }
      else
      {
        v258 = v258 + -4.0;
      }
      if ( v258 == 0.0 )
        v258 = c->k6395664;
      *(float *)&v256 = *(float *)&v256 + v258;
      if ( *(float *)&v256 > 1.0 )
        *(float *)&v256 = fmodf(*(float *)&v256 + 1.0, 2.0) - 1.0;
      v259 = juno_triangle(v256);
      s->s6395632 = v259;
      s->s6395600 = (float)(*(float *)&v256 * v257) + (float)(v257 - 1.0);
      v260 = (float)(v259 * c->k6395696) + c->k6395712;
      s->s6395680 = v260;
      v261 = 1.0 - v260;
      s->s6395856 = s->s6395840;
      s->s6395840 = s->s6395824;
      s->s6395824 = s->s6395808;
      s->s6395808 = s->s6395792;
      s->s6395792 = s->s6395776;
      s->s6395936 = s->s6395920;
      s->s6395920 = s->s6395904;
      s->s6395904 = s->s6395888;
      s->s6395888 = s->s6395872;
      s->s6395968 = s->s6395952;
      s->s6396016 = s->s6396000;
      s->s6396000 = s->s6395984;
      s->s6395760 = v260;
      v262 = c->k6396160;
      s->s6395728 = in36;
      s->s6395744 = in38;
      v263 = c->k6396144;
      v264 = (float)(in38 + in36) * 0.5;
      v265 = (float)((float)((float)(v260 * 0.5) + v262) * (float)((float)(v260 * 0.5) + v262)) * v263;
      v266 = (float)((float)((float)((float)((float)(1.0 - v260) * 0.5) + v262)
                           * (float)((float)((float)(1.0 - v260) * 0.5) + v262))
                   * v263)
           - (float)(v263 * (float)(1.0 - v260));
      v267 = c->k6396528;
      v268 = v260 + (float)(v265 - (float)(c->k6396144 * v260));
      v269 = c->k6396544;
      v270 = (float)((float)(c->k6396176 * (float)(v261 + v266)) * v267) + v269;
      s->s6396032 = (float)((float)(c->k6396176 * v268) * v267) + v269;
      s->s6396048 = v270;
      s->s6395872 = v264;
      v271 = (float)((float)((float)((float)(c->k6396208 * s->s6395888)
                                   + (float)(v264 * c->k6396192))
                           + (float)(c->k6396224 * s->s6395904))
                   + (float)(c->k6396240 * s->s6395920))
           + (float)(c->k6396256 * s->s6395936);
      s->s6395904 = v271;
      s->s6395776 = (float)((float)((float)(v264
                                                       - (float)(s->s6395792 * c->k6396304))
                                               - s->s6395808)
                                       * c->k6396288)
                               + s->s6395792;
      v272 = (float)(s->s6395792 * c->k6396288) + s->s6395808;
      s->s6395792 = v272;
      v273 = c->k6396272;
      v274 = c->k6396416;
      v275 = (float)(1.0 - v273) * v272;
      v276 = s->s6395824;
      v277 = (float)((float)(v275 + (float)(v273 * v271)) * c->k6396320)
           + (float)((float)(1.0 - c->k6396320) * v264);
      v278 = c->k6396432;
      v279 = (float)((float)(v277 - v276) * c->k6396336) + v276;
      v280 = v277
           + (float)((float)(c->k6396352 * (float)(v277 - v276)) - (float)(c->k6396352 * v277));
      s->s6395808 = v279;
      v281 = c->k6396448;
      v282 = c->k6396576 + s->s6396000;
      s->s6429424 = v281 * (float)((float)(v274 * s->s6395840) + (float)(v278 * v280));
      v283 = fminf(c->k6396592, v282) * v281;
      s->s6395984 = v283;
      if ( (float)(v283 - s->s6395968) >= 0.0 )
        v284 = c->k6396608;
      else
        v284 = c->k6396624;
      v285 = v284 + s->s6396016;
      v286 = c->k6396128;
      v56 = 0.0;
      v287 = s->s6395968;
      if ( v285 <= 0.0 )
        v288 = 0.0;
      else
        v288 = v285;
      v58 = -1.0;
      v289 = v288;
      v290 = (float)((float)(c->k6396128 - v287) * c->k6396400) + v287;
      if ( v289 >= -1.0 )
        v291 = fminf(v289, 1.0);
      else
        v291 = -1.0;
      s->s6396000 = v291 * c->k6396448;
      if ( (float)(v290 - v287) != 0.0 )
        v286 = v290;
      v292 = v286;
      s->s6395952 = v286;
      v293 = v286 + s->s6396032;
      v294 = (int)(float)(v293 * -16384.0);
      s->s6429440 = RINGR(s->s6429408 - v294 + 1);
      s->s6429444 = RINGR(s->s6429408 - v294 + 2);
      v295 = (float)(v293 * 16384.0) - (double)(int)(float)(v293 * 16384.0);
      s->s6429448 = v295;
      v296 = s->s6429440;
      v297 = s->s6396016;
      v298 = v292 + s->s6396048;
      v299 = (int)(float)(v298 * -16384.0);
      s->s6429456 = RINGR(s->s6429408 - v299 + 1);
      s->s6429460 = RINGR(s->s6429408 - v299 + 2);
      v300 = (float)(v298 * 16384.0) - (double)(int)(float)(v298 * 16384.0);
      s->s6429464 = v300;
      v301 = s->s6395856;
      v302 = (float)((float)(v295 * s->s6429444) - (float)(v295 * v296)) + v296;
      v303 = s->s6429456;
      v304 = v302 * v297;
      s->s6395824 = v304 - v301;
      s->s6395840 = (float)((float)(v304 - v301) * c->k6396560) + v301;
      v305 = c->k6396480;
      v306 = c->k6396464;
      v307 = s->s6395744;
      v308 = (float)(1.0 - v306) * v304;
      v309 = (float)((float)((float)(v300 * s->s6429460) - (float)(v300 * v303)) + v303) * v297;
      v310 = s->s6395728;
      v311 = c->k6396384;
      v312 = v304 * v311;
      v313 = (float)((float)((float)(v306 * v309) - (float)(v305 * v308)) + v308) * v311;
      v314 = c->k6396512;
      v315 = v314 * v312;
      s->s6396064 = v314 * v313;
      s->s6396080 = v314 * v312;
      v316 = c->k6396368;
      v317 = c->k6396432;
      v318 = (float)((float)(v305 * v307) + v310) * v316;
      v319 = (float)((float)(1.0 - v305) * v307) * v316;
      v320 = c->k6396496;
      s->s6396096 = (float)((float)(v317 * (float)(v318 * v320)) + (float)((float)(1.0 - v317) * v310))
                               + s->s6396064;
      s->s6396112 = (float)((float)(v317 * (float)(v319 * v320)) + (float)((float)(1.0 - v317) * v307))
                               + v315;
      v321 = (s->s6429408 - 1) & (c->k6429412 - 1);
      s->s6429408 = v321;
      RINGI(v321) = s->s6429424;
      v322 = c->k101744;
      v176 = v322 * s->s6396112;
      v177 = v322 * s->s6396096;
    }

    *o176 = v176; *o177 = v177; *o56 = v56; *o58 = v58;
}
