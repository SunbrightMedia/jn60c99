/* car.h -- CARSYNTH: a playable combustion engine.
 *
 * Sound source: the engine-sim port (es_*.c) -- cylinders, valves, intake,
 * exhaust gas dynamics, combustion, exhaust impulse response. Effects: the
 * JUNO-60 port's chorus, delay and reverb (engine_b).
 *
 * Playing it: a key sets the engine speed so the FIRING frequency
 * (rpm/60 x cylinders/2) is the key's pitch, and opens the throttle by
 * velocity x LOAD. Releasing all keys shuts the throttle and lets the revs
 * fall back to idle (overrun). Monophonic, last-note priority.
 *
 * Controls, all 0..1:
 *   ENGINE   engine preset (stepped)
 *   EXHAUST  exhaust impulse response (stepped)
 *   LOAD     throttle opening while a key is held
 *   REV      how fast the revs follow a key (20 ms .. 2 s)
 *   TONE     engine-sim "high frequency gain": d/dt of the flow vs the flow
 *   NOISE    engine-sim air noise + input jitter (combustion roughness)
 *   SPACE    JUNO chorus / delay / reverb amount
 */
#ifndef CAR_H
#define CAR_H

#define CAR_SR 44100      /* engine-sim's audio rate; its impulse responses are 44.1 kHz */

enum { CAR_ENGINE, CAR_EXHAUST, CAR_LOAD, CAR_REV, CAR_TONE, CAR_NOISE, CAR_SPACE, CAR_NPARAM };

void  car_init(void);
void  car_set(int param, float v01);
float car_get(int param);
void  car_note_on(int note, float velocity01);
void  car_note_off(int note);
void  car_render(float *L, float *R, int n);
/* 0 rpm, 1 target rpm, 2 throttle 0..1, 3 firing Hz, 4 n_cyl, 5 preset count,
 * 6 exhaust choices (Stock + library), 7 current engine index */
float car_meter(int which);
const char *car_engine_name(int i);
const char *car_exhaust_name(int i);

#endif
