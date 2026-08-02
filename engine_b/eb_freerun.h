/* eb_freerun.h — THE FREE-RUN CONTRACT. The core of engine B's design.
 *
 * MEASURED (session brief, and reproduced by the idle-prefix scenarios in
 * tools/trackb/null_ab.py): the same patch and the same note, differing only in
 * how many samples the engine idled first (1, 48, 441, 4410, 44100), produce
 * FIVE DIFFERENT outputs. Where the DCO phases, the noise LFSR and the FX LFOs
 * stand at note-on is part of the sound.
 *
 * THE RULE THAT FOLLOWS:
 *
 *     Skip the AUDIO work of a silent voice. NEVER skip its STATE ADVANCE.
 *
 * That is only affordable if the state advance is O(1) in the number of samples
 * skipped. So every free-running quantity in engine B exposes TWO operations:
 *
 *     eb_<x>_step(s)         advance one sample
 *     eb_<x>_advance(s, n)   advance n samples in O(1)
 *
 * and the EQUIVALENCE
 *
 *     advance(s, n)  ==  n calls of step(s)          EXACTLY, bit for bit
 *
 * is a unit test (engine_b/tests/test_freerun.c), not a comment. "Exactly" is
 * the whole point: an approximate catch-up would put the voice a fraction of a
 * cycle away from where the oracle has it, and the null in tools/engineb/null_b.py
 * gates at -100 dB.
 *
 * WHAT IS AND IS NOT FREE-RUNNING (this list is the design, read it before
 * adding a field to eb_voice):
 *
 *   FREE-RUNNING, must have advance():
 *     - DCO phase and sub-oscillator phase       (eb_phase, exact, O(1))
 *     - the global LFO phase                     (eb_phase, exact, O(1))
 *     - the chorus / FX LFO phases               (eb_phase, exact, O(1))
 *     - the shared noise LFSR                    (see the note below)
 *
 *   NOT free-running, must NOT be skipped and must NOT be "advanced":
 *     - envelopes, smoothers, filter state, delay lines. These are driven by
 *       input, or decay toward a target. A voice may only be skipped once its
 *       envelope has reached exactly zero and its output is exactly zero, at
 *       which point there is nothing in them left to advance. The skip
 *       PREDICATE is therefore part of this contract too, and it is deliberately
 *       conservative: silence of the OUTPUT is not enough, the state must be at
 *       rest.
 *
 * THE NOISE LFSR IS THE ONE DELIBERATE EXCEPTION, and it is a scoping fact, not
 * a shortcut. The LFSR is SHARED by all voices (docs: the plugin runs 9 isolated
 * units whose noise blocks step in lockstep, so every voice reads the same one-
 * step advance). It therefore steps once per sample whatever the polyphony, and
 * the per-voice skip never applies to it. eb_noise_advance() exists so the
 * contract is complete and testable, and it is an O(n) loop of 6 integer ops --
 * MEASURED-STATIC: cheaper than any jump-matrix for every n a skip could
 * produce, and it is never on the hot path. It is labelled O(n) here rather than
 * quietly presented as O(1).
 */
#ifndef ENGINEB_EB_FREERUN_H
#define ENGINEB_EB_FREERUN_H

#include <stdint.h>
#include "noise_lfsr.h"

/* ---------------------------------------------------------------- phase
 * A 32-bit fixed-point phase accumulator. Unsigned overflow in C is defined to
 * wrap modulo 2^32, so
 *
 *     acc + inc + inc + ... + inc   (n times)   ==   acc + inc*n   (mod 2^32)
 *
 * is an identity of the arithmetic, not an approximation. That is exactly why
 * the phase is an integer accumulator and not a float: a float phase would need
 * an fmod, would lose bits as it grew, and could not satisfy the equivalence
 * test at all. (The sealed port calls fmodf 24 times per sample; on the
 * ESP32-S3 those are soft-float double helpers -- see docs/engineb/COST_RIG.md.)
 *
 * Resolution: 2^-32 of a cycle. At 48 kHz that is a frequency quantum of
 * 48000/2^32 = 1.118e-5 Hz, i.e. 4.0e-7 cents at 440 Hz. MEASURED-STATIC from
 * the definition; whether it is fine enough against the oracle's own pitch law
 * is a question for the DCO module's gate, not an assumption made here.
 */
typedef struct { uint32_t acc; uint32_t inc; } eb_phase;

static inline void eb_phase_init(eb_phase *p, uint32_t acc, uint32_t inc)
{
    p->acc = acc; p->inc = inc;
}

static inline uint32_t eb_phase_step(eb_phase *p)
{
    uint32_t out = p->acc;          /* emit BEFORE advancing, like eb_noise_step */
    p->acc += p->inc;
    return out;
}

/* O(1) in n. One multiply. */
static inline void eb_phase_advance(eb_phase *p, uint32_t n)
{
    p->acc += p->inc * n;
}

/* Phase as a float in [0,1). Exact for the top 24 bits; the low 8 bits of the
 * accumulator are below single-precision resolution and are carried in the
 * INTEGER, which is the point of keeping the accumulator integral. */
static inline float eb_phase_unit(uint32_t acc)
{
    return (float)acc * (1.0f / 4294967296.0f);
}

/* ---------------------------------------------------------------- noise
 * eb_noise / eb_noise_init / eb_noise_step live in noise_lfsr.h and are PROVEN
 * bit-identical to the oracle over 200,000 samples. Only the advance-by-n half
 * of the contract is added here.
 *
 * O(n), by design and stated as such. See the header comment above.
 */
static inline void eb_noise_advance(eb_noise *s, uint32_t n)
{
    uint32_t i;
    for (i = 0; i < n; ++i) (void)eb_noise_step(s);
}

#endif /* ENGINEB_EB_FREERUN_H */
