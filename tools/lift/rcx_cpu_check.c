/* rcx_cpu_check.c -- op_rcr / op_rcl (jp8/src/jp8_cpu.h) vs the CPU (the BOSS L3 find, 2026-10-17): every size, count 0..255,
 * CF in 0/1, 4000 random values; CF always, OF where the masked count is 1. Build: cc -std=gnu99 -O1 -Ijp8/src tools/lift/rcx_cpu_check.c
 * -lm. Tooth: build it with -I<dir> holding the pre-fix jp8_cpu.h (git show 5f98ea5:jp8/src/jp8_cpu.h): 13,929,007 mismatches. */
#include "jp8_cpu.h"
#include <stdio.h>
#define ASM(NAME,INS,T,REG) static void hw_##NAME(uint64_t *a, unsigned n, int *cf, int *of) { T v = (T)*a; unsigned char c8 = (unsigned char)n; \
  unsigned long long fl; unsigned long long fi = *cf ? 1 : 0; \
  __asm__ volatile("pushq %3; popfq; " INS " %%cl, %0; pushfq; popq %1" : "+" REG (v), "=r"(fl) : "c"(c8), "r"(fi) : "cc"); \
  *a = (uint64_t)v; *cf = fl & 1; *of = (fl >> 11) & 1; }
ASM(rcrb,"rcrb",uint8_t,"q") ASM(rcrw,"rcrw",uint16_t,"r") ASM(rcrl,"rcrl",uint32_t,"r") ASM(rcrq,"rcrq",uint64_t,"r")
ASM(rclb,"rclb",uint8_t,"q") ASM(rclw,"rclw",uint16_t,"r") ASM(rcll,"rcll",uint32_t,"r") ASM(rclq,"rclq",uint64_t,"r")
typedef void (*hw_t)(uint64_t *, unsigned, int *, int *);
int main(void) {
  static CPU cc; CPU *c = &cc; int bad = 0, sizes[4] = {8, 16, 32, 64};
  hw_t R[4] = {hw_rcrb, hw_rcrw, hw_rcrl, hw_rcrq}, L[4] = {hw_rclb, hw_rclw, hw_rcll, hw_rclq};
  uint64_t s = 0x9E3779B97F4A7C15ULL;
  for (int k = 0; k < 4; k++) for (int op = 0; op < 2; op++) for (unsigned n = 0; n < 256; n++) for (int ci = 0; ci < 2; ci++)
  for (int t = 0; t < 4000; t++) {
    s ^= s << 13; s ^= s >> 7; s ^= s << 17; int sz = sizes[k]; uint64_t a = s & jp8_mask(sz), h = a; int hcf = ci, hof = 0;
    (op ? L[k] : R[k])(&h, n, &hcf, &hof);
    c->cf = ci; c->of = 7; uint64_t r = op ? op_rcl(c, sz, a, n) : op_rcr(c, sz, a, n);
    unsigned mn = (n & (sz == 64 ? 63 : 31)) % (sz + 1);
    if (r != h || c->cf != hcf || (mn == 1 && c->of != hof) || (mn == 0 && c->of != 7)) {
      if (bad++ < 5) printf("%s%d n=%u cf=%d a=%llx: lift %llx cf%d of%d  cpu %llx cf%d of%d\n", op ? "rcl" : "rcr", sz, n, ci,
        (unsigned long long)a, (unsigned long long)r, c->cf, c->of, (unsigned long long)h, hcf, hof); }
  }
  printf("rc_test: %d mismatches\n", bad); return bad != 0;
}
