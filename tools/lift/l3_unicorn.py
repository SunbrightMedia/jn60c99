#!/usr/bin/env python3
"""l3_unicorn.py -- L3 of the JUNO lift (docs/JUNO_LIFT.md), the ORACLE side: every state the CPU side
(tools/lift/l3_harness.c) ran, read from its stream on stdin, run through Unicorn (the emulator under every oracle of
this project) for ONE instruction, compared with the REAL CPU's out-state. Unicorn only (two-process rule: the lifted
code runs in the harness's own process). The report per form: states, lift != CPU (the harness's verdict, carried in
the stream), Unicorn != CPU by field, and the known Unicorn deviations by class (a denormal Unicorn keeps where the
CPU flushed it: no FTZ, and min/max under DAZ; MXCSR exception flags never set).
usage: <harness> ... | python3 tools/lift/l3_unicorn.py [--cases build/l3/l3_cases.json] [--out report.json]"""
import os
import re
import sys
import json
import zlib
import struct
import argparse
import collections

from unicorn import Uc, UcError, UC_ARCH_X86, UC_MODE_64, UC_PROT_ALL
from unicorn import x86_const as X

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
WBASE, WSIZE, GBASE, GSIZE = 0x700000000, 0x2000, 0x580000000, 0x2000
GPR = [X.UC_X86_REG_RAX, X.UC_X86_REG_RCX, X.UC_X86_REG_RDX, X.UC_X86_REG_RBX, X.UC_X86_REG_RSP, X.UC_X86_REG_RBP,
       X.UC_X86_REG_RSI, X.UC_X86_REG_RDI, X.UC_X86_REG_R8, X.UC_X86_REG_R9, X.UC_X86_REG_R10, X.UC_X86_REG_R11,
       X.UC_X86_REG_R12, X.UC_X86_REG_R13, X.UC_X86_REG_R14, X.UC_X86_REG_R15]
XMM = [getattr(X, 'UC_X86_REG_XMM%d' % i) for i in range(16)]
IN = struct.Struct('<II16QQ256sIIII' + 'QII16s' * 2)
OUT = struct.Struct('<16QQQ256sIIQQ16sII')
assert IN.size == 480 and OUT.size == 448, (IN.size, OUT.size)
R_MXF = 32
# the KNOWN ways Unicorn 2.1.4 departs from the CPU (each one a single-instruction fact, printed per form): a denormal
# result or min / max operand it does not flush, the NaN it picks from two NaN operands, a bsf / bsr of zero
KNOWN = re.compile(r'^unicorn!=cpu (xmm:(denormal|nan|denormal\+nan)|gpr:bsf-zero)$')
KNOWN_LIFT = re.compile(r'^unicorn!=lift gpr:bsf-zero$')       # the gate flavor: only bsf of zero (integer code)
FIELDS = ('gpr', 'rip', 'flags', 'xmm', 'mxcsr', 'mem', 'gs', 'ea', 'fault')


def fl5(f):
    return (f & 1) | ((f >> 2 & 1) << 1) | ((f >> 6 & 1) << 2) | ((f >> 7 & 1) << 3) | ((f >> 11 & 1) << 4)


def defined_flags(k, r1):
    """the Intel SDM's defined output flags (tools/lift/l3_harness.c defined_flags, the same rules)"""
    d = k['flagdef']
    if k['shk'] >= 0:
        cnt = k['shimm'] if k['shimm'] >= 0 else r1 & 0xFF
        m = cnt & (63 if k['shsz'] == 64 else 31)
        if not m:
            return 0x1F
        d = 0x0F | (0x10 if m == 1 else 0)
        if k['shk'] == 0 and m >= k['shsz']:
            d &= ~1
    return d


def hsh(b):
    return (zlib.crc32(b) << 32) | zlib.adler32(b)


