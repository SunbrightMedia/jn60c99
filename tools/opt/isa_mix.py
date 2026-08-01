#!/usr/bin/env python3
"""Static instruction-mix comparison, Cortex-M7 Thumb-2 vs x86-64 SSE2.

Classifies every instruction of a function into:
  FPARITH  single/double FP arithmetic (add/sub/mul/div/cvt/cmp/abs/neg/sqrt/min/max)
  FPMOV    FP register-register moves / GPR<->FPR transfers (no memory)
  FPLOAD   FP load from memory        FPSTORE  FP store to memory
  ILOAD    integer load               ISTORE   integer store
  BRANCH   any control transfer (cond/uncond/call/ret)
  IALU     everything else (integer ALU, moves, address arithmetic, nop)
"""
import re, subprocess, sys, collections

def dis(obj, sym, arch):
    tool = "arm-none-eabi-objdump" if arch == 'arm' else "objdump"
    out = subprocess.run([tool, "-d", "--no-show-raw-insn", obj],
                         capture_output=True, text=True).stdout
    body, on = [], False
    pool = 0
    for L in out.split("\n"):
        m = re.match(r'^[0-9a-f]+ <([^>]+)>:', L)
        if m:
            on = (m.group(1) == sym)
            continue
        if not on:
            continue
        if not L.strip():
            on = False
            continue
        m = re.match(r'^\s*[0-9a-f]+:\s+(.*)$', L)
        if not m:
            continue
        t = m.group(1).strip()
        t = re.sub(r'\s*@.*$', '', t).strip()          # drop objdump comments
        t = re.sub(r'\s*//.*$', '', t).strip()
        if not t or t.startswith('...'):
            continue
        if t.startswith('.word') or t.startswith('.short') or t.startswith('.byte'):
            pool += 1                                   # literal pool, not code
            continue
        if t.startswith('(bad)'):
            pool += 1                                   # pool decoded as garbage
            continue
        body.append(t)
    return body, pool

# ---------------- ARM Thumb-2 / VFPv5 ----------------
ARM_FPARITH = re.compile(r'^(vadd|vsub|vmul|vdiv|vsqrt|vcmp|vcmpe|vcvt|vcvtr|vabs|vneg|vnml|vml|vmls|vmla|vfma|vfms|vfnm|vmax|vmin|vsel|vrint)')
ARM_FPLD    = re.compile(r'^(vldr|vldm|vpop)')
ARM_FPST    = re.compile(r'^(vstr|vstm|vpush)')
ARM_FPMOV   = re.compile(r'^(vmov|vmrs|vmsr)')
ARM_BR      = re.compile(r'^(b|bl|blx|bx|bne|beq|bcs|bcc|bmi|bpl|bvs|bvc|bhi|bls|bge|blt|bgt|ble|cbz|cbnz|tbb|tbh)(\.[nw])?$')
ARM_LD      = re.compile(r'^(ldr|ldrb|ldrh|ldrsb|ldrsh|ldrd|ldm|ldmia|ldmdb|pop)')
ARM_ST      = re.compile(r'^(str|strb|strh|strd|stm|stmia|stmdb|push)')

def cls_arm(t):
    mn = t.split()[0]
    base = mn.split('.')[0]
    if ARM_FPARITH.match(base): return 'FPARITH'
    if ARM_FPLD.match(base):    return 'FPLOAD'
    if ARM_FPST.match(base):    return 'FPSTORE'
    if ARM_FPMOV.match(base):
        # vmov with a memory operand does not exist on VFP; all are reg moves
        return 'FPMOV'
    if ARM_BR.match(mn) or ARM_BR.match(base): return 'BRANCH'
    if base.startswith('it'):   return 'IALU'   # IT block, folded
    if ARM_LD.match(base):      return 'ILOAD'
    if ARM_ST.match(base):      return 'ISTORE'
    return 'IALU'

# ---------------- x86-64 SSE2 ----------------
X_FPARITH = re.compile(r'^(v?)(add|sub|mul|div|sqrt|min|max|ucomi|comi|cvt|and|or|xor|andn)(ss|sd|ps|pd|si2ss|si2sd|tss2si|tsd2si|ss2sd|sd2ss)')
X_FPMOVLIKE = re.compile(r'^(v?)(mov)(ss|sd|aps|apd|ups|upd|d|q|lps|hps|lpd|hpd|ddup|sldup|shdup)')
X_UNPCK = re.compile(r'^(v?)(unpck|shuf|pshuf|blend|insert|extract|pxor|xorps|xorpd|andps|andpd|orps|orpd)')
X_BR = re.compile(r'^(j[a-z]+|call|ret|leave|loop|jmp)')

