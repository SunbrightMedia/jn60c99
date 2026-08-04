/* eb_delay_t23.h -- GENERATED SKELETON, see the .c */
#ifndef ENGINEB_EB_DELAY_T23_H
#define ENGINEB_EB_DELAY_T23_H
#include <stdint.h>

typedef struct {
    float   k101744;
    float   k6395312;
    float   k6395328;
    float   k6395408;
    float   k6395648;
    float   k6395664;
    float   k6395696;
    float   k6395712;
    float   k6396128;
    float   k6396144;
    float   k6396160;
    float   k6396176;
    float   k6396192;
    float   k6396208;
    float   k6396224;
    float   k6396240;
    float   k6396256;
    float   k6396272;
    float   k6396288;
    float   k6396304;
    float   k6396320;
    float   k6396336;
    float   k6396352;
    float   k6396368;
    float   k6396384;
    float   k6396400;
    float   k6396416;
    float   k6396432;
    float   k6396448;
    float   k6396464;
    float   k6396480;
    float   k6396496;
    float   k6396512;
    float   k6396528;
    float   k6396544;
    float   k6396560;
    float   k6396576;
    float   k6396592;
    float   k6396608;
    float   k6396624;
    int32_t k6429412;   /* ring length, a power of two */
} eb_dly23_coef;

typedef struct {
    float    s6395344;
    float    s6395360;
    float    s6395376;
    float    s6395600;
    float    s6395632;
    float    s6395680;
    float    s6395728;
    float    s6395744;
    float    s6395760;
    float    s6395776;
    float    s6395792;
    float    s6395808;
    float    s6395824;
    float    s6395840;
    float    s6395856;
    float    s6395872;
    float    s6395888;
    float    s6395904;
    float    s6395920;
    float    s6395936;
    float    s6395952;
    float    s6395968;
    float    s6395984;
    float    s6396000;
    float    s6396016;
    float    s6396032;
    float    s6396048;
    float    s6396064;
    float    s6396080;
    float    s6396096;
    float    s6396112;
    float    s6429424;
    float    s6429440;
    float    s6429444;
    float    s6429448;
    float    s6429456;
    float    s6429460;
    float    s6429464;
    uint32_t s6395616;
    int32_t  s6429408;
    int32_t  s11022348;
    float   *ring;   /* the port's 6396640.., k6429412 entries */
} eb_dly23_state;

void eb_dly23_tick(eb_dly23_state *s, const eb_dly23_coef *c,
                   float in36, float in38, float k5,
                   float *o176, float *o177, float *o56, float *o58);

#endif
