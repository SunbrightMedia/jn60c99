#!/usr/bin/env python3
"""l3_cases.py -- L3 of the JUNO lift (docs/JUNO_LIFT.md): the work list of the per-instruction proof.

Every lifted statement SHIPPED in lift/jn_lift.c (parsed from the file, so the text under test IS the shipped text --
never a re-generation), keyed by (rva, statement); the instruction decoded from the plugin's own image (capstone);
its FORM (mnemonic + operand kinds and sizes); its defined output flags (Intel SDM: an undefined flag is not
compared -- tools/lift/l3_flags.py proves no reached code reads one); the state constraints the harness needs so the
instruction touches only mapped memory (a memory operand's base / index solved into the test window, the stack,
string-op pointers, divide operands that cannot fault). Writes build/l3/l3_cases.c (one C function per statement +
the case table, compiled with the product's own flags) and build/l3/l3_cases.json (the Unicorn side's list).

usage: python3 tools/lift/l3_cases.py [--all] [--tooth K]
  default: the statements whose rva the L1 census EXECUTED; --all: every non-trap statement of the lift.
  --tooth K: plant wrong semantic number K in its first matching statement (the prover MUST report it):
     1 cmp's subtract becomes an add (flags)   2 a jl becomes jle (control flow)   3 a mulss multiplies as an add
     4 a 32-bit load reads 16 bits (memory width)"""
import os
import re
import sys
import json
import argparse
import collections

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, os.path.join(REPO, 'tools', 'verify'))
import truth                                                       # noqa: E402
# image-generic (a later static lift, 2026-10-17): L3_BIN / L3_LIFT / L3_EXE point it at another plugin; unset, the JUNO
os.environ['LIFT_BIN'] = os.environ.get('L3_BIN') or truth.VST3
sys.path.insert(0, os.path.join(REPO, 'jp8', 'tools'))
import jp8_lift as L                                               # noqa: E402  (the lifter's own decoder + registers)
from capstone import x86                                           # noqa: E402

LIFT = os.environ.get('L3_LIFT') or os.path.join(REPO, 'lift', 'jn_lift.c')
EXE = os.environ.get('L3_EXE') or os.path.join(REPO, 'scratchpad', 'lift', 'juno_executed.json')
OUT = os.path.join(REPO, 'build', 'l3')
LINE = re.compile(r'^  /\*([0-9a-f]+) (.*?)\*/ (.*)$')
TRAP = re.compile(r'^jp8_trap\(c, 0x[0-9a-f]+, ".*"\);$')

# flags: bit 0 CF, 1 PF, 2 ZF, 3 SF, 4 OF (AF is never modelled and never read -- l3_flags.py)
ALL = 0x1F
FLAGDEF = {'mul': 0x11, 'imul': 0x11, 'div': 0, 'idiv': 0, 'bt': 0x05, 'bts': 0x05, 'btr': 0x05, 'btc': 0x05,
           'bsf': 0x04, 'bsr': 0x04}
SHIFTS = {'shl': 0, 'sal': 0, 'shr': 0, 'sar': 0, 'rol': 1, 'ror': 1, 'rcl': 1, 'rcr': 1}
STACK = {'push', 'pop', 'call', 'ret', 'leave'}
STRING = {'rep stosb', 'rep stosw', 'rep stosd', 'rep stosq', 'rep movsb', 'scasb', 'lodsd', 'stosb', 'movsb'}
FLOAT_LANES = ('ss', 'ps')
DOUBLE_LANES = ('sd', 'pd')


def form_of(ins):
    """mnemonic + operand kinds and sizes: 'add r32,imm8'"""
    ks = []
    for o in ins.operands:
        if o.type == x86.X86_OP_REG:
            n = ins.reg_name(o.reg)
            ks.append('x128' if n.startswith('xmm') else 'r%d' % (o.size * 8))
        elif o.type == x86.X86_OP_IMM:
            ks.append('imm%d' % (o.size * 8))
        else:
            m = o.mem
            pre = 'rip' if m.base == x86.X86_REG_RIP else ('gs' if m.segment and ins.reg_name(m.segment) == 'gs' else '')
            ks.append('%sm%d' % (pre, o.size * 8))
    return ins.mnemonic + ' ' + ','.join(ks)