def cls_x86(t):
    parts = t.split()
    mn = parts[0]
    ops = ' '.join(parts[1:])
    if mn.startswith('rep') or mn in ('lock','data16','nopw','nopl','cs'):
        parts = parts[1:]
        if not parts: return 'IALU'
        mn = parts[0]; ops = ' '.join(parts[1:])
    memref = bool(re.search(r'\(%r|\(%e|0x[0-9a-f]+\(%|\(,%|%rip\)', ops))
    isfp = bool(re.match(r'^(v?)(mov(ss|sd|aps|apd|ups|upd|dqa|dqu)|add|sub|mul|div|sqrt|min|max|ucomi|comi|cvt|unpck|shuf|blend|pxor|xorps|xorpd|andps|andpd|orps|orpd|pshuf|movd|movq)', mn)) and ('%xmm' in ops)
    if X_FPARITH.match(mn) and '%xmm' in ops:
        # arithmetic with a memory source still does a load; count as arith+load
        return 'FPARITH+LOAD' if memref else 'FPARITH'
    if isfp:
        if X_FPMOVLIKE.match(mn) or mn in ('movd','movq'):
            if memref:
                # destination memory => store, else load
                dst = ops.split(',')[-1].strip()
                return 'FPSTORE' if not dst.startswith('%xmm') else 'FPLOAD'
            return 'FPMOV'
        if X_UNPCK.match(mn):
            return 'FPARITH+LOAD' if memref else 'FPMOV'
    if X_BR.match(mn): return 'BRANCH'
    if memref:
        if mn == 'lea': return 'IALU'
        dst = ops.split(',')[-1].strip()
        if re.match(r'^(mov|movz|movs)', mn):
            return 'ISTORE' if not dst.startswith('%') else 'ILOAD'
        return 'ILOAD'
    return 'IALU'

ORDER = ['FPARITH','FPMOV','FPLOAD','FPSTORE','ILOAD','ISTORE','BRANCH','IALU']

def tally(body, arch):
    c = collections.Counter()
    for t in body:
        k = cls_arm(t) if arch == 'arm' else cls_x86(t)
        if k == 'FPARITH+LOAD':
            c['FPARITH'] += 1; c['FPLOAD'] += 1
        else:
            c[k] += 1
    c['TOTAL'] = len(body)
    return c

if __name__ == '__main__':
    import os
    S = os.path.dirname(os.path.abspath(__file__))
    targets = [("voice_render", "juno_voice_render"),
               ("master_render", "juno_master_render"),
               ("juno_dsp", "juno_triangle")]
    res = {}
    for f, sym in targets:
        for arch, suf in (('arm','m7'), ('x86','x86')):
            b, pool = dis(f"{S}/{f}_{suf}.o", sym, arch)
            res[(sym, arch)] = tally(b, arch)
            res[(sym, arch)]['POOL'] = pool
    hdr = f"{'function':22s} {'arch':4s} " + ' '.join(f"{k:>8s}" for k in ORDER) + f" {'TOTAL':>8s}"
    print(hdr); print('-'*len(hdr))
    for f, sym in targets:
        for arch in ('x86','arm'):
            c = res[(sym, arch)]
            print(f"{sym:22s} {arch:4s} " + ' '.join(f"{c[k]:8d}" for k in ORDER) + f" {c['TOTAL']:8d}")
        print()
    # per-sample rollup
    print("PER-SAMPLE (8 x voice + 1 x master + 104 x triangle):")
    for arch in ('x86','arm'):
        tot = collections.Counter()
        for k in ORDER + ['TOTAL']:
            tot[k] = (8*res[('juno_voice_render',arch)][k]
                      + res[('juno_master_render',arch)][k]
                      + 104*res[('juno_triangle',arch)][k])
        print(f"  {arch:4s} " + ' '.join(f"{k}={tot[k]}" for k in ORDER+['TOTAL']))
