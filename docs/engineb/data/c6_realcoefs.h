/* c6_realcoefs.h -- GENERATED: patch 32's REAL recalled DCO + decimator
 * coefficients. FIRST RUN'S DEFECT, kept as the warning it is: it read
 * the DCO levels from cells 4736/4752/4768, which are the PER-SAMPLE
 * copies (0.0 before a note) -- the exact trap the coefficient audit
 * exists for. The coefficients are 4192/4208/4224. */
#define RC_lvl_saw 0x0.0p+0f
#define RC_lvl_pulse 0x1.01e2a80000000p+0f
#define RC_lvl_sub 0x0.0p+0f
#define RC_gn_saw 0x1.0000000000000p+0f
#define RC_gn_pulse 0x1.b333340000000p-1f
#define RC_gn_sub 0x1.b333340000000p-1f
#define RC_amp_saw 0x1.99999a0000000p-3f
#define RC_amp_pulse 0x1.99999a0000000p-4f
#define RC_amp_sub 0x1.99999a0000000p-4f
#define RC_sat_in 0x1.921fb60000000p+0f
#define RC_subthr -0x1.47ae140000000p-8f
#define RC_k3 -0x1.5555560000000p-3f
#define RC_k5 0x1.1111100000000p-7f
#define RC_k7 -0x1.a01a020000000p-13f
#define RC_k9 0x1.71dd220000000p-19f
#define RC_k11 -0x1.af36f80000000p-26f
#define RC_pw 0x1.47ae140000000p-6f
static const float RC_fir[16] = {
    -0x1.4a8c220000000p-11f,
    -0x1.dcba0a0000000p-10f,
    -0x1.4fcc7e0000000p-9f,
    -0x1.a026ec0000000p-10f,
    0x1.3693a60000000p-9f,
    0x1.110a0e0000000p-7f,
    0x1.82c7e20000000p-7f,
    0x1.bafa2e0000000p-8f,
    -0x1.2ca1620000000p-7f,
    -0x1.e71c760000000p-6f,
    -0x1.462d280000000p-5f,
    -0x1.6d63e40000000p-6f,
    0x1.fc5cb80000000p-6f,
    0x1.c73e680000000p-4f,
    0x1.8a260e0000000p-3f,
    0x1.f328d20000000p-3f,
};
#define RC_k6256 0x1.6a0f840000000p-1f
#define RC_k6272 0x1.0000000000000p+1f
#define RC_k6336 0x1.0000000000000p+0f
