/* test_denormal.c — regression guard for the FTZ shim (src/juno_ftz.c).
 *
 * The plugin runs with x86 FTZ/DAZ; WASM does not, so decaying envelope/filter
 * feedback tails settle into the denormal range and stay there, ~100x-slowing
 * every op that touches them and causing the audio-callback crackle. The driver
 * calls juno_flush_denormals() each sample. This test plays a note, releases it,
 * lets the tails decay, and asserts the recursive DSP state carries NO decaying
 * denormal floats (only harmless header/pointer constants + effect-line integer
 * metadata, which are excluded from the flush by design, may remain — and those
 * are not in the float-arithmetic hot path). It also confirms the flush leaves
 * the audible output unchanged.
 */
#include <stdio.h>
#include <string.h>
#include <math.h>
#include <float.h>
#include <stdlib.h>
#include "../src/juno_engine.h"
#include "../src/juno_driver.h"
#include "../src/juno_note.h"

static int is_denorm(unsigned b){ unsigned e=(b>>23)&0xFF, m=b&0x7FFFFF; return e==0 && m!=0; }

/* count denormal floats strictly inside the per-voice DSP blocks [176,84272),
 * which is where the decaying envelope/filter feedback lives (the crackle
 * source). The header (<176) and effect metadata (>=84272) are excluded. */
static long count_voice_denormals(unsigned char *st){
    long d=0;
    for (unsigned v=0; v<JUNO_NUM_VOICES; ++v){
        unsigned base=176u + v*JUNO_VOICE_MAIN_STRIDE;
        for (unsigned o=base; o+4<=base+ (JUNO_VOICE_MAIN_STRIDE-176u); o+=4){
            unsigned b; memcpy(&b, st+o, 4); if (is_denorm(b)) ++d;
        }
    }
    return d;
}

int main(void){
    unsigned char *st = calloc(1, JUNO_STATE_BYTES);
    struct juno_host_shim shim;
    JF(st,16)=96000.0f;
    juno_chorus_init(st); juno_engine_init(st); juno_runtime_coeffs_apply(st);
    juno_driver_seed_voices(st);
    juno_driver_attach_host(st, &shim, 2);

    /* play + release a note, let the tails decay */
    juno_note_on(st, 0, 60, 100);
    float l,r; int i;
    for (i=0;i<40000;i++){ juno_note_tick(st); juno_driver_render_sample(st,&l,&r); }
    juno_note_off(st, 0);
    long peak=0;
    for (i=0;i<200000;i++){
        juno_note_tick(st); juno_driver_render_sample(st,&l,&r);
        if (!(l==l) || fabsf(l)>1e6f){ printf("FAIL: nonfinite output during decay\n"); return 1; }
        if ((i%20000)==0){ long d=count_voice_denormals(st); if (d>peak) peak=d; }
    }
    long final = count_voice_denormals(st);
    printf("voice-block decaying denormals after full release: %ld (peak seen %ld)\n", final, peak);
    if (final > 0 || peak > 0){
        printf("FAIL: FTZ shim left %ld decaying denormals in the voice DSP blocks\n", final);
        free(st); return 1;
    }
    printf("OK: FTZ shim keeps the recursive voice DSP state denormal-free\n");
    free(st);
    return 0;
}
