/* outstage -- the LAST stage before the DAC: master volume, startup sound mix,
 * and the SPEAKER-SAFE soft limiter. Portable C (host-tested: test/out_test.c).
 *
 * WHERE THE NUMBERS COME FROM (user's speaker, 2026-10-01; full method and
 * data in README "Speaker-safe output"). The user played C4, no FX, each wave,
 * on the v10 image and turned the volume up to the first audible distortion:
 * sine 75 %, triangle 79 %, saw 88 %, square 89 %. The exact v10 chain rebuilt
 * on the host gives the DAC level at each point. Sine and triangle agree within
 * 0.2 dB in fundamental and RMS (the speaker's real limit); saw and square
 * mask their own distortion. The SINE is the worst case in every measure: its
 * distortion point is a DAC peak of 503 (of 32767).
 *   OUT_CEIL  = 503 - 1 dB = 448: no sample ever leaves above it.
 *   OUT_KNEE  = 448 - 1 dB = 399: a single note at full volume peaks here, so
 *               single notes never touch the limiter; chords, unison, chorus
 *               and reverb are pressed smoothly into KNEE..CEIL. */
#ifndef MSQ_OUTSTAGE_H
#define MSQ_OUTSTAGE_H
#include <stdint.h>

#define OUT_CEIL      448.0f
#define OUT_KNEE      399.0f
#define OUT_NOTE_PEAK 2003.0f      /* one note's peak out of the FX (sine/tri/square; saw 1981) */
#define OUT_G_SYNTH   (OUT_KNEE / OUT_NOTE_PEAK)
#define OUT_G_CLIP    (2.0f * OUT_CEIL / 32768.0f)  /* clip peak 2 x CEIL: its loudest 50 ms ~ one note */

typedef struct {
    float env;                     /* peak envelope: instant attack, ~100 ms release */
    float rel;
    float vol_now;                 /* master volume, ramped per block */
} outstage_t;

typedef struct {
    int   peak;                    /* max |sample| sent */
    float min_gain;                /* deepest limiter gain (1 = untouched) */
    int   hard;                    /* samples the safety clip had to catch (must stay 0) */
} outstage_stats;

void  outstage_init(outstage_t *o, float sr);
/* Volume knob law (0..1): 0 = silent, else -48 .. 0 dB. */
float outstage_vol_law(float v);
/* n stereo frames: synth (post-FX int16) + clip (int16 stereo, or NULL) ->
 * volume (ramped to vol_to) -> soft limiter -> out. Stats accumulate. */
void  outstage_block(outstage_t *o, const int16_t *synth, const int16_t *clip, int n,
                     float vol_to, int16_t *out, outstage_stats *st);
#endif
