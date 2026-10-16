/* tone.h -- the board test's sound: a fixed program of stages, rendered as
 * 16-bit stereo frames. Pure C (no IDF): the host check (test/host_check.c)
 * renders the same code to a WAV and grades it. */
#ifndef BT_TONE_H
#define BT_TONE_H
#include <stdint.h>

#define BT_SR    44100
#define BT_PEAK  1036              /* -30 dBFS: the HP amp has gain 2 and no volume control */

enum { BT_SIL0, BT_LEFT, BT_GAP1, BT_RIGHT, BT_GAP2, BT_MELODY, BT_SIL1, BT_NSTAGE };
extern const char *const bt_stage_name[BT_NSTAGE];

typedef struct {
    int stage;                     /* current stage */
    uint32_t pos;                  /* frame within the stage */
    uint32_t len;                  /* frames in the stage */
    int note;                      /* melody: current note */
    uint32_t npos, nlen;           /* melody: frame within the note, its length */
    uint32_t ph, inc;              /* phase accumulator (2^32 = one cycle) */
} bt_tone;

void bt_tone_init(bt_tone *t);
/* Render n frames (interleaved L,R). Returns 1 if a stage ended inside the
 * block; *ended = that stage, *endpos = frames of the block that belong to it. */
int bt_tone_render(bt_tone *t, int16_t *lr, int n, int *ended, int *endpos);
#endif
