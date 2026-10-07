"""Oracle-only probe (CLAIMS B13b): every RAMPED set (rva 0x3C2920) and IMMEDIATE set (rva 0x3C2750)
the plugin's setSampleRate (rva 0x3C7A20) makes on a running engine, in order: unit, cell, value,
time index (ramped), the setSampleRate stage it happened in (vt3 = the processor's suspend, rva
0x3B86C0; 3BC980 = the effect container's setSampleRate; 3C2770 = the state's; vt5 = resume, rva
0x3B8560), the record's rate field at that moment, and the caller (the return address).
Configuration through setState before the switch: EFFECT / DELAY / REVERB TYPE, REVERB LEVEL (env EFX,
DLY, REV, REVLVL).
Writes scratchpad/setsr_sets_<tag>.pkl.

    EFX=2 DLY=1 REV=2 python3 probes/b13b/setsr_sets.py [patch] [setting] [host_rate] [tag]   (Unicorn only)"""
import os
import pickle
import struct
import sys

REPO = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.insert(0, os.path.join(REPO, 'tools', 'verify'))
import host_process_emu as H          # noqa: E402
import e2e_emu as E                   # noqa: E402
from unicorn import UC_HOOK_CODE      # noqa: E402
from unicorn.x86_const import (UC_X86_REG_RCX, UC_X86_REG_RDX, UC_X86_REG_R8, UC_X86_REG_XMM2,   # noqa: E402
                               UC_X86_REG_XMM3, UC_X86_REG_RSP)
from host_process_gate import HEADER, STRIDE, NAME   # noqa: E402

WRAP, IMM = 0x3C2920, 0x3C2750
STAGES = [(0x3C7A89, 'vt3'), (0x3C7A91, '3BC980'), (0x3C7A9D, '3C2770'), (0x3C7AA8, 'vt5')]
IDS = {'EFX': 0x00600258, 'DLY': 0x00600268, 'REV': 0x00600270, 'REVLVL': 0x0060005A}


def main():
    patch = int(sys.argv[1]) if len(sys.argv) > 1 else 9
    setting = int(sys.argv[2]) if len(sys.argv) > 2 else 2
    rate = float(sys.argv[3]) if len(sys.argv) > 3 else 48000.0
    tag = sys.argv[4] if len(sys.argv) > 4 else 'p%d_s%d' % (patch, setting)
    bank = E.bank_bytes()
    h = H.HostProcess()
    h.start(rate, 4096)
    q = lambda a: struct.unpack('<Q', h.uc.mem_read(a, 8))[0]
    st = {'on': False, 'stage': None}
    log = []
    unit_of = {}

    def on_entry(uc, addr, size, ud):
        st['on'] = True
        for u in range(9):
            unit_of[h.state[u]] = u

    def on_ret(uc, addr, size, ud):
        st['on'] = False

    def on_stage(uc, addr, size, ud):
        st['stage'] = dict(STAGES)[addr - E.IB]

    def on_set(uc, addr, size, ud):
        if not st['on']:
            return
        this = uc.reg_read(UC_X86_REG_RCX)
        if this not in unit_of:
            return
        di = uc.reg_read(UC_X86_REG_RDX) & 0xFFFFFFFF
        desc = q(this + 0x38) + 40 * di
        cell = q(desc + 0x20) - this
        ret = q(uc.reg_read(UC_X86_REG_RSP)) - E.IB
        if addr - E.IB == WRAP:
            typ = struct.unpack('<i', uc.mem_read(desc + 0xC, 4))[0]
            ri = struct.unpack('<i', uc.mem_read(desc + 0x14, 4))[0]
            rrate = struct.unpack('<I', uc.mem_read(q(this + 0x58) + 40 * ri + 0x18, 4))[0] if typ == 1 else None
            log.append(('R' if typ == 1 else 'N', st['stage'], unit_of[this], cell, uc.reg_read(UC_X86_REG_R8) & 0xFFFFFFFF,
                        uc.reg_read(UC_X86_REG_XMM3) & 0xFFFFFFFF, rrate, ret))
        else:
            log.append(('I', st['stage'], unit_of[this], cell, None, uc.reg_read(UC_X86_REG_XMM2) & 0xFFFFFFFF, None, ret))
    h.uc.hook_add(UC_HOOK_CODE, on_entry, begin=E.IB + 0x3C7A20, end=E.IB + 0x3C7A20)
    h.uc.hook_add(UC_HOOK_CODE, on_ret, begin=E.IB + 0x3C7AD3, end=E.IB + 0x3C7AD3)
    for a, _ in STAGES:
        h.uc.hook_add(UC_HOOK_CODE, on_stage, begin=E.IB + a, end=E.IB + a)
    h.uc.hook_add(UC_HOOK_CODE, on_set, begin=E.IB + WRAP, end=E.IB + WRAP)
    h.uc.hook_add(UC_HOOK_CODE, on_set, begin=E.IB + IMM, end=E.IB + IMM)
    rec = bank[HEADER + patch * STRIDE: HEADER + (patch + 1) * STRIDE]
    h.load_patch(rec[NAME:])
    cfg = [(IDS[k], int(os.environ[k])) for k in ('EFX', 'DLY', 'REV', 'REVLVL') if os.environ.get(k)]
    if cfg:
        pl = b''.join(struct.pack('>Ii', a, b) for a, b in cfg)
        if h.set_state(struct.pack('>I', len(pl)) + pl) != 0:
            raise SystemExit('setState failed')
    ev = lambda off, p, v: ('on', off, 0, p, v)
    h.process(256, events=[ev(0, 60, 0.8), ev(0, 64, 0.7)])
    for _ in range(int(os.environ.get('NBLK', '40'))):
        h.process(256)
    pl = struct.pack('>Ii', H.SAMPLERATE_ID, setting)
    if h.set_state(struct.pack('>I', len(pl)) + pl) != 0:
        raise SystemExit('setState failed')
    h.process(256)
    from collections import Counter
    print('%d sets: %s' % (len(log), dict(Counter((k, s) for k, s, *_ in log))))
    for e in log:
        if e[2] == 0 or e[2] == 8:
            k, s, u, cell, t, v, rr, ret = e
            print('%s %-6s u%d cell %9d t %-4s v %08x rec_rate %-8s caller %06x' % (
                k, s, u, cell, t, v, '%08x' % rr if rr is not None else '-', ret))
    p = os.path.join(REPO, 'scratchpad', 'setsr_sets_%s.pkl' % tag)
    pickle.dump({'patch': patch, 'setting': setting, 'host': rate, 'cfg': cfg, 'log': log}, open(p + '.partial', 'wb'))
    os.replace(p + '.partial', p)
    print('wrote', p)


if __name__ == '__main__':
    main()
