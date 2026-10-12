/* jp8.h -- the JUPITER-8 engine: the plugin's own machine code, lifted to C99 (jp8_lift.c or its fast pass), booted from
 * the post-static-init template (jp8/gen/jp8_template.bin) in the plugin's own order (drive2, S3_STATUS D7) and played
 * through the plugin's own entries. One engine per process (the lifted runtime is global). Every call is safe: a trap
 * inside the lifted code kills the engine (JP8_E_TRAP), the output then stays zero, and nothing aborts.
 * The host's MXCSR is saved on entry and restored on exit. */
#ifndef JP8_API_H
#define JP8_API_H
#include <stddef.h>
#include <stdint.h>

enum { JP8_OK = 0, JP8_E_TEMPLATE = -1, JP8_E_RATE = -2, JP8_E_TRAP = -3, JP8_E_ARG = -4, JP8_E_STATE = -5 };

/* boot: the template (raw JP8T bytes, not gzip), then FACTORY + BUILD at MXCSR 0x1F80, FTZ|DAZ, SETSR(rate), the
 * controller's default push. rate: 44100 or 96000 only (D3: the per-unit drive is exact at these two). */
int  jp8_init(const void *tmpl, size_t len, float sample_rate);
int  jp8_recall(int patch);                         /* factory patch 0..63: one HOSTPARAM per pool, the oracle's calls */
int  jp8_hostparam(uint32_t host_id, uint32_t raw); /* one host parameter write through the plugin's HOSTPARAM */
int  jp8_note_on(int key, int vel);                 /* NOTEON 0x445CF0 */
int  jp8_note_off(int key, int vel);                /* NOTEOFF 0x445C90 */
int  jp8_render(float *L, float *R, int n);         /* n host samples (any n >= 0); L or R may be NULL */
int  jp8_render_words(uint32_t *w18, int n);        /* per sample 18 words: v0 main, v0 sub .. v7 sub, L, R (bits) */
void jp8_free(void);                                /* the arenas stay mapped and are reused by the next jp8_init */
const char *jp8_error(void);

/* gates */
void    *jp8_guest(uint64_t gaddr, size_t len);     /* host pointer when [gaddr, gaddr+len) lies in one region, else NULL */
uint64_t jp8_unit_state(int u);                     /* guest address of unit u's state, u 0..8 (8 = master) */
uint64_t jp8_host_obj(void);                        /* guest address of the constructed HOST (CWaveGen) */
uint64_t jp8_heap_top(void);                        /* the bump allocator's pointer */
int      jp8_npatch(void);                          /* 64 */
#endif
