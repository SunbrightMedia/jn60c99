#include <stdio.h>
#include <stdint.h>
#include <string.h>
typedef struct { uint32_t mx, mo, a, b; uint64_t d; uint32_t out, zf; } T;
static void run(const char *op, T *t) {
#define PRE "ldmxcsr (%0)\n movss 8(%0),%%xmm0\n movss 12(%0),%%xmm1\n"
#define POST "movss %%xmm0,24(%0)\n stmxcsr 4(%0)\n"
  if (!strcmp(op,"mulss")) __asm__ volatile(PRE "mulss %%xmm1,%%xmm0\n" POST :: "r"(t) : "xmm0","xmm1","memory");
  if (!strcmp(op,"divss")) __asm__ volatile(PRE "divss %%xmm1,%%xmm0\n" POST :: "r"(t) : "xmm0","xmm1","memory");
  if (!strcmp(op,"addss")) __asm__ volatile(PRE "addss %%xmm1,%%xmm0\n" POST :: "r"(t) : "xmm0","xmm1","memory");
  if (!strcmp(op,"minss")) __asm__ volatile(PRE "minss %%xmm1,%%xmm0\n" POST :: "r"(t) : "xmm0","xmm1","memory");
  if (!strcmp(op,"maxss")) __asm__ volatile(PRE "maxss %%xmm1,%%xmm0\n" POST :: "r"(t) : "xmm0","xmm1","memory");
  if (!strcmp(op,"cvtsd2ss")) __asm__ volatile(PRE "cvtsd2ss 16(%0),%%xmm0\n" POST :: "r"(t) : "xmm0","xmm1","memory");
  if (!strcmp(op,"comiss")) __asm__ volatile(PRE "comiss %%xmm1,%%xmm0\n sete 28(%0)\n" POST :: "r"(t) : "xmm0","xmm1","memory","cc");
}
int main(int argc, char **argv) {
  char name[64], op[16]; unsigned a, b; unsigned long long d; unsigned mx;
  while (scanf("%x %63[^|]|%15s %x %x %llx", &mx, name, op, &a, &b, &d) == 6) {
    T t = {0}; t.mx = mx; t.a = a; t.b = b; t.d = d; run(op, &t);
    printf("HW  mx=%04x %-32s out=%08x mxcsr_after=%04x zf=%d\n", mx, name, t.out, t.mo, t.zf & 0xFF);
  }
  return 0;
}