def fpk_of(m):
    """lane kind for the edge values: 0 integer, 1 float lanes, 2 double lanes"""
    if m.startswith('cvt'):
        src = m[3:].split('2')[0].replace('t', '')
        return 2 if src in ('sd', 'pd') else 1 if src in ('ss', 'ps') else 0
    if m.endswith(DOUBLE_LANES) and m not in ('movsd',):
        return 2
    if m in ('movsd', 'comisd', 'ucomisd', 'maxsd', 'minsd', 'mulsd', 'addsd', 'subsd', 'divsd', 'sqrtsd'):
        return 2
    if m.endswith(FLOAT_LANES) or m in ('comiss', 'ucomiss', 'movss', 'movaps', 'movups', 'xorps', 'andps', 'orps',
                                         'unpcklps', 'movmskps'):
        return 1
    return 0


def describe(ins, stmt):
    """the harness's constraint record for one instruction (see l3_harness.c l3case)"""
    m = ins.mnemonic
    mb = mi = -1
    msc = msz = 0
    mdisp = 0
    mk = 0
    mem = [o for o in ins.operands if o.type == x86.X86_OP_MEM]
    if mem and m not in ('lea', 'nop') and not m.startswith('prefetch'):
        o = mem[0]; mm = o.mem
        msz = o.size or 1
        mdisp = mm.disp
        if mm.base == x86.X86_REG_RIP:
            mk = 2
        elif mm.segment and ins.reg_name(mm.segment) == 'gs':
            mk = 3
            if mm.base or mm.index:
                mk = 9                                             # gs + registers: not met in the plugin (asserted)
        else:
            mk = 1
            if mm.base:
                mb = L.reg(ins, mm.base)[0]
            if mm.index:
                mi = L.reg(ins, mm.index)[0]; msc = mm.scale
            if mb < 0 and mi < 0:
                mk = 9                                             # an absolute address: not met (asserted)
    stack = 1 if (m in STACK or m.startswith('bnd ') and m[4:] in STACK) else 0
    stack |= 1 if (mb == 4 or mi == 4) else 0
    strop = 1 if m in STRING else 0
    divk, divreg = 0, -1
    if m in ('div', 'idiv'):
        sz = ins.operands[0].size * 8
        divk = {('div', 32): 1, ('div', 64): 2, ('idiv', 32): 3, ('idiv', 64): 4}.get((m, sz), 9)
        if ins.operands[0].type == x86.X86_OP_REG:
            divreg = L.reg(ins, ins.operands[0].reg)[0]
        if divreg in (0, 2) or mb in (0, 2) or mi in (0, 2):
            divk = 9                                               # rax / rdx both dividend and divisor: not met
    base = m[5:] if m.startswith('lock ') else m[4:] if m.startswith('bnd ') else m
    shk, shimm, shsz = -1, -1, 0
    if base in SHIFTS:
        shk = SHIFTS[base]; shsz = ins.operands[0].size * 8
        if len(ins.operands) > 1 and ins.operands[1].type == x86.X86_OP_IMM:
            shimm = ins.operands[1].imm & 0xFF
        elif len(ins.operands) == 1:
            shimm = 1                                              # the one-operand form shifts by one
    ctl, ctlreg = 0, -1                                            # an indirect control transfer: its target must
    if base in ('jmp', 'call') and ins.operands[0].type == x86.X86_OP_REG:   # be canonical (else the CPU faults at
        ctl, ctlreg = 1, L.reg(ins, ins.operands[0].reg)[0]              # the instruction itself)
    elif base in ('jmp', 'call') and ins.operands[0].type == x86.X86_OP_MEM:
        ctl = 2
    elif base == 'ret':
        ctl = 3
    flagdef = FLAGDEF.get(base, ALL)
    if base in ('imul',):
        flagdef = 0x11
    return dict(mb=mb, mi=mi, msc=msc, msz=msz, mdisp=mdisp, mk=mk, stack=stack, str=strop, divk=divk,
                divreg=divreg, shk=shk, shimm=shimm, shsz=shsz, fpk=fpk_of(base), flagdef=flagdef,
                sp=1 if base == 'ldmxcsr' else 0, ctl=ctl, ctlreg=ctlreg,
                cases=[int(x, 16) for x in re.findall(r'case (0x[0-9a-f]+)ULL:', stmt)])


