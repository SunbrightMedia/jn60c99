"""Oracle-only probe (CLAIMS B16): what the plugin's own process() does with MIDI controller
parameters, set by set, on every unit.

Boots the plugin as a host does (tools/verify/host_process_emu.py, product start, host 48000),
holds a key, then sends one MIDI-param point per block (VST3 MIDI mapping: id 0x0FFFC100 + n,
n = 0..127 CC, 128 channel aftertouch, 129 pitch bend). Logs every ramped set (rva 0x3C2920:
unit, cell, descriptor type, time index, value bits), immediate set (rva 0x3C2750) and host
entry call (rva 0x3C7AE0: id, value) during that block. Prints one line per set kind.
    python3 probes/host_midi/ctl_path_probe.py      (Unicorn only)"""
import collections
import os
import struct
import sys

REPO = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.insert(0, os.path.join(REPO, 'tools', 'verify'))
import host_process_emu as H            # noqa: E402
from unicorn import UC_HOOK_CODE        # noqa: E402
from unicorn.x86_const import (UC_X86_REG_RCX, UC_X86_REG_RDX, UC_X86_REG_R8,   # noqa: E402
                               UC_X86_REG_XMM2, UC_X86_REG_XMM3)

BASE = 0x0FFFC100
WRAP, IMM, HOSTE = 0x3C2920, 0x3C2750, 0x3C7AE0
h = H.HostProcess()
h.start(48000.0, 256)
uc = h.uc
q = lambda a: struct.unpack('<Q', uc.mem_read(a, 8))[0]
cur = {'on': False}
log = []


def unit_of(addr):
    for u in range(9):
        if addr == h.state[u]:
            return u
    return -1


def hook(uc_, addr, size, ud):
    if not cur['on']:
        return
    rva = addr - H.IB
    if rva == HOSTE:
        log.append(('H', uc_.reg_read(UC_X86_REG_RDX) & 0xFFFFFFFF, uc_.reg_read(UC_X86_REG_R8) & 0xFFFFFFFF))
        return
    st = uc_.reg_read(UC_X86_REG_RCX)
    u = unit_of(st)
    di = uc_.reg_read(UC_X86_REG_RDX) & 0xFFFFFFFF
    desc = q(st + 0x38) + 40 * di
    cell = q(desc + 0x20) - st
    typ = struct.unpack('<i', uc_.mem_read(desc + 0xC, 4))[0]
    if rva == WRAP:
        log.append(('R', u, cell, typ, uc_.reg_read(UC_X86_REG_R8) & 0xFFFFFFFF, uc_.reg_read(UC_X86_REG_XMM3) & 0xFFFFFFFF))
    else:
        log.append(('I', u, cell, typ, None, uc_.reg_read(UC_X86_REG_XMM2) & 0xFFFFFFFF))


for r in (WRAP, IMM, HOSTE):
    uc.hook_add(UC_HOOK_CODE, hook, begin=H.IB + r, end=H.IB + r)
h.process(256, events=[('on', 0, 0, 60, 0.8)])
h.process(256)
TESTS = [('bend -2048', 129, (8192 - 2048) / 16383.0), ('bend max', 129, 1.0), ('bend 0', 129, 0.0),
         ('mod 64', 1, 64 / 127.0), ('expr 100', 11, 100 / 127.0), ('pan 30', 10, 30 / 127.0),
         ('sust on', 64, 1.0), ('sust off', 64, 0.0), ('AT 90', 128, 90 / 127.0),
         ('cc3 (mapped)', 3, 0.5), ('cc74 (mapped)', 74, 0.25), ('cc2 (unmapped)', 2, 0.5),
         ('cc123', 123, 0.0)]
for name, n, v in TESTS:
    del log[:]
    cur['on'] = True
    h.process(256, params=[(BASE + n, 0, v)])
    cur['on'] = False
    kinds = collections.Counter((x[0],) + ((x[3], x[4]) if x[0] != 'H' else ()) for x in log)
    units = sorted(set(x[1] for x in log if x[0] != 'H'))
    cells = sorted(set(x[2] for x in log if x[0] != 'H' and x[1] == 0))
    hosts = [x[1:] for x in log if x[0] == 'H']
    vals = sorted(set(x[5] for x in log if x[0] != 'H'))
    print('%-16s sets %d kinds %s units %s unit0 cells %s values %s host %s' % (
        name, len(log), dict(kinds), units, cells[:20], ['0x%08x' % b for b in vals[:4]], hosts[:4]))
