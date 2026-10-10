/* jx_lift_census.c -- the page census of the lifted parameter system (jx_lift_gate.py --census): every armed host
 * range (the guest regions' arenas) is made PROT_NONE; the first read of a page faults once (marked 1, opened
 * read-only), the first write faults once (marked 2, opened read-write); the faulting instruction then runs again. */
#define _GNU_SOURCE
#include <signal.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>
#include <ucontext.h>

#define NR 8
static uintptr_t c_lo[NR], c_hi[NR];
static uint8_t *c_fl[NR];
static int c_n;
static unsigned long c_stray;

static void c_handler(int sig, siginfo_t *si, void *uc_)
{
    uintptr_t a = (uintptr_t)si->si_addr & ~(uintptr_t)0xFFF;
    ucontext_t *uc = (ucontext_t *)uc_;
    int wr = (uc->uc_mcontext.gregs[REG_ERR] & 2) != 0;
    for (int i = 0; i < c_n; ++i)
        if (a >= c_lo[i] && a < c_hi[i]) {
            size_t pg = (a - c_lo[i]) >> 12;
            c_fl[i][pg] |= wr ? 2 : 1;
            mprotect((void *)a, 4096, (c_fl[i][pg] & 2) ? PROT_READ | PROT_WRITE : PROT_READ);
            return;
        }
    ++c_stray;
    signal(sig, SIG_DFL);                       /* not an armed page: the re-fault crashes as it should */
}

int census_arm(uintptr_t lo, size_t len)          /* lo, len page aligned */
{
    if (c_n == NR) return -1;
    c_lo[c_n] = lo; c_hi[c_n] = lo + len;
    c_fl[c_n] = calloc(len >> 12, 1);
    if (!c_fl[c_n]) return -1;
    if (mprotect((void *)lo, len, PROT_NONE)) return -2;
    return c_n++;
}

int census_install(void)
{
    struct sigaction sa;
    memset(&sa, 0, sizeof sa);
    sa.sa_sigaction = c_handler;
    sa.sa_flags = SA_SIGINFO | SA_NODEFER;
    sigemptyset(&sa.sa_mask);
    return sigaction(SIGSEGV, &sa, 0);
}

void census_disarm(void)                          /* everything read-write again (the flags are kept) */
{
    for (int i = 0; i < c_n; ++i) mprotect((void *)c_lo[i], c_hi[i] - c_lo[i], PROT_READ | PROT_WRITE);
}

const uint8_t *census_flags(int i) { return c_fl[i]; }
unsigned long census_stray(void) { return c_stray; }
