/* juno_synth.c — see juno_synth.h. Thin polyphonic wrapper over juno_driver. */
#include "../src/juno_engine.h"
#include "../src/juno_driver.h"
#include "../src/juno_reverb.h"
#include "juno_synth.h"
#include <stdlib.h>
#include <string.h>
void juno_runtime_coeffs_apply(unsigned char*);
/* The product is capture-free: seed engine coefficients from the binary-sourced
 * transcription (juno_capture_free_seed). Build with -DJUNO_USE_CAPTURE to restore
 * the old "PD The Juno Pad" memory-capture seed (kept only as a test oracle). */
#ifdef JUNO_USE_CAPTURE
#  define JUNO_SEED(st) juno_runtime_coeffs_apply(st)
#else
#  define JUNO_SEED(st) juno_capture_free_seed(st)
#endif

struct juno_synth {
    unsigned char *st;
    struct juno_host_shim shim;
    int   note_of_voice[JUNO_NUM_VOICES]; /* midi note currently on each voice, -1 free */
    unsigned age[JUNO_NUM_VOICES];        /* for round-robin / oldest-steal      */
    unsigned clock;
};

juno_synth *juno_synth_create(void){
    juno_synth *s = calloc(1, sizeof *s);
    s->st = malloc(JUNO_STATE_BYTES); memset(s->st, 0, JUNO_STATE_BYTES);
    juno_chorus_init(s->st); juno_engine_init(s->st); JUNO_SEED(s->st);
    juno_driver_attach_host(s->st, &s->shim, 2 /*CH1 default*/);
    for (int v=0; v<JUNO_NUM_VOICES; ++v) s->note_of_voice[v] = -1;
    return s;
}
void juno_synth_destroy(juno_synth *s){ if(!s) return; free(s->st); free(s); }

int juno_synth_load_preset(juno_synth *s, const char *bank, int rec, juno_preset_info *info){
    juno_preset_info local; if(!info) info=&local;
    int r = juno_preset_load(s->st, bank, rec, info);
    if (r) return r;
    int chorus = (info->chorus_mode>=1)? info->chorus_mode : 0;
    juno_driver_attach_host(s->st, &s->shim, chorus?chorus:2);
    if (info->reverb_type>=0 && info->reverb_type<=5)
        juno_reverb_activate(s->st, info->reverb_type, 1.0f);
    return 0;
}

void juno_synth_note_on(juno_synth *s, int note, int vel){
    (void)vel;
    int free_v=-1, oldest=0; unsigned oldest_age=~0u;
    for (int v=0; v<JUNO_NUM_VOICES; ++v){
        if (s->note_of_voice[v] < 0){ free_v=v; break; }
        if (s->age[v] < oldest_age){ oldest_age=s->age[v]; oldest=v; }
    }
    int v = (free_v>=0)? free_v : oldest;       /* steal oldest if full */
    if (free_v<0) juno_note_off(s->st, v);
    juno_note_on(s->st, v, note);
    s->note_of_voice[v]=note; s->age[v]=++s->clock;
}
void juno_synth_note_off(juno_synth *s, int note){
    for (int v=0; v<JUNO_NUM_VOICES; ++v)
        if (s->note_of_voice[v]==note){ juno_note_off(s->st, v); s->note_of_voice[v]=-1; }
}
void juno_synth_all_notes_off(juno_synth *s){
    for (int v=0; v<JUNO_NUM_VOICES; ++v){ juno_note_off(s->st, v); s->note_of_voice[v]=-1; }
}
void juno_synth_process(juno_synth *s, float *outL, float *outR, int n){
    for (int i=0;i<n;i++){ float l=0,r=0; juno_driver_render_sample(s->st,&l,&r); outL[i]=l; outR[i]=r; }
}
