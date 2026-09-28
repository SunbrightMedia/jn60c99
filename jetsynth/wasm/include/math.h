/* freestanding math.h for the jetsynth wasm32 build: only what engine_b's FX use */
#ifndef JET_WASM_MATH_H
#define JET_WASM_MATH_H
float fabsf(float);
float fmodf(float, float);
float fminf(float, float);
float fmaxf(float, float);
#endif
