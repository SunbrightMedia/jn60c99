#include <stdio.h>
#include "juno_tables.h"
int main(void)
{
    int r, k;
    printf("/* eb_pitch_tab.h -- GENERATED, DO NOT EDIT.\n"
           " * Pre-split double-float coefficients for EB_PITCH_FAST, produced by\n"
           " * tools/engineb/gen_pitch_tab.c from src/juno_tables.h.\n"
           " *\n"
           " * WHY IT EXISTS. The fast pitch path splits each double coefficient into\n"
           " * two floats (hi + lo). Doing that at USE costs 13 __subdf3 plus 26\n"
           " * conversions per call on the ESP32-S3 -- soft-double on a core with no\n"
           " * double FPU, on the per-sample path, 8 times per sample. The split is a\n"
           " * pure function of a compile-time constant, so it belongs here.\n"
           " *\n"
           " * EXACTNESS. Emitted as C99 hex float literals, so there is no decimal\n"
           " * round-trip: each value is the exact float the runtime split produced.\n"
           " * engine_b/tests/test_pitch_tab.c re-derives all 29x13 pairs with the\n"
           " * module's own df_coef() and requires bit equality -- if this file is\n"
           " * ever regenerated from a changed table and drifts, that test fails.\n"
           " *\n"
           " * Layout: row r of juno_pitch_table, even columns 0,2,..,24 -> [r][0..12].\n"
           " */\n"
           "#ifndef ENGINEB_EB_PITCH_TAB_H\n"
           "#define ENGINEB_EB_PITCH_TAB_H\n\n"
           "#define EB_PITCH_ROWS %d\n"
           "#define EB_PITCH_TERMS %d\n\n", 29, 13);
    for (int pass = 0; pass < 2; ++pass) {
        printf("static const float eb_pitch_%s[EB_PITCH_ROWS][EB_PITCH_TERMS] = {\n",
               pass ? "lo" : "hi");
        for (r = 0; r < 29; ++r) {
            printf("    {");
            for (k = 0; k < 13; ++k) {
                double v = juno_pitch_table[r][2 * k];
                float hi = (float)v;
                float lo = (float)(v - (double)hi);
                printf("%s%a", k ? ", " : " ", pass ? (double)lo : (double)hi);
            }
            printf(" },\n");
        }
        printf("};\n\n");
    }
    printf("#endif /* ENGINEB_EB_PITCH_TAB_H */\n");
    return 0;
}
