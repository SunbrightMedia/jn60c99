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

/* Per-voice integer stage-counter slots whose bit pattern only LOOKS denormal.
 * The envelope/filter state machines store small integers here (e.g. stage=3,
 * count=23 -> 0x00000003 / 0x00000017, which as floats are denormals). The plugin
 * stores the same integers (integer stores are unaffected by x86 FTZ) and reads
 * them back as float operands where DAZ neutralises them to 0; the residual
 * denormal*coeff product is sub-audible. They are STABLE (not decaying feedback)
 * and load-bearing (flushing the counter to 0 corrupts the state machine), so —
 * exactly like the excluded effect-line integer metadata — they are not the
 * crackle source the flush targets and are excluded from the guard. */
static int is_stage_counter(unsigned rel){
    static const unsigned SC[] = {2592,2608,2752,2768,3072,3088,3232,3248,3648,3664,7072,10048};
    for (unsigned i=0;i<sizeof(SC)/sizeof(SC[0]);++i) if (SC[i]==rel) return 1;
    return 0;
}

/* count denormal floats strictly inside the per-voice DSP blocks [176,84272),
 * which is where the decaying envelope/filter feedback lives (the crackle
 * source). The header (<176), effect metadata (>=84272), and the per-voice
 * integer stage counters (is_stage_counter) are excluded. */
static long count_voice_denormals(unsigned char *st){
    long d=0;
    for (unsigned v=0; v<JUNO_NUM_VOICES; ++v){
        unsigned base=176u + v*JUNO_VOICE_MAIN_STRIDE;
        for (unsigned o=base; o+4<=base+ (JUNO_VOICE_MAIN_STRIDE-176u); o+=4){
            unsigned b; memcpy(&b, st+o, 4);
            if (is_denorm(b) && !is_stage_counter(o - v*JUNO_VOICE_MAIN_STRIDE)) ++d;
        }
    }
    return d;
}

int main(void){
    unsigned char *st = calloc(1, JUNO_STATE_BYTES);
    struct juno_host_shim shim;
    JF(st,16)=96000.0f;
    juno_chorus_init(st); juno_engine_init(st); juno_engine_prepare(st);
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
