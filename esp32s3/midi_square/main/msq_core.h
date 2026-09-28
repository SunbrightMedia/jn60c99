/* msq_core -- MIDI parser + one square-wave voice. Portable C: the firmware
 * and the host test (test/host_test.c) compile THIS file, so the host test
 * grades the code that ships. Test firmware only -- not a synth port. */
#ifndef MSQ_CORE_H
#define MSQ_CORE_H
#include <stdint.h>

#define MSQ_MAX_HELD 16

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
    uint32_t phase;
    float    level, att_step, rel_step, amp;
    float    sr;
    /* counters */
    uint32_t n_bytes, n_on, n_off, n_cc, n_rt, n_other;
    int      last_note, last_vel, last_event; /* last_event: 0 none, 1 on, 2 off, 3 all-off */
} msq_t;

void  msq_init  (msq_t *m, float sr);
/* Feed one MIDI byte. Returns 1 when it completed a note/CC event. */
int   msq_byte  (msq_t *m, uint8_t b);
/* Interleaved stereo 16-bit, n frames. */
void  msq_render(msq_t *m, int16_t *lr, int n);
float msq_note_hz(int note);
#endif
