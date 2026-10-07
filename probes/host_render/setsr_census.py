"""Oracle-only census (CLAIMS B15): what the engine's construction and setSampleRate (CWaveGen
vt+8 BUILD rva 0x3C68D0, vt+24 rva 0x3C7A20) do to unit 0 -- every ramped set (cell, time index,
value), immediate set and direct write -- at a rate, and what a SECOND setSampleRate at another
rate (the plugin's first process() when vm.vs.sampleRate is not 96000) adds. Prints the counts
and the ramped sets; writes scratchpad/setsr_census.pkl.

    python3 probes/host_render/setsr_census.py [rate1 [rate2]]      (Unicorn only)"""
import os
import pickle
import struct
import sys

REPO = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.insert(0, os.path.join(REPO, 'tools', 'verify'))
import e2e_emu as E                      # noqa: E402
from unicorn import UC_HOOK_CODE          # noqa: E402
from unicorn.x86_const import UC_X86_REG_RCX, UC_X86_REG_RDX, UC_X86_REG_R8, UC_X86_REG_XMM2, UC_X86_REG_XMM3   # noqa: E402

WRAP, IMM = 0x3C2920, 0x3C2750
f32 = lambda b: struct.unpack('<f', struct.pack('<I', b))[0]


def main():
    r1 = float(sys.argv[1]) if len(sys.argv) > 1 else 96000.0
    r2 = float(sys.argv[2]) if len(sys.argv) > 2 else None
    e = E.E2E()
    ev = []
    st0 = {'p': None}

    def hook(uc_, addr, size, ud):
        st = st0['p']
        if st is None:
            # the first unit's state is the first 12 MB allocation BUILD makes
            sts = sorted(a for a, s in e.allocs if s == E.STATE_SZ)
            if not sts:
                return
            st = st0['p'] = sts[0]
        if uc_.reg_read(UC_X86_REG_RCX) != st:
            return
        di = uc_.reg_read(UC_X86_REG_RDX) & 0xFFFFFFFF
        desc = int.from_bytes(uc_.mem_read(st + 0x38, 8), 'little') + 40 * di
        cell = int.from_bytes(uc_.mem_read(desc + 0x20, 8), 'little') - st
        if addr - E.IB == WRAP:
            typ = int.from_bytes(uc_.mem_read(desc + 0xC, 4), 'little')
            ev.append(('R' if typ == 1 else 'N', cell, uc_.reg_read(UC_X86_REG_R8) & 0xFFFFFFFF,
                       uc_.reg_read(UC_X86_REG_XMM3) & 0xFFFFFFFF, len(ev)))
        else:
            ev.append(('I', cell, None, uc_.reg_read(UC_X86_REG_XMM2) & 0xFFFFFFFF, len(ev)))
    e.uc.hook_add(UC_HOOK_CODE, hook, begin=E.IB + WRAP, end=E.IB + WRAP)
    e.uc.hook_add(UC_HOOK_CODE, hook, begin=E.IB + IMM, end=E.IB + IMM)
    e.HOST = e.bump(0x8000)
    e.uc.mem_write(e.HOST, b'\0' * 0x8000)
    e.uc.mem_write(e.HOST + E.HOST_NVOICE, struct.pack('<i', 8))
    e.call(E.BUILD, rcx=e.HOST)
    n_build = len(ev)
    e.call_f(E.SETSR, e.HOST, r1)
    n_sr1 = len(ev)
    if r2:
        e.call_f(E.SETSR, e.HOST, r2)
    out = {'build': ev[:n_build], 'sr1': ev[n_build:n_sr1], 'sr2': ev[n_sr1:], 'r1': r1, 'r2': r2}
    for k in ('build', 'sr1', 'sr2'):
        kinds = {}
        for x in out[k]:
            kinds[x[0]] = kinds.get(x[0], 0) + 1
        print('%-5s %d sets %s' % (k, len(out[k]), kinds))
    rs = [x for x in out['sr1'] if x[0] in 'RN']
    tset = {}
    for x in rs:
        tset[x[2]] = tset.get(x[2], 0) + 1
    print('setSampleRate(%g) ramped sets by time index: %s' % (r1, dict(sorted(tset.items()))))
    print('first 30:', ' '.join('%s%d/t%d=%.5g' % (x[0], x[1], x[2], f32(x[3])) for x in rs[:30]))
    pickle.dump(out, open(os.path.join(REPO, 'scratchpad', 'setsr_census.pkl'), 'wb'))


if __name__ == '__main__':
    main()
