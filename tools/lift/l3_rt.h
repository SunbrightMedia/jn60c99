/* l3_rt.h -- what a generated L3 test function (build/l3/l3_cases.c, tools/lift/l3_cases.py) needs: the lifted CPU
 * model itself (jp8_cpu.h, the product's build flags) and the outcome of one statement. A statement ends in one of:
 * it falls through (T_FALL), it jumps to a label (T_GOTO), it calls or tail-calls a lifted function or an indirect
 * target (t_call: the state at that moment is SNAPSHOT -- it is the state the CPU has after the call or jmp), or it
 * returns (ret). The harness (tools/lift/l3_harness.c) compares that outcome with the real CPU's single step. */
#ifndef L3_RT_H
#define L3_RT_H
#include "jp8_cpu.h"

typedef struct {
    void (*fn)(CPU *);
    uint64_t rva;
    int len, exe, form;
    int mb, mi, msc, msz;        /* memory operand: base / index GPR (-1 none), scale, access size in bytes (0 none) */
    long long mdisp;             /* its displacement */
    int mk;                      /* 0 none, 1 base/index into the test window, 2 rip-relative (the image), 3 gs: */
    int stack, str;              /* rsp must point into the window; a string op (rdi / rsi into the window, rcx small) */
    int divk, divreg;            /* 1 div32 2 div64 3 idiv32 4 idiv64; the divisor's GPR (-1: the memory operand) */
    int shk, shimm, shsz;        /* shift (0) / rotate (1) or -1; its immediate count (-1: cl); operand bits */
    int fpflag;                  /* lane kind * 256 + defined output flags (bit 0 CF 1 PF 2 ZF 3 SF 4 OF) */
    int sp;                      /* 1: ldmxcsr (the loaded word must be a valid MXCSR) */
    int ctl, ctlreg;             /* indirect transfer: 1 via a GPR (ctlreg), 2 via the memory operand, 3 ret ([rsp]) */
    const uint64_t *ct; int nct; /* a jump table's targets (the lifted switch's cases) */
} l3case;
extern const l3case l3_cases[];
extern const int l3_ncases;
extern const uint64_t l3_ib;

enum { T_FELL = 0, T_WENT = 1, T_RETURNED = 4 };
extern int t_kind, t_called;
extern uint64_t t_target;
extern CPU t_snap;
extern uint64_t t_snap_w;
void t_call(CPU *c, uint64_t target);
#define T_GOTO(rva) do { t_kind = T_WENT; t_target = (rva) + l3_ib; } while (0)
#define T_FALL() do { t_kind = T_FELL; } while (0)
#endif