def flush_class(cpu, uni, fpk):
    """the class of an XMM difference, lane by lane: 'denormal' -- the CPU's lane is a signed zero where Unicorn's is a
    denormal of that sign (the CPU flushed it: FTZ, or min/max under DAZ; Unicorn keeps it); 'nan' -- both lanes are
    NaNs (two NaN operands: the CPU returns the FIRST source's, Unicorn another); else 'other' (a real difference)"""
    w = 8 if fpk == 2 else 4
    sign = 1 << (w * 8 - 1)
    expm = (0x7FF << 52) if w == 8 else (0xFF << 23)
    kinds = set()
    for o in range(0, len(cpu), w):                                # every lane of every register
        a, b = cpu[o:o + w], uni[o:o + w]
        if a == b:
            continue
        av, bv = int.from_bytes(a, 'little'), int.from_bytes(b, 'little')
        minv = (1 << 52) if w == 8 else (1 << 23)                    # the smallest normal
        if (av & ~sign) == 0 and (av & sign) == (bv & sign) and (((bv & expm) == 0 and (bv & ~sign)) or
                                                                  (bv & ~sign) == minv):
            kinds.add('denormal')                                   # the CPU flushed (FTZ / DAZ) a result Unicorn
            #                                                         kept: a denormal, or one rounded up to MIN
        elif (av & expm) == expm and (av & ~sign & ~expm) and (bv & expm) == expm and (bv & ~sign & ~expm):
            kinds.add('nan')
        else:
            return 'other'
    return '+'.join(sorted(kinds)) or 'other'


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--cases', default=os.path.join(REPO, 'build', 'l3', 'l3_cases.json'))
    ap.add_argument('--out', default=None)
    ap.add_argument('--tooth', action='store_true', help='flip one input bit for Unicorn in every 1000th state: '
                                                         'the comparison MUST report it')
    ap.add_argument('--dump', nargs=2, type=int, default=None, help='case state: print the XMM / GPR values')
    ap.add_argument('--dump-class', default=None, help="print the first states of a class (e.g. 'other')")
    ap.add_argument('--vs', choices=('cpu', 'lift'), default='cpu', help="what the stream's out-state is: the CPU's "
                    "(the product flavor's run) or the lift's (the gate flavor's run, --emit-lift: then Unicorn must "
                    "equal the lift except bsf of zero, which the lift keeps as the CPU does)")
    a = ap.parse_args()
    meta = json.load(open(a.cases))
    cases, forms = meta['cases'], meta['forms']
    d = os.path.dirname(a.cases)
    img = open(os.path.join(d, 'image.bin'), 'rb').read()
    pool = open(os.path.join(d, 'pool.bin'), 'rb').read()
    ib = meta['ib']
    uc = Uc(UC_ARCH_X86, UC_MODE_64)
    uc.mem_map(ib, (len(img) + 0xFFF) & ~0xFFF, UC_PROT_ALL)
    uc.mem_write(ib, img)
    uc.mem_map(WBASE, WSIZE, UC_PROT_ALL)
    uc.mem_map(GBASE, GSIZE, UC_PROT_ALL)
    uc.reg_write(X.UC_X86_REG_GS_BASE, GBASE)
    known = KNOWN if a.vs == 'cpu' else KNOWN_LIFT
    dumped = [0]
    stat = collections.defaultdict(lambda: collections.Counter())
    examples = collections.defaultdict(list)
    src = sys.stdin.buffer
    n = 0
    rec = IN.size + OUT.size
    while True:
        buf = src.read(rec * 256)
        if not buf:
            break
        if len(buf) % rec:
            raise SystemExit('stream cut mid-record (%d bytes)' % len(buf))
        for off in range(0, len(buf), rec):
            fi = IN.unpack_from(buf, off)
            fo = OUT.unpack_from(buf, off + IN.size)
            ci, si = fi[0], fi[1]
            r = list(fi[2:18]); fl = fi[18]; xin = fi[19]; mx, woff, goff, npatch = fi[20:24]
            patches = [(fi[24 + 4 * j], fi[25 + 4 * j], fi[27 + 4 * j]) for j in range(npatch)]
            orr = fo[0:16]; orip, ofl, ox, omx, ofault, owh, ogh, oea, lres, kind = fo[16:26]
            k = cases[ci]
            st = stat[k['form']]
            st['states'] += 1
            if lres & ~R_MXF:
                st['lift!=cpu'] += 1
            if a.tooth and n % 1000 == 999:
                r[0] ^= 1 << 3
            # memory: the window, the gs page, the patches; the image bytes under a rip operand saved
            uc.mem_write(WBASE, pool[woff:woff + WSIZE])
            uc.mem_write(GBASE, pool[goff:goff + GSIZE])
            ea = None
            if k['mk'] == 2:
                ea = ib + k['rva'] + k['len'] + k['mdisp']
                save = img[ea - ib:ea - ib + 16]
            for addr, ln, b in patches:
                uc.mem_write(addr, b[:ln])
            for i in range(16):
                uc.reg_write(GPR[i], r[i])
            uc.reg_write(X.UC_X86_REG_EFLAGS, (fl & 0x8D5) | 2)
            for i in range(16):
                uc.reg_write(XMM[i], int.from_bytes(xin[16 * i:16 * i + 16], 'little'))
            uc.reg_write(X.UC_X86_REG_MXCSR, mx)
            ufault = 0
            try:
                if k['mn'].startswith('rep '):                     # Unicorn counts ONE iteration of a rep as
                    uc.emu_start(ib + k['rva'], ib + k['rva'] + k['len'])  # an instruction: run it to its end
                else:
                    uc.emu_start(ib + k['rva'], 0, count=1)
            except UcError as e:
                ufault = e.errno or 1
            ur = [uc.reg_read(g) for g in GPR]
            urip = uc.reg_read(X.UC_X86_REG_RIP); ufl = uc.reg_read(X.UC_X86_REG_EFLAGS)
            ux = b''.join(uc.reg_read(XMM[i]).to_bytes(16, 'little') for i in range(16))
            umx = uc.reg_read(X.UC_X86_REG_MXCSR)
            uwh = hsh(bytes(uc.mem_read(WBASE, WSIZE))); ugh = hsh(bytes(uc.mem_read(GBASE, GSIZE)))
            uea = bytes(uc.mem_read(ea, 16)) if ea is not None else b'\0' * 16
            if ea is not None:
                uc.mem_write(ea, save)
            for addr, ln, b in patches:                            # a patch into the image: put the image back
                if ib <= addr < ib + len(img):
                    uc.mem_write(addr, img[addr - ib:addr - ib + ln])
            diff = []
            if (ufault != 0) != (ofault != 0):
                diff.append('fault')
            else:
                if list(orr) != ur:                                 # bsf / bsr of zero: the CPU keeps the
                    diff.append('gpr:bsf-zero' if k['mn'] in ('bsf', 'bsr') else 'gpr')   # register, Unicorn clears it
                if orip != urip:
                    diff.append('rip')
                if (fl5(ufl) ^ fl5(ofl)) & defined_flags(k, r[1]):
                    diff.append('flags')
                if ox != ux:                                        # judged in float lanes, then in double
                    cls = flush_class(ox, ux, 1)                    # lanes (a conversion's result lanes need
                    if cls == 'other':                              # not be its source's)
                        cls = flush_class(ox, ux, 2)
                    diff.append('xmm:' + cls)
                if (omx ^ umx) & ~0x3F:
                    diff.append('mxcsr')
                if (omx ^ umx) & 0x3F:
                    st['mxcsr-flags (excused)'] += 1
                if owh != uwh:
                    diff.append('mem')
                if ogh != ugh:
                    diff.append('gs')
                if ea is not None and oea != uea:
                    diff.append('ea')
            if a.dump_class and any(d.endswith(a.dump_class) for d in diff) and dumped[0] < 6:
                dumped[0] += 1
                print('CLASS %s case %d state %d %s mxcsr %#x' % (a.dump_class, ci, si, k['text'][:70], mx))
                for i in range(16):
                    xi, xo, xu = xin[16 * i:16 * i + 16], ox[16 * i:16 * i + 16], ux[16 * i:16 * i + 16]
                    if xi != xo or xo != xu:
                        print('  x%-2d in %s cpu %s uni %s' % (i, xi[::-1].hex(), xo[::-1].hex(), xu[::-1].hex()))
            if a.dump and (ci, si) == tuple(a.dump):
                print('DUMP case %d state %d %s mxcsr %#x: %s' % (ci, si, k['text'][:80], mx, diff))
                for i in range(16):
                    xi, xo, xu = xin[16 * i:16 * i + 16], ox[16 * i:16 * i + 16], ux[16 * i:16 * i + 16]
                    if xi != xo or xo != xu:
                        print('  x%-2d in %s cpu %s uni %s' % (i, xi[::-1].hex(), xo[::-1].hex(), xu[::-1].hex()))
                for i in range(16):
                    if orr[i] != ur[i] or r[i] != orr[i]:
                        print('  r%-2d in %016x cpu %016x uni %016x' % (i, r[i], orr[i], ur[i]))
                for addr, ln, b in patches:
                    print('  patch %#x: %s' % (addr, b[:ln][::-1].hex()))
            if diff:
                key = ('unicorn!=cpu ' if a.vs == 'cpu' else 'unicorn!=lift ') + '+'.join(diff)
                st[key] += 1
                if len(examples[k['form']]) < 3:
                    examples[k['form']].append(dict(case=ci, state=si, rva=hex(k['rva']), diff=diff, text=k['text'][:100]))
            n += 1
    rows = []
    for f in sorted(stat, key=lambda f: forms[f]):
        st = stat[f]
        bad = {kk: v for kk, v in st.items() if kk.startswith('unicorn!=') and not known.match(kk)}
        rows.append(dict(form=forms[f], **st, examples=examples.get(f, [])))
        if bad or (st['lift!=cpu'] and a.vs == 'cpu'):
            print('%-28s %6d states  lift!=cpu %4d  %s' % (forms[f], st['states'], st['lift!=cpu'],
                                                           ' '.join('%s:%d' % kv for kv in st.items()
                                                                    if kv[0].startswith('unicorn'))))
    tot = collections.Counter()
    for st in stat.values():
        tot.update(st)
    unknown = sum(v for kk, v in tot.items() if kk.startswith('unicorn!=') and not known.match(kk))
    fmt = ('L3 oracle side: %d states, %d forms; lift != CPU in %d states; Unicorn != ' +
           ('CPU' if a.vs == 'cpu' else 'lift') + ': %s; outside the known Unicorn classes: %d')
    print(fmt % (n, len(stat), tot['lift!=cpu'], ', '.join('%s %d' % (kk.split(' ', 1)[1], v) for kk, v in
                                                            sorted(tot.items()) if kk.startswith('unicorn')) or 'none',
                 unknown))
    if a.out:
        json.dump(dict(states=n, forms=rows, total=dict(tot), unknown=unknown), open(a.out, 'w'), indent=1)
    return 1 if (unknown or (tot['lift!=cpu'] and a.vs == 'cpu')) and not a.tooth else 0


if __name__ == '__main__':
    sys.exit(main())
