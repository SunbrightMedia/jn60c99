/* juno_fx.c — capture-free FX coefficient setup. See juno_fx.h.
 *
 * The JUNO chorus LFO rate ("Chorus CV") was long thought host-pushed/capture-
 * only. It is produced by sub_7FF91DFBE590 (rva 0x35E590, CDSPSystem8DlyCh
 * vtable slot 0): value = LUT22(step)*11.0 - 8.0, LUT22 = step/255 (rva 0x96D2E0;
 * scale 11.0 @ 0xAE5370, offset 8.0 @ 0xAE5350). The two chorus engine instances
 * (6395312 / 10692016) carry the fixed Chorus I / Chorus II rates; CH1=step 62,
 * CH2=step 50, both reproducing the captured bits 0xC0AA6A6A / 0xC0BAFAFB exactly.
 * So the chorus is fully capture-free. (docs/FX_MODE_COEFFICIENTS.md §3.) */
#include "juno_engine.h"
#include "juno_fx.h"

float juno_chorus_cv(int step){ return ((float)step * 11.0f) / 255.0f - 8.0f; }

void juno_chorus_set_rates(unsigned char *st){
    JF(st, 6395312)  = juno_chorus_cv(62);   /* Chorus I  rate  -> 0xC0AA6A6A */
    JF(st, 10692016) = juno_chorus_cv(50);   /* Chorus II rate  -> 0xC0BAFAFB */
}
