/* eb_dly_t4.c -- GENERATED from src/master_render.c:1871-2074. */
#include "eb_dly_t4.h"
#include "eb_dsp.h"
#include "juno_tables.h"
#include <math.h>
#include <string.h>
#include <stdbool.h>

#define LODWORD(x) (*(uint32_t *)&(x))
#define RINGR0(i)  (s->ring0[(c->k6463716 - 1) & (int32_t)(i)])
#define RINGI0(i)  (s->ring0[(i)])
#define RINGR1(i)  (s->ring1[(c->k6496500 - 1) & (int32_t)(i)])
#define RINGI1(i)  (s->ring1[(i)])

void eb_dly_t4_tick(eb_dly_t4_state *s, const eb_dly_t4_coef *c,
                 float in36, float in38, float k5, float *o176, float *o177, float *o56, float *o58)
{
    float v36;
    float v38;
    double v56;
    float v58;
    float v176;
    float v177;
    float v178;
    float v179;
    float v180;
    float v181;
    float v182;
    float v183;
    float v184;
    float v185;
    float v186;
    float v187;
    float v188;
    float v189;
    float v190;
    float v191;
    float v192;
    float v193;
    float v194;
    float v195;
    float v196;
    float v197;
    float v198;
    float v199;
    float v200;
    float v201;
    float v202;
    float v203;
    float v204;
    float v205;
    float v206;
    float v207;
    float v208;
    float v209;
    float v210;
    float v211;
    float v212;
    float v213;
    float v214;
    float v215;
    float v216;
    float v217;
    float v218;
    float v219;
    float v220;
    float v221;
    float v222;
    float v223;
    double v224;
    float v225;
    float v226;
    float v227;
    float v228;
    float v229;
    int v230;
    float v231;
    float v232;
    float v233;
    float v234;
    int v235;
    float v236;
    float v237;
    float v238;
    float v239;
    float v240;
    float v241;
    float v242;
    float v243;
    float v244;
    float v245;
    float v246;
    float v247;
    float v248;
    float v249;
    int v250;
    int v251;
    float v252;
    (void)k5;
      if ( s->s11022348 != 4 )
      {
        s->s6430320 = 0;
        s->s6430336 = 0;
        s->s6430352 = 0;
      }
      s->s11022348 = 4;
      v178 = c->k6429488;
      s->s6429504 = c->k6429472;
      s->s6429520 = v178;
      v179 = eb_pitch_poly((double)(float)( c->k6429472 + c->k6429568 ));
      s->s6429536 = fmaxf(fminf(v179, 512.0), -512.0);
      v180 = s->s6429520;
      s->s6429776 = s->s6429760;
      { float _inc3 = (float)(s->s6429536 * c->k6429808);
    if ( _inc3 < 4.0 ) { if ( _inc3 >= 2.0 ) _inc3 = _inc3 + -2.0; } else _inc3 = _inc3 + -4.0;
    if ( _inc3 == 0.0 ) _inc3 = c->k6429824;
    v181 = eb_wrap_hi((float)(s->s6429760 + _inc3)); }
      v182 = *(float *)&v181;
      v183 = eb_triangle_wrap(v181);
      s->s6429792 = v183;
      s->s6429760 = (float)(v182 * v180) + (float)(v180 - 1.0);
      v184 = (float)(v183 * c->k6429856) + c->k6429872;
      s->s6429840 = v184;
      s->s6430016 = s->s6430000;
      s->s6430000 = s->s6429984;
      s->s6429984 = s->s6429968;
      s->s6429968 = s->s6429952;
      s->s6429952 = s->s6429936;
      s->s6430112 = s->s6430096;
      s->s6430096 = s->s6430080;
      s->s6430080 = s->s6430064;
      s->s6430064 = s->s6430048;
      s->s6430048 = s->s6430032;
      s->s6430192 = s->s6430176;
      s->s6430176 = s->s6430160;
      s->s6430160 = s->s6430144;
      s->s6430144 = s->s6430128;
      s->s6430272 = s->s6430256;
      s->s6430256 = s->s6430240;
      s->s6430240 = s->s6430224;
      s->s6430224 = s->s6430208;
      s->s6430304 = s->s6430288;
      s->s6430352 = s->s6430336;
      s->s6430336 = s->s6430320;
      s->s6429920 = v184;
      v185 = c->k6430496;
      v186 = (float)(v184 * c->k6430800) + c->k6430816;
      s->s6429888 = in36;
      s->s6429904 = in38;
      v187 = c->k6430480;
      v188 = v184
           + (float)((float)((float)((float)((float)(v184 * 0.5) + v185) * (float)((float)(v184 * 0.5) + v185)) * v187)
                   - (float)(v187 * v184));
      v189 = v186
           + (float)((float)((float)((float)((float)(v186 * 0.5) + v185) * (float)((float)(v186 * 0.5) + v185)) * v187)
                   - (float)(v187 * v186));
      v190 = c->k6430832;
      v191 = c->k6430848;
      v192 = c->k6430512 * v189;
      s->s6430368 = (float)((float)(c->k6430512 * v188) * v190) + v191;
      s->s6430384 = (float)(v192 * v190) + v191;
      s->s6430128 = in36;
      v193 = (float)((float)((float)((float)(in36 * c->k6430528)
                                   + (float)(c->k6430544 * s->s6430144))
                           + (float)(c->k6430560 * s->s6430160))
                   + (float)(s->s6430176 * c->k6430576))
           + (float)(c->k6430592 * s->s6430192);
      s->s6430160 = v193;
      s->s6429936 = (float)((float)((float)(in36
                                                       - (float)(s->s6429952 * c->k6430640))
                                               - s->s6429968)
                                       * c->k6430624)
                               + s->s6429952;
      v194 = (float)(s->s6429952 * c->k6430624) + s->s6429968;
      s->s6429952 = v194;
      v195 = c->k6430608;
      v196 = (float)(1.0 - v195) * v194;
      v197 = s->s6429984;
      v198 = (float)((float)(v196 + (float)(v195 * v193)) * c->k6430656)
           + (float)((float)(1.0 - c->k6430656) * in36);
      v199 = c->k6430768;
      v200 = (float)((float)(v198 - v197) * c->k6430672) + v197;
      v201 = v198
           + (float)((float)(c->k6430688 * (float)(v198 - v197)) - (float)(c->k6430688 * v198));
      v202 = c->k6430752;
      s->s6429968 = v200;
      s->s6496512 = (float)((float)(v202 * s->s6430000) + (float)(v199 * v201))
                               * c->k6430784;
      v203 = s->s6429904;
      s->s6430208 = v203;
      v204 = (float)((float)((float)((float)(s->s6430224 * c->k6430544)
                                   + (float)(v203 * c->k6430528))
                           + (float)(c->k6430560 * s->s6430240))
                   + (float)(s->s6430256 * c->k6430576))
           + (float)(s->s6430272 * c->k6430592);
      s->s6430240 = v204;
      s->s6430032 = (float)((float)((float)(v203
                                                       - (float)(s->s6430048 * c->k6430640))
                                               - s->s6430064)
                                       * c->k6430624)
                               + s->s6430048;
      v205 = (float)(s->s6430048 * c->k6430624) + s->s6430064;
      s->s6430048 = v205;
      v206 = c->k6430608;
      v207 = c->k6430656;
      v208 = (float)(1.0 - v206) * v205;
      v209 = s->s6430080;
      v210 = v208 + (float)(v206 * v204);
      v211 = (float)(1.0 - v207) * v203;
      v212 = c->k6430752;
      v213 = (float)(v210 * v207) + v211;
      v214 = c->k6430768;
      v215 = (float)((float)(v213 - v209) * c->k6430672) + v209;
      v216 = v213
           + (float)((float)(c->k6430688 * (float)(v213 - v209)) - (float)(c->k6430688 * v213));
      s->s6430064 = v215;
      v217 = c->k6430784;
      v218 = c->k6430880 + s->s6430336;
      s->s6496544 = v217 * (float)((float)(v212 * s->s6430096) + (float)(v214 * v216));
      v219 = fminf(c->k6430896, v218) * v217;
      s->s6430320 = v219;
      v220 = s->s6430352;
      if ( (float)(v219 - s->s6430304) >= 0.0 )
        v221 = v220 + c->k6430912;
      else
        v221 = v220 + c->k6430928;
      v222 = c->k6430464;
      v56 = 0.0;
      v223 = s->s6430304;
      if ( v221 <= 0.0 )
        v224 = 0.0;
      else
        v224 = v221;
      v58 = -1.0;
      v225 = v224;
      v226 = (float)((float)(c->k6430464 - v223) * c->k6430736) + v223;
      if ( v225 >= -1.0 )
        v227 = fminf(v225, 1.0);
      else
        v227 = -1.0;
      s->s6430336 = v227 * c->k6430784;
      if ( (float)(v226 - v223) != 0.0 )
        v222 = v226;
      v228 = v222;
      s->s6430288 = v222;
      v229 = v222 + s->s6430368;
      v230 = (int)(float)(v229 * -16384.0);
      s->s6496528 = RINGR0(s->s6463712 - (v230) + 1);
      s->s6496532 = RINGR0(s->s6463712 - (v230) + 2);
      v231 = (float)(v229 * 16384.0) - (double)(int)(float)(v229 * 16384.0);
      s->s6496536 = v231;
      v232 = s->s6496528;
      v233 = s->s6430352;
      v234 = v228 + s->s6430384;
      v235 = (int)(float)(v234 * -16384.0);
      s->s6496560 = RINGR1(s->s6496496 - (v235) + 1);
      s->s6496564 = RINGR1(s->s6496496 - (v235) + 2);
      v236 = (float)(v234 * 16384.0) - (double)(int)(float)(v234 * 16384.0);
      s->s6496568 = v236;
      v237 = s->s6430016;
      v238 = (float)((float)(v231 * s->s6496532) - (float)(v231 * v232)) + v232;
      v239 = s->s6496560;
      v240 = v238 * v233;
      s->s6429984 = v240 - v237;
      s->s6430000 = (float)((float)(v240 - v237) * c->k6430864) + v237;
      v241 = s->s6430112;
      v242 = (float)((float)((float)(v236 * s->s6496564) - (float)(v236 * v239)) + v239) * v233;
      v243 = v242 - v241;
      s->s6430080 = v242 - v241;
      v244 = c->k6430720;
      v245 = v242 * v244;
      s->s6430096 = (float)(v243 * c->k6430864) + v241;
      v246 = s->s6429904;
      v247 = s->s6429888;
      v248 = c->k6430704;
      s->s6430400 = v240 * v244;
      s->s6430416 = v245;
      v249 = c->k6430768;
      s->s6430432 = (float)((float)(v249 * (float)(v248 * v247)) + (float)((float)(1.0 - v249) * v247))
                               + s->s6430400;
      s->s6430448 = (float)((float)(v249 * (float)(v248 * v246)) + (float)((float)(1.0 - v249) * v246))
                               + v245;
      v250 = (s->s6463712 - 1) & (c->k6463716 - 1);
      s->s6463712 = v250;
      RINGI0(v250) = s->s6496512;
      v251 = (s->s6496496 - 1) & (c->k6496500 - 1);
      s->s6496496 = v251;
      RINGI1(v251) = s->s6496544;
      v252 = c->k101744;
      v176 = v252 * s->s6430448;
      v177 = v252 * s->s6430432;
    *o176 = v176; *o177 = v177; *o56 = v56; *o58 = v58;
}
