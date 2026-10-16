/* jl_synth.h -- JUNO LITE engine. Pure C (no IDF): test/host_check.c runs it too. */
#ifndef JL_SYNTH_H
#define JL_SYNTH_H
#include <stdint.h>
#define JL_SR     44100
#define JL_BLOCK  64
#define JL_VOICES 6

typedef struct {              /* panel, 0..1 unless noted (JUNO-60 layout) */
    float lfo_rate, lfo_delay;
    float dco_lfo, pwm, pwm_lfo;          /* pwm_lfo: 1 = PWM from LFO, 0 = manual */
    int   pulse, saw;                     /* waveform switches */
    float sub, noise;
    float hpf;                            /* 0..1 */
    float cutoff, res, env_amt, vcf_lfo, kybd;
    int   env_neg;                        /* VCF env polarity */
    int   vca_gate;                       /* 1 = VCA by gate, 0 = by ENV */
    float level;
    float a, d, s, r;                     /* 0..1 */
    int   chorus;                         /* 0 off, 1 = I, 2 = II, 3 = I+II */
    const char *name;
} jl_patch;

extern const jl_patch jl_presets[];
extern const int jl_npresets;

void  jl_init(void);
void  jl_set_patch(const jl_patch *p);
void  jl_note_on(int note, int vel);
void  jl_note_off(int note);
void  jl_all_off(void);
void  jl_bend(float semis);
void  jl_mod(float amt);                  /* mod wheel -> LFO to DCO */
void  jl_cc_cutoff(float v);
void  jl_cc_res(float v);
void  jl_volume(float v);                 /* 0..0.5, default 0.15 */
void  jl_render(int16_t *lr);             /* JL_BLOCK stereo frames */
int   jl_active(void);                    /* sounding voices */
#endif
