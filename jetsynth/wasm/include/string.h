/* freestanding string.h for the jetsynth wasm32 build */
#ifndef JET_WASM_STRING_H
#define JET_WASM_STRING_H
#include <stddef.h>
void *memset(void *, int, size_t);
void *memcpy(void *, const void *, size_t);
#endif