def plant(stmts, k):
    """a planted wrong semantic in the first matching statement: the proof must see it (returns its index)"""
    for i, (rva, ins, s) in enumerate(stmts):
        if k == 1 and ins.mnemonic == 'cmp' and 'op_sub(' in s:
            stmts[i] = (rva, ins, s.replace('op_sub(', 'op_add(', 1)); return i
        if k == 2 and ins.mnemonic == 'jl' and 'CC_L)' in s:
            stmts[i] = (rva, ins, s.replace('CC_L)', 'CC_LE)', 1)); return i
        if k == 3 and ins.mnemonic == 'mulss' and 'JP8_MULSS(' in s:
            stmts[i] = (rva, ins, s.replace('JP8_MULSS(', 'JP8_ADDSS(', 1)); return i
        if k == 4 and ins.mnemonic == 'mov' and re.search(r'=\(uint64_t\)\(M32\(', s) is None and \
                re.match(r'^R\(\d+\)=\(\(uint64_t\)\(M32\(', s):
            stmts[i] = (rva, ins, s.replace('M32(', 'M16(', 1)); return i
    raise SystemExit('tooth %d: no statement to plant it in' % k)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--all', action='store_true')
    ap.add_argument('--tooth', type=int, default=0)
    ap.add_argument('--out', default=OUT)
    ap.add_argument('--forms', default=None, help='m1,m2,..: only statements of these mnemonics (prove new lifter forms)')
    ap.add_argument('--chunk', default=None, help='i/n: the i-th of n equal slices of the work list (--all runs)')
    a = ap.parse_args()
    exe = set(json.load(open(EXE))) if os.path.exists(EXE) or not a.all else set()   # --all needs no census (static lift)
    seen, stmts, traps = set(), [], collections.Counter()
    for ln in open(LIFT):
        mt = LINE.match(ln)
        if not mt:
            continue
        rva = int(mt.group(1), 16); s = mt.group(3).rstrip()
        if mt.group(2) == 'hook':
            continue
        if TRAP.match(s):
            traps['executed' if rva in exe else 'not executed'] += 1
            continue
        if not a.all and rva not in exe:
            continue
        if (rva, s) in seen:
            continue
        seen.add((rva, s))
        ins = L.dis(rva)
        if a.forms and ins.mnemonic not in a.forms.split(','):
            continue
        stmts.append((rva, ins, s))
    if traps['executed']:
        raise SystemExit('L2 regression: %d executed instructions are lifted as traps' % traps['executed'])
    if a.chunk:
        ci, cn = (int(x) for x in a.chunk.split('/'))
        stmts = stmts[ci * len(stmts) // cn:(ci + 1) * len(stmts) // cn]
    tooth_i = plant(stmts, a.tooth) if a.tooth else -1
    os.makedirs(a.out, exist_ok=True)
    img = bytes(L.IMG)                                             # the image as mapped (both sides map it at its base)
    with open(os.path.join(a.out, 'image.bin'), 'wb') as fh:
        fh.write(img)
    import random
    with open(os.path.join(a.out, 'pool.bin'), 'wb') as fh:      # the memory windows' bytes: one seeded pool
        fh.write(random.Random(0x4C33).randbytes(1 << 20))
    forms = {}
    cases, fstubs, skipped = [], set(), []
    body = []
    for rva, ins, s in stmts:
        i = len(cases)
        f = form_of(ins)
        fid = forms.setdefault(f, len(forms))
        d = describe(ins, s)
        if d['mk'] == 9 or d['divk'] == 9:
            if not a.all:
                raise SystemExit('form not handled by the harness: %s at %#x (%s)' % (f, rva, s))
            skipped.append(dict(rva=rva, form=f, text=s[:120]))     # --all: named and counted, never silent
            continue
        fstubs.update(re.findall(r'\bf_([0-9a-f]+)\(c\)', s))
        t = re.sub(r'goto L_([0-9a-f]+);', lambda g: '{ T_GOTO(0x%sULL); return; }' % g.group(1), s)
        body.append('static void t_%d(CPU *c) { X t0, t1; uint64_t a0, a1; (void)t0; (void)t1; (void)a0; (void)a1; '
                    '%s T_FALL(); }' % (i, t))             # the locals every lifted function declares (lift_func)
        if d['cases']:
            body.append('static const uint64_t ct_%d[] = {%s};' % (i, ', '.join('0x%xULL' % x for x in d['cases'])))
        d.update(rva=rva, len=ins.size, form=fid, exe=int(rva in exe), mn=ins.mnemonic, text=s[:160])
        cases.append(d)
    src = ['/* GENERATED by tools/lift/l3_cases.py -- the SHIPPED statements of lift/jn_lift.c, one test function each.',
           ' * %d statements, %d forms%s. */' % (len(stmts), len(forms),
                                                  ', TOOTH %d planted in case %d' % (a.tooth, tooth_i) if a.tooth else ''),
           '#include "l3_rt.h"', 'const uint64_t l3_ib = 0x%xULL;' % L.IB]
    src += ['static void f_%s(CPU *c) { t_call(c, 0x%sULL + l3_ib); }' % (h, h) for h in sorted(fstubs)]
    src += body
    src.append('const l3case l3_cases[] = {')
    for i, d in enumerate(cases):
        src.append('  {t_%d, 0x%xULL, %d, %d, %d, %d, %d, %d, %d, %dLL, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, '
                   '%s, %d},' % (
            i, d['rva'], d['len'], d['exe'], d['form'], d['mb'], d['mi'], d['msc'], d['msz'], d['mdisp'], d['mk'],
            d['stack'], d['str'], d['divk'], d['divreg'], d['shk'], d['shimm'], d['shsz'], d['fpk'] * 256 + d['flagdef'],
            d['sp'], d['ctl'], d['ctlreg'], 'ct_%d' % i if d['cases'] else '0', len(d['cases'])))
    src.append('};')
    src.append('const int l3_ncases = %d;' % len(cases))
    with open(os.path.join(a.out, 'l3_cases.c'), 'w') as fh:
        fh.write('\n'.join(src) + '\n')
    keep = ('rva', 'len', 'form', 'exe', 'mn', 'mk', 'msz', 'mdisp', 'flagdef', 'shk', 'shimm', 'shsz', 'fpk', 'text')
    meta = dict(ib=L.IB, forms=sorted(forms, key=forms.get), cases=[{k: d[k] for k in keep} for d in cases],
                tooth=a.tooth, tooth_case=tooth_i, all=a.all, traps=dict(traps), skipped=skipped)
    with open(os.path.join(a.out, 'l3_cases.json'), 'w') as fh:
        json.dump(meta, fh)
    print('l3_cases: %d statements (%s%s), %d forms, %d call stubs, %d not testable by the harness; traps outside the '
          'census: %d%s -> %s' % (
        len(cases), 'all' if a.all else 'executed', ' chunk ' + a.chunk if a.chunk else '', len(forms), len(fstubs),
        len(skipped), traps['not executed'],
        ' TOOTH %d in case %d (%s)' % (a.tooth, tooth_i, stmts[tooth_i][1].mnemonic) if a.tooth else '', a.out))


if __name__ == '__main__':
    main()
