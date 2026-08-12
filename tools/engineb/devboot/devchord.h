/* devchord.h -- THE DEMO CHORD, shared by the host oracle and the firmware.
 *
 * The recalled COEFFICIENTS carry pitch and velocity per voice (eb_render.h
 * :75-133), so the note the device sounds is part of what the CRC oracle
 * predicts. If the oracle and the firmware disagreed about the chord, every
 * CRC would mismatch and the mismatch would say nothing about the chip. So the
 * chord is defined ONCE, here, and both sides include it.
 *
 * DEVCHORD_N is a build knob and must be given the SAME value on both sides.
 * It is baked into the generated devcrc.h as DEVCRC_CHORD_N, and the firmware
 * refuses to quote a CRC verdict when the two differ -- a mismatch nobody can
 * explain is worse than no check.
 *
 * THE VOICES ARE CHOSEN, NOT ALLOCATED. The port's allocator fills from voice
 * 7 downward (MEASURED -- tools/engineb/listen_mask_probe.c, and the wake mask
 * in s3_listen_meta.h is built from it), so a chord of k sounds voices
 * 8-k .. 7. Reproducing that by hand keeps C3 (does recall build the right
 * coefficients on the chip) apart from C4 (does the allocator run on the
 * chip). It is NOT an allocator and must not be described as one.
 *
 * The notes are tools/engineb/gen_listen_coefs.py's own CHORD, so a recall
 * build and a frozen-blob build are playing the same thing and can be A/B'd
 * by ear -- which is the whole reason requirement 4 keeps the blob path alive.
 */
#ifndef DEVCHORD_H
#define DEVCHORD_H

#ifndef DEVCHORD_N
#define DEVCHORD_N 2
#endif
#if DEVCHORD_N < 1 || DEVCHORD_N > 8
#error "DEVCHORD_N must be 1..8"
#endif

#define DEVCHORD_VELOCITY 100

/* gen_listen_coefs.py CHORD[], first DEVCHORD_N of it */
static const int DEVCHORD_NOTE[8]  = { 48, 55, 60, 64, 67, 72, 76, 79 };
static const int DEVCHORD_VOICE[8] = { 8 - DEVCHORD_N, 9 - DEVCHORD_N,
                                       10 - DEVCHORD_N, 11 - DEVCHORD_N,
                                       12 - DEVCHORD_N, 13 - DEVCHORD_N,
                                       14 - DEVCHORD_N, 15 - DEVCHORD_N };
static const int DEVCHORD_VEL[8]   = { DEVCHORD_VELOCITY, DEVCHORD_VELOCITY,
                                       DEVCHORD_VELOCITY, DEVCHORD_VELOCITY,
                                       DEVCHORD_VELOCITY, DEVCHORD_VELOCITY,
                                       DEVCHORD_VELOCITY, DEVCHORD_VELOCITY };
/* the wake mask that follows: voices 8-N..7 */
#define DEVCHORD_WAKE  ((unsigned)((0xFFu << (8 - DEVCHORD_N)) & 0xFFu))

#endif /* DEVCHORD_H */
