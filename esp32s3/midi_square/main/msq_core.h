/* msq_core -- MIDI parser + a 6-voice polyphonic synth. Each voice is a
 * 7-oscillator unison stack whose waveform morphs sine -> triangle -> saw ->
 * square (band-limited saw/square), with its own linear attack/release.
 * Allocation: the same key reuses its voice; else a free voice; else the
 * quietest releasing voice; else the OLDEST held voice is stolen. Portable C: the firmware
 * and the host test (test/host_test.c) compile THIS file, so the host test
 * grades the code that ships. Test firmware only -- not a synth port. */
#ifndef MSQ_CORE_H
#define MSQ_CORE_H
#include <stdint.h>

#define MSQ_MAX_HELD 16
#define MSQ_UNI      7        /* unison oscillators per voice (gains ramp) */
#define MSQ_VOICES   6

typedef struct {
    volatile uint32_t inc;     /* published by the MIDI side (atomic 32-bit)   */
    volatile int      gate;
    volatile int      note;    /* -1 = never used                              */
    uint32_t age;              /* allocation clock, for stealing               */
    float    level;
    uint32_t uph[MSQ_UNI];
    float    ugain[MSQ_UNI];
} msq_voice;

typedef struct {
    /* parser */
    uint8_t status, d1;
    int     have;
    msq_voice v[MSQ_VOICES];
    uint32_t clock;
    volatile int nheld;        /* voices with the gate on                      */
    volatile int gate;         /* 1 while any voice is gated                   */
    float    amp;              /* per-voice peak, synth scale                  */
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
/* All voices summed as float, mono, same scale as msq_render. */
void  msq_render_f(msq_t *m, float *out, int n);
/* Voices [v0, v1) summed into out (overwrites). Two cores each take a range. */
void  msq_render_voices(msq_t *m, int v0, int v1, float *out, int n);
int   msq_voices_sounding(const msq_t *m);   /* gated or still releasing */
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
