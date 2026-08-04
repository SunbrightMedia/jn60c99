/* test_decim.c — eb_decim_tick() against the PORT's own arithmetic, bit for bit.
 *
 * WHY A UNIT TEST AND NOT THE SCENARIO GATE. `null_b.py --module decim` said
 * "17 of 30 fail, worst -36.6 dB". That is a true statement and a useless one:
 * it does not say WHICH sample first differs or which term is wrong. This file
 * drives both implementations from the same inputs and reports the first
 * differing sample, which is what actually localises a transcription defect.
 *
 * THE REFERENCE SIDE is the port's code, transcribed verbatim into a plain cell
 * array: the 30-move shift from src/voice_render.c:1697-1702, then the 32-tap
 * FIR and correction biquad from :2134-2173, with the port's exact
 * parenthesisation. Cell N of the port is CELL[N/16] here, because the port's
 * cells are 16 bytes apart.
 *
 * That is a hand transcription and could itself be wrong -- so it is not a
 * proof of correctness on its own. It is a DIFFERENTIAL: if the two agree, the
 * module matches this reading of the port, and the scenario gate then decides
 * whether the reading was right. If they disagree, the first differing sample
 * says where to look. Both halves are needed.
 */
#include <stdio.h>
#include <string.h>
#include <stdint.h>
#include "eb_decim.h"

#define C(n) cell[(n) / 16]
static float cell[800];

static uint32_t rs = 22222u;
static uint32_t r32(void) { rs ^= rs << 13; rs ^= rs >> 17; rs ^= rs << 5; return rs; }
static float rf(void)
{
    return (float)(int32_t)(r32() & 0xFFFFFF) / 8388608.0f - 1.0f;
}

/* The port, verbatim. Returns v526 and updates the cells. */
static float port_tick(float s0, float s1, float s2, float s3)
{
    float v518, v519, v520, v521, v522, v523, v524, v525, v526;

    /* :1697-1702 — the shift, all 30 moves, in the port's own order. */
    C(5056) = C(5040); C(5040) = C(5024); C(5024) = C(5008); C(5008) = C(4992);
    C(4992) = C(4976); C(4976) = C(4960); C(4960) = C(4944);
    C(5184) = C(5168); C(5168) = C(5152); C(5152) = C(5136); C(5136) = C(5120);
    C(5120) = C(5104); C(5104) = C(5088); C(5088) = C(5072);
    C(5312) = C(5296); C(5296) = C(5280); C(5280) = C(5264); C(5264) = C(5248);
    C(5248) = C(5232); C(5232) = C(5216); C(5216) = C(5200);
    C(5440) = C(5424); C(5424) = C(5408); C(5408) = C(5392); C(5392) = C(5376);
    C(5376) = C(5360); C(5360) = C(5344); C(5344) = C(5328);
    C(5504) = C(5488); C(5488) = C(5472);

    /* the DCO writes the four fresh sub-samples */
    C(4944) = s0; C(5072) = s1; C(5200) = s2; C(5328) = s3;

    /* :2134-2173 */
    v518 = C(5440);
    v519 = (float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)(C(5312) + C(5072))
                                                                                                   * C(5712))
                                                                                           + (float)((float)(v518 + C(4944))
                                                                                                   * C(5696)))
                                                                                   + (float)((float)(C(5200) + C(5184))
                                                                                           * C(5728)))
                                                                           + (float)((float)(C(5328) + C(5056))
                                                                                   * C(5744)))
                                                                   + (float)((float)(C(5424) + C(4960))
                                                                           * C(5760)))
                                                           + (float)((float)(C(5296) + C(5088))
                                                                   * C(5776)))
                                                   + (float)((float)(C(5216) + C(5168))
                                                           * C(5792)))
                                           + (float)((float)(C(5344) + C(5040))
                                                   * C(5808)))
                                   + (float)((float)(C(5408) + C(4976)) * C(5824)))
                           + (float)((float)(C(5104) + C(5280)) * C(5840)))
                   + (float)((float)(C(5232) + C(5152)) * C(5856)))
           + (float)((float)(C(5024) + C(5360)) * C(5872));
    v520 = C(5488);
    v521 = (float)(v520 * C(6256)) + C(5504);
    v522 = (float)((float)(v519 + (float)((float)(C(5392) + C(4992)) * C(5888)))
                 + (float)((float)(C(5264) + C(5120)) * C(5904)))
         + (float)((float)(C(5248) + C(5136)) * C(5920));
    v523 = (float)(C(5376) + C(5008)) * C(5936);
    C(5488) = v521;
    v524 = v522 + v523;
    v525 = v524 - (float)((float)(v520 * C(6272)) + v521);
    C(5472) = (float)(v525 * C(6256)) + v520;
    v526 = (float)((float)((float)(v521 - (float)(v525 * C(5456))) * C(6336))
                 - (float)(C(6336) * v524))
         + v524;
    return v526;
}

int main(void)
{
    eb_decim_state st;
    eb_decim_coef co;
    static const int CC[16] = {5712,5696,5728,5744,5760,5776,5792,5808,
                               5824,5840,5856,5872,5888,5904,5920,5936};
    long i, bad = 0, n = 300000;
    int j;

    memset(&st, 0, sizeof st);
    memset(cell, 0, sizeof cell);

    /* Coefficients are fixed for the run, as they are within a patch. */
    for (j = 0; j < 16; ++j) { C(CC[j]) = rf(); co.c[j] = C(CC[j]); }
    C(6256) = rf() * 0.5f;  co.k6256 = C(6256);
    C(6272) = rf() * 0.5f;  co.k6272 = C(6272);
    C(6336) = rf() * 0.5f;  co.k6336 = C(6336);
    C(5456) = rf() * 0.5f;

    for (i = 0; i < n; ++i) {
        float s0 = rf(), s1 = rf(), s2 = rf(), s3 = rf();
        float a = port_tick(s0, s1, s2, s3);
        float b = eb_decim_tick(&st, &co, C(5456), s0, s1, s2, s3);
        uint32_t x, y;
        memcpy(&x, &a, 4); memcpy(&y, &b, 4);
        if (x != y) {
            if (bad < 3)
                fprintf(stderr, "  FIRST DIFF at sample %ld: port %.9g (%08x)  "
                                "engine B %.9g (%08x)\n",
                        i, (double)a, x, (double)b, y);
            ++bad;
        }
    }
    printf("eb_decim_tick vs the port's own arithmetic: %ld samples, %ld differing\n",
           n, bad);
    printf("DECIMATOR: %s\n", bad ? "FAIL" : "PASS");
    return bad ? 1 : 0;
}
