/* jp8_speed_bench.c (driven by jp8_speed.py) -- JP8 render timing: VOICE_WRAP x8 + MASTER_WRAP per sample, as jp8_lift_c.py's render event calls them --
 * through the lifted code (jp8_call) or the plugin's own machine code run natively (ms_abi, the image mapped RWX) */
#define _GNU_SOURCE
#include <stdint.h>
#include <string.h>
#include <time.h>
#include <sys/mman.h>
#include "jp8_cpu.h"
extern int jp8_call(CPU *c, uint64_t rva, uint64_t rcx, uint64_t rdx, uint64_t r8, uint64_t r9);
#define BUF 0x700000000ULL
#define PAIR_V (BUF + 0x100)
#define OUT_M (BUF + 0x200)
#define OUT_S (BUF + 0x204)
#define PAIR_M (BUF + 0x300)
#define OUT_L (BUF + 0x400)
#define OUT_R (BUF + 0x404)
#define A2 (BUF + 0x500)
#define VOUT (BUF + 0x600)
#define RET 0x105000ULL
static double now(void) { struct timespec t; clock_gettime(CLOCK_MONOTONIC, &t); return t.tv_sec + 1e-9 * t.tv_nsec; }
static void q(uint64_t a, uint64_t v) { memcpy((void *)(uintptr_t)a, &v, 8); }
/* returns seconds; *sum gets a checksum of the outputs */
double bench_lift(CPU *c, const uint64_t *state, uint64_t rsp, uint32_t mx, int n, uint32_t *sum)
{
    uint32_t acc = 0; double t0 = now();
    for (int s = 0; s < n; s++) {
        for (int v = 0; v < 8; v++) {
            q(OUT_M, 0); q(PAIR_V, OUT_M); q(PAIR_V + 8, OUT_S);
            c->r[4] = rsp; c->mxcsr = mx; q(rsp - 8, RET);
            if (jp8_call(c, 0x3F80B0, state[v], (uint64_t)v, PAIR_V, 0)) return -1;
            memcpy((void *)(uintptr_t)(VOUT + 8 * v), (void *)(uintptr_t)OUT_M, 8);
            acc = acc * 31 + *(uint32_t *)(uintptr_t)OUT_M;
        }
        q(OUT_L, 0); q(PAIR_M, OUT_L); q(PAIR_M + 8, OUT_R);
        c->r[4] = rsp; c->mxcsr = mx; q(rsp - 8, RET);
        if (jp8_call(c, 0x3F8040, state[8], A2, PAIR_M, 0)) return -1;
        acc = acc * 31 + *(uint32_t *)(uintptr_t)OUT_L;
    }
    *sum = acc;
    return now() - t0;
}
typedef void (__attribute__((ms_abi)) *w3_t)(uint64_t, uint64_t, uint64_t);
double bench_native(const uint64_t *state, uint32_t mx, int n, uint32_t *sum, uint64_t img, uint64_t imgsz)
{
    uint32_t acc = 0, mx0 = _mm_getcsr(); double t0;
    if (mprotect((void *)(uintptr_t)img, imgsz, PROT_READ | PROT_WRITE | PROT_EXEC)) return -2;
    w3_t vw = (w3_t)(uintptr_t)(img + 0x3F80B0), mw = (w3_t)(uintptr_t)(img + 0x3F8040);
    _mm_setcsr(mx);
    t0 = now();
    for (int s = 0; s < n; s++) {
        for (int v = 0; v < 8; v++) {
            q(OUT_M, 0); q(PAIR_V, OUT_M); q(PAIR_V + 8, OUT_S);
            vw(state[v], (uint64_t)v, PAIR_V);
            memcpy((void *)(uintptr_t)(VOUT + 8 * v), (void *)(uintptr_t)OUT_M, 8);
            acc = acc * 31 + *(uint32_t *)(uintptr_t)OUT_M;
        }
        q(OUT_L, 0); q(PAIR_M, OUT_L); q(PAIR_M + 8, OUT_R);
        mw(state[8], A2, PAIR_M);
        acc = acc * 31 + *(uint32_t *)(uintptr_t)OUT_L;
    }
    t0 = now() - t0;
    _mm_setcsr(mx0);
    *sum = acc;
    return t0;
}
