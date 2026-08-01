/* 8-voice steady-state only, with gcov counters reset immediately before the
 * measured render loop, so the line weights describe THAT workload alone. */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include "teensy_golden.h"
typedef struct juno_ctx juno_ctx;
juno_ctx *juno_gui_create(float, int);
void juno_gui_destroy(juno_ctx*);
int  juno_gui_apply_bank(juno_ctx*, const unsigned char*, int, int);
void juno_gui_note_on(juno_ctx*, int, int);
void juno_gui_note_off(juno_ctx*, int);
void juno_gui_warmup(juno_ctx*, int);
int  juno_gui_render(juno_ctx*, float*, int);
extern void __gcov_reset(void);
extern void __gcov_dump(void);
#define BK_HEADER 23
#define BK_STRIDE 20223
#define BK_BLOB   16
#define BLOCK 48
int main(int argc, char **argv)
{
    int N = (argc > 1) ? atoi(argv[1]) : 4800;
    static float buf[2*BLOCK];
    unsigned char *bank = calloc(1, BK_HEADER + BK_STRIDE);
    memcpy(bank + BK_HEADER + BK_BLOB, tg_scenarios[0].blob, TG_BLOB_LEN);
    juno_ctx *c = juno_gui_create(44100.0f, 0);
    juno_gui_apply_bank(c, bank, BK_HEADER + BK_STRIDE, 0);
    juno_gui_warmup(c, 44100);
    for (int v = 0; v < 8; ++v) juno_gui_note_on(c, 36 + v*5, 100);
    for (int i = 0; i < 4800; i += BLOCK) juno_gui_render(c, buf, BLOCK); /* settle */
    __gcov_reset();
    for (int i = 0; i < N; i += BLOCK) juno_gui_render(c, buf, BLOCK);
    __gcov_dump();
    printf("SAMPLES %d\n", N);
    _exit(0);
}
