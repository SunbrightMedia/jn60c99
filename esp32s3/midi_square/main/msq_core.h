/* msq_core -- MIDI parser + one mono voice: a 7-oscillator unison stack whose
 * waveform morphs sine -> triangle -> saw -> square (band-limited saw/square),
 * with a linear attack/release envelope. Portable C: the firmware
 * and the host test (test/host_test.c) compile THIS file, so the host test
 * grades the code that ships. Test firmware only -- not a synth port. */
#ifndef MSQ_CORE_H
#define MSQ_CORE_H
#include <stdint.h>

#define MSQ_MAX_HELD 16
#define MSQ_UNI      7        /* unison oscillators (always running, gains ramp) */

typedef struct {
    /* parser */
    uint8_t status, d1;
    int     have;
    /* key stack, last-note priority */
    uint8_t held[MSQ_MAX_HELD];
    int     nheld;
    /* published to the renderer (32-bit, aligned: atomic on Xtensa) */
    volatile uint32_t inc;
    volatile int      gate;
    /* renderer */
    uint32_t uph[MSQ_UNI];     /* oscillator phases                         */
    float    ugain[MSQ_UNI];   /* oscillator gains, ramped toward targets   */
    float    level, amp;
    /* sound parameters: written by the knob task, read once per block */
    volatile float att_step, rel_step;
    volatile float wave;       /* 0 sine, 1 triangle, 2 saw, 3 square, morph between */
    volatile float unison;     /* 0 = one oscillator .. 1 = 7 oscillators, widest detune */
    float    attack_s, release_s;
    float    sr;
    /* counters */
    uint32_t n_bytes, n_on, n_off, n_cc, n_rt, n_other;
    int      last_note, last_vel, last_event; /* last_event: 0 none, 1 on, 2 off, 3 all-off */
} msq_t;

void  msq_init  (msq_t *m, float sr);
/* Feed one MIDI byte. Returns 1 when it completed a note/CC event. */
int   msq_byte  (msq_t *m, uint8_t b);
/* Interleaved stereo 16-bit, n frames (the voice only, no effects). */
void  msq_render(msq_t *m, int16_t *lr, int n);
/* The voice as float, same scale as msq_render (+-amp), n frames, mono. */
void  msq_render_f(msq_t *m, float *out, int n);
float msq_note_hz(int note);
/* Release time, seconds (linear fade from the current level; 0 -> clamped 1 ms). */
void  msq_set_release(msq_t *m, float seconds);
/* Knob law: x in 0..1 -> 10 ms .. 2 s, exponential (equal feel per turn). */
float msq_knob_to_release(float x);
void  msq_set_attack(msq_t *m, float seconds);
/* Knob law: x in 0..1 -> 1 ms .. 2 s, exponential. */
float msq_knob_to_attack(float x);
/* Waveform 0..3 and unison 0..1 (clamped). */
void  msq_set_wave(msq_t *m, float w);
void  msq_set_unison(msq_t *m, float u);
/* Unison law, exposed for the display: oscillator count 1..7 and outer detune in cents. */
int   msq_unison_voices(float u);
float msq_unison_cents(float u);
#endif
